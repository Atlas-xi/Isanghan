-----------------------------------
-- Area: Port Bastok
--  NPC: Vattian
-- Kuzotz Regional Merchant
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if GetRegionOwner(xi.region.KUZOTZ) ~= xi.nation.BASTOK then
        player:showText(npc, zones[xi.zone.PORT_BASTOK].text.VATTIAN_CLOSED_DIALOG)
    else
        local stock =
        {
            { 916,  855 }, -- Cactuar Needle
            { 4412, 299 }, -- Thundermelon
            { 4491, 184 }, -- Watermelon
        }

        player:showText(npc, zones[xi.zone.PORT_BASTOK].text.VATTIAN_OPEN_DIALOG)
        xi.shop.general(player, stock, xi.fameArea.BASTOK)
    end
end

return entity
