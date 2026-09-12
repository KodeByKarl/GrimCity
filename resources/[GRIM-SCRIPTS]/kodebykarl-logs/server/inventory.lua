--[[
    Exact, real-time ox_inventory Discord logs.
    Routes by inventory type → #OX-INVENTORY #DROPS #TRUNK #STASH #LOCKER
]]

local PREFIX = '[kodebykarl-logs:inventory]'

local function invCfg()
    return Config.Inventory
end

local function enabled()
    local c = invCfg()
    if not c or c.Enabled == false then return false end
    if not LogsEnabled or not LogsEnabled() then return false end
    return GetResourceState('ox_inventory') == 'started'
end

local function typeAllowed(channel)
    local c = invCfg()
    if c and c.Channels and c.Channels[channel] == false then
        return false
    end
    if Config.Types and Config.Types[channel] == false then
        return false
    end
    return true
end

--- Exact clock for staff (server local + UTC)
local function timeFields()
    return {
        { name = 'Time (Server)', value = ('`%s`'):format(os.date('%Y-%m-%d %H:%M:%S')), inline = true },
        { name = 'Time (UTC)', value = ('`%s`'):format(os.date('!%Y-%m-%d %H:%M:%S')), inline = true },
        { name = 'Unix', value = ('`%s`'):format(os.time()), inline = true },
    }
end

local function itemLabel(slot)
    if type(slot) ~= 'table' then return 'unknown' end
    local name = slot.name or 'unknown'
    local label = slot.label
    if not label and name ~= 'unknown' then
        local ok, item = pcall(function()
            return exports.ox_inventory:Items(name)
        end)
        if ok and item and item.label then
            label = item.label
        end
    end
    if label and label ~= name then
        return ('%s (%s)'):format(label, name)
    end
    return name
end

local function metaSummary(slot)
    if type(slot) ~= 'table' or type(slot.metadata) ~= 'table' then return nil end
    local md = slot.metadata
    local bits = {}
    if md.serial then bits[#bits + 1] = ('serial: %s'):format(md.serial) end
    if md.plate then bits[#bits + 1] = ('plate: %s'):format(md.plate) end
    if md.registered then bits[#bits + 1] = ('registered: %s'):format(md.registered) end
    if md.durability then bits[#bits + 1] = ('durability: %s'):format(md.durability) end
    if md.ammo then bits[#bits + 1] = ('ammo: %s'):format(md.ammo) end
    if md.component and type(md.component) == 'table' and #md.component > 0 then
        bits[#bits + 1] = ('components: %s'):format(#md.component)
    end
    if #bits == 0 then return nil end
    return table.concat(bits, ' · ')
end

local function invIdLooksLocker(id)
    id = tostring(id or ''):lower()
    if id == '' then return false end
    return id:find('locker', 1, true)
        or id:find('evidence', 1, true)
        or id:find('armory', 1, true)
        or id:find('armoury', 1, true)
end

--- Map transfer → Discord channel alias
local function resolveChannel(fromType, toType, fromId, toId)
    fromType = tostring(fromType or ''):lower()
    toType = tostring(toType or ''):lower()
    fromId = tostring(fromId or '')
    toId = tostring(toId or '')

    if toType == 'drop' or fromType == 'drop' or toId == 'newdrop' or fromId:find('^drop') or toId:find('^drop') then
        return 'drops'
    end

    if fromType == 'trunk' or toType == 'trunk' or fromType == 'glovebox' or toType == 'glovebox' then
        return 'trunk'
    end

    if fromType == 'policeevidence' or toType == 'policeevidence'
        or invIdLooksLocker(fromId) or invIdLooksLocker(toId) then
        return 'locker'
    end

    if fromType == 'stash' or toType == 'stash' then
        return 'stash'
    end

    return 'ox-inventory'
end

local function directionTitle(action, fromType, toType)
    action = tostring(action or 'move')
    if toType == 'drop' or tostring(toType) == 'newdrop' then
        return 'Item Dropped'
    end
    if fromType == 'drop' then
        return 'Drop Picked Up'
    end
    if action == 'swap' then
        return 'Items Swapped'
    end
    if action == 'stack' then
        return 'Items Stacked'
    end
    if action == 'give' then
        return 'Item Given'
    end
    if fromType == 'player' and toType ~= 'player' then
        return 'Item Deposited'
    end
    if toType == 'player' and fromType ~= 'player' then
        return 'Item Withdrawn'
    end
    if fromType == 'player' and toType == 'player' then
        return 'Player → Player Transfer'
    end
    return 'Inventory Transfer'
end

local function invBlock(kind, invType, invId)
    return ('Type: `%s`\nID: `%s`'):format(tostring(invType or '?'), tostring(invId or '?'))
end

local function writeTransfer(payload, channelOverride)
    if not enabled() then return end
    if type(payload) ~= 'table' then return end

    local fromType = payload.fromType
    local toType = payload.toType
    local fromId = payload.fromInventory
    local toId = payload.toInventory

    -- Skip rearranging within the same inventory (noise)
    local c = invCfg()
    if c and c.SkipSameInventory ~= false then
        if tostring(fromId) == tostring(toId) and fromType == toType and toId ~= 'newdrop' then
            return
        end
    end

    local channel = channelOverride or resolveChannel(fromType, toType, fromId, toId)
    if not typeAllowed(channel) then return end

    local slot = payload.fromSlot
    if type(slot) ~= 'table' then
        slot = { name = payload.itemName or 'unknown', count = payload.count }
    end

    local count = tonumber(payload.count) or tonumber(slot.count) or 1
    local fields = timeFields()

    fields[#fields + 1] = {
        name = 'Item',
        value = ('`%sx` **%s**'):format(count, itemLabel(slot)),
        inline = false,
    }
    fields[#fields + 1] = {
        name = 'Action',
        value = ('`%s`'):format(tostring(payload.action or 'move')),
        inline = true,
    }
    fields[#fields + 1] = {
        name = 'From',
        value = invBlock('from', fromType, fromId),
        inline = true,
    }
    fields[#fields + 1] = {
        name = 'To',
        value = invBlock('to', toType, toId),
        inline = true,
    }

    local meta = metaSummary(slot)
    if meta then
        fields[#fields + 1] = { name = 'Metadata', value = meta, inline = false }
    end

    if payload.dropId then
        fields[#fields + 1] = {
            name = 'Drop ID',
            value = ('`%s`'):format(payload.dropId),
            inline = true,
        }
    end

    local src = tonumber(payload.source)
    WriteLog(channel, {
        title = directionTitle(payload.action, fromType, toType),
        player = src,
        color = (Config.Colors and Config.Colors[channel]) or nil,
        fields = fields,
        coords = src and PlayerCoords and PlayerCoords(src) or nil,
    })
end

local function writeBuy(payload)
    if not enabled() or not typeAllowed('ox-inventory') then return end
    if type(payload) ~= 'table' then return end

    local item = payload.itemName or (payload.item and payload.item.name) or 'unknown'
    local count = tonumber(payload.count) or 1
    local price = tonumber(payload.price) or tonumber(payload.totalPrice) or nil
    local fields = timeFields()
    fields[#fields + 1] = {
        name = 'Item',
        value = ('`%sx` **%s**'):format(count, item),
        inline = false,
    }
    if price then
        fields[#fields + 1] = { name = 'Price', value = ('`$%s`'):format(price), inline = true }
    end
    fields[#fields + 1] = {
        name = 'Shop',
        value = ('`%s`'):format(tostring(payload.shopType or payload.shopId or '?')),
        inline = true,
    }

    WriteLog('ox-inventory', {
        title = 'Shop Purchase',
        player = payload.source,
        color = (Config.Colors and Config.Colors['ox-inventory']) or 3066993,
        fields = fields,
        coords = payload.source and PlayerCoords and PlayerCoords(payload.source) or nil,
    })
end

local function writeCraft(payload)
    if not enabled() or not typeAllowed('ox-inventory') then return end
    if type(payload) ~= 'table' then return end

    local recipe = payload.recipe
    local name = type(recipe) == 'table' and (recipe.name or recipe.label) or tostring(recipe or 'unknown')
    local fields = timeFields()
    fields[#fields + 1] = {
        name = 'Recipe',
        value = ('`%s`'):format(name),
        inline = false,
    }
    if payload.count then
        fields[#fields + 1] = {
            name = 'Count',
            value = ('`%s`'):format(payload.count),
            inline = true,
        }
    end

    WriteLog('ox-inventory', {
        title = 'Item Crafted',
        player = payload.source,
        color = (Config.Colors and Config.Colors['ox-inventory']) or 10181046,
        fields = fields,
        coords = payload.source and PlayerCoords and PlayerCoords(payload.source) or nil,
    })
end

local hooksReady = false

local function registerHooks()
    if hooksReady then return end
    if not enabled() then
        print(('^3%s^0 Disabled or ox_inventory not started.'):format(PREFIX))
        return
    end

    -- nil callback = filter/post-hook only (logs after success, never before)
    local swapId = exports.ox_inventory:registerHook('swapItems', nil)
    AddEventHandler(swapId, function(success, payload)
        if success then
            writeTransfer(payload)
        end
    end)

    local buyId = exports.ox_inventory:registerHook('buyItem', nil)
    AddEventHandler(buyId, function(success, payload)
        if success then
            writeBuy(payload)
        end
    end)

    local craftId = exports.ox_inventory:registerHook('craftItem', nil)
    AddEventHandler(craftId, function(success, payload)
        if success then
            writeCraft(payload)
        end
    end)

    hooksReady = true
    print(('^2%s^0 Hooks registered → OX-INVENTORY / DROPS / TRUNK / STASH / LOCKER'):format(PREFIX))
end

CreateThread(function()
    local deadline = GetGameTimer() + 60000
    while GetResourceState('ox_inventory') ~= 'started' and GetGameTimer() < deadline do
        Wait(500)
    end
    Wait(1500)
    registerHooks()
end)

AddEventHandler('onResourceStart', function(res)
    if res == 'ox_inventory' then
        hooksReady = false
        SetTimeout(1500, registerHooks)
    end
end)

-- Console smoke test
RegisterCommand('citylogs_inv_test', function(src)
    if src ~= 0 then return end
    for _, channel in ipairs({ 'ox-inventory', 'drops', 'trunk', 'stash', 'locker' }) do
        WriteLog(channel, {
            title = 'Inventory Log Test',
            description = ('Manual console test for `#%s`.'):format(channel),
            fields = timeFields(),
            thumbnail = false,
        })
    end
    print(('[kodebykarl-logs] Inventory channel tests queued.'))
end, true)
