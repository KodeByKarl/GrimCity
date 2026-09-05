ConfigDeathScreen = ConfigDeathScreen or {}

ConfigDeathScreen.Debug = false
ConfigDeathScreen.Command = "deathscreen" -- debug / preview open
ConfigDeathScreen.AutoOpenOnDeath = true
ConfigDeathScreen.CloseOnRespawn = true
ConfigDeathScreen.FocusMouse = true

-- How long to keep combat engagement hits before reset (ms)
ConfigDeathScreen.EngagementTimeout = 45000

-- Killer ped clone preview (center cutout shows game world)
ConfigDeathScreen.Preview = {
    enabled = true,
    camDistance = 2.35,
    camHeight = 0.42,
    fov = 38.0,
    cloneOffsetZ = 0.0,
}

-- Recent eliminations kept per player (server memory)
ConfigDeathScreen.RecentKillLimit = 5
