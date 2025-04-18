-----------------------------------
-- Absorb Spell Utilities
--
-- Absorb-STAT, Absorb-TP, Absorb-Attri
-----------------------------------
require('scripts/globals/utils')
-----------------------------------
xi = xi or {}
xi.spells = xi.spells or {}
xi.spells.absorb = xi.spells.absorb or {}
-----------------------------------

local absorbStatData =
{
    [xi.magic.spell.ABSORB_STR] = { boostEffect = xi.effect.STR_BOOST,      downEffect = xi.effect.STR_DOWN,      msg = xi.msg.basic.MAGIC_ABSORB_STR },
    [xi.magic.spell.ABSORB_DEX] = { boostEffect = xi.effect.DEX_BOOST,      downEffect = xi.effect.DEX_DOWN,      msg = xi.msg.basic.MAGIC_ABSORB_DEX },
    [xi.magic.spell.ABSORB_VIT] = { boostEffect = xi.effect.VIT_BOOST,      downEffect = xi.effect.VIT_DOWN,      msg = xi.msg.basic.MAGIC_ABSORB_VIT },
    [xi.magic.spell.ABSORB_AGI] = { boostEffect = xi.effect.AGI_BOOST,      downEffect = xi.effect.AGI_DOWN,      msg = xi.msg.basic.MAGIC_ABSORB_AGI },
    [xi.magic.spell.ABSORB_INT] = { boostEffect = xi.effect.INT_BOOST,      downEffect = xi.effect.INT_DOWN,      msg = xi.msg.basic.MAGIC_ABSORB_INT },
    [xi.magic.spell.ABSORB_MND] = { boostEffect = xi.effect.MND_BOOST,      downEffect = xi.effect.MND_DOWN,      msg = xi.msg.basic.MAGIC_ABSORB_MND },
    [xi.magic.spell.ABSORB_CHR] = { boostEffect = xi.effect.CHR_BOOST,      downEffect = xi.effect.CHR_DOWN,      msg = xi.msg.basic.MAGIC_ABSORB_CHR },
    [xi.magic.spell.ABSORB_ACC] = { boostEffect = xi.effect.ACCURACY_BOOST, downEffect = xi.effect.ACCURACY_DOWN, msg = xi.msg.basic.MAGIC_ABSORB_ACC },
}

-- https://www.bg-wiki.com/ffxi/Category:Absorb_Spell
xi.spells.absorb.doAbsorbStatSpell = function(caster, target, spell)
    local spellId          = spell:getID()
    local enhancingEffect  = absorbStatData[spellId].boostEffect
    local enfeeblingEffect = absorbStatData[spellId].downEffect

    -- Calculate resistance (2 state effects: Either No resist, half resist or full resist)
    local resist = xi.combat.magicHitRate.calculateResistRate(caster, target, xi.magic.spellGroup.BLACK, xi.skill.DARK_MAGIC, 0, xi.element.DARK, xi.mod.INT, enfeeblingEffect, 0)
    if resist < 0.5 then
        spell:setMsg(xi.msg.basic.MAGIC_RESIST)
        return 0
    end

    -- Calculate potency.
    local basePotency          = 3 + math.floor(caster:getMainLvl() / 5)
    local gearMultiplier       = 1 + caster:getMod(xi.mod.AUGMENTS_ABSORB) / 100
    local liberatorMultiplier  = 1 + caster:getMod(xi.mod.AUGMENTS_ABSORB_LIBERATOR) / 100
    local netherVoidMultiplier = 1
    if
        spellId ~= xi.magic.spell.ABSORB_TP and
        caster:hasStatusEffect(xi.effect.NETHER_VOID)
    then
        netherVoidMultiplier = 1 + caster:getStatusEffect(xi.effect.NETHER_VOID):getPower() / 100
    end

    local finalPotency = math.floor(basePotency * gearMultiplier * liberatorMultiplier)
    finalPotency       = math.floor(finalPotency * netherVoidMultiplier)

    -- Calculate duration.
    -- NOTE: Wiki information is contradicting.
    -- It states duration from gear (Absorb effect duration) is additive in gear pages and in table, but multiplicative in the equation.
    local baseDuration           = utils.clamp(180 + math.floor((caster:getSkillLevel(xi.skill.DARK_MAGIC) - 490.5) / 5), 0, 10000)
    local darkDurationMultiplier = 1 + caster:getMod(xi.mod.DARK_MAGIC_DURATION) / 100
    local durationGearMultiplier = 1 + caster:getMod(xi.mod.ABSORB_EFFECT_DURATION) / 100

    local finalDuration = math.floor(baseDuration * darkDurationMultiplier * durationGearMultiplier) + caster:getMod(xi.mod.ENHANCES_ABSORB_EFFECTS) -- Assume additive. TODO: Testing needed.

    -- Apply debuff and buff if needed. Absorb effects can be overwriten via higher potency.
    if target:addStatusEffect(enfeeblingEffect, finalPotency, 0, finalDuration) then
        -- Set associated message.
        spell:setMsg(absorbStatData[spellId].msg)

        -- Force-overwrite associated buff.
        caster:delStatusEffect(enhancingEffect)
        caster:addStatusEffect(enhancingEffect, finalPotency, 0, finalDuration)
    else
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return enfeeblingEffect
end

xi.spells.absorb.doAbsorbTPSpell = function(caster, target, spell)
    local finalDamage = 0

    -- Early return: Target absorbs or nullifies dark.
    if xi.spells.damage.calculateNukeAbsorbOrNullify(target, xi.element.DARK) then
        spell:setMsg(xi.msg.basic.MAGIC_RESIST)
        return finalDamage
    end

    -- Early return: Target doesn't have TP to absorb.
    local targetTP = target:getTP()
    if targetTP == 0 then
        spell:setMsg(xi.msg.basic.NO_EFFECT)
        return finalDamage
    end

    -- Base damage.
    local baseDamage = targetTP * 30 / 100

    -- Multipliers.
    local resistTier           = xi.combat.magicHitRate.calculateResistRate(caster, target, xi.magic.spellGroup.BLACK, xi.skill.DARK_MAGIC, 0, xi.element.DARK, xi.mod.INT, 0, 0)
    local additionalResistTier = xi.spells.damage.calculateAdditionalResistTier(caster, target, xi.element.DARK)
    local sdt                  = xi.spells.damage.calculateSDT(target, xi.element.DARK)
    local elementalStaffBonus  = xi.spells.damage.calculateElementalStaffBonus(caster, xi.element.DARK)
    local dayAndWeather        = xi.spells.damage.calculateDayAndWeather(caster, xi.element.DARK, false)
    local absorbMultiplier     = 1 + caster:getMod(xi.mod.AUGMENTS_ABSORB) / 100
    local liberatorMultiplier  = 1 + caster:getMod(xi.mod.AUGMENTS_ABSORB_LIBERATOR) / 100

    -- Operations.
    finalDamage = math.floor(baseDamage * resistTier)
    finalDamage = math.floor(finalDamage * additionalResistTier)
    finalDamage = math.floor(finalDamage * sdt)
    finalDamage = math.floor(finalDamage * elementalStaffBonus)
    finalDamage = math.floor(finalDamage * dayAndWeather)
    finalDamage = math.floor(finalDamage * absorbMultiplier)
    finalDamage = math.floor(finalDamage * liberatorMultiplier)

    -- Clamp
    finalDamage = utils.clamp(finalDamage, 0, 3000)

    -- Set proper message.
    spell:setMsg(xi.msg.basic.MAGIC_ABSORB_TP)

    -- Perform drain.
    caster:addTP(finalDamage)
    target:addTP(-finalDamage)

    return finalDamage
end

xi.spells.absorb.doAbsorbAttriSpell = function(caster, target, spell)
    local count       = 0
    local effectFirst = caster:stealStatusEffect(target, xi.effectFlag.DISPELABLE)

    if effectFirst ~= 0 then
        count = 1

        if caster:hasStatusEffect(xi.effect.NETHER_VOID) then
            local effectSecond = caster:stealStatusEffect(target, xi.effectFlag.DISPELABLE)
            if effectSecond ~= 0 then
                count = count + 1
            end
        end

        spell:setMsg(xi.msg.basic.MAGIC_STEAL)

        return count
    else
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT) -- No effect
    end

    return count
end
