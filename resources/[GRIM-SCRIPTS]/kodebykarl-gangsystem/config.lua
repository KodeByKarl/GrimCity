--[[
  kodebykarl-gangsystem config
  Fill Discord role IDs later (leave "" for now).
]]

Config = {}

Config.Debug = false
Config.MinPlaytimeSeconds = 2 * 60 * 60 -- 2 hours city playtime for claim car
Config.DiscordPollSeconds = 25
Config.ClaimCooldownMs = 4000

-- Discord live hire sync (roles empty until you fill them)
Config.Discord = {
    Enabled = true,
    -- Prefer convars (set in server.cfg):
    --   setr kodebykarl_discord_bot_token "YOUR_BOT_TOKEN"
    --   setr kodebykarl_discord_guild_id "YOUR_GUILD_ID"
    BotToken = '',
    GuildID = '',
}

--[[
  Grades (higher = more power)
  0 recruit, 1 member, 2 lieutenant, 3 boss
]]
Config.Grades = {
    [0] = { name = 'recruit', label = 'Recruit', boss = false },
    [1] = { name = 'member', label = 'Member', boss = false },
    [2] = { name = 'lieutenant', label = 'Lieutenant', boss = false },
    [3] = { name = 'boss', label = 'Boss', boss = true },
}

Config.BossGradeMin = 3

Config.Stash = {
    Boss = { slots = 100, weight = 500000, label = 'Boss Stash' },
    Public = { slots = 80, weight = 300000, label = 'Public Stash' },
    Personal = { slots = 50, weight = 150000, label = 'Personal Stash' },
}

--- Five iconic GTA V gang bases
Config.Gangs = {
    {
        id = 'ballas',
        label = 'Ballas',
        color = 27,
        discordRoleId = '', -- fill later
        claimVehicle = 'buccaneer2',
        blip = { sprite = 84, color = 27, scale = 0.85 },
        redzone = { coords = vec3(114.12, -1961.17, 21.33), radius = 85.0, color = 1, alpha = 100 },
        points = {
            bossStash = vec3(117.05, -1963.90, 21.33),
            publicStash = vec3(112.40, -1960.50, 21.33),
            personalStash = vec3(109.80, -1963.20, 21.33),
            wardrobe = vec3(120.20, -1960.10, 21.33),
            claimPed = {
                model = `g_m_y_ballaorig_01`,
                coords = vec4(105.55, -1956.80, 20.75, 320.0),
            },
        },
    },
    {
        id = 'families',
        label = 'The Families',
        color = 2,
        discordRoleId = '',
        claimVehicle = 'tornado',
        blip = { sprite = 84, color = 2, scale = 0.85 },
        redzone = { coords = vec3(-148.20, -1596.40, 34.80), radius = 80.0, color = 2, alpha = 100 },
        points = {
            bossStash = vec3(-151.10, -1599.20, 34.80),
            publicStash = vec3(-146.50, -1594.80, 34.80),
            personalStash = vec3(-144.20, -1598.40, 34.80),
            wardrobe = vec3(-153.80, -1594.10, 34.80),
            claimPed = {
                model = `g_m_y_famca_01`,
                coords = vec4(-140.60, -1590.90, 34.40, 50.0),
            },
        },
    },
    {
        id = 'vagos',
        label = 'Los Santos Vagos',
        color = 5,
        discordRoleId = '',
        claimVehicle = 'chino2',
        blip = { sprite = 84, color = 5, scale = 0.85 },
        redzone = { coords = vec3(331.40, -2041.80, 20.90), radius = 80.0, color = 5, alpha = 100 },
        points = {
            bossStash = vec3(334.20, -2044.50, 20.90),
            publicStash = vec3(328.80, -2040.10, 20.90),
            personalStash = vec3(326.50, -2043.60, 20.90),
            wardrobe = vec3(336.90, -2039.40, 20.90),
            claimPed = {
                model = `g_m_y_mexgoon_01`,
                coords = vec4(323.10, -2036.20, 20.50, 140.0),
            },
        },
    },
    {
        id = 'lostmc',
        label = 'The Lost MC',
        color = 40,
        discordRoleId = '',
        claimVehicle = 'daemon',
        blip = { sprite = 226, color = 40, scale = 0.85 },
        redzone = { coords = vec3(982.10, -104.40, 74.85), radius = 70.0, color = 40, alpha = 100 },
        points = {
            bossStash = vec3(985.40, -107.20, 74.85),
            publicStash = vec3(979.80, -102.90, 74.85),
            personalStash = vec3(977.50, -106.40, 74.85),
            wardrobe = vec3(988.10, -101.80, 74.85),
            claimPed = {
                model = `g_m_y_lost_01`,
                coords = vec4(974.20, -99.50, 74.35, 220.0),
            },
        },
    },
    {
        id = 'marabunta',
        label = 'Marabunta Grande',
        color = 3,
        discordRoleId = '',
        claimVehicle = 'faction2',
        blip = { sprite = 84, color = 3, scale = 0.85 },
        redzone = { coords = vec3(1250.40, -1575.80, 58.35), radius = 75.0, color = 3, alpha = 100 },
        points = {
            bossStash = vec3(1253.20, -1578.60, 58.35),
            publicStash = vec3(1247.80, -1573.20, 58.35),
            personalStash = vec3(1245.50, -1576.90, 58.35),
            wardrobe = vec3(1256.00, -1572.40, 58.35),
            claimPed = {
                model = `g_m_y_salvagoon_01`,
                coords = vec4(1241.90, -1569.80, 57.85, 30.0),
            },
        },
    },
}

function Config.GetGang(id)
    if type(id) ~= 'string' then return nil end
    for i = 1, #Config.Gangs do
        if Config.Gangs[i].id == id then
            return Config.Gangs[i]
        end
    end
    return nil
end

function Config.GetGangByDiscordRole(roleId)
    if type(roleId) ~= 'string' or roleId == '' then return nil end
    for i = 1, #Config.Gangs do
        local g = Config.Gangs[i]
        if g.discordRoleId and g.discordRoleId ~= '' and tostring(g.discordRoleId) == tostring(roleId) then
            return g
        end
    end
    return nil
end
