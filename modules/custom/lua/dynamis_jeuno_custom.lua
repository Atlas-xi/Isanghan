
-----------------------------------
-- Custom Dynamis-Jeuno Module
-- Purpose: Add custom merchant NPC to Dynamis-Jeuno
-- Location: modules/custom/lua/dynamis_jeuno_custom.lua
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Dynamis-Jeuno/Zone')

local m = Module:new('dynamis_jeuno_custom')

-- Use the working zone name format: xi.zones.Dynamis-Jeuno.Zone.onInitialize
m:addOverride('xi.zones.Dynamis-Jeuno.Zone.onInitialize', function(zone)
    super(zone)
    print("SUCCESS: Dynamis-Jeuno override working!")

    -- Remove all unwanted mobs except quest-spawnable ones
    local keepMobs = {
        17547265, -- Goblin Golem
        17547499, -- Arch Goblin Golem
        17547493, -- Quicktrix Hexhands
        17547494, -- Feralox Honeylips
        17547496, -- Scourquix Scaleskin
        17547498, -- Wilywox Tenderpalm
    }

    -- Create a lookup table for faster checking
    local keepMobsLookup = {}
    for _, mobId in ipairs(keepMobs) do
        keepMobsLookup[mobId] = true
    end

    -- Remove all unwanted mobs from the zone
    print("Dynamis-Jeuno: Starting mob removal")
    local removedCount = 0
    for mobId = 17547265, 17547510 do
        if not keepMobsLookup[mobId] then
            local mob = GetMobByID(mobId)
            if mob then
                mob:setSpawn(0, 0, 0, 0) -- Remove spawn position
                mob:setRespawnTime(0) -- Prevent respawn
                DespawnMob(mobId) -- Despawn if currently spawned
                removedCount = removedCount + 1
            end
        end
    end
    print("Dynamis-Jeuno: Removed " .. removedCount .. " mobs")

    -- Add custom merchant NPC
    print("Dynamis-Jeuno: Adding custom merchant")
    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Dyna Merchant', -- Shorter name to avoid truncation
        look = 2430,
        x = 54.84,
        y = 10.00,
        z = -66.90,
        rotation = 133,
        widescan = 1,

        onTrigger = function(player, npc)
            local stock = {
                { 3356, 100 },  -- Roving Bijou
                { 3392, 100 },  -- Odious Cup
                { 3393, 100 },  -- Odious Die
                { 3394, 100 },  -- Odious Mask
                { 3395, 100 },  -- Odious Grenade
            }

            player:printToPlayer("Welcome to the Dynamis Exchange! What can I get for you?", 0)
            xi.shop.general(player, stock)
        end,
    })

    print("Dynamis-Jeuno: Customizations complete")
end)

return m
