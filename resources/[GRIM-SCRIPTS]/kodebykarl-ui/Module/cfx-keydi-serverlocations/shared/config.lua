--[[
    Server Locations — in-game instance switcher.

    Each location is a routing bucket on THIS FiveM process (not a `connect`
    command). Players stay in the same character/inventory. Functions such as
    grind jobs only work on the locations that list them.

    Server #1 = Main RP (default on join)
    Server #2 = Grind realm (autofarm, chicken, raven, weed)
]]

ConfigServerLocations = {}

ConfigServerLocations.Debug = false
ConfigServerLocations.DefaultId = "server1"
-- Stay at current coords. Switching only changes routing bucket / functions.
ConfigServerLocations.TeleportOnSwitch = false
ConfigServerLocations.SwitchCooldown = 8 -- seconds between switches
ConfigServerLocations.FadeOutMs = 400
ConfigServerLocations.FadeInMs = 700

-- Must be inside a safezone to switch (jail / arena still always locked)
ConfigServerLocations.RequireSafezone = true
ConfigServerLocations.LockInJail = true
ConfigServerLocations.LockInArena = true

ConfigServerLocations.WrongServerNotify = "This is only available on %s. Open Control Center (F5) → Server Locations to switch."

-- Public location slots always follow sv_maxclients in server.cfg (not these numbers).
-- Optional loc.maxPlayers is only used for side-job instances, and is still capped by sv_maxclients.

-- Public city / grind realms
ConfigServerLocations.PublicServers = {
    {
        id = "server1",
        name = "Server #1 · Main",
        tag = "MAIN REALM",
        type = "main",
        description = "Main city RP. Jobs, housing, and social roleplay.",
        bucket = 0,
        spawn = vec4(222.2027, -864.0162, 30.2922, 1.0),
        functions = { "main", "jobs", "housing" },
        status = "ONLINE",
    },
    {
        id = "server2",
        name = "Server #2 · Grind",
        tag = "GRIND REALM",
        type = "grind",
        description = "Dedicated grinding instance. Farms, hunting, and gather jobs live here only.",
        bucket = 1,
        spawn = vec4(2004.3286, 4902.1523, 42.7468, 58.4939),
        functions = { "grind", "autofarm", "chicken", "raven", "weedfarm" },
        status = "ONLINE",
    },
}

-- Side job grinding instances (join from Server Locations → Side Jobs)
ConfigServerLocations.SideJobServers = {
    {
        id = "job_crab",
        name = "Crab Hunting Instance",
        tag = "CRAB JOB",
        type = "job",
        maxPlayers = 30,
        bucket = 11,
        spawn = vec4(-1593.21, 5193.04, 4.31, 295.0),
        description = "Grind crab harvesting without city lag.",
        functions = { "grind", "job_crab" },
    },
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
    {
        id = "job_fish",
        name = "Fishing Pier Instance",
        tag = "FISHING JOB",
        type = "job",
        maxPlayers = 30,
        bucket = 13,
        spawn = vec4(-1826.84, -1224.12, 13.02, 50.0),
        description = "Dedicated oceanic fishing instance.",
        functions = { "grind", "job_fish" },
    },
    {
        id = "job_recyc",
        name = "Recycling Center Instance",
        tag = "RECYCLING",
        type = "job",
        maxPlayers = 30,
        bucket = 14,
        spawn = vec4(55.77, 6472.12, 31.43, 225.0),
        description = "Material recycling & scrap grinding.",
        functions = { "grind", "job_recyc" },
    },
}

function ConfigServerLocations.GetById(id)
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
    if type(id) == "string" and id ~= "" then
        ConfigServerLocations.ClientCurrentId = id
    end
end

function ConfigServerLocations.GetClientCurrentId()
    if ConfigServerLocations.ClientCurrentId and ConfigServerLocations.ClientCurrentId ~= "" then
        return ConfigServerLocations.ClientCurrentId
    end
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.grimServerId then
        return LocalPlayer.state.grimServerId
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
        id = (state and state.grimServerId) or ConfigServerLocations.DefaultId
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
    local name = loc and loc.name or "the Grind server"
    return (ConfigServerLocations.WrongServerNotify):format(name)
end
