ESX = ESX or exports["es_extended"]:getSharedObject()

-- Live player counts + per-player current location (Server Locations module)
ESX.RegisterServerCallback('cfx-keydi-modules:server:getServersData', function(source, cb)
    if ServerLocations and ServerLocations.GetServersData then
        cb(ServerLocations.GetServersData(source))
        return
    end
    cb({})
end)

-- Identification Item Claim Handler
RegisterNetEvent('cfx-keydi-identification:server:giveIdItem', function()
    local src = source
    local count = exports.ox_inventory:Search(src, 'count', 'identification') or 0
    if count > 0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'IDENTIFICATION', description = 'You already have your ID card.', type = 'inform' })
        return
    end
    local success = exports.ox_inventory:AddItem(src, 'identification', 1)
    if success then
        TriggerClientEvent('ox_lib:notify', src, { title = 'IDENTIFICATION', description = 'You received your official identification card.', type = 'success' })
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'IDENTIFICATION', description = 'Inventory full. Could not receive ID card.', type = 'error' })
    end
end)

-- Character Name Change Handler
RegisterNetEvent('cfx-keydi-identification:server:changeName', function(firstName, lastName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    firstName = tostring(firstName or ''):gsub('^%s*(.-)%s*$', '%1')
    lastName = tostring(lastName or ''):gsub('^%s*(.-)%s*$', '%1')
    if firstName == '' or lastName == '' then
        TriggerClientEvent('ox_lib:notify', src, { title = 'CITY HALL', description = 'Invalid name provided.', type = 'error' })
        return
    end

    if xPlayer.setName then
        xPlayer.setName(('%s %s'):format(firstName, lastName))
    end
    xPlayer.set('firstName', firstName)
    xPlayer.set('lastName', lastName)

    if MySQL then
        pcall(function()
            MySQL.update('UPDATE users SET firstname = ?, lastname = ? WHERE identifier = ?', { firstName, lastName, xPlayer.identifier })
        end)
    end

    TriggerClientEvent('ox_lib:notify', src, { title = 'CITY HALL', description = ('Your name has been updated to %s %s.'):format(firstName, lastName), type = 'success' })
end)
