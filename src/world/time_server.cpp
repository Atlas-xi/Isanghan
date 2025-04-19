/*
===========================================================================

  Copyright (c) 2023 LandSandBoat Dev Teams

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

#include "time_server.h"

#include "common/cbasetypes.h"
#include "common/task_manager.h"
#include "common/tracy.h"
#include "common/vana_time.h"

#include "conquest_system.h"
#include "daily_tally.h"
#include "world_server.h"

int32 time_server(timer::time_point tick, CTaskManager::CTask* PTask)
{
    TracyZoneScoped;

    TIMETYPE     VanadielTOTD = CVanaTime::getInstance()->SyncTime();
    WorldServer* worldServer  = std::any_cast<WorldServer*>(PTask->m_data);
    auto         currentTime  = earth_time::now();
    auto         jstMinute    = earth_time::jst::get_minute(currentTime);
    auto         jstHour      = earth_time::jst::get_hour(currentTime);
    auto         jstWeekday   = earth_time::jst::get_weekday(currentTime);

    // Weekly update for conquest (sunday at midnight)
    static timer::time_point lastConquestTally  = tick - 1h;
    static timer::time_point lastConquestUpdate = tick - 1h;
    if (jstWeekday == 1 && jstHour == 0 && jstMinute == 0)
    {
        if (tick > (lastConquestTally + 1h))
        {
            worldServer->conquestSystem_->updateWeekConquest();
            lastConquestTally = tick;
        }
    }
    // Hourly conquest update
    else if (jstMinute == 0)
    {
        if (tick > (lastConquestUpdate + 1h))
        {
            worldServer->conquestSystem_->updateHourlyConquest();
            lastConquestUpdate = tick;
        }
    }

    // Vanadiel Hour
    static timer::time_point lastVHourlyUpdate = tick - 4800ms;
    if (CVanaTime::getInstance()->getMinute() == 0)
    {
        if (tick > (lastVHourlyUpdate + 4800ms))
        {
            worldServer->conquestSystem_->updateVanaHourlyConquest();
            lastVHourlyUpdate = tick;
        }
    }

    // JST Midnight
    static timer::time_point lastTickedJstMidnight = tick - 1h;
    if (jstHour == 0 && jstMinute == 0)
    {
        if (tick > (lastTickedJstMidnight + 1h))
        {
            if (settings::get<bool>("main.ENABLE_DAILY_TALLY"))
            {
                dailytally::UpdateDailyTallyPoints();
            }

            lastTickedJstMidnight = tick;
        }
    }

    // 4-hour RoE Timed blocks
    static timer::time_point lastTickedRoeBlock = tick - 1h;
    if (jstHour % 4 == 0 && jstMinute == 0)
    {
        if (tick > (lastTickedRoeBlock + 1h))
        {
            lastTickedRoeBlock = tick;
        }
    }

    // Vanadiel Day
    static timer::time_point lastVDailyUpdate = tick - 4800ms;
    if (CVanaTime::getInstance()->getHour() == 0 && CVanaTime::getInstance()->getMinute() == 0)
    {
        if (tick > (lastVDailyUpdate + 4800ms))
        {
            lastVDailyUpdate = tick;
        }
    }

    if (VanadielTOTD != TIME_NONE)
    {
    }

    return 0;
}
