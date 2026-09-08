ConfigChat = {
    fadeTimeout = 10000, -- hide message overlay 10s after last show/message/open
    suggestionLimit = 4,
    cooldownSeconds = 2,

    -- Personal OOC text chat is disabled. Only /commands are accepted (e.g. /wl, /gang, /me).
    allowPersonalChat = false,
    personalChatBlockedMessage = '[SYSTEM] Personal chat is disabled. Use commands only (example: /wl message).',

    -- Hide staff-only clutter from chat autocomplete (e.g. /Gv give-item).
    hiddenSuggestions = { '/gv', '/Gv', '/gc' },

    -- Freestyle only: type your own message. No fixed Auto Templates picker.
    commandSuggestions = {
        { name = '/wl', help = 'Job announcement (Freestyle)', params = {{ name = 'message', help = 'Your announcement' }} },
        { name = '/ems', help = 'EMS announcement (Freestyle)', params = {{ name = 'message', help = 'Your announcement' }} },
        { name = '/pd', help = 'Police / Sheriff announcement (Freestyle)', params = {{ name = 'message', help = 'Your announcement' }} },
        { name = '/police', help = 'Police / Sheriff announcement (Freestyle)', params = {{ name = 'message', help = 'Your announcement' }} },
        { name = '/mech', help = 'Mechanic announcement (Freestyle)', params = {{ name = 'message', help = 'Your announcement' }} },
        { name = '/gang', help = 'Gang announcement (Freestyle)', params = {{ name = 'message', help = 'Your announcement' }} },
    },

    -- Fixed Auto Templates removed — everything uses freestyle /wl [message].
    jobAutoTemplates = {
        enabled = false,
        jobs = {},
    },

    -- Freestyle job banners (same look as /gang). Type your own message.
    -- color = message text, headerColor = FEED line / time.
    jobTemplate = {
        enabled = true,
        command = "wl",
        -- Any on-duty job can /wl unless blocked below (or listed in allowedJobs when allowAnyJob is false).
        allowAnyJob = true,
        blockedJobs = {
            ["unemployed"] = true,
            ["offpolice"] = true,
            ["offsheriff"] = true,
            ["offambulance"] = true,
            ["offsambulance"] = true,
            ["offpambulance"] = true,
            ["offdoj"] = true,
            ["offmechanic"] = true,
        },
        default = {
            gif = nil,
            background = "#111111",
            color = "#ffffff",
            headerColor = "#cfcfcf",
        },
        -- Freestyle messages + custom banner images per job.
        jobs = {
            ["police"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/GCPD.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["sheriff"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/GCSD.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["doj"] = {
                gif = nil,
                background = "#1a0f2e",
                color = "#ffffff",
                headerColor = "#c4b5fd",
            },
            ["ambulance"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/01_EMS.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["sambulance"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/01_EMS.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["pambulance"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/01_EMS.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["mechanic"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/mechanibai.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["uwu"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/UWU.png",
                background = nil,
                color = "#111111",
                headerColor = "#4a1a2a",
            },
            ["tacoshop"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/taco.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["taco"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/taco.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["burgershot"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/BSHOT.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["8ball"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/8ball.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#e0aaff",
            },
            ["weedshop"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/weedshop.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["school"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/GCU.png",
                background = nil,
                color = "#ffffff",
                headerColor = "#ffffff",
            },
            ["tattooshop1"] = {
                gif = nil,
                background = "#111111",
                color = "#ffffff",
                headerColor = "#cfcfcf",
            },
            ["tattooshop2"] = {
                gif = nil,
                background = "#111111",
                color = "#ffffff",
                headerColor = "#cfcfcf",
            },
            ["tattooshop3"] = {
                gif = nil,
                background = "#111111",
                color = "#ffffff",
                headerColor = "#cfcfcf",
            },
            ["vu"] = {
                gif = nil,
                background = "#1a0814",
                color = "#ffffff",
                headerColor = "#f9a8d4",
            },
        }
    },

    gangTemplate = {
        enabled = true,
        -- Slash command is registered by kodebykarl-gangsystem as /gang only. Do not set this to gc/gang.
        command = false,
        -- Any assigned ESX gang can /gang (Freestyle).
        allowAnyGang = true,
        default = {
            gif = nil,
            background = "#111111",
            color = "#ffffff",
            headerColor = "#cfcfcf",
        },
        -- Optional custom colors. Keys MUST match es_extended gang names.
        gangs = {
            ["grimgang"] = {
                label = "GrimGang",
                gif = nil,
                background = "#1a0a0a",
                color = "#ffffff",
                headerColor = "#e8b4b4",
            },
        }
    },

    adminTemplate = {
        enabled = true,
        command = "admin",
        permissions = { "group.moderator", "group.admin", "group.superadmin", "group.developer" },
        gif = nil,
        background = "#DC143C",
        color = "#ffffff",
        headerColor = "#ffcccc",
    },

    -- /staff — staff announcement visible to ALL online players
    staffTemplate = {
        enabled = true,
        command = "staff",
        groups = { "mod", "moderator", "admin", "superadmin", "owner", "developer" },
        gif = nil,
        background = "#7C3AED", -- purple
        color = "#ffffff",
        headerColor = "#e9d5ff",
    },

    -- /staffo — staff-only chat (only staff groups can see)
    staffOnlyTemplate = {
        enabled = true,
        command = "sf",
        groups = { "mod", "moderator", "admin", "superadmin", "owner", "developer" },
        gif = nil,
        background = "#1E3A5F", -- dark blue
        color = "#ffffff",
        headerColor = "#93c5fd",
    },

    Me3D = {
        language = 'en',
        color = { r = 230, g = 230, b = 230, a = 255 },
        font = 0,
        time = 5000,
        scale = 0.5,
        dist = 250,
    },

    Me3DLanguages = {
        ['en'] = {
            commandName = 'me',
            commandDescription = 'Display an action above your head.',
            commandSuggestion = {{ name = 'action', help = '"scratch his nose" for example.'}},
            prefix = 'the person '
        }
    },

    Me3DLanguage = 'en'
}

return ConfigChat
