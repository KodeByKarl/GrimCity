RegisterNUICallback("submitIdentity", function(data, cb)
    IdentityUtils.Debug("submitIdentity NUI callback triggered with: %s", json.encode(data))

    -- Validation checks
    if not data.firstName or data.firstName == "" or
       not data.lastName or data.lastName == "" or
       not data.dob or not data.height or not data.gender then
        cb({ error = "All fields are required." })
        return
    end

    local heightVal = tonumber(data.height)
    if not heightVal or heightVal < Config.MinHeight or heightVal > Config.MaxHeight then
        cb({ error = ("Height must be between %d and %d cm."):format(Config.MinHeight, Config.MaxHeight) })
        return
    end

    local payload = {
        firstname = data.firstName,
        lastname = data.lastName,
        dateofbirth = data.dob, -- Timestamp in ms
        height = heightVal,
        sex = Constants.Genders[data.gender] or "m"
    }

    RegisterCharacter(payload)
    cb({ success = true })
end)

RegisterNUICallback("closeUI", function(data, cb)
    ToggleUI(false)
    cb({ ok = true })
end)
