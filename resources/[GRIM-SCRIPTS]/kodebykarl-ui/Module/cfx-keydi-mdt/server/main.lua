local ESX = exports["es_extended"]:getSharedObject()

-- In-memory cache for active duty officers and dispatch calls
local ActiveOfficers = {}
local ActiveDispatchCalls = {}
local NextDispatchId = 1001

-- =========================================================================
-- DATABASE INITIALIZATION
-- =========================================================================

local function InitDatabase()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mdt_incidents` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `title` VARCHAR(255) NOT NULL,
            `description` LONGTEXT NOT NULL,
            `location` VARCHAR(255) DEFAULT 'Unknown',
            `reporting_officer` VARCHAR(100) NOT NULL,
            `reporting_officer_identifier` VARCHAR(64) NOT NULL,
            `suspects` LONGTEXT DEFAULT '[]',
            `officers` LONGTEXT DEFAULT '[]',
            `charges` LONGTEXT DEFAULT '[]',
            `evidence` LONGTEXT DEFAULT '[]',
            `status` VARCHAR(50) DEFAULT 'Closed',
            `total_fine` INT DEFAULT 0,
            `total_jail` INT DEFAULT 0,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mdt_warrants` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `suspect_identifier` VARCHAR(64) NOT NULL,
            `suspect_name` VARCHAR(100) NOT NULL,
            `charges` LONGTEXT DEFAULT '[]',
            `reason` LONGTEXT NOT NULL,
            `issuing_officer` VARCHAR(100) NOT NULL,
            `issuing_officer_identifier` VARCHAR(64) NOT NULL,
            `status` VARCHAR(50) DEFAULT 'Active',
            `expire_date` VARCHAR(50) DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mdt_bolos` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `type` VARCHAR(50) NOT NULL DEFAULT 'person',
            `title` VARCHAR(255) NOT NULL,
            `target` VARCHAR(255) NOT NULL,
            `description` LONGTEXT NOT NULL,
            `priority` VARCHAR(20) DEFAULT 'medium',
            `image_url` VARCHAR(500) DEFAULT '',
            `author_name` VARCHAR(100) NOT NULL,
            `author_identifier` VARCHAR(64) NOT NULL,
            `status` VARCHAR(20) DEFAULT 'active',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mdt_officers` (
            `identifier` VARCHAR(64) PRIMARY KEY,
            `name` VARCHAR(100) DEFAULT '',
            `callsign` VARCHAR(50) DEFAULT '1-A-01',
            `department` VARCHAR(50) DEFAULT 'LSPD',
            `badge_number` VARCHAR(50) DEFAULT '001',
            `custom_notes` LONGTEXT DEFAULT '',
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mdt_citizen_notes` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `identifier` VARCHAR(64) NOT NULL,
            `note` LONGTEXT NOT NULL,
            `author_name` VARCHAR(100) NOT NULL,
            `author_identifier` VARCHAR(64) NOT NULL,
            `image_url` VARCHAR(500) DEFAULT '',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mdt_vehicle_flags` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `plate` VARCHAR(20) NOT NULL,
            `flag_type` VARCHAR(100) NOT NULL,
            `reason` LONGTEXT NOT NULL,
            `author_name` VARCHAR(100) NOT NULL,
            `author_identifier` VARCHAR(64) NOT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mdt_penal_codes` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `code` VARCHAR(50) NOT NULL UNIQUE,
            `title` VARCHAR(255) NOT NULL,
            `category` VARCHAR(100) NOT NULL,
            `class` VARCHAR(50) NOT NULL,
            `fine` INT DEFAULT 0,
            `jail_time` INT DEFAULT 0,
            `points` INT DEFAULT 0,
            `description` LONGTEXT DEFAULT ''
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Seed penal codes if table is empty
    MySQL.single('SELECT COUNT(*) as count FROM `mdt_penal_codes`', {}, function(res)
        if res and res.count == 0 then
            local seed = {
                { '10-101', 'Speeding (1-15 mph over)', 'Traffic', 'Infraction', 250, 0, 1, 'Operating a vehicle over the speed limit by 1-15 mph.' },
                { '10-102', 'Speeding (16-30 mph over)', 'Traffic', 'Infraction', 500, 0, 2, 'Operating a vehicle over the speed limit by 16-30 mph.' },
                { '10-103', 'Reckless Driving', 'Traffic', 'Misdemeanor', 1500, 10, 3, 'Driving with willful disregard for safety of persons or property.' },
                { '10-104', 'Driving Without a Valid License', 'Traffic', 'Infraction', 750, 0, 1, 'Operating a motor vehicle without a valid driver license on person.' },
                { '10-105', 'Evading Police in Vehicle / Hit & Run', 'Traffic', 'Felony', 5000, 25, 5, 'Fleeing the scene of an accident or evading law enforcement.' },
                { '20-201', 'Trespassing on Private Property', 'Public Order', 'Misdemeanor', 1000, 5, 0, 'Entering or remaining on property without owner consent.' },
                { '20-202', 'Disorderly Conduct', 'Public Order', 'Misdemeanor', 800, 5, 0, 'Engaging in violent, tumultuous, or threatening behavior in public.' },
                { '20-203', 'Resisting a Peace Officer', 'Obstruction', 'Misdemeanor', 2000, 15, 0, 'Intentionally fleeing, obstructing, or physically resisting an officer.' },
                { '20-204', 'Possession of Controlled Narcotics', 'Drug Offenses', 'Misdemeanor', 2500, 15, 0, 'Possession of illicit controlled substances in personal quantities.' },
                { '20-205', 'Drug Trafficking & Distribution', 'Drug Offenses', 'Felony', 10000, 45, 0, 'Manufacturing, transporting, or distributing narcotics in large quantities.' },
                { '30-301', 'Petty Theft', 'Property Crimes', 'Misdemeanor', 1200, 10, 0, 'Unlawful taking of property valued under $2,000.' },
                { '30-302', 'Grand Theft Auto', 'Property Crimes', 'Felony', 6500, 30, 0, 'Unlawfully taking or driving a motor vehicle without consent.' },
                { '30-303', 'Commercial Armed Robbery', 'Violent Crimes', 'Felony', 12000, 40, 0, 'Taking property from a business by force, fear, or weapon.' },
                { '30-304', 'Bank Robbery & Vault Breach', 'Violent Crimes', 'Felony', 25000, 60, 0, 'Armed robbery or unauthorized breach of a bank vault.' },
                { '30-305', 'Assault with a Deadly Weapon', 'Violent Crimes', 'Felony', 15000, 50, 0, 'Attacking or threatening another individual using a firearm or deadly weapon.' },
                { '30-306', 'Attempted Murder / Murder of a Peace Officer', 'Capital Crimes', 'Felony', 50000, 120, 0, 'Unlawful killing or attempted killing of an active law enforcement officer.' }
            }
            for _, item in ipairs(seed) do
                MySQL.insert('INSERT INTO `mdt_penal_codes` (`code`, `title`, `category`, `class`, `fine`, `jail_time`, `points`, `description`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', item)
            end
        end
    end)
end

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        InitDatabase()
    end
end)

-- =========================================================================
-- HELPER & VALIDATION FUNCTIONS
-- =========================================================================

local function IsOfficer(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not xPlayer.job then return false, nil end
    if ConfigMDT.AllowedJobs[xPlayer.job.name] then
        return true, xPlayer
    end
    return false, xPlayer
end

local function GetPlayerFullName(xPlayer)
    if not xPlayer then return "Unknown Officer" end
    local name = xPlayer.getName()
    if name and name ~= "" then return name end
    local first = xPlayer.get('firstName') or ""
    local last = xPlayer.get('lastName') or ""
    if first ~= "" or last ~= "" then
        return (first .. " " .. last):gsub("^%s*(.-)%s*$", "%1")
    end
    return xPlayer.name or "Officer"
end

local function BroadcastToOfficers(eventName, ...)
    for src, _ in pairs(ActiveOfficers) do
        TriggerClientEvent(eventName, src, ...)
    end
end

-- =========================================================================
-- OFFICER PROFILE & SESSION SYNC
-- =========================================================================

local function GetOrCreateOfficerData(xPlayer, cb)
    local identifier = xPlayer.identifier
    MySQL.single('SELECT * FROM `mdt_officers` WHERE `identifier` = ?', { identifier }, function(row)
        local fullName = GetPlayerFullName(xPlayer)
        local dept = "LSPD"
        if xPlayer.job.name == "sheriff" then dept = "BCSO"
        elseif xPlayer.job.name == "state" then dept = "SASP"
        elseif xPlayer.job.name == "fib" then dept = "FIB" end

        if not row then
            local callsign = ("1-A-%02d"):format(math.random(1, 99))
            local badge = tostring(xPlayer.job.grade)
            MySQL.insert('INSERT INTO `mdt_officers` (`identifier`, `name`, `callsign`, `department`, `badge_number`) VALUES (?, ?, ?, ?, ?)', {
                identifier, fullName, callsign, dept, badge
            })
            local data = {
                identifier = identifier,
                name = fullName,
                callsign = callsign,
                department = dept,
                badge_number = badge,
                rank = xPlayer.job.grade_label or "Officer",
                grade = xPlayer.job.grade or 0,
                job = xPlayer.job.name
            }
            cb(data)
        else
            local data = {
                identifier = identifier,
                name = fullName,
                callsign = row.callsign or "1-A-01",
                department = row.department or dept,
                badge_number = row.badge_number or tostring(xPlayer.job.grade),
                rank = xPlayer.job.grade_label or "Officer",
                grade = xPlayer.job.grade or 0,
                job = xPlayer.job.name
            }
            cb(data)
        end
    end)
end

-- =========================================================================
-- NUI & SERVER DATA HANDLERS
-- =========================================================================

-- Officer Login / Request Initial MDT Data
RegisterNetEvent('cfx-keydi-mdt:server:requestMdtData', function()
    local src = source
    local isAuthorized, xPlayer = IsOfficer(src)
    if not isAuthorized then
        TriggerClientEvent('cfx-keydi-mdt:client:openDenied', src, "Access Denied: You must be on duty as Law Enforcement.")
        return
    end

    GetOrCreateOfficerData(xPlayer, function(officerProfile)
        -- Update active officer cache
        ActiveOfficers[src] = {
            source = src,
            identifier = officerProfile.identifier,
            name = officerProfile.name,
            callsign = officerProfile.callsign,
            department = officerProfile.department,
            badge_number = officerProfile.badge_number,
            rank = officerProfile.rank,
            grade = officerProfile.grade,
            job = officerProfile.job,
            status = ActiveOfficers[src] and ActiveOfficers[src].status or "10-8",
            radio = ActiveOfficers[src] and ActiveOfficers[src].radio or "100.1 MHz",
            coords = GetEntityCoords(GetPlayerPed(src))
        }

        -- Fetch Dashboard Stats, Warrants, BOLOs, Penal Codes, and Active Calls in parallel
        MySQL.query('SELECT * FROM `mdt_warrants` WHERE `status` = "Active" ORDER BY `id` DESC LIMIT 50', {}, function(warrants)
            MySQL.query('SELECT * FROM `mdt_bolos` WHERE `status` = "active" ORDER BY `id` DESC LIMIT 50', {}, function(bolos)
                MySQL.query('SELECT * FROM `mdt_penal_codes` ORDER BY `category`, `code` ASC', {}, function(penalCodes)
                    MySQL.query('SELECT * FROM `mdt_incidents` ORDER BY `id` DESC LIMIT 20', {}, function(recentIncidents)
                        
                        -- Decode JSON columns for safe frontend parsing
                        local parsedWarrants = {}
                        if warrants then
                            for _, w in ipairs(warrants) do
                                pcall(function() w.charges = json.decode(w.charges) or {} end)
                                table.insert(parsedWarrants, w)
                            end
                        end

                        local parsedIncidents = {}
                        if recentIncidents then
                            for _, inc in ipairs(recentIncidents) do
                                pcall(function()
                                    inc.suspects = json.decode(inc.suspects) or {}
                                    inc.officers = json.decode(inc.officers) or {}
                                    inc.charges = json.decode(inc.charges) or {}
                                    inc.evidence = json.decode(inc.evidence) or {}
                                end)
                                table.insert(parsedIncidents, inc)
                            end
                        end

                        -- Prepare active officers list
                        local officerList = {}
                        for _, off in pairs(ActiveOfficers) do
                            table.insert(officerList, off)
                        end

                        -- Prepare active dispatch calls
                        local callsList = {}
                        for _, call in pairs(ActiveDispatchCalls) do
                            table.insert(callsList, call)
                        end

                        local payload = {
                            officer = officerProfile,
                            warrants = parsedWarrants,
                            bolos = bolos or {},
                            penalCodes = penalCodes or {},
                            recentIncidents = parsedIncidents,
                            activeOfficers = officerList,
                            dispatchCalls = callsList,
                            permissions = ConfigMDT.Permissions
                        }

                        TriggerClientEvent('cfx-keydi-mdt:client:receiveMdtData', src, payload)
                        BroadcastToOfficers('cfx-keydi-mdt:client:syncDutyUnits', officerList)
                    end)
                end)
            end)
        end)
    end)
end)

-- Update Officer Status (10-8, 10-6, 10-97, 10-7, 10-99)
RegisterNetEvent('cfx-keydi-mdt:server:setDutyStatus', function(status)
    local src = source
    if ActiveOfficers[src] then
        ActiveOfficers[src].status = status
        ActiveOfficers[src].coords = GetEntityCoords(GetPlayerPed(src))
        
        local officerList = {}
        for _, off in pairs(ActiveOfficers) do
            table.insert(officerList, off)
        end
        BroadcastToOfficers('cfx-keydi-mdt:client:syncDutyUnits', officerList)
    end
end)

-- Update Officer Callsign / Department / Badge
RegisterNetEvent('cfx-keydi-mdt:server:updateOfficerProfile', function(data)
    local src = source
    local isAuth, xPlayer = IsOfficer(src)
    if not isAuth or not data then return end

    local callsign = tostring(data.callsign or "1-A-01"):gsub("[^%w%-%s]", ""):sub(1, 20)
    local dept = tostring(data.department or "LSPD"):gsub("[^%w%s]", ""):sub(1, 20)
    local badge = tostring(data.badge_number or "001"):gsub("[^%w%-%s]", ""):sub(1, 20)

    MySQL.update([[
        INSERT INTO `mdt_officers` (`identifier`, `name`, `callsign`, `department`, `badge_number`)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE `callsign` = VALUES(`callsign`), `department` = VALUES(`department`), `badge_number` = VALUES(`badge_number`)
    ]], { xPlayer.identifier, GetPlayerFullName(xPlayer), callsign, dept, badge }, function()
        if ActiveOfficers[src] then
            ActiveOfficers[src].callsign = callsign
            ActiveOfficers[src].department = dept
            ActiveOfficers[src].badge_number = badge
        end

        local officerList = {}
        for _, off in pairs(ActiveOfficers) do
            table.insert(officerList, off)
        end
        BroadcastToOfficers('cfx-keydi-mdt:client:syncDutyUnits', officerList)
        TriggerClientEvent('cfx-keydi-mdt:client:officerProfileUpdated', src, {
            callsign = callsign,
            department = dept,
            badge_number = badge
        })
    end)
end)

-- =========================================================================
-- CITIZEN LOOKUP
-- =========================================================================

RegisterNetEvent('cfx-keydi-mdt:server:searchCitizen', function(query)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth or not query or query == "" then return end

    local searchPattern = "%" .. query .. "%"

    MySQL.query([[
        SELECT identifier, firstname, lastname, dateofbirth, sex, height, job, job_grade, phone_number
        FROM `users`
        WHERE CONCAT(firstname, ' ', lastname) LIKE ?
           OR firstname LIKE ?
           OR lastname LIKE ?
           OR dateofbirth LIKE ?
           OR identifier LIKE ?
           OR phone_number LIKE ?
        LIMIT 25
    ]], { searchPattern, searchPattern, searchPattern, searchPattern, searchPattern, searchPattern }, function(results)
        if not results or #results == 0 then
            TriggerClientEvent('cfx-keydi-mdt:client:receiveCitizenSearchResults', src, {})
            return
        end

        local citizens = {}
        local count = #results
        local processed = 0

        for _, citizen in ipairs(results) do
            local ident = citizen.identifier
            
            -- Query licenses
            MySQL.query('SELECT type FROM `user_licenses` WHERE `owner` = ?', { ident }, function(licenses)
                -- Query vehicles
                MySQL.query('SELECT plate, vehicle, stored FROM `owned_vehicles` WHERE `owner` = ?', { ident }, function(vehicles)
                    -- Query active warrants
                    MySQL.query('SELECT * FROM `mdt_warrants` WHERE `suspect_identifier` = ? AND `status` = "Active"', { ident }, function(warrants)
                        -- Query citizen notes
                        MySQL.query('SELECT * FROM `mdt_citizen_notes` WHERE `identifier` = ? ORDER BY `id` DESC LIMIT 10', { ident }, function(notes)
                            -- Query incident history
                            MySQL.query('SELECT * FROM `mdt_incidents` WHERE `suspects` LIKE ? ORDER BY `id` DESC LIMIT 10', { "%" .. ident .. "%" }, function(priors)
                                
                                local licList = {}
                                if licenses then
                                    for _, l in ipairs(licenses) do table.insert(licList, l.type) end
                                end

                                local vehList = {}
                                if vehicles then
                                    for _, v in ipairs(vehicles) do
                                        local modelName = "Unknown Model"
                                        pcall(function()
                                            local decoded = json.decode(v.vehicle)
                                            if decoded and decoded.model then
                                                modelName = tostring(decoded.model)
                                            end
                                        end)
                                        table.insert(vehList, {
                                            plate = v.plate,
                                            model = modelName,
                                            stored = v.stored == 1 or v.stored == true
                                        })
                                    end
                                end

                                local warrantList = {}
                                if warrants then
                                    for _, w in ipairs(warrants) do
                                        pcall(function() w.charges = json.decode(w.charges) or {} end)
                                        table.insert(warrantList, w)
                                    end
                                end

                                local priorList = {}
                                if priors then
                                    for _, p in ipairs(priors) do
                                        pcall(function()
                                            p.charges = json.decode(p.charges) or {}
                                            p.suspects = json.decode(p.suspects) or {}
                                        end)
                                        table.insert(priorList, p)
                                    end
                                end

                                table.insert(citizens, {
                                    identifier = ident,
                                    firstname = citizen.firstname or "",
                                    lastname = citizen.lastname or "",
                                    dateofbirth = citizen.dateofbirth or "01/01/1990",
                                    gender = (citizen.sex == "m" or citizen.sex == "0") and "Male" or "Female",
                                    height = citizen.height or "175 cm",
                                    job = citizen.job or "Unemployed",
                                    phone = citizen.phone_number or "N/A",
                                    licenses = licList,
                                    vehicles = vehList,
                                    warrants = warrantList,
                                    notes = notes or {},
                                    priors = priorList
                                })

                                processed = processed + 1
                                if processed == count then
                                    TriggerClientEvent('cfx-keydi-mdt:client:receiveCitizenSearchResults', src, citizens)
                                end
                            end)
                        end)
                    end)
                end)
            end)
        end
    end)
end)

-- Add Note to Citizen Profile
RegisterNetEvent('cfx-keydi-mdt:server:addCitizenNote', function(data)
    local src = source
    local isAuth, xPlayer = IsOfficer(src)
    if not isAuth or not data or not data.identifier or not data.note then return end

    local authorName = GetPlayerFullName(xPlayer)
    MySQL.insert('INSERT INTO `mdt_citizen_notes` (`identifier`, `note`, `author_name`, `author_identifier`, `image_url`) VALUES (?, ?, ?, ?, ?)', {
        data.identifier, data.note, authorName, xPlayer.identifier, data.imageUrl or ""
    }, function()
        MySQL.query('SELECT * FROM `mdt_citizen_notes` WHERE `identifier` = ? ORDER BY `id` DESC LIMIT 10', { data.identifier }, function(notes)
            TriggerClientEvent('cfx-keydi-mdt:client:citizenNotesUpdated', src, {
                identifier = data.identifier,
                notes = notes or {}
            })
        end)
    end)
end)

-- =========================================================================
-- VEHICLE LOOKUP
-- =========================================================================

RegisterNetEvent('cfx-keydi-mdt:server:searchVehicle', function(query)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth or not query or query == "" then return end

    local cleanQuery = query:gsub("%s+", ""):upper()
    local searchPattern = "%" .. cleanQuery .. "%"

    MySQL.query([[
        SELECT ov.plate, ov.owner, ov.vehicle, ov.stored, ov.garage,
               u.firstname, u.lastname, u.phone_number
        FROM `owned_vehicles` ov
        LEFT JOIN `users` u ON ov.owner = u.identifier
        WHERE REPLACE(ov.plate, ' ', '') LIKE ?
        LIMIT 20
    ]], { searchPattern }, function(results)
        if not results or #results == 0 then
            TriggerClientEvent('cfx-keydi-mdt:client:receiveVehicleSearchResults', src, {})
            return
        end

        local vehicles = {}
        local count = #results
        local processed = 0

        for _, row in ipairs(results) do
            local plate = row.plate
            local ownerName = (row.firstname and row.lastname) and (row.firstname .. " " .. row.lastname) or "Unknown / Government"

            -- Fetch vehicle flags
            MySQL.query('SELECT * FROM `mdt_vehicle_flags` WHERE `plate` = ? ORDER BY `id` DESC', { plate }, function(flags)
                -- Fetch vehicle BOLOs
                MySQL.query('SELECT * FROM `mdt_bolos` WHERE `type` = "vehicle" AND `target` LIKE ? AND `status` = "active"', { "%" .. plate .. "%" }, function(bolos)
                    
                    local modelName = "Unknown Vehicle"
                    local color = "Unknown Color"
                    pcall(function()
                        local vehData = json.decode(row.vehicle)
                        if vehData and vehData.model then
                            modelName = tostring(vehData.model)
                        end
                        if vehData and vehData.color1 then
                            color = "Color Code: " .. tostring(vehData.color1)
                        end
                    end)

                    table.insert(vehicles, {
                        plate = plate,
                        owner = ownerName,
                        ownerIdentifier = row.owner or "",
                        phone = row.phone_number or "N/A",
                        model = modelName,
                        color = color,
                        stored = row.stored == 1 or row.stored == true,
                        garage = row.garage or "Legion Garage",
                        flags = flags or {},
                        bolos = bolos or {}
                    })

                    processed = processed + 1
                    if processed == count then
                        TriggerClientEvent('cfx-keydi-mdt:client:receiveVehicleSearchResults', src, vehicles)
                    end
                end)
            end)
        end
    end)
end)

-- Add Vehicle Flag (Stolen, BOLO, Suspended, Impound)
RegisterNetEvent('cfx-keydi-mdt:server:addVehicleFlag', function(data)
    local src = source
    local isAuth, xPlayer = IsOfficer(src)
    if not isAuth or not data or not data.plate or not data.flagType then return end

    local authorName = GetPlayerFullName(xPlayer)
    MySQL.insert('INSERT INTO `mdt_vehicle_flags` (`plate`, `flag_type`, `reason`, `author_name`, `author_identifier`) VALUES (?, ?, ?, ?, ?)', {
        data.plate, data.flagType, data.reason or "No reason specified", authorName, xPlayer.identifier
    }, function()
        MySQL.query('SELECT * FROM `mdt_vehicle_flags` WHERE `plate` = ? ORDER BY `id` DESC', { data.plate }, function(flags)
            TriggerClientEvent('cfx-keydi-mdt:client:vehicleFlagsUpdated', src, {
                plate = data.plate,
                flags = flags or {}
            })
        end)
    end)
end)

-- Remove Vehicle Flag
RegisterNetEvent('cfx-keydi-mdt:server:removeVehicleFlag', function(flagId, plate)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth or not flagId then return end

    MySQL.query('DELETE FROM `mdt_vehicle_flags` WHERE `id` = ?', { flagId }, function()
        if plate then
            MySQL.query('SELECT * FROM `mdt_vehicle_flags` WHERE `plate` = ? ORDER BY `id` DESC', { plate }, function(flags)
                TriggerClientEvent('cfx-keydi-mdt:client:vehicleFlagsUpdated', src, {
                    plate = plate,
                    flags = flags or {}
                })
            end)
        end
    end)
end)

-- =========================================================================
-- WARRANTS & BOLOS
-- =========================================================================

RegisterNetEvent('cfx-keydi-mdt:server:createWarrant', function(data)
    local src = source
    local isAuth, xPlayer = IsOfficer(src)
    if not isAuth or not data or not data.suspectIdentifier or not data.reason then return end

    local issuingOfficer = GetPlayerFullName(xPlayer)
    local chargesJson = json.encode(data.charges or {})
    local expireDate = data.expireDate or os.date("%Y-%m-%d", os.time() + (7 * 86400))

    MySQL.insert('INSERT INTO `mdt_warrants` (`suspect_identifier`, `suspect_name`, `charges`, `reason`, `issuing_officer`, `issuing_officer_identifier`, `status`, `expire_date`) VALUES (?, ?, ?, ?, ?, ?, "Active", ?)', {
        data.suspectIdentifier, data.suspectName or "Unknown", chargesJson, data.reason, issuingOfficer, xPlayer.identifier, expireDate
    }, function(insertId)
        MySQL.query('SELECT * FROM `mdt_warrants` WHERE `status` = "Active" ORDER BY `id` DESC', {}, function(warrants)
            local parsed = {}
            if warrants then
                for _, w in ipairs(warrants) do
                    pcall(function() w.charges = json.decode(w.charges) or {} end)
                    table.insert(parsed, w)
                end
            end
            BroadcastToOfficers('cfx-keydi-mdt:client:syncWarrants', parsed)
            BroadcastToOfficers('cfx-keydi-mdt:client:alertBroadcast', {
                type = "warrant",
                title = "NEW ARREST WARRANT ISSUED",
                message = ("Warrant issued for %s by %s"):format(data.suspectName or "Unknown", issuingOfficer)
            })
        end)
    end)
end)

RegisterNetEvent('cfx-keydi-mdt:server:deleteWarrant', function(warrantId)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth or not warrantId then return end

    MySQL.update('UPDATE `mdt_warrants` SET `status` = "Served" WHERE `id` = ?', { warrantId }, function()
        MySQL.query('SELECT * FROM `mdt_warrants` WHERE `status` = "Active" ORDER BY `id` DESC', {}, function(warrants)
            local parsed = {}
            if warrants then
                for _, w in ipairs(warrants) do
                    pcall(function() w.charges = json.decode(w.charges) or {} end)
                    table.insert(parsed, w)
                end
            end
            BroadcastToOfficers('cfx-keydi-mdt:client:syncWarrants', parsed)
        end)
    end)
end)

RegisterNetEvent('cfx-keydi-mdt:server:createBolo', function(data)
    local src = source
    local isAuth, xPlayer = IsOfficer(src)
    if not isAuth or not data or not data.title or not data.target then return end

    local authorName = GetPlayerFullName(xPlayer)
    local priority = data.priority or "medium"

    MySQL.insert('INSERT INTO `mdt_bolos` (`type`, `title`, `target`, `description`, `priority`, `image_url`, `author_name`, `author_identifier`, `status`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, "active")', {
        data.type or "person", data.title, data.target, data.description or "", priority, data.imageUrl or "", authorName, xPlayer.identifier
    }, function(insertId)
        MySQL.query('SELECT * FROM `mdt_bolos` WHERE `status` = "active" ORDER BY `id` DESC', {}, function(bolos)
            BroadcastToOfficers('cfx-keydi-mdt:client:syncBolos', bolos or {})
            BroadcastToOfficers('cfx-keydi-mdt:client:alertBroadcast', {
                type = "bolo",
                title = ("NEW BOLO: %s"):format(data.title:upper()),
                message = ("Target: %s | Priority: %s | Issued by: %s"):format(data.target, priority:upper(), authorName)
            })
        end)
    end)
end)

RegisterNetEvent('cfx-keydi-mdt:server:deleteBolo', function(boloId)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth or not boloId then return end

    MySQL.update('UPDATE `mdt_bolos` SET `status` = "resolved" WHERE `id` = ?', { boloId }, function()
        MySQL.query('SELECT * FROM `mdt_bolos` WHERE `status` = "active" ORDER BY `id` DESC', {}, function(bolos)
            BroadcastToOfficers('cfx-keydi-mdt:client:syncBolos', bolos or {})
        end)
    end)
end)

-- =========================================================================
-- INCIDENT REPORTS
-- =========================================================================

RegisterNetEvent('cfx-keydi-mdt:server:saveIncident', function(data)
    local src = source
    local isAuth, xPlayer = IsOfficer(src)
    if not isAuth or not data or not data.title or not data.description then return end

    local authorName = GetPlayerFullName(xPlayer)
    local suspectsJson = json.encode(data.suspects or {})
    local officersJson = json.encode(data.officers or {})
    local chargesJson = json.encode(data.charges or {})
    local evidenceJson = json.encode(data.evidence or {})
    local totalFine = tonumber(data.totalFine) or 0
    local totalJail = tonumber(data.totalJail) or 0
    local status = data.status or "Closed"

    if data.id and tonumber(data.id) then
        -- Update existing
        MySQL.update([[
            UPDATE `mdt_incidents`
            SET `title` = ?, `description` = ?, `location` = ?, `suspects` = ?, `officers` = ?, `charges` = ?, `evidence` = ?, `status` = ?, `total_fine` = ?, `total_jail` = ?
            WHERE `id` = ?
        ]], {
            data.title, data.description, data.location or "Los Santos", suspectsJson, officersJson, chargesJson, evidenceJson, status, totalFine, totalJail, data.id
        }, function()
            TriggerClientEvent('cfx-keydi-mdt:client:incidentSaved', src, data.id)
            TriggerEvent('cfx-keydi-mdt:server:refreshIncidents')
        end)
    else
        -- Create new
        MySQL.insert([[
            INSERT INTO `mdt_incidents` (`title`, `description`, `location`, `reporting_officer`, `reporting_officer_identifier`, `suspects`, `officers`, `charges`, `evidence`, `status`, `total_fine`, `total_jail`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            data.title, data.description, data.location or "Los Santos", authorName, xPlayer.identifier, suspectsJson, officersJson, chargesJson, evidenceJson, status, totalFine, totalJail
        }, function(newId)
            TriggerClientEvent('cfx-keydi-mdt:client:incidentSaved', src, newId)
            TriggerEvent('cfx-keydi-mdt:server:refreshIncidents')
        end)
    end
end)

AddEventHandler('cfx-keydi-mdt:server:refreshIncidents', function()
    MySQL.query('SELECT * FROM `mdt_incidents` ORDER BY `id` DESC LIMIT 40', {}, function(incidents)
        local parsed = {}
        if incidents then
            for _, inc in ipairs(incidents) do
                pcall(function()
                    inc.suspects = json.decode(inc.suspects) or {}
                    inc.officers = json.decode(inc.officers) or {}
                    inc.charges = json.decode(inc.charges) or {}
                    inc.evidence = json.decode(inc.evidence) or {}
                end)
                table.insert(parsed, inc)
            end
        end
        BroadcastToOfficers('cfx-keydi-mdt:client:syncIncidents', parsed)
    end)
end)

RegisterNetEvent('cfx-keydi-mdt:server:deleteIncident', function(incidentId)
    local src = source
    local isAuth, xPlayer = IsOfficer(src)
    if not isAuth or not incidentId then return end

    if xPlayer.job.grade < (ConfigMDT.Permissions.delete_incident or 3) then
        TriggerClientEvent('esx:showNotification', src, "Insufficient rank permissions to delete incident reports.")
        return
    end

    MySQL.query('DELETE FROM `mdt_incidents` WHERE `id` = ?', { incidentId }, function()
        TriggerEvent('cfx-keydi-mdt:server:refreshIncidents')
    end)
end)

-- =========================================================================
-- DISPATCH CALLS & PANIC BUTTON
-- =========================================================================

local function CreateDispatchCall(code, title, message, coords, street, caller, phone, priority)
    NextDispatchId = NextDispatchId + 1
    local callId = NextDispatchId
    local newCall = {
        id = callId,
        code = code or "10-90",
        title = title or "Dispatch Call",
        message = message or "",
        coords = coords or { x = 0.0, y = 0.0, z = 0.0 },
        street = street or "Unknown Location",
        caller = caller or "911 Emergency",
        phone = phone or "N/A",
        priority = priority or "medium",
        units = {},
        status = "active",
        time = os.date("%H:%M:%S")
    }

    ActiveDispatchCalls[callId] = newCall

    local callsList = {}
    for _, call in pairs(ActiveDispatchCalls) do
        table.insert(callsList, call)
    end

    BroadcastToOfficers('cfx-keydi-mdt:client:syncDispatchCalls', callsList)
    BroadcastToOfficers('cfx-keydi-mdt:client:alertBroadcast', {
        type = "dispatch",
        priority = priority,
        title = ("DISPATCH: %s (%s)"):format(newCall.title:upper(), newCall.code),
        message = ("%s | Location: %s"):format(newCall.message, newCall.street),
        call = newCall
    })

    return callId
end

RegisterNetEvent('cfx-keydi-mdt:server:attachUnitToCall', function(callId)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth or not callId or not ActiveDispatchCalls[callId] then return end

    local officer = ActiveOfficers[src]
    if not officer then return end

    local call = ActiveDispatchCalls[callId]
    local alreadyAttached = false
    for i, unit in ipairs(call.units) do
        if unit.source == src then
            table.remove(call.units, i)
            alreadyAttached = true
            break
        end
    end

    if not alreadyAttached then
        table.insert(call.units, {
            source = src,
            callsign = officer.callsign,
            name = officer.name
        })
    end

    local callsList = {}
    for _, c in pairs(ActiveDispatchCalls) do
        table.insert(callsList, c)
    end
    BroadcastToOfficers('cfx-keydi-mdt:client:syncDispatchCalls', callsList)
end)

RegisterNetEvent('cfx-keydi-mdt:server:resolveDispatchCall', function(callId)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth or not callId then return end

    if ActiveDispatchCalls[callId] then
        ActiveDispatchCalls[callId] = nil
    end

    local callsList = {}
    for _, c in pairs(ActiveDispatchCalls) do
        table.insert(callsList, c)
    end
    BroadcastToOfficers('cfx-keydi-mdt:client:syncDispatchCalls', callsList)
end)

RegisterNetEvent('cfx-keydi-mdt:server:triggerPanic', function(coords, street)
    local src = source
    local isAuth = IsOfficer(src)
    if not isAuth then return end

    local officer = ActiveOfficers[src]
    local officerName = officer and officer.name or "Officer"
    local callsign = officer and officer.callsign or "10-99"

    local callId = CreateDispatchCall(
        "10-99",
        ("OFFICER IN DISTRESS: %s (%s)"):format(officerName, callsign),
        "Immediate backup requested! Officer activated emergency panic beacon.",
        coords or GetEntityCoords(GetPlayerPed(src)),
        street or "Current Officer Location",
        officerName,
        "POLICE RADIO",
        "urgent"
    )
end)

-- Player Drop Cleanup
AddEventHandler('playerDropped', function()
    local src = source
    if ActiveOfficers[src] then
        ActiveOfficers[src] = nil
        local officerList = {}
        for _, off in pairs(ActiveOfficers) do
            table.insert(officerList, off)
        end
        BroadcastToOfficers('cfx-keydi-mdt:client:syncDutyUnits', officerList)
    end
end)

-- =========================================================================
-- SERVER EXPORTS (For Robberies, 911 Calls, Dispatch, and Jobs)
-- =========================================================================

exports('AddDispatchCall', function(callData)
    if not callData then return end
    return CreateDispatchCall(
        callData.code or "10-90",
        callData.title or "Emergency Call",
        callData.message or "Incident Reported",
        callData.coords or { x = 0, y = 0, z = 0 },
        callData.street or "Los Santos",
        callData.caller or "Citizen 911",
        callData.phone or "Anonymous",
        callData.priority or "medium"
    )
end)

exports('CreateBolo', function(boloData)
    if not boloData then return end
    MySQL.insert('INSERT INTO `mdt_bolos` (`type`, `title`, `target`, `description`, `priority`, `image_url`, `author_name`, `author_identifier`, `status`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, "active")', {
        boloData.type or "person", boloData.title or "BOLO", boloData.target or "Unknown", boloData.description or "", boloData.priority or "medium", boloData.imageUrl or "", boloData.author or "System", "SYSTEM"
    }, function()
        MySQL.query('SELECT * FROM `mdt_bolos` WHERE `status` = "active" ORDER BY `id` DESC', {}, function(bolos)
            BroadcastToOfficers('cfx-keydi-mdt:client:syncBolos', bolos or {})
        end)
    end)
end)

exports('GetOnDutyOfficers', function()
    local list = {}
    for _, off in pairs(ActiveOfficers) do
        table.insert(list, off)
    end
    return list
end)
