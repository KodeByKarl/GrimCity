Vars = {}
Vars.ox = exports.ox_inventory
Vars.bleedingData = {
	[0] = 'NONE',
	[1] = 'SLOW',
	[2] = 'MEDIUM',
	[5] = 'FAST',
}

local function loadOxItems()
	local ok, items = pcall(function()
		return exports.ox_inventory:Items()
	end)
	if ok and type(items) == 'table' then
		Vars.oxItems = items
		return true
	end
	return false
end

if not loadOxItems() then
	Vars.oxItems = {}
	CreateThread(function()
		local attempts = 100
		while attempts > 0 and not loadOxItems() do
			attempts -= 1
			Wait(100)
		end
		if not next(Vars.oxItems) then
			warn('[cfx-keydi-ambulance] ox_inventory Items export unavailable')
		end
	end)
end

if IsDuplicityVersion() then
	Vars.cacheDeads = {}
else
	Vars.isBed = false
	Vars.isBusy = false
	Vars.isDead = false
	Vars.isReviving = false
	Vars.deathToken = 0
	Vars.lastHitBone = nil
	Vars.lastHitBoneAt = 0
	Vars.inSandy = false
	Vars.IsDispatched = false
	Vars.Status = {
		health = 0,
		multiplier = 2.0,
		pulse = 70,
		area = 'NONE',
		blood = 100,
		bleeding = 0,
		timer = 0,
		currentPulse = -1,
		currentBlood = -1,
		currentArea = '',
		currentBleeding = 'NONE',
		name = '',
		bone = {
			[24817] = true,
			[24818] = true,
			[10706] = true,
			[24816] = true,
			[11816] = true
		}
	}
	Vars.ReviveAnim = {
		cpr_a_1 = 'mini@cpr@char_a@cpr_def',
		cpr_a_2 = 'mini@cpr@char_a@cpr_str',
		cpr_b_1 = 'mini@cpr@char_b@cpr_def',
		cpr_b_2 = 'mini@cpr@char_b@cpr_str',
		start = 'cpr_intro',
		pump = 'cpr_pumpchest',
		success = 'cpr_success'
	}
end

return Vars
