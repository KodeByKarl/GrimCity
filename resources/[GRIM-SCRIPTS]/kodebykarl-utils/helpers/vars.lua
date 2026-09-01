local Vars = {}

Vars.ox = exports.ox_inventory
Vars.oxCb = lib.callback
Vars.carrying = {}
Vars.carried = {}
Vars.buhating = {}
Vars.nakabuhat = {}
Vars.Impound = {}
Vars.takingHostage = {}
Vars.takenHostage = {}

function Vars.isCarryBusy(src)
	return Vars.buhating[src]
		or Vars.nakabuhat[src]
		or Vars.carrying[src]
		or Vars.carried[src]
end

---Wait until ox_inventory exposes Items (avoids boot race / failed early export).
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
			warn('[cfx-keydi-utils] ox_inventory Items export unavailable')
		end
	end)
end

if not IsDuplicityVersion() then
	Vars.oxPoints = lib.points
	Vars.oxImagePath = GetConvar('inventory:imagepath', '')
	Vars.playerState = LocalPlayer.state
	Vars.oxTarget = exports.ox_target
	Vars.isCarrying = false
end

return Vars
