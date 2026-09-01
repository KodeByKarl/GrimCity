local ESX = exports["es_extended"]:getSharedObject()
local welcomeShown = false
-- Set while a brand-new character is in identity / appearance creation.
local suppressAutomaticWelcome = false

local function showWelcomeScreen(force)
    if welcomeShown or isIdentityOpen then
        return
    end

    if not force then
        if suppressAutomaticWelcome or IsNuiFocused() then
            return
        end
    end

    ESX.TriggerServerCallback('cfx-keydi-welcome:getWelcomeData', function(data)
        -- Re-check because another NUI (such as illenium-appearance) may
        -- have opened while the server callback was in flight.
        if not data or isIdentityOpen then
            return
        end

        if not force and (suppressAutomaticWelcome or IsNuiFocused()) then
            return
        end

        welcomeShown = true
        suppressAutomaticWelcome = false
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "cfx-keydi-welcome:show",
            data = {
                serverName = ConfigWelcome.serverName,
                playerName = data.firstName .. " " .. data.lastName,
                home = ConfigWelcome.home,
                links = ConfigWelcome.links,
                updates = ConfigWelcome.updates or {},
            }
        })
    end)
end

-- A new character enters illenium-appearance after identity registration.
-- Suppress the automatic welcome until creation is finished.
RegisterNetEvent('esx_identity:showRegisterIdentity', function()
    suppressAutomaticWelcome = true
    welcomeShown = false
    SendNUIMessage({
        action = "cfx-keydi-welcome:hide"
    })
end)

-- Returning players only. New characters (isNew) go through identity → appearance first.
RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew)
    if isNew then
        suppressAutomaticWelcome = true
        return
    end

    -- Wait a bit for the player to spawn and screen fade/transition
    Wait(5000)
    showWelcomeScreen(false)
end)

-- Fired after identity registration once appearance NUI focus has been released.
RegisterNetEvent('cfx-keydi-welcome:show', function()
    welcomeShown = false
    suppressAutomaticWelcome = false
    showWelcomeScreen(true)
end)

-- Close NUI callback from React
RegisterNUICallback("cfx-keydi-welcome:close", function(data, cb)
    if not isIdentityOpen then
        SetNuiFocus(false, false)
    end
    SendNUIMessage({
        action = "cfx-keydi-welcome:hide"
    })
    cb("ok")
end)

-- Command to manually reopen the welcome screen
RegisterCommand("welcome", function()
    welcomeShown = false
    suppressAutomaticWelcome = false
    showWelcomeScreen(true)
end, false)
