--[[
    cfx-keydi-market — server (sell grind items for cash/bank)
]]

if ConfigMarket and ConfigMarket.Enabled == false then return end

local ESX = exports['es_extended']:getSharedObject()
local ox_inventory = exports.ox_inventory

local basePrices = {}
local priceLookup = {}

for _, entry in ipairs(ConfigMarket.Items or {}) do
    local minP = math.floor(tonumber(entry.minPrice) or tonumber(entry.price) or 1)
    local maxP = math.floor(tonumber(entry.maxPrice) or minP)
    if maxP < minP then
        minP, maxP = maxP, minP
    end
    minP = math.max(1, minP)
    maxP = math.max(minP, maxP)
    basePrices[entry.item] = { min = minP, max = maxP }
    -- Midpoint until first randomize
    priceLookup[entry.item] = math.floor((minP + maxP) / 2)
end

local sellCooldown = {}

local intervalMinutes = tonumber((ConfigMarket.PriceUpdate or {}).IntervalMinutes) or 120
if intervalMinutes < 1 then intervalMinutes = 1 end
local intervalSeconds = math.floor(intervalMinutes * 60)
local lastUpdateAt = os.time()
local nextUpdateAt = lastUpdateAt + intervalSeconds

local function stampUpdate()
    lastUpdateAt = os.time()
    nextUpdateAt = lastUpdateAt + intervalSeconds
end

local function copyPrices()
    local out = {}
    for item, price in pairs(priceLookup) do
        out[item] = price
    end
    return out
end

local function buildCatalog()
    local items = {}
    for _, entry in ipairs(ConfigMarket.Items or {}) do
        local range = basePrices[entry.item]
        if range then
            items[#items + 1] = {
                item = entry.item,
                label = entry.label or entry.item,
                category = entry.category or 'General',
                price = priceLookup[entry.item] or range.min,
                minPrice = range.min,
                maxPrice = range.max,
            }
        end
    end
    return {
        items = items,
        lastUpdateAt = lastUpdateAt,
        nextUpdateAt = nextUpdateAt,
        intervalMinutes = intervalMinutes,
    }
end

local function randomizePrices()
    for item, range in pairs(basePrices) do
        priceLookup[item] = math.random(range.min, range.max)
    end
end

local function broadcastPrices(announce)
    TriggerClientEvent('cfx-keydi-market:client:pricesUpdated', -1, copyPrices(), announce == true)
end

lib.callback.register('cfx-keydi-market:server:getPrices', function()
    return copyPrices()
end)

lib.callback.register('cfx-keydi-market:server:getCatalog', function()
    return buildCatalog()
end)

RegisterNetEvent('cfx-keydi-market:server:sell', function(payload)
    local src = source
    if type(src) ~= 'number' or src < 1 then return end
    if type(payload) ~= 'table' or type(payload.cart) ~= 'table' then return end

    local now = GetGameTimer()
    if sellCooldown[src] and (now - sellCooldown[src]) < 1500 then
        return
    end
    sellCooldown[src] = now

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end
    local pos = GetEntityCoords(ped)
    local nearMarket = false
    for i = 1, #(ConfigMarket.Locations or {}) do
        local c = ConfigMarket.Locations[i].coords
        if c and #(pos - vector3(c.x, c.y, c.z)) <= 8.0 then
            nearMarket = true
            break
        end
    end
    if not nearMarket then
        KeydiElectron.Flag(src, "Market sell exploit (not at NPC)", "cfx-keydi-market")
        TriggerClientEvent('cfx-keydi-market:client:notify', src, 'You must be at the sell market.', 'error')
        return
    end

    local payout = payload.payout == 'bank' and 'bank' or 'cash'
    local total = 0
    local toRemove = {}

    for i = 1, #payload.cart do
        local row = payload.cart[i]
        if type(row) == 'table' then
            local itemName = row.item
            local amount = math.floor(tonumber(row.amount) or 0)
            local unitPrice = priceLookup[itemName]

            if itemName and amount > 0 and unitPrice and unitPrice > 0 then
                local have = ox_inventory:Search(src, 'count', itemName) or 0
                if have < amount then
                    TriggerClientEvent('cfx-keydi-market:client:notify', src, ('Not enough %s.'):format(itemName), 'error')
                    return
                end
                toRemove[#toRemove + 1] = { item = itemName, amount = amount, price = unitPrice }
                total = total + (unitPrice * amount)
            end
        end
    end

    if #toRemove < 1 or total < 1 then
        TriggerClientEvent('cfx-keydi-market:client:notify', src, 'Nothing to sell.', 'error')
        return
    end

    for i = 1, #toRemove do
        local row = toRemove[i]
        local removed = ox_inventory:RemoveItem(src, row.item, row.amount)
        if not removed then
            TriggerClientEvent('cfx-keydi-market:client:notify', src, 'Failed to remove items.', 'error')
            return
        end
    end

    if payout == 'bank' then
        xPlayer.addAccountMoney('bank', total)
    else
        xPlayer.addMoney(total)
    end

    TriggerClientEvent('cfx-keydi-market:client:sold', src, total, payout)
end)

AddEventHandler('playerDropped', function()
    sellCooldown[source] = nil
end)

CreateThread(function()
    local cfg = ConfigMarket.PriceUpdate or {}
    local interval = intervalSeconds * 1000

    -- Start with randomized prices (no announce on resource boot)
    math.randomseed(os.time() + GetGameTimer())
    randomizePrices()
    stampUpdate()
    broadcastPrices(false)

    while true do
        Wait(interval)
        randomizePrices()
        stampUpdate()
        broadcastPrices(cfg.Announce ~= false)

        if ConfigMarket.Debug then
            print(('^3[cfx-keydi-market]^0 prices updated (next in %sm)'):format(intervalMinutes))
        end
    end
end)
