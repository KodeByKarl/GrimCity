-----------------------------------------------------------------
-- cfx-keydi-radio config
-----------------------------------------------------------------

--- Jobs allowed on emergency bands (all three can use 1.x / 2.x / 3.x)
local emergencyJobs = {
    police = 0,
    ambulance = 0,
    sheriff = 0,
}

--- Build per-frequency restrictions for pma-voice channel checks.
--- Bands:
---   1.00–1.99  Police band
---   2.00–2.99  Ambulance band
---   3.00–3.99  Sheriff band
local function buildRestrictedChannels()
    local channels = {}
    local bands = {
        { min = 1.00, max = 1.99 },
        { min = 2.00, max = 2.99 },
        { min = 3.00, max = 3.99 },
    }

    for i = 1, #bands do
        local minH = math.floor(bands[i].min * 100 + 0.5)
        local maxH = math.floor(bands[i].max * 100 + 0.5)
        for h = minH, maxH do
            channels[h / 100] = emergencyJobs
        end
    end

    return channels
end

local restrictedChannels = buildRestrictedChannels()

return {
    -- Enable usable item for opening the radio
    useUsableItem = true,

    -- Enable command for opening the radio
    useCommand = false,

    -- Default keybind for the '/radio' command
    commandKey = '',

    -- Enable disconnecting from frequency when there is no radio item left in player's inventory
    disconnectWithoutRadio = true,

    -- Percentage of volume to increase/decrease per step
    volumeStep = 10,

    -- Frequency decimal precision
    frequencyStep = 0.01,

    -- Maximum amount of available frequencies (starting from 0)
    maximumFrequencies = 1000,

    -- Frequency restrictions (generated from emergency bands above)
    -- police / ambulance / sheriff can all join 1.x, 2.x, and 3.x
    restrictedChannels = restrictedChannels,

    ---@param frequency number
    ---@return boolean
    isRestrictedFrequency = function(frequency)
        frequency = tonumber(frequency)
        if not frequency then return false end
        if restrictedChannels[frequency] then return true end
        local key = math.floor(frequency * 100 + 0.5) / 100
        return restrictedChannels[key] ~= nil
    end,

    -- ! The following options will override pma-voice convars
    -- Enable radio voice effect (voice sounds like on a real radio)
    radioEffect = true,

    -- Enable animation while talking on radio
    radioAnimation = true,

    -- Default keybind for talking on radio
    radioTalkKey = 'LMENU',
}
