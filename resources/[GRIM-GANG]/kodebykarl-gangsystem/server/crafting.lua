--[[
    Gang crafting benches — recipes: Config.GangCrafting (shared/crafting.lua)
    Locations: Config.Gangs[name].crafting.coords
]]

local ESX = exports['es_extended']:getSharedObject()

local function getBench(gangName)
    local key = Gang.NormalizeName(gangName)
    local gang = Config.Gangs and Config.Gangs[key]
    if not gang or not gang.crafting then return nil, key, gang end
    return gang.crafting, key, gang
end

local function nearCraftBench(src, bench)
    local cfg = Config.GangCrafting or {}
    if not bench or not bench.coords then
        return false, 'Crafting location is not set yet.'
    end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false, 'Invalid player.' end
    local p = GetEntityCoords(ped)
    local c = bench.coords
    local maxDist = (cfg.InteractDistance or 1.8) + 2.0
    if #(p - vec3(c.x, c.y, c.z)) > maxDist then
        return false, 'Too far from the crafting bench.'
    end
    return true
end

lib.callback.register('cfx-keydi-gang:crafting:checkMaterials', function(source, gangName, recipeId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not Gang.IsMember(xPlayer, gangName) then
        return {}
    end

    local recipe = GetGangCraftingRecipe(recipeId)
    if not recipe or not recipe.ingredients then return {} end

    local stock = {}
    for i = 1, #recipe.ingredients do
        local item = recipe.ingredients[i].item
        stock[item] = exports.ox_inventory:GetItemCount(source, item) or 0
    end
    return stock
end)

lib.callback.register('cfx-keydi-gang:crafting:craft', function(source, gangName, recipeId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, 'No player.' end
    if Gang.IsRateLimited(source, 1500) then return false, 'Slow down.' end
    if not Gang.IsMember(xPlayer, gangName) then
        return false, 'You are not a member of this gang.'
    end

    if not Config.GangCrafting or Config.GangCrafting.Enabled == false then
        return false, 'Gang crafting is disabled.'
    end

    local bench, key = getBench(gangName)
    if not bench then return false, 'Crafting not configured for this gang.' end

    local okNear, nearMsg = nearCraftBench(source, bench)
    if not okNear then return false, nearMsg end

    local recipe = GetGangCraftingRecipe(recipeId)
    if not recipe then return false, 'Unknown recipe.' end

    local ingredients = recipe.ingredients or {}
    for i = 1, #ingredients do
        local ing = ingredients[i]
        local have = exports.ox_inventory:GetItemCount(source, ing.item) or 0
        local need = tonumber(ing.count) or 1
        if have < need then
            return false, ('Missing materials (%s).'):format(ing.item)
        end
    end

    for i = 1, #ingredients do
        local ing = ingredients[i]
        local removed = exports.ox_inventory:RemoveItem(source, ing.item, tonumber(ing.count) or 1)
        if not removed then
            return false, 'Could not take materials.'
        end
    end

    local giveCount = tonumber(recipe.count) or 1
    local added = exports.ox_inventory:AddItem(source, recipe.item, giveCount)
    if not added then
        for i = 1, #ingredients do
            local ing = ingredients[i]
            exports.ox_inventory:AddItem(source, ing.item, tonumber(ing.count) or 1)
        end
        return false, 'Inventory full.'
    end

    return true, ('Crafted x%d %s'):format(giveCount, recipe.label or recipe.item)
end)
