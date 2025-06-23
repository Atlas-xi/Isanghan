-----------------------------------
-- Simple Test NPC for GM_Home - Following Working Pattern Exactly
-- File: modules/custom/test_simple_shop.lua
-----------------------------------
require('modules/module_utils')
require('scripts/zones/GM_Home/Zone')

local m = Module:new('test_simple_shop')

-- Forward declarations (required) - exactly like working example
local menu  = {}
local mainPage = {}
local weaponsPage1 = {}
local weaponsPage2 = {}

-- Delay function exactly like working example
local delaySendMenu = function(player)
    player:timer(50, function(playerArg)
        playerArg:customMenu(menu)
    end)
end

-- Menu structure exactly like working example
menu =
{
    title = 'Simple Test Shop',
    options = {},
}

-- Main page exactly like working example
mainPage =
{
    {
        'Weapons',
        function(playerArg)
            menu.options = weaponsPage1
            delaySendMenu(playerArg)
        end,
    },
    {
        'Leave',
        function(playerArg)
            playerArg:printToPlayer('Thank you for visiting!')
        end,
    },
}

-- Weapons page 1 exactly like working example
weaponsPage1 =
{
    {
        'Item 1 - Bronze Sword - 100 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 1')
            menu.options = weaponsPage1
            delaySendMenu(playerArg)
        end,
    },
    {
        'Item 2 - Mythril Sword - 500 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 2')
            menu.options = weaponsPage1
            delaySendMenu(playerArg)
        end,
    },
    {
        'Item 3 - Iron Sword - 200 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 3')
            menu.options = weaponsPage1
            delaySendMenu(playerArg)
        end,
    },
    {
        'Item 4 - Steel Sword - 300 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 4')
            menu.options = weaponsPage1
            delaySendMenu(playerArg)
        end,
    },
    {
        'Next Page',
        function(playerArg)
            menu.options = weaponsPage2
            delaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            menu.options = mainPage
            delaySendMenu(playerArg)
        end,
    },
}

-- Weapons page 2 exactly like working example
weaponsPage2 =
{
    {
        'Item 5 - Silver Sword - 400 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 5')
            menu.options = weaponsPage2
            delaySendMenu(playerArg)
        end,
    },
    {
        'Item 6 - Gold Sword - 600 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 6')
            menu.options = weaponsPage2
            delaySendMenu(playerArg)
        end,
    },
    {
        'Item 7 - Platinum Sword - 700 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 7')
            menu.options = weaponsPage2
            delaySendMenu(playerArg)
        end,
    },
    {
        'Item 8 - Diamond Sword - 800 gil',
        function(playerArg)
            playerArg:printToPlayer('You selected item 8')
            menu.options = weaponsPage2
            delaySendMenu(playerArg)
        end,
    },
    {
        'Previous Page',
        function(playerArg)
            menu.options = weaponsPage1
            delaySendMenu(playerArg)
        end,
    },
    {
        'Back to Categories',
        function(playerArg)
            menu.options = mainPage
            delaySendMenu(playerArg)
        end,
    },
}

m:addOverride('xi.zones.GM_Home.Zone.onInitialize', function(zone)
    -- Call the zone's original function
    super(zone)

    -- Create simple test shop NPC
    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Simple Shop Test',
        look = '2430',
        x = 15.0,
        y = 0.0,
        z = 0.0,
        rotation = 128,
        widescan = 1,
        
        onTrigger = function(player, npc)
            printf("[SIMPLE SHOP] NPC triggered by %s", player:getName())
            menu.title = 'Simple Test Shop'
            menu.options = mainPage
            delaySendMenu(player)
        end,
        
        onTrade = function(player, npc, trade)
            player:printToPlayer("I don't need anything.", xi.msg.channel.SYSTEM_3)
        end,
    })
end)

return m
