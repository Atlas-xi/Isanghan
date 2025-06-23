-----------------------------------
-- Dynamic NPC Manager - Corrected for LandSandBoat
-- File: modules/custom/lua/npc_manager.lua
-----------------------------------
require('modules/module_utils')

local npcCore = require('modules/custom/lua/npc_shop_core')
local shopConfigs = require('modules/custom/lua/shop_configs')
local npcLocations = require('modules/custom/lua/npc_locations')

local m = Module:new('dynamic_npc_manager')

-- Storage for active NPCs
local activeNPCs = {}

-- Create a single NPC as a dynamic entity
local function createDynamicNPC(zone, npcConfig)
    printf("[DEBUG] ===== Starting NPC Creation =====")
    printf("[DEBUG] Creating NPC: %s in zone %d", npcConfig.id, zone:getID())
    printf("[DEBUG] NPC Config: %s", tostring(npcConfig))
    
    -- Check if zone is valid
    if not zone then
        printf("ERROR: Zone is nil!")
        return nil
    end
    
    -- Check if npcConfig is valid
    if not npcConfig then
        printf("ERROR: NPC config is nil!")
        return nil
    end
    
    printf("[DEBUG] NPC shop config: %s", npcConfig.shopConfig or "nil")
    printf("[DEBUG] NPC position: x=%.2f, y=%.2f, z=%.2f", 
        npcConfig.position.x or 0, npcConfig.position.y or 0, npcConfig.position.z or 0)
    printf("[DEBUG] NPC name: %s", npcConfig.npcData.name or "nil")
    printf("[DEBUG] NPC look: %s", npcConfig.npcData.look or "nil")
    
    -- Test if we can access required modules
    if not shopConfigs then
        printf("ERROR: shopConfigs module not loaded!")
        return nil
    end
    
    if not npcCore then
        printf("ERROR: npcCore module not loaded!")
        return nil
    end
    
    -- Get the shop configuration
    local shopData = shopConfigs[npcConfig.shopConfig]
    if not shopData then
        printf("ERROR: Shop config '%s' not found for NPC '%s'", npcConfig.shopConfig, npcConfig.id)
        -- List available configs
        local availableConfigs = {}
        for key, _ in pairs(shopConfigs or {}) do
            table.insert(availableConfigs, key)
        end
        printf("ERROR: Available shop configs: %s", table.concat(availableConfigs, ", "))
        return nil
    end
    printf("[DEBUG] Shop data found: %s", tostring(shopData))

    -- Create the NPC behavior using the core logic
    local npcBehavior = npcCore.createShopNPC(shopData)
    if not npcBehavior then
        printf("ERROR: Failed to create NPC behavior for %s", npcConfig.id)
        return nil
    end
    printf("[DEBUG] NPC behavior created successfully")

    -- Test basic NPC creation first (without shop behavior)
    printf("[DEBUG] Attempting to create basic NPC entity...")
    local npc = zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = npcConfig.npcData.name,
        look = npcConfig.npcData.look,
        x = npcConfig.position.x,
        y = npcConfig.position.y,
        z = npcConfig.position.z,
        rotation = npcConfig.position.rotation,
        widescan = npcConfig.npcData.widescan or 1,

        onTrade = function(player, npc, trade)
            printf("[DEBUG] NPC %s onTrade called", npcConfig.id)
            if npcBehavior and npcBehavior.onTrade then
                npcBehavior.onTrade(player, npc, trade)
            else
                player:printToPlayer("I don't need anything right now.")
            end
        end,

        onTrigger = function(player, npc)
            printf("[DEBUG] NPC %s onTrigger called", npcConfig.id)
            if npcBehavior and npcBehavior.onTrigger then
                npcBehavior.onTrigger(player, npc)
            else
                player:printToPlayer(string.format("Hello! I'm %s.", npcConfig.npcData.name))
            end
        end,

        onEventUpdate = function(player, csid, option, npc)
            printf("[DEBUG] NPC %s onEventUpdate called", npcConfig.id)
            if npcBehavior and npcBehavior.onEventUpdate then
                npcBehavior.onEventUpdate(player, csid, option, npc)
            end
        end,

        onEventFinish = function(player, csid, option, npc)
            printf("[DEBUG] NPC %s onEventFinish called", npcConfig.id)
            if npcBehavior and npcBehavior.onEventFinish then
                npcBehavior.onEventFinish(player, csid, option, npc)
            end
        end
    })

    if npc then
        printf("SUCCESS: Created NPC '%s' (ID: %d) at %.2f, %.2f, %.2f in zone %d",
            npcConfig.npcData.name, npc:getID(),
            npcConfig.position.x, npcConfig.position.y, npcConfig.position.z,
            zone:getID())

        -- Store reference to the active NPC
        activeNPCs[npcConfig.id] = {
            npc = npc,
            config = npcConfig,
            shopData = shopData,
            zone = zone:getID()
        }
        printf("[DEBUG] ===== NPC Creation Complete =====")
        return npc
    else
        printf("ERROR: insertDynamicEntity returned nil for NPC: %s", npcConfig.id)
        printf("[DEBUG] ===== NPC Creation Failed =====")
        return nil
    end
end

-- Setup zone overrides for each zone that needs NPCs
local function setupZoneOverrides()
    local zonesWithNPCs = npcLocations.getZonesWithNPCs()
    printf("[DEBUG] Setting up overrides for zones: %s", table.concat(zonesWithNPCs, ", "))

    for _, zoneId in ipairs(zonesWithNPCs) do
        local zoneName = GetZoneName(zoneId)
        if zoneName then
            printf("[DEBUG] Attempting to create override for zone ID %d (%s)", zoneId, zoneName)
            
            -- Try multiple possible override paths
            local possiblePaths = {
                -- LandSandBoat zone path variations
                string.format('xi.zones.%s.Zone.onInitialize', zoneName),
                string.format('xi.zones.%s.onInitialize', zoneName),
                string.format('zones.%s.Zone.onInitialize', zoneName),
                string.format('zones.%s.onInitialize', zoneName),
                string.format('%s.Zone.onInitialize', zoneName),
                string.format('%s.onInitialize', zoneName),
                -- Try with zone ID
                string.format('xi.zones.zone%d.Zone.onInitialize', zoneId),
                string.format('xi.zones.zone%d.onInitialize', zoneId),
                -- Try with mixed case
                string.format('xi.zones.%s.Zone.onInitialize', zoneName:lower()),
                string.format('xi.zones.%s.onInitialize', zoneName:lower()),
                -- Try GM_Home specific variations if it's zone 210
                zoneId == 210 and 'xi.zones.GM_Home.Zone.onInitialize' or nil,
                zoneId == 210 and 'xi.zones.GM_Home.onInitialize' or nil,
                zoneId == 210 and 'xi.zones.gm_home.Zone.onInitialize' or nil,
                zoneId == 210 and 'xi.zones.gm_home.onInitialize' or nil
            }
            
            local overrideCreated = false
            for i, path in ipairs(possiblePaths) do
                printf("[DEBUG] Trying override path %d: %s", i, path)
                
                local success, err = pcall(function()
                    m:addOverride(path, function(zone)
                        printf("[ZONE OVERRIDE] *** Zone %d (%s) onInitialize triggered via path: %s ***", zone:getID(), zone:getName(), path)
                        
                        -- Call the zone's original onInitialize function if it exists
                        if super then
                            local success, err = pcall(super, zone)
                            if not success then
                                printf("[WARNING] super() call failed: %s", tostring(err))
                            end
                        end

                        printf("[DEBUG] Processing NPCs for zone %d (%s)", zone:getID(), zone:getName())

                        -- Get NPCs for this zone
                        local npcsForZone = npcLocations.getNPCsByZone(zone:getID())
                        printf("[DEBUG] Found %d NPCs to create for zone %d", #npcsForZone, zone:getID())
                        
                        local addedCount = 0

                        for _, npcConfig in ipairs(npcsForZone) do
                            printf("[DEBUG] Attempting to create NPC: %s", npcConfig.id)
                            local success, result = pcall(createDynamicNPC, zone, npcConfig)
                            if success and result then
                                addedCount = addedCount + 1
                                printf("[DEBUG] Successfully created NPC: %s", npcConfig.id)
                            elseif not success then
                                printf("ERROR: Failed to create NPC %s - %s", npcConfig.id, tostring(result))
                            else
                                printf("ERROR: NPC creation returned nil for %s", npcConfig.id)
                            end
                        end

                        if addedCount > 0 then
                            printf("SUCCESS: Added %d shop NPCs to %s (zone %d)", 
                                addedCount, zone:getName(), zone:getID())
                        else
                            printf("WARNING: No NPCs were added to zone %d", zone:getID())
                        end
                    end)
                end)
                
                if success then
                    printf("[DEBUG] Successfully created override with path: %s", path)
                    overrideCreated = true
                    break
                else
                    printf("[DEBUG] Failed to create override with path %s: %s", path, tostring(err))
                end
            end
            
            if not overrideCreated then
                printf("ERROR: Could not create any override for zone %d (%s)", zoneId, zoneName)
                printf("ERROR: All attempted paths failed. Zone may not exist or override system may not be working.")
            end
        else
            printf("ERROR: Could not get zone name for zone ID %d", zoneId)
        end
    end
end

-- Helper function to get zone name for override
function GetZoneName(zoneId)
    -- Manual mapping for zones with known script names
    local zoneNames = {
        [161] = "Castle_Zvahl_Baileys", -- Exact case from LandSandBoat
        [230] = "Southern_San_dOria",
        [235] = "Northern_San_dOria", 
        [240] = "Bastok_Markets",
        [245] = "Bastok_Mines",
        [250] = "Port_Bastok",
        [210] = "GM_Home", -- For testing
        [238] = "Chateau_dOraguille",
        [241] = "Metalworks",
        [248] = "Windurst_Waters",
        [239] = "Port_San_dOria",
        [249] = "Windurst_Walls",
        [246] = "Windurst_Woods",
        [251] = "Port_Windurst",
        [252] = "Kazham",
        [253] = "Norg",
        [254] = "Rabao",
        [255] = "Selbina",
        [256] = "Mhaura"
    }
    
    local zoneName = zoneNames[zoneId]
    if zoneName then
        return zoneName
    end
    
    -- Try to get zone name from xi.zone constants if available
    if xi and xi.zone then
        for constantName, id in pairs(xi.zone) do
            if id == zoneId then
                -- Convert constant name to script folder name format
                local scriptName = constantName:gsub("_", "_")
                -- Convert to proper case (first letter upper, rest as-is)
                scriptName = scriptName:sub(1,1):upper() .. scriptName:sub(2):lower()
                printf("[DEBUG] Auto-detected zone name for %d: %s", zoneId, scriptName)
                return scriptName
            end
        end
    end
    
    -- If not found, log it and return nil
    printf("[WARNING] Unknown zone ID %d - add it to GetZoneName function", zoneId)
    return nil
end

-- Public functions for management
local npcManager = {}

function npcManager.getActiveNPC(npcId)
    return activeNPCs[npcId]
end

function npcManager.getStatus()
    local status = {
        activeNPCs = {},
        totalCount = 0,
        zoneCount = {}
    }

    for id, npcData in pairs(activeNPCs) do
        table.insert(status.activeNPCs, {
            id = id,
            name = npcData.config.npcData.name,
            zone = npcData.zone
        })
        status.totalCount = status.totalCount + 1

        if not status.zoneCount[npcData.zone] then
            status.zoneCount[npcData.zone] = 0
        end
        status.zoneCount[npcData.zone] = status.zoneCount[npcData.zone] + 1
    end

    return status
end

function npcManager.debugInfo()
    printf("=== Dynamic NPC Manager Debug ===")
    local status = npcManager.getStatus()
    printf("Total NPCs: %d", status.totalCount)
    
    for zoneId, count in pairs(status.zoneCount) do
        printf("Zone %d: %d NPCs", zoneId, count)
    end
    
    for _, npcInfo in ipairs(status.activeNPCs) do
        printf("- %s (%s) in zone %d", npcInfo.name, npcInfo.id, npcInfo.zone)
    end
end

-- Add a manual creation function for testing
function npcManager.createNPCsInZone(zoneId)
    printf("[MANUAL] Attempting to create NPCs in zone %d", zoneId)
    
    -- Get NPCs configured for this zone
    local npcsForZone = npcLocations.getNPCsByZone(zoneId)
    if #npcsForZone == 0 then
        printf("[MANUAL] No NPCs configured for zone %d", zoneId)
        return 0
    end
    
    printf("[MANUAL] Found %d NPCs to create", #npcsForZone)
    
    -- Try to find the zone by checking all existing zones
    local targetZone = nil
    
    -- Use xi.zone constants to find the zone
    if zoneId == 210 then -- GM_Home
        -- For GM_Home, we need to get the zone instance differently
        -- Try to get it from the zone registry
        for i = 1, 300 do
            local zone = GetZone(i)
            if zone and zone:getID() == zoneId then
                targetZone = zone
                printf("[MANUAL] Found zone %d (%s) using GetZone", zone:getID(), zone:getName())
                break
            end
        end
    end
    
    if not targetZone then
        printf("[MANUAL] Could not find zone %d", zoneId)
        return 0
    end
    
    local createdCount = 0
    for _, npcConfig in ipairs(npcsForZone) do
        if not activeNPCs[npcConfig.id] then
            printf("[MANUAL] Creating NPC: %s", npcConfig.id)
            local success, npc = pcall(createDynamicNPC, targetZone, npcConfig)
            if success and npc then
                createdCount = createdCount + 1
                printf("[MANUAL] Successfully created: %s", npcConfig.id)
            else
                printf("[MANUAL] Failed to create %s: %s", npcConfig.id, tostring(npc))
            end
        else
            printf("[MANUAL] NPC %s already exists", npcConfig.id)
        end
    end
    
    printf("[MANUAL] Created %d NPCs in zone %d", createdCount, zoneId)
    return createdCount
end

-- Make the manual function available globally
_G.createNPCsManually = npcManager.createNPCsInZone

-- Initialize the system with error handling
printf("[Dynamic NPCs] *** MODULE LOADING STARTED ***")

-- Test if required modules are working
printf("[DEBUG] Testing module dependencies...")
if npcCore then
    printf("[DEBUG] ✓ npcCore module loaded")
else
    printf("[ERROR] ✗ npcCore module failed to load")
end

if shopConfigs then
    printf("[DEBUG] ✓ shopConfigs module loaded")
    -- Get available shop configs
    local availableConfigs = {}
    for key, _ in pairs(shopConfigs) do
        table.insert(availableConfigs, key)
    end
    printf("[DEBUG] Available shop configs: %s", table.concat(availableConfigs, ", "))
else
    printf("[ERROR] ✗ shopConfigs module failed to load")
end

if npcLocations then
    printf("[DEBUG] ✓ npcLocations module loaded")
else
    printf("[ERROR] ✗ npcLocations module failed to load")
end

-- Test if npcLocations is working
local zonesWithNPCs = npcLocations.getZonesWithNPCs()
printf("[Dynamic NPCs] Found zones with NPCs: %s", table.concat(zonesWithNPCs, ", "))

-- List all NPCs to verify configuration
npcLocations.listAllNPCs()

local success, error = pcall(function()
    printf("[Dynamic NPCs] Initializing NPC system...")
    setupZoneOverrides()
    
    -- Remove zone-specific alternative hooks - the system is now generic
    printf("[Dynamic NPCs] Generic zone system ready for any zone")
    
    -- Add a global player zone change listener as a last resort
    printf("[Dynamic NPCs] Adding global zone change listener...")
    local success, err = pcall(function()
        m:addOverride('CPlayer.setZone', function(player, zoneid, ...)
            -- Call original function
            local result = super(player, zoneid, ...)
            
            -- Check if this is a zone we care about
            for _, targetZoneId in ipairs(zonesWithNPCs) do
                if zoneid == targetZoneId then
                    printf("[GLOBAL LISTENER] Player %s entered target zone %d", player:getName(), zoneid)
                    
                    -- Small delay to ensure zone is loaded
                    player:timer(1000, function(player)
                        local zone = player:getZone()
                        if zone then
                            local npcsForZone = npcLocations.getNPCsByZone(zoneid)
                            printf("[GLOBAL LISTENER] Creating %d NPCs for zone %d", #npcsForZone, zoneid)
                            
                            for _, npcConfig in ipairs(npcsForZone) do
                                if not activeNPCs[npcConfig.id] then
                                    printf("[GLOBAL LISTENER] Creating NPC: %s", npcConfig.id)
                                    local npcSuccess, npc = pcall(createDynamicNPC, zone, npcConfig)
                                    if npcSuccess and npc then
                                        printf("[GLOBAL LISTENER] Successfully created NPC: %s", npcConfig.id)
                                    end
                                end
                            end
                        end
                    end)
                    break
                end
            end
            
            return result
        end)
    end)
    
    if success then
        printf("[DEBUG] Successfully created global zone change listener")
    else
        printf("[DEBUG] Failed to create global zone change listener: %s", tostring(err))
    end
    
    -- Make manager available globally
    _G.dynamicNPCManager = npcManager
    
    printf("[Dynamic NPCs] System ready - %d zones configured", 
        #npcLocations.getZonesWithNPCs())
end)

if not success then
    printf("ERROR: Failed to initialize Dynamic NPC system: %s", tostring(error))
else
    printf("[Dynamic NPCs] *** MODULE LOADING COMPLETED SUCCESSFULLY ***")
end

return m
