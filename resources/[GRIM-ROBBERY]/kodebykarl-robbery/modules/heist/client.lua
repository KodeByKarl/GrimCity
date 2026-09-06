local ox_target = exports.ox_target
local _AddStateBagChangeHandler = AddStateBagChangeHandler
local _CreateThread = CreateThread
local playerState = LocalPlayer.state
playerState.inTraphouse = false
local BigHeist = {
    isBusy = {},
    timer = {},
    destroy = {},
    markerCache = {},
    blipCache = {},
    debugBlipCache = {},
    debugPointsCache = {}
}

AddEventHandler('ESX:Client:PlayerLoaded', function()
    
end)

function StartBigHeist(data)
    local key = data.args.key
    local config = Config.Heist[key]

    if not config.settings.disablePCheck then
        local isOnHold = GlobalState.PriorityPolice.canRob
        if not isOnHold then
            ESX.Notify('[SYSTEM]: Priority', config.label..' is on hold', 'warning', 5000)
            return
        end
    end

    --[[ local robbery = exports['cfx-cs-scoreboard']:CheckLawEnforcementByTable(config.require)
    if not robbery.enable then
        ESX.Notify('ROBBERY - '..config.label, ('There must be at least %s %s in town to rob.'):format(robbery.count, robbery.name), 'error', 5000)
        return
    end ]]
    local canRob = lib.callback.await('cfx-cs-robbery:check', false, key)
    if not canRob then return end

    if config.requireItem and next(config.requireItem) then
        local hasItem = HasItem(config.requireItem)
        if not hasItem then return end
    end

    if config.minigame then
        if config.minigame.game == 'lockpick' then
            local success = exports['cfx-cs-lockpick']:StartLockpickGame(config.minigame.lockpickCount)
            if not success then
                ESX.Notify('ROBBERY - '..config.label, 'Failed.', 'error', 5000)
                return
            end
        end
        if config.minigame.game == 'skillCheck' then
            local success = lib.skillCheck(config.minigame.skillCheck, {'w', 'a', 's', 'd'})
            if not success then
                ESX.Notify('ROBBERY - '..config.label, 'Failed.', 'error', 5000)
                return
            end
        end
    end

    TriggerServerEvent('cfx-cs-robbery:StartTimer', key)
end

local function setStateBagHandlers(blipId, notifyId, gubed)
    _AddStateBagChangeHandler(blipId, "global", function(_, theGlobalKey, value)
        local theKey = theGlobalKey:gsub('_blip', '')
        local config = Config.Heist[theKey]
        if value then
            local coords = config.ped and config.ped.coords.xyz or config.marker.coords
            BigHeist.blipCache[blipId] = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(BigHeist.blipCache[blipId], 161)
            SetBlipScale(BigHeist.blipCache[blipId], 1.5)
            SetBlipColour(BigHeist.blipCache[blipId], 1)
            PulseBlip(BigHeist.blipCache[blipId])
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName('Illegal Activity')
            EndTextCommandSetBlipName(BigHeist.blipCache[blipId])
        else
            if BigHeist.blipCache[blipId] and DoesBlipExist(BigHeist.blipCache[blipId]) then
                RemoveBlip(BigHeist.blipCache[blipId])
                BigHeist.blipCache[blipId] = nil
            end
        end
    end)
    if notifyId then
        _AddStateBagChangeHandler(notifyId, "global", function(_, theGlobalKey, value)
            local theKey = theGlobalKey:gsub('_notify', '')
            local config = Config.Heist[theKey]
            if value then
                lib.notify({
                    title = 'Illegal Activity',
                    description = 'Ongoing '..config.label,
                    duration = 15000, -- Keep it persistent for announcements
                    position = 'top-center', -- Center the announcement at the top
                    icon = 'bullhorn', -- Use an icon that represents an announcement
                    iconColor = '#E53E3E', -- Red icon color for importance
                    style = {
                        backgroundColor = '#1A202C', -- Darker background for emphasis
                        color = '#FFFFFF', -- Bright text color for contrast
                        fontSize = '16px', -- Larger font size for visibility
                        fontWeight = 'bold', -- Make text bold for impact
                        border = '2px solid #E53E3E', -- Red border for urgency
                        padding = '16px', -- Add padding for better spacing
                        borderRadius = '8px', -- Rounded edges for a clean look
                        boxShadow = '0px 4px 10px rgba(0, 0, 0, 0.4)', -- Subtle shadow for depth
                        ['.description'] = {
                            color = '#F7FAFC', -- Lighter description text
                            fontSize = '13px', -- Slightly smaller for hierarchy
                        }
                    },
                })
            end
        end)
    end

    if gubed then
        _AddStateBagChangeHandler(gubed, "global", function(_, theGlobalKey, value)
            local theKey = theGlobalKey:gsub('_debug', '')
            local config = Config.Heist[theKey]
            local coords = config.ped and config.ped.coords.xyz or config.marker.coords
            if value then
                local cPoint = lib.points.new({
                    coords = coords,
                    distance = config.debug.ZoneSize,
                    zoneCoords = coords,
                    blipSize = config.debug.blipSize,
                    ZoneSize = config.debug.ZoneSize
                })
                function cPoint:nearby()
                    DrawMarker(28, self.zoneCoords.x, self.zoneCoords.y, self.zoneCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.ZoneSize, self.ZoneSize, self.ZoneSize, 255, 0, 0, 40, false, false, 2, true, false, false, false)
                end
                function cPoint:onEnter()
                    --[[ local redzoneBlip = AddBlipForRadius(self.zoneCoords.x, self.zoneCoords.y, self.zoneCoords.z, self.blipSize + 0.0)
                    SetBlipColour(redzoneBlip, 1)
                    SetBlipAlpha(redzoneBlip, 200)
                    BigHeist.debugBlipCache[theKey] = redzoneBlip ]]
                    SetInTraphouse(true)
                    if not BigHeist.timer[theKey] and not Player(cache.serverId).state.dead then
                        lib.showTextUI('You are in a traphouse zone. This area is kill on sight.', {
                            position = "bottom-center",
                            icon = 'fa-solid fa-skull-crossbones',
                            iconColor = '#FF0949',
                            style = {
                                backgroundColor = '#2E2E2E', -- Slightly lighter background for better contrast
                                color = '#F1F1F1', -- Softer white text for reduced strain on the eyes
                                padding = '12px 24px', -- Adds more spacing for a cleaner look
                                borderRadius = '8px', -- Rounded corners for a modern look
                                border = '2px solid #FF0949', -- Adds a border matching the icon color
                                fontSize = '16px', -- Clear and readable text size
                                fontFamily = 'Arial, sans-serif', -- Clean and widely supported font
                                textAlign = 'center', -- Centers the text nicely
                                boxShadow = '0 4px 20px rgba(0, 0, 0, 0.7)', -- Larger and softer shadow
                                transition = 'all 0.3s ease', -- Smooth transition for hover effects
                                hover = {
                                    backgroundColor = '#FF0949', -- Changes background color on hover
                                    color = '#212121', -- Inverts text color on hover
                                },
                                ['.description'] = {
                                    color = '#D1D1D1', -- Subtle contrast for description text
                                    fontSize = '14px', -- Slightly smaller for descriptions
                                }
                            }
                        })
                    end
                end
                function cPoint:onExit()
                    SetInTraphouse(false)
                    --[[ if BigHeist.debugBlipCache[theKey] then
                        if DoesBlipExist(BigHeist.debugBlipCache[theKey]) then
                            RemoveBlip(BigHeist.debugBlipCache[theKey])
                        end
                    end ]]
                    if not BigHeist.timer[theKey] and not Player(cache.serverId).state.dead then
                        lib.hideTextUI()
                    end
                end
                BigHeist.debugPointsCache[theKey] = cPoint
            else
                SetInTraphouse(false)
                if BigHeist.debugPointsCache[theKey] then
                    BigHeist.debugPointsCache[theKey]:remove()
                    BigHeist.debugPointsCache[theKey] = nil
                end
                if BigHeist.debugBlipCache[theKey] then
                    if DoesBlipExist(BigHeist.debugBlipCache[theKey]) then
                        RemoveBlip(BigHeist.debugBlipCache[theKey])
                    end
                    BigHeist.debugBlipCache[theKey] = nil
                end
                if not BigHeist.timer[theKey] and not Player(cache.serverId).state.dead then
                    lib.hideTextUI()
                end
            end
        end)
    end
end

function SetInTraphouse(state)
    if type(state) ~= "boolean" then return end
    playerState.inTraphouse = state
end

function LoadBigHeist()
    _CreateThread(function()
        for i = 1, 99 do
            local trapKey = "trap" .. i
            if Config.Heist[trapKey] and Config.Heist[trapKey].marker and Config.Heist[trapKey].debug then
                local coords = Config.Heist[trapKey].marker.coords
                local blipSize = Config.Heist[trapKey].debug.blipSize or 150
        
                local redzoneBlip = AddBlipForRadius(coords.x, coords.y, coords.z, blipSize + 0.0)
                SetBlipColour(redzoneBlip, 1)
                SetBlipAlpha(redzoneBlip, 200)
        
                local blipSprite = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipSprite(blipSprite, 274)
                SetBlipDisplay(blipSprite, 4)
                SetBlipScale(blipSprite, 1.0)
                SetBlipColour(blipSprite, 1)
                SetBlipAsShortRange(blipSprite, true)
        
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("TH "..Config.Heist[trapKey].label)
                EndTextCommandSetBlipName(blipSprite)
            end
        end
    end)
    _CreateThread(function()
        for heist, value in pairs(Config.Heist) do
            if value.ped then
                local spawnedped
                RequestModel(value.ped.model)
                while not HasModelLoaded(value.ped.model) do
                    Wait(0)
                end
                if type(value.ped.model) == 'string' then value.ped.model = joaat(value.ped.model) end
                spawnedped = CreatePed(0, value.ped.model, value.ped.coords.x, value.ped.coords.y, value.ped.coords.z - 1.0, value.ped.coords.w, false, false)
                FreezeEntityPosition(spawnedped, true)
                SetEntityInvincible(spawnedped, true)
                SetBlockingOfNonTemporaryEvents(spawnedped, true)
                ox_target:addLocalEntity(spawnedped, {
                    {
                        icon = 'fa-solid fa-book',
                        label = 'Start '..value.label,
                        onSelect = StartBigHeist,
                        args = {key = heist},
                        distance = 2.5
                    }
                })
                Config.Heist[heist].ped.entity = spawnedped
            end
            if value.marker then
                local cPoint = lib.points.new({
                    coords = value.marker.coords,
                    distance = value.marker.distance,
                    storeName = value.label,
                    heistId = heist
                })
                function cPoint:nearby()
                    if self.currentDistance > 2.5 and not GlobalState[self.heistId] then
                        ESX.DrawMarker(self.coords, 255, 0, 0, 1000)
                    end
                    if self.currentDistance < 2.5 and not GlobalState[self.heistId] then
                        ESX.DrawText3D(self.coords.x, self.coords.y, self.coords.z, 'Press ~g~E~w~ to start ~r~'..self.storeName..'~w~')
                    end
                    if self.currentDistance < 2.5 and IsControlJustReleased(0, 38) and not GlobalState[self.heistId] then
                        StartBigHeist({args = {key = heist}})
                    end
                end
            end
            if value.settings.autoBlip then
                setStateBagHandlers(heist..'_blip', (value.settings.autoAnnounce and heist..'_notify' or false), ((value.debug and value.debug.enable) and heist..'_debug' or false))
            end
        end
        print('^0[^3kodebykarl-robbery^0]: ^2Heist Loaded.^0')
    end)
end

RegisterNetEvent('cfx-cs-robbery:DestroyClient', function(key)
    BigHeist.destroy[key] = true
    Wait(5000)
    BigHeist.destroy[key] = false
end)


RegisterNetEvent('cfx-cs-robbery:SyncTimer', function(key)
    local config = Config.Heist[key]
    BigHeist.timer[key] = config.timer
    _CreateThread(function()
		while true do
			Wait(1000)
			BigHeist.timer[key] -= 1
            lib.showTextUI(config.label..': '..BigHeist.timer[key]..' seconds remaining', {
                position = "bottom-center",
                icon = 'fa-solid fa-stopwatch',
                iconColor = '#FF0949',
                style = {
                    backgroundColor = '#2E2E2E', -- Slightly lighter background for better contrast
                    color = '#F1F1F1', -- Softer white text for reduced strain on the eyes
                    padding = '12px 24px', -- Adds more spacing for a cleaner look
                    borderRadius = '8px', -- Rounded corners for a modern look
                    border = '2px solid #FF0949', -- Adds a border matching the icon color
                    fontSize = '16px', -- Clear and readable text size
                    fontFamily = 'Arial, sans-serif', -- Clean and widely supported font
                    textAlign = 'center', -- Centers the text nicely
                    boxShadow = '0 4px 20px rgba(0, 0, 0, 0.7)', -- Larger and softer shadow
                    transition = 'all 0.3s ease', -- Smooth transition for hover effects
                    hover = {
                        backgroundColor = '#FF0949', -- Changes background color on hover
                        color = '#212121', -- Inverts text color on hover
                    },
                    ['.description'] = {
                        color = '#D1D1D1', -- Subtle contrast for description text
                        fontSize = '14px', -- Slightly smaller for descriptions
                    }
                }
            })
            if BigHeist.timer[key] <= 0 then
                lib.hideTextUI()
                break
            end
            if BigHeist.destroy[key] then
                lib.hideTextUI()
                break
            end
		end
	end)
    _CreateThread(function()
		while true do
			Wait(0)
            local coords = GetEntityCoords(cache.ped)
            local dist = config.ped and #(coords - config.ped.coords.xyz) or #(coords - config.marker.coords)
            if dist > config.distanceToCancel then
                TriggerServerEvent('cfx-cs-robbery:DestroyServer', key)
                break
            end
            if BigHeist.destroy[key] then
                break
            end
		end
	end)
end)


function UnloadBigHeist()
    for k,v in pairs(Config.Heist) do
        if v.ped then
            DeletePed(v.ped.entity)
            Config.Heist[k].ped.entity = 0
        end
    end
end

AddEventHandler('ESX:Client:PlayerLoaded', function()
    LoadBigHeist()
end)

AddEventHandler('onResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then return end
    Wait(1000)
    LoadBigHeist()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return end
    UnloadBigHeist()
end)