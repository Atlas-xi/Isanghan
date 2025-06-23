-----------------------------------
-- Add Armor Shop NPC to Castle Zvahl Baileys (zone 161)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Castle_Zvahl_Baileys/Zone')
-----------------------------------
local m = Module:new('armor_shop_npc')

m:addOverride('xi.zones.Castle_Zvahl_Baileys.Zone.onInitialize', function(zone)
    -- Call the zone's original function for onInitialize
    super(zone)

    -- Insert Currency Shop NPC into zone
    zone:insertDynamicEntity({
        -- NPC type
        objtype = xi.objType.NPC,

        -- The name visible to players
        name = 'Currency',

        -- NPC appearance - using a basic humanoid model
        look = 2430,

        -- Set the position using in-game coordinates
        x = 375.20,
        y = -12.02,
        z = -19.44,

        -- Rotation is scaled 0-255, with 0 being East
        rotation = 27,

        -- Make NPC visible in widescan
        widescan = 1,

        -- Shop functionality on trigger
        onTrigger = function(player, npc)
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
            }

            -- Show shop dialog and open shop
            player:printToPlayer("Welcome to my relic weapons and currency exchange!", 0)
            xi.shop.general(player, stock)
        end,
    })

    -- Insert Base Relic Shop NPC into zone
    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Base Relic',
        look = 2431,
        x = 380.50,
        y = -12.02,
        z = -15.20,
        rotation = 64,
        widescan = 1,
        onTrigger = function(player, npc)
            local stock = {           
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
            player:printToPlayer("Fresh consumables and provisions!", 0)
            xi.shop.general(player, stock)
        end,
    })

    -- Insert Ingredients Shop NPC into zone
    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Ingredients',
        look = 2432,
        x = 370.10,
        y = -12.02,
        z = -22.80,
        rotation = 192,
        widescan = 1,
        onTrigger = function(player, npc)
            local stock = {
                -- Crystals
                { 4096, 100 }, -- Fire Crystal
                { 4097, 100 }, -- Ice Crystal
                { 4098, 100 }, -- Wind Crystal
                { 4099, 100 }, -- Earth Crystal
                { 4100, 100 }, -- Lightning Crystal
                { 4101, 100 }, -- Water Crystal
                { 4102, 100 }, -- Light Crystal
                { 4103, 100 }, -- Dark Crystal
                -- Basic Materials
                { 880, 50 },   -- Copper Ore
                { 881, 75 },   -- Tin Ore
                { 882, 100 },  -- Iron Ore
                { 883, 200 },  -- Silver Ore
                { 884, 500 },  -- Gold Ore
                { 885, 1000 }, -- Platinum Ore
                { 844, 25 },   -- Cotton Cloth
                { 845, 40 },   -- Wool Cloth
                { 846, 60 },   -- Silk Cloth
                { 847, 100 },  -- Velvet Cloth
            }
            player:printToPlayer("Quality materials for all your crafting needs!", 0)
            xi.shop.general(player, stock)
        end,
    })
end)

return m
