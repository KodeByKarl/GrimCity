ConfigSheriff = {}

ConfigSheriff.Job = 'sheriff'
ConfigSheriff.OffDutyJob = 'offsheriff'
ConfigSheriff.Label = "Sheriff's Office"
ConfigSheriff.ShortLabel = 'BCSO'

-- Sandy Shores Sheriff Station (Sandy Sheriff / Hospital MLO)
ConfigSheriff.Station = {
    Location = {
        coords = vector3(1886.3198, 3661.4883, 37.3998),
        heading = 294.5282,
    },
    Blip = {
        Coords = vector3(1886.3198, 3661.4883, 37.3998),
        Sprite = 60,
        Display = 4,
        Scale = 1.0,
        Colour = 5,
        Label = "Sheriff's Office",
    },
    Documents = {
        coords = vector3(1886.3198, 3661.4883, 37.3998),
        radius = 1.5,
        label = 'Open Documents',
        icon = 'fa-solid fa-file-lines',
    },
    Wardrobe = {
        coords = vector3(1881.2179, 3661.3215, 34.1129),
        heading = 291.0265,
        length = 1.2,
        width = 1.8,
        minZ = 33.1,
        maxZ = 35.5,
        label = 'Sheriff Wardrobe',
        icon = 'fa-solid fa-shirt',
    },
    Armoury = {
        coords = vector3(1891.7761, 3660.1177, 34.1130),
        heading = 178.0177,
        label = 'Sheriff Armoury',
    },
    Evidence = {
        coords = vector3(1888.1609, 3663.3677, 34.1130),
        heading = 28.5636,
        label = 'Sheriff Evidence',
    },
    PublicStash = {
        coords = vector3(1890.9138, 3663.4829, 34.1129),
        heading = 304.5840,
        label = 'Sheriff Shared Locker',
    },
    PersonalStash = {
        coords = vector3(1891.9514, 3661.7656, 34.1129),
        heading = 277.9326,
        label = 'Sheriff Personal Locker',
    },
    BossStash = {
        coords = vector3(1877.5516, 3659.5029, 37.3998),
        heading = 119.8286,
        label = 'Sheriff Boss Locker',
    },
    Helipad = {
        access = vector3(1883.4827, 3659.4534, 40.8335),
        heading = 297.0320,
        spawn = vector4(1892.9338, 3664.7878, 40.8335, 119.3511),
        label = 'Sheriff Helipad',
        garageId = 'Sheriff Helipad',
    },
}

-- Minimum grade for /givescs (boss = 6)
ConfigSheriff.CallsignBossGradeName = 'boss'
