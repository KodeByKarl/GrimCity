return {
    General = {
        -- Time before spawn selector auto-opens (ms) - 180 seconds (3 minutes)
        RespawnTimer = 60000 * 3,
        BleedoutTimer = 60000 * 15,
        -- STL (morgue) respawn bank charge
        RespawnFine = 1000,
        RespawnWithNegativeBank = 60000 * 15,
        -- After STL respawn: 5 min recovery, first 2 min with crutch prop (no sprint)
        STLRecovery = {
            total = 300,
            crutch = 120,
        },
        -- Pocket items drop on the ground at the death spot (STL + quit while dead)
        DropItemsOnStl = true,
        DropItemsOnQuit = true,
        KeepItemsOnDrop = { 'identification', 'phone' },
        -- Anti spawn-kill after STL. Protected players cannot take or deal damage.
        SpawnProtection = {
            duration = 60,
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
            jobs = { 'ambulance', 'sambulance' },
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
            coords = vec3(1119.2155, -1508.1837, 35.7184),
            sprite = 61,
            colour = 1,
            scale = 0.8,
            shortRange = true,
        },
    },
    CheckIn = {
        {
            price = 1000,
            onDuty = 1, -- only available when 0 ambulance on duty
            job = 'ambulance',
            coords = vec3(1121.6476, -1535.6367, 37.1247),
            distance = {interact = 0.5},
        },
    }
}