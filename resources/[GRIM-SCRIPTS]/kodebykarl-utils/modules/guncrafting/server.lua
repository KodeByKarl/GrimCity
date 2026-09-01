--[[
    Gun Crafting Module (Server)
    Workbench locations, prop objects, and crafting recipes live strictly server-side.
    Players consume raw materials and components to craft firearms, attachments, and ammo.
]]

local Vars = require 'helpers.vars'

local cooldown = {}
local recipeById = {}
local locationById = {}

local GunCrafting = {
    name = 'guncrafting',
    interactDistance = 3.0,
    cooldown = 3,

    -- Server-side Workbenches & Locations
    locations = {
        {
            id = 1,
            label = 'Gun Crafting Bench — Cypress Flats Warehouse',
            coords = vec4(723.15, -1088.74, 22.17, 90.0),
            model = 'gr_prop_gr_bench_02b',
            spawnProp = true,
            sections = { 'pistols', 'attachments', 'ammo' },
        },
        {
            id = 2,
            label = 'Gun Crafting Bench — El Burro Scrapyard',
            coords = vec4(1424.78, -2579.92, 45.45, 180.0),
            model = 'prop_tool_bench02',
            spawnProp = true,
            sections = { 'pistols', 'attachments', 'ammo' },
        },
        {
            id = 3,
            label = 'Gun Crafting Bench — Sandy Shores Bunker',
            coords = vec4(2481.65, 4956.12, 44.82, 315.0),
            model = 'gr_prop_gr_bench_02b',
            spawnProp = true,
            sections = { 'pistols', 'attachments', 'ammo' },
        },
        {
            id = 4,
            label = 'Gun Crafting Bench — Paleto Sawmill Workshop',
            coords = vec4(-584.22, 5284.11, 70.26, 70.0),
            model = 'gr_prop_gr_bench_02b',
            spawnProp = true,
            sections = { 'pistols', 'attachments', 'ammo' },
        },
    },

    -- Server-side Crafting Catalog & Material Requirements
    recipes = {
        -- =============================================================
        -- PISTOLS
        -- =============================================================
        {
            id = 'craft_heavypistol',
            section = 'pistols',
            label = 'Heavy Pistol',
            description = 'High stopping power .45 semi-automatic handgun.',
            item = 'WEAPON_HEAVYPISTOL',
            count = 1,
            craftTime = 7500,
            ingredients = {
                { item = 'steel', label = 'Steel', count = 8 },
                { item = 'iron', label = 'Iron', count = 5 },
                { item = 'weapon_parts', label = 'Weapon Parts', count = 2 },
            },
        },
        {
            id = 'craft_pistol50',
            section = 'pistols',
            label = '.50 Pistol',
            description = 'Heavy caliber .50 Action Express handgun.',
            item = 'WEAPON_PISTOL50',
            count = 1,
            craftTime = 8000,
            ingredients = {
                { item = 'steel', label = 'Steel', count = 10 },
                { item = 'iron', label = 'Iron', count = 6 },
                { item = 'weapon_parts', label = 'Weapon Parts', count = 2 },
            },
        },
        {
            id = 'craft_g29',
            section = 'pistols',
            label = 'G29',
            description = 'Glock 29 compact tactical combat pistol.',
            item = 'WEAPON_COMBATPISTOL',
            count = 1,
            craftTime = 7000,
            ingredients = {
                { item = 'steel', label = 'Steel', count = 7 },
                { item = 'iron', label = 'Iron', count = 4 },
                { item = 'weapon_parts', label = 'Weapon Parts', count = 2 },
            },
        },
        {
            id = 'craft_deagle',
            section = 'pistols',
            label = 'Desert Deagle',
            description = 'High caliber Desert Eagle handgun.',
            item = 'WEAPON_PISTOL50',
            count = 1,
            craftTime = 8500,
            ingredients = {
                { item = 'steel', label = 'Steel', count = 12 },
                { item = 'aluminum', label = 'Aluminum', count = 6 },
                { item = 'weapon_parts', label = 'Weapon Parts', count = 3 },
            },
        },
        {
            id = 'craft_vintagepistol',
            section = 'pistols',
            label = 'Vintage Pistol',
            description = 'Classic vintage semi-automatic handgun.',
            item = 'WEAPON_VINTAGEPISTOL',
            count = 1,
            craftTime = 6500,
            ingredients = {
                { item = 'steel', label = 'Steel', count = 6 },
                { item = 'iron', label = 'Iron', count = 4 },
                { item = 'weapon_parts', label = 'Weapon Parts', count = 1 },
            },
        },
        {
            id = 'craft_pistolmk2',
            section = 'pistols',
            label = 'MK2',
            description = 'Upgraded tactical Pistol Mk II.',
            item = 'WEAPON_PISTOL_MK2',
            count = 1,
            craftTime = 9000,
            ingredients = {
                { item = 'steel', label = 'Steel', count = 10 },
                { item = 'aluminum', label = 'Aluminum', count = 5 },
                { item = 'weapon_parts', label = 'Weapon Parts', count = 3 },
            },
        },

        -- =============================================================
        -- ATTACHMENTS
        -- =============================================================
        {
            id = 'craft_suppressor',
            section = 'attachments',
            label = 'Weapon Suppressor',
            description = 'Reduces muzzle flash and gunfire noise.',
            item = 'at_suppressor_light',
            count = 1,
            craftTime = 5000,
            ingredients = {
                { item = 'aluminum', label = 'Aluminum', count = 5 },
                { item = 'steel', label = 'Steel', count = 3 },
            },
        },
        {
            id = 'craft_extendedclip',
            section = 'attachments',
            label = 'Extended Magazine',
            description = 'Increases firearm magazine capacity.',
            item = 'at_clip_extended_pistol',
            count = 1,
            craftTime = 4000,
            ingredients = {
                { item = 'steel', label = 'Steel', count = 4 },
                { item = 'spring', label = 'Spring', count = 2 },
            },
        },

        -- =============================================================
        -- AMMO
        -- =============================================================
        {
            id = 'craft_ammo_9mm',
            section = 'ammo',
            label = '9mm Ammo Box (50 rounds)',
            description = 'Standard pistol & SMG ammunition.',
            item = 'ammo-9',
            count = 50,
            craftTime = 3500,
            ingredients = {
                { item = 'copper', label = 'Copper', count = 3 },
                { item = 'lead', label = 'Lead', count = 2 },
            },
        },
        {
            id = 'craft_ammo_rifle',
            section = 'ammo',
            label = '5.56 Rifle Ammo Box (60 rounds)',
            description = 'Assault rifle ammunition.',
            item = 'ammo-rifle',
            count = 60,
            craftTime = 4500,
            ingredients = {
                { item = 'copper', label = 'Copper', count = 5 },
                { item = 'lead', label = 'Lead', count = 4 },
            },
        },
        {
            id = 'craft_ammo_shotgun',
            section = 'ammo',
            label = '12 Gauge Shells (30 shells)',
            description = 'Heavy shotgun ammunition.',
            item = 'ammo-shotgun',
            count = 30,
            craftTime = 4000,
            ingredients = {
                { item = 'copper', label = 'Copper', count = 4 },
                { item = 'lead', label = 'Lead', count = 3 },
            },
        },
    },
}

-- Index location & recipe maps
for i = 1, #GunCrafting.locations do
    local loc = GunCrafting.locations[i]
    locationById[loc.id] = loc
end

for i = 1, #GunCrafting.recipes do
    local rec = GunCrafting.recipes[i]
    recipeById[rec.id] = rec
end

local function serializeLocations()
    local out = {}
    for i = 1, #GunCrafting.locations do
        local loc = GunCrafting.locations[i]
        out[i] = {
            id = loc.id,
            label = loc.label,
            x = loc.coords.x,
            y = loc.coords.y,
            z = loc.coords.z,
            heading = loc.coords.w or 0.0,
            model = loc.model,
            spawnProp = loc.spawnProp,
            sections = loc.sections,
        }
    end
    return out
end

local function serializeRecipes()
    local out = {}
    for i = 1, #GunCrafting.recipes do
        local r = GunCrafting.recipes[i]
        out[i] = {
            id = r.id,
            section = r.section,
            label = r.label,
            description = r.description,
            item = r.item,
            count = r.count,
            craftTime = r.craftTime,
            ingredients = r.ingredients,
            locations = r.locations,
        }
    end
    return out
end

local function isPlayerNearLocation(src, locationId)
    local loc = locationById[locationId]
    if not loc then return false end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local coords = GetEntityCoords(ped)
    local c = loc.coords
    local maxDist = (GunCrafting.interactDistance or 3.0) + 3.0
    return #(coords - vec3(c.x, c.y, c.z)) <= maxDist
end

-- Return server config & catalog to client
lib.callback.register('cfx-keydi-utils:guncrafting:getData', function()
    return {
        name = GunCrafting.name,
        interactDistance = GunCrafting.interactDistance,
        locations = serializeLocations(),
        recipes = serializeRecipes(),
    }
end)

-- Return current player stock counts for recipe ingredients
lib.callback.register('cfx-keydi-utils:guncrafting:checkMaterials', function(source, recipeId)
    local src = source
    local recipe = recipeById[recipeId]
    if not recipe or not recipe.ingredients then
        return {}
    end

    local result = {}
    for i = 1, #recipe.ingredients do
        local ing = recipe.ingredients[i]
        local count = Vars.ox:Search(src, 'count', ing.item) or 0
        result[ing.item] = count
    end
    return result
end)

-- Execute crafting on server
lib.callback.register('cfx-keydi-utils:guncrafting:craft', function(source, locationId, recipeId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return false, 'Player not found.'
    end

    locationId = tonumber(locationId)
    if type(recipeId) ~= 'string' or not locationId then
        return false, 'Invalid crafting request.'
    end

    local loc = locationById[locationId]
    local recipe = recipeById[recipeId]
    if not loc or not recipe then
        return false, 'Unknown crafting recipe.'
    end

    -- Verify location distance
    if not isPlayerNearLocation(src, locationId) then
        return false, 'Too far from the crafting workbench.'
    end

    -- Verify cooldown
    local now = os.time()
    local cd = GunCrafting.cooldown or 3
    if cooldown[src] and (now - cooldown[src]) < cd then
        return false, 'Wait a moment before crafting again.'
    end

    -- Verify location restrictions if specified
    if recipe.locations then
        local allowed = false
        for i = 1, #recipe.locations do
            if recipe.locations[i] == locationId then
                allowed = true
                break
            end
        end
        if not allowed then
            return false, 'This workbench cannot craft that item.'
        end
    end

    -- Check required ingredients
    local missing = {}
    for i = 1, #recipe.ingredients do
        local ing = recipe.ingredients[i]
        local userCount = Vars.ox:Search(src, 'count', ing.item) or 0
        local needed = ing.count or 1
        if userCount < needed then
            missing[#missing + 1] = ('%s (%d/%d)'):format(ing.label or ing.item, userCount, needed)
        end
    end

    if #missing > 0 then
        return false, ('Missing materials: %s'):format(table.concat(missing, ', '))
    end

    -- Check carry capacity
    local canCarry = Vars.ox:CanCarryItem(src, recipe.item, recipe.count or 1)
    if canCarry == false then
        return false, 'Not enough inventory space for crafted item.'
    end

    -- Remove ingredients
    for i = 1, #recipe.ingredients do
        local ing = recipe.ingredients[i]
        Vars.ox:RemoveItem(src, ing.item, ing.count or 1)
    end

    -- Deliver crafted item
    if not Vars.ox:AddItem(src, recipe.item, recipe.count or 1) then
        -- Refund ingredients if giving item fails
        for i = 1, #recipe.ingredients do
            local ing = recipe.ingredients[i]
            Vars.ox:AddItem(src, ing.item, ing.count or 1)
        end
        return false, 'Failed to deliver crafted item. Materials refunded.'
    end

    cooldown[src] = now
    return true, recipe.label, recipe.count or 1
end)

AddEventHandler('playerDropped', function()
    cooldown[source] = nil
end)
