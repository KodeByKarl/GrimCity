ESX = exports['es_extended']:getSharedObject()
Config = Config or {}

-- Grim ESX has ShowNotification / ox_lib, not ESX.Notify (Keydi-style modules).
if not IsDuplicityVersion() then
    if ESX and type(ESX.Notify) ~= 'function' then
        ESX.Notify = function(title, message, nType, duration)
            local kind = nType
            if kind == 'inform' then kind = 'info' end

            if type(message) ~= 'string' then
                message = title
                title = 'Notification'
            end

            if ESX.ShowNotification then
                ESX.ShowNotification(message or '', kind, duration or 5000, title)
                return
            end

            if lib and lib.notify then
                lib.notify({
                    title = title or 'Notification',
                    description = message or '',
                    type = kind or 'info',
                    duration = duration or 5000,
                })
            end
        end
    end

    RegisterNetEvent('esx:Notify', function(title, message, nType, duration)
        if ESX and ESX.Notify then
            ESX.Notify(title, message, nType, duration)
        end
    end)
end
