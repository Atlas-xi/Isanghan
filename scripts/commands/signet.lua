-----------------------------------
-- func: signet
-- desc: Applies the Signet effect to the player (or specified target).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

commandObj.onTrigger = function(player, targetName)
    local targ = player

    if targetName ~= nil then
        local possibleTarget = GetPlayerByName(targetName)
        if possibleTarget ~= nil then
            targ = possibleTarget
        else
            player:printToPlayer(string.format('Player named "%s" not found.', targetName), xi.msg.channel.SYSTEM_3)
            return
        end
    end

    local effectId = xi.effect.SIGNET
    local power = 0
    local tick = 3
    local duration = 90000 -- 25 hours

    if targ:addStatusEffect(effectId, power, tick, duration) then
        targ:messagePublic(280, targ, effectId, effectId) -- "Player gains the effect of Signet"
    else
        targ:messagePublic(283, targ, effectId) -- "Unable to apply effect"
    end
end

return commandObj
