local function ResetHouseStateTimer(house)
    CreateThread(function ()
        Wait(Config.HouseRob.TimeToCloseDoors * 60000)
        Config.HouseRob.Houses[house]["opened"] = false
        local furnitureData = Config.HouseRob.Houses[house]["furniture"]
        for i = 1, #furnitureData do
            Config.HouseRob.Houses[house]["furniture"][i].searched = false
        end
        TriggerClientEvent('cfx-cs-robbery:houserob:client:ResetHouseState', -1, house)
    end)
end

-- Callbacks
lib.callback.register('cfx-cs-robbery:houserob:server:GetHouseConfig', function(_)
    return Config.HouseRob.Houses
end)

-- Events
RegisterNetEvent('cfx-cs-robbery:houserob:server:SetBusyState', function(cabin, house, bool)
    Config.HouseRob.Houses[house]["furniture"][cabin]["isBusy"] = bool
    TriggerClientEvent('cfx-cs-robbery:houserob:client:SetBusyState', -1, cabin, house, bool)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:enterHouse', function(house)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not Config.HouseRob.Houses[house]["opened"] then
        ResetHouseStateTimer(house)
        TriggerClientEvent('cfx-cs-robbery:houserob:client:setHouseState', -1, house, true)
        lib.logger(xPlayer.source, 'robbery_houserob', xPlayer.name..' ['..xPlayer.source..'] started house robbery at vec3('..Config.HouseRob.Houses[house]['coords'].x..', '..Config.HouseRob.Houses[house]['coords'].y..', '..Config.HouseRob.Houses[house]['coords'].z..') ('..house..')')
    end
    TriggerClientEvent('cfx-cs-robbery:houserob:client:enterHouse', src, house)
    Config.HouseRob.Houses[house]["opened"] = true
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:searchFurniture', function(cabin, house)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local tier = Config.HouseRob.Houses[house].tier
    local availableItems = Config.HouseRob.Rewards[tier][Config.HouseRob.Houses[house].furniture[cabin].type]
    local itemCount = math.random(0, 3)
    if itemCount > 0 then
        local selectedItem = availableItems[math.random(1, #availableItems)]
        local amount = math.random(selectedItem.min, selectedItem.max)
        ox_inventory:AddItem(xPlayer.source, selectedItem.item, amount)
        lib.logger(xPlayer.source, 'robbery_houserob', xPlayer.name..' received '..amount..'x '..ox_items[selectedItem.item].label..' from house robbery ['..house..']')
    else
        TriggerClientEvent('esx:Notify', src, 'House Robbery', 'The box is empty.', 'error', 5000)
    end
    if Config.HouseRob.RewardsSpecial and next(Config.HouseRob.RewardsSpecial) then
        local itemCount2 = math.random(0, 2)
        if itemCount2 > 0 then
            local selectedItem = Config.HouseRob.RewardsSpecial[math.random(1, #Config.HouseRob.RewardsSpecial)]
            local amount = math.random(selectedItem.min, selectedItem.max)
            ox_inventory:AddItem(xPlayer.source, selectedItem.item, amount)
            lib.logger(xPlayer.source, 'robbery_houserob', xPlayer.name..' received '..amount..'x '..ox_items[selectedItem.item].label..' from house robbery (Rare Item) ['..house..']')
        end
    end
    Config.HouseRob.Houses[house]["furniture"][cabin]["searched"] = true
    TriggerClientEvent('cfx-cs-robbery:houserob:client:setCabinState', -1, house, cabin, true)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:removeAdvancedLockpick', function()
    local src = source
    ox_inventory:RemoveItem(src, 'advancedlockpick', 1)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:server:removeLockpick', function()
    local src = source
    ox_inventory:RemoveItem(src, 'lockpick', 1)
end)

RegisterNetEvent('cfx-cs-robbery:houserob:setRoutingBucket', function(bucket)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    SetPlayerRoutingBucket(xPlayer.source, bucket)
end)