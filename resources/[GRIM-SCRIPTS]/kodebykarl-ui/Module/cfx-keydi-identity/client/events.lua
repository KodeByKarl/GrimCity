RegisterNetEvent("esx_identity:showRegisterIdentity", function()
    IdentityUtils.Debug("Received event esx_identity:showRegisterIdentity")

    -- Reset skin on first spawn if needed
    TriggerEvent("esx_skin:resetFirstSpawn")

    CreateThread(function()
        -- Wait until ESX finished spawning / loading screen teardown
        local deadline = GetGameTimer() + 15000
        while GetGameTimer() < deadline do
            if ESX.PlayerLoaded and DoesEntityExist(PlayerPedId()) and not IsScreenFadedOut() then
                break
            end
            Wait(100)
        end

        -- Small buffer so ShutdownLoadingScreenNui / HUD init don't clear focus
        Wait(750)

        if ESX.PlayerData and ESX.PlayerData.dead then
            return
        end

        if isIdentityOpen then
            -- Already open — re-assert lock
            ToggleUI(true)
            return
        end

        ToggleUI(true)
    end)
end)

RegisterNetEvent("esx_identity:alreadyRegistered", function()
    IdentityUtils.Debug("Player is already registered. Triggering skin load.")
    TriggerEvent("esx_skin:playerRegistered")
end)
