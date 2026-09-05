--[[
    Shared gang crafting catalog — same recipes for every gang.
    Per-gang bench location only: Config.Gangs[name].crafting.coords
]]

Config.GangCrafting = {
    Enabled = true,
    Label = 'Gang Crafting Bench',
    InteractDistance = 1.8,

    -- Adjust item names to match ox_inventory
    Recipes = {
        {
            id = 'lockpick',
            label = 'Lockpick',
            description = 'Basic lockpick',
            item = 'lockpick',
            count = 1,
            craftTime = 5000,
            ingredients = {
                { item = 'scrapmetal', count = 2 },
            },
        },
        {
            id = 'bandage',
            label = 'Bandage',
            description = 'Field bandage',
            item = 'bandage',
            count = 2,
            craftTime = 4000,
            ingredients = {
                { item = 'cloth', count = 1 },
            },
        },
    },
}

function GetGangCraftingRecipes()
    local cfg = Config.GangCrafting
    if not cfg or cfg.Enabled == false then return {} end
    return cfg.Recipes or {}
end

function GetGangCraftingRecipe(recipeId)
    local recipes = GetGangCraftingRecipes()
    for i = 1, #recipes do
        if recipes[i].id == recipeId then
            return recipes[i]
        end
    end
end
