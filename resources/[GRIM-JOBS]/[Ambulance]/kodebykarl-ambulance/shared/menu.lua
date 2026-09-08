return {
    menu = {
        access = {['ambulance'] = 0, ['sambulance'] = 0, ['pambulance'] = 0}
    },
    revive = {
        access = {['ambulance'] = 0, ['sambulance'] = 0, ['pambulance'] = 0},
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
        access = {['ambulance'] = 0, ['sambulance'] = 0, ['pambulance'] = 0},
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
        access = {['ambulance'] = 0, ['sambulance'] = 0, ['pambulance'] = 0},
    },
    bodybag = {
        access = {['ambulance'] = 0, ['sambulance'] = 0, ['pambulance'] = 0}
    },
    bed = {
        access = {['ambulance'] = 0, ['sambulance'] = 0, ['pambulance'] = 0},
        locations = {
            ambulance = {
                vec4(-1023.0645, -1363.4724, 6.8696, 72.8515),  -- bed 1
                vec4(-1023.7744, -1365.8915, 6.8696, 115.3542), -- bed 2
                vec4(-1023.9689, -1368.2661, 6.8696, 121.3029), -- bed 3
            },
            sambulance = {
                vec4(-264.4805, 6325.2949, 33.2788, 161.4241),
            },
            pambulance = {
                vec4(-264.4805, 6325.2949, 33.2788, 161.4241), -- bed 1
            },
        }
    },
    unbed = {
        access = {['ambulance'] = 0, ['sambulance'] = 0, ['pambulance'] = 0}
    }
}