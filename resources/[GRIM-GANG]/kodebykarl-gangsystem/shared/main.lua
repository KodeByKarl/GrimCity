Config = {}

-- Gang keys MUST match es_extended/shared/config/gang.lua
-- Locations/stashes are optional; turfwars only needs the gang name on the player.
Config.Gangs = {
    ['grimgang'] = {
        name = 'grimgang',
        label = 'GrimGang',
        bossGrade = 3, -- Boss
        -- discordRoleId = '', -- set Discord role ID when ready
        rgbColor = { r = 180, g = 40, b = 40 },
        primaryColor = 1,
        secondaryColor = 1,
        stashes = {
            public = {
                coords = nil, -- set vec4(x, y, z, w) later
                label = 'GrimGang Public Stash',
                id = 'grimgang_public_stash',
                slots = 300,
                maxWeight = 1000000,
                owner = false,
            },
            private = {
                coords = nil,
                label = 'GrimGang Private Stash',
                id = 'grimgang_private_stash',
                slots = 100,
                maxWeight = 3000000,
                owner = true,
            },
            boss = {
                coords = nil,
                label = 'GrimGang Boss Stash',
                id = 'grimgang_boss_stash',
                slots = 300,
                maxWeight = 1000000,
                owner = 6, -- shared: bosses only (grade >= bossGrade)
            },
        },
        -- Boss management is via iPad Organization app (no world bossMenu marker)
        wardrobe = {
            coords = nil,
        },
        vehicle = {
            coords = nil,
            model = 'sultan', -- change when location is set
        },
        -- Bench location only — recipes are shared in shared/crafting.lua
        crafting = {
            coords = nil, -- set vec4(x, y, z, w) later
        },
    },
}


--[[
    Discord role gate for gang hire.
    Player must be in GuildID AND have that gang's discordRoleId before a boss can hire them.
    Bot needs: Server Members Intent + View Server Members permission in that Discord.
]]
Config.DiscordHire = {
    Enabled = true,
    AllowOfflineHire = true, -- Hire by Discord ID even if recruit is offline
    -- Main Grim City Discord (same guild as loadingscreen staff roles).
    -- Bot token: convar kodebykarl_discord_bot_token (must be invited here + Server Members Intent).
    GuildID = '1240677650348118148',
    -- Empty = reuse Config.Logs.BotToken, then kodebykarl_discord_bot_token convar
    BotToken = '',
    RequireDiscordLinked = true,
    RequireInGuild = true,
    -- If a gang has no discordRoleId set, block hire (safer) or allow (set false)
    -- false = demo-friendly (GrimGang has no Discord role yet)
    BlockIfRoleNotConfigured = false,
    -- Short cache so rapid re-hires don't spam Discord (roles refresh after this)
    RoleCacheMs = 15000,
    Messages = {
        NoDiscord = 'Recruit must link Discord in FiveM settings first.',
        NotInGuild = 'Recruit must join the Discord server and get the gang role first.',
        MissingRole = 'Recruit does not have the %s Discord role yet. Re-check the role, then try again.',
        RoleNotConfigured = 'Discord role is not configured for this gang yet. Ask staff to set discordRoleId.',
        BotCannotAccess = 'Discord bot cannot read that server. Invite the bot + enable Server Members Intent.',
        ApiError = 'Could not verify Discord role. Try again in a moment.',
        InvalidDiscordId = 'Invalid Discord ID. Paste the numeric ID only.',
        NoCharacter = 'No character found for that Discord. They must join the city once first.',
        AlreadyInGang = 'That player is already in your gang.',
        OfflineDisabled = 'Offline Discord hire is disabled.',
    },
}

-- Precompute vec3 so client points / server distance checks skip per-call reconstruction
do
    local function toVec3(coords)
        if not coords then return nil end
        return vec3(coords.x, coords.y, coords.z)
    end

    for _, gang in pairs(Config.Gangs) do
        if gang.stashes then
            for _, stash in pairs(gang.stashes) do
                stash.vec = toVec3(stash.coords)
            end
        end
        if gang.wardrobe then
            gang.wardrobe.vec = toVec3(gang.wardrobe.coords)
        end
        if gang.vehicle then
            gang.vehicle.vec = toVec3(gang.vehicle.coords)
        end
        if gang.crafting then
            gang.crafting.vec = toVec3(gang.crafting.coords)
        end
    end
end

function GetConfiguredGangs()
    return Config.Gangs
end

exports('GetGangs', GetConfiguredGangs)

--[[
    Discord logs (roster / exploit).
]]
Config.Logs = {
    Enabled = true,
    BotToken = '',
    GuildID = "1536358290777444397",

    ChannelNames = {
        roster = "GANG-ROSTER",
        exploit = "GANG-EXPLOIT",
    },

    ChannelIDs = {
        roster = "1536366691653656609",
        exploit = "1536366696179437619",
    },

    LogTypes = {
        roster = true,
        exploit = true,
    },

    EmbedColors = {
        hire = 3447003,
        promote = 15844367,
        demote = 15105570,
        fire = 10038562,
        exploit = 15158332,
    },

    PostCooldownMs = 500,
}
