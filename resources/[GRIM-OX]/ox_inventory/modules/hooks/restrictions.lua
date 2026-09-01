local exports = exports

local blockedInventories = {
    stash = true,
    drop = true,
    glovebox = true,
    trunk = true,
}

local function notifyBlocked(source)
    if source and source > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Money cannot be dropped or placed in stashes, gloveboxes, or trunks!'
        })
    end
end

CreateThread(function()
    exports.ox_inventory:registerHook('swapItems', function(payload)
        local toType = payload.toType
        local fromType = payload.fromType

        -- Block dropping on ground or putting into stashes / glovebox / trunk (clean money only)
        if blockedInventories[toType] then
            local fromItem = type(payload.fromSlot) == 'table' and payload.fromSlot.name
            if fromItem == 'money' then
                notifyBlocked(payload.source)
                return false
            end
        end

        -- Block swapping item from stash/drop/glovebox/trunk if player's slot contains money
        if blockedInventories[fromType] then
            local toItem = type(payload.toSlot) == 'table' and payload.toSlot.name
            if toItem == 'money' then
                notifyBlocked(payload.source)
                return false
            end
        end

        return true
    end, {
        itemFilter = {
            money = true,
        }
    })
end)
