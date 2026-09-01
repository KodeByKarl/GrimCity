local Config = require 'configs.gv'
local Vars = require 'helpers.vars'

if not Config or not Config.Enabled then return end

local function buildItemOptions()
    local options = {}
    local items = Config.Items or {}
    for i = 1, #items do
        local name = items[i]
        local def = Vars.oxItems and Vars.oxItems[name]
        if not def and Vars.ox then
            def = Vars.ox:Items(name)
        end
        options[#options + 1] = {
            value = name,
            label = def and def.label or name,
        }
    end
    table.sort(options, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    return options
end

local function openGvMenu()
    local allowed = lib.callback.await('cfx-keydi-utils:gv:canUse', false)
    if not allowed then
        ESX.Notify(Config.NotifyTitle or 'GIVE ITEM', 'You do not have permission.', 'error', 5000)
        return
    end

    local itemOptions = buildItemOptions()
    if #itemOptions == 0 then
        ESX.Notify(Config.NotifyTitle or 'GIVE ITEM', 'No items configured.', 'error', 5000)
        return
    end

    lib.registerContext({
        id = 'cfx_keydi_gv_menu',
        title = 'Give Item (Gv)',
        options = {
            {
                title = 'Item To Give',
                description = 'Search boxes → choose player ID or all players',
                icon = 'box',
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog('Give Item (Gv)', {
                        {
                            type = 'select',
                            label = 'Item To Give',
                            description = 'Search boxes (ayuda, beta, hightable, ...)',
                            icon = 'box',
                            required = true,
                            searchable = true,
                            clearable = true,
                            options = itemOptions,
                        },
                        {
                            type = 'select',
                            label = 'To',
                            description = 'Player ID or all online players',
                            icon = 'users',
                            required = true,
                            options = {
                                { value = 'id', label = 'Player ID' },
                                { value = 'all', label = 'All Players' },
                            },
                        },
                        {
                            type = 'number',
                            label = 'Player ID',
                            description = 'Required when To = Player ID',
                            icon = 'hashtag',
                            min = 1,
                        },
                        {
                            type = 'number',
                            label = 'Amount',
                            description = ('Max %s'):format(Config.MaxAmount or 50),
                            icon = 'hashtag',
                            required = true,
                            default = 1,
                            min = 1,
                            max = Config.MaxAmount or 50,
                        },
                    })

                    if not input then return end

                    local item = input[1]
                    local targetType = input[2]
                    local targetId = input[3]
                    local amount = input[4]

                    if targetType == 'id' and (not targetId or targetId < 1) then
                        ESX.Notify(Config.NotifyTitle or 'GIVE ITEM', 'Enter a valid Player ID.', 'error', 5000)
                        return
                    end

                    -- Client only requests; server validates group, item whitelist, target, amount
                    TriggerServerEvent('cfx-keydi-utils:gv:give', {
                        item = item,
                        targetType = targetType,
                        targetId = targetId,
                        amount = amount,
                    })
                end,
            },
        },
    })

    lib.showContext('cfx_keydi_gv_menu')
end

RegisterCommand(Config.Command or 'Gv', function()
    openGvMenu()
end, false)
