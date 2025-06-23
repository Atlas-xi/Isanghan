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

#include "0x11b_mastery_display.h"

#include "entities/charentity.h"
#include "packets/char_status.h"
#include "utils/charutils.h"

PacketValidationResult GP_CLI_COMMAND_MASTERY_DISPLAY::validate(MapSession* PSession, const CCharEntity* PChar) const
{
    return PacketValidator()
        .range("Mode", Mode, GP_CLI_COMMAND_MASTERY_DISPLAY_MODE::Off, GP_CLI_COMMAND_MASTERY_DISPLAY_MODE::On);
}

void GP_CLI_COMMAND_MASTERY_DISPLAY::process(MapSession* PSession, CCharEntity* PChar) const
{
    PChar->m_jobMasterDisplay = Mode;

    charutils::SaveJobMasterDisplay(PChar);
    PChar->pushPacket<CCharStatusPacket>(PChar);
}
