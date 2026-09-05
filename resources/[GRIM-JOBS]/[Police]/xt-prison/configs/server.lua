return {
    EnableJailCommand = true,                   -- Jail command using ox_lib input menu

    UnemployedJobName = 'unemployed',           -- Name of unemployed job (if remove job is enabled)

    AllowedToKeepItems = {                      --  Items found/received in prison that can be kept when released
        ['money'] = true
    },

    PoliceJobs = {                              -- Police jobs
        'police',
        'sheriff'
    },

    Lifers = {                                  -- Lifer identifiers
        'RANDOLIOCID',
        'QWADEBOTCID'
    },

    tempItems = {
        ['bread'] = 5,
        ['sprunk'] = 5,
        ['stresstabs'] = 5,
        -- ['robitussin'] = 5,
        -- ['ondansetron'] = 5,
        -- ['meclizine'] = 5
    },

    --[[
        Discord logs (same bot pattern as cfx-keydi-utils / banking / police).
        Create: PRISON-JAIL, PRISON-RELEASE, PRISON-BREAK, PRISON-ITEMS
    ]]
    Logs = {
        Enabled = true,
        BotToken = "MTUzNjM2NDUyMjc5MTUwNjA0Mg.GfAaOT.pXdZcrMv-0yl2Blw9cESfKGSbv56AvD5C6-jTo",
        GuildID = "1536358290777444397",

        ChannelNames = {
            jail = "PRISON-JAIL",
            release = "PRISON-RELEASE",
            breakout = "PRISON-BREAK",
            items = "PRISON-ITEMS",
        },

        ChannelIDs = {
            jail = "1536366564805320754",
            release = "1536366569066598461",
            breakout = "1536366573185404998",
            items = "1536366577279172701",
        },

        LogTypes = {
            jail = true,       -- jail + roster time change
            release = true,    -- unjail / roster unjail
            breakout = true,   -- escape, terminal hack, exploit ban
            items = true,      -- confiscate / return
        },

        EmbedColors = {
            jail = 15105570,
            timeUpdate = 3447003,
            release = 5763719,
            breakout = 15158332,
            hack = 15844367,
            exploit = 10038562,
            confiscate = 10181046,
            returnItems = 3066993,
        },

        PostCooldownMs = 500,
    },

    banPlayer = function(source, cid)
        if PrisonLogs and PrisonLogs.Exploit then
            PrisonLogs.Exploit({
                src = source,
                identifier = cid,
                reason = 'Tried to return prison items while still jailed / invalid terminal hack',
            })
        end
        DropPlayer(source, 'Trying to exploit? Gago!')
    end
}