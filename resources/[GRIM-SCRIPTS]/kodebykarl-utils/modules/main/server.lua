local Vars = require 'helpers.vars'
local takehostage = require 'configs.takehostage'

AddEventHandler('playerDropped', function()
	local src = source
	if Vars.Impound[src] then
		Vars.Impound[src] = nil
	end
	if Vars.buhating[src] then
		TriggerClientEvent("cfx-keydi-utils:Buhat:Stop", Vars.buhating[src])
		Vars.nakabuhat[Vars.buhating[src]] = nil
		Vars.buhating[src] = nil
	end
	if Vars.nakabuhat[src] then
		TriggerClientEvent("cfx-keydi-utils:Buhat:Stop", Vars.nakabuhat[src])
		Vars.buhating[Vars.nakabuhat[src]] = nil
		Vars.nakabuhat[src] = nil
	end
	if Vars.carrying[src] then
		TriggerClientEvent("cfx-keydi-utils:Carry:Stop", Vars.carrying[src])
		Vars.carried[Vars.carrying[src]] = nil
		Vars.carrying[src] = nil
	end
	if Vars.carried[src] then
		TriggerClientEvent("cfx-keydi-utils:Carry:Stop", Vars.carried[src])
		Vars.carrying[Vars.carried[src]] = nil
		Vars.carried[src] = nil
	end
	if takehostage.enable then
		if Vars.takingHostage[src] then
			TriggerClientEvent("TakeHostage:cl_stop", Vars.takingHostage[src])
			Vars.takenHostage[Vars.takingHostage[src]] = nil
			Vars.takingHostage[src] = nil
		end
		if Vars.takenHostage[src] then
			TriggerClientEvent("TakeHostage:cl_stop", Vars.takenHostage[src])
			Vars.takingHostage[Vars.takenHostage[src]] = nil
			Vars.takenHostage[src] = nil
		end
	end
end)
