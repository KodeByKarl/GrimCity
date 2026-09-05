ConfigVip = ConfigVip or {}

ConfigVip.Debug = false

--[[
  Tier features (connected systems):
    characterSlots  → kodebykarl-multicharacter (multicharacter_slots)
    pedMenu         → /pedmenu via illenium-appearance (VIP 2+)
    welcomeBanner   → /wcb self-edit welcome banner
]]
ConfigVip.Tiers = {
    vip1 = {
        label = "VIP 1",
        characterSlots = 1,
        pedMenu = false,
        welcomeBanner = true,
        perks = { "VIP chat tag", "Edit own welcome banner" },
    },
    vip2 = {
        label = "VIP 2",
        characterSlots = 2,
        pedMenu = true,
        welcomeBanner = true,
        perks = {
            "VIP chat tag",
            "Ped Menu (/pedmenu)",
            "2 character slots (MultiVIP)",
            "Edit own welcome banner",
        },
    },
    vip3 = {
        label = "VIP 3",
        characterSlots = 3,
        pedMenu = true,
        welcomeBanner = true,
        perks = {
            "Priority queue",
            "Ped Menu (/pedmenu)",
            "3 character slots (MultiVIP)",
            "Edit own welcome banner",
            "VIP chat tag",
        },
    },
    vip4 = {
        label = "VIP 4",
        characterSlots = 3,
        pedMenu = true,
        welcomeBanner = true,
        perks = {
            "Priority queue",
            "Ped Menu (/pedmenu)",
            "Max character slots",
            "Custom banner + sound",
            "VIP chat tag",
        },
    },
    vip5 = {
        label = "VIP 5",
        characterSlots = 3,
        pedMenu = true,
        welcomeBanner = true,
        perks = {
            "Highest priority",
            "Ped Menu (/pedmenu)",
            "Max character slots",
            "Custom banner + sound",
            "VIP chat tag",
        },
    },
}

-- Staff groups that can Set / Edit / Revoke VIP from Control Center
ConfigVip.StaffGroups = {
    owner = true,
    developer = true,
}
