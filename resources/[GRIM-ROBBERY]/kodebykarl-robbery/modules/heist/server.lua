local BigHeist = {
    lastRobbed = {},
    onGoing = {},
    Player = {},
}

CreateThread(function ()
    for heist, value in pairs(Config.Heist) do
        if value.marker then
            GlobalState[heist] = false
        end
    end
end)

RegisterNetEvent('cfx-cs-robbery:StartTimer', function(key)
    local src = source
    local config = Config.Heist[key]
    local xPlayer = ESX.GetPlayerFromId(src)
    if (config.ped and #(xPlayer.getCoords(true) - config.ped.coords.xyz) <= 5) or (config.marker and #(xPlayer.getCoords(true) - config.marker.coords) <= 5) then
        if BigHeist.onGoing[key] then return end
        if config.requireItem and next(config.requireItem) then
            for k,v in pairs(config.requireItem) do
                ox_inventory:RemoveItem(xPlayer.source, k, v)
            end
        end

        BigHeist.onGoing[key] = true

        if config.settings.autoPriority then
            GlobalState.PriorityPolice = {
                canRob = false,
                status = 'inprogress',
                status_label = '🔴In progress',
                name = config.label
            }
        end

        if config.settings.autoTemplate then
            exports['cfx-cs-chat']:JobTemplateWithoutID('police', 'A priority call is in progress. Please do not interfere, otherwise you will be kicked. All calls are on hold until this one concludes.')
        end

        if config.marker then
            GlobalState:set(key, true, true)
        end

        if config.settings.autoBlip then
            GlobalState:set(key..'_blip', true, true)
        end

        if config.settings.autoAnnounce then
            GlobalState:set(key..'_notify', true, true)
        end

        if config.debug and config.debug.enable then
            GlobalState:set(key..'_debug', true, true)
        end

        if config.dispatch and config.dispatch.enable then
            ESX.SendDispatch(config.dispatch.jobs, 'On going robbery at '..config.label, 10000)
        end

        BigHeist.lastRobbed[key] = os.time()

        lib.logger(src, 'robbery_'..key, xPlayer.name..' started '..config.label)

        TriggerClientEvent('esx:Notify', xPlayer.source, 'ROBBERY - '..config.label, 'You started '..config.label, 'warning', 10000)

        TriggerClientEvent('cfx-cs-robbery:SyncTimer', xPlayer.source, key)

        BigHeist.Player[xPlayer.source] = ESX.SetTimeout(config.timer * 1000, function()
            BigHeist.Player[src] = nil
            BigHeist.onGoing[key] = false
            if config.marker then
                GlobalState:set(key, false, true)
            end
            if config.settings.autoBlip then
                GlobalState:set(key..'_blip', false, true)
            end
            if config.settings.autoAnnounce then
                GlobalState:set(key..'_notify', false, true)
            end
            if config.debug and config.debug.enable then
                GlobalState:set(key..'_debug', false, true)
            end
            if xPlayer then
                TriggerClientEvent('cfx-cs-robbery:DestroyClient', xPlayer.source, key)
                if next(config.rewards) then
                    local receivedItem = {}
                    for i = 1, #config.rewards do
                        local itemData = config.rewards[i]
                        local amount = math.random(itemData.min, itemData.max)
                        if ox_inventory:CanCarryItem(xPlayer.source, itemData.item, amount) then
                            ox_inventory:AddItem(xPlayer.source, itemData.item, amount)
                            table.insert(receivedItem, ESX.Math.GroupDigits(amount)..'x '..ox_items[itemData.item].label)
                        end
                    end
                    lib.logger(xPlayer.source, 'robbery_'..key, xPlayer.name..' ['..xPlayer.source..'] received '..table.concat(receivedItem, ', ')..' in '..config.label)
                end
            end
        end)
    end
end)

RegisterNetEvent('cfx-cs-robbery:DestroyServer', function(key)
    local src = source
    local config = Config.Heist[key]
    if BigHeist.Player[src] and BigHeist.onGoing[key] then
        ESX.ClearTimeout(BigHeist.Player[src])
        BigHeist.Player[src] = nil
        BigHeist.onGoing[key] = false
        TriggerClientEvent('cfx-cs-robbery:DestroyClient', src, key)
        TriggerClientEvent('esx:Notify', src, 'ROBBERY - '..config.label, config.label..' has been cancelled.', 'warning', 10000)
        if config.marker then
            GlobalState:set(key, false, true)
        end
        if config.settings.autoBlip then
            GlobalState:set(key..'_blip', false, true)
        end
        if config.settings.autoAnnounce then
            GlobalState:set(key..'_notify', false, true)
        end
        if config.debug and config.debug.enable then
            GlobalState:set(key..'_debug', false, true)
        end
    end
end)


lib.callback.register('cfx-cs-robbery:check', function(source, key)
    local src = source
    local returnValue = true
    local config = Config.Heist[key]
    if BigHeist.onGoing[key] then
        TriggerClientEvent('esx:Notify', src, 'ROBBERY - '..config.label, config.label..' is currently being robbed.', 'error', 5000)
        return false
    end
    if BigHeist.lastRobbed[key] ~= nil and (os.time() - config.reset) < BigHeist.lastRobbed[key] then
        TriggerClientEvent('esx:Notify', src, 'ROBBERY - '..config.label, ('%s was recently been robbed. Please wait %s seconds until you can rob again.'):format(config.label, (config.reset - (os.time() - BigHeist.lastRobbed[key]))), 'error', 5000)
        returnValue = false
    end
    return returnValue
end)