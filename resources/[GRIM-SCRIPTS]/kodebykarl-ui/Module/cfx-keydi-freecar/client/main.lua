local ESX = exports['es_extended']:getSharedObject()

local isMenuOpen = false

local function Notify(title, message, msgType)
    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(message, msgType or 'info')
    else
        TriggerEvent('esx:Notify', title or (Config.FreeCar and Config.FreeCar.NotificationTitle) or 'FREE CAR', message, msgType or 'info', 5000)
    end
end

local function CloseFreeCarMenu()
    if not isMenuOpen then return end
    isMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'cfx-keydi-freecar:hide' })
end

local function OpenFreeCarMenu()
    if isMenuOpen then return end

    local claimed = lib.callback.await('cfx-keydi-freecar:server:hasClaimed', false)
    if claimed then
        Notify(Config.FreeCar.NotificationTitle, 'You have already claimed your free vehicles!', 'error')
        return
    end

    local bonus = Config.FreeCar.BonusVehicle or {}

    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'cfx-keydi-freecar:show',
        data = {
            vehicles = Config.FreeCar.AllowedVehicles or {},
            title = Config.FreeCar.NotificationTitle or 'FREE CAR',
            spinDurationMs = Config.FreeCar.SpinDurationMs or 6500,
            bonusVehicle = {
                model = bonus.model or 'burrito',
                label = bonus.label or 'Declasse Burrito',
            },
        }
    })
end

RegisterNetEvent('cfx-keydi-freecar:client:notify', function(title, message, msgType)
    Notify(title, message, msgType)
end)

RegisterNetEvent('cfx-keydi-freecar:client:open', function()
    OpenFreeCarMenu()
end)

RegisterNetEvent('cfx-keydi-freecar:client:claimed', function(plate, result)
    CloseFreeCarMenu()
    local bonusLabel = result and result.bonusLabel or 'Burrito'
    local winLabel = result and result.label or 'vehicle'
    Notify(
        Config.FreeCar.NotificationTitle,
        ('Claimed %s + %s! Both are in your garage.'):format(tostring(winLabel), tostring(bonusLabel)),
        'success'
    )
end)

RegisterCommand(Config.FreeCar.Command or 'freecar', function()
    OpenFreeCarMenu()
end, false)

exports('OpenFreeCarMenu', OpenFreeCarMenu)
exports('CloseFreeCarMenu', CloseFreeCarMenu)

RegisterNUICallback('cfx-keydi-freecar:close', function(_, cb)
    cb('ok')
    CloseFreeCarMenu()
end)

RegisterNUICallback('cfx-keydi-freecar:spin', function(_, cb)
    local result = lib.callback.await('cfx-keydi-freecar:server:spin', false)
    if not result then
        cb({ success = false, message = 'Spin failed' })
        Notify(Config.FreeCar.NotificationTitle, 'Spin failed.', 'error')
        return
    end

    cb(result)

    if not result.success then
        Notify(Config.FreeCar.NotificationTitle, result.message or 'Unable to claim vehicle.', 'error')
        return
    end

    if result.plate then
        CreateThread(function()
            Wait((Config.FreeCar and Config.FreeCar.SpinDurationMs or 6500) + 2800)
            if isMenuOpen then
                CloseFreeCarMenu()
            end

            local bonusLabel = result.bonusLabel or 'Burrito'
            Notify(
                Config.FreeCar.NotificationTitle,
                ('You won %s! Bonus %s also added. Both are in your garage.'):format(
                    tostring(result.label or result.model),
                    tostring(bonusLabel)
                ),
                'success'
            )
        end)
    end
end)
