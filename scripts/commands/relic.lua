-----------------------------------
-- func: relic
-- desc: Teleports the player to relic shop location.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = ""
}

commandObj.onTrigger = function(player, args)
    local zoneId = 161
    local x = 390.55
    local y = -12.00
    local z = -20.60
    local rot = 138

    player:setPos(x, y, z, rot, zoneId)
    player:printToPlayer("Teleported to Relic Shop location.", xi.msg.channel.SYSTEM_3)
end

return commandObj
