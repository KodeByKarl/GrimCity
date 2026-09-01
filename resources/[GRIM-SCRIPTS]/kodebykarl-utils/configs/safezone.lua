return {
    Zones = {
        {
            name = 'hospital_safezone',
            label = 'Hospital Safezone',
            debug = false,
            thickness = 60.0,
            points = {
                vec3(1096.5913, -1455.3551, 35.9425),
                vec3(1161.0087, -1454.7744, 34.7756),
                vec3(1161.4196, -1615.7422, 34.8027),
                vec3(1093.9041, -1612.3132, 29.2213),
            },
            -- Everyone: no weapons. Police: stun gun only.
            restrictWeapons = true,
            policeJobs = { 'police' },
            policeAllowedWeapons = {
                `WEAPON_STUNGUN`,
                `WEAPON_STUNGUN_MP`,
            },
        },
        {
            name = 'mechanic_safezone',
            label = 'Mechanic Safezone',
            debug = false,
            thickness = 60.0,
            points = {
                vec3(-380.7108, -99.3672, 39.0560),
                vec3(-372.4598, -69.6116, 45.6595),
                vec3(-291.0760, -97.7739, 47.0032),
                vec3(-301.5728, -134.3909, 43.7095),
                vec3(-309.7080, -167.0191, 39.9751),
                vec3(-350.2759, -180.0781, 38.1522),
                vec3(-364.4107, -156.0221, 38.2316),
            },
            -- Everyone: no weapons. Police: stun gun only.
            restrictWeapons = true,
            policeJobs = { 'police' },
            policeAllowedWeapons = {
                `WEAPON_STUNGUN`,
                `WEAPON_STUNGUN_MP`,
            },
        },
    },
}

