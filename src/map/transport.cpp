﻿/*
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

#include "transport.h"

#include "common/timer.h"
#include "common/vana_time.h"

#include <cstdlib>

#include "entities/charentity.h"
#include "map_networking.h"
#include "map_server.h"
#include "packets/entity_update.h"
#include "packets/event.h"
#include "utils/zoneutils.h"
#include "zone.h"

void Transport_Ship::setVisible(bool visible) const
{
    if (visible)
    {
        this->npc->status = STATUS_TYPE::NORMAL;
        // This appears to be some sort of magic bit/flag set. In QSC 0x8001 is observed on the effects that light up the weight on the weighted doors.
        // The effect of 0x8001 appears to be to "stay in place" and not "stand on top of" things, such as the floor -- most likely fixes positions to the exact X/Y/Z coords supplied in 0x00E.
        this->npc->loc.p.moving = 0x8007;
    }
    else
    {
        this->npc->status = STATUS_TYPE::DISAPPEAR;
        // Missing 0x0001 bit here
        this->npc->loc.p.moving = 0x8006;
    }
}

void Transport_Ship::animateSetup(uint8 animationID, vanadiel_time::time_point horizonTime) const
{
    this->npc->animation = animationID;
    this->npc->SetLocalVar("TransportTimestamp", earth_time::vanadiel_timestamp(vanadiel_time::to_earth_time(horizonTime)));
}

void Transport_Ship::spawn() const
{
    this->npc->loc = this->dock;
    this->setVisible(true);
}

void TransportZone_Town::updateShip() const
{
    this->ship.dock.zone->UpdateEntityPacket(this->ship.npc, ENTITY_UPDATE, UPDATE_COMBAT, true);
}

void TransportZone_Town::openDoor(bool sendPacket) const
{
    this->npcDoor->animation = ANIMATION_OPEN_DOOR;

    if (sendPacket)
    {
        this->ship.dock.zone->UpdateEntityPacket(this->npcDoor, ENTITY_UPDATE, UPDATE_COMBAT, true);
    }
}

void TransportZone_Town::closeDoor(bool sendPacket) const
{
    this->npcDoor->animation = ANIMATION_CLOSE_DOOR;

    if (sendPacket)
    {
        this->ship.dock.zone->UpdateEntityPacket(this->npcDoor, ENTITY_UPDATE, UPDATE_COMBAT, true);
    }
}

void TransportZone_Town::depart() const
{
    this->ship.dock.zone->TransportDepart(this->ship.npc->loc.boundary, this->ship.npc->loc.prevzone);
}

void Elevator_t::openDoor(CNpcEntity* npc) const
{
    npc->animation = ANIMATION_OPEN_DOOR;
    zoneutils::GetZone(this->zoneID)->UpdateEntityPacket(npc, ENTITY_SPAWN, UPDATE_ALL_MOB, true);
}

void Elevator_t::closeDoor(CNpcEntity* npc) const
{
    npc->animation = ANIMATION_CLOSE_DOOR;
    zoneutils::GetZone(this->zoneID)->UpdateEntityPacket(npc, ENTITY_SPAWN, UPDATE_ALL_MOB, true);
}

/************************************************************************
 *                                                                       *
 *  Loads transportation from the database table transport               *
 *                                                                       *
 ************************************************************************/

void CTransportHandler::InitializeTransport(IPP mapIPP)
{
    if (townZoneList.size() != 0)
    {
        ShowError("townZoneList is not empty.");
        return;
    }

    const char* fmtQuery = "SELECT id, transport, door, dock_x, dock_y, dock_z, dock_rot, \
                            boundary, zone, anim_arrive, anim_depart, time_offset, time_interval, \
                            time_waiting, time_anim_arrive, time_anim_depart FROM transport LEFT JOIN \
                            zone_settings ON ((transport >> 12) & 0xFFF) = zoneid WHERE \
                            IF(%d <> 0, '%s' = zoneip AND %d = zoneport, TRUE)";

    int32 ret = _sql->Query(fmtQuery, mapIPP.getIP(), mapIPP.getIPString(), mapIPP.getPort());
    if (ret != SQL_ERROR && _sql->NumRows() != 0)
    {
        while (_sql->NextRow() == SQL_SUCCESS)
        {
            TransportZone_Town zoneTown;

            zoneTown.ship.dock.zone = zoneutils::GetZone((_sql->GetUIntData(1) >> 12) & 0x0FFF);

            zoneTown.ship.dock.p.x        = _sql->GetFloatData(3);
            zoneTown.ship.dock.p.y        = _sql->GetFloatData(4);
            zoneTown.ship.dock.p.z        = _sql->GetFloatData(5);
            zoneTown.ship.dock.p.rotation = (uint8)_sql->GetIntData(6);
            zoneTown.ship.dock.boundary   = (uint16)_sql->GetIntData(7);
            zoneTown.ship.dock.prevzone   = (uint8)_sql->GetIntData(8);

            zoneTown.npcDoor  = zoneutils::GetEntity(_sql->GetUIntData(2), TYPE_NPC);
            zoneTown.ship.npc = zoneutils::GetEntity(_sql->GetUIntData(1), TYPE_SHIP);
            if (!zoneTown.ship.npc)
            {
                ShowError("Transport <%u>: transport not found", (uint8)_sql->GetIntData(0));
                continue;
            }

            zoneTown.ship.animationArrive = (uint8)_sql->GetIntData(9);
            zoneTown.ship.animationDepart = (uint8)_sql->GetIntData(10);

            zoneTown.ship.timeOffset      = xi::vanadiel_clock::minutes(_sql->GetIntData(11));
            zoneTown.ship.timeInterval    = xi::vanadiel_clock::minutes(_sql->GetIntData(12));
            zoneTown.ship.timeArriveDock  = xi::vanadiel_clock::minutes(_sql->GetIntData(14));
            zoneTown.ship.timeDepartDock  = zoneTown.ship.timeArriveDock + xi::vanadiel_clock::minutes(_sql->GetIntData(13));
            zoneTown.ship.timeVoyageStart = zoneTown.ship.timeDepartDock + xi::vanadiel_clock::minutes(_sql->GetIntData(15) - 1);

            zoneTown.ship.state = STATE_TRANSPORT_INIT;
            zoneTown.ship.setVisible(false);
            zoneTown.closeDoor(false);

            if (zoneTown.npcDoor == nullptr)
            {
                ShowError("Transport <%u>: door not found", (uint8)_sql->GetIntData(0));
                continue;
            }
            if (zoneTown.ship.timeArriveDock < xi::vanadiel_clock::minutes(10))
            {
                ShowError("Transport <%u>: time_anim_arrive must be > 10", (uint8)_sql->GetIntData(0));
                continue;
            }
            if (zoneTown.ship.timeInterval < zoneTown.ship.timeVoyageStart)
            {
                ShowError("Transport <%u>: time_interval must be > time_anim_arrive + time_waiting + time_anim_depart", (uint8)_sql->GetIntData(0));
                continue;
            }

            townZoneList.emplace_back(zoneTown);
        }
    }

    fmtQuery = "SELECT zone, time_offset, time_interval, time_waiting, time_anim_arrive, time_anim_depart \
                FROM transport LEFT JOIN \
                zone_settings ON zone = zoneid WHERE \
                IF(%d <> 0, '%s' = zoneip AND %d = zoneport, TRUE)";

    ret = _sql->Query(fmtQuery, mapIPP.getIP(), mapIPP.getIPString(), mapIPP.getPort());
    if (ret != SQL_ERROR && _sql->NumRows() != 0)
    {
        while (_sql->NextRow() == SQL_SUCCESS)
        {
            TransportZone_Voyage voyageZone{};

            voyageZone.voyageZone = nullptr;
            voyageZone.voyageZone = zoneutils::GetZone((uint8)_sql->GetUIntData(0));

            if (voyageZone.voyageZone != nullptr && voyageZone.voyageZone->GetID() > 0)
            {
                voyageZone.timeOffset   = xi::vanadiel_clock::minutes(_sql->GetIntData(1));
                voyageZone.timeInterval = xi::vanadiel_clock::minutes(_sql->GetIntData(2));

                voyageZone.timeArriveDock  = xi::vanadiel_clock::minutes(_sql->GetIntData(4));
                voyageZone.timeDepartDock  = voyageZone.timeArriveDock + xi::vanadiel_clock::minutes(_sql->GetIntData(3));
                voyageZone.timeVoyageStart = voyageZone.timeDepartDock + xi::vanadiel_clock::minutes(_sql->GetIntData(5));

                voyageZone.state = STATE_TRANSPORTZONE_INIT;

                voyageZoneList.emplace_back(voyageZone);
            }
            else
            {
                ShowError("TransportZone <%u>: zone not found", (uint8)_sql->GetIntData(0));
            }
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Main transportation controller                                  *
 *                                                                       *
 ************************************************************************/

void CTransportHandler::TransportTimer()
{
    vanadiel_time::time_point vanaTime         = vanadiel_time::now();
    vanadiel_time::duration   vanaTimeDuration = vanaTime.time_since_epoch();
    vanadiel_time::duration   alignedTime;
    vanadiel_time::duration   shipTimerOffset;

    // Loop through town zones and update transportion accordingly
    for (auto& i : townZoneList)
    {
        TransportZone_Town* townZone = &i;

        alignedTime     = vanaTimeDuration - townZone->ship.timeOffset;
        shipTimerOffset = alignedTime % townZone->ship.timeInterval;

        if (townZone->ship.state == STATE_TRANSPORT_AWAY)
        {
            if (shipTimerOffset < townZone->ship.timeArriveDock)
            {
                townZone->ship.state = STATE_TRANSPORT_ARRIVING;
                townZone->ship.animateSetup(townZone->ship.animationArrive, vanaTime);
                townZone->ship.spawn();

                townZone->updateShip();
            }
        }
        else if (townZone->ship.state == STATE_TRANSPORT_DEPARTING)
        {
            if (shipTimerOffset >= townZone->ship.timeVoyageStart)
            {
                townZone->ship.state = STATE_TRANSPORT_AWAY;
                townZone->ship.setVisible(false);

                townZone->updateShip();
            }
        }
        else if (townZone->ship.state == STATE_TRANSPORT_DOCKED)
        {
            if (shipTimerOffset >= townZone->ship.timeDepartDock)
            {
                townZone->ship.state = STATE_TRANSPORT_DEPARTING;
                townZone->ship.animateSetup(townZone->ship.animationDepart, vanaTime);

                townZone->closeDoor(true);
                townZone->depart();
                townZone->updateShip();
            }
        }
        else if (townZone->ship.state == STATE_TRANSPORT_ARRIVING)
        {
            if (shipTimerOffset >= townZone->ship.timeArriveDock)
            {
                townZone->ship.state = STATE_TRANSPORT_DOCKED;
                townZone->openDoor(true);
            }
        }
        else if (townZone->ship.state == STATE_TRANSPORT_INIT)
        {
            if (shipTimerOffset >= townZone->ship.timeVoyageStart)
            {
                townZone->ship.state = STATE_TRANSPORT_AWAY;
            }
            else if (shipTimerOffset >= townZone->ship.timeDepartDock)
            {
                vanadiel_time::duration departTime = shipTimerOffset - townZone->ship.timeDepartDock;
                townZone->ship.state               = STATE_TRANSPORT_DEPARTING;
                townZone->ship.spawn();
                townZone->ship.animateSetup(townZone->ship.animationDepart, vanaTime - departTime);
            }
            else if (shipTimerOffset >= townZone->ship.timeArriveDock)
            {
                townZone->ship.state = STATE_TRANSPORT_DOCKED;
                townZone->openDoor(false);
                townZone->ship.spawn();
                townZone->ship.animateSetup(townZone->ship.animationArrive, vanaTime - shipTimerOffset);
            }
            else
            {
                townZone->ship.state = STATE_TRANSPORT_ARRIVING;

                townZone->ship.spawn();
                townZone->ship.animateSetup(townZone->ship.animationArrive, vanaTime - shipTimerOffset);
            }
        }
        else
        {
            ShowError("Unexpected state reached for transportation %d", townZone->ship.npc->id);
        }
    }

    // Loop through voyage zones and zone passengers accordingly
    for (auto& i : voyageZoneList)
    {
        TransportZone_Voyage* zoneIterator = &i;

        alignedTime     = vanaTimeDuration - zoneIterator->timeOffset;
        shipTimerOffset = alignedTime % zoneIterator->timeInterval;

        if (zoneIterator->state == STATE_TRANSPORTZONE_VOYAGE)
        {
            // Zone them out 10 Van minutes before the boat reaches the dock
            if (shipTimerOffset < zoneIterator->timeVoyageStart && shipTimerOffset > zoneIterator->timeArriveDock - xi::vanadiel_clock::minutes(10))
            {
                zoneIterator->state = STATE_TRANSPORTZONE_EVICT;
            }
        }
        else if (zoneIterator->state == STATE_TRANSPORTZONE_EVICT)
        {
            zoneIterator->voyageZone->TransportDepart(0, zoneIterator->voyageZone->GetID());
            zoneIterator->state = STATE_TRANSPORTZONE_WAIT;
        }
        else if (zoneIterator->state == STATE_TRANSPORTZONE_WAIT)
        {
            if (shipTimerOffset < zoneIterator->timeDepartDock)
            {
                zoneIterator->state = STATE_TRANSPORTZONE_EVICT;
            }
            else
            {
                zoneIterator->state = STATE_TRANSPORTZONE_DOCKED;
            }
        }
        else if (zoneIterator->state == STATE_TRANSPORTZONE_DOCKED)
        {
            if (shipTimerOffset > zoneIterator->timeVoyageStart)
            {
                zoneIterator->state = STATE_TRANSPORTZONE_VOYAGE;
            }
        }
        else if (zoneIterator->state == STATE_TRANSPORTZONE_INIT)
        {
            if (shipTimerOffset < zoneIterator->timeVoyageStart)
            {
                zoneIterator->state = STATE_TRANSPORTZONE_EVICT;
            }
            else
            {
                zoneIterator->state = STATE_TRANSPORTZONE_VOYAGE;
            }
        }
        else
        {
            ShowError("Unexpected state reached for travel zone %d", zoneIterator->voyageZone->GetID());
        }
    }

    // Loop through elevators
    for (auto& i : ElevatorList)
    {
        Elevator_t* elevator = &i;

        if (elevator->activated)
        {
            if (elevator->state == STATE_ELEVATOR_TOP || elevator->state == STATE_ELEVATOR_BOTTOM)
            {
                if (vanaTime >= elevator->lastTrigger + elevator->interval)
                {
                    startElevator(elevator);
                }
            }
            else if (elevator->state == STATE_ELEVATOR_ASCEND || elevator->state == STATE_ELEVATOR_DESCEND)
            {
                if (vanaTime >= elevator->lastTrigger + elevator->movetime)
                {
                    arriveElevator(elevator);
                }
            }
            else
            {
                ShowError("Unexpected state reached for elevator %d", elevator->Elevator->id);
            }
        }
    }
}

// gets returns a pointer to an Elevator_t if available
Elevator_t* CTransportHandler::getElevator(uint8 elevatorID)
{
    for (auto& i : ElevatorList)
    {
        Elevator_t* elevator = &i;

        if (elevator->id == elevatorID)
        {
            return elevator;
        }
    }

    return nullptr;
}

/************************************************************************
 *                                                                       *
 *  Initializes an elevator                                              *
 *                                                                       *
 ************************************************************************/

void CTransportHandler::insertElevator(Elevator_t elevator)
{
    // check to see if this elevator already exists
    for (auto& i : ElevatorList)
    {
        Elevator_t* PElevator = &i;

        if (PElevator->Elevator->getName() == elevator.Elevator->getName() && PElevator->zoneID == elevator.zoneID)
        {
            ShowError("Elevator already exists.");
            return;
        }
    }

    // Double check that the NPC entities all exist
    if (elevator.LowerDoor == nullptr || elevator.UpperDoor == nullptr || elevator.Elevator == nullptr)
    {
        ShowError("Elevator %d could not load NPC entity. Ignoring this elevator.", elevator.Elevator->id);
        return;
    }

    // Have permanent elevators wait until their next cycle to begin moving
    vanadiel_time::time_point vanaTime         = vanadiel_time::now();
    vanadiel_time::duration   vanaTimeDuration = vanaTime.time_since_epoch();
    elevator.lastTrigger                       = vanaTime - (vanaTimeDuration % elevator.interval) + elevator.interval;

    // Initialize the elevator into the correct state based on
    // its animation value in the database.
    if (elevator.Elevator->animation == ANIMATION_ELEVATOR_DOWN)
    {
        elevator.state = STATE_ELEVATOR_BOTTOM;
    }
    else if (elevator.Elevator->animation == ANIMATION_ELEVATOR_UP)
    {
        elevator.state = STATE_ELEVATOR_TOP;
    }
    else
    {
        ShowError("Elevator %d has unexpected animation. Ignoring this elevator.", elevator.Elevator->id);
        return;
    }

    // Inconsistant animations throughout the elevators
    if (elevator.animationsReversed)
    {
        elevator.state ^= 1;
    }

    // Ensure that the doors start in the correct positions
    // regardless of their values in the database.

    elevator.LowerDoor->animation = (elevator.state == STATE_ELEVATOR_TOP) ? ANIMATION_CLOSE_DOOR : ANIMATION_OPEN_DOOR;
    elevator.UpperDoor->animation = (elevator.state == STATE_ELEVATOR_TOP) ? ANIMATION_OPEN_DOOR : ANIMATION_CLOSE_DOOR;

    ElevatorList.emplace_back(elevator);
}

/************************************************************************
 *                                                                       *
 *  Called when a lever is pulled in the field.                          *
 *                                                                       *
 ************************************************************************/

void CTransportHandler::startElevator(int32 elevatorID)
{
    for (auto& i : ElevatorList)
    {
        Elevator_t* elevator = &i;

        if (elevator->id == elevatorID)
        {
            CTransportHandler::startElevator(elevator);
            return;
        }
    }
}

/************************************************************************
 *                                                                       *
 *  Called when an elevator should start moving.                         *
 *                                                                       *
 ************************************************************************/
void CTransportHandler::startElevator(Elevator_t* elevator)
{
    vanadiel_time::time_point vanaTime = vanadiel_time::now();

    // Take care of animation and state changes
    if (elevator->state == STATE_ELEVATOR_TOP)
    {
        elevator->state               = STATE_ELEVATOR_DESCEND;
        elevator->Elevator->animation = elevator->animationsReversed ? ANIMATION_ELEVATOR_UP : ANIMATION_ELEVATOR_DOWN;
        elevator->closeDoor(elevator->UpperDoor);
    }
    else if (elevator->state == STATE_ELEVATOR_BOTTOM)
    {
        elevator->state               = STATE_ELEVATOR_ASCEND;
        elevator->Elevator->animation = elevator->animationsReversed ? ANIMATION_ELEVATOR_DOWN : ANIMATION_ELEVATOR_UP;
        elevator->closeDoor(elevator->LowerDoor);
    }
    else
    {
        return;
    }

    // Update elevator params
    if (!elevator->isPermanent)
    {
        elevator->lastTrigger = vanaTime;
        elevator->activated   = true;
    }
    else
    {
        elevator->lastTrigger = vanaTime - (vanaTime.time_since_epoch() % elevator->interval); // Keep the elevators synced to Vanadiel time
    }

    elevator->Elevator->SetLocalVar("TransportTimestamp", earth_time::vanadiel_timestamp(vanadiel_time::to_earth_time(vanaTime)));

    zoneutils::GetZone(elevator->zoneID)->UpdateEntityPacket(elevator->Elevator, ENTITY_UPDATE, UPDATE_COMBAT, true);
}

/************************************************************************
 *                                                                       *
 *  Called when an elevator has finished moving.                         *
 *                                                                       *
 ************************************************************************/

void CTransportHandler::arriveElevator(Elevator_t* elevator)
{
    // Disable manual elevators
    if (!elevator->isPermanent)
    {
        elevator->activated = false;
    }

    // Update state
    elevator->state = (elevator->state == STATE_ELEVATOR_ASCEND) ? STATE_ELEVATOR_TOP : STATE_ELEVATOR_BOTTOM;

    // Take care of doors
    if (elevator->state == STATE_ELEVATOR_BOTTOM)
    {
        elevator->openDoor(elevator->LowerDoor);
    }
    else if (elevator->state == STATE_ELEVATOR_TOP)
    {
        elevator->openDoor(elevator->UpperDoor);
    }
    else
    {
        ShowError("Elevator %d has malfunctioned", elevator->Elevator->id);
    }
}
