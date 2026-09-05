-- =========================================
-- NOLIMITS UNIVERSITY - INVENTORY BRIDGE
-- =========================================
-- Supports: ox_inventory | qb-inventory | qs-inventory | ak47_inventory
-- Configure in shared/config.lua → Config.InventorySystem

Inventory = {}

-- =========================================
-- INTERNAL HELPERS
-- =========================================

--- Safely returns the QBCore object (server-side only).
--- Returns nil if qb-core is not running.
local function GetQBCore()
    if GetResourceState('qb-core') ~= 'started' then return nil end
    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    return ok and core or nil
end

--- Safely returns the raw QBCore Player object for a given server source.
--- Returns nil on failure.
local function GetQBPlayer(source)
    local QBCore = GetQBCore()
    if not QBCore then return nil end
    local Player = QBCore.Functions.GetPlayer(source)
    return Player or nil
end

-- =========================================
-- ADD ITEM
-- =========================================

--- Adds an item to a player's inventory.
--- @param source  number  Player server ID
--- @param item    string  Item name
--- @param count   number  Amount to add
--- @param metadata table  Optional metadata / info table
--- @return boolean  true on success
function Inventory.AddItem(source, item, count, metadata)
    if Config.InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:AddItem(source, item, count, metadata)
    elseif Config.InventorySystem == 'qb-inventory' then
        -- exports['qb-inventory']:AddItem(source, item, amount, slot, info)
        return exports['qb-inventory']:AddItem(source, item, count, false, metadata)
    elseif Config.InventorySystem == 'qs-inventory' then
        if not exports['qs-inventory']:CanCarryItem(source, item, count) then
            return false
        end
        return exports['qs-inventory']:AddItem(source, item, count, false, metadata)
    elseif Config.InventorySystem == 'ak47_inventory' then
        local success, reason = exports['ak47_inventory']:AddItem(source, item, count, nil, metadata)
        return success
    else
        print('^1[nl-university]^7 Unsupported inventory system in AddItem: ' .. tostring(Config.InventorySystem))
        return false
    end
end

-- =========================================
-- REMOVE ITEM
-- =========================================

--- Removes an item from a player's inventory.
--- @param source   number  Player server ID
--- @param item     string  Item name
--- @param count    number  Amount to remove
--- @param metadata table   Optional metadata (ox_inventory slot filter)
--- @return boolean  true on success
function Inventory.RemoveItem(source, item, count, metadata)
    if Config.InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(source, item, count, metadata)
    elseif Config.InventorySystem == 'qb-inventory' then
        -- exports['qb-inventory']:RemoveItem(source, item, amount, slot, metadata)
        return exports['qb-inventory']:RemoveItem(source, item, count, false, metadata)
    elseif Config.InventorySystem == 'qs-inventory' then
        return exports['qs-inventory']:RemoveItem(source, item, count)
    elseif Config.InventorySystem == 'ak47_inventory' then
        local success, reason = exports['ak47_inventory']:RemoveItem(source, item, count)
        return success
    else
        print('^1[nl-university]^7 Unsupported inventory system in RemoveItem: ' .. tostring(Config.InventorySystem))
        return false
    end
end

-- =========================================
-- GET ITEM COUNT
-- =========================================

--- Returns the total count of an item in a player's inventory.
--- @param source  number  Player server ID
--- @param item    string  Item name
--- @return number  Total count (0 if not found)
function Inventory.GetItemCount(source, item)
    if Config.InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(source, item)
    elseif Config.InventorySystem == 'qb-inventory' then
        local Player = GetQBPlayer(source)
        if not Player then return 0 end

        local count = 0
        for _, v in pairs(Player.PlayerData.items or {}) do
            if v and v.name == item then
                count = count + (v.amount or 1)
            end
        end
        return count
    elseif Config.InventorySystem == 'qs-inventory' then
        return exports['qs-inventory']:GetItemTotalAmount(source, item)
    elseif Config.InventorySystem == 'ak47_inventory' then
        if IsDuplicityVersion() then
            return exports['ak47_inventory']:GetAmount(source, item) or 0
        else
            return exports['ak47_inventory']:Search('amount', item) or 0
        end
    else
        print('^1[nl-university]^7 Unsupported inventory system in GetItemCount: ' .. tostring(Config.InventorySystem))
        return 0
    end
end

-- =========================================
-- CAN CARRY ITEM
-- =========================================

--- Checks whether a player can carry additional items by weight.
--- @param source  number  Player server ID
--- @param item    string  Item name
--- @param count   number  Amount to check
--- @return boolean  true if player can carry the items
function Inventory.CanCarryItem(source, item, count)
    if Config.InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:CanCarryItem(source, item, count)
    elseif Config.InventorySystem == 'qb-inventory' then
        local QBCore = GetQBCore()
        if not QBCore then return false end

        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end

        -- Retrieve item weight from shared items
        local itemData = QBCore.Shared.Items[item]
        if not itemData then
            -- Unknown item — allow by default to avoid false-blocking
            return true
        end

        local addedWeight = (itemData.weight or 0) * count
        local maxWeight   = (Player.PlayerData.metadata and Player.PlayerData.metadata.maxweight) or 120000
        local usedWeight  = 0

        for _, v in pairs(Player.PlayerData.items or {}) do
            if v and v.name then
                local vData = QBCore.Shared.Items[v.name]
                if vData then
                    usedWeight = usedWeight + ((vData.weight or 0) * (v.amount or 1))
                end
            end
        end

        return (usedWeight + addedWeight) <= maxWeight
    elseif Config.InventorySystem == 'qs-inventory' then
        return exports['qs-inventory']:CanCarryItem(source, item, count)
    elseif Config.InventorySystem == 'ak47_inventory' then
        return exports['ak47_inventory']:CanAddItem(source, item, count)
    else
        print('^1[nl-university]^7 Unsupported inventory system in CanCarryItem: ' .. tostring(Config.InventorySystem))
        return false
    end
end

-- =========================================
-- REGISTER USABLE ITEM  (server-side only)
-- =========================================

--- Registers a usable item callback.
--- Should only be called from server-side scripts.
--- @param item      string    Item name
--- @param callback  function  fn(source, itemData) called on use
function Inventory.RegisterUsableItem(item, callback)
    if Config.InventorySystem == 'ox_inventory' then
        -- ox_inventory hook — payload table, NOT positional arguments
        exports.ox_inventory:registerHook('useItem', function(payload)
            if payload.item.name == item then
                callback(payload.source, payload.item)
            end
        end, {
            print      = false,
            itemFilter = { [item] = true },
        })
    elseif Config.InventorySystem == 'qb-inventory' then
        local QBCore = GetQBCore()
        if not QBCore then
            print('^1[nl-university]^7 QBCore not available for RegisterUsableItem: ' .. tostring(item))
            return
        end
        QBCore.Functions.CreateUseableItem(item, function(source, itemData)
            callback(source, itemData)
        end)
    elseif Config.InventorySystem == 'qs-inventory' then
        exports['qs-inventory']:CreateUsableItem(item, function(source, itemData)
            callback(source, itemData)
        end)
    elseif Config.InventorySystem == 'ak47_inventory' then
        -- ak47_inventory does not have a native RegisterUsableItem/CreateUsableItem export.
        -- The item must be configured as usable in the ak47_inventory item definitions,
        -- and use a server event or export to trigger the callback.
        -- We register a net event as a fallback trigger.
        RegisterNetEvent('nl-university:ak47:useItem:' .. item, function()
            local src = source
            callback(src, { name = item })
        end)
        print('^3[nl-university]^7 ak47_inventory: registered fallback event for usable item: ' .. item)
    else
        print('^1[nl-university]^7 Unsupported inventory system in RegisterUsableItem: ' ..
        tostring(Config.InventorySystem))
    end
end

-- =========================================
-- GET ITEM  (with metadata)
-- =========================================

--- Returns the first matching item table from a player's inventory.
--- Includes metadata/info and slot information.
--- @param source  number  Player server ID
--- @param item    string  Item name
--- @return table|nil  Item data table, or nil if not found
function Inventory.GetItem(source, item)
    if Config.InventorySystem == 'ox_inventory' then
        local items = exports.ox_inventory:GetInventoryItems(source)
        if not items then return nil end
        for _, invItem in pairs(items) do
            if invItem.name == item then
                return invItem
            end
        end
        return nil
    elseif Config.InventorySystem == 'qb-inventory' then
        local Player = GetQBPlayer(source)
        if not Player then return nil end
        for _, v in pairs(Player.PlayerData.items or {}) do
            if v and v.name == item then
                return v
            end
        end
        return nil
    elseif Config.InventorySystem == 'qs-inventory' then
        local items = exports['qs-inventory']:GetInventory(source)
        if not items then return nil end
        for _, invItem in pairs(items) do
            if invItem.name == item then
                return invItem
            end
        end
        return nil
    elseif Config.InventorySystem == 'ak47_inventory' then
        return exports['ak47_inventory']:GetItem(source, item)
    else
        print('^1[nl-university]^7 Unsupported inventory system in GetItem: ' .. tostring(Config.InventorySystem))
        return nil
    end
end

-- =========================================
-- NOTIFY PLAYER
-- =========================================

--- Sends an ox_lib notification to a player.
--- @param source   number  Player server ID
--- @param message  string  Notification message
--- @param type     string  'success' | 'error' | 'inform' | 'warning'  (default: 'inform')
function Inventory.Notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        type        = type or 'inform',
        description = message,
    })
end

return Inventory
