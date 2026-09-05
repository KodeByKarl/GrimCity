--[[
    Regions — in-game instance switcher (routing buckets).

    Each region is a separate routing bucket on THIS FiveM process (not a
    `connect` command). Players keep the same character/inventory.
    Players only see others in the SAME region (bucket isolation).

    Region 1 = All Farm (autofarm, raven, weed, orange)
    Region 2 = School (city / school RP — default for new players)
    Region 3 = Turf War
    Region 4 = Turf War
]]

ConfigServerLocations = {}

ConfigServerLocations.Debug = false
ConfigServerLocations.DefaultId = "region2"
-- Stay at current coords. Switching only changes routing bucket / functions.
ConfigServerLocations.TeleportOnSwitch = false
ConfigServerLocations.SwitchCooldown = 8 -- seconds between switches
ConfigServerLocations.FadeOutMs = 400
ConfigServerLocations.FadeInMs = 700

-- Must be inside a safezone to switch (jail / arena still always locked)
ConfigServerLocations.RequireSafezone = true
ConfigServerLocations.LockInJail = true
ConfigServerLocations.LockInArena = true

ConfigServerLocations.WrongServerNotify = "This is only available on %s. Open Control Center (F5) → Regions to switch."

-- Legacy id remaps (old Server #1 / #2 → Regions)
ConfigServerLocations.LegacyIdMap = {
    server1 = "region2",
    server2 = "region1",
}

-- Public location slots always follow sv_maxclients in server.cfg (not these numbers).
-- Optional loc.maxPlayers is only used for side-job instances, and is still capped by sv_maxclients.

ConfigServerLocations.PublicServers = {
    {
        id = "region1",
        name = "Region 1 · All Farm",
        tag = "FARM REALM",
        type = "farm",
        description = "All farms available here — autofarm, hunting, weed, and orange picking.",
        bucket = 1,
        spawn = vec4(2004.3286, 4902.1523, 42.7468, 58.4939),
        functions = { "grind", "autofarm", "raven", "weedfarm", "job_orange" },
        status = "ONLINE",
    },
    {
        id = "region2",
        name = "Region 2 · School",
        tag = "SCHOOL REALM",
        type = "school",
        description = "School / city RP. Jobs, housing, and social roleplay.",
        bucket = 0,
        spawn = vec4(222.2027, -864.0162, 30.2922, 1.0),
        functions = { "main", "jobs", "housing", "school" },
        status = "ONLINE",
    },
    {
        id = "region3",
        name = "Region 3 · Turf War",
        tag = "TURF REALM",
        type = "turfwar",
        description = "Turf War instance. Gang wars only work here and on Region 4.",
        bucket = 2,
        spawn = vec4(-2248.41, 269.54, 174.60, 0.0),
        functions = { "turfwar" },
        status = "ONLINE",
    },
    {
        id = "region4",
        name = "Region 4 · Turf War",
        tag = "TURF REALM",
        type = "turfwar",
        description = "Second Turf War instance. Isolated from Region 3 players.",
        bucket = 3,
        spawn = vec4(2506.01, -383.29, 94.12, 0.0),
        functions = { "turfwar" },
        status = "ONLINE",
    },
}

-- Side job instances (Orange only)
ConfigServerLocations.SideJobServers = {
    {
        id = "job_orange",
        name = "Orange Picking Instance",
        tag = "ORANGE JOB",
        type = "job",
        maxPlayers = 30,
        bucket = 12,
        spawn = vec4(2326.0691, 4761.2773, 35.9651, 47.1926),
        description = "Pick oranges in a dedicated orchard instance.",
        functions = { "grind", "autofarm", "job_orange" },
    },
}

function ConfigServerLocations.NormalizeId(id)
    if type(id) ~= "string" or id == "" then return nil end
    local mapped = ConfigServerLocations.LegacyIdMap and ConfigServerLocations.LegacyIdMap[id]
    if mapped then return mapped end
    return id
end

function ConfigServerLocations.GetById(id)
    id = ConfigServerLocations.NormalizeId(id)
    if type(id) ~= "string" or id == "" then return nil, nil end

    for i = 1, #ConfigServerLocations.PublicServers do
        local loc = ConfigServerLocations.PublicServers[i]
        if loc.id == id then
            return loc, "public"
        end
    end

    for i = 1, #ConfigServerLocations.SideJobServers do
        local loc = ConfigServerLocations.SideJobServers[i]
        if loc.id == id then
            return loc, "job"
        end
    end

    return nil, nil
end

function ConfigServerLocations.HasFunction(location, fn)
    if not location or type(fn) ~= "string" then return false end
    if location.type == fn then return true end

    local list = location.functions
    if type(list) ~= "table" then return false end

    for i = 1, #list do
        if list[i] == fn or list[i] == "*" then
            return true
        end
    end

    return false
end

--- Client cache so grind scripts see the new server immediately (state bags lag).
function ConfigServerLocations.SetClientCurrentId(id)
    id = ConfigServerLocations.NormalizeId(id)
    if type(id) == "string" and id ~= "" then
        ConfigServerLocations.ClientCurrentId = id
    end
end

function ConfigServerLocations.GetClientCurrentId()
    if ConfigServerLocations.ClientCurrentId and ConfigServerLocations.ClientCurrentId ~= "" then
        return ConfigServerLocations.NormalizeId(ConfigServerLocations.ClientCurrentId)
    end
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.grimServerId then
        return ConfigServerLocations.NormalizeId(LocalPlayer.state.grimServerId)
    end
    return ConfigServerLocations.DefaultId
end

--- Server: pass player id. Client: omit src (uses client cache / LocalPlayer.state).
function ConfigServerLocations.CanUseFunction(fn, src)
    local id
    if IsDuplicityVersion() then
        src = tonumber(src)
        if not src or src < 1 then return false end
        local state = Player(src).state
        id = ConfigServerLocations.NormalizeId((state and state.grimServerId) or ConfigServerLocations.DefaultId)
    else
        id = ConfigServerLocations.GetClientCurrentId()
    end

    local loc = ConfigServerLocations.GetById(id)
    return ConfigServerLocations.HasFunction(loc, fn)
end

function ConfigServerLocations.LocationAllows(location, fn)
    if location then
        return ConfigServerLocations.HasFunction(location, fn)
            or ConfigServerLocations.HasFunction(location, "grind")
    end
    return ConfigServerLocations.CanUseFunction(fn)
        or ConfigServerLocations.CanUseFunction("grind")
end

function ConfigServerLocations.FindLocationForFunction(fn)
    for i = 1, #ConfigServerLocations.PublicServers do
        local loc = ConfigServerLocations.PublicServers[i]
        if ConfigServerLocations.HasFunction(loc, fn) then
            return loc
        end
    end
    for i = 1, #ConfigServerLocations.SideJobServers do
        local loc = ConfigServerLocations.SideJobServers[i]
        if ConfigServerLocations.HasFunction(loc, fn) then
            return loc
        end
    end
    return nil
end

function ConfigServerLocations.WrongServerMessage(fn)
    local loc = ConfigServerLocations.FindLocationForFunction(fn)
    local name = loc and loc.name or "the correct Region"
    return (ConfigServerLocations.WrongServerNotify):format(name)
end
