local Config = require 'configs.gv'
local Vars = require 'helpers.vars'

if not Config or not Config.Enabled then return end

local allowedItems = {}
for i = 1, #(Config.Items or {}) do
    allowedItems[Config.Items[i]] = true
end

local function isAllowed(xPlayer)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AllowedGroups and Config.AllowedGroups[group] == true
end

local function notify(src, message, msgType)
    TriggerClientEvent('esx:Notify', src, Config.NotifyTitle or 'GIVE ITEM', message, msgType or 'info', 7000)
end

local function formatLog(xPlayer, payload, reason)
    local parts = {
        'GV GIVE ITEM',
        ('Staff: %s [%s]'):format(xPlayer.name, xPlayer.source),
        ('Group: %s'):format(xPlayer.getGroup and xPlayer.getGroup() or '?'),
        ('Item: %s'):format(payload and payload.item or '?'),
        ('Amount: %s'):format(payload and payload.amount or '?'),
        ('TargetType: %s'):format(payload and payload.targetType or '?'),
        ('TargetId: %s'):format(payload and payload.targetId or '-'),
        ('Reason: %s'):format(reason or 'ok'),
    }
    return table.concat(parts, ' | ')
end

lib.callback.register('cfx-keydi-utils:gv:canUse', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return isAllowed(xPlayer)
end)

RegisterNetEvent('cfx-keydi-utils:gv:give', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not isAllowed(xPlayer) then
        lib.logger(src, 'cfx-keydi-sentry', formatLog(xPlayer, data, 'UNAUTHORIZED'), 'ERROR')
        notify(src, 'You do not have permission.', 'error')
        return
    end

    if type(data) ~= 'table' then
        notify(src, 'Invalid request.', 'error')
        return
    end

    local item = data.item
    local targetType = data.targetType
    local targetId = tonumber(data.targetId)
    local amount = math.floor(tonumber(data.amount) or 0)
    local maxAmount = Config.MaxAmount or 50

    if type(item) ~= 'string' or not allowedItems[item] then
        lib.logger(src, 'cfx-keydi-sentry', formatLog(xPlayer, data, 'BLOCKED_ITEM'), 'ERROR')
        notify(src, 'That item is not allowed.', 'error')
        return
    end

    local itemDef = Vars.ox:Items(item)
    if not itemDef then
        notify(src, ('Item definition missing: %s'):format(item), 'error')
        return
    end

    if amount < 1 or amount > maxAmount then
        notify(src, ('Amount must be between 1 and %s.'):format(maxAmount), 'error')
        return
    end

    if targetType ~= 'id' and targetType ~= 'all' then
        notify(src, 'Invalid target type.', 'error')
        return
    end

    local label = itemDef.label or item
    local given = 0
    local failed = 0

    if targetType == 'id' then
        if not targetId or targetId < 1 then
            notify(src, 'Enter a valid Player ID.', 'error')
            return
        end

        local xTarget = ESX.GetPlayerFromId(targetId)
        if not xTarget then
            notify(src, ('Player ID %s is not online.'):format(targetId), 'error')
            return
        end

        local ok = Vars.ox:AddItem(targetId, item, amount)
        if ok then
            given = 1
            notify(targetId, ('You received %sx %s.'):format(amount, label), 'success')
            notify(src, ('Gave %sx %s to ID %s (%s).'):format(amount, label, targetId, xTarget.getName and xTarget.getName() or xTarget.name), 'success')
        else
            failed = 1
            notify(src, ('Failed to give %s to ID %s (inventory full?).'):format(label, targetId), 'error')
        end
    else
        local players = ESX.GetExtendedPlayers and ESX.GetExtendedPlayers() or nil
        if players then
            for i = 1, #players do
                local xTarget = players[i]
                local tid = xTarget.source
                local ok = Vars.ox:AddItem(tid, item, amount)
                if ok then
                    given += 1
                    notify(tid, ('You received %sx %s.'):format(amount, label), 'success')
                else
                    failed += 1
                end
            end
        else
            local ids = GetPlayers()
            for i = 1, #ids do
                local tid = tonumber(ids[i])
                if tid then
                    local ok = Vars.ox:AddItem(tid, item, amount)
                    if ok then
                        given += 1
                        notify(tid, ('You received %sx %s.'):format(amount, label), 'success')
                    else
                        failed += 1
                    end
                end
            end
        end

        notify(src, ('Gave %sx %s to %s player(s)%s.'):format(
            amount,
            label,
            given,
            failed > 0 and (' (%s failed)'):format(failed) or ''
        ), given > 0 and 'success' or 'error')
    end

    lib.logger(src, 'cfx-keydi-gv', formatLog(xPlayer, {
        item = item,
        amount = amount,
        targetType = targetType,
        targetId = targetId,
    }, ('given=%s failed=%s'):format(given, failed)), 'INFO')
end)
