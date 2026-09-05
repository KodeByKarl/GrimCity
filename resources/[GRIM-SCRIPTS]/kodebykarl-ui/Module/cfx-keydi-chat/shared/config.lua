ConfigChat = {
    fadeTimeout = 10000, -- hide message overlay 10s after last show/message/open
    suggestionLimit = 4,
    cooldownSeconds = 2,

    -- Personal OOC text chat is disabled. Only /commands are accepted (e.g. /wl, /gang, /me).
    allowPersonalChat = false,
    personalChatBlockedMessage = '[SYSTEM] Personal chat is disabled. Use commands only (example: /wl message).',

    -- Hide staff-only clutter from chat autocomplete (e.g. /Gv give-item).
    hiddenSuggestions = { '/gv', '/Gv', '/gc' },

    -- Shown in chat like job /wl — gangs use /gang only (Freestyle).
    commandSuggestions = {
        { name = '/wl', help = 'Job announcement (no message opens Auto Templates)', params = {{ name = 'message', help = 'Your announcement (optional)' }} },
        { name = '/ems', help = 'EMS announcement (no message opens EMS Templates)', params = {{ name = 'message', help = 'Your announcement (optional)' }} },
        { name = '/pd', help = 'Police announcement (no message opens PD Templates)', params = {{ name = 'message', help = 'Your announcement (optional)' }} },
        { name = '/police', help = 'Police announcement (no message opens Police Templates)', params = {{ name = 'message', help = 'Your announcement (optional)' }} },
        { name = '/mech', help = 'Mechanic announcement (no message opens Mechanic Templates)', params = {{ name = 'message', help = 'Your announcement (optional)' }} },
        { name = '/jobtp', help = 'Open job announcement templates menu' },
        { name = '/gang', help = 'Gang announcement (Freestyle)', params = {{ name = 'message', help = 'Your announcement (optional)' }} },
    },

    -- Auto Templates: /wl, /ems, /pd, /mech with no message opens a categorized picker for jobs listed below.
    -- Free-text /wl [message] still works for all authorized jobs.
    jobAutoTemplates = {
        enabled = true,
        jobs = {
            --- ========================================
            --- EMS / AMBULANCE TEMPLATES
            --- ========================================
            ["ambulance"] = {
                -- General Templates
                {
                    id = "ems_available",
                    category = "General Templates",
                    title = "EMS Available",
                    description = "EMS ready and available to serve",
                    icon = "circle-check",
                    message = "Pandora City EMS is now ready and available to serve you. Thank you!",
                },
                {
                    id = "ems_only_one",
                    category = "General Templates",
                    title = "Only 1 EMS Available",
                    description = "Advised to bring patient to hospital",
                    icon = "user-doctor",
                    message = "There is only 1 EMS available at the moment. It is highly advised that you BRING THE PATIENT TO THE HOSPITAL. Please be patient for any distress calls. Thank you.",
                },
                {
                    id = "ems_none_available",
                    category = "General Templates",
                    title = "No EMS Available",
                    description = "Please value your life",
                    icon = "circle-xmark",
                    message = "ATTENTION: Please be advised that there is NO EMS available at the moment. PLEASE VALUE YOUR LIFE. Thank you.",
                },
                {
                    id = "ems_police_assistance",
                    category = "General Templates",
                    title = "Police Assistance",
                    description = "Requesting police assistance at hospital",
                    icon = "shield-halved",
                    message = "Pandora City EMS is requesting POLICE ASSISTANCE at the hospital. Thank you.",
                },
                {
                    id = "ems_impound",
                    category = "General Templates",
                    title = "Impound Notice",
                    description = "Non-EMS parked vehicles subject to impound",
                    icon = "truck-pickup",
                    message = "All NON-EMS vehicles parked in front of or beside the hospital are subject to IMPOUND. Our designated EMS parking area is located on the other side of the bridge. Thank you!",
                },
                {
                    id = "ems_blocking_driveway",
                    category = "General Templates",
                    title = "Blocking Emergency Driveway",
                    description = "Do not block emergency driveway",
                    icon = "triangle-exclamation",
                    message = "PLEASE DON'T BLOCK THE HOSPITAL EMERGENCY DRIVEWAY. Our designated parking area is located on the other side of the bridge. Thank you!",
                },
                {
                    id = "ems_meeting",
                    category = "General Templates",
                    title = "Meeting Template",
                    description = "Distress calls paused for short meeting",
                    icon = "users",
                    message = "Pandora City EMS will be having a short meeting. All DISTRESS CALLS AND ROBBERY RESPONSES will not be attended to for the meantime. We appreciate your understanding. THANK YOU!",
                },
                {
                    id = "ems_returning",
                    category = "General Templates",
                    title = "Returning to Hospital",
                    description = "EMS heading back to hospital",
                    icon = "hospital",
                    message = "Pandora City EMS is heading back to the hospital. Thank you!",
                },
                {
                    id = "ems_mass_hiring",
                    category = "General Templates",
                    title = "Mass Hiring",
                    description = "Now accepting new applicants",
                    icon = "clipboard-user",
                    message = "MASS HIRING!!! Pandora City EMS is NOW ACCEPTING NEW APPLICANTS. For those who are interested, kindly inform any EMS staff member so they can notify the Hospital Directors for an interview. THANK YOU!",
                },
                {
                    id = "ems_radio",
                    category = "General Templates",
                    title = "Join Radio Frequency",
                    description = "Connect to designated radio frequency",
                    icon = "walkie-talkie",
                    message = "TO ALL ON-DUTY EMS: Please connect to our designated radio frequency. THANK YOU!",
                },

                -- Distress & Hostage
                {
                    id = "ems_distress_received",
                    category = "Distress & Hostage",
                    title = "Distress Received",
                    description = "EMS is on the way to distress call",
                    icon = "truck-medical",
                    fields = { needsPostal = true },
                    message = "DISTRESS RECEIVED, Pandora City EMS is on the way. Please be patient and wait for the medical personnel to arrive. Thank you. [POSTAL#]",
                },
                {
                    id = "ems_multiple_distress",
                    category = "Distress & Hostage",
                    title = "Multiple Distress Calls",
                    description = "Queue delay announcement",
                    icon = "bell",
                    message = "Please be advised that MULTIPLE DISTRESS CALLS are currently in queue. There may be a delay in our response. Please be patient and wait for the medical personnel to arrive. Thank you.",
                },
                {
                    id = "ems_missing_patient",
                    category = "Distress & Hostage",
                    title = "Missing Patient",
                    description = "Looking for a missing patient",
                    icon = "magnifying-glass",
                    fields = { needsPostal = true },
                    message = "Pandora City EMS is looking for a MISSING PATIENT. Please bring the patient to the hospital once found. Thank you! [POSTAL#]",
                },
                {
                    id = "ems_high_terrain",
                    category = "Distress & Hostage",
                    title = "High-Terrain Distress",
                    description = "Cannot respond in high-terrain areas",
                    icon = "mountain",
                    fields = { needsPostal = true },
                    message = "Pandora City EMS CANNOT RESPOND to distress calls located in high-terrain areas. Please bring the patient to the hospital. Thank you! [POSTAL#]",
                },
                {
                    id = "ems_redzone_restriction",
                    category = "Distress & Hostage",
                    title = "Red Zone Restriction",
                    description = "Not allowed to enter red zone areas",
                    icon = "ban",
                    fields = { needsPostal = true },
                    message = "Pandora City EMS is NOT ALLOWED to enter RED ZONE areas. Please bring the patient to the hospital. Thank you! [POSTAL#]",
                },
                {
                    id = "ems_redzone_distress",
                    category = "Distress & Hostage",
                    title = "Red Zone Distress",
                    description = "Not allowed to respond inside red zone",
                    icon = "circle-exclamation",
                    fields = { needsPostal = true },
                    message = "Pandora City EMS is NOT ALLOWED to respond to distress calls made inside RED ZONE [POSTAL#]. Please bring the patient to Pandora General Hospital. Thank you!",
                },
                {
                    id = "ems_hostage_standby",
                    category = "Distress & Hostage",
                    title = "Hostage Standby",
                    description = "Standby and ready to pick up hostage",
                    icon = "handcuffs",
                    message = "Pandora City EMS is ON STANDBY AND READY to pick up the hostage.",
                },
                {
                    id = "ems_hostage_secured",
                    category = "Distress & Hostage",
                    title = "Hostage Secured",
                    description = "Hostage secured, heading back",
                    icon = "lock",
                    message = "HOSTAGE SECURED, Pandora City EMS is heading back to the hospital. Thank you!",
                },

                -- Small Heist
                {
                    id = "ems_heist_small_store",
                    category = "Small Heist",
                    title = "Small Store Robbery",
                    description = "Standby at Small Store Robbery",
                    icon = "store",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT SMALL STORE ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_liquor_store",
                    category = "Small Heist",
                    title = "Liquor Store Robbery",
                    description = "Standby at Liquor Store Robbery",
                    icon = "wine-bottle",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT LIQUOR STORE ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_ammunation",
                    category = "Small Heist",
                    title = "Ammu-Nation Robbery",
                    description = "Standby at Ammu-Nation Robbery",
                    icon = "gun",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT AMMU-NATION ROBBERY [POSTAL#]!",
                },

                -- Medium Heist
                {
                    id = "ems_heist_fleeca",
                    category = "Medium Heist",
                    title = "Fleeca Bank Robbery",
                    description = "Standby at Fleeca Bank Robbery",
                    icon = "building-columns",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT FLEECA BANK ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_yellow_jack",
                    category = "Medium Heist",
                    title = "Yellow Jack Robbery",
                    description = "Standby at Yellow Jack Robbery",
                    icon = "beer-mug-empty",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT YELLOW JACK ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_cluckin_bell",
                    category = "Medium Heist",
                    title = "Cluckin' Bell Robbery",
                    description = "Standby at Cluckin' Bell Robbery",
                    icon = "drumstick-bite",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT CLUCKIN' BELL ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_jewelry",
                    category = "Medium Heist",
                    title = "Jewelry Store Robbery",
                    description = "Standby at Jewelry Store Robbery",
                    icon = "gem",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT JEWELRY STORE ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_life_invader",
                    category = "Medium Heist",
                    title = "Life Invader Robbery",
                    description = "Standby at Life Invader Robbery",
                    icon = "desktop",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT LIFE INVADER ROBBERY [POSTAL#]!",
                },

                -- Big Heist
                {
                    id = "ems_heist_principal_bank",
                    category = "Big Heist",
                    title = "Principal Bank Robbery",
                    description = "Standby at Principal Bank Robbery",
                    icon = "vault",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT PRINCIPAL BANK ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_humane_labs",
                    category = "Big Heist",
                    title = "Humane Labs Robbery",
                    description = "Standby at Humane Labs Robbery",
                    icon = "flask",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY AT HUMANE LABS ROBBERY [POSTAL#]!",
                },
                {
                    id = "ems_heist_yacht",
                    category = "Big Heist",
                    title = "Yacht Robbery",
                    description = "Standby near Yacht Robbery",
                    icon = "ship",
                    fields = { needsPostal = true },
                    message = "Pandora City Medical Department IS NOW PROCEEDING AND WILL BE ON STANDBY NEAR YACHT ROBBERY [POSTAL#]!",
                },
            },

            --- ========================================
            --- POLICE / SHERIFF TEMPLATES
            --- ========================================
            ["police"] = {
                -- General & Status
                {
                    id = "pd_available",
                    category = "General & Status",
                    title = "PD 10-8 Available",
                    description = "Police units available to serve and protect",
                    icon = "shield",
                    message = "Pandora City Police Department is 10-8 and now available to serve and protect. In case of emergency, dial 911. Thank you!",
                },
                {
                    id = "pd_low_units",
                    category = "General & Status",
                    title = "Low Units Available",
                    description = "Limited units - priority calls only",
                    icon = "circle-half-stroke",
                    message = "Pandora City Police Department has limited units on duty. Priority calls and emergency situations will be attended first. Thank you!",
                },
                {
                    id = "pd_unavailable",
                    category = "General & Status",
                    title = "PD 10-7 Minimal",
                    description = "Minimal units on duty - value your life",
                    icon = "shield-halved",
                    message = "ATTENTION: Police Department currently has minimal units. Please value your life and stay safe.",
                },
                {
                    id = "pd_mass_hiring",
                    category = "General & Status",
                    title = "PD Mass Hiring",
                    description = "Now accepting police applicants",
                    icon = "clipboard-user",
                    message = "MASS HIRING: Pandora City Police Department is NOW ACCEPTING APPLICANTS. Proceed to MRPD for interview and requirements.",
                },
                {
                    id = "pd_radio",
                    category = "General & Status",
                    title = "Join Police Radio",
                    description = "On-duty LEO connect to radio frequency",
                    icon = "walkie-talkie",
                    message = "TO ALL ON-DUTY LEO: Please connect to our designated police radio frequency. THANK YOU!",
                },
                {
                    id = "pd_meeting",
                    category = "General & Status",
                    title = "Briefing Meeting",
                    description = "Department meeting in progress",
                    icon = "users",
                    message = "Pandora City Police Department will be having a brief meeting. Non-emergency calls may be delayed. Thank you!",
                },

                -- Alerts & Enforcement
                {
                    id = "pd_active_pursuit",
                    category = "Alerts & Enforcement",
                    title = "Active Pursuit (10-80)",
                    description = "High-speed pursuit in progress",
                    icon = "car-burst",
                    fields = { needsPostal = true },
                    message = "High-speed pursuit in progress near [POSTAL#]. Civilians please pull over and yield to emergency vehicles!",
                },
                {
                    id = "pd_code5",
                    category = "Alerts & Enforcement",
                    title = "Code 5 Area Clear",
                    description = "Civilians clear area immediately",
                    icon = "triangle-exclamation",
                    fields = { needsPostal = true },
                    message = "Code 5 in effect. Clear the area immediately. Anyone refusing to leave will be detained and arrested. [POSTAL#]",
                },
                {
                    id = "pd_lockdown",
                    category = "Alerts & Enforcement",
                    title = "Lockdown / Perimeter",
                    description = "Perimeter established - restricted area",
                    icon = "road-barrier",
                    fields = { needsPostal = true },
                    message = "Pandora City Police Department has established a lockdown and perimeter around [POSTAL#]. Do not enter the restricted area.",
                },
                {
                    id = "pd_checkpoint",
                    category = "Alerts & Enforcement",
                    title = "Traffic Checkpoint",
                    description = "DUI / Driver check in progress",
                    icon = "id-card",
                    fields = { needsPostal = true },
                    message = "Pandora City Police Department is conducting a DUI / Traffic Checkpoint at [POSTAL#]. Please slow down and prepare ID/driver's license.",
                },
                {
                    id = "pd_apb",
                    category = "Alerts & Enforcement",
                    title = "APB / BOLO Alert",
                    description = "Broadcast wanted/APB description",
                    icon = "bullhorn",
                    fields = { needsReason = true },
                    message = "ALL UNITS & CITIZENS: An APB has been issued for [REASON]. Contact 911 if sighted.",
                },

                -- 10-90 Active Heists
                {
                    id = "pd_1090_small",
                    category = "10-90 Active",
                    title = "Small Heist (10-90)",
                    description = "Active small/liquor store - redzone",
                    icon = "store",
                    fields = { needsPostal = true },
                    message = "ATTENTION CITIZEN, THERE IS AN ACTIVE 10-90 AT [POSTAL#] - SMALL/LIQUOR STORE. THE AREA IS NOW REDZONE. PROHIBITING CITIZENS NEAR THE PREMISES UNTIL FURTHER NOTICE. WE ARE REQUESTING EMS AND MECH! PLEASE BE ON STAND-BY AND WAIT FOR CODE 4. THANK YOU!",
                },
                {
                    id = "pd_1090_big",
                    category = "10-90 Active",
                    title = "Big Heist (10-90)",
                    description = "Active big heist - enter type + postal",
                    icon = "building-columns",
                    fields = { needsPostal = true, needsReason = true },
                    message = "ATTENTION CITIZEN, THERE IS AN ACTIVE 10-90 AT [POSTAL#] - [REASON]. THE AREA IS NOW REDZONE. PROHIBITING CITIZENS NEAR THE PREMISES UNTIL FURTHER NOTICE. WE ARE REQUESTING EMS AND MECH! PLEASE BE ON STAND-BY AND WAIT FOR CODE 4. THANK YOU!",
                },

                -- Code Status
                {
                    id = "pd_code6",
                    category = "Code Status",
                    title = "Code 6 Investigating",
                    description = "PCPD investigating - stay out of area",
                    icon = "magnifying-glass",
                    message = "CODE 6: PCPD IS NOW INVESTIGATING THE AREA. PLEASE REFRAIN FROM ENTERING THE SAID AREA UNTIL FURTHER ANNOUNCEMENT!",
                },
                {
                    id = "pd_code4_officers_down",
                    category = "Code Status",
                    title = "Code 4 - Officers Down",
                    description = "All officers down - EMS proceed with caution",
                    icon = "heart-pulse",
                    message = "CODE 4: ALL OFFICERS DOWN! EMS PLEASE PROCEED TO PROVIDE MEDICAL ASSISTANCE AND USE CAUTION. CITIZEN/S CAN ENTER THE PREMISES ONCE THE EMS ANNOUNCES THE AREA IS CLEAR. THANK YOU!",
                },
                {
                    id = "pd_code4_robbers_down",
                    category = "Code Status",
                    title = "Code 4 - Robbers Down",
                    description = "All robbers down at small/liquor store",
                    icon = "user-injured",
                    fields = { needsPostal = true },
                    message = "CODE 4: ALL ROBBERS DOWN! AT [POSTAL#] SMALL/LIQUOR STORE. EMS PLEASE PROCEED TO PROVIDE MEDICAL ASSISTANCE AND USE CAUTION. CITIZEN/S CAN ENTER THE PREMISES ONCE THE EMS ANNOUNCES THE AREA IS CLEAR. THANK YOU!",
                },

                -- Police Intercepts
                {
                    id = "pd_intercept_traphouse",
                    category = "Police Intercept",
                    title = "Intercept Traphouse",
                    description = "PCPD intercepting latest traphouse",
                    icon = "house",
                    message = "PCPD IS NOW INTERCEPTING THE LATEST (TRAPHOUSE). ALL CIVILIANS PLEASE STAY AWAY FROM THE AREA!",
                },
                {
                    id = "pd_intercept_turfwar",
                    category = "Police Intercept",
                    title = "Intercept Turf War",
                    description = "PCPD intercepting latest turf war",
                    icon = "crosshairs",
                    message = "PCPD IS NOW INTERCEPTING THE LATEST (TURF WAR). ALL CIVILIANS PLEASE STAY AWAY FROM THE AREA!",
                },

                -- Robbery Responses (legacy)
                {
                    id = "pd_store_response",
                    category = "Robbery Responses",
                    title = "Store Robbery Response",
                    description = "Responding to store robbery",
                    icon = "store",
                    fields = { needsPostal = true },
                    message = "Pandora City Police Department is responding to an ongoing Store Robbery at [POSTAL#]. Stay clear of the vicinity!",
                },
                {
                    id = "pd_bank_response",
                    category = "Robbery Responses",
                    title = "Bank Robbery Response",
                    description = "Responding to bank robbery",
                    icon = "building-columns",
                    fields = { needsPostal = true },
                    message = "Pandora City Police Department is responding to an ongoing Bank Robbery at [POSTAL#]. Stay clear of the vicinity!",
                },
                {
                    id = "pd_negotiations",
                    category = "Robbery Responses",
                    title = "Hostage Negotiations",
                    description = "Initiating hostage negotiations",
                    icon = "handcuffs",
                    fields = { needsPostal = true },
                    message = "Pandora City Police Department is initiating hostage negotiations at [POSTAL#].",
                },
                {
                    id = "pd_scene_secured",
                    category = "Robbery Responses",
                    title = "Scene Secured",
                    description = "Incident resolved and area secure",
                    icon = "circle-check",
                    fields = { needsPostal = true },
                    message = "The situation at [POSTAL#] has been resolved and the area is now declared SECURE.",
                },
            },

            --- ========================================
            --- MECHANIC TEMPLATES
            --- ========================================
            ["mechanic"] = {
                -- Shop Status
                {
                    id = "mech_open",
                    category = "Shop Status",
                    title = "Shop Open",
                    description = "Mechanic shop is open at postal 7231",
                    icon = "store",
                    message = "PANDORA CITY MECHANIC SHOP IS NOW OPEN AND READY TO PERSONALIZE YOUR FAVORITE VEHICLES! COME VISIT US AT POSTAL 7231. THANK YOU AND ENJOY YOUR DAY!",
                },
                {
                    id = "mech_closed",
                    category = "Shop Status",
                    title = "Shop Closed",
                    description = "Mechanic shop is closed",
                    icon = "store-slash",
                    message = "PANDORA CITY MECHANIC SHOP IS NOW CLOSED. THANK YOU AND DRIVE SAFE!",
                },
                {
                    id = "mech_only_one",
                    category = "Shop Status",
                    title = "1 Mechanic Available",
                    description = "Limited mechanics on duty",
                    icon = "user-gear",
                    message = "There is currently only 1 Mechanic available on duty. Please wait patiently in line. Thank you for understanding!",
                },
                {
                    id = "mech_break",
                    category = "Shop Status",
                    title = "Shop on Break",
                    description = "Shop taking a short break",
                    icon = "mug-hot",
                    message = "PANDORA CITY MECHANIC SHOP IS TAKING A SHORT BREAK. PLEASE COME BACK LATER, THANK YOU AND DRIVE SAFE!",
                },
                {
                    id = "mech_mass_hiring",
                    category = "Shop Status",
                    title = "Mass Hiring",
                    description = "Ride Out Customs is hiring",
                    icon = "clipboard-user",
                    message = "MASS HIRING: Ride Out Customs / Mechanic Shop is NOW ACCEPTING APPLICANTS! Visit the shop to apply.",
                },
                {
                    id = "mech_radio",
                    category = "Shop Status",
                    title = "Join Radio Frequency",
                    description = "On-duty mechanics connect to radio",
                    icon = "walkie-talkie",
                    message = "ALL ON-DUTY PANDORA CITY MECHANICS, PLEASE CONNECT TO OUR RADIO FREQUENCY.",
                },

                -- Roadside & Towing
                {
                    id = "mech_roam",
                    category = "Roadside & Towing",
                    title = "Roaming & Impound Warning",
                    description = "Mechanics roaming streets for impound",
                    icon = "truck-pickup",
                    message = "PLEASE BE AWARE THAT ALL VEHICLES PARKED ILLEGALLY ARE SUBJECT TO IMPOUND. MECHANICS ARE NOW ROAMING THE CITY!",
                },
                {
                    id = "mech_roadside",
                    category = "Roadside & Towing",
                    title = "Roadside Assistance",
                    description = "Mechanic en route for assistance",
                    icon = "wrench",
                    fields = { needsPostal = true },
                    message = "Mechanic is en route for roadside assistance / repair at [POSTAL#]. Please stay with your vehicle.",
                },
                {
                    id = "mech_tow_dispatched",
                    category = "Roadside & Towing",
                    title = "Tow Truck Dispatched",
                    description = "Tow truck on the way",
                    icon = "truck-front",
                    fields = { needsPostal = true },
                    message = "Mechanic flatbed / tow truck dispatched to [POSTAL#].",
                },
                {
                    id = "mech_robbery",
                    category = "Roadside & Towing",
                    title = "Responding to 10-90",
                    description = "Responding to robbery scene",
                    icon = "handcuffs",
                    message = "PANDORA CITY MECHANIC IS RESPONDING TO THE LATEST 10-90.",
                },

                -- Promos & Packages
                {
                    id = "mech_promo",
                    category = "Promos & Packages",
                    title = "Vehicle Tuning Promo",
                    description = "Discounts on mods and upgrades",
                    icon = "tags",
                    message = "SPECIAL PROMO: Enjoy discounts on performance tuning and custom modifications today at the shop!",
                },
                {
                    id = "mech_diagnostics",
                    category = "Promos & Packages",
                    title = "Free Diagnostics",
                    description = "Free vehicle inspection and engine check",
                    icon = "screwdriver-wrench",
                    message = "FREE VEHICLE DIAGNOSTICS: Bring your vehicle in today for a free inspection and engine check!",
                },
            },
        },
    },
    
    -- color = message text, headerColor = FEED line / time. Use #111111 on white gif banners.
    -- PD / EMS / Mechanic / Food businesses → /wl [message]
    jobTemplate = {
        enabled = true,
        command = "wl",
        jobs = {
            --- PD
            ["police"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/Finalpolicetemplate.png",
                background = nil,
                color = "#ffffffff",
                headerColor = "#ecececff",
            },
            ["sheriff"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/FinalSherifftemplate.png",
                background = nil,
                color = "#111111",
                headerColor = "#ffffffff",
            },
            --- EMS
            ["ambulance"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/FinalHP1.png",
                background = nil,
                color = "#ffffffff",
                headerColor = "#ffffffff",
            },
            ["sambulance"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/FinalHP2.png",
                background = nil,
                color = "#111111",
                headerColor = "#ffffffff",
            },
            --- Mechanic (Benny's / framework job name)
            ["mechanic"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/FinalRideOut.png",
                background = nil,
                color = "#ffffffff",
                headerColor = "#ffffffff",
            },
            --- Businesses (same /wl command)
            ["uwu"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/4c008699-3d0b-470a-bd1a-7e1a7d3a921b.png",
                background = nil,
                color = "#ffffffff",
                headerColor = "#ffffffff",
            },
            ["tacoshop"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/FinalTaco.png",
                background = nil,
                color = "#111111",
                headerColor = "#ffffffff",
            },
            ["burgershot"] = {
                gif = "https://r2.fivemanage.com/7qoUgFxV85h3Czm85xGbV/New_Project_5_1.png",
                background = nil,
                color = "#ffffffff",
                headerColor = "#ffffff",
            },
            ["8ball"] = {
                gif = "nui://cfx-keydi-ui/web/dist/assets/eightball_banner.png",
                background = "linear-gradient(135deg, #0d081b 0%, #1f0f35 50%, #0d081b 100%)",
                color = "#ffffffff",
                headerColor = "#e0aaff",
            },
            --- Tattoo shops (if used)
            ["tattooshop1"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/tattooshop1.png",
                background = nil,
                color = "#111111",
                headerColor = "#ffffffff",
            },
            ["tattooshop2"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/tattooshop2.png",
                background = nil,
                color = "#111111",
                headerColor = "#ffffffff",
            },
            ["tattooshop3"] = {
                gif = "https://r2.fivemanage.com/xT3CmlRwCyHdA15m3tfWg/templates/tattooshopsilenzio.png",
                background = nil,
                color = "#111111",
                headerColor = "#ffffffff",
            },
            ["vu"] = {
                gif = "https://r2.fivemanage.com/jWHtKTIB2qDgmUWvaXcm9/ad4eae03-53b4-4689-adec-b9ea50f7b7c9.png",
                background = nil,
                color = "#ffffffff",
                headerColor = "#ffffffff",
            },
        }
    },
    
    gangTemplate = {
        enabled = true,
        -- Slash command is registered by kodebykarl-gangsystem as /gang only. Do not set this to gc/gang.
        command = false,
        -- Any assigned ESX gang can /gang (Freestyle).
        -- Custom gif/colors below override this free default.
        allowAnyGang = true,
        default = {
            gif = nil,
            background = "#111111",
            color = "#ffffff",
            headerColor = "#cfcfcf",
        },
        -- Optional custom banners. Keys MUST match es_extended gang names.
        -- /gang uses assigned gang only — job is ignored.
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
