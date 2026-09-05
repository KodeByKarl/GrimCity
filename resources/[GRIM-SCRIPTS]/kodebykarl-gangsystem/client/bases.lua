local spawnedPeds = {}

local function Notify(msg, nType)
    lib.notify({ title = 'GANG', description = msg, type = nType or 'inform' })
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

local function SpawnClaimPed(gang)
    local pedCfg = gang.points and gang.points.claimPed
    if not pedCfg then return end

    local model = pedCfg.model
    lib.requestModel(model, 5000)
    local c = pedCfg.coords
    local ped = CreatePed(0, model, c.x, c.y, c.z, c.w or 0.0, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(model)
    spawnedPeds[#spawnedPeds + 1] = ped

    exports.ox_target:addLocalEntity(ped, {
        {
            name = ('kbk_claim_%s'):format(gang.id),
            icon = 'fa-solid fa-car',
            label = ('Claim %s Gang Car (1x)'):format(gang.label),
            distance = 2.2,
            onSelect = function()
                if not IsInGang(gang.id) then
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
                    TriggerServerEvent('kodebykarl-gangsystem:server:claimCar', gang.id)
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

        -- Base blip (always — base location). Redzones handled separately.
        if g.blip and g.redzone then
            local blip = AddBlipForCoord(g.redzone.coords.x, g.redzone.coords.y, g.redzone.coords.z)
            SetBlipSprite(blip, g.blip.sprite or 84)
            SetBlipColour(blip, g.blip.color or 1)
            SetBlipScale(blip, g.blip.scale or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(g.label .. ' Base')
            EndTextCommandSetBlipName(blip)
        end

        AddBoxTarget(('kbk_boss_%s'):format(g.id), p.bossStash, 'Boss Stash', 'fa-solid fa-vault', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            TriggerServerEvent('kodebykarl-gangsystem:server:openStash', g.id, 'boss')
        end)

        AddBoxTarget(('kbk_public_%s'):format(g.id), p.publicStash, 'Public Stash', 'fa-solid fa-box', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            TriggerServerEvent('kodebykarl-gangsystem:server:openStash', g.id, 'public')
        end)

        AddBoxTarget(('kbk_personal_%s'):format(g.id), p.personalStash, 'Personal Stash', 'fa-solid fa-locker', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            TriggerServerEvent('kodebykarl-gangsystem:server:openStash', g.id, 'personal')
        end)

        AddBoxTarget(('kbk_wardrobe_%s'):format(g.id), p.wardrobe, 'Wardrobe', 'fa-solid fa-shirt', function()
            if not IsInGang(g.id) then return Notify('Not your gang.', 'error') end
            OpenWardrobe()
        end)

        SpawnClaimPed(g)
        ::continue::
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for i = 1, #spawnedPeds do
        if DoesEntityExist(spawnedPeds[i]) then
            DeleteEntity(spawnedPeds[i])
        end
    end
end)
