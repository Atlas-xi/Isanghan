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

#include "timer.h"

namespace timer
{
    // server startup time
    time_point start_time;

    void init()
    {
        start_time = clock::now();
    }

    void final()
    {
    }

    time_point getStartTime()
    {
        return start_time;
    }

    duration getUptime()
    {
        return clock::now() - start_time;
    }

    // https://stackoverflow.com/questions/35282308/convert-between-c11-clocks/35282833#35282833
    utc_clock::time_point toUtc(time_point timerTime)
    {
        auto utcNow   = utc_clock::now();
        auto timerNow = clock::now();
        return std::chrono::time_point_cast<utc_clock::duration>(timerTime - timerNow + utcNow);
    };

    time_point fromUtc(utc_clock::time_point utcTime)
    {
        auto timerNow = clock::now();
        auto utcNow   = utc_clock::now();
        return utcTime - utcNow + timerNow;
    };
}; // namespace timer
