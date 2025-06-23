-----------------------------------
-- func: home
-- desc: Teleports the player to a preset home location.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = ""
}

commandObj.onTrigger = function(player, args)
    local zoneId = 256
    local x = 20.20
    local y = 0.00
    local z = 12.68
    local rot = 64

    player:setPos(x, y, z, rot, zoneId)
    player:printToPlayer("Teleported to home location.", xi.msg.channel.SYSTEM_3)
end

return commandObj
