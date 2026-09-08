return {
    Jobs = {
        ['police'] = vec4(485.8881, -916.4838, 26.2386, 272.8872),
        ['sheriff'] = vec4(1853.21, 3689.51, 34.27, 210.0),
        ['ambulance'] = vec4(-1038.44, -1356.31, 5.9474, 170.0),
        ['sambulance'] = vec4(-283.6857, 6325.4751, 32.3472, 278.8888),
        ['pambulance'] = vec4(-283.6857, 6325.4751, 32.3472, 278.8888),
    },
    Gangs = {},
    -- zone = 'city' | 'blaine' — STL auto-picks from where the player died.
    Locations = {
        ['murrieta'] = {
            label = 'City Hospital',
            area = 'Los Santos',
            zone = 'city',
            cost = 15000,
            coords = vec4(-1038.44, -1356.31, 5.9474, 170.0),
        },
        ['paleto_hospital'] = {
            label = 'Paleto Ambulance',
            area = 'Paleto Bay',
            zone = 'blaine',
            cost = 15000,
            coords = vec4(-283.6857, 6325.4751, 32.3472, 278.8888),
        },
        -- Fallback / STL
        ['morgue'] = {
            label = 'STL Spawn (Morgue)',
            area = 'Morgue',
            cost = 15000,
            coords = vec4(-1679.9622, -291.5636, 51.8834, 151.5166),
            hidden = true,
        },
    },
}
