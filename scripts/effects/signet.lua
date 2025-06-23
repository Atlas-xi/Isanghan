-----------------------------------
-- xi.effect.SIGNET
--   Signet is a beneficial Status Effect that allows the acquisition of Conquest Points and Crystals
--   from defeated enemies that grant Experience Points.
--
--   Additional Custom Behavior:
--     - Applies simulated Regen and Refresh each tick
--     - Bonus DEF and EVA vs auto-attack targets
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.DEF, 15)
    target:addLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.EVA, 15)
end

effectObject.onEffectTick = function(target, effect)
    -- Custom Regen and Refresh behavior
    local hpRegen = 1    -- HP restored per tick
    local mpRegen = 1    -- MP restored per tick

    if target:getHP() > 0 then
        target:addHP(hpRegen)
        target:addMP(mpRegen)
    end
end

effectObject.onEffectLose = function(target, effect)
    target:delLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.DEF, 15)
    target:delLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.EVA, 15)
end

return effectObject
