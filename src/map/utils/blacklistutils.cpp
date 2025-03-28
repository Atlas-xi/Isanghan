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

#include "blacklistutils.h"

#include "common/database.h"
#include "common/logging.h"
#include "common/sql.h"
#include "common/utils.h"

#include "entities/charentity.h"

#include "map_server.h"

#include "packets/send_blacklist.h"

namespace blacklistutils
{
    bool IsBlacklisted(uint32 ownerId, uint32 targetId)
    {
        const auto rset = db::preparedStmt("SELECT * FROM char_blacklist WHERE charid_owner = ? AND charid_target = ? LIMIT 1", ownerId, targetId);
        return rset && rset->rowsCount();
    }

    bool AddBlacklisted(uint32 ownerId, uint32 targetId)
    {
        if (IsBlacklisted(ownerId, targetId))
        {
            return false;
        }

        const auto rset = db::preparedStmt("INSERT INTO char_blacklist (charid_owner, charid_target) VALUES (?, ?)", ownerId, targetId);
        return rset && rset->rowsAffected() == 1;
    }

    bool DeleteBlacklisted(uint32 ownerId, uint32 targetId)
    {
        if (!IsBlacklisted(ownerId, targetId))
        {
            return false;
        }

        const auto rset = db::preparedStmt("DELETE FROM char_blacklist WHERE charid_owner = ? AND charid_target = ? LIMIT 1", ownerId, targetId);
        return rset && rset->rowsAffected() == 1;
    }

    void SendBlacklist(CCharEntity* PChar)
    {
        std::vector<std::pair<uint32, std::string>> blacklist;

        // Obtain this users blacklist info..
        const char* query = "SELECT c.charid, c.charname FROM char_blacklist AS b INNER JOIN chars AS c ON b.charid_target = c.charid WHERE charid_owner = %u";
        if (_sql->Query(query, PChar->id) == SQL_ERROR || _sql->NumRows() == 0)
        {
            PChar->pushPacket<CSendBlacklist>(PChar, blacklist, true, true);
            return;
        }

        // Loop and build blacklist
        int currentCount = 0;
        int totalCount   = 0;
        int rowCount     = _sql->NumRows();

        while (_sql->NextRow() == SQL_SUCCESS)
        {
            uint32      accid_target = _sql->GetUIntData(0);
            std::string targetName   = _sql->GetStringData(1);

            blacklist.emplace_back(accid_target, targetName);
            currentCount++;
            totalCount++;

            if (currentCount == 12)
            {
                // reset the client blist if it's the first 12 (or less)
                // this is the last blist packet if total count equals row count
                PChar->pushPacket<CSendBlacklist>(PChar, blacklist, totalCount <= 12, totalCount == rowCount);
                blacklist.clear();
                currentCount = 0;
            }
        }

        // Push remaining entries..
        if (!blacklist.empty())
        {
            PChar->pushPacket<CSendBlacklist>(PChar, blacklist, false, true);
        }
    }

} // namespace blacklistutils
