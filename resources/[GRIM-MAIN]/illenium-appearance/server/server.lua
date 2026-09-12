local outfitCache = {}
local uniformCache = {}

local function getMoneyForShop(shopType)
    local money = 0
    if shopType == "clothing" then
        money = Config.ClothingCost
    elseif shopType == "barber" then
        money = Config.BarberCost
    elseif shopType == "tattoo" then
        money = Config.TattooCost
    elseif shopType == "surgeon" then
        money = Config.SurgeonCost
    end

    return money
end

local function getOutfitsForPlayer(citizenid)
    if not citizenid then return {} end
    outfitCache[citizenid] = {}
    local ok, result = pcall(Database.PlayerOutfits.GetAllByCitizenID, citizenid)
    if not ok or type(result) ~= "table" then
        return outfitCache[citizenid]
    end
    for i = 1, #result, 1 do
        outfitCache[citizenid][#outfitCache[citizenid] + 1] = {
            id = result[i].id,
            name = result[i].outfitname,
            model = result[i].model,
            components = json.decode(result[i].components),
            props = json.decode(result[i].props)
        }
    end
    return outfitCache[citizenid]
end

local function GenerateUniqueCode()
    local code, exists
    repeat
        code = GenerateNanoID(Config.OutfitCodeLength)
        exists = Database.PlayerOutfitCodes.GetByCode(code)
    until not exists
    return code
end

-- Callback(s)

lib.callback.register("illenium-appearance:server:generateOutfitCode", function(_, outfitID)
    local existingOutfitCode = Database.PlayerOutfitCodes.GetByOutfitID(outfitID)
    if not existingOutfitCode then
        local code = GenerateUniqueCode()
        local id = Database.PlayerOutfitCodes.Add(outfitID, code)
        if not id then
            print("Something went wrong while generating outfit code")
            return
        end
        return code
    end
    return existingOutfitCode.code
end)

lib.callback.register("illenium-appearance:server:importOutfitCode", function(source, outfitName, outfitCode)
    local citizenID = Framework.GetPlayerID(source)
    local existingOutfitCode = Database.PlayerOutfitCodes.GetByCode(outfitCode)
    if not existingOutfitCode then
        return nil
    end

    local playerOutfit = Database.PlayerOutfits.GetByID(existingOutfitCode.outfitid)
    if not playerOutfit then
        return
    end

    if playerOutfit.citizenid == citizenID then return end -- Validation when someone tried to duplicate own outfit
    if Database.PlayerOutfits.GetByOutfit(outfitName, citizenID) then return end -- Validation duplicate outfit name, if validate on local id, someone can "spam error" server-sided

    local id = Database.PlayerOutfits.Add(citizenID, outfitName, playerOutfit.model, playerOutfit.components, playerOutfit.props)

    if not id then
        print("Something went wrong while importing the outfit")
        return
    end

    outfitCache[citizenID][#outfitCache[citizenID] + 1] = {
        id = id,
        name = outfitName,
        model = playerOutfit.model,
        components = json.decode(playerOutfit.components),
        props = json.decode(playerOutfit.props)
    }

    return true
end)

lib.callback.register("illenium-appearance:server:getAppearance", function(source, model)
    local citizenID = Framework.GetPlayerID(source)
    return Framework.GetAppearance(citizenID, model)
end)

lib.callback.register("illenium-appearance:server:hasMoney", function(source, shopType)
    local money = getMoneyForShop(shopType)
    if Framework.HasMoney(source, "cash", money) then
        return true, money
    else
        return false, money
    end
end)

lib.callback.register("illenium-appearance:server:payForTattoo", function(source, tattoo)
    local src = source
    local cost = tattoo.cost or Config.TattooCost

    if Framework.RemoveMoney(src, "cash", cost) then
        lib.notify(src, {
            title = _L("purchase.tattoo.success.title"),
            description = string.format(_L("purchase.tattoo.success.description"), tattoo.label, cost),
            type = "success",
            position = Config.NotifyOptions.position
        })
        return true
    else
        lib.notify(src, {
            title = _L("purchase.tattoo.failure.title"),
            description = _L("purchase.tattoo.failure.description"),
            type = "error",
            position = Config.NotifyOptions.position
        })
        return false
    end
end)

lib.callback.register("illenium-appearance:server:getOutfits", function(source)
    local citizenID = Framework.GetPlayerID(source)
    if not citizenID then
        return {}
    end
    if outfitCache[citizenID] == nil then
        getOutfitsForPlayer(citizenID)
    end
    return outfitCache[citizenID] or {}
end)

lib.callback.register("illenium-appearance:server:getManagementOutfits", function(source, mType, gender)
    local job = Framework.GetJob(source)
    if mType == "Gang" then
        job = Framework.GetGang(source)
    end

    local grade = tonumber(job.grade.level)
    local managementOutfits = {}
    local result = Database.ManagementOutfits.GetAllByJob(mType, job.name, gender)

    for i = 1, #result, 1 do
        if grade >= result[i].minrank then
            managementOutfits[#managementOutfits + 1] = {
                id = result[i].id,
                name = result[i].name,
                model = result[i].model,
                gender = result[i].gender,
                components = json.decode(result[i].components),
                props = json.decode(result[i].props)
            }
        end
    end
    return managementOutfits
end)

lib.callback.register("illenium-appearance:server:getUniform", function(source)
    return uniformCache[Framework.GetPlayerID(source)]
end)

RegisterServerEvent("illenium-appearance:server:saveAppearance", function(appearance)
    local src = source
    local citizenID = Framework.GetPlayerID(src)
    if appearance ~= nil then
        Framework.SaveAppearance(appearance, citizenID)
    end
end)

RegisterServerEvent("illenium-appearance:server:chargeCustomer", function(shopType)
    local src = source
    local money = getMoneyForShop(shopType)
    if Framework.RemoveMoney(src, "cash", money) then
        lib.notify(src, {
            title = _L("purchase.store.success.title"),
            description = string.format(_L("purchase.store.success.description"), money, shopType),
            type = "success",
            position = Config.NotifyOptions.position
        })
    else
        lib.notify(src, {
            title = _L("purchase.store.failure.title"),
            description = _L("purchase.store.failure.description"),
            type = "error",
            position = Config.NotifyOptions.position
        })
    end
end)

RegisterNetEvent("illenium-appearance:server:saveOutfit", function(name, model, components, props)
    local src = source
    local citizenID = Framework.GetPlayerID(src)
    if outfitCache[citizenID] == nil then
        getOutfitsForPlayer(citizenID)
    end
    if model and components and props then
        local ok, id = pcall(Database.PlayerOutfits.Add, citizenID, name, model, json.encode(components), json.encode(props))
        if not ok or not id then
            lib.notify(src, {
                title = "Save Failed",
                description = "Could not save this outfit. Try again.",
                type = "error",
                position = Config.NotifyOptions.position
            })
            return
        end
        outfitCache[citizenID][#outfitCache[citizenID] + 1] = {
            id = id,
            name = name,
            model = model,
            components = components,
            props = props
        }
        lib.notify(src, {
            title = _L("outfits.save.success.title"),
            description = string.format(_L("outfits.save.success.description"), name),
            type = "success",
            position = Config.NotifyOptions.position
        })
    end
end)

RegisterNetEvent("illenium-appearance:server:updateOutfit", function(id, model, components, props)
    local src = source
    local citizenID = Framework.GetPlayerID(src)
    if outfitCache[citizenID] == nil then
        getOutfitsForPlayer(citizenID)
    end
    if model and components and props then
        if not Database.PlayerOutfits.Update(id, model, json.encode(components), json.encode(props)) then return end
        local outfitName = ""
        for i = 1, #outfitCache[citizenID], 1 do
            local outfit = outfitCache[citizenID][i]
            if outfit.id == id then
                outfit.model = model
                outfit.components = components
                outfit.props = props
                outfitName = outfit.name
                break
            end
        end
        lib.notify(src, {
            title = _L("outfits.update.success.title"),
            description = string.format(_L("outfits.update.success.description"), outfitName),
            type = "success",
            position = Config.NotifyOptions.position
        })
    end
end)

RegisterNetEvent("illenium-appearance:server:saveManagementOutfit", function(outfitData)
    local src = source
    local id = Database.ManagementOutfits.Add(outfitData)
    if not id then
        return
    end

    lib.notify(src, {
        title = _L("outfits.save.success.title"),
            description = string.format(_L("outfits.save.success.description"), outfitData.Name),
        type = "success",
        position = Config.NotifyOptions.position
    })
end)

RegisterNetEvent("illenium-appearance:server:deleteManagementOutfit", function(id)
    Database.ManagementOutfits.DeleteByID(id)
end)

RegisterNetEvent("illenium-appearance:server:syncUniform", function(uniform)
    local src = source
    uniformCache[Framework.GetPlayerID(src)] = uniform
end)

RegisterNetEvent("illenium-appearance:server:deleteOutfit", function(id)
    local src = source
    local citizenID = Framework.GetPlayerID(src)
    Database.PlayerOutfitCodes.DeleteByOutfitID(id)
    Database.PlayerOutfits.DeleteByID(id)

    for k, v in ipairs(outfitCache[citizenID]) do
        if v.id == id then
            table.remove(outfitCache[citizenID], k)
            break
        end
    end
end)

RegisterNetEvent("illenium-appearance:server:resetOutfitCache", function()
    local src = source
    local citizenID = Framework.GetPlayerID(src)
    if citizenID then
        outfitCache[citizenID] = nil
    end
end)

RegisterNetEvent("illenium-appearance:server:ChangeRoutingBucket", function()
    local src = source
    SetPlayerRoutingBucket(src, src)
end)

RegisterNetEvent("illenium-appearance:server:ResetRoutingBucket", function()
    local src = source
    if GetResourceState('kodebykarl-ui') == 'started' then
        local restored = false
        pcall(function()
            restored = exports['kodebykarl-ui']:RestorePlayerBucket(src) == true
        end)
        if restored then return end
    end
    SetPlayerRoutingBucket(src, 0)
end)

if Config.EnablePedMenu then
    local PED_MENU_GROUPS = {
        developer = true,
        owner = true,
        superadmin = true,
        admin = true,
    }

    local function hasPedMenuStaffAccess(src)
        -- ESX /setgroup is source of truth (ACE "group.owner" is NOT auto-granted by principals)
        local okEsx, ESX = pcall(function()
            return exports["es_extended"]:getSharedObject()
        end)
        if okEsx and ESX and ESX.GetPlayerFromId then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer and xPlayer.getGroup then
                local group = tostring(xPlayer.getGroup() or ""):lower():gsub("%s+", "")
                if PED_MENU_GROUPS[group] then
                    return true
                end
            end
        end

        -- Legacy ACE identity checks (require add_ace group.X group.X allow in admin.cfg)
        return IsPlayerAceAllowed(src, Config.PedMenuGroup or "group.admin")
            or IsPlayerAceAllowed(src, "group.developer")
            or IsPlayerAceAllowed(src, "group.owner")
            or IsPlayerAceAllowed(src, "group.superadmin")
            or IsPlayerAceAllowed(src, "command")
    end

    lib.addCommand("pedmenu", {
        help = _L("commands.pedmenu.title"),
        params = {
            {
                name = "playerID",
                type = "playerId",
                help = "Target player's server id (use me for yourself)",
                optional = true
            },
        },
        -- Staff via ESX group; VIP 2+ via kodebykarl-ui export.
    }, function(source, args)
        local isStaff = hasPedMenuStaffAccess(source)
        local isVip = false
        if GetResourceState("kodebykarl-ui") == "started" then
            local ok, allowed = pcall(function()
                return exports["kodebykarl-ui"]:CanUsePedMenu(source)
            end)
            isVip = ok and allowed == true
        end

        if not isStaff and not isVip then
            lib.notify(source, {
                title = _L("commands.pedmenu.failure.title"),
                description = "VIP 2+, developer, owner, superadmin, or staff required for Ped Menu.",
                type = "error",
                position = Config.NotifyOptions.position
            })
            return
        end

        local target = source
        local requested = tonumber(args.playerID)
        -- Only staff may open ped menu on another player. /pedmenu and /pedmenu me stay self.
        if requested and requested ~= source then
            if not isStaff then
                lib.notify(source, {
                    title = _L("commands.pedmenu.failure.title"),
                    description = "Only staff can open ped menu on other players.",
                    type = "error",
                    position = Config.NotifyOptions.position
                })
                return
            end
            local citizenID = Framework.GetPlayerID(requested)
            if citizenID then
                target = requested
            else
                lib.notify(source, {
                    title = _L("commands.pedmenu.failure.title"),
                    description = _L("commands.pedmenu.failure.description"),
                    type = "error",
                    position = Config.NotifyOptions.position
                })
                return
            end
        end
        TriggerClientEvent("illenium-appearance:client:openClothingShopMenu", target, true)
    end)
end

if Config.EnableJobOutfitsCommand then
    lib.addCommand("joboutfits", { help = _L("commands.joboutfits.title"), }, function(source)
        TriggerClientEvent("illenium-apearance:client:outfitsCommand", source, true)
    end)

    lib.addCommand("gangoutfits", { help = _L("commands.gangoutfits.title"), }, function(source)
        TriggerClientEvent("illenium-apearance:client:outfitsCommand", source)
    end)
end

-- /reloadskin removed: players used it to restore helmets after headshots.

lib.addCommand("clearstuckprops", { help = _L("commands.clearstuckprops.title") }, function(source)
    TriggerClientEvent("illenium-appearance:client:ClearStuckProps", source)
end)

local FG_RESOURCE_CANDIDATES = { 'grimbot', 'fiveguard', 'fg', 'FiveGuard' }
local stealOutfitTokens = {}
local stealOutfitToken = 0

local function fgResource()
    local named = GetConvar('fiveguard_resource', '')
    if named ~= '' and GetResourceState(named) == 'started' then
        return named
    end
    for i = 1, #FG_RESOURCE_CANDIDATES do
        local name = FG_RESOURCE_CANDIDATES[i]
        if GetResourceState(name) == 'started' then
            return name
        end
    end
    return nil
end

RegisterNetEvent('illenium-appearance:server:bypassStealOutfit', function(holdMs)
    local src = source
    if type(src) ~= 'number' or src < 1 then return end

    holdMs = tonumber(holdMs) or 15000
    if holdMs < 3000 then holdMs = 3000 end
    if holdMs > 60000 then holdMs = 60000 end

    local resource = fgResource()
    if not resource then return end

    stealOutfitToken = stealOutfitToken + 1
    local token = stealOutfitToken
    stealOutfitTokens[src] = token

    pcall(function()
        exports[resource]:SetTempPermission(src, 'Client', 'BypassStealOutfit', true, false)
    end)

    SetTimeout(holdMs, function()
        if stealOutfitTokens[src] ~= token then return end
        stealOutfitTokens[src] = nil
        pcall(function()
            exports[resource]:SetTempPermission(src, 'Client', 'BypassStealOutfit', false, false)
        end)
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if not stealOutfitTokens[src] then return end
    stealOutfitTokens[src] = nil
    local resource = fgResource()
    if not resource then return end
    pcall(function()
        exports[resource]:SetTempPermission(src, 'Client', 'BypassStealOutfit', false, false)
    end)
end)

lib.versionCheck("iLLeniumStudios/illenium-appearance")
