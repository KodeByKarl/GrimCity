local ESX = exports['es_extended']:getSharedObject()

local function createStationBlip()
    -- Blip is also created by kodebykarl-police when LawEnforcement.sheriff is enabled.
    -- Skip duplicate if police already owns it.
    if GetResourceState('kodebykarl-police') == 'started' then
        return
    end

    local blipCfg = ConfigSheriff.Station and ConfigSheriff.Station.Blip
    if not blipCfg or not blipCfg.Coords then return end

    local blip = AddBlipForCoord(blipCfg.Coords.x, blipCfg.Coords.y, blipCfg.Coords.z)
    SetBlipSprite(blip, blipCfg.Sprite or 60)
    SetBlipDisplay(blip, blipCfg.Display or 4)
    SetBlipScale(blip, blipCfg.Scale or 1.0)
    SetBlipColour(blip, blipCfg.Colour or 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipCfg.Label or ConfigSheriff.Label)
    EndTextCommandSetBlipName(blip)
end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

local function isSheriff()
    local job = (ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name)
    if not job then
        local pd = ESX.GetPlayerData()
        job = pd and pd.job and pd.job.name
    end
    return job == 'sheriff' or job == 'offsheriff'
end

local function openSheriffWardrobe()
    if not isSheriff() then
        ESX.ShowNotification('Only Sheriff personnel can access this wardrobe.', 'error')
        return
    end

    if GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
    else
        ESX.ShowNotification('Wardrobe opened.', 'info')
    end
end

local function setupWardrobe()
    local wardrobeCfg = ConfigSheriff.Station and ConfigSheriff.Station.Wardrobe
    if not wardrobeCfg or not wardrobeCfg.coords then return end

    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addBoxZone({
            coords = wardrobeCfg.coords,
            size = wardrobeCfg.size or vector3(1.2, 2.0, 2.5),
            rotation = wardrobeCfg.heading or 0.0,
            debug = false,
            options = {
                {
                    name = 'sheriff_wardrobe',
                    icon = (wardrobeCfg.target and wardrobeCfg.target.icon) or wardrobeCfg.icon or 'fa-solid fa-shirt',
                    label = (wardrobeCfg.target and wardrobeCfg.target.label) or wardrobeCfg.label or 'Sheriff Wardrobe',
                    groups = { ['sheriff'] = 0, ['offsheriff'] = 0 },
                    onSelect = function()
                        openSheriffWardrobe()
                    end,
                    distance = (wardrobeCfg.target and wardrobeCfg.target.distance) or wardrobeCfg.distance or 2.0
                }
            }
        })
    end

    local point = lib.points.new({
        coords = wardrobeCfg.coords,
        distance = 1.8,
    })

    function point:onEnter()
        if isSheriff() then
            lib.showTextUI('[E] - Sheriff Wardrobe', { icon = 'tshirt', position = 'right-center' })
        end
    end

    function point:onExit()
        lib.hideTextUI()
    end

    function point:nearby()
        if isSheriff() then
            if IsControlJustReleased(0, 38) then -- E key
                openSheriffWardrobe()
            end
        end
    end
end

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(200) end
    ESX.PlayerData = ESX.GetPlayerData()
    createStationBlip()
    setupWardrobe()
end)

-- F6 / LEO tools live on kodebykarl-police (HasGroup includes sheriff).
-- Alias so other scripts can open the sheriff menu the same way.
RegisterNetEvent('cfx-cs-sheriff:client:openQuickMenu', function()
    TriggerEvent('cfx-cs-police:client:openQuickMenu')
end)

exports('OpenQuickMenu', function()
    TriggerEvent('cfx-cs-police:client:openQuickMenu')
end)

RegisterNetEvent('cfx-cs-sheriff:client:openWardrobe', function()
    openSheriffWardrobe()
end)

exports('OpenWardrobe', openSheriffWardrobe)
