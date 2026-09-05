local RESOURCE_NAME = "jg-dealerships"
local print = function(...) end

local VERSION_URL   = "https://raw.githubusercontent.com/jgscripts/versions/main/" .. RESOURCE_NAME .. ".txt"

local function isNewerVersion(current, latest)

    local currentParts = {}

    for part in string.gmatch(current, "[^.]+") do

        table.insert(currentParts, tonumber(part))

    end

    local latestParts = {}

    for part in string.gmatch(latest, "[^.]+") do

        table.insert(latestParts, tonumber(part))

    end

    local length = math.max(#currentParts, #latestParts)

    for i = 1, length do

        local c = currentParts[i] or 0

        local l = latestParts[i] or 0

        if c < l then

            return true

        elseif c > l then

            return false

        end

    end

    return false

end

local function onVersionCheckResponse(statusCode, body, headers, errorData)

    if statusCode ~= 200 then

        print("^1[" .. RESOURCE_NAME .. "] Unable to perform update check (HTTP " .. tostring(statusCode) .. ")")

        print("^3[ByTcHub] ^1discord.gg/tchub ")

        print("^3[ByTcHub] Fixed By ByTcHub!")

        print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        if errorData then

            print("^1[" .. RESOURCE_NAME .. "] Error: " .. tostring(errorData) .. "^0")

            print("^3[ByTcHub] ^1discord.gg/tchub ")

            print("^3[ByTcHub] Fixed By ByTcHub!")

            print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        end

        return

    end

    if not body or body == "" then

        print("^1[" .. RESOURCE_NAME .. "] Update check failed: Empty response^0")

        print("^3[ByTcHub] ^1discord.gg/tchub ")

        print("^3[ByTcHub] Fixed By ByTcHub!")

        print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        return

    end

    local installedVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

    if not installedVersion then

        print("^1[" .. RESOURCE_NAME .. "] Could not retrieve installed version^0")

        print("^3[ByTcHub] ^1discord.gg/tchub ")

        print("^3[ByTcHub] Fixed By ByTcHub!")

        print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        return

    end

    if installedVersion == "dev" then

        print("^3[" .. RESOURCE_NAME .. "] Using dev version^0")

        print("^3[ByTcHub] ^1discord.gg/tchub ")

        print("^3[ByTcHub] Fixed By ByTcHub!")

        print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        return

    end

    local latestVersion = body:match("^[^\n]+")

    if not latestVersion then

        print("^1[" .. RESOURCE_NAME .. "] Could not parse version from response^0")

        print("^3[ByTcHub] ^1discord.gg/tchub ")

        print("^3[ByTcHub] Fixed By ByTcHub!")

        print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        return

    end

    local currentVer = installedVersion:match("^v?(.+)") or installedVersion

    local latestVer = latestVersion:match("^v?(.+)") or latestVersion

    if isNewerVersion(currentVer, latestVer) then

        print(

            "^3[" .. RESOURCE_NAME .. "] Update available! " ..

            "(current: ^1" .. installedVersion ..

            "^3, latest: ^2" .. latestVersion .. "^3)^0"

        )

        print("^3[ByTcHub] ^1discord.gg/tchub ")

        print("^3[ByTcHub] Fixed By ByTcHub!")

        print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        print("^3[" .. RESOURCE_NAME .. "] Release notes: discord.gg/jgscripts^0")

    else

        print("^2[" .. RESOURCE_NAME .. "] Version up to date (" .. installedVersion .. ")^0")

    end

end

CreateThread(function()

    PerformHttpRequest(VERSION_URL, onVersionCheckResponse, "GET")

end)

local function checkArtifactVersion()

    local serverVersion = GetConvar("version", "unknown")

    local buildNumber   = string.match(serverVersion, "v%d+%.%d+%.%d+%.(%d+)")

    if not buildNumber then

        print("^3[" .. RESOURCE_NAME .. "] Could not parse server build number from version: " .. serverVersion .. "^0")

        print("^3[ByTcHub] ^1discord.gg/tchub ")

        print("^3[ByTcHub] Fixed By ByTcHub!")

        print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        return

    end

    local artifactCheckUrl = "https://artifacts.jgscripts.com/check?artifact=" .. buildNumber

    PerformHttpRequest(artifactCheckUrl, function(statusCode, body, _, errorData)

        if statusCode ~= 200 then

            print("^1[" .. RESOURCE_NAME .. "] Could not check artifact version (HTTP " .. tostring(statusCode) .. ")^0")

            if errorData then

                print("^1[" .. RESOURCE_NAME .. "] Error: " .. tostring(errorData) .. "^0")

                print("^3[ByTcHub] ^1discord.gg/tchub ")

                print("^3[ByTcHub] Fixed By ByTcHub!")

                print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

            end

            return

        end

        if not body or body == "" then

            print("^1[" .. RESOURCE_NAME .. "] Artifact check failed: Empty response^0")

            print("^3[ByTcHub] ^1discord.gg/tchub ")

            print("^3[ByTcHub] Fixed By ByTcHub!")

            print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

            return

        end

        local success, data = pcall(json.decode, body)

        if not success then

            print("^1[" .. RESOURCE_NAME .. "] Failed to parse artifact check response^0")

            print("^3[ByTcHub] ^1discord.gg/tchub ")

            print("^3[ByTcHub] Fixed By ByTcHub!")

            print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

            return

        end

        if not data then

            print("^1[" .. RESOURCE_NAME .. "] Invalid artifact check response^0")

            print("^3[ByTcHub] ^1discord.gg/tchub ")

            print("^3[ByTcHub] Fixed By ByTcHub!")

            print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

            return

        end

        if data.status == "BROKEN" then

            print(

                "^1WARNING: The current FXServer version you are using (artifacts version) has known issues. " ..

                "Please update to the latest stable artifacts: https://artifacts.jgscripts.com^0"

            )

            print("^0Artifact version:^3", serverVersion, "\n^0Known issues:^3", data.reason or "Unknown", "^0")

            print("^3[ByTcHub] ^1discord.gg/tchub ")

            print("^3[ByTcHub] Fixed By ByTcHub!")

            print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        elseif data.status == "OK" then

            print("^2[" .. RESOURCE_NAME .. "] Server artifact version is OK (" .. serverVersion .. ")^0")

            print("^3[ByTcHub] ^1discord.gg/tchub ")

            print("^3[ByTcHub] Fixed By ByTcHub!")

            print("^3[ByTcHub] U have any problem just open a ticket on discord.gg/tchub and will fix it!")

        end

    end)

end

CreateThread(function()

    Wait(1000)
    checkArtifactVersion()

end)
