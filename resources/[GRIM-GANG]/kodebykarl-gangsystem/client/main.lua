local ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer or {}
end)

RegisterNetEvent('esx:setGang', function(gang)
    PlayerData.gang = gang
end)

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

local function getPlayerGang()
    local gang = PlayerData.gang
    if gang and gang.name then return gang end

    local stateGang = LocalPlayer.state.gang
    if stateGang and stateGang.name then
        PlayerData.gang = stateGang
        return stateGang
    end

    PlayerData = ESX.GetPlayerData() or PlayerData
    return PlayerData.gang
end

local function isGangMember(gangName)
    local gang = getPlayerGang()
    return gang and gang.name == gangName
end

local function isGangBoss(gangName, minGrade)
    local gang = getPlayerGang()
    if not gang or gang.name ~= gangName then return false end
    local name = gang.grade_name and string.lower(tostring(gang.grade_name)):gsub('%s+', '_') or ''
    if name == 'boss' or name == 'patron' or name == 'patrona' or name == 'el_patron'
        or name == 'underboss' or name == 'supremo' or name == 'pioneers' or name == 'forensics' or name == 'detective' then
        return true
    end
    return (tonumber(gang.grade) or 0) >= (minGrade or 1)
end

local function releaseUi()
    lib.hideContext()
    lib.hideTextUI()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    TriggerEvent('illenium-appearance:client:forceClose')
    Wait(150)
end

local function requestOpenStash(gangName, stashKey)
    releaseUi()
    TriggerServerEvent('cfx-keydi-gang:server:openStash', gangName, stashKey)
end

local function openStashMenu(gang)
    if not isGangMember(gang.name) then
        ESX.ShowNotification('You are not a member of ' .. gang.label .. '!', 'error')
        return
    end

    local options = {}
    for stashKey, stash in pairs(gang.stashes) do
        if stashKey ~= 'boss' then
            options[#options + 1] = {
                title = stash.label,
                description = stash.owner and 'Personal stash (only you can see this)' or 'Shared gang stash',
                icon = stash.owner and 'lock' or 'box-open',
                onSelect = function()
                    if not isGangMember(gang.name) then
                        ESX.ShowNotification('You do not have access to this stash!', 'error')
                        return
                    end
                    requestOpenStash(gang.name, stashKey)
                end
            }
        end
    end

    if #options == 0 then
        ESX.ShowNotification('No stashes available for you.', 'error')
        return
    end

    lib.registerContext({
        id = 'gang_stash_menu_' .. gang.name,
        title = gang.label .. ' - Stashes',
        options = options
    })
    lib.showContext('gang_stash_menu_' .. gang.name)
end

local function openBossStash(gang)
    if isGangBoss(gang.name, gang.bossGrade) then
        requestOpenStash(gang.name, 'boss')
    else
        ESX.ShowNotification('You do not have boss access!', 'error')
    end
end

-- Discord hire character picker (used by iPad Organization / hireByDiscord flow)
RegisterNetEvent('cfx-keydi-gang:client:pickDiscordCharacter', function(gangName, discordId, characters)
    if type(characters) ~= 'table' or #characters == 0 then return end

    local options = {}
    for i = 1, #characters do
        local char = characters[i]
        options[#options + 1] = {
            title = char.name or ('Character ' .. i),
            description = 'Identifier: ' .. tostring(char.identifier),
            icon = 'user',
            onSelect = function()
                TriggerServerEvent('cfx-keydi-gang:server:hireByDiscord', gangName, discordId, char.identifier)
            end
        }
    end

    lib.registerContext({
        id = 'gang_hire_discord_chars_' .. tostring(gangName),
        title = 'Select Character to Hire',
        options = options
    })
    lib.showContext('gang_hire_discord_chars_' .. tostring(gangName))
end)

local function openWardrobe(gang)
    if not isGangMember(gang.name) then
        ESX.ShowNotification('You are not a member of ' .. gang.label .. '!', 'error')
        return
    end

    releaseUi()

    if GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
    else
        ESX.ShowNotification('Wardrobe opened.', 'info')
    end
end

local function openCrafting(gang)
    if not isGangMember(gang.name) then
        ESX.ShowNotification('You are not a member of ' .. gang.label .. '!', 'error')
        return
    end

    if not gang.crafting then
        ESX.ShowNotification('Crafting is not set up for this gang.', 'error')
        return
    end

    local shared = Config.GangCrafting
    if not shared or shared.Enabled == false then
        ESX.ShowNotification('Gang crafting is disabled.', 'error')
        return
    end

    local recipes = GetGangCraftingRecipes()
    if #recipes == 0 then
        ESX.ShowNotification('No crafting recipes configured yet.', 'info')
        return
    end

    local options = {}
    for i = 1, #recipes do
        local r = recipes[i]
        local stock = lib.callback.await('cfx-keydi-gang:crafting:checkMaterials', false, gang.name, r.id) or {}
        local parts = {}
        local canCraft = true
        if r.ingredients then
            for j = 1, #r.ingredients do
                local ing = r.ingredients[j]
                local have = tonumber(stock[ing.item]) or 0
                local need = tonumber(ing.count) or 1
                if have < need then canCraft = false end
                parts[#parts + 1] = ('%s %d/%d'):format(ing.item, have, need)
            end
        end

        local desc = r.description or ''
        if #parts > 0 then
            desc = (desc ~= '' and (desc .. '\n') or '') .. 'Needs: ' .. table.concat(parts, ', ')
        end

        options[#options + 1] = {
            title = r.label or r.id,
            description = desc,
            icon = canCraft and 'fa-solid fa-hammer' or 'fa-solid fa-circle-xmark',
            disabled = not canCraft,
            onSelect = function()
                local ok = lib.progressBar({
                    duration = r.craftTime or 5000,
                    label = ('Crafting %s…'):format(r.label or r.id),
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_ped',
                        flag = 49,
                    },
                })
                if not ok then
                    ESX.ShowNotification('Crafting cancelled.', 'error')
                    return
                end

                local success, msg = lib.callback.await('cfx-keydi-gang:crafting:craft', false, gang.name, r.id)
                if success then
                    ESX.ShowNotification(msg or 'Crafted successfully.', 'success')
                else
                    ESX.ShowNotification(msg or 'Crafting failed.', 'error')
                end
            end,
        }
    end

    lib.registerContext({
        id = 'gang_crafting_' .. gang.name,
        title = shared.Label or (gang.label .. ' Crafting'),
        options = options,
    })
    lib.showContext('gang_crafting_' .. gang.name)
end

local function spawnGangVehicle(gang)
    if not isGangMember(gang.name) then
        ESX.ShowNotification('You are not a member of ' .. gang.label .. '!', 'error')
        return
    end

    local vData = gang.vehicle
    local spawnCoords = vData.vec or vec3(vData.coords.x, vData.coords.y, vData.coords.z)

    if IsAnyVehicleNearPoint(spawnCoords.x, spawnCoords.y, spawnCoords.z, 3.0) then
        ESX.ShowNotification('Vehicle spawn area is blocked!', 'error')
        return
    end

    ESX.Game.SpawnVehicle(vData.model, spawnCoords, vData.coords.w, function(vehicle)
        SetEntityHeading(vehicle, vData.coords.w)
        if gang.rgbColor then
            SetVehicleCustomPrimaryColour(vehicle, gang.rgbColor.r, gang.rgbColor.g, gang.rgbColor.b)
            SetVehicleCustomSecondaryColour(vehicle, gang.rgbColor.r, gang.rgbColor.g, gang.rgbColor.b)
        end
        SetVehicleColours(vehicle, gang.primaryColor or 145, gang.secondaryColor or 145)
        SetVehicleNumberPlateText(vehicle, string.upper(string.sub(gang.name, 1, 4)) .. math.random(10, 99))
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        ESX.ShowNotification(vData.label .. ' spawned!', 'success')
    end)
end

local function storeGangVehicle(gang)
    if not isGangMember(gang.name) then return end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        vehicle = ESX.Game.GetVehicleInDirection()
    end

    if DoesEntityExist(vehicle) then
        ESX.Game.DeleteVehicle(vehicle)
        ESX.ShowNotification('Gang vehicle stored!', 'success')
    else
        ESX.ShowNotification('No vehicle nearby to store!', 'error')
    end
end

local function isTurfRegion()
    return GangRegion.Allowed()
end

local function addGangPoint(coords, distance, text, canUse, onUse, extraControl)
    if not coords then return end
    local point = lib.points.new({ coords = coords, distance = distance or 1.5 })

    function point:onEnter()
        if isTurfRegion() and canUse() then
            lib.showTextUI(text)
        end
    end

    function point:onExit()
        lib.hideTextUI()
    end

    function point:nearby()
        if not isTurfRegion() then return end
        if IsControlJustReleased(0, 38) then
            if not canUse() then return end
            onUse(38)
        elseif extraControl and IsControlJustReleased(0, extraControl) then
            if not canUse() then return end
            onUse(extraControl)
        end
    end
end

CreateThread(function()
    for _, gang in pairs(Config.Gangs) do
        local stashes = gang.stashes
        if stashes and stashes.public and stashes.public.vec then
            addGangPoint(stashes.public.vec, 1.5, '[E] - Access Gang Stashes', function()
                return isGangMember(gang.name)
            end, function()
                openStashMenu(gang)
            end)
        end

        if stashes and stashes.boss and stashes.boss.vec then
            addGangPoint(stashes.boss.vec, 1.5, '[E] - Boss Stash', function()
                return isGangBoss(gang.name, gang.bossGrade)
            end, function()
                openBossStash(gang)
            end)
        end

        if gang.wardrobe and gang.wardrobe.vec then
            addGangPoint(gang.wardrobe.vec, 1.5, '[E] - Wardrobe', function()
                return isGangMember(gang.name)
            end, function()
                openWardrobe(gang)
            end)
        end

        if gang.vehicle and gang.vehicle.vec then
            addGangPoint(gang.vehicle.vec, 2.5, '[E] - Garage / [G] - Store Vehicle', function()
                return isGangMember(gang.name)
            end, function(control)
                if control == 38 then
                    spawnGangVehicle(gang)
                else
                    storeGangVehicle(gang)
                end
            end, 47)
        end

        if gang.crafting and gang.crafting.vec then
            local dist = (Config.GangCrafting and Config.GangCrafting.InteractDistance) or 1.8
            addGangPoint(gang.crafting.vec, dist, '[E] - Gang Crafting', function()
                return isGangMember(gang.name)
            end, function()
                openCrafting(gang)
            end)
        end
    end
end)

AddEventHandler('cfx-keydi-serverlocations:changed', function()
    lib.hideTextUI()
    if not isTurfRegion() then
        lib.hideContext()
    end
end)

AddStateBagChangeHandler('grimServerId', ('player:%s'):format(GetPlayerServerId(PlayerId())), function()
    lib.hideTextUI()
    if not isTurfRegion() then
        lib.hideContext()
    end
end)
