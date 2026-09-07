Config = {}

--[[
    Discord logs (same bot pattern as cfx-keydi-utils / banking / business).
    Create: POLICE-LICENSE, POLICE-DOCS, POLICE-ACTION
]]
Config.Logs = {
    Enabled = true,
    BotToken = "MTUzNjM2NDUyMjc5MTUwNjA0Mg.GfAaOT.pXdZcrMv-0yl2Blw9cESfKGSbv56AvD5C6-jTo",
    GuildID = "1536358290777444397",

    ChannelNames = {
        license = "POLICE-LICENSE",
        docs = "POLICE-DOCS",
        action = "POLICE-ACTION",
    },

    ChannelIDs = {
        license = "1536366551773610086",
        docs = "1536366555833696407",
        action = "1536366560292114482",
    },

    LogTypes = {
        license = true,
        docs = true,
        action = true, -- search, id check, cuff, uncuff, gsr
    },

    EmbedColors = {
        licenseGrant = 5763719,
        licenseRevoke = 15158332,
        docs = 3447003,
        search = 10181046,
        id = 3066993,
        cuff = 15105570,
        uncuff = 5763719,
        gsr = 15844367,
    },

    PostCooldownMs = 500,
}

-- Object Config --
Config.MaxSpikes = 10
Config.Objects = {
    ["cone"] = {model = `prop_roadcone02a`, freeze = false},
    ["barrier"] = {model = `prop_barrier_work06a`, freeze = true},
    ["roadsign"] = {model = `prop_snow_sign_road_06g`, freeze = true},
    ["tent"] = {model = `prop_gazebo_03`, freeze = true},
    ["light"] = {model = `prop_worklight_03b`, freeze = true},
}

-- Issued License --
Config.GiveLicense = {
    authorized = {['police'] = 4, ['sheriff'] = 4}
}

-- Scoreboard priority (Safe / Hold / Cooldown / In Progress) in the F6 menu
-- In Progress is set automatically when a robbery starts.
Config.PriorityStatus = {
    enabled = true,
    -- Minimum grade required to change status. All officers can view.
    authorized = {
        ['police'] = 0,
        ['sheriff'] = 0,
    },
}

-- GSR Test Configuration --
Config.GSR = {
    GSRTestTimer = 900
}

-- Riot Shield (F6 toggle) --
Config.RiotShield = {
    model = `prop_ballistic_shield`,
    damageReduction = 0.5, -- 0.5 = take 50% damage while shield is active
    bone = 18905, -- left hand
    offset = vector3(0.3, 0.0, 0.1),
    rotation = vector3(270.0, 120.0, 0.0),
    anim = {
        dict = 'missfam4',
        name = 'base',
    },
}

-- Law Enforcement Config --
Config.LawEnforcement = {
    police = {
        Blip = {
            Coords  = vector3(68.4584, -433.7952, 39.1436),
			Sprite  = 60,
			Display = 4,
			Scale   = 1.0,
			Colour  = 38,
			Label = 'Police Department'
        },
    },
    sheriff = {
        Blip = {
            Coords  = vector3(1886.3198, 3661.4883, 37.3998),
			Sprite  = 60,
			Display = 4,
			Scale   = 1.0,
			Colour  = 5,
			Label = "Sheriff's Office"
        },
    },
}

-- Documents --
Config.Documents = {
    -- Any player can open My Documents (copies). Jobs below can also issue.
    command = 'documents',
    commandHelp = 'Open your documents. Show or give copies to nearby players.',
    issuerJobs = {
        police = true,
        sheriff = true,
        ambulance = true,
        sambulance = true,
    },
    birthdateFormat = 'DD/MM/YYYY',
    paperProp = {
        name = 'prop_cd_paper_pile1',
        xRot = -130.0,
        yRot = -50.0,
        zRot = 0.0,
    },
    locale = {
        receiveNotification = 'You received a document: ',
        giveNotification = 'You gave a document: ',
        cancel = 'Cancel',
        noPlayersAround = "There's no one around you",
        showDocument = 'Show Document',
        giveCopy = 'Give Copy',
    },
    locations = {
        {
            job = 'police',
            coords = vector3(68.3700, -434.0321, 39.1436),
            radius = 1.5,
            label = 'Open Documents',
            icon = 'fa-solid fa-file-lines',
        },
        {
            job = 'sheriff',
            coords = vector3(1886.3198, 3661.4883, 37.3998),
            radius = 1.5,
            label = 'Open Documents',
            icon = 'fa-solid fa-file-lines',
        },
        {
            jobs = { ['ambulance'] = 0, ['sambulance'] = 0 },
            coords = vector3(1125.2184, -1537.4072, 37.1248),
            radius = 1.5,
            label = 'Medical Certificate',
            icon = 'fa-solid fa-file-medical',
        },
    },
    -- Seeded into k5_document_templates if the job has none yet
    DefaultTemplates = {
        police = {
            {
                minGrade = 0,
                documentName = 'Police Report',
                documentDescription = 'Official LSPD incident / crime report',
                fields = {
                    { name = 'Suspect Name', value = '' },
                    { name = 'Incident Location', value = '' },
                    { name = 'Date / Time', value = '' },
                    { name = 'Charges', value = '' },
                },
                infoName = 'REPORT DETAILS',
                infoTemplate = '',
            },
            {
                minGrade = 0,
                documentName = 'Traffic Citation',
                documentDescription = 'Official traffic citation / fine notice',
                fields = {
                    { name = 'Driver Name', value = '' },
                    { name = 'Vehicle Plate', value = '' },
                    { name = 'Violation', value = '' },
                    { name = 'Fine Amount', value = '' },
                },
                infoName = 'CITATION DETAILS',
                infoTemplate = '',
            },
            {
                minGrade = 0,
                documentName = 'Arrest Warrant',
                documentDescription = 'Authorized warrant for arrest',
                fields = {
                    { name = 'Suspect Name', value = '' },
                    { name = 'DOB', value = '' },
                    { name = 'Charges', value = '' },
                    { name = 'Issuing Officer', value = '' },
                },
                infoName = 'WARRANT DETAILS',
                infoTemplate = '',
            },
        },
        sheriff = {
            {
                minGrade = 0,
                documentName = 'Sheriff Report',
                documentDescription = 'Official BCSO incident / crime report',
                fields = {
                    { name = 'Suspect Name', value = '' },
                    { name = 'Incident Location', value = '' },
                    { name = 'Date / Time', value = '' },
                    { name = 'Charges', value = '' },
                },
                infoName = 'REPORT DETAILS',
                infoTemplate = '',
            },
            {
                minGrade = 0,
                documentName = 'Traffic Citation',
                documentDescription = 'Official traffic citation / fine notice',
                fields = {
                    { name = 'Driver Name', value = '' },
                    { name = 'Vehicle Plate', value = '' },
                    { name = 'Violation', value = '' },
                    { name = 'Fine Amount', value = '' },
                },
                infoName = 'CITATION DETAILS',
                infoTemplate = '',
            },
            {
                minGrade = 0,
                documentName = 'Arrest Warrant',
                documentDescription = 'Authorized warrant for arrest',
                fields = {
                    { name = 'Suspect Name', value = '' },
                    { name = 'DOB', value = '' },
                    { name = 'Charges', value = '' },
                    { name = 'Issuing Deputy', value = '' },
                },
                infoName = 'WARRANT DETAILS',
                infoTemplate = '',
            },
        },
        ambulance = {
            {
                minGrade = 0,
                documentName = 'Medical Certificate',
                documentDescription = 'Official EMS medical certificate',
                fields = {
                    { name = 'Patient Name', value = '' },
                    { name = 'Date of Birth', value = '' },
                    { name = 'Diagnosis', value = '' },
                    { name = 'Treatment Given', value = '' },
                    { name = 'Fit for Duty / Work', value = '' },
                    { name = 'Issuing Medic', value = '' },
                },
                infoName = 'MEDICAL DETAILS',
                infoTemplate = '',
            },
        },
        sambulance = {
            {
                minGrade = 0,
                documentName = 'Medical Certificate',
                documentDescription = 'Official EMS medical certificate',
                fields = {
                    { name = 'Patient Name', value = '' },
                    { name = 'Date of Birth', value = '' },
                    { name = 'Diagnosis', value = '' },
                    { name = 'Treatment Given', value = '' },
                    { name = 'Fit for Duty / Work', value = '' },
                    { name = 'Issuing Medic', value = '' },
                },
                infoName = 'MEDICAL DETAILS',
                infoTemplate = '',
            },
        },
    },
}

-- Police Coin Harvesting / Auto-Farm --
Config.CoinHarvest = {
    enabled = true,
    job = 'police',
    locations = {
        vector4(53.6287, -435.0399, 39.1436, 69.8936),
        vector4(54.7880, -431.7105, 39.1436, 93.3263),
    },
    interactDistance = 1.5,
    drawDistance = 6.0,
    duration = 10000, -- 10 seconds progress bar
    reward = {
        item = 'grimpolicecoin',
        min = 1,
        max = 10,
    },
    anim = {
        dict = 'anim@heists@prison_heiststation@cop_reactions',
        clip = 'cop_b_idle',
        flag = 1,
    },
}

