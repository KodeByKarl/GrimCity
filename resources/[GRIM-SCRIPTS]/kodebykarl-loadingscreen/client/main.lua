--- Multicharacter already calls ShutdownLoadingScreen / ShutdownLoadingScreenNui.
--- Export + event for non-multichar / manual fallbacks.

local shutDown = false

local function RequestShutdown()
    if shutDown then return end
    shutDown = true
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
end

exports('RequestShutdown', RequestShutdown)

AddEventHandler('esx:loadingScreenOff', function()
    RequestShutdown()
end)

RegisterNetEvent('kodebykarl-loadingscreen:shutdown', function()
    RequestShutdown()
end)
