Actions = {}

function Actions:TrackPauseMenu()
    if IsPauseMenuActive() then
        if not self.isPauseMenuOpen then
            self.isPauseMenuOpen = true
            TriggerEvent("esx:pauseMenuActive", true)
        end
    elseif self.isPauseMenuOpen then
        self.isPauseMenuOpen = false
        TriggerEvent("esx:pauseMenuActive", false)
    end
end

function Actions:TrackVehicle()
    local ped = (cache and cache.ped) or PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        if not self.inVehicle then
            self.inVehicle = true
            self.currentVehicle = vehicle
            local seat = -1
            for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                if GetPedInVehicleSeat(vehicle, i) == ped then
                    seat = i
                    break
                end
            end
            TriggerEvent("esx:enteredVehicle", vehicle, seat, GetEntityModel(vehicle))
        end
    elseif self.inVehicle then
        self.inVehicle = false
        TriggerEvent("esx:exitedVehicle", self.currentVehicle)
        self.currentVehicle = nil
    end
end

function Actions:TrackPedCoordsOnce()
    CreateThread(function()
        while ESX.PlayerLoaded do
            local ped = (cache and cache.ped) or PlayerPedId()
            local coords = GetEntityCoords(ped)
            ESX.SetPlayerData("coords", coords)
            Wait(1000)
        end
    end)
end

function Actions:SlowLoop()
    CreateThread(function()
        while ESX.PlayerLoaded do
            self:TrackPauseMenu()
            self:TrackVehicle()
            Wait(500)
        end
    end)
end

function Actions:Init()
    local ped = (cache and cache.ped) or PlayerPedId()
    ESX.SetPlayerData("ped", ped)
    ESX.SetPlayerData("weapon", (cache and cache.weapon) or GetSelectedPedWeapon(ped))

    self:SlowLoop()
    self:TrackPedCoordsOnce()
end

if lib and lib.onCache then
    lib.onCache("ped", function(ped)
        ESX.SetPlayerData("ped", ped)
        TriggerEvent("esx:playerPedChanged", ped)
    end)

    lib.onCache("weapon", function(weapon)
        ESX.SetPlayerData("weapon", weapon)
        TriggerEvent("esx:weaponChanged", weapon)
    end)
end

Actions:Init()
