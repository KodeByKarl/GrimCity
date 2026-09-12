ESX = ESX or exports["es_extended"]:getSharedObject()

-- Live player counts + per-player current location (Server Locations module)
ESX.RegisterServerCallback('cfx-keydi-modules:server:getServersData', function(source, cb)
    if ServerLocations and ServerLocations.GetServersData then
        cb(ServerLocations.GetServersData(source))
        return
    end
    cb({})
end)

local function dojCfg()
    return (ConfigModules and ConfigModules.DOJ) or {}
end

local function notify(src, title, description, nType)
    TriggerClientEvent('ox_lib:notify', src, {
        title = title or 'DOJ',
        description = description,
        type = nType or 'inform',
    })
end

local function isOnDutyDoj(xPlayer)
    return xPlayer and xPlayer.job and xPlayer.job.name == 'doj'
end

local function playersNear(srcA, srcB, maxDist)
    local pedA = GetPlayerPed(srcA)
    local pedB = GetPlayerPed(srcB)
    if not pedA or pedA == 0 or not pedB or pedB == 0 then return false end
    local a = GetEntityCoords(pedA)
    local b = GetEntityCoords(pedB)
    return #(a - b) <= (maxDist or 3.0)
end

local function formatMoney(n)
    n = math.floor(tonumber(n) or 0)
    if ESX and ESX.Math and ESX.Math.GroupDigits then
        return ESX.Math.GroupDigits(n)
    end
    local s = tostring(n)
    local k
    while true do
        s, k = s:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
        if k == 0 then break end
    end
    return s
end

local function chargePlayer(xTarget, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return true end

    local bank = 0
    local cash = 0
    if xTarget.getAccount then
        local bankAcc = xTarget.getAccount('bank')
        bank = bankAcc and tonumber(bankAcc.money) or 0
        local moneyAcc = xTarget.getAccount('money')
        cash = moneyAcc and tonumber(moneyAcc.money) or 0
    end
    if cash <= 0 and xTarget.getMoney then
        cash = tonumber(xTarget.getMoney()) or 0
    end

    if bank >= amount then
        xTarget.removeAccountMoney('bank', amount, 'DOJ service fee')
        return true
    end
    if cash >= amount then
        if xTarget.removeAccountMoney then
            xTarget.removeAccountMoney('money', amount, 'DOJ service fee')
        elseif xTarget.removeMoney then
            xTarget.removeMoney(amount, 'DOJ service fee')
        else
            return false
        end
        return true
    end
    return false
end

local function depositSociety(amount, identifier, note)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return true end
    local account = dojCfg().SocietyAccount or 'society_doj'
    if GetResourceState('cfx-keydi-society') ~= 'started' then
        return false
    end
    local ok = pcall(function()
        exports['cfx-keydi-society']:AddMoney(account, amount, identifier, note)
    end)
    return ok
end

local function applyNameChange(xTarget, firstName, lastName)
    firstName = tostring(firstName or ''):gsub('^%s*(.-)%s*$', '%1')
    lastName = tostring(lastName or ''):gsub('^%s*(.-)%s*$', '%1')
    if firstName == '' or lastName == '' then
        return false
    end
    if #firstName > 50 or #lastName > 50 then
        return false
    end

    if xTarget.setName then
        xTarget.setName(('%s %s'):format(firstName, lastName))
    end
    xTarget.set('firstName', firstName)
    xTarget.set('lastName', lastName)

    if MySQL then
        pcall(function()
            MySQL.update(
                'UPDATE users SET firstname = ?, lastname = ? WHERE identifier = ?',
                { firstName, lastName, xTarget.identifier }
            )
        end)
    end
    return true, firstName, lastName
end

-- Free City Hall self-serve disabled — DOJ handles issuance.
RegisterNetEvent('cfx-keydi-identification:server:giveIdItem', function()
    local src = source
    notify(src, 'DOJ', 'Citizen IDs are issued by the Department of Justice ($250,000).', 'error')
end)

RegisterNetEvent('cfx-keydi-identification:server:changeName', function()
    local src = source
    notify(src, 'DOJ', 'Legal name changes are processed by the Department of Justice ($500,000).', 'error')
end)

lib.callback.register('cfx-keydi-doj:issueCitizenId', function(source, targetId)
    local cfg = dojCfg()
    local price = tonumber(cfg.CitizenIdPrice) or 250000
    local maxDist = tonumber(cfg.MaxDistance) or 3.0

    local xStaff = ESX.GetPlayerFromId(source)
    if not isOnDutyDoj(xStaff) then
        return { ok = false, error = 'not_doj' }
    end

    targetId = tonumber(targetId)
    if not targetId or targetId == source then
        return { ok = false, error = 'invalid_target' }
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        return { ok = false, error = 'offline' }
    end

    if not playersNear(source, targetId, maxDist) then
        return { ok = false, error = 'far' }
    end

    local count = exports.ox_inventory:Search(targetId, 'count', 'identification') or 0
    if count > 0 then
        return { ok = false, error = 'has_id' }
    end

    if not chargePlayer(xTarget, price) then
        return { ok = false, error = 'no_money', price = price }
    end

    local success = exports.ox_inventory:AddItem(targetId, 'identification', 1)
    if not success then
        xTarget.addAccountMoney('bank', price, 'DOJ ID refund')
        return { ok = false, error = 'inventory_full' }
    end

    depositSociety(price, xStaff.identifier, ('Citizen ID — %s'):format(xTarget.identifier))

    notify(targetId, 'DOJ', ('You received your Citizen ID. Fee: $%s.'):format(formatMoney(price)), 'success')
    notify(source, 'DOJ', ('Issued Citizen ID. $%s deposited to DOJ funds.'):format(formatMoney(price)), 'success')
    return { ok = true, price = price }
end)

lib.callback.register('cfx-keydi-doj:changeName', function(source, data)
    local cfg = dojCfg()
    local price = tonumber(cfg.ChangeNamePrice) or 500000
    local maxDist = tonumber(cfg.MaxDistance) or 3.0

    local xStaff = ESX.GetPlayerFromId(source)
    if not isOnDutyDoj(xStaff) then
        return { ok = false, error = 'not_doj' }
    end

    data = type(data) == 'table' and data or {}
    local targetId = tonumber(data.targetId)
    if not targetId or targetId == source then
        return { ok = false, error = 'invalid_target' }
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        return { ok = false, error = 'offline' }
    end

    if not playersNear(source, targetId, maxDist) then
        return { ok = false, error = 'far' }
    end

    if not chargePlayer(xTarget, price) then
        return { ok = false, error = 'no_money', price = price }
    end

    local ok, firstName, lastName = applyNameChange(xTarget, data.firstName, data.lastName)
    if not ok then
        xTarget.addAccountMoney('bank', price, 'DOJ name-change refund')
        return { ok = false, error = 'invalid' }
    end

    depositSociety(price, xStaff.identifier, ('Name change — %s → %s %s'):format(xTarget.identifier, firstName, lastName))

    notify(targetId, 'DOJ', ('Legal name updated to %s %s. Fee: $%s.'):format(firstName, lastName, formatMoney(price)), 'success')
    notify(source, 'DOJ', ('Processed name change. $%s deposited to DOJ funds.'):format(formatMoney(price)), 'success')
    return { ok = true, price = price, name = ('%s %s'):format(firstName, lastName) }
end)
