--[[
    Blackmarket client — catalog/locations from server. Buy with black_money.
    ox_target only (no props).
]]

local Vars = require 'helpers.vars'
local Region = require 'helpers.region'

local busy = false
local Data = nil
local ActiveLocationId = nil

local SECTION_META = {
    tier1 = { title = 'Class 1 — Street', icon = 'fa-solid fa-gun', desc = 'SNS, TEC-9, Mini Uzi, Sawed-off' },
    tier2 = { title = 'Class 2 — Mid', icon = 'fa-solid fa-burst', desc = 'MP5, MP9, Pump Mk II, Heavy Shotgun' },
    tier3 = { title = 'Class 3 — Endgame', icon = 'fa-solid fa-crosshairs', desc = 'Compact, Tactical, Heavy, Battle Rifle' },
    attachment = { title = 'Attachments', icon = 'fa-solid fa-screwdriver-wrench', desc = 'Extended clips & suppressors' },
    ammo = { title = 'Ammo', icon = 'fa-solid fa-boxes-stacked', desc = '9mm, .45, 5.56, 7.62, 12 Gauge' },
}

local function notify(msg, nType)
    ESX.Notify('BLACKMARKET', msg, nType or 'info', 5000)
end

local function getDirty()
    return Vars.ox:Search('count', Data and Data.currency or 'black_money') or 0
end

local function locationSections(locationId)
    if not Data then return {} end
    for i = 1, #Data.locations do
        if Data.locations[i].id == locationId then
            return Data.locations[i].sections or {}
        end
    end
    return {}
end

local function buy(entry)
    if busy then
        return notify('Already buying.', 'error')
    end
    if not ActiveLocationId then
        return notify('Invalid blackmarket spot.', 'error')
    end

    local dirty = getDirty()
    if dirty < entry.price then
        return notify(('Need $%s dirty money.'):format(ESX.Math.GroupDigits(entry.price)), 'error')
    end

    busy = true
    if Vars.oxTarget then
        Vars.oxTarget:disableTargeting(true)
    end

    local ok = lib.progressBar({
        duration = 3500,
        label = ('Buying %s…'):format(entry.label),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a',
            flag = 49,
        },
    })

    busy = false
    if Vars.oxTarget then
        Vars.oxTarget:disableTargeting(false)
    end

    if not ok then
        return notify('Cancelled.', 'error')
    end

    local success, a, b = lib.callback.await('cfx-keydi-utils:blackmarket:buy', false, ActiveLocationId, entry.id)
    if success then
        notify(('Bought %s for $%s dirty.'):format(a or entry.label, ESX.Math.GroupDigits(b or entry.price)), 'success')
    else
        notify(a or 'Purchase failed.', 'error')
    end
end

local function isItemAtLocation(entry, locationId)
    if not entry.locations then return true end
    for i = 1, #entry.locations do
        if entry.locations[i] == locationId then
            return true
        end
    end
    return false
end

local function openSection(section)
    if not Data or not ActiveLocationId then return end

    local dirty = getDirty()
    local options = {}
    for i = 1, #Data.items do
        local entry = Data.items[i]
        if entry.section == section and isItemAtLocation(entry, ActiveLocationId) then
            local canBuy = dirty >= entry.price
            options[#options + 1] = {
                title = entry.label,
                description = ('$%s dirty money'):format(ESX.Math.GroupDigits(entry.price)),
                icon = 'fa-solid fa-sack-dollar',
                disabled = not canBuy,
                metadata = {
                    { label = 'Price', value = ('$%s DM'):format(ESX.Math.GroupDigits(entry.price)) },
                    { label = 'Your DM', value = ('$%s'):format(ESX.Math.GroupDigits(dirty)) },
                    { label = 'Amount', value = tostring(entry.count) },
                },
                onSelect = function()
                    buy(entry)
                end,
            }
        end
    end

    if #options == 0 then
        return notify('Nothing available in this section at this location.', 'error')
    end

    local meta = SECTION_META[section] or { title = section }
    lib.registerContext({
        id = 'cfx_keydi_blackmarket_section',
        title = meta.title,
        menu = 'cfx_keydi_blackmarket_root',
        options = options,
    })
    lib.showContext('cfx_keydi_blackmarket_section')
end

local function openRoot(locationId)
    if not Region.Allowed('illegal') then
        return notify(Region.Message('illegal'), 'error')
    end
    if not Data then
        return notify('Blackmarket unavailable.', 'error')
    end

    ActiveLocationId = locationId
    local sections = locationSections(locationId)
    local dirty = getDirty()
    local options = {
        {
            title = 'Dirty Money',
            description = ('Balance: $%s'):format(ESX.Math.GroupDigits(dirty)),
            icon = 'fa-solid fa-money-bill-wave',
            readOnly = true,
        },
    }

    for i = 1, #sections do
        local key = sections[i]
        local meta = SECTION_META[key]
        if meta then
            -- Check if this location has items in this section
            local count = 0
            for j = 1, #Data.items do
                local entry = Data.items[j]
                if entry.section == key and isItemAtLocation(entry, locationId) then
                    count = count + 1
                end
            end

            if count > 0 then
                options[#options + 1] = {
                    title = meta.title,
                    description = meta.desc,
                    icon = meta.icon,
                    arrow = true,
                    onSelect = function()
                        openSection(key)
                    end,
                }
            end
        end
    end

    local locLabel = 'Blackmarket'
    for i = 1, #Data.locations do
        if Data.locations[i].id == locationId then
            locLabel = Data.locations[i].label or locLabel
            break
        end
    end

    lib.registerContext({
        id = 'cfx_keydi_blackmarket_root',
        title = locLabel,
        options = options,
    })
    lib.showContext('cfx_keydi_blackmarket_root')
end

CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(200)
    end
    Vars.oxTarget = Vars.oxTarget or exports.ox_target

    Data = lib.callback.await('cfx-keydi-utils:blackmarket:getData', false)
    if not Data or not Data.locations then
        warn('[cfx-keydi-utils] blackmarket: failed to load server data')
        return
    end

    local dist = Data.interactDistance or 2.0
    for i = 1, #Data.locations do
        local loc = Data.locations[i]
        local locId = loc.id
        Vars.oxTarget:addSphereZone({
            coords = vec3(loc.x, loc.y, loc.z),
            radius = dist,
            debug = false,
            options = {
                {
                    name = ('cfx_keydi_blackmarket_%s'):format(locId),
                    icon = 'fa-solid fa-skull-crossbones',
                    label = loc.label or 'Blackmarket',
                    distance = dist,
                    onSelect = function()
                        if not Region.Allowed('illegal') then
                            return notify(Region.Message('illegal'), 'error')
                        end
                        openRoot(locId)
                    end,
                },
            },
        })
    end
end)
