RegisterNetEvent("esx_identity:showRegisterIdentity", function()
    IdentityUtils.Debug("Received event esx_identity:showRegisterIdentity")
    ToggleUI(true)
end)

RegisterNetEvent("esx_identity:alreadyRegistered", function()
    IdentityUtils.Debug("Player is already registered. Triggering skin load.")
    TriggerEvent("esx_skin:playerRegistered")
end)
