/*
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

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>

#ifdef WIN32
#include <io.h>
#endif

//
// Legacy global variables
//

MapServer*                      gMapServer;
std::unique_ptr<SqlConnection>  _sql;
extern std::map<uint16, CZone*> g_PZoneList; // Global array of pointers for zones

std::unordered_map<uint32, std::unordered_map<uint16, std::vector<std::pair<uint16, uint8>>>> PacketMods;

MapServer::MapServer(int argc, char** argv)
: Application("map", argc, argv)
, networking_(std::make_unique<MapNetworking>(*this))
, mapStatistics_(std::make_unique<MapStatistics>())
{
    // TODO: Get rid of this
    gMapServer = this;

    do_init();
}

MapServer::~MapServer() = default;

void MapServer::loadConsoleCommands()
{
    // clang-format off
    consoleService_->RegisterCommand("gm", "Change a character's GM level.",
    [](std::vector<std::string>& inputs)
    {
        if (inputs.size() != 3)
        {
            fmt::print("Usage: gm <char_name> <level>. example: gm Testo 1\n");
            return;
        }

        auto  name  = inputs[1];
        auto* PChar = zoneutils::GetCharByName(name);
        if (!PChar)
        {
            fmt::print("Couldnt find character: {}\n", name);
            return;
        }

        auto level = std::clamp<uint8>(static_cast<uint8>(stoi(inputs[2])), 0, 5);

        PChar->m_GMlevel = level;

        // NOTE: This is the same logic as charutils::SaveCharGMLevel(PChar);
        // But we're not executing on the main thread, so we're doing it with
        // our own SQL connection.
        {
            auto otherSql  = std::make_unique<SqlConnection>();
            auto query = "UPDATE %s SET %s %u WHERE charid = %u";
            otherSql->Query(query, "chars", "gmlevel =", PChar->m_GMlevel, PChar->id);
        }

        fmt::print("> Promoting {} to GM level {}\n", PChar->name, level);
        PChar->pushPacket<CChatMessagePacket>(PChar, MESSAGE_SYSTEM_3, fmt::format("You have been set to GM level {}.", level));
    });

    consoleService_->RegisterCommand("reload_recipes", "Reload crafting recipes.",
    [&](std::vector<std::string>& inputs)
    {
        fmt::print("> Reloading crafting recipes\n");
        synthutils::LoadSynthRecipes();
    });
    // clang-format on
}

void MapServer::prepareWatchdog()
{
    // clang-format off
    auto period   = settings::get<uint32>("main.INACTIVITY_WATCHDOG_PERIOD");
    auto periodMs = (period > 0) ? std::chrono::milliseconds(period) : 2000ms;

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
            std::this_thread::sleep_for(std::chrono::milliseconds(200));

            throw std::runtime_error("Watchdog thread time exceeded. Killing process.");
        }
    });
    // clang-format on
}

void MapServer::run()
{
    Application::markLoaded();

    // Main runtime cycle
    {
        duration next = std::chrono::milliseconds(200); // TODO: MapConstants

        while (Application::isRunning())
        {
            next = CTaskMgr::getInstance()->DoTimer(server_clock::now());
            networking_->doSockets(next);
            watchdog_->update();
        }
    }

    do_final();
}

int32 MapServer::do_init()
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

    ShowInfoFmt("Zones assigned to this process: {}", zoneutils::GetZonesAssignedToThisProcess().size());

    ShowInfo(fmt::format("Random samples (integer): {}", utils::getRandomSampleString(0, 255)));
    ShowInfo(fmt::format("Random samples (float): {}", utils::getRandomSampleString(0.0f, 1.0f)));

    // TODO: Get rid of legacy _sql and SqlConnection
    ShowInfo("do_init: connecting to database");
    _sql = std::make_unique<SqlConnection>();

    ShowInfo(fmt::format("database name: {}", db::getDatabaseSchema()).c_str());
    ShowInfo(fmt::format("database server version: {}", db::getDatabaseVersion()).c_str());
    ShowInfo(fmt::format("database client version: {}", db::getDriverVersion()).c_str());
    db::checkCharset();
    db::checkTriggers();

    luautils::init(); // Also calls moduleutils::LoadLuaModules();

    PacketParserInitialize();

    _sql->Query("DELETE FROM accounts_sessions WHERE IF(%u = 0 AND %u = 0, true, server_addr = %u AND server_port = %u)",
                mapIPP.getIP(), mapIPP.getPort(), mapIPP.getIP(), mapIPP.getPort());

    ShowInfo("do_init: zlib is reading");
    zlib_init();

    ShowInfo("do_init: starting ZMQ thread");
    message::init();

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
    zoneutils::LoadZoneList();

    fishingutils::InitializeFishingSystem();
    instanceutils::LoadInstanceList();

    monstrosity::LoadStaticData();

    // const auto udpPort = gMapIPP.getPort() == 0 ? settings::get<uint16>("network.MAP_PORT") : gMapIPP.getPort();
    // gMapSocket         = std::make_unique<MapSocket>(udpPort);

    CVanaTime::getInstance()->setCustomEpoch(settings::get<int32>("map.VANADIEL_TIME_EPOCH"));

    zoneutils::InitializeWeather(); // Need VanaTime initialized

    CTransportHandler::getInstance()->InitializeTransport();

    CTaskMgr::getInstance()->AddTask("time_server", server_clock::now(), nullptr, CTaskMgr::TASK_INTERVAL, 2400ms, time_server);
    // CTaskMgr::getInstance()->AddTask("map_cleanup", server_clock::now(), nullptr, CTaskMgr::TASK_INTERVAL, 5s, &map_cleanup);
    // CTaskMgr::getInstance()->AddTask("garbage_collect", server_clock::now(), nullptr, CTaskMgr::TASK_INTERVAL, 15min, &map_garbage_collect);
    CTaskMgr::getInstance()->AddTask("persist_server_vars", server_clock::now(), nullptr, CTaskMgr::TASK_INTERVAL, 1min, serverutils::PersistVolatileServerVars);

    zoneutils::TOTDChange(CVanaTime::getInstance()->GetCurrentTOTD()); // This tells the zones to spawn stuff based on time of day conditions (such as undead at night)

    ShowInfo("do_init: Removing expired database variables");
    uint32 currentTimestamp = CVanaTime::getInstance()->getSysTime();
    db::preparedStmt("DELETE FROM char_vars WHERE expiry > 0 AND expiry <= ?", currentTimestamp);
    db::preparedStmt("DELETE FROM server_variables WHERE expiry > 0 AND expiry <= ?", currentTimestamp);

    PacketGuard::Init();

    moduleutils::OnInit();

    luautils::OnServerStart();

    moduleutils::ReportLuaModuleUsage();

    db::enableTimers();

    prepareWatchdog();

#ifdef TRACY_ENABLE
    ShowInfo("*** TRACY IS ENABLED ***");
#endif // TRACY_ENABLE

    return 0;
}

void MapServer::do_final()
{
    TracyZoneScoped;

    consoleService_->stop();

    ability::CleanupAbilitiesList();
    itemutils::FreeItemList();
    battleutils::FreeWeaponSkillsList();
    battleutils::FreeMobSkillList();
    battleutils::FreePetSkillList();
    fishingutils::CleanupFishing();
    guildutils::Cleanup();
    mobutils::Cleanup();
    traits::ClearTraitsList();

    petutils::FreePetList();
    trustutils::FreeTrustList();
    zoneutils::FreeZoneList();

    CTaskMgr::delInstance();
    CVanaTime::delInstance();
    Async::delInstance();

    timer_final();

    luautils::cleanup();
    logging::ShutDown();

    // if (code != EXIT_SUCCESS)
    // {
    //     std::exit(code);
    // }
}

int32 MapServer::map_cleanup(time_point tick, CTaskMgr::CTask* PTask)
{
    TracyZoneScoped;

    networking().sessions().cleanupSessions();

    // clang-format off
    zoneutils::ForEachZone([](CZone* PZone)
    {
        PZone->GetZoneEntities()->EraseStaleDynamicTargIDs();
    });
    // clang-format on

    return 0;
}

int32 MapServer::map_garbage_collect(time_point tick, CTaskMgr::CTask* PTask)
{
    TracyZoneScoped;

    ShowInfo("CTaskMgr Active Tasks: %i", CTaskMgr::getInstance()->getTaskList().size());

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
