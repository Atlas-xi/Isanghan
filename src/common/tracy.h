﻿/*
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

#pragma once

#include <fmt/format.h>

//
// TODO: Move these somewhere else
//

inline std::string hex8ToString(std::uint8_t hex)
{
    return fmt::format("0x{:02X}", hex);
}

inline std::string hex16ToString(std::uint16_t hex)
{
    return fmt::format("0x{:04X}", hex);
}

inline std::string hex32ToString(std::uint32_t hex)
{
    return fmt::format("0x{:08X}", hex);
}

// clang-format off
#ifdef TRACY_ENABLE

#ifndef TRACY_CALLSTACK
#define TRACY_CALLSTACK 4
#endif

#include "tracy/Tracy.hpp"

#include <cstdint>
#include <fmt/format.h>
#include <string>

#define TracyFrameMark          FrameMark
#define TracyZoneScoped         ZoneScoped
#define TracyZoneScopedN(n)     ZoneScopedN(n)
#define TracyZoneNamed(var)     ZoneNamedN(var, #var, true)
#define TracyZoneText(n, l)     ZoneText(n, l)
#define TracyZoneScopedC(c)     ZoneScopedC(c)
#define TracyZoneString(str)    ZoneText(str.c_str(), str.size())
#define TracyZoneCString(cstr)  ZoneText(cstr, std::strlen(cstr))
#define TracyMessageStr(str)    TracyMessage(str.c_str(), str.size())
#define TracySetThreadName(str) tracy::SetThreadName(str)

#define TracyZoneHex8(num) \
    auto str = hex8ToString(num); \
    TracyZoneText(str.c_str(), str.size());

#define TracyZoneHex16(num) \
    auto str = hex16ToString(num); \
    TracyZoneText(str.c_str(), str.size());

#define TracyZoneHex32(num) \
    auto str = hex32ToString(num); \
    TracyZoneText(str.c_str(), str.size());

#define TracyReportGraphNumber(name, num) \
    TracyPlotConfig(name, tracy::PlotFormatType::Number, false, true, 0); \
    TracyPlot(name, num);

#define TracyReportGraphBytes(name, num) \
    TracyPlotConfig(name, tracy::PlotFormatType::Memory, false, true, 0); \
    TracyPlot(name, num);

#define TracyReportGraphPercent(name, num) \
    TracyPlotConfig(name, tracy::PlotFormatType::Percentage, false, true, 0); \
    TracyPlot(name, num);

#define TracyReportLuaMemory(L) \
    TracyReportGraphBytes("Lua Memory Usage", static_cast<double>(lua_gc(L, LUA_GCCOUNT, 0)) * 1024.0);

#else // Empty stubs for regular builds
#define TracyFrameMark                     std::ignore = 0
#define TracyZoneScoped                    std::ignore = 0
#define TracyZoneScopedN(n)                std::ignore = n
#define TracyZoneNamed(var)                std::ignore = #var
#define TracyZoneText(n, l)                std::ignore = n; std::ignore = l
#define TracyZoneScopedC(c)                std::ignore = c
#define TracyZoneString(str)               std::ignore = str
#define TracyZoneCString(cstr)             std::ignore = cstr
#define TracyZoneIString(istr)             std::ignore = istr
#define TracyZoneHex8(num)                 std::ignore = num
#define TracyZoneHex16(num)                std::ignore = num
#define TracyZoneHex32(num)                std::ignore = num
#define TracyReportGraphNumber(name, num)  std::ignore = name; std::ignore = num
#define TracyReportGraphBytes(name, num)   std::ignore = name; std::ignore = num
#define TracyReportGraphPercent(name, num) std::ignore = name; std::ignore = num
#define TracyReportLuaMemory(L)            std::ignore = L
#define TracyMessageStr(str)               std::ignore = str
#define TracySetThreadName(str)            std::ignore = str
#define TracyLockable(m, n)                m n
#define LockableBase(type)                 type
#define LockMark(m)                        std::ignore = m
#endif
// clang-format on
