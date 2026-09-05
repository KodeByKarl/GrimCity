local spawnedPeds = {}
local claimEntries = {}
local streamerStarted = false

local FALLBACK_PED = `a_m_y_business_01`
local SPAWN_DIST = 80.0
local DESPAWN_DIST = 120.0

local function Notify(msg, nType)
    lib.notify({ title = 'GANG', description = msg, type = nType or 'inform' })
end

local function SafeRequestModel(model)
    local hash = type(model) == 'string' and joaat(model) or model
    if not hash or not IsModelInCdimage(hash) or not IsModelValid(hash) then
        hash = FALLBACK_PED
    end
    if HasModelLoaded(hash) then return hash end
    RequestModel(hash)
    local deadline = GetGameTimer() + 4000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do
        Wait(10)
    end
    if HasModelLoaded(hash) then return hash end
    if hash ~= FALLBACK_PED then
        return SafeRequestModel(FALLBACK_PED)
    end
    return nil
end

local function OpenWardrobe()
    if GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openClothingShop', false)
        return
    end
    Notify('Appearance resource not started.', 'error')
end

local function AddBoxTarget(name, coords, label, icon, onSelect)
    exports.ox_target:addBoxZone({
        name = name,
        coords = coords,
        size = vec3(1.4, 1.4, 2.2),
        rotation = 0,
        debug = Config.Debug,
        options = {
            {
                name = name .. '_opt',
                icon = icon,
                label = label,
                distance = 2.0,
                onSelect = onSelect,
            },
        },
    })
end

local function DeleteClaimPed(entry)
    if not entry then return end
    if entry.ped and DoesEntityExist(entry.ped) then
        pcall(function()
            exports.ox_target:removeLocalEntity(entry.ped)
        end)
        DeleteEntity(entry.ped)
    end
    entry.ped = nil
end

local function SpawnClaimPed(entry)
    if not entry or (entry.ped and DoesEntityExist(entry.ped)) then return end

    local model = SafeRequestModel(entry.model)
    if not model then return end

    local c = entry.coords
    local ped = CreatePed(0, model, c.x, c.y, c.z, c.w or 0.0, false, true)
    SetModelAsNoLongerNeeded(model)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    spawnedPeds[#spawnedPeds + 1] = ped
    entry.ped = ped

    exports.ox_target:addLocalEntity(ped, {
        {
            name = ('kbk_claim_%s'):format(entry.gangId),
            icon = 'fa-solid fa-car',
            label = ('Claim %s Gang Car (1x)'):format(entry.label),
            distance = 2.2,
            onSelect = function()
                if not IsInGang(entry.gangId) then
                    return Notify('You must be a hired member of this gang.', 'error')
                end
                local ok = lib.progressBar({
                    duration = Config.ClaimCooldownMs or 4000,
                    label = 'Signing gang vehicle papers...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                })
                if ok then
                    TriggerServerEvent('kodebykarl-gangsystem:server:claimCar', entry.gangId)
                end
            end,
        },
    })
end

CreateThread(function()
    for i = 1, #Config.Gangs do
        local g = Config.Gangs[i]
        local p = g.points
        if not p then goto continue end

        AddBoxTarget(('kbk_boss_%s'):format(g.id), p.bossStash, 'Boss Stash', 'fa-solid fa-vault', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            TriggerServerEvent('kodebykarl-gangsystem:server:openStash', g.id, 'boss')
        end)

        AddBoxTarget(('kbk_public_%s'):format(g.id), p.publicStash, 'Public Stash', 'fa-solid fa-box', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            TriggerServerEvent('kodebykarl-gangsystem:server:openStash', g.id, 'public')
        end)

        AddBoxTarget(('kbk_personal_%s'):format(g.id), p.personalStash, 'Personal Stash', 'fa-solid fa-box-archive', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            TriggerServerEvent('kodebykarl-gangsystem:server:openStash', g.id, 'personal')
        end)

        AddBoxTarget(('kbk_wardrobe_%s'):format(g.id), p.wardrobe, 'Wardrobe', 'fa-solid fa-shirt', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            OpenWardrobe()
        end)

        if p.claimPed and p.claimPed.coords then
            claimEntries[#claimEntries + 1] = {
                gangId = g.id,
                label = g.label,
                model = p.claimPed.model,
                coords = p.claimPed.coords,
                ped = nil,
            }
        end
        ::continue::
    end
end)

local function StartClaimPedStreamer()
    if streamerStarted then return end
    streamerStarted = true

    CreateThread(function()
        while streamerStarted do
            local pos = GetEntityCoords(PlayerPedId())
            for i = 1, #claimEntries do
                local entry = claimEntries[i]
                local c = entry.coords
                local dist = #(pos - vec3(c.x, c.y, c.z))
                if dist <= SPAWN_DIST then
                    SpawnClaimPed(entry)
                elseif dist >= DESPAWN_DIST then
                    DeleteClaimPed(entry)
                end
            end
            Wait(2000)
        end
    end)
end

-- Do not load gang peds during character select — they fight freemode streaming.
RegisterNetEvent('esx:playerLoaded', function()
    CreateThread(function()
        Wait(4000)
        StartClaimPedStreamer()
    end)
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateThread(function()
        Wait(2500)
        if LocalPlayer.state.playerLoaded or (ESX and ESX.PlayerLoaded) then
            StartClaimPedStreamer()
        end
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    streamerStarted = false
    for i = 1, #claimEntries do
        DeleteClaimPed(claimEntries[i])
    end
    for i = 1, #spawnedPeds do
        if DoesEntityExist(spawnedPeds[i]) then
            DeleteEntity(spawnedPeds[i])
        end
    end
end)
