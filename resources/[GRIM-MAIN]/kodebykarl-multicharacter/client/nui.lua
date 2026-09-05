local ESX = exports["es_extended"]:getSharedObject()

RegisterNUICallback("previewCharacter", function(data, cb)
    data = type(data) == "table" and data or {}

    if data.clearPreview then
        DestroyPreviewPed()
        ClearScriptCam()
        cb("ok")
        return
    end

    local skinData = data.skin
    if type(skinData) ~= "table" then
        skinData = {}
    end

    if data.rawSex then skinData.rawSex = data.rawSex end
    if data.sex then skinData.sex = data.sex end

    SpawnCharacterPreview(skinData, Config.Multicharacter.DefaultSpawn)
    cb("ok")
end)

RegisterNUICallback("vipSlotLocked", function(data, cb)
    local slot = tonumber(data and data.slot) or 2
    lib.notify({
        title = "MultiVIP Required",
        description = ("Slot %s needs MultiVIP access. Ask staff to unlock it."):format(slot),
        type = "error",
        position = "top-center",
    })
    cb("ok")
end)

RegisterNUICallback("closeMultivip", function(_, cb)
    CloseMultivip()
    cb({ ok = true })
end)

RegisterNUICallback("setMultivipSlots", function(data, cb)
    data = type(data) == "table" and data or {}
    ESX.TriggerServerCallback("esx_multicharacter:setVipSlots", function(result)
        cb(result or { ok = false })
    end, data)
end)

RegisterNUICallback("selectCharacter", function(data, cb)
    local charId = data.charId
    if charId then
        SetPendingNewCharacter(false)
        TriggerServerEvent('esx_multicharacter:CharacterChosen', charId, false)
        CloseMulticharacter()
        cb({ success = true })
    else
        cb({ success = false })
    end
end)

RegisterNUICallback("createCharacter", function(data, cb)
    if not data or not data.firstname or not data.lastname then
        cb({ success = false, message = "Invalid data" })
        return
    end

    ESX.TriggerServerCallback("esx_multicharacter:createCharacter", function(success, charId)
        if success then
            SetPendingNewCharacter(true)
            TriggerServerEvent('esx_multicharacter:CharacterChosen', charId, true)
            CloseMulticharacter()
        else
            lib.notify({
                title = "Character Slots",
                description = "No free character slot. Unlock slot 2 or 3 with /Multivip.",
                type = "error",
                position = "top-center",
            })
        end
        cb({ success = success })
    end, data)
end)

RegisterNUICallback("deleteCharacter", function(data, cb)
    local charId = data.charId
    if charId then
        ESX.TriggerServerCallback("esx_multicharacter:deleteCharacter", function(success)
            if success then
                lib.notify({
                    title = "Character Deleted",
                    description = "Character deleted successfully.",
                    type = "success",
                    position = "top-center",
                })
                RefreshCharacters()
            else
                lib.notify({
                    title = "Character Delete",
                    description = "Could not delete character.",
                    type = "error",
                    position = "top-center",
                })
            end
            cb({ success = success })
        end, charId)
    else
        cb({ success = false })
    end
end)

RegisterNUICallback("close", function(data, cb)
    CloseMulticharacter()
    cb("ok")
end)
