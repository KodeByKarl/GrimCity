ConfigRadioList = ConfigRadioList or {}

ConfigRadioList.Debug = false

-- Commands
ConfigRadioList.ToggleListCommand = "radiolist" -- Toggle full player roster modal
ConfigRadioList.EditPosCommand = "moveradio"      -- Toggle HUD edit/drag mode
ConfigRadioList.ToggleHudCommand = "toggleradio"  -- Toggle HUD visibility

-- Default Channel Name Format (matches cfx-keydi-radio frequencyStep 0.01)
ConfigRadioList.FormatFrequency = function(channel)
    if not channel or channel == 0 then return "Disconnected" end
    return string.format("%.2f MHz", tonumber(channel) or 0.0)
end

-- Allowed jobs to see specific private radio info if needed
ConfigRadioList.LetPlayersDragHud = true
