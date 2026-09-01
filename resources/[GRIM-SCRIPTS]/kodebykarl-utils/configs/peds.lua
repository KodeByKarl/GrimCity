return {
    {
        model = 's_m_m_fiboffice_01',
        coords = vector4(241.1,-1378.89,33.74, 140.84),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 408,
            color = 3, 
            scale = 0.5,
            label = 'Driving School',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-book',
                    label = 'Driving School',
                    onSelect = function()
                        exports['cfx-keydi-utils']:openDMV()
                    end,
                    distance = 2.5
                }
            },
        }
    },
    {
        model = 'cs_movpremmale',
        coords = vec4(-545.042, -204.037, 38.215, 215.459),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 498,
            color = 3, 
            scale = 0.5,
            label = 'ID Card',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-id-card',
                    label = 'Request License',
                    onSelect = function()
                        if GetResourceState('kodebykarl-ui') == 'started' then
                            exports['kodebykarl-ui']:RequestLicense()
                        else
                            TriggerServerEvent('cfx-keydi-identification:server:giveIdItem')
                        end
                    end,
                    distance = 2.5
                },
                {
                    icon = 'fa-solid fa-user-pen',
                    label = 'Change Name',
                    onSelect = function()
                        exports['kodebykarl-ui']:OpenChangeNameMenu()
                    end,
                    distance = 2.5
                }
            },
        }
    },
    {
        model = 'a_m_m_mlcrisis_01',
        coords = vec4(-1038.838, -2730.971, 20.169, 237.722),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 226,
            color = 2,
            scale = 0.6,
            label = 'Rental',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-shop',
                    label = 'Open Rental',
                    onSelect = function ()
                        exports['kodebykarl-ui']:OpenRentalMenu('airport')
                    end,
                    distance = 3.0
                },
                {
                    icon = 'fa-solid fa-gift',
                    label = 'New Player Kit',
                    onSelect = function ()
                        TriggerServerEvent('cfx-keydi-utils:newplayerkit:server:claim')
                    end,
                    distance = 3.0
                }
            },
        }
    },
    {
        model = 'a_m_m_mlcrisis_01',
        coords = vec4(-1673.3219, -301.4520, 51.8120, 141.9751),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 226,
            color = 2,
            scale = 0.6,
            label = 'Rental',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-shop',
                    label = 'Open Rental',
                    onSelect = function ()
                        exports['kodebykarl-ui']:OpenRentalMenu('rockford')
                    end,
                    distance = 3.0
                }
            },
        }
    },
    {
        model = 'a_m_m_mlcrisis_01',
        coords = vec4(113.543, -3341.364, 6.007, 356.812),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 226,
            color = 2,
            scale = 0.6,
            label = 'Rental (Boat)',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-shop',
                    label = 'Open Rental',
                    onSelect = function ()
                        exports['kodebykarl-ui']:OpenRentalMenu('boat_lsia')
                    end,
                    distance = 3.0
                }
            },
        }
    },
    {
        model = 'a_m_m_mlcrisis_01',
        coords = vec4(-491.9571, -2928.2600, 6.0047, 49.3564),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 226,
            color = 2,
            scale = 0.6,
            label = 'Rental (Boat)',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-shop',
                    label = 'Open Rental',
                    onSelect = function ()
                        exports['kodebykarl-ui']:OpenRentalMenu('boat_terminal')
                    end,
                    distance = 3.0
                }
            },
        }
    },
    {
        model = 'a_m_m_mlcrisis_01',
        coords = vec4(-1796.238, -971.344, 2.174, 29.734),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 226,
            color = 2,
            scale = 0.6,
            label = 'Rental (Boat)',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-shop',
                    label = 'Open Rental',
                    onSelect = function ()
                        exports['kodebykarl-ui']:OpenRentalMenu('boat_delperro')
                    end,
                    distance = 3.0
                }
            },
        }
    },
    {
        model = 'a_m_m_mlcrisis_01',
        coords = vec4(-269.385, 6645.973, 7.427, 130.537),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 226,
            color = 2,
            scale = 0.6,
            label = 'Rental (Boat)',
            data = 0, -- Do not touch
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-shop',
                    label = 'Open Rental',
                    onSelect = function ()
                        exports['kodebykarl-ui']:OpenRentalMenu('boat_paleto')
                    end,
                    distance = 3.0
                }
            },
        }
    },
    {
        -- Sell Market NPC (coords must match kodebykarl-ui ConfigMarket.Locations)
        model = 'a_m_m_business_01',
        coords = vec4(342.9301, -1298.0554, 32.55, 154.4067),
        minusOne = false,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        currentpednumber = 0,
        blip = {
            sprite = 78,
            color = 2,
            scale = 0.85,
            label = 'Sell Market',
            data = 0,
        },
        target = {
            options = {
                {
                    icon = 'fa-solid fa-store',
                    label = 'Open Sell Market',
                    onSelect = function()
                        if GetResourceState('kodebykarl-ui') == 'started' then
                            exports['kodebykarl-ui']:OpenSellMarket()
                        else
                            TriggerEvent('cfx-keydi-market:client:open')
                        end
                    end,
                    distance = 2.5
                }
            },
        }
    },

}