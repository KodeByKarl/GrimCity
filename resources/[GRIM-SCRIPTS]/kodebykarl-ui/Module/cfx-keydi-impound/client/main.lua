RegisterNetEvent("cfx-keydi-impound:client:startCountdown", function(duration)
    SendNUIMessage({
        action = "cfx-keydi-impound:show",
        duration = duration
    })
end)

RegisterNetEvent("cfx-keydi-impound:client:completed", function()
    SendNUIMessage({
        action = "cfx-keydi-impound:completed"
    })
end)
