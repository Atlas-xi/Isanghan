-----------------------------------
-- func: warp
-- desc: Saves and recalls up to 10 custom warp locations per player using cjson.
-- usage:
--   !warp set <1-10>      - Saves current position if slot is empty
--   !warp <1-10>          - Warps to a saved slot
--   !warp delete <1-10>   - Deletes a warp slot
--   !warp list            - Lists all saved warps
--   !warp help            - Displays help
-----------------------------------
local cjson = require("cjson.safe")
local warpPath = "scripts/globals/warps"

---@type TCommand
local commandObj = {}

commandObj.cmdprops = {
    permission = 0,
    parameters = "ss"
}

-- Load warp data for player
local function loadWarpData(player)
    local filePath = string.format("%s/%s.json", warpPath, player:getName():lower())
    local f = io.open(filePath, "r")
    if not f then return {} end
    local content = f:read("*a")
    f:close()
    return cjson.decode(content) or {}
end

-- Save warp data for player
local function saveWarpData(player, data)
    local filePath = string.format("%s/%s.json", warpPath, player:getName():lower())
    local f = io.open(filePath, "w+")
    if f then
        f:write(cjson.encode(data))
        f:close()
    end
end

commandObj.onTrigger = function(player, arg1, arg2)
    if arg1 == nil or arg1 == "help" then
        player:printToPlayer("Warp Command Help:", xi.msg.channel.SYSTEM_3)
        player:printToPlayer("  !warp set [1-10]    - Save current position to a slot (only if empty)", xi.msg.channel.SYSTEM_3)
        player:printToPlayer("  !warp [1-10]        - Warp to a previously saved slot", xi.msg.channel.SYSTEM_3)
        player:printToPlayer("  !warp delete [1-10] - Delete a saved warp slot", xi.msg.channel.SYSTEM_3)
        player:printToPlayer("  !warp list          - List all saved warp slots", xi.msg.channel.SYSTEM_3)
        player:printToPlayer("  !warp help          - Show this help text", xi.msg.channel.SYSTEM_3)
        return
    end

    local data = loadWarpData(player)

    -- Handle list
    if arg1 == "list" then
        player:printToPlayer("Saved Warp Slots:", xi.msg.channel.SYSTEM_3)
        for i = 1, 10 do
            if data[tostring(i)] then
                local w = data[tostring(i)]
                player:printToPlayer(string.format("  Slot %d: Zone %d (X: %.2f, Y: %.2f, Z: %.2f)", i, w.zone, w.x, w.y, w.z), xi.msg.channel.SYSTEM_3)
            else
                player:printToPlayer(string.format("  Slot %d: [Empty]", i), xi.msg.channel.SYSTEM_3)
            end
        end
        return
    end

    -- Handle delete
    if arg1 == "delete" and arg2 then
        local slot = tonumber(arg2)
        if slot and slot >= 1 and slot <= 10 then
            data[tostring(slot)] = nil
            saveWarpData(player, data)
            player:printToPlayer(string.format("Deleted warp slot %d.", slot), xi.msg.channel.SYSTEM_3)
        else
            player:printToPlayer("Invalid slot number. Use 1-10.", xi.msg.channel.SYSTEM_3)
        end
        return
    end

    -- Handle set
    if arg1 == "set" and arg2 then
        local slot = tonumber(arg2)
        if slot and slot >= 1 and slot <= 10 then
            if data[tostring(slot)] then
                player:printToPlayer(string.format("Slot %d already in use. Use !warp delete %d to clear it first.", slot, slot), xi.msg.channel.SYSTEM_3)
                return
            end
            data[tostring(slot)] = {
                x = player:getXPos(),
                y = player:getYPos(),
                z = player:getZPos(),
                rot = player:getRotPos(),
                zone = player:getZoneID()
            }
            saveWarpData(player, data)
            player:printToPlayer(string.format("Saved warp slot %d.", slot), xi.msg.channel.SYSTEM_3)
        else
            player:printToPlayer("Invalid slot number. Use 1-10.", xi.msg.channel.SYSTEM_3)
        end
        return
    end

    -- Handle warp
    local slot = tonumber(arg1)
    if slot and slot >= 1 and slot <= 10 then
        local wp = data[tostring(slot)]
        if wp then
            player:setPos(wp.x, wp.y, wp.z, wp.rot, wp.zone)
            player:printToPlayer(string.format("Warped to slot %d.", slot), xi.msg.channel.SYSTEM_3)
        else
            player:printToPlayer(string.format("Slot %d is empty. Use !warp set %d to save location.", slot, slot), xi.msg.channel.SYSTEM_3)
        end
        return
    end

    -- Fallback
    player:printToPlayer("Invalid usage. Use !warp help for syntax.", xi.msg.channel.SYSTEM_3)
end

return commandObj
