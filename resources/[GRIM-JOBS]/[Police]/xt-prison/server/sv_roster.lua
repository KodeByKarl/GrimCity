local utils = require 'modules.server.utils'
local prisonJob = require 'configs.prisonjob'

-- View Jail Roster --
lib.callback.register('xt-prison:server:getJailRoster', function(source)
    return utils.generateJailRoster()
end)

-- Unjails Player via Roster --
lib.callback.register('xt-prison:server:unjailPlayerByRoster', function(source, targetSource)
    local isCop = utils.isCop(source)
    if not isCop then return false end

    local state = Player(targetSource).state
    if state and state.jailTime > 0 then
        setJailTime(targetSource, 0)

        lib.notify(targetSource, {
            title = locale('notify.freedom'),
            description = locale('notify.unjailed_by_roster')
        })
        Wait(3000)
        local released = lib.callback.await('xt-prison:client:exitJail', targetSource, true)
        if released and PrisonLogs and PrisonLogs.Release then
            PrisonLogs.Release({
                src = source,
                name = getCharName(source),
                identifier = getCharID(source),
                targetSrc = targetSource,
                targetName = getCharName(targetSource),
                targetIdentifier = getCharID(targetSource),
                method = 'roster unjail',
            })
        end
        return released
    end

    return state and (state.jailTime <= 0) or false
end)

RegisterNetEvent('xt-prison:server:update', function(time, id)
    local src = source
    local xPlayer  = getPlayer(src)
    local targetCoords = prisonJob.Welding.locations[id].coords.xyz
    local state = Player(xPlayer.source).state
    if prisonJob.Welding.reduceTime ~= time then return end
    if #(xPlayer.getCoords(true) - targetCoords) > 8.0 then
        return lib.notify(src, {
            title = 'ROSTER',
            description = 'OUT OF RANGE'
        })
    end
    if state and state.jailTime > 0 then
        state.jailTime = state.jailTime - time
        setJailTime(src, state.jailTime)
    end
end)


-- Set Player Jail Time via Roster --
lib.callback.register('xt-prison:server:changePlayerJailTimeByRoster', function(source, targetSource, newTime)
    local isCop = utils.isCop(source)
    if not isCop then return false end

    local state = Player(targetSource).state
    if state and state.jailTime > 0 then
        setJailTime(targetSource, newTime)

        lib.notify(targetSource, {
            title = locale('notify.new_time_by_roster'),
            description = (locale('notify.new_time_by_roster_description')):format(newTime)
        })

        if PrisonLogs and PrisonLogs.Jail then
            PrisonLogs.Jail({
                updated = true,
                src = source,
                name = getCharName(source),
                identifier = getCharID(source),
                targetSrc = targetSource,
                targetName = getCharName(targetSource),
                targetIdentifier = getCharID(targetSource),
                time = newTime,
                method = 'roster time change',
            })
        end
    end

    return state and (state.jailTime == newTime) or false
end)