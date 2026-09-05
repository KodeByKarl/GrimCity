Config = Config or {}

Config.Spawn = {
    Debug = false,
    OpenCommand = "spawnselector",
    
    -- Respawn timer in seconds (900s = 15:00)
    RespawnTimer = 900,
    AllowEarlySpawn = true,

    -- Spawn points (jobs = nil → everyone; jobs = { 'police' } → that job only)
    Locations = {
        {
            id = "stl_morgue",
            name = "STL Spawn (Morgue)",
            description = "Rockford Hills morgue — $1,000 fee · 5 min recovery (2 min crutch).",
            coords = { x = -1679.9622, y = -291.5636, z = 51.8834, heading = 151.5166 },
            mapX = 36.5,
            mapY = 66.8,
            type = "hospital",
            image = "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?q=80&w=600&auto=format&fit=crop"
        },
        {
            id = "police_station",
            name = "Police Station",
            description = "Mission Row PD respawn — Police only.",
            coords = { x = 485.8881, y = -916.4838, z = 26.2386, heading = 272.8872 },
            mapX = 54.2,
            mapY = 71.5,
            type = "police",
            jobs = { "police" },
            image = "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=600&auto=format&fit=crop"
        },
    }
}
