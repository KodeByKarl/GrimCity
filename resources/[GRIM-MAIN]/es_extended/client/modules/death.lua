Death = {}
Death._index = Death

function Death:ResetValues()
    self.killerEntity = nil
    self.deathCause = nil
    self.killerId = nil
    self.killerServerId = nil
end

function Death:ByPlayer()
    local victimCoords = GetEntityCoords(ESX.PlayerData.ped)
    local killerCoords = GetEntityCoords(self.killerEntity)
    local distance = #(victimCoords - killerCoords)

    local data = {
        victimCoords = { x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1), z = ESX.Math.Round(victimCoords.z, 1) },
        killerCoords = { x = ESX.Math.Round(killerCoords.x, 1), y = ESX.Math.Round(killerCoords.y, 1), z = ESX.Math.Round(killerCoords.z, 1) },

        killedByPlayer = true,
        deathCause = self.deathCause,
        distance = ESX.Math.Round(distance, 1),

        killerServerId = self.killerServerId,
        killerClientId = self.killerId,
    }

    TriggerEvent("esx:onPlayerDeath", data)
    TriggerServerEvent("esx:onPlayerDeath", data)
end

function Death:Natural()
    local coords = GetEntityCoords(ESX.PlayerData.ped)

    local data = {
        victimCoords = { x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1) },

        killedByPlayer = false,
        deathCause = self.deathCause,
    }

    TriggerEvent("esx:onPlayerDeath", data)
    TriggerServerEvent("esx:onPlayerDeath", data)
end

--- Exploding / rammed vehicles report as the killer entity. Attribute to the
--- last driver, or the player who still network-owns the spawned vehicle.
function Death:ResolveVehicleKiller(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) or IsPedAPlayer(entity) then
        return
    end

    local myServerId = GetPlayerServerId(PlayerId())
    local candidate = 0

    if IsEntityAVehicle(entity) then
        candidate = GetLastPedInVehicleSeat(entity, -1)
        if not candidate or candidate == 0 then
            candidate = GetPedInVehicleSeat(entity, -1)
        end
    end

    if candidate and candidate ~= 0 and IsPedAPlayer(candidate) then
        local idx = NetworkGetPlayerIndexFromPed(candidate)
        local sid = GetPlayerServerId(idx)
        if idx and NetworkIsPlayerActive(idx) and sid and sid > 0 and sid ~= myServerId then
            self.killerEntity = candidate
            self.killerId = idx
            self.killerServerId = sid
            return
        end
    end

    if NetworkGetEntityIsNetworked(entity) then
        local owner = NetworkGetEntityOwner(entity)
        if owner and owner ~= -1 and NetworkIsPlayerActive(owner) then
            local sid = GetPlayerServerId(owner)
            if sid and sid > 0 and sid ~= myServerId then
                self.killerEntity = GetPlayerPed(owner)
                self.killerId = owner
                self.killerServerId = sid
            end
        end
    end
end

function Death:Died()
    self.killerEntity = GetPedSourceOfDeath(ESX.PlayerData.ped)
    self.deathCause = GetPedCauseOfDeath(ESX.PlayerData.ped)
    self.killerId = NetworkGetPlayerIndexFromPed(self.killerEntity)
    self.killerServerId = GetPlayerServerId(self.killerId)

    local isActive = NetworkIsPlayerActive(self.killerId)

    if not (self.killerEntity ~= ESX.PlayerData.ped and self.killerId and isActive) then
        self:ResolveVehicleKiller(self.killerEntity)
        isActive = NetworkIsPlayerActive(self.killerId)
    end

    if self.killerEntity ~= ESX.PlayerData.ped and self.killerId and isActive then
        self:ByPlayer()
    else
        self:Natural()
    end

    self:ResetValues()
end

AddEventHandler("esx:onPlayerSpawn", function()
    Citizen.CreateThreadNow(function()
        while not ESX.PlayerLoaded do Wait(0) end

        while ESX.PlayerLoaded and not ESX.PlayerData.dead do
            if DoesEntityExist(ESX.PlayerData.ped) and (IsPedDeadOrDying(ESX.PlayerData.ped, true) or IsPedFatallyInjured(ESX.PlayerData.ped)) then
                Death:Died()
                break
            end
            Citizen.Wait(250)
        end
    end)
end)
