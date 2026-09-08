local ESX = exports["es_extended"]:getSharedObject()
local welcomeShown = false
-- Set while a brand-new character is in appearance creation.
local suppressAutomaticWelcome = false

local function showWelcomeScreen(force)
    if welcomeShown then
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
        if not data then
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

-- Returning players only. New characters (isNew) go through appearance first.
-- Show during multichar blackout (right after slot select), not 5s+ after spawn fade-in.
RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew)
    if isNew then
        suppressAutomaticWelcome = true
        return
    end

    CreateThread(function()
        -- Yield so kodebykarl-multicharacter can CloseMulticharacter / fade out first.
        Wait(0)

        local deadline = GetGameTimer() + 2000
        while GetGameTimer() < deadline do
            if IsScreenFadedOut() and not IsNuiFocused() then
                break
            end
            Wait(50)
        end

        -- force=true: ignore IsNuiFocused (spawn may still settle) and show over blackout
        showWelcomeScreen(true)
    end)
end)

-- Fired after appearance creation for new characters.
RegisterNetEvent('cfx-keydi-welcome:show', function()
    welcomeShown = false
    suppressAutomaticWelcome = false
    showWelcomeScreen(true)
end)

-- Close NUI callback from React
RegisterNUICallback("cfx-keydi-welcome:close", function(data, cb)
    SetNuiFocus(false, false)
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
