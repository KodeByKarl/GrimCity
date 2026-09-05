--[[
  Pause-menu redzone radius blips — ONLY visible on Region 3 / 4 (turfwar function).
  Leaving to Region 1 / 2 removes them.
]]

local redzoneBlips = {}

local function CanShowTurfMap()
    if GetResourceState('kodebykarl-ui') ~= 'started' then
        return false
    end
    local ok, allowed = pcall(function()
        return exports['kodebykarl-ui']:HasFunction('turfwar')
    end)
    return ok and allowed == true
end

local function ClearRedzones()
    for i = 1, #redzoneBlips do
        local b = redzoneBlips[i]
        if b and DoesBlipExist(b) then
            RemoveBlip(b)
        end
    end
    redzoneBlips = {}
end

local function CreateRedzones()
    ClearRedzones()
    for i = 1, #Config.Gangs do
        local g = Config.Gangs[i]
        local rz = g.redzone
        if rz and rz.coords then
            local blip = AddBlipForRadius(rz.coords.x, rz.coords.y, rz.coords.z, rz.radius or 75.0)
            SetBlipColour(blip, rz.color or 1)
            SetBlipAlpha(blip, rz.alpha or 100)
            -- Not short-range so it shows on pause-menu map while in turf regions
            SetBlipAsShortRange(blip, false)
            redzoneBlips[#redzoneBlips + 1] = blip
        end
    end
end

local function RefreshRedzones()
    if CanShowTurfMap() then
        if #redzoneBlips == 0 then
            CreateRedzones()
        end
    else
        ClearRedzones()
    end
end

CreateThread(function()
    Wait(2000)
    RefreshRedzones()
    while true do
        Wait(3000)
        RefreshRedzones()
    end
end)

AddEventHandler('cfx-keydi-serverlocations:changed', function()
    Wait(250)
    RefreshRedzones()
end)

AddStateBagChangeHandler('grimServerId', ('player:%s'):format(GetPlayerServerId(PlayerId())), function()
    Wait(250)
    RefreshRedzones()
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        ClearRedzones()
    end
end)
