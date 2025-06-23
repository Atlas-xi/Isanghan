-----------------------------------
-- NPC Location Configuration - Production Ready
-- File: modules/custom/lua/npc_locations.lua
-----------------------------------

local npcLocations = {}

-- Production NPCs in Castle Zvahl Baileys (zone 161)
npcLocations.shops = {
    {
        id = "relic_weapon_merchant",
        shopConfig = "rare_items", -- Using available shop config
        zone = 161, -- Castle_Zvahl_Baileys
        position = {
            x = 390.7915,
            y = -12.0000,
            z = -16.6878,
            rotation = 67
        },
        npcData = {
            name = "Relic Weapons",
            look = "2430", -- NPC model
            widescan = 1
        }
    },
    {
        id = "relic_armor_merchant",
        shopConfig = "general_equipment", -- Using available shop config
        zone = 161, -- Castle_Zvahl_Baileys
        position = {
            x = 390.0000,
            y = -12.0000,
            z = -22.0000,
            rotation = 128
        },
        npcData = {
            name = "Relic Armor",
            look = "2433", -- Different NPC model
            widescan = 1
        }
    }
}

-- Test NPCs in GM_Home (zone 210) - for testing only
--[[
npcLocations.shops = {
    {
        id = "test_relic_merchant",
        shopConfig = "rare_items",
        zone = 210, -- GM_Home for testing
        position = {
            x = 10.0,
            y = 0.0,
            z = 0.0,
            rotation = 128
        },
        npcData = {
            name = "Test Relic Merchant",
            look = "2430",
            widescan = 1
        }
    },
    {
        id = "test_consumables_vendor",
        shopConfig = "consumables",
        zone = 210, -- GM_Home for testing
        position = {
            x = 15.0,
            y = 0.0,
            z = 0.0,
            rotation = 64
        },
        npcData = {
            name = "Test Supplies Vendor",
            look = "2433",
            widescan = 1
        }
    }
}
--]]

-- Helper functions remain the same
function npcLocations.validateZoneId(zoneId)
    return type(zoneId) == "number" and zoneId > 0 and zoneId < 1000
end

function npcLocations.getNPCsByZone(zoneId)
    local npcsForZone = {}
    for _, npc in ipairs(npcLocations.shops) do
        if npc.zone == zoneId then
            table.insert(npcsForZone, npc)
        end
    end
    return npcsForZone
end

function npcLocations.getNPCById(npcId)
    for _, npc in ipairs(npcLocations.shops) do
        if npc.id == npcId then
            return npc
        end
    end
    return nil
end

function npcLocations.getZonesWithNPCs()
    local zones = {}
    local seenZones = {}

    for _, npc in ipairs(npcLocations.shops) do
        if not seenZones[npc.zone] then
            table.insert(zones, npc.zone)
            seenZones[npc.zone] = true
        end
    end

    return zones
end

function npcLocations.listAllNPCs()
    printf("=== Dynamic NPC Configuration ===")
    for _, npc in ipairs(npcLocations.shops) do
        printf("ID: %s | Name: %s | Zone: %d | Shop: %s",
            npc.id, npc.npcData.name, npc.zone, npc.shopConfig)
    end
    printf("Total NPCs configured: %d", #npcLocations.shops)
end

return npcLocations

