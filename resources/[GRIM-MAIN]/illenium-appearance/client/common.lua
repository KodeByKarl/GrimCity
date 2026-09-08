function CheckDuty()
    return not Config.OnDutyOnlyClothingRooms or (Config.OnDutyOnlyClothingRooms and client.job.onduty)
end

function IsPlayerAllowedForOutfitRoom(outfitRoom)
    if not outfitRoom then return false end

    -- Job check: If room specifies a job, player must have that set job
    if outfitRoom.job then
        local playerJob = (client.job and client.job.name) or (Framework.PlayerData and Framework.PlayerData.job and Framework.PlayerData.job.name)
        if not playerJob then return false end
        local jobMatched = false
        if type(outfitRoom.job) == "table" then
            for _, j in pairs(outfitRoom.job) do
                if j == playerJob then
                    jobMatched = true
                    break
                end
            end
        else
            jobMatched = (playerJob == outfitRoom.job)
        end
        if not jobMatched then
            return false
        end
    end

    -- Gang check: If room specifies a gang, player must have that gang
    if outfitRoom.gang then
        local playerGang = (client.gang and client.gang.name) or (Framework.PlayerData and Framework.PlayerData.gang and Framework.PlayerData.gang.name)
        if not playerGang then return false end
        local gangMatched = false
        if type(outfitRoom.gang) == "table" then
            for _, g in pairs(outfitRoom.gang) do
                if g == playerGang then
                    gangMatched = true
                    break
                end
            end
        else
            gangMatched = (playerGang == outfitRoom.gang)
        end
        if not gangMatched then
            return false
        end
    end

    -- Duty check if configured
    if outfitRoom.job and not CheckDuty() then
        return false
    end

    -- CitizenID check (only if specified and not empty)
    if outfitRoom.citizenIDs and #outfitRoom.citizenIDs > 0 then
        local isAllowed = false
        for i = 1, #outfitRoom.citizenIDs do
            if Framework.IsPlayerAllowed(outfitRoom.citizenIDs[i]) then
                isAllowed = true
                break
            end
        end
        if not isAllowed then
            return false
        end
    end

    return true
end

function GetPlayerJobOutfits(job)
    local outfits = {}
    local gender = Framework.GetGender()
    local gradeLevel = job and Framework.GetJobGrade() or Framework.GetGangGrade()
    local jobName = job and client.job.name or client.gang.name

    if Config.BossManagedOutfits then
        local mType = job and "Job" or "Gang"
        local result = lib.callback.await("illenium-appearance:server:getManagementOutfits", false, mType, gender)
        for i = 1, #result, 1 do
            outfits[#outfits + 1] = {
                type = mType,
                model = result[i].model,
                components = result[i].components,
                props = result[i].props,
                disableSave = true,
                name = result[i].name
            }
        end
    elseif Config.Outfits[jobName] and Config.Outfits[jobName][gender] then
        for i = 1, #Config.Outfits[jobName][gender], 1 do
            for _, v in pairs(Config.Outfits[jobName][gender][i].grades) do
                if v == gradeLevel then
                    outfits[#outfits + 1] = Config.Outfits[jobName][gender][i]
                    outfits[#outfits].gender = gender
                    outfits[#outfits].jobName = jobName
                end
            end
        end
    end

    return outfits
end

function OpenOutfitRoom(outfitRoom)
    local isAllowed = IsPlayerAllowedForOutfitRoom(outfitRoom)
    if isAllowed then
        OpenMenu(nil, "outfit")
    end
end

function OpenBarberShop()
    local config = GetDefaultConfig()
    config.headOverlays = true
    OpenShop(config, false, "barber")
end

function OpenTattooShop()
    local config = GetDefaultConfig()
    config.tattoos = true
    OpenShop(config, false, "tattoo")
end

function OpenSurgeonShop()
    local config = GetDefaultConfig()
    config.headBlend = true
    config.faceFeatures = true
    OpenShop(config, false, "surgeon")
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if Config.BossManagedOutfits then
            Management.RemoveItems()
        end
    end
end)
