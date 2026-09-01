-- =========================================================================
-- CFX-KEYDI-MDT DATABASE SCHEMA
-- Compatible with ESX Legacy and oxmysql
-- =========================================================================

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

CREATE TABLE IF NOT EXISTS `mdt_bolos` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `type` VARCHAR(50) NOT NULL DEFAULT 'person', -- 'person', 'vehicle', 'area'
    `title` VARCHAR(255) NOT NULL,
    `target` VARCHAR(255) NOT NULL, -- Name, Plate, or Area Name
    `description` LONGTEXT NOT NULL,
    `priority` VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high'
    `image_url` VARCHAR(500) DEFAULT '',
    `author_name` VARCHAR(100) NOT NULL,
    `author_identifier` VARCHAR(64) NOT NULL,
    `status` VARCHAR(20) DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_officers` (
    `identifier` VARCHAR(64) PRIMARY KEY,
    `name` VARCHAR(100) DEFAULT '',
    `callsign` VARCHAR(50) DEFAULT '1-A-01',
    `department` VARCHAR(50) DEFAULT 'LSPD',
    `badge_number` VARCHAR(50) DEFAULT '001',
    `custom_notes` LONGTEXT DEFAULT '',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_citizen_notes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(64) NOT NULL,
    `note` LONGTEXT NOT NULL,
    `author_name` VARCHAR(100) NOT NULL,
    `author_identifier` VARCHAR(64) NOT NULL,
    `image_url` VARCHAR(500) DEFAULT '',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_vehicle_flags` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `plate` VARCHAR(20) NOT NULL,
    `flag_type` VARCHAR(100) NOT NULL,
    `reason` LONGTEXT NOT NULL,
    `author_name` VARCHAR(100) NOT NULL,
    `author_identifier` VARCHAR(64) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_dispatch_calls` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `message` LONGTEXT DEFAULT '',
    `coords` LONGTEXT DEFAULT '{}',
    `street` VARCHAR(255) DEFAULT 'Unknown Street',
    `caller` VARCHAR(100) DEFAULT '911 Emergency',
    `phone` VARCHAR(50) DEFAULT 'Anonymous',
    `priority` VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
    `units` LONGTEXT DEFAULT '[]',
    `status` VARCHAR(20) DEFAULT 'active', -- 'active', 'resolved'
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_penal_codes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `class` VARCHAR(50) NOT NULL, -- 'Infraction', 'Misdemeanor', 'Felony'
    `fine` INT DEFAULT 0,
    `jail_time` INT DEFAULT 0,
    `points` INT DEFAULT 0,
    `description` LONGTEXT DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Initial seed for penal codes
INSERT IGNORE INTO `mdt_penal_codes` (`code`, `title`, `category`, `class`, `fine`, `jail_time`, `points`, `description`) VALUES
('10-101', 'Speeding (1-15 mph over)', 'Traffic', 'Infraction', 250, 0, 1, 'Operating a vehicle over the posted speed limit by 1-15 mph.'),
('10-102', 'Speeding (16-30 mph over)', 'Traffic', 'Infraction', 500, 0, 2, 'Operating a vehicle over the posted speed limit by 16-30 mph.'),
('10-103', 'Reckless Driving', 'Traffic', 'Misdemeanor', 1500, 10, 3, 'Driving with willful disregard for safety of persons or property.'),
('10-104', 'Driving Without a Valid License', 'Traffic', 'Infraction', 750, 0, 1, 'Operating a motor vehicle without a valid driver license on person.'),
('10-105', 'Hit and Run / Evading Police in Vehicle', 'Traffic', 'Felony', 5000, 25, 5, 'Fleeing the scene of an accident or evading law enforcement in a motor vehicle.'),
('20-201', 'Trespassing on Private Property', 'Public Order', 'Misdemeanor', 1000, 5, 0, 'Entering or remaining on property without permission from the owner.'),
('20-202', 'Disorderly Conduct', 'Public Order', 'Misdemeanor', 800, 5, 0, 'Engaging in violent, tumultuous, or threatening behavior in public.'),
('20-203', 'Resisting Law Enforcement Officer', 'Obstruction', 'Misdemeanor', 2000, 15, 0, 'Intentionally fleeing, obstructing, or physically resisting a police officer.'),
('20-204', 'Possession of Illegal Narcotics (Personal)', 'Drug Offenses', 'Misdemeanor', 2500, 15, 0, 'Possession of controlled illicit substances in small personal quantities.'),
('20-205', 'Drug Trafficking / Intent to Distribute', 'Drug Offenses', 'Felony', 10000, 45, 0, 'Manufacturing, transporting, or distributing narcotics in large quantities.'),
('30-301', 'Petty Theft', 'Property Crimes', 'Misdemeanor', 1200, 10, 0, 'Unlawful taking of property valued under $2,000.'),
('30-302', 'Grand Theft Auto (Vehicle Theft)', 'Property Crimes', 'Felony', 6500, 30, 0, 'Unlawfully taking or driving a motor vehicle without the owner consent.'),
('30-303', 'Robbery of a Commercial Business / Store', 'Violent Crimes', 'Felony', 12000, 40, 0, 'Taking property from a store or commercial entity by force, fear, or weapon.'),
('30-304', 'Bank Robbery / Vault Breach', 'Violent Crimes', 'Felony', 25000, 60, 0, 'Armed robbery or unauthorized breach of a financial institution vault.'),
('30-305', 'Assault with a Deadly Weapon', 'Violent Crimes', 'Felony', 15000, 50, 0, 'Attacking or threatening another individual using a firearm or deadly weapon.'),
('30-306', 'Attempted Murder / Murder of a Peace Officer', 'Capital Crimes', 'Felony', 50000, 120, 0, 'Unlawful premeditated killing or attempted killing of an active law enforcement officer.');
