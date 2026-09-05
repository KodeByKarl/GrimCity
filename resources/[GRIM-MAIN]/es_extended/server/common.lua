ESX.Players = {}
ESX.Jobs = {}
ESX.Gangs = {}
ESX.Items = {}

RegisterNetEvent("esx:onPlayerSpawn", function()
    ESX.Players[source].spawned = true
end)

if Config.CustomInventory then
    SetConvarReplicated("inventory:framework", "esx")
    SetConvarReplicated("inventory:weight", tostring(Config.MaxWeight * 1000))
end

local function StartDBSync()
    CreateThread(function()
        local interval <const> = 10 * 60 * 1000
        while true do
            Wait(interval)
            Core.SavePlayers()
        end
    end)
end

MySQL.ready(function()
    Core.DatabaseConnected = true

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `user_groups` (
            `license` VARCHAR(72) NOT NULL,
            `group` VARCHAR(50) NOT NULL DEFAULT 'user',
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`license`)
        )
    ]])

    pcall(function()
        MySQL.query.await("ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `gang` VARCHAR(50) NULL DEFAULT 'none'")
        MySQL.query.await("ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `gang_grade` INT NULL DEFAULT 0")
    end)

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `gang_members` (
            `identifier` VARCHAR(100) NOT NULL,
            `gang` VARCHAR(50) NOT NULL,
            `grade` INT NOT NULL DEFAULT 0,
            `name` VARCHAR(100) NOT NULL,
            `joined_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `last_seen` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    if not Config.CustomInventory then
        ESX.RefreshItems()
    end

    ESX.RefreshJobs()
    ESX.RefreshGangs()

    print(("[^2INFO^7] ESX ^5Legacy %s^0 initialized!"):format(GetResourceMetadata(GetCurrentResourceName(), "version", 0)))

    StartDBSync()
    if Config.EnablePaycheck then
        StartPayCheck()
    end
end)

RegisterNetEvent("esx:clientLog", function(msg)
    if Config.EnableDebug then
        print(("[^2TRACE^7] %s^7"):format(msg))
    end
end)

RegisterNetEvent("esx:ReturnVehicleType", function(Type, Request)
    if Core.ClientCallbacks[Request] then
        Core.ClientCallbacks[Request](Type)
        Core.ClientCallbacks[Request] = nil
    end
end)

GlobalState.playerCount = 0
