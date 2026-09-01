ConfigIndicator = {}

ConfigIndicator.Debug = false

-- Default settings that will be sent to the React UI and loaded on player join.
-- These are fully modifiable in-game via the style control settings menu.
ConfigIndicator.DefaultSettings = {
    deadText = "Dead",
    deadIcon = "skull", -- skull, crossbones, heart-crack, ghost, danger, sick, x-mark, skull-io, ban
    fontFamily = "JetBrains Mono",
    fontSize = 18,
    duration = 3.0,
    healthColor = "#f87171",
    armorColor = "#60a5fa"
}
