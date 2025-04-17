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

#pragma once

#include <chrono>

#include "cbasetypes.h"

namespace timer
{
    // This clock is not stable across reboots.
    // Use utc_clock if you need real time.
    // Use timer::toUtc/timer::fromUtc to persist timestamps to the database (status effects).
    using clock      = std::chrono::steady_clock;
    using duration   = clock::duration;
    using time_point = clock::time_point;

    void init();
    void final();

    time_point getStartTime();
    duration   getUptime();

    template <typename Rep, typename Period>
    auto getMilliseconds(const std::chrono::duration<Rep, Period>& d) -> int64
    {
        return std::chrono::duration_cast<std::chrono::milliseconds>(d).count();
    };

    template <typename Rep, typename Period>
    auto getSeconds(const std::chrono::duration<Rep, Period>& d) -> int64
    {
        return std::chrono::duration_cast<std::chrono::seconds>(d).count();
    };

    utc_clock::time_point toUtc(time_point timerTime);
    time_point            fromUtc(utc_clock::time_point utcTime);
}; // namespace timer
