-----------------------------------
-- Area: Bastok Mines
--  NPC: Boytz
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.BRASS_FLOWERPOT,      1050, 3 },
        { xi.item.PICKAXE,               210, 3 },
        { xi.item.FLASK_OF_EYE_DROPS,   2724, 3 },
        { xi.item.ANTIDOTE,              331, 3 },
        { xi.item.FLASK_OF_ECHO_DROPS,   840, 2 },
        { xi.item.POTION,                955, 2 },
        { xi.item.ETHER,                5025, 1 },
        { xi.item.WOODEN_ARROW,            4, 2 },
        { xi.item.IRON_ARROW,              8, 3 },
        { xi.item.CROSSBOW_BOLT,           6, 3 },
        { xi.item.REPUBLIC_WAYSTONE,   10500, 3 },
    }

    -- Thief's tools.
    if GetNationRank(player:getNation()) >= 2 then -- Player nation rank 2 or 3.
        table.insert(stock, { xi.item.SET_OF_THIEFS_TOOLS, 4158, 3 })
    end

    -- Living Key.
    local sandyNationRank  = GetNationRank(xi.nation.SANDORIA)
    local bastokNationRank = GetNationRank(xi.nation.BASTOK)
    local windyNationRank  = GetNationRank(xi.nation.WINDURST)
    if
        (bastokNationRank == sandyNationRank and bastokNationRank == windyNationRank) or                        -- All 3 nations tied.
        (bastokNationRank ~= sandyNationRank and bastokNationRank ~= windyNationRank and bastokNationRank == 3) -- Nation not tied and nation last.
    then
        table.insert(stock, { xi.item.LIVING_KEY, 5520, 3 })
    end

    player:showText(npc, zones[xi.zone.BASTOK_MINES].text.BOYTZ_SHOP_DIALOG)
    xi.shop.nation(player, stock, xi.nation.BASTOK)
end

return entity
