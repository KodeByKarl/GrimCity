Config = {}
ox_inventory = exports.ox_inventory
ox_items = ox_inventory:Items()
ESX = exports['es_extended']:getSharedObject()
local duplicity = IsDuplicityVersion()

if not duplicity then
    function HasItem(data)
        if next(data) then
            for k,v in pairs(data) do
                local itemCount = ox_inventory:Search('count', k)
                if itemCount < v then
                    ESX.Notify('ROBBERY', ('You must have %sx %s to proceed with this action.'):format(v, ox_items[k].label), 'error', 5000)
                    return false
                end
            end
        end
        return true
    end
end