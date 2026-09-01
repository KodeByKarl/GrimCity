ESX = exports["es_extended"]:getSharedObject()
local playerIdentity = {}
local alreadyRegistered = {}

-- Utility functions for formatting
local function formatDate(timestamp)
    local dateTable = os.date("*t", timestamp / 1000)
    return string.format("%02d/%02d/%04d", dateTable.day, dateTable.month, dateTable.year)
end

local function formatName(str)
    if not str then return "" end
    local lowered = string.lower(str)
    return lowered:gsub("^%l", string.upper)
end

-- Export functions for other scripts if needed
exports('FormatName', formatName)
exports('FormatDate', formatDate)

-- Check character identity when player loads
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.identifier

    Database.GetIdentity(identifier, function(identity)
        if not identity or not identity.firstName or identity.firstName == "" then
            playerIdentity[identifier] = nil
            alreadyRegistered[identifier] = false
            IdentityUtils.Debug("Player %s does not have an identity. Prompting registration.", playerId)
            TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
        else
            playerIdentity[identifier] = identity
            alreadyRegistered[identifier] = true

            xPlayer.setName(('%s %s'):format(identity.firstName, identity.lastName))
            xPlayer.set('firstName', identity.firstName)
            xPlayer.set('lastName', identity.lastName)
            xPlayer.set('dateofbirth', identity.dateOfBirth)
            xPlayer.set('sex', identity.sex)
            xPlayer.set('height', identity.height)

            TriggerClientEvent('esx_identity:setPlayerData', xPlayer.source, identity)
            TriggerClientEvent('esx_identity:alreadyRegistered', xPlayer.source)
            IdentityUtils.Debug("Loaded identity for player %s (%s %s)", playerId, identity.firstName, identity.lastName)
        end
    end)
end)

-- Handle player disconnect
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        playerIdentity[xPlayer.identifier] = nil
        alreadyRegistered[xPlayer.identifier] = nil
    end
end)
