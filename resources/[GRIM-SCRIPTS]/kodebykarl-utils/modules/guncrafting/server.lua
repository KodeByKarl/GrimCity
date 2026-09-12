--[[
    Gun Crafting Module (Server)
    Workbench locations, prop objects, and crafting recipes live strictly server-side.
    Players consume raw materials and components to craft firearms, attachments, and ammo.
]]

local Vars = require 'helpers.vars'
local Region = require 'helpers.region'

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
            label = 'Gun Crafting Bench',
            coords = vec4(3310.6545, 5176.4243, 19.6146, 51.9649),
            model = 'gr_prop_gr_bench_02b',
            spawnProp = true,
            sections = { 'weapons' },
        },
    },

    -- Same cost for every firearm. Each craft yields 2 guns.
    recipes = {
        {
            id = 'craft_pistol',
            section = 'weapons',
            label = 'Pistol',
            description = 'Standard 9mm pistol. Crafts 2.',
            item = 'WEAPON_PISTOL',
            count = 2,
            craftTime = 7000,
            ingredients = {
                { item = 'gunpowder', label = 'Gunpowder', count = 5 },
                { item = 'copper', label = 'Copper', count = 5 },
                { item = 'car_blueprint', label = 'Blueprint', count = 2 },
            },
        },
        {
            id = 'craft_glock22',
            section = 'weapons',
            label = 'Glock 22',
            description = 'Glock 22 pistol. Crafts 2.',
            item = 'WEAPON_GLOCK22',
            count = 2,
            craftTime = 7000,
            ingredients = {
                { item = 'gunpowder', label = 'Gunpowder', count = 5 },
                { item = 'copper', label = 'Copper', count = 5 },
                { item = 'car_blueprint', label = 'Blueprint', count = 2 },
            },
        },
        {
            id = 'craft_appistol',
            section = 'weapons',
            label = 'AP Pistol',
            description = 'Fully automatic AP Pistol. Crafts 2.',
            item = 'WEAPON_APPISTOL',
            count = 2,
            craftTime = 8000,
            ingredients = {
                { item = 'gunpowder', label = 'Gunpowder', count = 5 },
                { item = 'copper', label = 'Copper', count = 5 },
                { item = 'car_blueprint', label = 'Blueprint', count = 2 },
            },
        },
        {
            id = 'craft_assaultrifle',
            section = 'weapons',
            label = 'Assault Rifle',
            description = 'Standard assault rifle. Crafts 2.',
            item = 'WEAPON_ASSAULTRIFLE',
            count = 2,
            craftTime = 9000,
            ingredients = {
                { item = 'gunpowder', label = 'Gunpowder', count = 5 },
                { item = 'copper', label = 'Copper', count = 5 },
                { item = 'car_blueprint', label = 'Blueprint', count = 2 },
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

    if not Region.Allowed('illegal', src) then
        return false, Region.Message('illegal')
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
