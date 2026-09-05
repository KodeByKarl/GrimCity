local currentGang = nil

RegisterNetEvent('kodebykarl-gangsystem:client:setGang', function(gang)
    currentGang = gang
    LocalPlayer.state:set('gang', gang, true)
end)

AddStateBagChangeHandler('gang', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(_, _, value)
    currentGang = value
end)

function IsInGang(gangId)
    if not currentGang then
        currentGang = LocalPlayer.state.gang
    end
    if not currentGang then return false end
    if gangId then return currentGang.name == gangId end
    return true
end

function GetLocalGang()
    return currentGang or LocalPlayer.state.gang
end

exports('GetLocalGang', GetLocalGang)
exports('IsInGang', IsInGang)

CreateThread(function()
    Wait(1500)
    currentGang = LocalPlayer.state.gang
end)
