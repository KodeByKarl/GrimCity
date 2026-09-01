--[[
    Raven - Pig Slaughter / Hunting
    One-file module (client + server via IsDuplicityVersion).
]]

ConfigRaven = {
    Debug = false,

    Ped = {
        model = "a_m_m_farmer_01",
        coords = vec4(-2091.3125, 2640.1421, 2.8954, 20.3600),
        scenario = "WORLD_HUMAN_CLIPBOARD",
    },

    Blip = {
        label = "Raven Pig Farm",
        sprite = 141,
        color = 1,
        scale = 0.85,
        shortRange = true,
    },

    Pig = {
        model = "a_c_pig",
        coords = vec4(-2108.3953, 2663.3638, 2.8277, 32.0394),
        count = 15,
        spawnRadius = 12.0,
    },

    RequiredWeapon = "WEAPON_KNIFE",
    RewardItem = "raw_meat",
    RewardMin = 1,
    RewardMax = 3,
    ToolUses = 100, -- harvests before knife breaks (-1 durability per harvest)

    HuntZoneRadius = 75.0,
    HarvestDistance = 2.5,
    HarvestDuration = 4000,
}

local function CanUseRaven(src)
    if type(ConfigServerLocations) ~= "table" or not ConfigServerLocations.CanUseFunction then
        return true
    end
    if IsDuplicityVersion() then
        return ConfigServerLocations.CanUseFunction("grind", src) or ConfigServerLocations.CanUseFunction("raven", src)
    end
    return ConfigServerLocations.CanUseFunction("grind") or ConfigServerLocations.CanUseFunction("raven")
end

local function DebugLog(msg)
    if ConfigRaven.Debug then
        print(("[Raven] %s"):format(msg))
    end
end

if IsDuplicityVersion() then
    ---------------------------------------------------------------------------
    -- SERVER
    ---------------------------------------------------------------------------
    local hunters = {}          -- [src] = true after startHunt at the farm
    local pendingHarvest = {}   -- [src] = GetGameTimer() when beginHarvest accepted

    local function IsNearPigFarm(src)
        local ped = GetPlayerPed(src)
        if not ped or ped == 0 then return false end
        local playerCoords = GetEntityCoords(ped)
        local pig = ConfigRaven.Pig.coords
        local farmer = ConfigRaven.Ped.coords
        local pigCenter = vector3(pig.x, pig.y, pig.z)
        local npcPos = vector3(farmer.x, farmer.y, farmer.z)
        local zone = ConfigRaven.HuntZoneRadius or 75.0
        return #(playerCoords - pigCenter) <= zone or #(playerCoords - npcPos) <= 12.0
    end

    local function HasKnife(src)
        local count = exports.ox_inventory:Search(src, "count", ConfigRaven.RequiredWeapon) or 0
        if type(count) == "table" then
            count = count[ConfigRaven.RequiredWeapon] or 0
        end
        if (tonumber(count) or 0) > 0 then return true end

        local countItem = exports.ox_inventory:Search(src, "count", "knife") or 0
        if type(countItem) == "table" then
            countItem = countItem["knife"] or 0
        end
        return (tonumber(countItem) or 0) > 0
    end

    local function WearKnife(src)
        local targetItem = ConfigRaven.RequiredWeapon
        local slots = exports.ox_inventory:Search(src, "slots", targetItem)
        local slot = nil
        if type(slots) == "table" then
            for _, entry in pairs(slots) do
                if type(entry) == "table" and entry.slot then
                    slot = entry
                    break
                end
            end
        end

        if not slot then
            targetItem = "knife"
            slots = exports.ox_inventory:Search(src, "slots", targetItem)
            if type(slots) == "table" then
                for _, entry in pairs(slots) do
                    if type(entry) == "table" and entry.slot then
                        slot = entry
                        break
                    end
                end
            end
        end

        if not slot then return false, false end

        local uses = tonumber(ConfigRaven.ToolUses) or 100
        if uses < 1 then uses = 100 end
        local drain = 100 / uses

        local dur = slot.metadata and slot.metadata.durability
        if type(dur) ~= "number" then
            dur = 100
        end

        dur = dur - drain
        if dur <= 0 then
            exports.ox_inventory:RemoveItem(src, targetItem, 1, nil, slot.slot)
            return true, true
        end

        exports.ox_inventory:SetDurability(src, slot.slot, dur)
        return true, false
    end

    lib.callback.register("cfx-keydi-raven:canStart", function(source)
        if not CanUseRaven(source) then
            return false, "wrong_server"
        end
        local ok, hasKnife = pcall(HasKnife, source)
        if not ok or not hasKnife then
            return false, "knife"
        end
        if not IsNearPigFarm(source) then
            return false, "distance"
        end
        return true
    end)

    lib.callback.register("cfx-keydi-raven:startHunt", function(src)
        if type(src) ~= "number" or src < 1 then return false, "invalid" end
        if not CanUseRaven(src) then return false, "wrong_server" end
        if not IsNearPigFarm(src) then return false, "distance" end
        local ok, hasKnife = pcall(HasKnife, src)
        if not ok or not hasKnife then return false, "knife" end
        hunters[src] = true
        pendingHarvest[src] = nil
        return true
    end)

    RegisterNetEvent("cfx-keydi-raven:stopHunt", function()
        local src = source
        hunters[src] = nil
        pendingHarvest[src] = nil
    end)

    lib.callback.register("cfx-keydi-raven:beginHarvest", function(src)
        if type(src) ~= "number" or src < 1 then return false end
        if not hunters[src] then return false end
        if not IsNearPigFarm(src) then
            hunters[src] = nil
            pendingHarvest[src] = nil
            return false
        end
        local ok, hasKnife = pcall(HasKnife, src)
        if not ok or not hasKnife then return false end

        local now = GetGameTimer()
        local pending = pendingHarvest[src]
        local duration = ConfigRaven.HarvestDuration or 4000
        if pending and (now - pending) < (duration * 3) then
            return false
        end

        pendingHarvest[src] = now
        return true
    end)

    RegisterNetEvent("cfx-keydi-raven:harvest", function()
        local src = source
        if type(src) ~= "number" or src < 1 then return end

        if not hunters[src] then
            KeydiElectron.Flag(src, "Raven harvest exploit (no hunt session)", "cfx-keydi-raven")
            return
        end

        local started = pendingHarvest[src]
        if not started then
            KeydiElectron.Flag(src, "Raven harvest exploit (no begin)", "cfx-keydi-raven")
            return
        end

        local duration = ConfigRaven.HarvestDuration or 4000
        if (GetGameTimer() - started) < (duration - 400) then
            KeydiElectron.Flag(src, "Raven harvest exploit (skipped wait)", "cfx-keydi-raven")
            return
        end
        pendingHarvest[src] = nil

        if not IsNearPigFarm(src) then
            hunters[src] = nil
            TriggerClientEvent("cfx-keydi-raven:notify", src, "Too far from the pig farm.", "error")
            return
        end

        if not HasKnife(src) then
            TriggerClientEvent("cfx-keydi-raven:notify", src, "You need a knife to harvest meat.", "error")
            return
        end

        local amount = math.random(ConfigRaven.RewardMin, ConfigRaven.RewardMax)
        local canCarry = exports.ox_inventory:CanCarryAmount(src, ConfigRaven.RewardItem) or 0
        if canCarry < 1 then
            TriggerClientEvent("cfx-keydi-raven:notify", src, "You cannot carry any more raw meat.", "error")
            return
        end
        if amount > canCarry then
            amount = canCarry
        end

        local added = exports.ox_inventory:AddItem(src, ConfigRaven.RewardItem, amount)
        if added then
            local _, broken = WearKnife(src)
            if broken then
                TriggerClientEvent("cfx-keydi-raven:notify", src, ("You harvested %dx Raw Meat — your knife broke."):format(amount), "error")
            else
                TriggerClientEvent("cfx-keydi-raven:notify", src, ("You harvested %dx Raw Meat"):format(amount), "success")
            end
            TriggerClientEvent("cfx-keydi-raven:harvested", src)
        else
            TriggerClientEvent("cfx-keydi-raven:notify", src, "Failed to add raw meat.", "error")
        end
    end)

    CreateThread(function()
        while true do
            Wait(2000)
            for src in pairs(hunters) do
                if not IsNearPigFarm(src) then
                    hunters[src] = nil
                    pendingHarvest[src] = nil
                end
            end
        end
    end)

    AddEventHandler("playerDropped", function()
        local src = source
        hunters[src] = nil
        pendingHarvest[src] = nil
    end)
else
    ---------------------------------------------------------------------------
    -- CLIENT
    ---------------------------------------------------------------------------
    local ESX = exports["es_extended"]:getSharedObject()

    local npcPed = nil
    local farmBlip = nil
    local farmerTargetZone = nil
    local hunting = false
    local harvesting = false
    local pigs = {} -- { entity = number, dead = bool, targeted = bool }

    local function Notify(msg, nType)
        ESX.ShowNotification(msg, nType or "info")
    end

    local function PlayerHasKnife()
        local weapon = ConfigRaven.RequiredWeapon
        local items
        pcall(function()
            items = exports.ox_inventory:GetPlayerItems()
        end)
        if type(items) == "table" then
            for _, item in pairs(items) do
                if type(item) == "table" and (item.name == weapon or item.name == "knife") then
                    local dur = item.metadata and item.metadata.durability
                    if dur == nil or (type(dur) == "number" and dur > 0) then
                        return true
                    end
                end
            end
        end

        local count = 0
        pcall(function()
            count = exports.ox_inventory:Search("count", weapon) or 0
        end)
        if type(count) == "table" then
            count = count[weapon] or 0
        end
        if (tonumber(count) or 0) > 0 then return true end

        count = 0
        pcall(function()
            count = exports.ox_inventory:Search("count", "knife") or 0
        end)
        if type(count) == "table" then
            count = count["knife"] or 0
        end
        return (tonumber(count) or 0) > 0
    end

    RegisterNetEvent("cfx-keydi-raven:notify", function(msg, nType)
        Notify(msg, nType)
    end)

    local function LoadModel(model)
        local hash = type(model) == "number" and model or joaat(model)
        if not IsModelInCdimage(hash) then return nil end
        RequestModel(hash)
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(hash) and GetGameTimer() < timeout do
            Wait(10)
        end
        if not HasModelLoaded(hash) then return nil end
        return hash
    end

    local function RandomPigCoords()
        local center = ConfigRaven.Pig.coords
        local radius = ConfigRaven.Pig.spawnRadius or 12.0
        local angle = math.random() * math.pi * 2
        local dist = math.random() * radius
        local x = center.x + math.cos(angle) * dist
        local y = center.y + math.sin(angle) * dist
        local z = center.z
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 5.0, false)
        if found and groundZ and math.abs(groundZ - z) < 8.0 then
            z = groundZ
        end
        return x, y, z, math.random(0, 359) + 0.0
    end

    local function CountLivingPigs()
        local count = 0
        for _, pig in ipairs(pigs) do
            if pig.entity and DoesEntityExist(pig.entity) and not IsEntityDead(pig.entity) then
                count = count + 1
            end
        end
        return count
    end

    local function SpawnPig()
        local hash = LoadModel(ConfigRaven.Pig.model)
        if not hash then
            DebugLog("failed to load pig model")
            return nil
        end

        local x, y, z, heading = RandomPigCoords()
        local ped = CreatePed(28, hash, x, y, z, heading, false, true)
        if not ped or ped == 0 then
            SetModelAsNoLongerNeeded(hash)
            return nil
        end

        SetEntityAsMissionEntity(ped, true, true)
        SetPedFleeAttributes(ped, 0, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanRagdoll(ped, true)
        SetEntityHealth(ped, 200)

        local center = ConfigRaven.Pig.coords
        TaskWanderInArea(ped, center.x, center.y, center.z, ConfigRaven.Pig.spawnRadius or 12.0, 2.0, 3.0)
        SetModelAsNoLongerNeeded(hash)

        pigs[#pigs + 1] = {
            entity = ped,
            dead = false,
            targeted = false,
        }

        return ped
    end

    local function EnsurePigCount()
        local living = CountLivingPigs()
        local needed = ConfigRaven.Pig.count - living
        for _ = 1, needed do
            SpawnPig()
        end
    end

    local function CleanupPig(index)
        local pig = pigs[index]
        if not pig then return end

        if pig.entity and DoesEntityExist(pig.entity) then
            if pig.targeted then
                pcall(function()
                    exports.ox_target:removeLocalEntity(pig.entity)
                end)
            end
            DeleteEntity(pig.entity)
        end

        table.remove(pigs, index)
    end

    local function ClearAllPigs()
        for i = #pigs, 1, -1 do
            CleanupPig(i)
        end
        pigs = {}
    end

    local function StopHunting(silent)
        if not hunting then return end
        hunting = false
        harvesting = false
        ClearAllPigs()
        TriggerServerEvent("cfx-keydi-raven:stopHunt")
        if not silent then
            Notify("Pig hunting stopped.", "info")
        end
    end

    local function StartHarvest(entity)
        if harvesting or not hunting then return end
        if not entity or not DoesEntityExist(entity) then return end
        if not IsEntityDead(entity) then
            Notify("The pig is still alive.", "error")
            return
        end

        local playerPed = PlayerPedId()
        if #(GetEntityCoords(playerPed) - GetEntityCoords(entity)) > ConfigRaven.HarvestDistance + 1.0 then
            Notify("Move closer to the pig.", "error")
            return
        end

        local hasKnife = PlayerHasKnife()
        if not hasKnife then
            Notify("You need a knife to harvest meat.", "error")
            return
        end

        harvesting = true

        local began = lib.callback.await("cfx-keydi-raven:beginHarvest", false)
        if not began then
            harvesting = false
            Notify("You cannot harvest right now.", "error")
            return
        end

        GiveWeaponToPed(playerPed, joaat(ConfigRaven.RequiredWeapon), 0, false, true)
        SetCurrentPedWeapon(playerPed, joaat(ConfigRaven.RequiredWeapon), true)

        local success = lib.progressBar({
            duration = ConfigRaven.HarvestDuration,
            label = "Harvesting raw meat…",
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = "amb@medic@standing@kneel@base",
                clip = "base",
            },
        })

        if not success or not hunting then
            harvesting = false
            ClearPedTasks(playerPed)
            return
        end

        TriggerServerEvent("cfx-keydi-raven:harvest")

        for i = #pigs, 1, -1 do
            local pig = pigs[i]
            if pig.entity == entity then
                if pig.targeted then
                    pcall(function()
                        exports.ox_target:removeLocalEntity(entity)
                    end)
                end
                if DoesEntityExist(entity) then
                    DeleteEntity(entity)
                end
                table.remove(pigs, i)
                break
            end
        end

        EnsurePigCount()
        harvesting = false
    end

    local function AddHarvestTarget(pigIndex)
        local pig = pigs[pigIndex]
        if not pig or pig.targeted or not pig.entity or not DoesEntityExist(pig.entity) then return end

        local entity = pig.entity
        pig.targeted = true
        exports.ox_target:addLocalEntity(entity, {
            {
                name = ("raven_harvest_%s"):format(entity),
                icon = "fa-solid fa-drumstick-bite",
                label = "Harvest Raw Meat",
                distance = ConfigRaven.HarvestDistance,
                canInteract = function()
                    return hunting and not harvesting and DoesEntityExist(entity) and IsEntityDead(entity)
                end,
                onSelect = function()
                    StartHarvest(entity)
                end,
            },
        })
    end

    local function StartHunting()
        if hunting then
            Notify("You are already hunting pigs.", "info")
            return
        end

        if not CanUseRaven() then
            Notify(
                (ConfigServerLocations and ConfigServerLocations.WrongServerMessage)
                    and ConfigServerLocations.WrongServerMessage("grind")
                    or "Pig hunting is only available on Server #2 · Grind.",
                "error"
            )
            return
        end

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local npcPos = vector3(ConfigRaven.Ped.coords.x, ConfigRaven.Ped.coords.y, ConfigRaven.Ped.coords.z)
        local pigCenter = vector3(ConfigRaven.Pig.coords.x, ConfigRaven.Pig.coords.y, ConfigRaven.Pig.coords.z)

        if #(playerCoords - npcPos) > 15.0 and #(playerCoords - pigCenter) > ConfigRaven.HuntZoneRadius then
            Notify("Stay near the pig farm area to hunt.", "error")
            return
        end

        if not PlayerHasKnife() then
            Notify("You need a Knife in your inventory to start hunting.", "error")
            return
        end

        local started, reason = lib.callback.await("cfx-keydi-raven:startHunt", false)
        if not started then
            if reason == "wrong_server" then
                Notify(
                    (ConfigServerLocations and ConfigServerLocations.WrongServerMessage)
                        and ConfigServerLocations.WrongServerMessage("grind")
                        or "Pig hunting is only available on Server #2 · Grind.",
                    "error"
                )
            else
                Notify("Stay near the pig farm area to hunt.", "error")
            end
            return
        end

        hunting = true
        EnsurePigCount()
        Notify("Pig hunting started. Kill pigs and harvest meat with your knife.", "success")
    end

    -- Maintain living pig count + attach harvest targets on death
    CreateThread(function()
        while true do
            if hunting then
                for i = #pigs, 1, -1 do
                    local pig = pigs[i]
                    if not pig.entity or not DoesEntityExist(pig.entity) then
                        table.remove(pigs, i)
                    elseif IsEntityDead(pig.entity) then
                        if not pig.dead then
                            pig.dead = true
                            AddHarvestTarget(i)
                            -- Respawn living pig so living count stays at 15
                            EnsurePigCount()
                        end
                    else
                        local pCoords = GetEntityCoords(pig.entity)
                        local center = ConfigRaven.Pig.coords
                        if #(pCoords - vector3(center.x, center.y, center.z)) > (ConfigRaven.Pig.spawnRadius + 25.0) then
                            CleanupPig(i)
                        end
                    end
                end

                EnsurePigCount()

                -- Auto-stop if player leaves the farm area
                local center = ConfigRaven.Pig.coords
                local pedCoords = GetEntityCoords(PlayerPedId())
                local npcPos = vector3(ConfigRaven.Ped.coords.x, ConfigRaven.Ped.coords.y, ConfigRaven.Ped.coords.z)
                local distToPigCenter = #(pedCoords - vector3(center.x, center.y, center.z))
                local distToFarmer = #(pedCoords - npcPos)

                if distToPigCenter > ConfigRaven.HuntZoneRadius and distToFarmer > (ConfigRaven.HuntZoneRadius + 10.0) then
                    StopHunting()
                    Notify("You left the pig farm area.", "error")
                end

                Wait(500)
            else
                Wait(1000)
            end
        end
    end)

    local function GetFarmerCoords()
        local c = ConfigRaven.Ped.coords
        return vector3(c.x, c.y, c.z)
    end

    local function RegisterFarmerTarget()
        if farmerTargetZone then return end
        if GetResourceState("ox_target") ~= "started" then return end

        local c = ConfigRaven.Ped.coords
        farmerTargetZone = exports.ox_target:addSphereZone({
            coords = vec3(c.x, c.y, c.z + 0.5),
            radius = 2.2,
            debug = ConfigRaven.Debug,
            options = {
                {
                    name = "raven_start_hunt",
                    icon = "fa-solid fa-bacon",
                    label = "Start Pig Hunting",
                    distance = 2.5,
                    canInteract = function()
                        return CanUseRaven() and not hunting
                    end,
                    onSelect = function()
                        StartHunting()
                    end,
                },
                {
                    name = "raven_stop_hunt",
                    icon = "fa-solid fa-ban",
                    label = "Stop Pig Hunting",
                    distance = 2.5,
                    canInteract = function()
                        return hunting
                    end,
                    onSelect = function()
                        StopHunting()
                    end,
                },
            },
        })
    end

    local function SpawnFarmer()
        if npcPed and DoesEntityExist(npcPed) then return end

        local pedCfg = ConfigRaven.Ped
        local hash = LoadModel(pedCfg.model)
        if not hash then
            print("[Raven] Failed to load NPC model")
            return
        end

        local c = pedCfg.coords
        RequestCollisionAtCoord(c.x, c.y, c.z)
        npcPed = CreatePed(0, hash, c.x, c.y, c.z, c.w, false, true)
        if not npcPed or npcPed == 0 then
            SetModelAsNoLongerNeeded(hash)
            npcPed = nil
            return
        end

        SetEntityAsMissionEntity(npcPed, true, true)
        SetPedFleeAttributes(npcPed, 0, false)
        SetBlockingOfNonTemporaryEvents(npcPed, true)
        SetEntityInvincible(npcPed, true)
        SetPedCanBeTargetted(npcPed, true)
        SetEntityCoordsNoOffset(npcPed, c.x, c.y, c.z, false, false, false)
        SetEntityHeading(npcPed, c.w)
        FreezeEntityPosition(npcPed, true)
        if pedCfg.scenario then
            TaskStartScenarioInPlace(npcPed, pedCfg.scenario, 0, true)
        end
        SetModelAsNoLongerNeeded(hash)
    end

    local function DeleteFarmer()
        if npcPed and DoesEntityExist(npcPed) then
            DeleteEntity(npcPed)
        end
        npcPed = nil
    end

    -- Setup: wait for ox_target, register sphere zone, create blip, manage NPC streaming
    CreateThread(function()
        Wait(1000)

        while GetResourceState("ox_target") ~= "started" do
            Wait(200)
        end

        RegisterFarmerTarget()

        local pedCfg = ConfigRaven.Ped
        local blipCfg = ConfigRaven.Blip
        farmBlip = AddBlipForCoord(pedCfg.coords.x, pedCfg.coords.y, pedCfg.coords.z)
        SetBlipSprite(farmBlip, blipCfg.sprite or 141)
        SetBlipDisplay(farmBlip, 3)
        SetBlipScale(farmBlip, blipCfg.scale or 0.85)
        SetBlipColour(farmBlip, blipCfg.color or 1)
        SetBlipAsShortRange(farmBlip, blipCfg.shortRange ~= false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipCfg.label or "Raven Pig Farm")
        EndTextCommandSetBlipName(farmBlip)
        if not CanUseRaven() then
            SetBlipDisplay(farmBlip, 0)
        end

        while true do
            local dist = #(GetEntityCoords(PlayerPedId()) - GetFarmerCoords())
            if CanUseRaven() and dist < 80.0 then
                SpawnFarmer()
            elseif dist > 120.0 or not CanUseRaven() then
                DeleteFarmer()
            end
            Wait(2000)
        end
    end)

    AddEventHandler("onResourceStop", function(resourceName)
        if resourceName ~= GetCurrentResourceName() then return end
        StopHunting(true)
        if farmerTargetZone and GetResourceState("ox_target") == "started" then
            pcall(function()
                exports.ox_target:removeZone(farmerTargetZone)
            end)
            farmerTargetZone = nil
        end
        DeleteFarmer()
        if farmBlip then
            RemoveBlip(farmBlip)
        end
    end)

    AddEventHandler("cfx-keydi-serverlocations:changed", function(location)
        local enabled = ConfigServerLocations.LocationAllows
            and ConfigServerLocations.LocationAllows(location, "raven")
            or CanUseRaven()
        if farmBlip then
            SetBlipDisplay(farmBlip, enabled and 3 or 0)
            SetBlipAsShortRange(farmBlip, true)
        end
        if not enabled then
            StopHunting(true)
            DeleteFarmer()
        end
    end)
end
