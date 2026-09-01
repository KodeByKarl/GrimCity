Config = Config or {}

Config.Multicharacter = {
    MaxSlots = 3,
    DefaultSlots = 1, -- non-VIP players can only use slot 1
    DefaultSpawn = vector4(-268.4, -957.1, 31.2, 205.5), -- Campus Spawn
    CamCoords = vector3(-269.4, -958.1, 32.2),
    CamPoint = vector3(-268.4, -957.1, 31.8),
    CamFov = 46.0,
    DefaultJob = 'student',
    DefaultGrade = 0,
    DefaultMoney = 5000,
    DefaultBank = 10000,
    VipCommand = 'Multivip',
    AllowedVipGroups = {
        developer = true,
        owner = true,
    },
}
