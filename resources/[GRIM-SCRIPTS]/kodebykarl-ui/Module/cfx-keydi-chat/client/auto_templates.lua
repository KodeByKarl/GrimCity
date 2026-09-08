-- Freestyle aliases: /ems /pd /mech forward to /wl [message]. No fixed Auto Templates.

local function wlCommand()
    return (ConfigChat.jobTemplate and ConfigChat.jobTemplate.command) or 'wl'
end

local function postFreestyle(args)
    local msg = table.concat(args or {}, ' ')
    local cmd = wlCommand()
    if not msg or msg == '' then
        lib.notify({
            title = 'Announcement',
            description = ('Format: /%s [message] — freestyle only.'):format(cmd),
            type = 'inform',
        })
        return
    end
    ExecuteCommand(('%s %s'):format(cmd, msg))
end

RegisterCommand('ems', function(_, args)
    postFreestyle(args)
end, false)

RegisterCommand('hospital', function(_, args)
    postFreestyle(args)
end, false)

RegisterCommand('pd', function(_, args)
    postFreestyle(args)
end, false)

RegisterCommand('police', function(_, args)
    postFreestyle(args)
end, false)

RegisterCommand('mech', function(_, args)
    postFreestyle(args)
end, false)

RegisterCommand('mechanic', function(_, args)
    postFreestyle(args)
end, false)

RegisterNetEvent('cfx-keydi-chat:openJobAutoTemplates', function()
    lib.notify({
        title = 'Announcement',
        description = 'Fixed templates removed. Use /wl [message] (freestyle).',
        type = 'inform',
    })
end)
