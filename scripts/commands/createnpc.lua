-----------------------------------
-- func: createnpc
-- desc: Creates dynamic NPCs in the current zone with proper integration
-----------------------------------

local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

function commandObj.onTrigger(player, target)
    local zone = player:getZone()
    if not zone then
        player:printToPlayer('You are not in a valid zone.')
        return
    end

    local zoneId = zone:getID()
    player:printToPlayer(string.format('Attempting to create NPCs in zone %d (%s)...', zoneId, zone:getName()))

    -- Try to get the required modules
    local npcLocations, npcCore, shopConfigs
    
    local locSuccess, locResult = pcall(require, 'modules/custom/lua/npc_locations')
    local coreSuccess, coreResult = pcall(require, 'modules/custom/lua/npc_shop_core')
    local shopSuccess, shopResult = pcall(require, 'modules/custom/lua/shop_configs')

    if not locSuccess then
        player:printToPlayer('Could not load NPC locations module.')
        printf('[createnpc] Failed to load npcLocations: %s', tostring(locResult))
        return
    end

    if not coreSuccess then
        player:printToPlayer('Could not load NPC shop core module.')
        printf('[createnpc] Failed to load npcCore: %s', tostring(coreResult))
        return
    end

    if not shopSuccess then
        player:printToPlayer('Could not load shop configs module.')
        printf('[createnpc] Failed to load shopConfigs: %s', tostring(shopResult))
        return
    end

    npcLocations = locResult
    npcCore = coreResult
    shopConfigs = shopResult

    -- Check if this zone has configured NPCs
    local npcsForZone = npcLocations.getNPCsByZone(zoneId)
    if #npcsForZone == 0 then
        player:printToPlayer('No NPCs configured for this zone.')
        return
    end

    player:printToPlayer(string.format('Found %d NPCs to create', #npcsForZone))
    printf('[createnpc] Player %s attempting to create %d NPCs in zone %d', player:getName(), #npcsForZone, zoneId)

    -- Create storage for active NPCs if it doesn't exist
    if not _G.activeNPCs then
        _G.activeNPCs = {}
        printf('[createnpc] Created global activeNPCs storage')
    end

    -- Create NPCs with full functionality
    local createdCount = 0
    for _, npcConfig in ipairs(npcsForZone) do
        -- Check if NPC already exists in our tracking
        if not _G.activeNPCs[npcConfig.id] then
            player:printToPlayer(string.format('Creating NPC: %s', npcConfig.npcData.name))
            printf('[createnpc] Creating NPC: %s', npcConfig.id)

            -- Get the shop configuration
            local shopData = shopConfigs[npcConfig.shopConfig]
            if not shopData then
                printf('[createnpc] ERROR: Shop config "%s" not found for NPC "%s"', npcConfig.shopConfig, npcConfig.id)
                player:printToPlayer(string.format('ERROR: Shop config "%s" not found', npcConfig.shopConfig))
                
                -- List available configs for debugging
                local availableConfigs = {}
                for key, _ in pairs(shopConfigs) do
                    table.insert(availableConfigs, key)
                end
                printf('[createnpc] Available shop configs: %s', table.concat(availableConfigs, ', '))
                goto continue
            end

            -- Create the NPC behavior using the core logic
            local npcBehavior = npcCore.createShopNPC(shopData)
            if not npcBehavior then
                printf('[createnpc] ERROR: Failed to create NPC behavior for %s', npcConfig.id)
                goto continue
            end

            -- Create the NPC entity
            local success, npc = pcall(function()
                return zone:insertDynamicEntity({
                    objtype = xi.objType.NPC,
                    name = npcConfig.npcData.name,
                    look = npcConfig.npcData.look,
                    x = npcConfig.position.x,
                    y = npcConfig.position.y,
                    z = npcConfig.position.z,
                    rotation = npcConfig.position.rotation,
                    widescan = npcConfig.npcData.widescan or 1,

                    onTrade = function(playerArg, npcArg, trade)
                        printf('[NPC] %s onTrade triggered by %s', npcConfig.id, playerArg:getName())
                        if npcBehavior and npcBehavior.onTrade then
                            npcBehavior.onTrade(playerArg, npcArg, trade)
                        else
                            playerArg:printToPlayer("I don't need anything right now.", xi.msg.channel.SYSTEM_3)
                        end
                    end,

                    onTrigger = function(playerArg, npcArg)
                        printf('[NPC] %s onTrigger by %s', npcConfig.id, playerArg:getName())
                        if npcBehavior and npcBehavior.onTrigger then
                            npcBehavior.onTrigger(playerArg, npcArg)
                        else
                            playerArg:printToPlayer(string.format("Hello! I'm %s, but my shop isn't working.", npcConfig.npcData.name), xi.msg.channel.SYSTEM_3)
                        end
                    end,

                    onEventUpdate = function(playerArg, csid, option, npcArg)
                        printf('[NPC] %s onEventUpdate', npcConfig.id)
                        if npcBehavior and npcBehavior.onEventUpdate then
                            npcBehavior.onEventUpdate(playerArg, csid, option, npcArg)
                        end
                    end,

                    onEventFinish = function(playerArg, csid, option, npcArg)
                        printf('[NPC] %s onEventFinish', npcConfig.id)
                        if npcBehavior and npcBehavior.onEventFinish then
                            npcBehavior.onEventFinish(playerArg, csid, option, npcArg)
                        end
                    end
                })
            end)

            if success and npc then
                -- Store the NPC in our tracking system (matching npc_manager pattern)
                _G.activeNPCs[npcConfig.id] = {
                    npc = npc,
                    config = npcConfig,
                    shopData = shopData,
                    zone = zone:getID()
                }

                createdCount = createdCount + 1
                printf('[createnpc] SUCCESS: Created NPC "%s" (ID: %d) at %.2f, %.2f, %.2f in zone %d',
                    npcConfig.npcData.name, npc:getID(),
                    npcConfig.position.x, npcConfig.position.y, npcConfig.position.z,
                    zone:getID())
                
                player:printToPlayer(string.format('✓ Created: %s', npcConfig.npcData.name))
            else
                printf('[createnpc] ERROR: Failed to create NPC entity: %s', tostring(npc))
                player:printToPlayer(string.format('✗ Failed: %s', npcConfig.npcData.name))
            end
        else
            player:printToPlayer(string.format('NPC %s already exists', npcConfig.npcData.name))
            printf('[createnpc] NPC %s already exists in tracking', npcConfig.id)
        end

        ::continue::
    end

    player:printToPlayer(string.format('Created %d/%d NPCs in %s', createdCount, #npcsForZone, zone:getName()))
    
    if createdCount > 0 then
        player:printToPlayer('NPCs with shop functionality should now be available!')
        player:printToPlayer('Try interacting with them to test the menus.')
        
        -- Also make manager functions available if they exist
        if not _G.dynamicNPCManager then
            _G.dynamicNPCManager = {
                getActiveNPC = function(npcId)
                    return _G.activeNPCs[npcId]
                end,
                getStatus = function()
                    local status = {
                        activeNPCs = {},
                        totalCount = 0,
                        zoneCount = {}
                    }
                    
                    for id, npcData in pairs(_G.activeNPCs or {}) do
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
            }
            printf('[createnpc] Created minimal dynamicNPCManager')
        end
    else
        player:printToPlayer('No new NPCs were created. Check console for errors.')
    end

    printf('[createnpc] Command completed: %d NPCs created for player %s', createdCount, player:getName())
end

return commandObj
