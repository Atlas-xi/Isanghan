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

namespace earth_time
{
    // Base clock for wall-clock time (UTC)
    using clock      = std::chrono::system_clock;
    using duration   = clock::duration;
    using time_point = clock::time_point;

    inline std::tm to_utc_tm(const time_point& tp)
    {
        std::time_t time_t_val = clock::to_time_t(tp);
        std::tm     utc_tm{};
        _gmtime_s(&utc_tm, &time_t_val);
        return utc_tm;
    }

    inline std::tm to_local_tm(const time_point& tp)
    {
        std::time_t time_t_val = clock::to_time_t(tp);
        std::tm     local_tm{};
        _localtime_s(&local_tm, &time_t_val);
        return local_tm;
    }

    namespace utc
    {
        inline time_point now()
        {
            return clock::now();
        }

        // seconds after the minute - [​0​, 60]
        inline uint32 get_second(const time_point& tp)
        {
            return to_utc_tm(tp).tm_sec;
        }
        // minutes after the hour – [​0​, 59]
        inline uint32 get_minute(const time_point& tp)
        {
            return to_utc_tm(tp).tm_min;
        }
        // hours since midnight – [​0​, 23]
        inline uint32 get_hour(const time_point& tp)
        {
            return to_utc_tm(tp).tm_hour;
        }
        // day of the month – [1, 31]
        inline uint32 get_monthday(const time_point& tp)
        {
            return to_utc_tm(tp).tm_mday;
        }
        // months since January – [​0​, 11]
        inline uint32 get_month(const time_point& tp)
        {
            return to_utc_tm(tp).tm_mon;
        }
        // years since 1900
        inline uint32 get_year(const time_point& tp)
        {
            return to_utc_tm(tp).tm_year;
        }
        // days since Sunday – [​0​, 6]
        inline uint32 get_weekday(const time_point& tp)
        {
            return to_utc_tm(tp).tm_wday;
        }
        // days since January 1 – [​0​, 365]
        inline uint32 get_yearday(const time_point& tp)
        {
            return to_utc_tm(tp).tm_yday;
        }

        inline time_point get_next_midnight(const time_point& tp)
        {
            auto previous_midnight = std::chrono::floor<std::chrono::days>(tp);
            auto next_midnight     = previous_midnight + std::chrono::days(1);
            return next_midnight;
        }
        inline time_point get_next_midnight()
        {
            return get_next_midnight(now());
        }
    } // namespace utc

    // Japan Standard Time (UTC+9)
    namespace jst
    {
        constexpr std::chrono::hours jst_offset = std::chrono::hours(9);

        inline uint32 get_second(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_sec;
        }
        inline uint32 get_minute(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_min;
        }
        inline uint32 get_hour(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_hour;
        }
        inline uint32 get_monthday(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_mday;
        }
        inline uint32 get_month(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_mon;
        }
        inline uint32 get_year(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_year;
        }
        inline uint32 get_weekday(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_wday;
        }
        inline uint32 get_yearday(const time_point& tp)
        {
            return to_utc_tm(tp + jst_offset).tm_yday;
        }

        inline time_point get_next_midnight(const time_point& tp)
        {
            // Add jst_offset to align JST day with UTC day, then subtract from UTC midnight.
            return utc::get_next_midnight(tp + jst_offset) - jst_offset;
        }
        inline time_point get_next_midnight()
        {
            return get_next_midnight(utc::now());
        }
    } // namespace jst

    namespace local
    {
        inline uint32 get_second(const time_point& tp)
        {
            return to_local_tm(tp).tm_sec;
        }
        inline uint32 get_minute(const time_point& tp)
        {
            return to_local_tm(tp).tm_min;
        }
        inline uint32 get_hour(const time_point& tp)
        {
            return to_local_tm(tp).tm_hour;
        }
        inline uint32 get_monthday(const time_point& tp)
        {
            return to_local_tm(tp).tm_mday;
        }
        inline uint32 get_month(const time_point& tp)
        {
            return to_local_tm(tp).tm_mon;
        }
        inline uint32 get_year(const time_point& tp)
        {
            return to_local_tm(tp).tm_year;
        }
        inline uint32 get_weekday(const time_point& tp)
        {
            return to_local_tm(tp).tm_wday;
        }
        inline uint32 get_yearday(const time_point& tp)
        {
            return to_local_tm(tp).tm_yday;
        }
        inline bool is_dst(const time_point& tp)
        {
            return to_local_tm(tp).tm_isdst > 0;
        }
    } // namespace local

    // Earth time = UTC
    inline time_point now()
    {
        return utc::now();
    }

    // Returns a Unix timestamp.
    inline uint32 timestamp(const time_point& tp)
    {
        return std::chrono::duration_cast<std::chrono::seconds>(tp.time_since_epoch()).count();
    }
    inline uint32 timestamp()
    {
        return timestamp(now());
    }

    // Returns an integer 0-6 representing Monday-Sunday JST.
    inline uint8 get_game_weekday(const time_point& tp)
    {
        return static_cast<uint8>((jst::get_weekday(tp) + 6) % 7);
    }
    inline uint8 get_game_weekday()
    {
        return get_game_weekday(now());
    }

    // Returns a time point for the start of the next game week (midnight Monday JST aka weekly reset).
    inline time_point get_next_game_week(const time_point& tp)
    {
        time_point next_jst_midnight = jst::get_next_midnight(tp);
        uint8      game_weekday      = get_game_weekday(tp);

        // Start with the next midnight and apply N days worth of time to it.
        time_point next_game_week = next_jst_midnight + std::chrono::days(6 - game_weekday);

        return next_game_week;
    }
    inline time_point get_next_game_week()
    {
        return get_next_game_week(now());
    }
}; // namespace earth_time
