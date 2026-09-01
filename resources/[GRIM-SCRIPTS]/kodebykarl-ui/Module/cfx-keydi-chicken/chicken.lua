--[[
    Chicken Farm — Raven-style slaughter grind
    Poly zone keeps chickens inside; fled birds are replaced so count stays at 15.
]]

ConfigChicken = {
    Debug = false,

    -- Talk to this NPC (ox_target) to start / stop hunting
    Ped = {
        model = "a_m_m_farmer_01",
        coords = vec4(2294.8849, 4930.2189, 41.33, 180.0),
        scenario = "WORLD_HUMAN_CLIPBOARD",
    },

    Blip = {
        label = "Chicken Farm",
        sprite = 141,
        color = 5,
        scale = 0.85,
        shortRange = true,
    },

    Chicken = {
        model = "a_c_hen",
        count = 15,
    },

    -- Chicken paddock (ox_lib poly zone). Birds that leave are deleted + respawned.
    Zone = {
        points = {
            vec3(2305.7749, 4929.1973, 41.4494),
            vec3(2295.6411, 4919.2441, 41.4355),
            vec3(2284.1963, 4931.3540, 41.4309),
            vec3(2293.9224, 4941.0801, 41.4353),
        },
        thickness = 30.0,
        debug = false,
    },

    RequiredWeapon = "WEAPON_KNIFE",
    RewardItem = "raw_chicken",
    RewardMin = 1,
    RewardMax = 3,
    ToolUses = 100, -- harvests before knife breaks (-1 durability per harvest)


    ToolUses = 100, -- harvests before knife breaks (-1 durability per harvest)


    HarvestDistance = 2.5,
    HarvestDuration = 4000,
}

local function CanUseChicken(src)
    if type(ConfigServerLocations) ~= "table" or not ConfigServerLocations.CanUseFunction then
        return true
    end
    if IsDuplicityVersion() then
        return ConfigServerLocations.CanUseFunction("grind", src) or ConfigServerLocations.CanUseFunction("chicken", src)
    end
    return ConfigServerLocations.CanUseFunction("grind") or ConfigServerLocations.CanUseFunction("chicken")
end

local function DebugLog(msg)
    if ConfigChicken.Debug then
        print(("[Chicken] %s"):format(msg))
    end
end

local function GetZoneCenter()
    local points = ConfigChicken.Zone.points
    local sx, sy, sz = 0.0, 0.0, 0.0
    for i = 1, #points do
        sx = sx + points[i].x
        sy = sy + points[i].y
        sz = sz + points[i].z
    end
    local n = #points
    return vector3(sx / n, sy / n, sz / n)
end

if IsDuplicityVersion() then
    ---------------------------------------------------------------------------
    -- SERVER
    ---------------------------------------------------------------------------
    local hunters = {}
    local pendingHarvest = {}

    ---Simple point-in-polygon (XY) for server distance checks
    local function IsInsideZone(coords)
        local points = ConfigChicken.Zone.points
        local x, y = coords.x, coords.y
        local inside = false
        local j = #points
        for i = 1, #points do
            local xi, yi = points[i].x, points[i].y
            local xj, yj = points[j].x, points[j].y
            if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / ((yj - yi) + 0.0) + xi) then
                inside = not inside
            end
            j = i
        end
        return inside
    end

    local function IsNearChickenFarm(src)
        local ped = GetPlayerPed(src)
        if not ped or ped == 0 then return false end
        local playerCoords = GetEntityCoords(ped)
        if IsInsideZone(playerCoords) then return true end
        local farmer = ConfigChicken.Ped.coords
        return #(playerCoords - vector3(farmer.x, farmer.y, farmer.z)) <= 8.0
    end

    local function HasKnife(src)
        local count = exports.ox_inventory:Search(src, "count", ConfigChicken.RequiredWeapon) or 0
        if type(count) == "table" then
            count = count[ConfigChicken.RequiredWeapon] or 0
        end
        if (tonumber(count) or 0) > 0 then return true end

        local countItem = exports.ox_inventory:Search(src, "count", "knife") or 0
        if type(countItem) == "table" then
            countItem = countItem["knife"] or 0
        end
        return (tonumber(countItem) or 0) > 0
    end

    local function WearKnife(src)
        local targetItem = ConfigChicken.RequiredWeapon
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

        local uses = tonumber(ConfigChicken.ToolUses) or 100
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

    lib.callback.register("cfx-keydi-chicken:canStart", function(source)
        local ok, hasKnife = pcall(HasKnife, source)
        if not ok or not hasKnife then
            return false, "knife"
        end
        if not IsNearChickenFarm(source) then
            return false, "distance"
        end
        return true
    end)

    lib.callback.register("cfx-keydi-chicken:startHunt", function(src)
        if type(src) ~= "number" or src < 1 then return false, "invalid" end
        if not CanUseChicken(src) then return false, "wrong_server" end
        if not IsNearChickenFarm(src) then return false, "distance" end
        local ok, hasKnife = pcall(HasKnife, src)
        if not ok or not hasKnife then return false, "knife" end
        hunters[src] = true
        pendingHarvest[src] = nil
        return true
    end)

    RegisterNetEvent("cfx-keydi-chicken:stopHunt", function()
        local src = source
        hunters[src] = nil
        pendingHarvest[src] = nil
    end)

    lib.callback.register("cfx-keydi-chicken:beginHarvest", function(src)
        if type(src) ~= "number" or src < 1 then return false end
        if not hunters[src] then return false end
        if not IsNearChickenFarm(src) then
            hunters[src] = nil
            pendingHarvest[src] = nil
            return false
        end
        local ok, hasKnife = pcall(HasKnife, src)
        if not ok or not hasKnife then return false end

        local now = GetGameTimer()
        local pending = pendingHarvest[src]
        local duration = ConfigChicken.HarvestDuration or 4000
        if pending and (now - pending) < (duration * 3) then
            return false
        end

        pendingHarvest[src] = now
        return true
    end)

    RegisterNetEvent("cfx-keydi-chicken:harvest", function()
        local src = source
        if type(src) ~= "number" or src < 1 then return end

        if not hunters[src] then
            KeydiElectron.Flag(src, "Chicken harvest exploit (no hunt session)", "cfx-keydi-chicken")
            return
        end

        local started = pendingHarvest[src]
        if not started then
            KeydiElectron.Flag(src, "Chicken harvest exploit (no begin)", "cfx-keydi-chicken")
            return
        end

        local duration = ConfigChicken.HarvestDuration or 4000
        if (GetGameTimer() - started) < (duration - 400) then
            KeydiElectron.Flag(src, "Chicken harvest exploit (skipped wait)", "cfx-keydi-chicken")
            return
        end
        pendingHarvest[src] = nil

        if not IsNearChickenFarm(src) then
            hunters[src] = nil
            TriggerClientEvent("cfx-keydi-chicken:notify", src, "Too far from the chicken farm.", "error")
            return
        end

        if not HasKnife(src) then
            TriggerClientEvent("cfx-keydi-chicken:notify", src, "You need a knife to gather chicken meat.", "error")
            return
        end

        local amount = math.random(ConfigChicken.RewardMin, ConfigChicken.RewardMax)
        local canCarry = exports.ox_inventory:CanCarryAmount(src, ConfigChicken.RewardItem) or 0
        if canCarry < 1 then
            TriggerClientEvent("cfx-keydi-chicken:notify", src, "You cannot carry any more raw chicken.", "error")
            return
        end
        if amount > canCarry then
            amount = canCarry
        end

        local added = exports.ox_inventory:AddItem(src, ConfigChicken.RewardItem, amount)
        if added then
            local _, broken = WearKnife(src)
            if broken then
                TriggerClientEvent("cfx-keydi-chicken:notify", src, ("You gathered %dx Raw Chicken — your knife broke."):format(amount), "error")
            else
                TriggerClientEvent("cfx-keydi-chicken:notify", src, ("You gathered %dx Raw Chicken"):format(amount), "success")
            end
            TriggerClientEvent("cfx-keydi-chicken:harvested", src)
        else
            TriggerClientEvent("cfx-keydi-chicken:notify", src, "Failed to add raw chicken.", "error")
        end
    end)

    CreateThread(function()
        while true do
            Wait(2000)
            for src in pairs(hunters) do
                if not IsNearChickenFarm(src) then
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
    local farmZone = nil
    local farmerTargetZone = nil
    local playerInZone = false
    local hunting = false
    local harvesting = false
    -- chickens[i] = { entity, dead, targeted }
    local chickens = {}

    local function Notify(msg, nType)
        ESX.ShowNotification(msg, nType or "info")
    end

    local function PlayerHasKnife()
        local weapon = ConfigChicken.RequiredWeapon
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

    RegisterNetEvent("cfx-keydi-chicken:notify", function(msg, nType)
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

    local function GetZoneBounds()
        local points = ConfigChicken.Zone.points
        local minX, maxX = points[1].x, points[1].x
        local minY, maxY = points[1].y, points[1].y
        local z = points[1].z
        for i = 2, #points do
            local p = points[i]
            if p.x < minX then minX = p.x end
            if p.x > maxX then maxX = p.x end
            if p.y < minY then minY = p.y end
            if p.y > maxY then maxY = p.y end
            z = z + p.z
        end
        return minX, maxX, minY, maxY, z / #points
    end

    local function IsCoordsInZone(coords)
        if farmZone and farmZone.contains then
            return farmZone:contains(coords)
        end
        local points = ConfigChicken.Zone.points
        local x, y = coords.x, coords.y
        local inside = false
        local j = #points
        for i = 1, #points do
            local xi, yi = points[i].x, points[i].y
            local xj, yj = points[j].x, points[j].y
            if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / ((yj - yi) + 0.0) + xi) then
                inside = not inside
            end
            j = i
        end
        return inside
    end

    local function RandomChickenCoords()
        local minX, maxX, minY, maxY, avgZ = GetZoneBounds()
        local center = GetZoneCenter()

        for _ = 1, 40 do
            local x = minX + math.random() * (maxX - minX)
            local y = minY + math.random() * (maxY - minY)
            local candidate = vector3(x, y, avgZ)
            if IsCoordsInZone(candidate) then
                local z = avgZ
                local found, groundZ = GetGroundZFor_3dCoord(x, y, avgZ + 5.0, false)
                if found and groundZ and math.abs(groundZ - avgZ) < 8.0 then
                    z = groundZ
                end
                return x, y, z, math.random(0, 359) + 0.0
            end
        end

        local z = center.z
        local found, groundZ = GetGroundZFor_3dCoord(center.x, center.y, center.z + 5.0, false)
        if found then z = groundZ end
        return center.x, center.y, z, math.random(0, 359) + 0.0
    end

    local function CountLivingChickens()
        local count = 0
        for _, chicken in ipairs(chickens) do
            if chicken.entity and DoesEntityExist(chicken.entity) and not IsEntityDead(chicken.entity) then
                count = count + 1
            end
        end
        return count
    end

    local function SpawnChicken()
        local hash = LoadModel(ConfigChicken.Chicken.model)
        if not hash then
            DebugLog("failed to load chicken model")
            return nil
        end

        local x, y, z, heading = RandomChickenCoords()
        local ped = CreatePed(28, hash, x, y, z, heading, false, true)
        if not ped or ped == 0 then
            SetModelAsNoLongerNeeded(hash)
            return nil
        end

        SetEntityAsMissionEntity(ped, true, true)
        SetPedFleeAttributes(ped, 0, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanRagdoll(ped, true)
        SetEntityHealth(ped, 150)

        local center = GetZoneCenter()
        TaskWanderInArea(ped, center.x, center.y, center.z, 6.0, 2.0, 3.0)
        SetModelAsNoLongerNeeded(hash)

        chickens[#chickens + 1] = {
            entity = ped,
            dead = false,
            targeted = false,
        }

        return ped
    end

    local function EnsureChickens()
        local living = CountLivingChickens()
        local needed = ConfigChicken.Chicken.count - living
        for _ = 1, needed do
            SpawnChicken()
        end
    end

    local function CleanupChicken(index)
        local chicken = chickens[index]
        if not chicken then return end

        if chicken.entity and DoesEntityExist(chicken.entity) then
            if chicken.targeted then
                pcall(function()
                    exports.ox_target:removeLocalEntity(chicken.entity)
                end)
            end
            DeleteEntity(chicken.entity)
        end

        table.remove(chickens, index)
    end

    local function ClearAllChickens()
        for i = #chickens, 1, -1 do
            CleanupChicken(i)
        end
        chickens = {}
    end

    local function StopHunting(silent)
        if not hunting then return end
        hunting = false
        harvesting = false
        ClearAllChickens()
        TriggerServerEvent("cfx-keydi-chicken:stopHunt")
        if not silent then
            Notify("Chicken hunting stopped.", "info")
        end
    end

    local function StartHarvest(entity)
        if harvesting or not hunting then return end
        if not entity or not DoesEntityExist(entity) then return end
        if not IsEntityDead(entity) then
            Notify("The chicken is still alive.", "error")
            return
        end

        local playerPed = PlayerPedId()
        if #(GetEntityCoords(playerPed) - GetEntityCoords(entity)) > ConfigChicken.HarvestDistance + 1.0 then
            Notify("Move closer to the chicken.", "error")
            return
        end

        local hasKnife = PlayerHasKnife()
        if not hasKnife then
            Notify("You need a knife to gather chicken meat.", "error")
            return
        end

        harvesting = true

        local began = lib.callback.await("cfx-keydi-chicken:beginHarvest", false)
        if not began then
            harvesting = false
            Notify("You cannot gather chicken right now.", "error")
            return
        end

        GiveWeaponToPed(playerPed, joaat(ConfigChicken.RequiredWeapon), 0, false, true)
        SetCurrentPedWeapon(playerPed, joaat(ConfigChicken.RequiredWeapon), true)

        local success = lib.progressBar({
            duration = ConfigChicken.HarvestDuration,
            label = "Gathering chicken meat…",
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

        TriggerServerEvent("cfx-keydi-chicken:harvest")

        for i = #chickens, 1, -1 do
            local chicken = chickens[i]
            if chicken.entity == entity then
                if chicken.targeted then
                    pcall(function()
                        exports.ox_target:removeLocalEntity(entity)
                    end)
                end
                if DoesEntityExist(entity) then
                    DeleteEntity(entity)
                end
                table.remove(chickens, i)
                break
            end
        end

        EnsureChickens()
        harvesting = false
    end

    local function AddHarvestTarget(chickenIndex)
        local chicken = chickens[chickenIndex]
        if not chicken or chicken.targeted or not chicken.entity or not DoesEntityExist(chicken.entity) then
            return
        end

        local entity = chicken.entity
        chicken.targeted = true
        exports.ox_target:addLocalEntity(entity, {
            {
                name = ("chicken_harvest_%s"):format(entity),
                icon = "fa-solid fa-drumstick-bite",
                label = "Gather Raw Chicken",
                distance = ConfigChicken.HarvestDistance,
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
            Notify("You are already hunting chickens.", "info")
            return
        end

        if not CanUseChicken() then
            Notify(
                (ConfigServerLocations and ConfigServerLocations.WrongServerMessage)
                    and ConfigServerLocations.WrongServerMessage("grind")
                    or "Chicken hunting is only available on Server #2 · Grind.",
                "error"
            )
            return
        end

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local npcPos = vector3(ConfigChicken.Ped.coords.x, ConfigChicken.Ped.coords.y, ConfigChicken.Ped.coords.z)
        local nearFarmer = #(playerCoords - npcPos) <= 5.0

        if not nearFarmer and not playerInZone and not IsCoordsInZone(playerCoords) then
            Notify("Stay inside the chicken farm area to hunt.", "error")
            return
        end

        if not PlayerHasKnife() then
            Notify("You need a Knife in your inventory to start hunting.", "error")
            return
        end

        local started, reason = lib.callback.await("cfx-keydi-chicken:startHunt", false)
        if not started then
            if reason == "wrong_server" then
                Notify(
                    (ConfigServerLocations and ConfigServerLocations.WrongServerMessage)
                        and ConfigServerLocations.WrongServerMessage("grind")
                        or "Chicken hunting is only available on Server #2 · Grind.",
                    "error"
                )
            else
                Notify("Stay inside the chicken farm area to hunt.", "error")
            end
            return
        end

        hunting = true
        EnsureChickens()
        Notify("Chicken hunting started. Kill chickens and gather meat with your knife.", "success")
    end

    -- Maintain chickens + remove birds that leave the poly zone + refill to 15
    CreateThread(function()
        while true do
            if hunting then
                for i = #chickens, 1, -1 do
                    local chicken = chickens[i]
                    if not chicken.entity or not DoesEntityExist(chicken.entity) then
                        table.remove(chickens, i)
                    elseif IsEntityDead(chicken.entity) then
                        if not chicken.dead then
                            chicken.dead = true
                            AddHarvestTarget(i)
                        end
                    else
                        local coords = GetEntityCoords(chicken.entity)
                        if not IsCoordsInZone(coords) then
                            -- Fled the paddock — remove and replace so stock never runs out
                            DebugLog(("chicken left zone, removing entity %s"):format(chicken.entity))
                            CleanupChicken(i)
                        end
                    end
                end

                EnsureChickens()

                local pedCoords = GetEntityCoords(PlayerPedId())
                local stillInFarm = playerInZone or IsCoordsInZone(pedCoords)
                if not stillInFarm then
                    local npcPos = vector3(ConfigChicken.Ped.coords.x, ConfigChicken.Ped.coords.y, ConfigChicken.Ped.coords.z)
                    stillInFarm = #(pedCoords - npcPos) <= 8.0
                end

                if not stillInFarm then
                    StopHunting()
                    Notify("You left the chicken farm area.", "error")
                end

                Wait(500)
            else
                Wait(1000)
            end
        end
    end)

    local function GetFarmerCoords()
        local c = ConfigChicken.Ped.coords
        return vector3(c.x, c.y, c.z)
    end

    local function RegisterFarmerTarget()
        if farmerTargetZone then return end
        if GetResourceState("ox_target") ~= "started" then return end

        local c = ConfigChicken.Ped.coords
        farmerTargetZone = exports.ox_target:addSphereZone({
            coords = vec3(c.x, c.y, c.z + 0.5),
            radius = 2.2,
            debug = ConfigChicken.Debug,
            options = {
                {
                    name = "chicken_start_hunt",
                    icon = "fa-solid fa-drumstick-bite",
                    label = "Start Chicken Hunting",
                    distance = 2.5,
                    canInteract = function()
                        return CanUseChicken() and not hunting
                    end,
                    onSelect = function()
                        StartHunting()
                    end,
                },
                {
                    name = "chicken_stop_hunt",
                    icon = "fa-solid fa-ban",
                    label = "Stop Chicken Hunting",
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

        local pedCfg = ConfigChicken.Ped
        local hash = LoadModel(pedCfg.model)
        if not hash then
            print("[Chicken] Failed to load NPC model")
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
        SetPedCanBeTargetted(npcPed, false)
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

    -- Poly zone + farmer NPC + blip + ox_target sphere (works even if the ped culls)
    CreateThread(function()
        Wait(1000)

        while GetResourceState("ox_target") ~= "started" do
            Wait(200)
        end

        local zoneCfg = ConfigChicken.Zone
        local ok, zone = pcall(function()
            return lib.zones.poly({
                name = "cfx_keydi_chicken_farm",
                points = zoneCfg.points,
                thickness = zoneCfg.thickness or 30.0,
                debug = zoneCfg.debug or ConfigChicken.Debug,
                onEnter = function()
                    playerInZone = true
                end,
                onExit = function()
                    playerInZone = false
                    if hunting then
                        StopHunting()
                        Notify("You left the chicken farm area.", "error")
                    end
                end,
            })
        end)

        if ok and zone then
            farmZone = zone
            local ped = PlayerPedId()
            if ped and ped ~= 0 and farmZone.contains and farmZone:contains(GetEntityCoords(ped)) then
                playerInZone = true
            end
        else
            print("[Chicken] Failed to create farm poly zone — hunting area fallback is NPC proximity.")
        end

        RegisterFarmerTarget()

        local pedCfg = ConfigChicken.Ped
        local blipCfg = ConfigChicken.Blip
        farmBlip = AddBlipForCoord(pedCfg.coords.x, pedCfg.coords.y, pedCfg.coords.z)
        SetBlipSprite(farmBlip, blipCfg.sprite or 141)
        SetBlipDisplay(farmBlip, 3)
        SetBlipScale(farmBlip, blipCfg.scale or 0.85)
        SetBlipColour(farmBlip, blipCfg.color or 5)
        SetBlipAsShortRange(farmBlip, blipCfg.shortRange ~= false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipCfg.label or "Chicken Farm")
        EndTextCommandSetBlipName(farmBlip)
        if not CanUseChicken() then
            SetBlipDisplay(farmBlip, 0)
        end

        while true do
            local dist = #(GetEntityCoords(PlayerPedId()) - GetFarmerCoords())
            if CanUseChicken() and dist < 80.0 then
                SpawnFarmer()
            elseif dist > 120.0 or not CanUseChicken() then
                DeleteFarmer()
            end
            Wait(2000)
        end
    end)

    AddEventHandler("onResourceStop", function(resourceName)
        if resourceName ~= GetCurrentResourceName() then return end
        StopHunting(true)
        if farmZone then
            farmZone:remove()
            farmZone = nil
        end
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
            and ConfigServerLocations.LocationAllows(location, "chicken")
            or CanUseChicken()
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
