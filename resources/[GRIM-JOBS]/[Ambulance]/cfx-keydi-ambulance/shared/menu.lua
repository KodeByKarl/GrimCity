return {
    menu = {
        access = {['ambulance'] = 0, ['sambulance'] = 0}
    },
    revive = {
        access = {['ambulance'] = 0, ['sambulance'] = 0},
        require = {
            item = 'ems_medikit',
            amount = 1
        },
        -- Anyone with a medikit can ox_target a downed player (no EMS payout).
        civilian = {
            item = 'medikit',
            amount = 1
        },
        reward = {
            item = 'money',
            amount = 200
        }
    },
    heal = {
        access = {['ambulance'] = 0, ['sambulance'] = 0},
        require = {
            item = 'ems_medikit',
            amount = 1
        },
        civilian = {
            item = 'medikit',
            amount = 1
        },
        reward = {
            item = 'money',
            amount = 100
        }
    },
    vitals = {
        access = {['ambulance'] = 0, ['sambulance'] = 0},
    },
    bodybag = {
        access = {['ambulance'] = 0, ['sambulance'] = 0}
    },
    bed = {
        access = {['ambulance'] = 0, ['sambulance'] = 0},
        locations = {
            ambulance = {
                vec4(1117.5215, -1543.2089, 35.8833, 179.6849), -- bed 1
                vec4(1121.0836, -1543.1462, 35.8833, 87.8008),  -- bed 2
                vec4(1124.6890, -1543.1010, 35.8833, 89.4009),  -- bed 3
                vec4(1124.7041, -1543.0934, 35.8833, 89.4011),  -- bed 4
                vec4(1128.2155, -1543.2877, 35.8833, 267.4705), -- bed 5
            },
            sambulance = {
                -- vec4(1676.010, 3647.416, 36.339, 35.303),
                -- vec4(1671.604, 3645.180, 36.339, 32.474),
                -- vec4(1667.124, 3642.354, 36.339, 32.141),
                -- vec4(1662.616, 3639.992, 36.339, 26.354),
            }
        }
    },
    unbed = {
        access = {['ambulance'] = 0, ['sambulance'] = 0}
    }
}