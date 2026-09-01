if Config.EnableCommands then
    RegisterCommand("register", function()
        if Config.Debug then
            IdentityUtils.Debug("Triggered /register test command")
            ToggleUI(true)
        end
    end, false)

    RegisterCommand("closereg", function()
        if Config.Debug then
            IdentityUtils.Debug("Triggered /closereg test command")
            ToggleUI(false)
        end
    end, false)
end
