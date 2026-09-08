return {
    General = {
        -- Time before STL / respawn button unlocks (ms)
        RedZoneRespawnTimer = 60000, -- 1 min inside RedZone
        RespawnTimer = 300000, -- 5 mins outside RedZone
        BleedoutTimer = 600000, -- 10 mins bleedout buffer after respawn unlocks
        -- STL (morgue) respawn bank charge
        RespawnFine = 15000, -- 15K fine
        RespawnWithNegativeBank = 300000, -- 5 mins
        -- After STL respawn
        STLRecovery = {
            total = 10,
            crutch = 0,
        },
        -- Pocket items drop on the ground at the death spot (STL + quit while dead)
        DropItemsOnStl = false, -- TEST (was true) so we don't wipe pockets while checking spawn
        DropItemsOnQuit = true,
        KeepItemsOnDrop = { 'identification', 'phone' },
        -- Anti spawn-kill after STL. Protected players cannot take or deal damage.
        SpawnProtection = {
            duration = 5, -- TEST (was 60)
        },
        -- Dead players cannot hear voice or world audio (anti-ghost)
        DeathMuteHearing = true,
        -- EMS revive recovery (seconds). crutch = forced crutch prop / no-sprint window.
        Recovery = {
            ['all'] = 120,
            ['police'] = 60,
            ['sheriff'] = 60,
            crutch = 120,
        },
        Dispatch911 = {
            blipSprite = 153,
            blipColor = 1,
            blipScale = 1.1,
            blipDuration = 300000, -- 5 minutes
            jobs = { 'ambulance', 'sambulance', 'pambulance' },
        },
    },

    --[[
        Discord logs (same bot pattern as banking / police / business).
        Create: EMS-REVIVE, EMS-MONEY, EMS-BODYBAG, EMS-BED, EMS-SENTRY
    ]]
    Logs = {
        Enabled = true,
        BotToken = "MTUzNjM2NDUyMjc5MTUwNjA0Mg.GfAaOT.pXdZcrMv-0yl2Blw9cESfKGSbv56AvD5C6-jTo",
        GuildID = "1536358290777444397",

        ChannelNames = {
            revive = "EMS-REVIVE",   -- revive + heal
            money = "EMS-MONEY",     -- check-in + respawn fine
            bodybag = "EMS-BODYBAG",
            bed = "EMS-BED",         -- admit + unbed
            sentry = "EMS-SENTRY",   -- failed validation + bleedout wipe
        },

        ChannelIDs = {
            revive = "1536366585315336264",
            money = "1536366589308436502",
            bodybag = "1536366593418993776",
            bed = "1536366598120542288",
            sentry = "1536366602289946665",
        },

        LogTypes = {
            revive = true,
            heal = true,
            money = true,
            bodybag = true,
            bed = true,
            sentry = true,
            bleedout = true,
        },

        EmbedColors = {
            revive = 5763719,
            heal = 3066993,
            checkIn = 3447003,
            fine = 15105570,
            bodybag = 10038562,
            bedAdmit = 10181046,
            unbed = 15844367,
            bleedout = 15158332,
            sentry = 15158332,
        },

        PostCooldownMs = 500,
    },

    Blips = {
        {
            label = 'Hospital',
            coords = vec3(-1040.5308, -1355.7512, 5.9474),
            sprite = 61,
            colour = 1,
            scale = 0.8,
            shortRange = true,
        },
    },
    Station = {
        Wardrobe = {
            coords = vector3(-1043.5010, -1352.3008, 5.9474),
            heading = 268.2458,
            size = vector3(1.2, 2.0, 2.5),
            label = 'EMS Wardrobe',
            icon = 'fa-solid fa-shirt',
        },
        Garage = {
            access = vector3(-1030.4906, -1415.4324, 5.4256),
            heading = 24.4261,
            spawn = vector4(-1035.8992, -1421.0535, 5.4292, 66.2173),
            label = 'EMS Garage',
            garageId = 'EMS Garage',
        },
    },
    CheckIn = {
        {
            price = 1000,
            onDuty = 1, -- only available when 0 ambulance on duty
            job = 'ambulance',
            coords = vec3(-1040.5308, -1355.7512, 5.9474),
            distance = {interact = 0.5},
        },
        {
            price = 1000,
            onDuty = 1,
            job = 'pambulance',
            coords = vec3(-256.80, 6318.20, 32.4327),
            distance = {interact = 0.5},
        },
    }
}