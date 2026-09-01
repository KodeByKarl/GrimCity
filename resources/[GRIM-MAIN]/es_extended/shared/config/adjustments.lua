Config.DisableHealthRegeneration = false -- Player will no longer regenerate health
Config.DisableVehicleRewards = true      -- Disables Player Receiving weapons from vehicles
Config.DisableNPCDrops = true            -- stops NPCs from dropping weapons on death
Config.DisableDispatchServices = true    -- Disable Dispatch services
Config.DisableScenarios = true           -- Disable Scenarios
Config.DisableAimAssist = false           -- disables AIM assist (mainly on controllers)
Config.DisableVehicleSeatShuff = false   -- Disables vehicle seat shuff
Config.DisableDisplayAmmo = false         -- Disable ammunition display
Config.EnablePVP = true                   -- Allow Player to player combat
Config.EnableWantedLevel = false          -- Disable Normal GTA wanted Level

Config.RemoveHudComponents = {
    [1] = true,   -- WANTED_STARS
    [2] = false,  -- WEAPON_ICON
    [3] = false,  -- CASH
    [4] = false,  -- MP_CASH
    [5] = false,  -- MP_MESSAGE
    [6] = false,  -- VEHICLE_NAME
    [7] = false,  -- AREA_NAME
    [8] = false,  -- VEHICLE_CLASS
    [9] = false,  -- STREET_NAME
    [10] = false, -- HELP_TEXT
    [11] = false, -- FLOATING_HELP_TEXT_1
    [12] = false, -- FLOATING_HELP_TEXT_2
    [13] = false, -- CASH_CHANGE
    [14] = false, -- RETICLE
    [15] = false, -- SUBTITLE_TEXT
    [16] = false, -- RADIO_STATIONS
    [17] = false, -- SAVING_GAME
    [18] = false, -- GAME_STREAM
    [19] = false, -- WEAPON_WHEEL
    [20] = false, -- WEAPON_WHEEL_STATS
    [21] = false, -- HUD_COMPONENTS
    [22] = false, -- HUD_WEAPONS
}

Config.Multipliers = {
    pedDensity = 0.0,
    scenarioPedDensityInterior = 0.0,
    scenarioPedDensityExterior = 0.0,
    ambientVehicleRange = 0.0,
    parkedVehicleDensity = 0.0,
    randomVehicleDensity = 0.0,
    vehicleDensity = 0.0
}

Config.CustomAIPlates = "........"

Config.DiscordActivity = {
    appId = 0,
    assetName = "LargeIcon",
    assetText = "{server_name}",
    buttons = {
        { label = "Join Server", url = "fivem://connect/{server_endpoint}" },
        { label = "Discord",     url = "https://discord.esx-framework.org" },
    },
    presence = "{player_name} [{player_id}] | {server_players}/{server_maxplayers}",
    refresh = 1 * 60 * 1000,
}
