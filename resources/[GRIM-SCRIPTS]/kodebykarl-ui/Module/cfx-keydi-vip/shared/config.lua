ConfigVip = ConfigVip or {}

ConfigVip.Debug = false

--[[
  Tier features (connected systems):
    characterSlots  → kodebykarl-multicharacter (multicharacter_slots)
    pedMenu         → /ped or /pedmenu via illenium-appearance (VIP 2 & 3: 1 Month Access /ped)
    welcomeBanner   → /wcb self-edit welcome banner with audio
    grindBonus      → bonus amount added to all grindings (+5 / +10 / +15)
]]
ConfigVip.Tiers = {
    vip1 = {
        label = "VIP 1",
        characterSlots = 1,
        pedMenu = false,
        welcomeBanner = true,
        grindBonus = 5,
        perks = {
            "+ 5 ALL GRINDINGS",
            "DISCORD ROLE",
            "WELCOME BANNER WITH AUDIO",
        },
    },
    vip2 = {
        label = "IMMORTAL",
        characterSlots = 2,
        pedMenu = true,
        welcomeBanner = true,
        grindBonus = 10,
        perks = {
            "1 MONTH ACCESS /PED",
            "+ 10 ALL GRINDINGS",
            "WELCOME BANNER WITH AUDIO",
            "DISCORD ROLE",
            "VIP CAR  ( CARDEALER)",
        },
    },
    vip3 = {
        label = "SUPREME",
        characterSlots = 3,
        pedMenu = true,
        welcomeBanner = true,
        grindBonus = 15,
        perks = {
            "1 MONTH ACCESS /PED",
            "+ 15 ALL GRINDINGS",
            "WELCOME BANNER WITH AUDIO",
            "1 EXCLUSIVE CAR  OWN SCRIPT",
            "DEATH CAM AUDIO/Banner",
            "1 FREE CLOTHES w/ 2 variant",
            "DISCORD ROLE",
        },
    },
}

-- Staff groups that can Set / Edit / Revoke VIP from Control Center
ConfigVip.StaffGroups = {
    owner = true,
    developer = true,
}
