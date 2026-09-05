local function Notify(title, description, nType)
    lib.notify({
        title = title or "VIP",
        description = description,
        type = nType or "inform",
        position = "top-center",
    })
end

local function OpenPedMenu()
    lib.callback("cfx-keydi-vip:canPedMenu", false, function(ok)
        if not ok then
            Notify("Ped Menu", "VIP 2+ required for ped menu access.", "error")
            return
        end
        -- Same event staff /pedmenu uses (full ped customization)
        TriggerEvent("illenium-appearance:client:openClothingShopMenu", true)
    end)
end

local function OpenWelcomeBannerSelf()
    lib.callback("cfx-keydi-vip:canWelcomeBanner", false, function(ok)
        if not ok then
            Notify("Welcome Banner", "Active VIP required to edit your banner.", "error")
            return
        end
        ExecuteCommand(ConfigWelcomeBanner and ConfigWelcomeBanner.Command or "wcb")
    end)
end

RegisterNUICallback("cfx-keydi-vip:getStatus", function(_, cb)
    lib.callback("cfx-keydi-vip:getStatus", false, function(result)
        cb(result or { vip = nil })
    end)
end)

RegisterNUICallback("cfx-keydi-vip:openPedMenu", function(_, cb)
    OpenPedMenu()
    cb({ ok = true })
end)

RegisterNUICallback("cfx-keydi-vip:openWelcomeBanner", function(_, cb)
    OpenWelcomeBannerSelf()
    cb({ ok = true })
end)

-- VIP players can also type /pedmenu; illenium admin ACE still works separately.
RegisterCommand("vipped", function()
    OpenPedMenu()
end, false)

RegisterCommand("mybanner", function()
    OpenWelcomeBannerSelf()
end, false)
