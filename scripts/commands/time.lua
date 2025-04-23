-----------------------------------
-- func: time
-- desc: Prints time info.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = ''
}

commandObj.onTrigger = function(player)
    local channel = xi.msg.channel.SYSTEM_3
    local elementalDayName =
    {
        "Firesday",
        "Earthsday",
        "Watersday",
        "Windsday",
        "Iceday",
        "Lightningday",
        "Lightsday",
        "Darksday",
    }
    local totdName =
    {
        "Midnight",
        "New Day",
        "Dawn",
        "Daytime",
        "Dusk",
        "Evening",
        "Night",
    }
    local raceName =
    {
        "Hume Male",
        "Hume Female",
        "Elvaan Male",
        "Elvaan Female",
        "Taru Male",
        "Taru Female",
        "Mithra",
        "Galka",
    }
    local rseZoneName =
    {
        "Ordelle's Caves",
        "Gusgen Mines",
        "Maze of Shakhrami",
    }

    -- Time and Date
    local year = VanadielYear() + 886
    local month = VanadielMonth() + 1
    local day = VanadielDayOfTheMonth()
    local dayElement = elementalDayName[VanadielDayOfTheWeek() + 1]
    local hour = VanadielHour()
    local minute = VanadielMinute()
    local totd = totdName[VanadielTOTD()] or "None"
    player:printToPlayer(fmt('It has been {} Vana\'diel days ({} Earth seconds) since the Vana\'diel epoch.', VanadielUniqueDay(), VanadielTime()), channel)
    player:printToPlayer(fmt('Vana\'diel: {}/{}/{}, {}, {:02}:{:02} ({}, {} days into the year)', year, month, day, dayElement, hour, minute, totd, VanadielDayOfTheYear()), channel)

    -- Moon
    local moonDirection = VanadielMoonDirection()
    local moonPhase = VanadielMoonPhase()
    local moonType = IsMoonFull() and "Full Moon" or IsMoonNew() and "New Moon"
    if not moonType then
        if moonDirection == 1 then
            if moonPhase <= 93 and moonPhase >= 62 then
                moonType = "Waning Gibbous"
            elseif moonPhase <= 60 and moonPhase >= 43 then
                moonType = "Last Quarter"
            elseif moonPhase <= 40 and moonPhase >= 12 then
                moonType = "Waning Crescent"
            end
        elseif moonDirection == 2 then
            if moonPhase >= 7 and moonPhase <= 38 then
                moonType = "Waxing Crescent"
            elseif moonPhase >= 40 and moonPhase <= 55 then
                moonType = "First Quarter"
            elseif moonPhase >= 57 and moonPhase <= 88 then
                moonType = "Waxing Gibbous"
            end
        end
    end
    player:printToPlayer(fmt('              {} ({}%)', moonType, moonPhase), channel)

    -- RSE
    local rseRace = raceName[VanadielRSERace()]
    local rseLocation = rseZoneName[VanadielRSELocation() + 1]
    player:printToPlayer(fmt('Current RSE is {} in {}.', rseRace, rseLocation), channel)
end

return commandObj
