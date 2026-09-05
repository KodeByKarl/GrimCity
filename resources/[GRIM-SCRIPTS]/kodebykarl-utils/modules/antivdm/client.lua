local Config = require 'configs.antivdm'

if not Config or not Config.Enabled then
    return
end

local radius = Config.PedNoCollisionDistance or 12.0
local disableRunOver = Config.DisableRunOverDamage ~= false
local WEAPON_RUN_OVER = `WEAPON_RUN_OVER_BY_CAR`
local WEAPON_RAMMED = `WEAPON_RAMMED_BY_CAR`

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if ped ~= 0 and not IsPedInAnyVehicle(ped, false) then
            local coords = GetEntityCoords(ped)
            local vehicles = GetGamePool('CVehicle')
            for i = 1, #vehicles do
                local veh = vehicles[i]
                if veh ~= 0 and DoesEntityExist(veh) and #(coords - GetEntityCoords(veh)) < radius then
                    SetEntityNoCollisionEntity(ped, veh, true)
                end
            end
            if disableRunOver then
                SetWeaponDamageModifierThisFrame(WEAPON_RUN_OVER, 0.0)
                SetWeaponDamageModifierThisFrame(WEAPON_RAMMED, 0.0)
            end
            Wait(0)
        else
            Wait(400)
        end
    end
end)
