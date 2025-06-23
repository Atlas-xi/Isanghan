-----------------------------------
-- func: merit
-- desc: Teleports the player to a preset merit camp location (bats or worms).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

commandObj.onTrigger = function(player, arg)
    if arg == nil then
        player:printToPlayer("Usage: !merit <bats|worms>", xi.msg.channel.SYSTEM_3)
        return
    end

    local destination = string.lower(arg)

    if destination == "bats" then
        player:setPos(220.15, -24.00, 80.37, 107, 204) -- Bats: X, Y, Z, Rot, Zone
    elseif destination == "worms" then
        player:setPos(-20.49, -10.52, 143.07, 0, 212) -- Worms: X, Y, Z, Rot, Zone
    else
        player:printToPlayer("Invalid merit camp. Usage: !merit <bats|worms>", xi.msg.channel.SYSTEM_3)
    end
end

return commandObj
