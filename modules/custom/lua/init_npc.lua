-----------------------------------
-- Dynamic Custom NPCs Initialization Script
-- This file handles the automatic loading of all dynamic custom NPCs
-- File: modules/custom/init.lua
--
-- This should be loaded from your main modules directory
-----------------------------------

-- Configuration
local config = {
    enableDebugOutput = true,
    systemName = "Dynamic Custom NPCs"
}

-- Main initialization function
local function initializeDynamicNPCs()
    if config.enableDebugOutput then
        printf("=================================================")
        printf("%s - Initializing...", config.systemName)
        printf("=================================================")
    end

    -- Load the dynamic NPC manager module
    -- This will automatically set up all zone hooks and create NPCs
    local success, npcManager = pcall(require, 'modules/custom/lua/npc_manager')
    
    if success then
        if config.enableDebugOutput then
            printf("%s - Successfully loaded dynamic NPC manager", config.systemName)
        end
        
        -- Optional: Get status after a short delay to let zones initialize
        if _G.dynamicNPCManager then
            -- Small delay to let zones load
            local checkStatus = function()
                local status = _G.dynamicNPCManager.getStatus()
                if config.enableDebugOutput then
                    printf("%s Status:", config.systemName)
                    printf("- Total NPCs: %d", status.totalCount)
                    printf("- Zones with NPCs: %d", #status.activeNPCs > 0 and 1 or 0)
                    for zoneId, count in pairs(status.zoneCount) do
                        printf("  - Zone %d: %d NPCs", zoneId, count)
                    end
                end
            end
            
            -- Use a simple timer if available, otherwise check immediately
            if type(timer) == "function" then
                timer(3000, checkStatus) -- 3 second delay
            else
                checkStatus()
            end
        end
    else
        printf("ERROR: Failed to load dynamic NPC manager: %s", npcManager)
    end
end

-- Initialize the system
if config.enableDebugOutput then
    printf("Starting %s initialization...", config.systemName)
end

initializeDynamicNPCs()

-- Export for manual calling if needed
return {
    initialize = initializeDynamicNPCs,
    config = config
}
