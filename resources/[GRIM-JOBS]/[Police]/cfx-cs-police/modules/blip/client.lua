CreateThread(function()
    for k,v in pairs(Config.LawEnforcement) do
        local blip = AddBlipForCoord(v.Blip.Coords)
		SetBlipSprite (blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale  (blip, v.Blip.Scale)
		SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(v.Blip.Label)
		EndTextCommandSetBlipName(blip)
    end
end)