/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

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

#include "map_statistics.h"

#include "common/tracy.h"

void MapStatistics::reportToTracy()
{
    /*
    TracyReportLuaMemory(lua.lua_state());

    std::size_t activeZoneCount       = 0;
    std::size_t playerCount           = 0;
    std::size_t mobCount              = 0;
    std::size_t dynamicTargIdCount    = 0;
    std::size_t dynamicTargIdCapacity = 0;

    for (auto& [id, PZone] : g_PZoneList)
    {
        if (PZone->IsZoneActive())
        {
            activeZoneCount += 1;
            playerCount += PZone->GetZoneEntities()->GetCharList().size();
            mobCount += PZone->GetZoneEntities()->GetMobList().size();
            dynamicTargIdCount += PZone->GetZoneEntities()->GetUsedDynamicTargIDsCount();
            dynamicTargIdCapacity += 511;
        }
    }

    TracyReportGraphNumber("Active Zones (Process)", static_cast<std::int64_t>(activeZoneCount));
    TracyReportGraphNumber("Connected Players (Process)", static_cast<std::int64_t>(playerCount));
    TracyReportGraphNumber("Active Mobs (Process)", static_cast<std::int64_t>(mobCount));
    TracyReportGraphNumber("Task Manager Tasks", static_cast<std::int64_t>(CTaskMgr::getInstance()->getTaskList().size()));

    TracyReportGraphPercent("Dynamic Entity TargID Capacity Usage Percent", static_cast<double>(dynamicTargIdCount) / static_cast<double>(dynamicTargIdCapacity));

    TracyReportGraphNumber("Total Packets To Send Per Tick", static_cast<std::int64_t>(TotalPacketsToSendPerTick));
    TracyReportGraphNumber("Total Packets Sent Per Tick", static_cast<std::int64_t>(TotalPacketsSentPerTick));
    TracyReportGraphNumber("Total Packets Delayed Per Tick", static_cast<std::int64_t>(TotalPacketsDelayedPerTick));

    TotalPacketsToSendPerTick  = 0;
    TotalPacketsSentPerTick    = 0;
    TotalPacketsDelayedPerTick = 0;
    */
}
