local Config = require 'configs.playtimereward'

if not Config or not Config.Enabled then return end

RegisterNetEvent('cfx-keydi-utils:playtimereward:claim', function()
    TriggerServerEvent('cfx-keydi-utils:playtimereward:server:claim')
end)

exports('ClaimPlaytimeReward', function()
    TriggerServerEvent('cfx-keydi-utils:playtimereward:server:claim')
end)
