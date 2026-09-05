ConfigScoreboard = {}

ConfigScoreboard.Debug = false

ConfigScoreboard.ServerName = "Grim City" -- Display name of your server in the scoreboard
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

-- World events config (location/status overwritten live via exports['kodebykarl-ui']:SetWorldEvent)
ConfigScoreboard.WorldEvents = {
    { name = "Airdrop", location = "—", status = "INACTIVE" },
    { name = "Traphouse", location = "—", status = "INACTIVE" },
    { name = "Turf Wars", location = "—", status = "INACTIVE" }
}

-- Default refresh interval for scoreboard metrics on client (in ms)
ConfigScoreboard.RefreshInterval = 5000

-- Discord integration
ConfigScoreboard.DiscordBotToken = "" -- Add your Discord Bot Token here to enable profile picture sync
