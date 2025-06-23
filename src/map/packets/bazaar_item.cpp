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

#include "bazaar_item.h"

#include "common/utils.h"
#include "common/vana_time.h"

#include <cstring>

#include "utils/itemutils.h"

CBazaarItemPacket::CBazaarItemPacket(CItem* PItem, uint8 SlotID, uint16 Tax)
{
    this->setType(0x105);
    this->setSize(0x2E);

    ref<uint8>(0x10) = SlotID;

    if (PItem != nullptr)
    {
        ref<uint32>(0x04) = PItem->getCharPrice();
        ref<uint32>(0x08) = PItem->getQuantity();
        ref<uint16>(0x0C) = Tax;
        ref<uint16>(0x0E) = PItem->getID();

        if (PItem->isSubType(ITEM_CHARGED) && PItem->isType(ITEM_USABLE))
        {
            timer::time_point currentTime = timer::now();
            timer::time_point nextUseTime = static_cast<CItemUsable*>(PItem)->getNextUseTime();

            ref<uint8>(0x11) = 0x01; // ITEM_CHARGED flag
            ref<uint8>(0x12) = ((CItemUsable*)PItem)->getCurrentCharges();
            ref<uint8>(0x14) = (nextUseTime > currentTime ? 0x90 : 0xD0);

            ref<uint32>(0x15) = earth_time::vanadiel_timestamp(timer::to_utc(nextUseTime));
            ref<uint32>(0x19) = static_cast<uint32>(timer::count_seconds(static_cast<CItemUsable*>(PItem)->getUseDelay()) + earth_time::vanadiel_timestamp());
        }
        else
        {
            std::memcpy(buffer_.data() + 0x11, PItem->m_extra, std::min<size_t>(CItem::extra_size, 24));
        }
    }
}
