--[[
  Gang map blips (named base + redzone radius) — ONLY visible on Region 3 / 4
  (turfwar function). Leaving to Region 1 / 2 removes them.
]]

local redzoneBlips = {}
local baseBlips = {}
local redzonesVisible = false

local function CanShowTurfMap()
    if GetResourceState('kodebykarl-ui') ~= 'started' then
        return false
    end
    local ok, allowed = pcall(function()
        return exports['kodebykarl-ui']:HasFunction('turfwar')
    end)
    return ok and allowed == true
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

local function CreateRedzones()
    ClearRedzones()
    for i = 1, #Config.Gangs do
        local g = Config.Gangs[i]
        local rz = g.redzone
        if rz and rz.coords then
            local radius = tonumber(rz.radius) or 150.0
            local blip = AddBlipForRadius(rz.coords.x, rz.coords.y, rz.coords.z, radius)
            -- Classic red 2D zone (color 1) unless gang overrides
            SetBlipColour(blip, rz.color or 1)
            SetBlipAlpha(blip, rz.alpha or 128)
            -- Visible on pause-menu map while in turf regions
            SetBlipAsShortRange(blip, false)
            redzoneBlips[#redzoneBlips + 1] = blip

            if g.blip then
                local named = AddBlipForCoord(rz.coords.x, rz.coords.y, rz.coords.z)
                SetBlipSprite(named, g.blip.sprite or 84)
                SetBlipColour(named, g.blip.color or 1)
                SetBlipScale(named, g.blip.scale or 0.8)
                SetBlipAsShortRange(named, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(g.label .. ' Base')
                EndTextCommandSetBlipName(named)
                baseBlips[#baseBlips + 1] = named
            end
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
    -- Force rebuild so radius/color always match config after region hop
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
