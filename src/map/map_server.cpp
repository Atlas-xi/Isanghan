﻿/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "map_server.h"

#include "common/async.h"
#include "common/blowfish.h"
#include "common/console_service.h"
#include "common/database.h"
#include "common/debug.h"
#include "common/ipp.h"
#include "common/logging.h"
#include "common/macros.h"
#include "common/settings.h"
#include "common/timer.h"
#include "common/utils.h"
#include "common/vana_time.h"
#include "common/version.h"
#include "common/zlib.h"

#include "ability.h"
#include "daily_system.h"
#include "ipc_client.h"
#include "job_points.h"
#include "latent_effect_container.h"
#include "linkshell.h"
#include "map_networking.h"
#include "map_statistics.h"
#include "mob_spell_list.h"
#include "monstrosity.h"
#include "packet_guard.h"
#include "packet_system.h"
#include "roe.h"
#include "spell.h"
#include "status_effect_container.h"
#include "time_server.h"
#include "transport.h"
#include "zone.h"
#include "zone_entities.h"

#include "ai/controllers/automaton_controller.h"

#include "items/item_equipment.h"

#include "packets/basic.h"
#include "packets/chat_message.h"
#include "packets/server_ip.h"

#include "utils/battleutils.h"
#include "utils/charutils.h"
#include "utils/fishingutils.h"
#include "utils/gardenutils.h"
#include "utils/guildutils.h"
#include "utils/instanceutils.h"
#include "utils/itemutils.h"
#include "utils/mobutils.h"
#include "utils/moduleutils.h"
#include "utils/petutils.h"
#include "utils/serverutils.h"
#include "utils/synergyutils.h"
#include "utils/synthutils.h"
#include "utils/trustutils.h"
#include "utils/zoneutils.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>

#ifdef _WIN32
#include <io.h>
#endif

//
// Legacy global variables
//

// TODO: These are all hacks and shouldn't be globally exposed like this!

std::unique_ptr<SqlConnection>  _sql;
extern std::map<uint16, CZone*> g_PZoneList; // Global array of pointers for zones

MapServer::MapServer(int argc, char** argv)
: Application("map", argc, argv)
, mapStatistics_(std::make_unique<MapStatistics>())
, networking_(std::make_unique<MapNetworking>(*this, *mapStatistics_))
{
    do_init();
}

MapServer::~MapServer()
{
    do_final();
}

void MapServer::loadConsoleCommands()
{
    // clang-format off
    consoleService_->registerCommand("gm", "Change a character's GM level",
    [](std::vector<std::string>& inputs)
    {
        if (inputs.size() != 3)
        {
            fmt::print("Usage: gm <char_name> <level>. example: gm Testo 1\n");
            return;
        }

        const auto name  = inputs[1];
        auto*      PChar = zoneutils::GetCharByName(name);
        if (!PChar)
        {
            fmt::print("Couldnt find character: {}\n", name);
            return;
        }

        const auto level = std::clamp<uint8>(static_cast<uint8>(stoi(inputs[2])), 0, 5);

        PChar->m_GMlevel = level;

        charutils::SaveCharGMLevel(PChar);

        fmt::print("> Promoting {} to GM level {}\n", PChar->name, level);
        PChar->pushPacket<CChatMessagePacket>(PChar, MESSAGE_SYSTEM_3, fmt::format("You have been set to GM level {}.", level));
    });

    consoleService_->registerCommand("reload_recipes", "Reload crafting recipes",
    [&](std::vector<std::string>& inputs)
    {
        fmt::print("> Reloading crafting recipes\n");
        synthutils::LoadSynthRecipes();
    });

    consoleService_->registerCommand("stats", "Print runtime stats",
    [&](std::vector<std::string>& inputs)
    {
        mapStatistics_->print();
    });

    consoleService_->registerCommand("backtrace", "Print backtrace",
    [&](std::vector<std::string>& inputs)
    {
        const auto backtrace = logging::GetBacktrace();
        for (const auto& line : backtrace)
        {
            fmt::print("{}\n", line);
        }
    });
    // clang-format on
}

void MapServer::prepareWatchdog()
{
    auto period = settings::get<uint32>("main.INACTIVITY_WATCHDOG_PERIOD");

    if (Application::isRunningInCI())
    {
        // Double the timer period, to account for the slower CI environment
        period *= 2;
    }

    const auto periodMs = (period > 0) ? std::chrono::milliseconds(period) : 2000ms;

    // clang-format off
    watchdog_ = std::make_unique<Watchdog>(periodMs, [period]()
    {
        if (debug::isRunningUnderDebugger())
        {
            ShowCritical("!!! INACTIVITY WATCHDOG HAS TRIGGERED !!!");
            ShowCriticalFmt("Process main tick has taken {}ms or more.", period);
            ShowCritical("Detaching watchdog thread, it will not fire again until restart.");
        }
        else if (!settings::get<bool>("main.DISABLE_INACTIVITY_WATCHDOG"))
        {
            std::string outputStr = "!!! INACTIVITY WATCHDOG HAS TRIGGERED !!!\n\n";

            outputStr += fmt::format("Process main tick has taken {}ms or more.\n", period);
            outputStr += fmt::format("Backtrace Messages:\n\n");

            const auto backtrace = logging::GetBacktrace();
            for (const auto& line : backtrace)
            {
                outputStr += fmt::format("    {}\n", line);
            }

            outputStr += "\nKilling Process!!!\n";

            ShowCritical(outputStr);

            // Allow some time for logging to flush
            std::this_thread::sleep_for(200ms);

            throw std::runtime_error("Watchdog thread time exceeded. Killing process.");
        }
    });
    // clang-format on
}

void MapServer::run()
{
    Application::markLoaded();

    while (Application::isRunning())
    {
        timer::duration tasksDuration;
        timer::duration networkDuration;
        timer::duration tickDuration;

        const auto tickStart = timer::now();
        {
            tasksDuration = CTaskManager::getInstance()->doExpiredTasks(tickStart);
            // Use tick remainder for networking with a maximum to ensure that the network phase
            // doesn't starve and a minimum to prevent bumping up against the time limit.
            networkDuration = networking_->doSocketsBlocking(kMainLoopInterval - std::clamp<timer::duration>(tasksDuration, 50ms, 150ms));
        }
        tickDuration = timer::now() - tickStart;

        const auto tickDiffTime = kMainLoopInterval - tickDuration;

        mapStatistics_->set(MapStatistics::Key::TasksTickTime, timer::count_milliseconds(tasksDuration));
        mapStatistics_->set(MapStatistics::Key::NetworkTickTime, timer::count_milliseconds(networkDuration));
        mapStatistics_->set(MapStatistics::Key::TotalTickTime, timer::count_milliseconds(tickDuration));
        mapStatistics_->set(MapStatistics::Key::TickDiffTime, timer::count_milliseconds(tickDiffTime));
        mapStatistics_->flush();

        DebugPerformanceFmt("Tasks: {}ms, Network: {}ms, Total: {}ms, Diff/Sleep: {}ms",
                            timer::count_milliseconds(tasksDuration),
                            timer::count_milliseconds(networkDuration),
                            timer::count_milliseconds(tickDuration),
                            timer::count_milliseconds(tickDiffTime));

        watchdog_->update();

        if (tickDiffTime > 0ms)
        {
            std::this_thread::sleep_for(tickDiffTime);
        }
        else if (tickDiffTime < -kMainLoopBacklogThreshold)
        {
            RATE_LIMIT(15s, ShowWarningFmt("Main loop is running {}ms behind, performance is degraded!", -timer::count_milliseconds(tickDiffTime)));
        }
    }
}

void MapServer::do_init()
{
    TracyZoneScoped;

#ifdef TRACY_ENABLE
    ShowInfo("*** TRACY IS ENABLED ***");
#endif // TRACY_ENABLE

    ShowInfo(fmt::format("Last Branch: {}", version::GetGitBranch()));
    ShowInfo(fmt::format("SHA: {} ({})", version::GetGitSha(), version::GetGitDate()));

    ShowInfo("do_init: begin server initialization");

    const auto mapIPP = networking_->ipp();

    ShowInfoFmt("map_ip: {}", mapIPP.getIPString());
    ShowInfoFmt("map_port: {}", mapIPP.getPort());

    ShowInfoFmt("Zones assigned to this process: {}", zoneutils::GetZonesAssignedToThisProcess(mapIPP).size());

    ShowInfo(fmt::format("Random samples (integer): {}", utils::getRandomSampleString(0, 255)));
    ShowInfo(fmt::format("Random samples (float): {}", utils::getRandomSampleString(0.0f, 1.0f)));

    // TODO: Get rid of legacy _sql and SqlConnection
    ShowInfo("do_init: connecting to database");
    _sql = std::make_unique<SqlConnection>();

    ShowInfo(fmt::format("database name: {}", db::getDatabaseSchema()).c_str());
    ShowInfo(fmt::format("database server version: {}", db::getDatabaseVersion()).c_str());
    ShowInfo(fmt::format("database client version: {}", db::getDriverVersion()).c_str());

    if (!isRunningInCI())
    {
        db::checkCharset();
    }

    db::checkTriggers();

    luautils::init(mapIPP, isRunningInCI()); // Also calls moduleutils::LoadLuaModules();

    PacketParserInitialize();

    // Delete sessions that are associated with this map process, but leave others alone
    db::preparedStmt("DELETE FROM accounts_sessions WHERE IF(? = 0 AND ? = 0, true, server_addr = ? AND server_port = ?)",
                     mapIPP.getIP(), mapIPP.getPort(), mapIPP.getIP(), mapIPP.getPort());

    ShowInfo("do_init: zlib is reading");
    zlib_init();

    ShowInfo("do_init: starting ZMQ thread");
    message::init(networking());

    ShowInfo("do_init: loading items");
    itemutils::Initialize();

    ShowInfo("do_init: loading plants");
    gardenutils::Initialize();

    ShowInfo("do_init: loading spells");
    spell::LoadSpellList();
    mobSpellList::LoadMobSpellList();
    automaton::LoadAutomatonSpellList();
    automaton::LoadAutomatonAbilities();

    guildutils::Initialize();
    charutils::LoadExpTable();
    traits::LoadTraitsList();
    effects::LoadEffectsParameters();
    battleutils::LoadSkillTable();
    meritNameSpace::LoadMeritsList();
    ability::LoadAbilitiesList();
    battleutils::LoadWeaponSkillsList();
    battleutils::LoadMobSkillsList();
    battleutils::LoadPetSkillsList();
    battleutils::LoadSkillChainDamageModifiers();
    petutils::LoadPetList();
    trustutils::LoadTrustList();
    mobutils::LoadSqlModifiers();
    jobpointutils::LoadGifts();
    daily::LoadDailyItems();
    roeutils::UpdateUnityRankings();
    synthutils::LoadSynthRecipes();
    synergyutils::LoadSynergyRecipes();
    CItemEquipment::LoadAugmentData(); // TODO: Move to itemutils

    if (!std::filesystem::exists("./navmeshes/") || std::filesystem::is_empty("./navmeshes/"))
    {
        ShowInfo("./navmeshes/ directory isn't present or is empty");
    }

    if (!std::filesystem::exists("./losmeshes/") || std::filesystem::is_empty("./losmeshes/"))
    {
        ShowInfo("./losmeshes/ directory isn't present or is empty");
    }

    ShowInfo("do_init: loading zones");
    zoneutils::LoadZoneList(mapIPP);

    fishingutils::InitializeFishingSystem();
    instanceutils::LoadInstanceList(mapIPP);

    monstrosity::LoadStaticData();

    zoneutils::InitializeWeather(); // Need VanaTime initialized

    CTransportHandler::getInstance()->InitializeTransport(mapIPP);

    CTaskManager::getInstance()->AddTask("time_server", timer::now(), nullptr, CTaskManager::TASK_INTERVAL, kTimeServerTickInterval, time_server);
    CTaskManager::getInstance()->AddTask("map_cleanup", timer::now(), nullptr, CTaskManager::TASK_INTERVAL, 5s, std::bind(&MapServer::map_cleanup, this, std::placeholders::_1, std::placeholders::_2));
    CTaskManager::getInstance()->AddTask("garbage_collect", timer::now(), nullptr, CTaskManager::TASK_INTERVAL, 15min, std::bind(&MapServer::map_garbage_collect, this, std::placeholders::_1, std::placeholders::_2));
    CTaskManager::getInstance()->AddTask("persist_server_vars", timer::now(), nullptr, CTaskManager::TASK_INTERVAL, 1min, serverutils::PersistVolatileServerVars);

    zoneutils::TOTDChange(vanadiel_time::get_totd()); // This tells the zones to spawn stuff based on time of day conditions (such as undead at night)

    ShowInfo("do_init: Removing expired database variables");
    uint32 currentTimestamp = earth_time::timestamp();
    db::preparedStmt("DELETE FROM char_vars WHERE expiry > 0 AND expiry <= ?", currentTimestamp);
    db::preparedStmt("DELETE FROM server_variables WHERE expiry > 0 AND expiry <= ?", currentTimestamp);

    PacketGuard::Init();

    moduleutils::OnInit();

    luautils::OnServerStart();

    moduleutils::ReportLuaModuleUsage();

    _sql->EnableTimers();
    db::enableTimers();

    prepareWatchdog();

#ifdef TRACY_ENABLE
    ShowInfo("*** TRACY IS ENABLED ***");
#endif // TRACY_ENABLE
}

void MapServer::do_final()
{
    TracyZoneScoped;

    itemutils::FreeItemList();
    battleutils::FreeWeaponSkillsList();
    battleutils::FreeMobSkillList();
    battleutils::FreePetSkillList();
    fishingutils::CleanupFishing();
    guildutils::Cleanup();
    mobutils::Cleanup();
    traits::ClearTraitsList();

    petutils::FreePetList();
    zoneutils::FreeZoneList();

    CTaskManager::delInstance();
    Async::delInstance();

    luautils::cleanup();
    logging::ShutDown();
}

int32 MapServer::map_cleanup(timer::time_point tick, CTaskManager::CTask* PTask)
{
    TracyZoneScoped;

    networking().sessions().cleanupSessions(networking().ipp());

    // clang-format off
    zoneutils::ForEachZone([](CZone* PZone)
    {
        PZone->GetZoneEntities()->EraseStaleDynamicTargIDs();
    });
    // clang-format on

    return 0;
}

int32 MapServer::map_garbage_collect(timer::time_point tick, CTaskManager::CTask* PTask)
{
    TracyZoneScoped;

    ShowInfo("CTaskManager Active Tasks: %i", CTaskManager::getInstance()->getTaskList().size());

    luautils::garbageCollectFull();
    return 0;
}

auto MapServer::networking() -> MapNetworking&
{
    return *networking_;
}

auto MapServer::statistics() -> MapStatistics&
{
    return *mapStatistics_;
}

auto MapServer::zones() -> std::map<uint16, CZone*>&
{
    return g_PZoneList;
}
