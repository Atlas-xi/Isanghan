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

#pragma once

#include <chrono>
#include <ctime>

#include "cbasetypes.h"
#include "xi.h"

enum DAYTYPE : uint8
{
    FIRESDAY     = 0,
    EARTHSDAY    = 1,
    WATERSDAY    = 2,
    WINDSDAY     = 3,
    ICEDAY       = 4,
    LIGHTNINGDAY = 5,
    LIGHTSDAY    = 6,
    DARKSDAY     = 7
};

namespace vanadiel_time
{
    using clock      = xi::vanadiel_clock;
    using duration   = clock::duration;
    using time_point = clock::time_point;

    enum TOTD : uint8
    {
        NONE     = 0,
        MIDNIGHT = 1,
        NEWDAY   = 2,
        DAWN     = 3,
        DAY      = 4,
        DUSK     = 5,
        EVENING  = 6,
        NIGHT    = 7
    };

    inline time_point now()
    {
        return clock::now();
    }

    inline earth_time::time_point to_earth_time(time_point vanadiel_tp)
    {
        earth_time::duration earth_since_epoch = std::chrono::duration_cast<earth_time::duration>(vanadiel_tp.time_since_epoch());
        return earth_time::time_point(earth_since_epoch + earth_time::vanadiel_epoch);
    };

    inline time_point from_earth_time(earth_time::time_point earth_tp)
    {
        clock::duration vanadiel_since_epoch = std::chrono::duration_cast<clock::duration>(earth_tp - earth_time::vanadiel_epoch);
        return time_point(vanadiel_since_epoch);
    };

    inline uint32 count_weeks(const duration& d)
    {
        clock::weeks total_weeks = std::chrono::duration_cast<clock::weeks>(d);
        return static_cast<uint32>(total_weeks.count());
    }

    inline uint32 count_days(const duration& d)
    {
        clock::days total_days = std::chrono::duration_cast<clock::days>(d);
        return static_cast<uint32>(total_days.count());
    }

    inline std::tm to_tm(const time_point& tp)
    {
        std::tm  result        = {};
        duration d_since_epoch = tp.time_since_epoch();

        auto total_days_count = count_days(d_since_epoch);
        auto days_into_year   = total_days_count % 360;

        result.tm_yday = static_cast<uint32>(days_into_year);
        result.tm_mday = static_cast<uint32>(days_into_year % 30) + 1;
        result.tm_wday = static_cast<uint32>(total_days_count % 8);

        // Calculate components by progressively removing larger units.
        clock::years year = std::chrono::duration_cast<clock::years>(d_since_epoch);
        d_since_epoch -= year;
        result.tm_year = static_cast<uint32>(year.count());

        clock::months mon = std::chrono::duration_cast<clock::months>(d_since_epoch);
        d_since_epoch -= mon;
        result.tm_mon = static_cast<uint32>(mon.count());

        // Get the time within the day.
        d_since_epoch = tp.time_since_epoch() - clock::days(total_days_count);

        clock::hours hour = std::chrono::duration_cast<clock::hours>(d_since_epoch);
        d_since_epoch -= hour;
        result.tm_hour = static_cast<uint32>(hour.count());

        clock::minutes min = std::chrono::duration_cast<clock::minutes>(d_since_epoch);
        d_since_epoch -= min;
        result.tm_min = static_cast<uint32>(min.count());

        clock::seconds sec = std::chrono::duration_cast<clock::seconds>(d_since_epoch);
        result.tm_sec      = static_cast<uint32>(sec.count());

        return result;
    }

    // seconds after the minute - [​0​, 60]
    inline uint32 get_second(const time_point& tp)
    {
        return to_tm(tp).tm_sec;
    }
    // minutes after the hour – [​0​, 59]
    inline uint32 get_minute(const time_point& tp)
    {
        return to_tm(tp).tm_min;
    }
    // hours since midnight – [​0​, 23]
    inline uint32 get_hour(const time_point& tp)
    {
        return to_tm(tp).tm_hour;
    }
    // day of the month – [1, 30]
    inline uint32 get_monthday(const time_point& tp)
    {
        return to_tm(tp).tm_mday;
    }
    // month – [​0​, 11]
    inline uint32 get_month(const time_point& tp)
    {
        return to_tm(tp).tm_mon;
    }
    // years since 886
    inline uint32 get_year(const time_point& tp)
    {
        return to_tm(tp).tm_year;
    }
    // days since Firesday – [​0​, 7]
    inline uint32 get_weekday(const time_point& tp)
    {
        return to_tm(tp).tm_wday;
    }
    // days since 1st day of year – [​0​, 360]
    inline uint32 get_yearday(const time_point& tp)
    {
        return to_tm(tp).tm_yday;
    }

    inline time_point get_next_midnight(const time_point& tp)
    {
        auto previous_midnight = std::chrono::floor<clock::days>(tp);
        auto next_midnight     = previous_midnight + clock::days(1);
        return next_midnight;
    }
    inline time_point get_next_midnight()
    {
        return get_next_midnight(now());
    }

    inline TOTD get_totd(const time_point& tp)
    {
        auto hour = get_hour(tp);

        if (hour < 4)
        {
            return TOTD::MIDNIGHT;
        }
        else if (hour >= 4 && hour < 6)
        {
            return TOTD::NEWDAY;
        }
        else if (hour == 6)
        {
            return TOTD::DAWN;
        }
        else if (hour >= 7 && hour < 17)
        {
            return TOTD::DAY;
        }
        else if (hour == 17)
        {
            return TOTD::DUSK;
        }
        else if (hour >= 18 && hour < 20)
        {
            return TOTD::EVENING;
        }
        else if (hour >= 20)
        {
            return TOTD::NIGHT;
        }
        return TOTD::NONE;
    }
    inline TOTD get_totd()
    {
        return get_totd(now());
    }

    namespace moon
    {
        inline uint32 get_phase(const time_point& tp)
        {
            int32  phase   = 0;
            double daysmod = static_cast<int32>((count_days(tp.time_since_epoch() + clock::years(886)) + 26) % 84);

            if (daysmod >= 42)
            {
                phase = static_cast<int32>(100 * ((daysmod - 42) / 42) + 0.5);
            }
            else
            {
                phase = static_cast<int32>(100 * (1 - (daysmod / 42)) + 0.5);
            }

            return phase;
        }
        inline uint32 get_phase()
        {
            return get_phase(now());
        }

        inline uint8 get_direction(const time_point& tp)
        {
            double daysmod = static_cast<int32>((count_days(tp.time_since_epoch() + clock::years(886)) + 26) % 84);

            if (daysmod == 42 || daysmod == 0)
            {
                return 0; // neither waxing nor waning
            }
            else if (daysmod < 42)
            {
                return 1; // waning
            }
            else
            {
                return 2; // waxing
            }
        }
        inline uint8 get_direction()
        {
            return get_direction(now());
        }
    } // namespace moon

    namespace rse
    {
        inline uint8 get_race()
        {
            return static_cast<uint8>(count_weeks(now().time_since_epoch()) % 8 + 1);
        }
        inline uint8 get_location()
        {
            return static_cast<uint8>(count_weeks(now().time_since_epoch()) % 3);
        }
    } // namespace rse
}; // namespace vanadiel_time
