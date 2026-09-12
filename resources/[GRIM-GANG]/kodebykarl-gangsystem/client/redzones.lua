--[[
  Gang map blips (named base + redzone radius) — Region 1 only (gangbase).
  TrapHouse is Region 3 / 4. Leaving Region 1 removes these blips.
]]

local redzoneBlips = {}
local baseBlips = {}
local redzonesVisible = false

local function CanShowTurfMap()
    return GangRegion.Allowed()
end

local function RemoveBlipList(list)
    for i = 1, #list do
        local b = list[i]
        if b and DoesBlipExist(b) then
            RemoveBlip(b)
        end
    end
end

local function ClearRedzones()
    RemoveBlipList(redzoneBlips)
    RemoveBlipList(baseBlips)
    redzoneBlips = {}
    baseBlips = {}
    redzonesVisible = false
end

local function GangBlipCoords(g)
    local coords = (g.wardrobe and g.wardrobe.coords)
        or (g.stashes and g.stashes.public and g.stashes.public.coords)
        or (g.crafting and g.crafting.coords)
        or (g.vehicle and g.vehicle.coords)
    if not coords then return nil end
    if (tonumber(coords.x) or 0) == 0.0 and (tonumber(coords.y) or 0) == 0.0 then
        return nil
    end
    return coords
end

local function CreateRedzones()
    ClearRedzones()
    for _, g in pairs(Config.Gangs or {}) do
        local coords = GangBlipCoords(g)
        if coords then
            local radius = tonumber(g.redzoneRadius) or 150.0
            local blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)
            SetBlipColour(blip, g.primaryColor or 1)
            SetBlipAlpha(blip, 110)
            SetBlipAsShortRange(blip, false)
            redzoneBlips[#redzoneBlips + 1] = blip

            local named = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(named, 84)
            SetBlipColour(named, g.primaryColor or 1)
            SetBlipScale(named, 0.85)
            SetBlipAsShortRange(named, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName((g.label or 'Gang') .. ' Base')
            EndTextCommandSetBlipName(named)
            baseBlips[#baseBlips + 1] = named
        end
    end
    redzonesVisible = (#redzoneBlips > 0) or (#baseBlips > 0)
end

local function RefreshRedzones()
    local allow = CanShowTurfMap()
    if allow and not redzonesVisible then
        CreateRedzones()
    elseif not allow and redzonesVisible then
        ClearRedzones()
    end
end

CreateThread(function()
    Wait(2000)
    RefreshRedzones()
    while true do
        Wait(2000)
        RefreshRedzones()
    end
end)

AddEventHandler('cfx-keydi-serverlocations:changed', function()
    Wait(250)
    ClearRedzones()
    RefreshRedzones()
end)

AddStateBagChangeHandler('grimServerId', ('player:%s'):format(GetPlayerServerId(PlayerId())), function()
    Wait(250)
    ClearRedzones()
    RefreshRedzones()
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        ClearRedzones()
    end
end)
