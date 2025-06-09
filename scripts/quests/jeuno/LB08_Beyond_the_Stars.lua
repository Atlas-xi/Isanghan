-----------------------------------
-- Beyond the Stars
-----------------------------------
-- Log ID: 3, Quest ID: 135
-- Nomad Moogle : !pos 10.012 1.453 121.883 243
-----------------------------------
local ruludeID = zones[xi.zone.RULUDE_GARDENS]
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.BEYOND_THE_STARS)

-- TODO: Properly code the rock, paper, scissors minigame. Awaiting for a capture.
-- Probably a matter of chaining onEventUpdates and tracking Maat's and Degengard's HP. Maybe not.
-- It seems that the event tracks HP on it's own.
-- Degengard's moves are selected at random.

quest.reward =
{
    fame = 50,
    fameArea = xi.fameArea.JEUNO,
}

quest.sections =
{
    -- Section: Quest available.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getLevelCap() == 85 and
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Nomad_Moogle'] =
            {
                onTrigger = function(player, npc)
                    local playerLevel     = player:getMainLvl()
                    local limitBreaker    = player:hasKeyItem(xi.ki.LIMIT_BREAKER) and 1 or 2
                    local lastQuestNumber = 0
                    local lastQuestStage  = 0
                    if
                        xi.settings.main.MAX_LEVEL > 85 and
                        limitBreaker == 1
                    then
                        if playerLevel > 80 then
                            lastQuestNumber = 3
                        elseif playerLevel == 80 then
                            lastQuestNumber = 2
                            lastQuestStage  = 2
                        end
                    end

                    return quest:progressEvent(10045, playerLevel, limitBreaker, lastQuestNumber, lastQuestStage)
                end,
            },

            onEventFinish =
            {
                [10045] = function(player, csid, option, npc)
                    if option == 9 then -- Accept quest option.
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: Quest accepted.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Nomad_Moogle'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        npcUtil.tradeHasExactly(trade, { { xi.item.KINDREDS_CREST, 10 } }) and
                        player:getMeritCount() > 4
                    then
                        return quest:progressEvent(10137)
                    end
                end,

                onTrigger = function(player, npc)
                    -- Rock, Paper, Scissor Minigame.
                    if quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(10161)

                    -- Reminder
                    else
                        local playerLevel     = player:getMainLvl()
                        local limitBreaker    = player:hasKeyItem(xi.ki.LIMIT_BREAKER) and 1 or 2
                        local lastQuestNumber = 3
                        local lastQuestStage  = 1

                        return quest:event(10045, playerLevel, limitBreaker, lastQuestNumber, lastQuestStage)
                    end
                end,
            },

            -- onEventUpdate =
            -- {
                -- [10161] = function(player, csid, option, npc)
                -- end,
            -- },

            onEventFinish =
            {
                [10137] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:setMerits(player:getMeritCount() - 5)
                    quest:setVar(player, 'Prog', 1)
                end,

                [10161] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setLevelCap(90)
                        player:messageSpecial(ruludeID.text.YOUR_LEVEL_LIMIT_IS_NOW_90)
                    end
                end,
            },
        },
    },
}

return quest
