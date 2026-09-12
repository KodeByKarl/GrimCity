--[[
    Blackmarket — buy with black_money (no materials).
    Locations + catalog live on the server only.
]]

local Vars = require 'helpers.vars'
local Region = require 'helpers.region'

local CURRENCY = 'black_money'

local Blackmarket = {
    name = 'blackmarket',
    interactDistance = 2.0,
    cooldown = 3,

    -- Each location: coords + label + sections
    locations = {
        {
            -- Location 1 — East Coast / Catfish View (Street & Smuggler Arsenal)
            label = 'Blackmarket — East Coast',
            coords = vec4(3819.7573, 4440.5991, 2.8057, 194.8459),
            sections = { 'tier1', 'tier2', 'tier3', 'attachment', 'ammo' },
        },
        {
            -- Location 2 — North Wilderness / Mt. Chiliad (Tactical & Heavy Rifles)
            label = 'Blackmarket — North Wilderness',
            coords = vec4(-419.0885, 4006.3496, 81.2739, 15.5439),
            sections = { 'tier1', 'tier2', 'tier3', 'attachment', 'ammo' },
        },
        {
            -- Location 3 — Paleto Cove / North Coast (Spec-Ops & Modern SMGs)
            label = 'Blackmarket — Paleto Cove',
            coords = vec4(-2167.1072, 5193.7529, 16.5311, 27.0260),
            sections = { 'tier1', 'tier2', 'tier3', 'attachment', 'ammo' },
        },
        {
            -- Location 4 — West Coast / Lago Zancudo (High-Caliber & Heavy Firepower)
            label = 'Blackmarket — West Coast',
            coords = vec4(-2417.5396, 3371.5432, 32.9743, 250.0580),
            sections = { 'tier1', 'tier2', 'tier3', 'attachment', 'ammo' },
        },
    },

    -- price = black_money
    -- locations = { ... } assigns items specifically to locations (different guns per spot)
    items = {
        -- =============================================================
        -- LOCATION 1: East Coast (Street & Smuggler Guns)
        -- =============================================================
        -- Class 1 (street)
        { id = 'w_snspistol',     locations = { 1 }, section = 'tier1', label = 'SNS Pocket Pistol',        item = 'WEAPON_SNSPISTOL',       count = 1, price = 45000 },
        { id = 'w_machinepistol', locations = { 1 }, section = 'tier1', label = 'TEC-9 (Machine Pistol)',   item = 'WEAPON_MACHINEPISTOL',   count = 1, price = 65000 },
        { id = 'w_sawnoff',       locations = { 1 }, section = 'tier1', label = 'Sawed-off Shotgun',        item = 'WEAPON_SAWNOFFSHOTGUN',  count = 1, price = 75000 },
        -- Class 2 (mid)
        { id = 'w_smg',           locations = { 1 }, section = 'tier2', label = 'MP5 (SMG)',                item = 'WEAPON_SMG',             count = 1, price = 145000 },
        { id = 'w_pumpmk2',       locations = { 1 }, section = 'tier2', label = 'Pump Shotgun Mk II',       item = 'WEAPON_PUMPSHOTGUN_MK2', count = 1, price = 175000 },
        -- Class 3 (high)
        { id = 'w_compactrifle',  locations = { 1 }, section = 'tier3', label = 'Compact Rifle (Draco)',    item = 'WEAPON_COMPACTRIFLE',    count = 1, price = 285000 },

        -- =============================================================
        -- LOCATION 2: North Wilderness (Tactical & Heavy Rifles)
        -- =============================================================
        -- Class 1 (street)
        { id = 'w_heavypistol',   locations = { 2 }, section = 'tier1', label = 'Heavy Pistol .45',         item = 'WEAPON_HEAVYPISTOL',     count = 1, price = 55000 },
        { id = 'w_doubleaction',  locations = { 2 }, section = 'tier1', label = 'Double Action Revolver',   item = 'WEAPON_DOUBLEACTION',    count = 1, price = 70000 },
        -- Class 2 (mid)
        { id = 'w_combatpdw',     locations = { 2 }, section = 'tier2', label = 'Combat PDW (SIG MPX)',     item = 'WEAPON_COMBATPDW',       count = 1, price = 155000 },
        { id = 'w_bullpupshotgun',locations = { 2 }, section = 'tier2', label = 'Bullpup Shotgun',         item = 'WEAPON_BULLPUPSHOTGUN',  count = 1, price = 180000 },
        -- Class 3 (high)
        { id = 'w_tacticalrifle', locations = { 2 }, section = 'tier3', label = 'Tactical Rifle (M16A4)',   item = 'WEAPON_TACTICALRIFLE',   count = 1, price = 345000 },
        { id = 'w_heavyrifle',    locations = { 2 }, section = 'tier3', label = 'Heavy Rifle (SCAR-L)',     item = 'WEAPON_HEAVYRIFLE',      count = 1, price = 395000 },

        -- =============================================================
        -- LOCATION 3: Paleto Cove (Spec-Ops & Modern SMGs)
        -- =============================================================
        -- Class 1 (street)
        { id = 'w_vintagepistol', locations = { 3 }, section = 'tier1', label = 'Vintage Pistol',          item = 'WEAPON_VINTAGEPISTOL',   count = 1, price = 50000 },
        { id = 'w_minismg',       locations = { 3 }, section = 'tier1', label = 'Mini SMG (Skorpion)',      item = 'WEAPON_MINISMG',         count = 1, price = 70000 },
        -- Class 2 (mid)
        { id = 'w_tecpistol',     locations = { 3 }, section = 'tier2', label = 'Tactical SMG (MP9)',       item = 'WEAPON_TECPISTOL',       count = 1, price = 160000 },
        { id = 'w_heavyshotgun',  locations = { 3 }, section = 'tier2', label = 'Heavy Shotgun (Saiga-12)', item = 'WEAPON_HEAVYSHOTGUN',    count = 1, price = 195000 },
        -- Class 3 (high)
        { id = 'w_specialcarbine',locations = { 3 }, section = 'tier3', label = 'Special Carbine (G36C)',   item = 'WEAPON_SPECIALCARBINE',  count = 1, price = 360000 },
        { id = 'w_militaryrifle', locations = { 3 }, section = 'tier3', label = 'Military Rifle (AUG A3)', item = 'WEAPON_MILITARYRIFLE',   count = 1, price = 410000 },

        -- =============================================================
        -- LOCATION 4: West Coast (High-Caliber & Heavy Firepower)
        -- =============================================================
        -- Class 1 (street)
        { id = 'w_appistol',      locations = { 4 }, section = 'tier1', label = 'AP Pistol (Full Auto)',    item = 'WEAPON_APPISTOL',        count = 1, price = 85000 },
        { id = 'w_microsmg',      locations = { 4 }, section = 'tier1', label = 'Mini Uzi',                 item = 'WEAPON_MICROSMG',        count = 1, price = 80000 },
        -- Class 2 (mid)
        { id = 'w_gusenberg',     locations = { 4 }, section = 'tier2', label = 'Gusenberg Sweeper',        item = 'WEAPON_GUSENBERG',       count = 1, price = 170000 },
        { id = 'w_dbshotgun',     locations = { 4 }, section = 'tier2', label = 'Double Barrel Shotgun',    item = 'WEAPON_DBSHOTGUN',       count = 1, price = 165000 },
        -- Class 3 (high)
        { id = 'w_assaultrifle',  locations = { 4 }, section = 'tier3', label = 'Assault Rifle (AK-47)',    item = 'WEAPON_ASSAULTRIFLE',    count = 1, price = 350000 },
        { id = 'w_battlerifle',   locations = { 4 }, section = 'tier3', label = 'Battle Rifle (FAL)',       item = 'WEAPON_BATTLERIFLE',     count = 1, price = 450000 },

        -- =============================================================
        -- SHARED: Attachments (Available across all 4 locations)
        -- =============================================================
        { id = 'at_ext_pistol',   section = 'attachment', label = 'Extended Clip (Pistol)', item = 'at_clip_extended_pistol', count = 1, price = 25000 },
        { id = 'at_ext_smg',      section = 'attachment', label = 'Extended Clip (SMG)',    item = 'at_clip_extended_smg',    count = 1, price = 32000 },
        { id = 'at_ext_rifle',    section = 'attachment', label = 'Extended Clip (Rifle)',  item = 'at_clip_extended_rifle',  count = 1, price = 40000 },
        { id = 'at_supp_light',   section = 'attachment', label = 'Suppressor (Light)',     item = 'at_suppressor_light',     count = 1, price = 55000 },
        { id = 'at_supp_heavy',   section = 'attachment', label = 'Suppressor (Heavy)',     item = 'at_suppressor_heavy',     count = 1, price = 75000 },

        -- =============================================================
        -- SHARED: Ammo Packs (Available across all 4 locations)
        -- =============================================================
        { id = 'ammo_9mm',  section = 'ammo', label = '9mm Ammo (x50)',         item = 'ammo-9',       count = 50, price = 12000 },
        { id = 'ammo_45',   section = 'ammo', label = '.45 ACP Ammo (x40)',     item = 'ammo-45',      count = 40, price = 15000 },
        { id = 'ammo_556',  section = 'ammo', label = '5.56 Rifle Ammo (x40)',  item = 'ammo-rifle',   count = 40, price = 18000 },
        { id = 'ammo_762',  section = 'ammo', label = '7.62 Rifle Ammo (x30)',  item = 'ammo-rifle2',  count = 30, price = 22000 },
        { id = 'ammo_12g',  section = 'ammo', label = '12 Gauge Shells (x20)',  item = 'ammo-shotgun', count = 20, price = 16000 },
    },
}

local itemById = {}
for i = 1, #Blackmarket.items do
    itemById[Blackmarket.items[i].id] = Blackmarket.items[i]
end

local cooldown = {}

local function hasSection(sections, section)
    for i = 1, #sections do
        if sections[i] == section then return true end
    end
    return false
end

local function serializeLocations()
    local out = {}
    for i = 1, #Blackmarket.locations do
        local loc = Blackmarket.locations[i]
        local c = loc.coords
        out[i] = {
            id = i,
            label = loc.label or 'Blackmarket',
            x = c.x, y = c.y, z = c.z, w = c.w,
            sections = loc.sections,
        }
    end
    return out
end

local function serializeItems()
    local out = {}
    for i = 1, #Blackmarket.items do
        local it = Blackmarket.items[i]
        out[i] = {
            id = it.id,
            section = it.section,
            label = it.label,
            item = it.item,
            count = it.count,
            price = it.price,
            locations = it.locations,
        }
    end
    return out
end

local function nearLocation(src, locationId)
    local loc = Blackmarket.locations[locationId]
    if not loc then return false end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local coords = GetEntityCoords(ped)
    local c = loc.coords
    local maxDist = (Blackmarket.interactDistance or 2.0) + 3.0
    return #(coords - vec3(c.x, c.y, c.z)) <= maxDist
end

lib.callback.register('cfx-keydi-utils:blackmarket:getData', function()
    return {
        name = Blackmarket.name,
        currency = CURRENCY,
        interactDistance = Blackmarket.interactDistance,
        locations = serializeLocations(),
        items = serializeItems(),
    }
end)

lib.callback.register('cfx-keydi-utils:blackmarket:buy', function(source, locationId, itemId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return false, 'Player not found.'
    end

    if not Region.Allowed('illegal', src) then
        return false, Region.Message('illegal')
    end

    locationId = tonumber(locationId)
    if type(itemId) ~= 'string' or not locationId then
        return false, 'Invalid request.'
    end

    local loc = Blackmarket.locations[locationId]
    local entry = itemById[itemId]
    if not loc or not entry then
        return false, 'Unknown item.'
    end

    if not hasSection(loc.sections, entry.section) then
        return false, 'This spot does not sell that.'
    end

    if entry.locations then
        local allowed = false
        for i = 1, #entry.locations do
            if entry.locations[i] == locationId then
                allowed = true
                break
            end
        end
        if not allowed then
            return false, 'This spot does not sell that.'
        end
    end

    if not nearLocation(src, locationId) then
        return false, 'Too far from the blackmarket.'
    end

    local now = os.time()
    local cd = Blackmarket.cooldown or 3
    if cooldown[src] and (now - cooldown[src]) < cd then
        return false, 'Wait a moment.'
    end

    local price = math.floor(tonumber(entry.price) or 0)
    if price < 1 then
        return false, 'Invalid price.'
    end

    local dirty = Vars.ox:Search(src, 'count', CURRENCY) or 0
    if dirty < price then
        return false, ('Need $%s dirty money.'):format(ESX.Math.GroupDigits(price))
    end

    local canCarry = Vars.ox:CanCarryItem(src, entry.item, entry.count)
    if canCarry == false then
        return false, 'Not enough inventory space.'
    end

    if not Vars.ox:RemoveItem(src, CURRENCY, price) then
        return false, 'Could not take dirty money.'
    end

    if not Vars.ox:AddItem(src, entry.item, entry.count) then
        Vars.ox:AddItem(src, CURRENCY, price)
        return false, 'Could not give item. Refunded.'
    end

    cooldown[src] = now
    return true, entry.label, price
end)

AddEventHandler('playerDropped', function()
    cooldown[source] = nil
end)
