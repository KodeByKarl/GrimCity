-- Helper validations
local function checkNameFormat(name, minLength, maxLength)
    if not name then return false end
    local stringLength = string.len(name)
    local isAlphanumeric = not string.match(name, "%W")
    local hasNumbers = string.match(name, "%d")
    return isAlphanumeric and not hasNumbers and stringLength >= minLength and stringLength <= maxLength
end

local function checkSexFormat(sex)
    return sex == "m" or sex == "M" or sex == "f" or sex == "F"
end

local function checkHeightFormat(height)
    local numHeight = tonumber(height) or 0
    return numHeight >= Config.MinHeight and numHeight <= Config.MaxHeight
end

local function formatName(str)
    local lowered = string.lower(str)
    return lowered:gsub("^%l", string.upper)
end

local function formatDate(timestamp)
    if not timestamp then return os.date("%d/%m/%Y") end
    local tsNum = tonumber(timestamp)
    if not tsNum then return os.date("%d/%m/%Y") end
    local dateTable = os.date("*t", math.floor(tsNum / 1000))
    if not dateTable then return os.date("%d/%m/%Y") end
    return string.format("%02d/%02d/%04d", dateTable.day, dateTable.month, dateTable.year)
end

ESX.RegisterServerCallback('esx_identity:registerIdentity', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        IdentityUtils.Debug("registerIdentity failed: Player source %s not found.", source)
        return cb(false)
    end

    if type(data) ~= "table" then
        IdentityUtils.Debug("registerIdentity failed: Data is not a table.")
        return cb(false)
    end

    -- Format DOB from millisecond timestamp
    local formattedDob = formatDate(data.dateofbirth)
    local formattedFirstName = formatName(data.firstname)
    local formattedLastName = formatName(data.lastname)
    local formattedSex = string.lower(data.sex)

    IdentityUtils.Debug("Register identity request: First: %s, Last: %s, DOB: %s, Sex: %s, Height: %s",
        formattedFirstName, formattedLastName, formattedDob, formattedSex, data.height)

    -- Validations
    if not checkNameFormat(formattedFirstName, Config.MinFirstNameLength, Config.MaxFirstNameLength) then
        xPlayer.showNotification("Invalid first name format.", "error")
        return cb(false)
    end
    if not checkNameFormat(formattedLastName, Config.MinLastNameLength, Config.MaxLastNameLength) then
        xPlayer.showNotification("Invalid last name format.", "error")
        return cb(false)
    end
    if not checkSexFormat(formattedSex) then
        xPlayer.showNotification("Invalid gender selection.", "error")
        return cb(false)
    end
    if not checkHeightFormat(data.height) then
        xPlayer.showNotification("Invalid height. Must be realistic.", "error")
        return cb(false)
    end

    local identity = {
        firstName = formattedFirstName,
        lastName = formattedLastName,
        dateOfBirth = formattedDob,
        sex = formattedSex,
        height = tonumber(data.height)
    }

    -- Save to database
    Database.SaveIdentity(xPlayer.identifier, identity, function(success)
        if success then
            xPlayer.setName(('%s %s'):format(identity.firstName, identity.lastName))
            xPlayer.set('firstName', identity.firstName)
            xPlayer.set('lastName', identity.lastName)
            xPlayer.set('dateofbirth', identity.dateOfBirth)
            xPlayer.set('sex', identity.sex)
            xPlayer.set('height', identity.height)

            TriggerEvent('esx_identity:completedRegistration', source, {
                firstname = identity.firstName,
                lastname = identity.lastName,
                dateofbirth = identity.dateOfBirth,
                sex = identity.sex,
                height = identity.height
            })
            TriggerClientEvent('esx_identity:setPlayerData', source, identity)
            
            IdentityUtils.Debug("Character registered and saved for %s", xPlayer.identifier)
            cb(true)
        else
            xPlayer.showNotification("Error saving identity to database.", "error")
            cb(false)
        end
    end)
end)
