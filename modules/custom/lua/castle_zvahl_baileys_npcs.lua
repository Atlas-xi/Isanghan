-----------------------------------
-- Castle Zvahl Baileys NPCs - Following Working Pattern
-- File: modules/custom/castle_zvahl_npcs.lua
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Castle_Zvahl_Baileys/Zone')

local m = Module:new('castle_zvahl_npcs')

-- =================================
-- RELIC WEAPON MERCHANT (rare_items)
-- =================================

-- Forward declarations for Relic Weapon Merchant
local weaponMenu = {}
local weaponMainPage = {}
local weaponItemsPage1 = {}
local weaponItemsPage2 = {}
local weaponBaseWeaponPage1 = {}
local weaponBaseWeaponPage2 = {}
local weaponCurrencyPage1 = {}

-- Delay function for weapon merchant
local weaponDelaySendMenu = function(player)
    player:timer(50, function(playerArg)
        playerArg:customMenu(weaponMenu)
    end)
end

-- Weapon merchant menu structure
weaponMenu =
{
    title = 'I deal in rare and special items...',
    options = {},
}

-- Weapon merchant main page
weaponMainPage =
{
    {
        'Items',
        function(playerArg)
            weaponMenu.options = weaponItemsPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Base Weapons',
        function(playerArg)
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Currency',
        function(playerArg)
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Leave',
        function(playerArg)
            playerArg:printToPlayer('These items won\'t last long!')
        end,
    },
}

-- Weapon merchant - Items page 1
weaponItemsPage1 =
{
    {
        'Amaltheia Leather - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(875)
                playerArg:printToPlayer('You purchased Amaltheia Leather!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Orichalcum Sheet - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(668)
                playerArg:printToPlayer('You purchased Orichalcum Sheet!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Ancient Lumber - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(720)
                playerArg:printToPlayer('You purchased Ancient Lumber!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Buckler - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(12301)
                playerArg:printToPlayer('You purchased Buckler!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Round Shield - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(12295)
                playerArg:printToPlayer('You purchased Round Shield!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Next Page',
        function(playerArg)
            weaponMenu.options = weaponItemsPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            weaponMenu.options = weaponMainPage
            weaponDelaySendMenu(playerArg)
        end,
    },
}

-- Weapon merchant - Items page 2
weaponItemsPage2 =
{
    {
        'Koenig Shield - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(12387)
                playerArg:printToPlayer('You purchased Koenig Shield!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Attestation of Invulnerability - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1821)
                playerArg:printToPlayer('You purchased Attestation of Invulnerability!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Necropsyche - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1589)
                playerArg:printToPlayer('You purchased Necropsyche!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Supernal Fragment - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1822)
                playerArg:printToPlayer('You purchased Supernal Fragment!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponItemsPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Previous Page',
        function(playerArg)
            weaponMenu.options = weaponItemsPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            weaponMenu.options = weaponMainPage
            weaponDelaySendMenu(playerArg)
        end,
    },
}

-- Base Weapons page 1 (8 items to test limit)
weaponBaseWeaponPage1 =
{
    {
        'Relic Knuckles - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18260)
                playerArg:printToPlayer('You purchased Relic Knuckles!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Dagger - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18266)
                playerArg:printToPlayer('You purchased Relic Dagger!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Sword - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18272)
                playerArg:printToPlayer('You purchased Relic Sword!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Blade - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18278)
                playerArg:printToPlayer('You purchased Relic Blade!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Axe - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18284)
                playerArg:printToPlayer('You purchased Relic Axe!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Bhuj - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18290)
                playerArg:printToPlayer('You purchased Relic Bhuj!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Lance - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18296)
                playerArg:printToPlayer('You purchased Relic Lance!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Scythe - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18302)
                playerArg:printToPlayer('You purchased Relic Scythe!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Next Page',
        function(playerArg)
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            weaponMenu.options = weaponMainPage
            weaponDelaySendMenu(playerArg)
        end,
    },
}

-- Base Weapons page 2
weaponBaseWeaponPage2 =
{
    {
        'Ihintanto - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18308)
                playerArg:printToPlayer('You purchased Ihintanto!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Ito - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18314)
                playerArg:printToPlayer('You purchased Ito!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Maul - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18320)
                playerArg:printToPlayer('You purchased Relic Maul!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Staff - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18326)
                playerArg:printToPlayer('You purchased Relic Staff!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Gun - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18332)
                playerArg:printToPlayer('You purchased Relic Gun!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Horn - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18338)
                playerArg:printToPlayer('You purchased Relic Horn!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Bow - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(18344)
                playerArg:printToPlayer('You purchased Relic Bow!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Relic Shield - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(15066)
                playerArg:printToPlayer('You purchased Relic Shield!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponBaseWeaponPage2
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Previous Page',
        function(playerArg)
            weaponMenu.options = weaponBaseWeaponPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            weaponMenu.options = weaponMainPage
            weaponDelaySendMenu(playerArg)
        end,
    },
}

-- Currency page
weaponCurrencyPage1 =
{
    {
        'One Byne Bill - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1455)
                playerArg:printToPlayer('You purchased One Byne Bill!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'One Hundred Byne Bill - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1456)
                playerArg:printToPlayer('You purchased One Hundred Byne Bill!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Ten Thousand Byne Bill - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1457)
                playerArg:printToPlayer('You purchased Ten Thousand Byne Bill!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Tukuku Whiteshell - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1449)
                playerArg:printToPlayer('You purchased Tukuku Whiteshell!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Lungo Nango Jadeshell - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1450)
                playerArg:printToPlayer('You purchased Lungo Nango Jadeshell!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Rimilala Stripeshell - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1451)
                playerArg:printToPlayer('You purchased Rimilala Stripeshell!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Ordelle Bronzepiece - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1452)
                playerArg:printToPlayer('You purchased Ordelle Bronzepiece!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Montiont Silverpiece - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1453)
                playerArg:printToPlayer('You purchased Montiont Silverpiece!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Ranperre Goldpiece - 1 gil',
        function(playerArg)
            if playerArg:getGil() >= 1 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1)
                playerArg:addItem(1454)
                playerArg:printToPlayer('You purchased Ranperre Goldpiece!')
            else
                playerArg:printToPlayer('You need 1 gil and inventory space!')
            end
            weaponMenu.options = weaponCurrencyPage1
            weaponDelaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            weaponMenu.options = weaponMainPage
            weaponDelaySendMenu(playerArg)
        end,
    },
}

-- =================================
-- RELIC ARMOR MERCHANT (general_equipment) - Simplified for testing
-- =================================

local armorMenu = {}
local armorMainPage = {}
local armorWeaponsPage1 = {}

local armorDelaySendMenu = function(player)
    player:timer(50, function(playerArg)
        playerArg:customMenu(armorMenu)
    end)
end

armorMenu =
{
    title = 'Welcome to my relic shop!',
    options = {},
}

armorMainPage =
{
    {
        'Weapons',
        function(playerArg)
            armorMenu.options = armorWeaponsPage1
            armorDelaySendMenu(playerArg)
        end,
    },
    {
        'Leave',
        function(playerArg)
            playerArg:printToPlayer('Come back anytime for quality gear!')
        end,
    },
}

armorWeaponsPage1 =
{
    {
        'Bronze Sword - 1000 gil',
        function(playerArg)
            if playerArg:getGil() >= 1000 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(1000)
                playerArg:addItem(16482)
                playerArg:printToPlayer('You purchased Bronze Sword!')
            else
                playerArg:printToPlayer('You need 1000 gil and inventory space!')
            end
            armorMenu.options = armorWeaponsPage1
            armorDelaySendMenu(playerArg)
        end,
    },
    {
        'Mythril Sword - 2500 gil',
        function(playerArg)
            if playerArg:getGil() >= 2500 and playerArg:getFreeSlotsCount() > 0 then
                playerArg:delGil(2500)
                playerArg:addItem(16640)
                playerArg:printToPlayer('You purchased Mythril Sword!')
            else
                playerArg:printToPlayer('You need 2500 gil and inventory space!')
            end
            armorMenu.options = armorWeaponsPage1
            armorDelaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            armorMenu.options = armorMainPage
            armorDelaySendMenu(playerArg)
        end,
    },
}

-- =================================
-- ZONE INITIALIZATION
-- =================================

m:addOverride('xi.zones.Castle_Zvahl_Baileys.Zone.onInitialize', function(zone)
    -- Call the zone's original function
    super(zone)

    printf("[Castle Zvahl] Creating NPCs...")

    -- Create Relic Weapon Merchant
    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Relic Weapon Merchant',
        look = '2430',
        x = 390.7915,
        y = -12.0000,
        z = -16.6878,
        rotation = 67,
        widescan = 1,
        
        onTrigger = function(player, npc)
            printf("[Weapon Merchant] Triggered by %s", player:getName())
            weaponMenu.title = 'I deal in rare and special items...'
            weaponMenu.options = weaponMainPage
            weaponDelaySendMenu(player)
        end,
        
        onTrade = function(player, npc, trade)
            player:printToPlayer("I'm not interested in trades right now.")
        end,
    })

    -- Create Relic Armor Merchant
    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Relic Armor Merchant',
        look = '2433',
        x = 390.0000,
        y = -12.0000,
        z = -22.0000,
        rotation = 128,
        widescan = 1,
        
        onTrigger = function(player, npc)
            printf("[Armor Merchant] Triggered by %s", player:getName())
            armorMenu.title = 'Welcome to my relic shop!'
            armorMenu.options = armorMainPage
            armorDelaySendMenu(player)
        end,
        
        onTrade = function(player, npc, trade)
            player:printToPlayer("I'm not interested in trades right now.")
        end,
    })

    printf("[Castle Zvahl] NPCs created successfully!")
end)

return m
