ConfigScoreboard = {}

ConfigScoreboard.Debug = false

ConfigScoreboard.ServerName = "Pandora City" -- Display name of your server in the scoreboard
ConfigScoreboard.EnablePriorityStatus = true -- Set to true to show Priority Status in the scoreboard, false to hide it

-- After a robbery ends (or PD sets Cooldown): wait this long, then auto Safe
ConfigScoreboard.PriorityCooldownSeconds = 15 * 60

ConfigScoreboard.ToggleKey = 'F10' -- Default keybind to toggle the scoreboard

-- Jobs we want to count online in the scoreboard
ConfigScoreboard.Jobs = {
    { name = "LS EMS", job = "ambulance" },
    { name = "LS Police", job = "police" },
    { name = "Mechanic", job = "mechanic" },
}

-- World events config
ConfigScoreboard.WorldEvents = {
    { name = "Airdrop", location = "Sandy Shores", status = "INACTIVE" },
    { name = "Traphouse", location = "Unknown", status = "INACTIVE" },
    { name = "Turf Wars", location = "Unknown", status = "INACTIVE" }
}

-- Default refresh interval for scoreboard metrics on client (in ms)
ConfigScoreboard.RefreshInterval = 5000

-- Discord integration
ConfigScoreboard.DiscordBotToken = "" -- Add your Discord Bot Token here to enable profile picture sync
