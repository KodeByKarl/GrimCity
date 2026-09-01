local carry = require 'configs.carry'
local buhat = require 'configs.buhat'

RegisterNUICallback('UILoaded', function(_, cb)
    cb({ ok = true })
end)

AddEventHandler('ox_inventory:currentWeapon', function(item)
    local weapon = item?.name or ''
    if weapon:find('WEAPON_') then
        if buhat.InProgress and (buhat.type == "beingcarried" or buhat.type == 'carrying') or
        carry.IsCarrying and (carry._type == "beingcarried" or carry._type == "carrying") then
			TriggerEvent('ox_inventory:disarm')
		end
    end
end)