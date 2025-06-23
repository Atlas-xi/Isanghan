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

#include "0x117_unity_quest.h"

#include "entities/charentity.h"
#include "packets/menu_unity.h"
#include "packets/roe_sparkupdate.h"

PacketValidationResult GP_CLI_COMMAND_UNITY_QUEST::validate(MapSession* PSession, const CCharEntity* PChar) const
{
    return PacketValidator()
        .mustEqual(Kind, 0x0, "Kind not 0x0"); // Client always sends 0x0 despite possibly supporting 0x1, 0x2
}

void GP_CLI_COMMAND_UNITY_QUEST::process(MapSession* PSession, CCharEntity* PChar) const
{
    // TODO: Incomplete implementation.
    // This stub only handles the needed RoE updates.
    PChar->pushPacket<CRoeSparkUpdatePacket>(PChar);
    PChar->pushPacket<CMenuUnityPacket>(PChar);
}
