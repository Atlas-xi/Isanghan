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

#include "common/application.h"
#include "common/blowfish.h"
#include "common/cbasetypes.h"
#include "common/ipp.h"
#include "common/md52.h"
#include "common/mmo.h"
#include "common/sql.h"
#include "common/taskmgr.h"
#include "common/watchdog.h"
#include "common/xirand.h"

#include <list>
#include <map>
#include <memory>

#include "map_constants.h"
#include "zone.h"

//
// Forward Declarations
//

class MapServer;
class SqlConnection;
class MapNetworking;
class MapStatistics;
class CZone;

//
// Exposed globals
//

extern MapServer*                     gMapServer;
extern std::unique_ptr<SqlConnection> _sql;

class MapServer final : public Application
{
public:
    MapServer(int argc, char** argv);
    ~MapServer() override;

    //
    // Application
    //

    void loadConsoleCommands() override;

    void run() override;

    //
    // Init
    //

    void prepareWatchdog();

    // TODO: Kernel logic
    auto do_init() -> int32;
    void do_final();

    //
    // Maintenance
    //

    int32 map_cleanup(time_point tick, CTaskMgr::CTask* PTask); // Clean up timed out players
    int32 map_garbage_collect(time_point tick, CTaskMgr::CTask* PTask);

    //
    // Accessors
    //

    auto networking() -> MapNetworking&;
    auto statistics() -> MapStatistics&;
    auto zones() -> std::map<uint16, CZone*>&; // g_PZoneList
    // gameState()

private:
    std::unique_ptr<MapNetworking> networking_;
    std::unique_ptr<MapStatistics> mapStatistics_;
    std::unique_ptr<Watchdog>      watchdog_;
};
