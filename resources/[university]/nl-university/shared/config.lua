-- =========================================
-- NOLIMITS UNIVERSITY - UNIFIED CONFIGURATION
-- =========================================
-- Visit: https://nolimits.gitbook.io/nolimits/university-script
-- Support: https://discord.gg/Swj5A8ZhC9

Config = {}

-- =========================================
-- 1. GENERAL SETTINGS
-- =========================================

Config.Framework = 'auto' -- Options: 'esx', 'qbcore', 'qbx', or 'auto' (automatically detects)
Config.TargetSystem = "ox_target" -- Options: "qb-target" or "ox_target"
Config.InventorySystem = 'ox_inventory' -- Options: 'ox_inventory', 'qb-inventory', 'qs-inventory', or 'ak47_inventory'
Config.Language = 'en' -- Options: 'en' for English, 'fr' for French
Config.debug = false -- Set to TRUE to use /zone box command for getting coordinates

-- =========================================
-- 2. STUDENT ID & ITEMS
-- =========================================

Config.StudentIDItem = 'student_id' -- Item name for student ID card
Config.OneBagInInventory = true -- Only allow 1 backpack per player

-- =========================================
-- 3. STORAGE CONFIGURATION
-- =========================================

-- Backpack Storage Capacity
Config.BackpackStorage = {
    slots = 8,
    weight = 10000
}

-- Locker Storage Capacity
Config.Locker = {
    label = "Metal School Locker",
    slots = 10,
    weight = 5000
}

-- =========================================
-- 4. MAP BLIPS
-- =========================================

Config.UniversityBlip = {
    {
        coords = vec3(-1652.97, 172.24, 64.33),
        sprite = 419,
        color = 0,
        scale = 0.9,
        name = "University - Main Campus",
        shortRange = true
    }
}

Config.ShowBlipHoverInfo = true

-- =========================================
-- 5. DIRECTOR OFFICE LOCATIONS
-- =========================================

Config.DirectorMenu = {
    vector3(-1656.5, 193.2, 61.65),  -- Main Director's office
    --vector3(-1653.2, 189.9, 61.65)   -- Add more locations if needed
}

-- =========================================
-- 5.1 DIRECTOR ZONE CONFIGURATION
-- =========================================

Config.DirectorZone = {
    enabled = true, -- Set to false to disable the director zone
    name = "Director Zone",
    coords = vec3(-1655.0, 190.25, 62.25),
    size = vec3(9.75, 5.25, 3.0),
    rotation = 296.0,
    debug = false,
    
    -- Notification settings
    notifications = {
        enter = {
            title = "Director Room",
            description = "You have entered the exclusive Director Room!",
            type = "success",
            icon = "fa-solid fa-door-open",
            duration = 5000,
            position = "top"
        },
        exit = {
            title = "Director Room",
            description = "You have left the Director Room.",
            type = "inform",
            icon = "fa-solid fa-door-closed",
            duration = 3000,
            position = "top"
        }
    },
    
    -- Special effects
    effects = {
        playSound = true,
        soundName = "SELECT",
        soundDict = "HUD_FRONTEND_DEFAULT_SOUNDSET",
        screenFade = true,
        fadeDuration = 500
    }
}

-- =========================================
-- 6. INTERACTION ZONES
-- =========================================

Config.InteractionZone = {
    size = vec3(0.75, 0.75, 0.75) -- Default size for interaction zones
}

-- =========================================
-- 7. SCHOOL BELL
-- =========================================
-- Who may ring: job name + lowest grade (0 = trainee, 1 = employee, etc.).
-- Where: add one vec3 per bell. More campuses = more lines in Locations.
-- Legacy configs can use Location = vec3(...) instead of Locations; both work.

Config.Bell = {
    Job = "school",
    JobGrade = 2,

    Locations = {
        vec3(-1655.4, 182.4, 61.9),
        -- vec3(-1700.0, 200.0, 62.0),
    },

    InteractionDistance = 0.7,
    Cooldown = 60,
    NotificationRadius = 150.0,

    Sound = {
        name = "doorbell",
        url = "nui://nl-university/html/sounds/bell.ogg",
        volume = 0.5,
        maxVolume = 0.9,
        range = 60.0
    },
    Animation = {
        dict = "anim@apt_trans@elevator",
        anim = "elev_1",
        duration = 2000
    }
}

-- Bell Notification Settings
Config.Notifications = {
    success = {
        title = "School Bell",
        description = "You have successfully rung the bell!",
        type = "success",
        icon = "fa-solid fa-bell",
        position = "top",
        duration = 3000
    },
    cooldown = {
        title = "Cooldown",
        description = "Please wait before ringing the bell again.",
        type = "error",
        icon = "fa-solid fa-bell",
        position = "top",
        duration = 3000
    },
    noPermission = {
        title = "School Bell",
        description = "You do not have permission to ring the bell.",
        type = "error",
        icon = "fa-solid fa-bell",
        position = "top",
        duration = 3000
    }
}

-- =========================================
-- 8. PRINTER CONFIGURATION
-- =========================================

Config.Printer = {
    Zones = {
        vector3(-1649.8502, 161.7986, 66.9664),
        vector3(-1660.64, 182.07, 66.61),
        vector3(-1654.73, 156.37, 70.8)
    },
    PaperItem = 'printer_paper',
    MaxCopies = 10,
    BaseDuration = 5000, -- Base time to print (ms)
    PerCopyDuration = 1000, -- Additional time per copy (ms)
    Cooldown = 0 -- Cooldown between prints (seconds)
}

-- =========================================
-- 9. STUDENT LOCKERS
-- =========================================

Config.StudentLockers = {
    -- Locker Settings
    RequiredJob = "school",
    InteractionDistance = 2.5,
    InteractionLabel = "Open School Personal Locker",
    InteractionIcon = "fa-solid fa-lock",
    
    -- Locker Zones (Ground Floor)
    GroundFloor = {
        { name = "locker_1", coords = vec3(-1666.0, 177.75, 66.0), size = vec3(0.5, 3.5, 3.25), rotation = 296.25 },
        { name = "locker_2", coords = vec3(-1659.5, 180.75, 66.5), size = vec3(0.5, 2.5, 2.25), rotation = 115.0 },
        { name = "locker_3", coords = vec3(-1652.5, 184.0, 66.55), size = vec3(3.9, 0.5, 2.0), rotation = 24.0 },
        { name = "locker_4", coords = vec3(-1651.1, 181.15, 66.5), size = vec3(3.85, 0.8, 2.25), rotation = 25.0 },
        { name = "locker_5", coords = vec3(-1654.65, 178.7, 66.6), size = vec3(2.35, 2.25, 1.95), rotation = 26.0 },
        { name = "locker_6", coords = vec3(-1658.15, 177.9, 66.6), size = vec3(0.65, 2.5, 1.95), rotation = 295.25 },
        { name = "locker_7", coords = vec3(-1661.3, 176.6, 61.8), size = vec3(2.45, 0.4, 11.55), rotation = 24.5 },
        { name = "locker_8", coords = vec3(-1644.65, 186.0, 66.5), size = vec3(0.45, 2.45, 2.15), rotation = 25.25 },
        { name = "locker_9", coords = vec3(-1642.5, 181.9, 66.0), size = vec3(0.9, 4.4, 3.2), rotation = 25.0 },
        { name = "locker_10", coords = vec3(-1639.75, 175.25, 66.5), size = vec3(0.25, 4.5, 2.25), rotation = 25.0 },
        { name = "locker_11", coords = vec3(-1637.9, 171.0, 66.6), size = vec3(0.15, 2.45, 1.95), rotation = 25.0 },
        { name = "locker_12", coords = vec3(-1646.9, 179.9, 66.6), size = vec3(0.1, 4.4, 1.9), rotation = 25.0 },
        { name = "locker_13", coords = vec3(-1644.0, 173.3, 66.6), size = vec3(0.5, 4.6, 2.0), rotation = 26.0 },
        { name = "locker_14", coords = vec3(-1643.55, 165.0, 66.0), size = vec3(4.0, 3.5, 3.2), rotation = 24.75 },
        { name = "locker_15", coords = vec3(-1645.65, 169.45, 66.65), size = vec3(4.0, 1.1, 1.9), rotation = 25.25 },
        { name = "locker_16", coords = vec3(-1662.7, 172.15, 66.6), size = vec3(0.35, 5.4, 2.0), rotation = 25.0 },
        { name = "locker_17", coords = vec3(-1665.4, 170.95, 66.65), size = vec3(1.1, 5.5, 1.9), rotation = 25.0 },
        { name = "locker_18", coords = vec3(-1662.25, 165.15, 65.0), size = vec3(0.25, 5.45, 5.25), rotation = 25.0 },
        { name = "locker_19", coords = vec3(-1660.0, 166.2, 66.2), size = vec3(0.3, 5.7, 2.75), rotation = 25.5 },
        { name = "locker_20", coords = vec3(-1649.35, 167.3, 66.6), size = vec3(2.45, 0.35, 1.95), rotation = 25.0 },
        { name = "locker_21", coords = vec3(-1652.55, 165.85, 66.5), size = vec3(2.45, 0.4, 2.2), rotation = 25.5 },
        { name = "locker_22", coords = vec3(-1655.95, 165.15, 66.55), size = vec3(2.4, 2, 2.0), rotation = 25.0 },
        { name = "locker_23", coords = vec3(-1651.2, 163.1, 66.6), size = vec3(2.4, 0.4, 2.0), rotation = 25.0 },
        { name = "locker_24", coords = vec3(-1657.9, 160.1, 66.6), size = vec3(3.5, 0.2, 1.9), rotation = 26.0 },
    },
    
    -- Locker Zones (Upper Floor)
    UpperFloor = {
        { name = "locker_upper_1", coords = vec3(-1644.7, 185.96, 70.55), size = vec3(0.3, 2.45, 1.95), rotation = 25.0 },
        { name = "locker_upper_2", coords = vec3(-1642.74, 181.88, 70.6), size = vec3(0.45, 4.6, 1.9), rotation = 25.0 },
        { name = "locker_upper_3", coords = vec3(-1639.64, 175.24, 70.65), size = vec3(0.4, 4.5, 1.85), rotation = 25.0 },
        { name = "locker_upper_4", coords = vec3(-1637.83, 171.07, 70.6), size = vec3(0.3, 2.4, 1.9), rotation = 25.5 },
        { name = "locker_upper_5", coords = vec3(-1643.98, 173.29, 70.6), size = vec3(0.4, 4.4, 1.9), rotation = 25.0 },
        { name = "locker_upper_6", coords = vec3(-1647.03, 179.85, 70.65), size = vec3(0.4, 4.4, 1.8), rotation = 25.0 },
        { name = "locker_upper_7", coords = vec3(-1644.23, 166.41, 70.55), size = vec3(3.9, 0.3, 1.9), rotation = 24.5 },
        { name = "locker_upper_8", coords = vec3(-1645.48, 169.14, 70.6), size = vec3(3.9, 0.4, 1.9), rotation = 25.0 },
        { name = "locker_upper_9", coords = vec3(-1651.26, 163.12, 70.6), size = vec3(2.5, 0.3, 1.9), rotation = 25.0 },
        { name = "locker_upper_10", coords = vec3(-1652.5, 165.78, 70.6), size = vec3(2.4, 0.25, 1.85), rotation = 25.0 },
        { name = "locker_upper_11", coords = vec3(-1657.86, 160.05, 70.6), size = vec3(3.35, 0.3, 1.8), rotation = 25.0 },
        { name = "locker_upper_12", coords = vec3(-1662.23, 165.14, 70.65), size = vec3(0.25, 5.6, 1.75), rotation = 25.25 },
        { name = "locker_upper_13", coords = vec3(-1660.01, 166.18, 70.6), size = vec3(0.2, 5.4, 1.9), rotation = 25.25 },
        { name = "locker_upper_14", coords = vec3(-1662.81, 172.19, 70.6), size = vec3(0.25, 5.5, 1.9), rotation = 25.0 },
        { name = "locker_upper_15", coords = vec3(-1665.04, 171.02, 70.6), size = vec3(0.35, 5.4, 1.85), rotation = 25.0 },
        { name = "locker_upper_16", coords = vec3(-1666.11, 177.68, 70.6), size = vec3(3.35, 0.5, 1.9), rotation = 24.75 },
        { name = "locker_upper_17", coords = vec3(-1661.4, 176.76, 68.5), size = vec3(2.4, 0.1, 6.05), rotation = 25.0 },
        { name = "locker_upper_18", coords = vec3(-1659.4, 180.77, 70.6), size = vec3(2.35, 0.4, 1.9), rotation = 25.0 },
        { name = "locker_upper_19", coords = vec3(-1655.08, 179.53, 70.6), size = vec3(2.5, 0.3, 1.9), rotation = 25.0 },
        { name = "locker_upper_20", coords = vec3(-1652.43, 183.95, 70.65), size = vec3(3.8, 0.35, 1.8), rotation = 25.0 },
        { name = "locker_upper_21", coords = vec3(-1651.16, 181.3, 70.6), size = vec3(3.9, 0.4, 1.85), rotation = 25.0 },
    }
}

-- =========================================
-- 10. CLASSROOM ZONES
-- =========================================
-- Configure classroom entry/exit zones and notifications
-- Use /zone box in-game (with Config.debug = true) to get correct coordinates for your MLO
-- Adjust these coordinates to match your specific MLO (e.g., iPromx school academy)
--
-- NOTE: To change classroom names and messages, edit them directly below!
-- The locale file (locales/en.json) is NOT used for these - edit them here in config.lua
-- Example: Change "Japanese Language Classroom" to "Administration Class" below

Config.ClassroomZones = {
    {
        name = "Italian Language Classroom",
        coords = vec3(-1665.9, 182.95, 62.05),
        size = vec3(9.55, 7.7, 3.6),
        rotation = 24.0,
        enterTitle = "Italian Language Classroom",
        enterDescription = "Benvenuto! You've entered the Italian Language Classroom. 🇮🇹",
        enterType = "success",
        enterIcon = "fa-solid fa-book-open",
        enterDuration = 5000,
        exitDescription = "Arrivederci! You've left the Italian Language Classroom. 📖",
        exitType = "inform",
        exitIcon = "fa-solid fa-door-closed",
        exitDuration = 3000
    },
    {
        name = "Music Classroom",
        coords = vec3(-1653.9, 156.7, 62.0),
        size = vec3(10.3, 7.8, 4.2),
        rotation = 25.0,
        enterTitle = "Music Classroom",
        enterDescription = "Welcome! You've entered the Music Classroom. 🎵",
        enterType = "success",
        enterIcon = "fa-solid fa-music",
        enterDuration = 5000,
        exitDescription = "Goodbye! You've left the Music Classroom. 🎼",
        exitType = "inform",
        exitIcon = "fa-solid fa-door-closed",
        exitDuration = 3000
    },
    {
        name = "Russian Language Classroom",
        coords = vec3(-1644.7, 160.9, 67.15),
        size = vec3(9.6, 7.6, 3.1),
        rotation = 24.5,
        enterTitle = "Russian Language Classroom",
        enterDescription = "Добро пожаловать! You've entered the Russian Language Classroom. 🇷🇺",
        enterType = "success",
        enterIcon = "fa-solid fa-book-open",
        enterDuration = 5000,
        exitDescription = "До свидания! You've left the Russian Language Classroom. 📖",
        exitType = "inform",
        exitIcon = "fa-solid fa-door-closed",
        exitDuration = 3000
    },
    {
        name = "Spanish Language Classroom",
        coords = vec3(-1666.0, 182.8, 67.1),
        size = vec3(9.8, 7.6, 3.15),
        rotation = 25.0,
        enterTitle = "Spanish Language Classroom",
        enterDescription = "¡Bienvenido! You've entered the Spanish Language Classroom. 🇪🇸",
        enterType = "success",
        enterIcon = "fa-solid fa-book-open",
        enterDuration = 5000,
        exitDescription = "¡Adiós! You've left the Spanish Language Classroom. 📖",
        exitType = "inform",
        exitIcon = "fa-solid fa-door-closed",
        exitDuration = 3000
    },
    {
        name = "Japanese Language Classroom",
        coords = vec3(-1653.8, 156.6, 67.2),
        size = vec3(9.45, 7.6, 3.2),
        rotation = 24.75,
        enterTitle = "Japanese Language Classroom",
        enterDescription = "ようこそ! You've entered the Japanese Language Classroom. 🇯🇵",
        enterType = "success",
        enterIcon = "fa-solid fa-book-open",
        enterDuration = 5000,
        exitDescription = "さようなら! You've left the Japanese Language Classroom. 📖",
        exitType = "inform",
        exitIcon = "fa-solid fa-door-closed",
        exitDuration = 3000
    },
    {
        name = "Women's Toilet",
        coords = vec3(-1657.25, 167.8, 71.0),
        size = vec3(3.8, 6.1, 2.6),
        rotation = 25.0,
        enterTitle = "Women's Toilet",
        enterDescription = "You've entered the Women's Toilet. 🚺",
        enterType = "success",
        enterIcon = "fa-solid fa-toilet",
        enterDuration = 5000,
        exitDescription = "You've left the Women's Toilet. 🚪",
        exitType = "inform",
        exitIcon = "fa-solid fa-door-closed",
        exitDuration = 3000
    },
    {
        name = "Chemistry Classroom",
        coords = vec3(-1647.42, 159.71, 71.2),
        size = vec3(15.65, 7.8, 3.15),
        rotation = 26.0,
        enterTitle = "Chemistry Classroom",
        enterDescription = "Welcome! You've entered the Chemistry Classroom. 🧪",
        enterType = "success",
        enterIcon = "fa-solid fa-flask",
        enterDuration = 5000,
        exitDescription = "Goodbye! You've left the Chemistry Classroom. 📖",
        exitType = "inform",
        exitIcon = "fa-solid fa-door-closed",
        exitDuration = 3000
    }
}

-- =========================================
-- 11. SHOP CONFIGURATION
-- =========================================

Config.Shops = {
    -- School Armory (restricted to school staff)
    school_armory = {
        label = "School Armory",
        description = "Equipment and supplies for school staff",
        coords = vec3(-1638.6670, 180.4080, 66.6080),
        size = vec3(4.0, 4.0, 3.0),
        rotation = 295.0,
        distance = 3.0,
        icon = "fa-solid fa-shield-halved",
        interactionText = "Open School Armory",
        requiredJob = "school",
        requiredGrades = {1, 2},
        items = {
            { name = 'printer_paper', price = 1, count = 10 },
            { name = 'bandage', price = 4, count = 10 },
            { name = 'whiteboard2', price = 4, count = 10 }
        },
        enabled = true,
        serverEvent = 'school:openShop'
    },

    -- Chemistry Shop (open to everyone)
    chemistry_shop = {
        label = "Chemistry Shop",
        description = "Chemical supplies and equipment",
        coords = vec3(-1655.7, 158.15, 70.75),
        size = vec3(3.0, 3.0, 3.0),
        rotation = 28.0,
        distance = 3.0,
        icon = "fa-solid fa-flask",
        interactionText = "Open Chemistry Shop",
        requiredJob = nil,
        requiredGrades = {},
        items = {
            { name = 'acetone', price = 20, count = 10 },
            { name = 'acid', price = 23, count = 10 }
        },
        enabled = true,
        serverEvent = 'chemistry:openShop'
    },

    -- Paper Shop (open to everyone)
    paper_shop = {
        label = "Paper Shop",
        description = "Office supplies and paper products",
        coords = vec3(-1651.4, 154.01, 70.7),
        size = vec3(3.0, 3.0, 3.0),
        rotation = 115.5,
        distance = 3.0,
        icon = "fa-solid fa-file-lines",
        interactionText = "Open Paper Shop",
        requiredJob = nil,
        requiredGrades = {},
        items = {
            { name = 'printer_paper', price = 1, count = 10 },
            { name = 'notebook', price = 5, count = 20 },
            { name = 'pen', price = 2, count = 50 }
        },
        enabled = true,
        serverEvent = 'shop:open'
    },

    -- University Backpack Shop (NPC-based)
    university_backpack_shop = {
        label = "University Shop",
        description = "Backpacks and school supplies",
        coords = vec3(-1639.41, 173.08, 61.76),
        items = {
            { name = 'backpack', price = 500, count = 5 }
        },
        enabled = true,
        serverEvent = 'shop:open',
        useNPC = true
    }
}

-- =========================================
-- 12. SHOP VENDOR (PED) CONFIGURATIONS
-- =========================================

Config.ShopPeds = {
    backpack_vendor = {
        coords = vec3(-1639.41, 173.08, 61.76),
        model = `a_m_y_business_02`,
        heading = 102.98,
        animation = "WORLD_HUMAN_STAND_IMPATIENT",
        shopId = 'university_backpack_shop',
        interaction = {
            name = "open_backpack_shop",
            icon = "fa-solid fa-shop",
            label = "Open University Shop",
            distance = 2.5
        }
    }
}

-- =========================================
-- 13. UI SETTINGS
-- =========================================

Config.textuiPos = 'right-center'
Config.sitsGetUpKey = 38 -- E key

-- =========================================
-- 13.1 BOSS MENU MONITOR (/setupbossmenu)
-- =========================================
-- Spawns sf_prop_sf_monitor_b_02b, optional gizmo if `whiteboards` is running,
-- renders DUI on the in-world screen via cr-3dnui (AddReplaceTexture).
-- Permission: ACE `command.setupbossmenu` OR Config.debug when allowIfDebug is true.
Config.BossMenuMonitor = {
    enabled = true,
    command = 'setupbossmenu',
    acePermission = 'command.setupbossmenu',
    -- Some FX/client builds expose no client-side IsPlayerAceAllowed — script skips ACE when true (weak; prefer fixing artifacts).
    allowIfAceNativeMissing = true,
    allowIfDebug = true,
    model = 'sf_prop_sf_monitor_b_02b',
    origTexDict = 'sf_prop_sf_monitor_b_02b',
    origTexName = 'script_rt_monitor_b_02b',
    duiWidth = 1024,
    duiHeight = 512,
    -- cr-3dnui SendReplaceMouseMove flipY: only enable if the panel looks upside-down vs clicks.
    flipMouseY = false,
    flipNormV = false,
    flipMouseX = false,
    invertMouseDeltaY = false,
    -- false = only the DUI page cursor (#dui-cursor, driven by SendReplaceMessage like nl-lockers). true = extra GTA HUD crosshair.
    showHudCursor = false,
    -- false = locker laptop: pump DUI only when the mouse moves. true = every frame (smoother hover / fewer “stuck” pixels).
    sendDuiMouseEveryFrame = true,
    -- SendReplaceMessage { type='cursor', x, y } so the page draws an arrow + synthetic mousemove (matches nl-lockers DUI_MouseMove).
    sendDuiCursorOverlay = true,
    -- SendReplaceMessage { type='click' } on press/release for :active / focus parity with laptop.js
    sendDuiClickOverlay = true,
    hudCursorInvertY = true,
    hudCursorW = 0.022,
    hudCursorH = 0.038,
    hudCursorTipX = 0.0,
    hudCursorTipY = 0.0,
    -- rect = always-visible HUD blocks (recommended); sprite = cr-3dnui asset; auto = sprite when loaded else rect.
    hudCursorStyle = 'rect',
    hudFallbackW = 0.014,
    hudFallbackH = 0.024,
    hudFallbackDot = 0.0045,
    -- Like nl-lockers laptop: networked prop improves ox_target entity targeting.
    networked = true,
    interactDistance = 2.5,
    targetIcon = 'fas fa-desktop',
    targetLabel = 'Use boss computer',
    -- Scripted camera on prop (same pattern as locker laptop attachCam / PointCamAtEntity).
    camera = {
        attachX = -0.02,
        -- More negative Y = further back from the screen.
        attachY = -1.05,
        attachZ = 0.78,
        pointX = 0.0,
        pointY = 0.06,
        pointZ = 0.32,
        fov = 38.0,
    },
    -- Full 0..1 = entire DUI reachable. Tight margins (e.g. 0.02..0.98) clip edge pixels.
    screenBounds = { L = 0.0, R = 1.0, T = 0.0, B = 1.0 },
    -- true = map cursor via scripted-cam ray → plane on the prop (best aim); false = legacy normalized drift only.
    useCameraRayMapping = true,
    -- Ray hits a rectangle on the monitor (meters). Tune localOffset / half sizes if clicks misalign vs texture.
    screenRay = {
        localOffset = { x = 0.0, y = 0.0, z = 0.12 },
        halfWidth = 0.16,
        halfHeight = 0.09,
        edgeMargin = 1.12,
        flipU = false,
        flipV = false,
    },
    -- While Left Shift (sprint) is held, mouse deltas scale by this (lower = finer).
    mousePrecisionHoldMultiplier = 0.22,
    -- Frontend arrow keys: nudge virtual cursor by this many DUI pixels per frame (disabled during session).
    mouseArrowNudgePx = 4,
    -- Lower = finer aim (high-DPI mice feel “fast” — start ~3.0–4.0, then tune).
    mouseSensitivity = 3.25,
    -- Omit to match mouseSensitivity.
    -- mouseSensitivityY = 3.0,
    -- Jitter filter (raise if micro-shake; lower if you can’t creep to the last pixel near edges).
    mouseDeadZone = 0.0025,
    -- Clamp |GetDisabledControlNormal| per axis per frame (reduces sudden jumps). nil/0 = off.
    mouseMaxInputAbs = 0.028,
    -- 1.0 = linear. ~1.08–1.12 damps tiny twitches (pairs with mouseDeadZone).
    mouseCurveExponent = 1.1,
    -- 1.0 = raw deltas like nl-lockers. Lower only if you want floaty smoothing.
    mouseDeltaSmoothing = 1.0,
}

-- =========================================
-- 14. NOTIFICATION MESSAGES
-- =========================================

Strings = {
    action_incomplete = 'Action Incomplete',
    one_backpack_only = 'You can only have 1x backpack!',
    backpack_in_backpack = 'You can\'t place a backpack within another!'
}

-- =========================================
-- BACKWARD COMPATIBILITY
-- =========================================

StudentLockerConfig = {
    LockerZones = {},
    Settings = {
        RequiredJob = Config.StudentLockers.RequiredJob,
        InteractionDistance = Config.StudentLockers.InteractionDistance,
        Debug = Config.debug,
        InteractionLabel = Config.StudentLockers.InteractionLabel,
        InteractionIcon = Config.StudentLockers.InteractionIcon
    }
}

-- Merge ground floor and upper floor lockers
for _, locker in ipairs(Config.StudentLockers.GroundFloor) do
    locker.targetId = nil
    table.insert(StudentLockerConfig.LockerZones, locker)
end

for _, locker in ipairs(Config.StudentLockers.UpperFloor) do
    locker.targetId = nil
    table.insert(StudentLockerConfig.LockerZones, locker)
end
