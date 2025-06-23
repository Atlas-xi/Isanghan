-----------------------------------
-- Custom NPC: Armor
-- Area: Castle Zvahl Baileys
-- Type: Relic Weapons & Currency Shop
-- Location: 375.20, -12.02, -19.44, Rotation: 27
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock = {
        -- Currency Items
        { 1455, 1 }, -- One Byne Bill
        { 1456, 1 }, -- One Hundred Byne Bill
        { 1457, 1 }, -- Ten Thousand Byne Bill
        { 1449, 1 }, -- Tukuku Whiteshell
        { 1450, 1 }, -- Lungo Nango Jadeshell
        { 1451, 1 }, -- Rimilala Stripeshell
        { 1452, 1 }, -- Ordelle Bronzepiece
        { 1453, 1 }, -- Montiont Silverpiece
        { 1454, 1 }, -- Ranperre Goldpiece
        
        -- Relic Weapons
        { 18260, 1 }, -- Relic Knuckles
        { 18266, 1 }, -- Relic Dagger
        { 18272, 1 }, -- Relic Sword
        { 18278, 1 }, -- Relic Blade
        { 18284, 1 }, -- Relic Axe
        { 18290, 1 }, -- Relic Bhuj
        { 18296, 1 }, -- Relic Lance
        { 18302, 1 }, -- Relic Scythe
        { 18308, 1 }, -- Ihintanto
        { 18314, 1 }, -- Ito
        { 18320, 1 }, -- Relic Maul
        { 18326, 1 }, -- Relic Staff
        { 18332, 1 }, -- Relic Gun
        { 18338, 1 }, -- Relic Horn
        { 18344, 1 }, -- Relic Bow
        { 15066, 1 }, -- Relic Shield
    }

    -- Show shop dialog and open shop
    player:showText(npc, "Welcome to my relic weapons and currency exchange!")
    xi.shop.general(player, stock)
end

return entity
