ConfigModules = {}

ConfigModules.Debug = false
ConfigModules.OpenCommand = "controlcenter"
ConfigModules.ToggleKey = "F5" -- Key mapping to open the Control Center Settings Menu

-- Regions live in Module/cfx-keydi-serverlocations (in-game bucket switch).
-- Keep these flags in sync with ConfigServerLocations for the Control Center UI.
ConfigModules.RequireSafezone = true
ConfigModules.LockInJail = true
ConfigModules.LockInArena = true
ConfigModules.LockInJobInstance = false -- job instances are left by switching back to a public server
