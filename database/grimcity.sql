-- ==========================================================
-- GrimCity Roleplay — full database bootstrap
-- Merges: legacy + jobs/grades (PD/EMS/Sheriff/DOJ/biz) + gangs + pvp_stats
-- Import once on a fresh MySQL/MariaDB server.
-- ==========================================================

CREATE DATABASE IF NOT EXISTS `grimcity`;
USE `grimcity`;

-- --------------------------------------------------------
-- Table structure & data for table `items`
-- --------------------------------------------------------
CREATE TABLE `items` (
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `weight` int(11) NOT NULL DEFAULT 1,
  `rare` tinyint(4) NOT NULL DEFAULT 0,
  `can_remove` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('alive_chicken', 'Living chicken', 1, 0, 1),
('bandage', 'Bandage', 2, 0, 1),
('blowpipe', 'Blowtorch', 2, 0, 1),
('bread', 'Bread', 1, 0, 1),
('cannabis', 'Cannabis', 3, 0, 1),
('carokit', 'Body Kit', 3, 0, 1),
('carotool', 'Tools', 2, 0, 1),
('clothe', 'Cloth', 1, 0, 1),
('copper', 'Copper', 1, 0, 1),
('cutted_wood', 'Cut wood', 1, 0, 1),
('diamond', 'Diamond', 1, 0, 1),
('essence', 'Gas', 1, 0, 1),
('fabric', 'Fabric', 1, 0, 1),
('fish', 'Fish', 1, 0, 1),
('radio', 'Radio', 1, 0, 1),
('fixkit', 'Repair Kit', 3, 0, 1),
('fixtool', 'Repair Tools', 2, 0, 1),
('gazbottle', 'Gas Bottle', 2, 0, 1),
('gold', 'Gold', 1, 0, 1),
('iron', 'Iron', 1, 0, 1),
('marijuana', 'Marijuana', 2, 0, 1),
('medikit', 'Medikit', 2, 0, 1),
('packaged_chicken', 'Chicken fillet', 1, 0, 1),
('packaged_plank', 'Packaged wood', 1, 0, 1),
('petrol', 'Oil', 1, 0, 1),
('petrol_raffin', 'Processed oil', 1, 0, 1),
('phone', 'Phone', 1, 0, 1),
('slaughtered_chicken', 'Slaughtered chicken', 1, 0, 1),
('stone', 'Stone', 1, 0, 1),
('washed_stone', 'Washed stone', 1, 0, 1),
('water', 'Water', 1, 0, 1),
('wood', 'Wood', 1, 0, 1),
('wool', 'Wool', 1, 0, 1);

-- --------------------------------------------------------
-- Table structure & data for table `jobs`
-- --------------------------------------------------------
CREATE TABLE `jobs` (
  `name` varchar(50) NOT NULL,
  `label` varchar(50) DEFAULT NULL,
  `type` varchar(51) NOT NULL DEFAULT 'civ',
  `whitelisted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO `jobs` (`name`, `label`, `type`, `whitelisted`) VALUES
('unemployed', 'Unemployed', 'civ', 0),
('student', 'Student', 'civ', 0),
('teacher', 'Teacher', 'civ', 0),
('police', 'Police', 'leo', 1),
('ambulance', 'EMS', 'ems', 0),
('pambulance', 'Paleto Ambulance', 'ems', 0),
('mechanic', 'Mechanic', 'mechanic', 0),
('offpolice', 'Off-Duty Police', 'leo', 0),
('sheriff', 'Sheriff', 'leo', 1),
('offsheriff', 'Off-Duty Sheriff', 'leo', 0),
('offambulance', 'Off-Duty EMS', 'ems', 0),
('offpambulance', 'Off-Duty Paleto Ambulance', 'ems', 0),
('offmechanic', 'Off-Duty Mechanic', 'mechanic', 0),
('8ball', '8Ball', 'civ', 0),
('burgershot', 'Burger Shot', 'civ', 0),
('uwu', 'UwU Cafe', 'civ', 0),
('tacoshop', 'Taco Shop', 'civ', 0),
('taco', 'Taco Shop', 'civ', 0),
('weedshop', 'Weed Shop', 'civ', 0),
('doj', 'DOJ', 'civ', 1),
('offdoj', 'Off-Duty DOJ', 'civ', 0);

-- --------------------------------------------------------
-- Table structure & data for table `job_grades`
-- --------------------------------------------------------
CREATE TABLE `job_grades` (
  `id` int(11) NOT NULL,
  `job_name` varchar(50) DEFAULT NULL,
  `grade` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `salary` int(11) NOT NULL,
  `skin_male` longtext NOT NULL,
  `skin_female` longtext NOT NULL
) ENGINE=InnoDB;

INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
(1, 'unemployed', 0, 'unemployed', 'Unemployed', 200, '{}', '{}'),
(2, 'student', 0, 'freshman', 'Freshman', 10, '{}', '{}'),
(3, 'student', 1, 'sophomore', 'Sophomore', 15, '{}', '{}'),
(4, 'student', 2, 'junior', 'Junior', 20, '{}', '{}'),
(5, 'student', 3, 'senior', 'Senior', 25, '{}', '{}'),
(6, 'teacher', 0, 'intern', 'Teacher Intern', 50, '{}', '{}'),
(7, 'teacher', 1, 'teacher', 'Teacher', 100, '{}', '{}'),
(8, 'teacher', 2, 'head_teacher', 'Department Head', 150, '{}', '{}'),
(9, 'teacher', 3, 'principal', 'Principal', 200, '{}', '{}'),
(10, 'police', 0, 'cadet', 'Cadet', 60000, '{}', '{}'),
(11, 'police', 1, 'officer', 'Police Officer', 65000, '{}', '{}'),
(12, 'police', 2, 'senior', 'Senior Police Officer', 70000, '{}', '{}'),
(13, 'police', 3, 'captain', 'Captain', 75000, '{}', '{}'),
(14, 'police', 4, 'deputy', 'Deputy Chief', 80000, '{}', '{}'),
(15, 'police', 5, 'chief', 'Chief of Police', 100000, '{}', '{}'),
(16, 'police', 6, 'boss', 'Director', 120000, '{}', '{}'),
(17, 'offpolice', 0, 'cadet', 'Cadet', 0, '{}', '{}'),
(18, 'offpolice', 1, 'officer', 'Police Officer', 0, '{}', '{}'),
(19, 'offpolice', 2, 'senior', 'Senior Police Officer', 0, '{}', '{}'),
(20, 'offpolice', 3, 'captain', 'Captain', 0, '{}', '{}'),
(21, 'offpolice', 4, 'deputy', 'Deputy Chief', 0, '{}', '{}'),
(22, 'offpolice', 5, 'chief', 'Chief of Police', 0, '{}', '{}'),
(23, 'offpolice', 6, 'boss', 'Director', 0, '{}', '{}'),
(24, 'ambulance', 0, 'intern', 'Intern', 65000, '{}', '{}'),
(25, 'ambulance', 1, 'nurse', 'Nurse', 70000, '{}', '{}'),
(26, 'ambulance', 2, 'head_nurse', 'Head Nurse', 75000, '{}', '{}'),
(27, 'ambulance', 3, 'resident_doctor', 'Resident Doctor', 80000, '{}', '{}'),
(28, 'ambulance', 4, 'senior_resident_doctor', 'Senior Resident Doctor', 85000, '{}', '{}'),
(29, 'ambulance', 5, 'assistant_director', 'Assistant Director', 90000, '{}', '{}'),
(30, 'ambulance', 6, 'boss', 'Medical Director', 100000, '{}', '{}'),
(31, 'offambulance', 0, 'intern', 'Intern', 0, '{}', '{}'),
(32, 'offambulance', 1, 'nurse', 'Nurse', 0, '{}', '{}'),
(33, 'offambulance', 2, 'head_nurse', 'Head Nurse', 0, '{}', '{}'),
(34, 'offambulance', 3, 'resident_doctor', 'Resident Doctor', 0, '{}', '{}'),
(35, 'offambulance', 4, 'senior_resident_doctor', 'Senior Resident Doctor', 0, '{}', '{}'),
(36, 'offambulance', 5, 'assistant_director', 'Assistant Director', 0, '{}', '{}'),
(37, 'offambulance', 6, 'boss', 'Medical Director', 0, '{}', '{}'),
(38, 'mechanic', 0, 'recruit', 'Recruit', 0, '{}', '{}'),
(39, 'mechanic', 1, 'employee', 'Mechanic', 0, '{}', '{}'),
(40, 'mechanic', 2, 'lead', 'Lead Mechanic', 0, '{}', '{}'),
(41, 'mechanic', 3, 'boss', 'Boss', 0, '{}', '{}'),
(42, 'offmechanic', 0, 'recruit', 'Recruit', 0, '{}', '{}'),
(43, 'offmechanic', 1, 'employee', 'Mechanic', 0, '{}', '{}'),
(44, 'offmechanic', 2, 'lead', 'Lead Mechanic', 0, '{}', '{}'),
(45, 'offmechanic', 3, 'boss', 'Boss', 0, '{}', '{}'),
(46, '8ball', 0, 'trainee', 'Trainee', 0, '{}', '{}'),
(47, '8ball', 1, 'staff', 'Staff', 0, '{}', '{}'),
(48, '8ball', 2, 'manager', 'Manager', 0, '{}', '{}'),
(49, '8ball', 3, 'boss', 'Owner', 0, '{}', '{}'),
(50, 'burgershot', 0, 'trainee', 'Trainee', 0, '{}', '{}'),
(51, 'burgershot', 1, 'crew', 'Crew', 0, '{}', '{}'),
(52, 'burgershot', 2, 'manager', 'Manager', 0, '{}', '{}'),
(53, 'burgershot', 3, 'boss', 'Owner', 0, '{}', '{}'),
(54, 'uwu', 0, 'trainee', 'Trainee', 0, '{}', '{}'),
(55, 'uwu', 1, 'barista', 'Barista', 0, '{}', '{}'),
(56, 'uwu', 2, 'manager', 'Manager', 0, '{}', '{}'),
(57, 'uwu', 3, 'boss', 'Owner', 0, '{}', '{}'),
(58, 'tacoshop', 0, 'trainee', 'Trainee', 0, '{}', '{}'),
(59, 'tacoshop', 1, 'cook', 'Cook', 0, '{}', '{}'),
(60, 'tacoshop', 2, 'manager', 'Manager', 0, '{}', '{}'),
(61, 'tacoshop', 3, 'boss', 'Owner', 0, '{}', '{}'),
(62, 'taco', 0, 'trainee', 'Trainee', 0, '{}', '{}'),
(63, 'taco', 1, 'cook', 'Cook', 0, '{}', '{}'),
(64, 'taco', 2, 'manager', 'Manager', 0, '{}', '{}'),
(65, 'taco', 3, 'boss', 'Owner', 0, '{}', '{}'),
(66, 'weedshop', 0, 'trimmer', 'Trimmer', 0, '{}', '{}'),
(67, 'weedshop', 1, 'budtender', 'Budtender', 0, '{}', '{}'),
(68, 'weedshop', 2, 'manager', 'Manager', 0, '{}', '{}'),
(69, 'weedshop', 3, 'boss', 'Owner', 0, '{}', '{}'),
(70, 'sheriff', 0, 'cadet', 'Deputy Cadet', 60000, '{}', '{}'),
(71, 'sheriff', 1, 'deputy', 'Deputy Sheriff', 65000, '{}', '{}'),
(72, 'sheriff', 2, 'senior', 'Senior Deputy', 70000, '{}', '{}'),
(73, 'sheriff', 3, 'sergeant', 'Sergeant', 75000, '{}', '{}'),
(74, 'sheriff', 4, 'lieutenant', 'Lieutenant', 80000, '{}', '{}'),
(75, 'sheriff', 5, 'captain', 'Captain', 100000, '{}', '{}'),
(76, 'sheriff', 6, 'boss', 'Sheriff', 120000, '{}', '{}'),
(77, 'offsheriff', 0, 'cadet', 'Deputy Cadet', 0, '{}', '{}'),
(78, 'offsheriff', 1, 'deputy', 'Deputy Sheriff', 0, '{}', '{}'),
(79, 'offsheriff', 2, 'senior', 'Senior Deputy', 0, '{}', '{}'),
(80, 'offsheriff', 3, 'sergeant', 'Sergeant', 0, '{}', '{}'),
(81, 'offsheriff', 4, 'lieutenant', 'Lieutenant', 0, '{}', '{}'),
(82, 'offsheriff', 5, 'captain', 'Captain', 0, '{}', '{}'),
(83, 'offsheriff', 6, 'boss', 'Sheriff', 0, '{}', '{}'),
(84, 'doj', 0, 'clerk', 'Clerk', 55000, '{}', '{}'),
(85, 'doj', 1, 'paralegal', 'Paralegal', 60000, '{}', '{}'),
(86, 'doj', 2, 'attorney', 'Attorney', 70000, '{}', '{}'),
(87, 'doj', 3, 'prosecutor', 'Prosecutor', 80000, '{}', '{}'),
(88, 'doj', 4, 'judge', 'Judge', 90000, '{}', '{}'),
(89, 'doj', 5, 'boss', 'Director', 100000, '{}', '{}'),
(90, 'offdoj', 0, 'clerk', 'Clerk', 0, '{}', '{}'),
(91, 'offdoj', 1, 'paralegal', 'Paralegal', 0, '{}', '{}'),
(92, 'offdoj', 2, 'attorney', 'Attorney', 0, '{}', '{}'),
(93, 'offdoj', 3, 'prosecutor', 'Prosecutor', 0, '{}', '{}'),
(94, 'offdoj', 4, 'judge', 'Judge', 0, '{}', '{}'),
(95, 'offdoj', 5, 'boss', 'Director', 0, '{}', '{}'),
(96, 'pambulance', 0, 'intern', 'Intern', 65000, '{}', '{}'),
(97, 'pambulance', 1, 'nurse', 'Nurse', 70000, '{}', '{}'),
(98, 'pambulance', 2, 'head_nurse', 'Head Nurse', 75000, '{}', '{}'),
(99, 'pambulance', 3, 'resident_doctor', 'Resident Doctor', 80000, '{}', '{}'),
(100, 'pambulance', 4, 'senior_resident_doctor', 'Senior Resident Doctor', 85000, '{}', '{}'),
(101, 'pambulance', 5, 'assistant_director', 'Assistant Director', 90000, '{}', '{}'),
(102, 'pambulance', 6, 'boss', 'Medical Director', 100000, '{}', '{}'),
(103, 'offpambulance', 0, 'intern', 'Intern', 0, '{}', '{}'),
(104, 'offpambulance', 1, 'nurse', 'Nurse', 0, '{}', '{}'),
(105, 'offpambulance', 2, 'head_nurse', 'Head Nurse', 0, '{}', '{}'),
(106, 'offpambulance', 3, 'resident_doctor', 'Resident Doctor', 0, '{}', '{}'),
(107, 'offpambulance', 4, 'senior_resident_doctor', 'Senior Resident Doctor', 0, '{}', '{}'),
(108, 'offpambulance', 5, 'assistant_director', 'Assistant Director', 0, '{}', '{}'),
(109, 'offpambulance', 6, 'boss', 'Medical Director', 0, '{}', '{}');

-- --------------------------------------------------------
-- Table structure & data for table `licenses`
-- --------------------------------------------------------
CREATE TABLE `licenses` (
  `type` varchar(60) NOT NULL,
  `label` varchar(60) NOT NULL
) ENGINE=InnoDB;

INSERT INTO `licenses` (`type`, `label`) VALUES
('dmv', 'Driving Permit'),
('drive', 'Drivers License'),
('drive_bike', 'Motorcycle License'),
('drive_truck', 'Commercial Drivers License'),
('weed_processing', 'Weed Processing License'),
('boat', 'Boat License');

-- --------------------------------------------------------
-- Table structure for table `owned_vehicles`
-- --------------------------------------------------------
CREATE TABLE `owned_vehicles` (
  `owner` varchar(60) DEFAULT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  `parking` VARCHAR(60) DEFAULT NULL,
  `pound` VARCHAR(60) DEFAULT NULL
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------
CREATE TABLE `users` (
  `identifier` varchar(60) NOT NULL,
  `ssn` VARCHAR(15) NULL DEFAULT NULL,
  `accounts` longtext DEFAULT NULL,
  `group` varchar(50) DEFAULT 'user',
  `inventory` longtext DEFAULT NULL,
  `job` varchar(20) DEFAULT 'unemployed',
  `job_grade` int(11) DEFAULT 0,
  `gang` varchar(50) DEFAULT 'none',
  `gang_grade` int(11) DEFAULT 0,
  `loadout` longtext DEFAULT NULL,
  `metadata` LONGTEXT NULL DEFAULT NULL,
  `position` longtext NULL DEFAULT NULL,
  `firstname` varchar(16) DEFAULT NULL,
  `lastname` varchar(16) DEFAULT NULL,
  `dateofbirth` varchar(10) DEFAULT NULL,
  `sex` varchar(1) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `skin` longtext DEFAULT NULL,
  `status` longtext DEFAULT NULL,
  `is_dead` tinyint(1) DEFAULT 0,
  `id` int(11) NOT NULL,
  `disabled` TINYINT(1) NULL DEFAULT '0',
  `last_property` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_seen` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `phone_number` VARCHAR(20) DEFAULT NULL
) ENGINE=InnoDB;

ALTER TABLE `users` ADD COLUMN `pincode` INT NULL;

-- --------------------------------------------------------
-- Table structure for table `user_licenses`
-- --------------------------------------------------------
CREATE TABLE `user_licenses` (
  `id` int(11) NOT NULL,
  `type` varchar(60) NOT NULL,
  `owner` varchar(60) NOT NULL
) ENGINE=InnoDB;

-- --------------------------------------------------------
-- Table structure & data for table `vehicles`
-- --------------------------------------------------------
CREATE TABLE `vehicles` (
  `name` varchar(60) NOT NULL,
  `model` varchar(60) NOT NULL,
  `price` int(11) NOT NULL,
  `category` varchar(60) DEFAULT NULL
) ENGINE=InnoDB;

INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES
('Adder', 'adder', 900000, 'super'),
('Akuma', 'AKUMA', 7500, 'motorcycles'),
('Alpha', 'alpha', 60000, 'sports'),
('Ardent', 'ardent', 1150000, 'sportsclassics'),
('Asea', 'asea', 5500, 'sedans'),
('Autarch', 'autarch', 1955000, 'super'),
('Avarus', 'avarus', 18000, 'motorcycles'),
('Bagger', 'bagger', 13500, 'motorcycles'),
('Baller', 'baller2', 40000, 'suvs'),
('Baller Sport', 'baller3', 60000, 'suvs'),
('Banshee', 'banshee', 70000, 'sports'),
('Banshee 900R', 'banshee2', 255000, 'super'),
('Bati 801', 'bati', 12000, 'motorcycles'),
('Bati 801RR', 'bati2', 19000, 'motorcycles'),
('Bestia GTS', 'bestiagts', 55000, 'sports'),
('BF400', 'bf400', 6500, 'motorcycles'),
('Bf Injection', 'bfinjection', 16000, 'offroad'),
('Bifta', 'bifta', 12000, 'offroad'),
('Bison', 'bison', 45000, 'vans'),
('Blade', 'blade', 15000, 'muscle'),
('Blazer', 'blazer', 6500, 'offroad'),
('Blazer Sport', 'blazer4', 8500, 'offroad'),
('blazer5', 'blazer5', 1755600, 'offroad'),
('Blista', 'blista', 8000, 'compacts'),
('BMX (velo)', 'bmx', 160, 'motorcycles'),
('Bobcat XL', 'bobcatxl', 32000, 'vans'),
('Brawler', 'brawler', 45000, 'offroad'),
('Brioso R/A', 'brioso', 18000, 'compacts'),
('Btype', 'btype', 62000, 'sportsclassics'),
('Btype Hotroad', 'btype2', 155000, 'sportsclassics'),
('Btype Luxe', 'btype3', 85000, 'sportsclassics'),
('Buccaneer', 'buccaneer', 18000, 'muscle'),
('Buccaneer Rider', 'buccaneer2', 24000, 'muscle'),
('Buffalo', 'buffalo', 12000, 'sports'),
('Buffalo S', 'buffalo2', 20000, 'sports'),
('Bullet', 'bullet', 90000, 'super'),
('Burrito', 'burrito3', 19000, 'vans'),
('Camper', 'camper', 42000, 'vans'),
('Carbonizzare', 'carbonizzare', 75000, 'sports'),
('Carbon RS', 'carbonrs', 18000, 'motorcycles'),
('Casco', 'casco', 30000, 'sportsclassics'),
('Cavalcade', 'cavalcade2', 55000, 'suvs'),
('Cheetah', 'cheetah', 375000, 'super'),
('Chimera', 'chimera', 38000, 'motorcycles'),
('Chino', 'chino', 15000, 'muscle'),
('Chino Luxe', 'chino2', 19000, 'muscle'),
('Cliffhanger', 'cliffhanger', 9500, 'motorcycles'),
('Cognoscenti Cabrio', 'cogcabrio', 55000, 'coupes'),
('Cognoscenti', 'cognoscenti', 55000, 'sedans'),
('Comet', 'comet2', 65000, 'sports'),
('Comet SR', 'comet5', 1145000, 'sports'),
('Contender', 'contender', 70000, 'suvs'),
('Coquette', 'coquette', 65000, 'sports'),
('Coquette Classic', 'coquette2', 40000, 'sportsclassics'),
('Coquette BlackFin', 'coquette3', 55000, 'muscle'),
('Cruiser (velo)', 'cruiser', 510, 'motorcycles'),
('Cyclone', 'cyclone', 1890000, 'super'),
('Daemon', 'daemon', 11500, 'motorcycles'),
('Daemon High', 'daemon2', 13500, 'motorcycles'),
('Defiler', 'defiler', 9800, 'motorcycles'),
('Deluxo', 'deluxo', 4721500, 'sportsclassics'),
('Dominator', 'dominator', 35000, 'muscle'),
('Double T', 'double', 28000, 'motorcycles'),
('Dubsta', 'dubsta', 45000, 'suvs'),
('Dubsta Luxuary', 'dubsta2', 60000, 'suvs'),
('Bubsta 6x6', 'dubsta3', 120000, 'offroad'),
('Dukes', 'dukes', 28000, 'muscle'),
('Dune Buggy', 'dune', 8000, 'offroad'),
('Elegy', 'elegy2', 38500, 'sports'),
('Emperor', 'emperor', 8500, 'sedans'),
('Enduro', 'enduro', 5500, 'motorcycles'),
('Entity XF', 'entityxf', 425000, 'super'),
('Esskey', 'esskey', 4200, 'motorcycles'),
('Exemplar', 'exemplar', 32000, 'coupes'),
('F620', 'f620', 40000, 'coupes'),
('Faction', 'faction', 20000, 'muscle'),
('Faction Rider', 'faction2', 30000, 'muscle'),
('Faction XL', 'faction3', 40000, 'muscle'),
('Faggio', 'faggio', 1900, 'motorcycles'),
('Vespa', 'faggio2', 2800, 'motorcycles'),
('Felon', 'felon', 42000, 'coupes'),
('Felon GT', 'felon2', 55000, 'coupes'),
('Feltzer', 'feltzer2', 55000, 'sports'),
('Stirling GT', 'feltzer3', 65000, 'sportsclassics'),
('Fixter (velo)', 'fixter', 225, 'motorcycles'),
('FMJ', 'fmj', 185000, 'super'),
('Fhantom', 'fq2', 17000, 'suvs'),
('Fugitive', 'fugitive', 12000, 'sedans'),
('Furore GT', 'furoregt', 45000, 'sports'),
('Fusilade', 'fusilade', 40000, 'sports'),
('Gargoyle', 'gargoyle', 16500, 'motorcycles'),
('Gauntlet', 'gauntlet', 30000, 'muscle'),
('Gang Burrito', 'gburrito', 45000, 'vans'),
('Burrito', 'gburrito2', 29000, 'vans'),
('Glendale', 'glendale', 6500, 'sedans'),
('Grabger', 'granger', 50000, 'suvs'),
('Gresley', 'gresley', 47500, 'suvs'),
('GT 500', 'gt500', 785000, 'sportsclassics'),
('Guardian', 'guardian', 45000, 'offroad'),
('Hakuchou', 'hakuchou', 31000, 'motorcycles'),
('Hakuchou Sport', 'hakuchou2', 55000, 'motorcycles'),
('Hermes', 'hermes', 535000, 'muscle'),
('Hexer', 'hexer', 12000, 'motorcycles'),
('Hotknife', 'hotknife', 125000, 'muscle'),
('Huntley S', 'huntley', 40000, 'suvs'),
('Hustler', 'hustler', 625000, 'muscle'),
('Infernus', 'infernus', 180000, 'super'),
('Innovation', 'innovation', 23500, 'motorcycles'),
('Intruder', 'intruder', 7500, 'sedans'),
('Issi', 'issi2', 10000, 'compacts'),
('Jackal', 'jackal', 38000, 'coupes'),
('Jester', 'jester', 65000, 'sports'),
('Jester(Racecar)', 'jester2', 135000, 'sports'),
('Journey', 'journey', 6500, 'vans'),
('Kamacho', 'kamacho', 345000, 'offroad'),
('Khamelion', 'khamelion', 38000, 'sports'),
('Kuruma', 'kuruma', 30000, 'sports'),
('Landstalker', 'landstalker', 35000, 'suvs'),
('RE-7B', 'le7b', 325000, 'super'),
('Lynx', 'lynx', 40000, 'sports'),
('Mamba', 'mamba', 70000, 'sports'),
('Manana', 'manana', 12800, 'sportsclassics'),
('Manchez', 'manchez', 5300, 'motorcycles'),
('Massacro', 'massacro', 65000, 'sports'),
('Massacro(Racecar)', 'massacro2', 130000, 'sports'),
('Mesa', 'mesa', 16000, 'suvs'),
('Mesa Trail', 'mesa3', 40000, 'suvs'),
('Minivan', 'minivan', 13000, 'vans'),
('Monroe', 'monroe', 55000, 'sportsclassics'),
('The Liberator', 'monster', 210000, 'offroad'),
('Moonbeam', 'moonbeam', 18000, 'vans'),
('Moonbeam Rider', 'moonbeam2', 35000, 'vans'),
('Nemesis', 'nemesis', 5800, 'motorcycles'),
('Neon', 'neon', 1500000, 'sports'),
('Nightblade', 'nightblade', 35000, 'motorcycles'),
('Nightshade', 'nightshade', 65000, 'muscle'),
('9F', 'ninef', 65000, 'sports'),
('9F Cabrio', 'ninef2', 80000, 'sports'),
('Omnis', 'omnis', 35000, 'sports'),
('Oppressor', 'oppressor', 3524500, 'super'),
('Oracle XS', 'oracle2', 35000, 'coupes'),
('Osiris', 'osiris', 160000, 'super'),
('Panto', 'panto', 10000, 'compacts'),
('Paradise', 'paradise', 19000, 'vans'),
('Pariah', 'pariah', 1420000, 'sports'),
('Patriot', 'patriot', 55000, 'suvs'),
('PCJ-600', 'pcj', 6200, 'motorcycles'),
('Penumbra', 'penumbra', 28000, 'sports'),
('Pfister', 'pfister811', 85000, 'super'),
('Phoenix', 'phoenix', 12500, 'muscle'),
('Picador', 'picador', 18000, 'muscle'),
('Pigalle', 'pigalle', 20000, 'sportsclassics'),
('Prairie', 'prairie', 12000, 'compacts'),
('Premier', 'premier', 8000, 'sedans'),
('Primo Custom', 'primo2', 14000, 'sedans'),
('X80 Proto', 'prototipo', 2500000, 'super'),
('Radius', 'radi', 29000, 'suvs'),
('raiden', 'raiden', 1375000, 'sports'),
('Rapid GT', 'rapidgt', 35000, 'sports'),
('Rapid GT Convertible', 'rapidgt2', 45000, 'sports'),
('Rapid GT3', 'rapidgt3', 885000, 'sportsclassics'),
('Reaper', 'reaper', 150000, 'super'),
('Rebel', 'rebel2', 35000, 'offroad'),
('Regina', 'regina', 5000, 'sedans'),
('Retinue', 'retinue', 615000, 'sportsclassics'),
('Revolter', 'revolter', 1610000, 'sports'),
('riata', 'riata', 380000, 'offroad'),
('Rocoto', 'rocoto', 45000, 'suvs'),
('Ruffian', 'ruffian', 6800, 'motorcycles'),
('Ruiner 2', 'ruiner2', 5745600, 'muscle'),
('Rumpo', 'rumpo', 15000, 'vans'),
('Rumpo Trail', 'rumpo3', 19500, 'vans'),
('Sabre Turbo', 'sabregt', 20000, 'muscle'),
('Sabre GT', 'sabregt2', 25000, 'muscle'),
('Sanchez', 'sanchez', 5300, 'motorcycles'),
('Sanchez Sport', 'sanchez2', 5300, 'motorcycles'),
('Sanctus', 'sanctus', 25000, 'motorcycles'),
('Sandking', 'sandking', 55000, 'offroad'),
('Savestra', 'savestra', 990000, 'sportsclassics'),
('SC 1', 'sc1', 1603000, 'super'),
('Schafter', 'schafter2', 25000, 'sedans'),
('Schafter V12', 'schafter3', 50000, 'sports'),
('Scorcher (velo)', 'scorcher', 280, 'motorcycles'),
('Seminole', 'seminole', 25000, 'suvs'),
('Sentinel', 'sentinel', 32000, 'coupes'),
('Sentinel XS', 'sentinel2', 40000, 'coupes'),
('Sentinel3', 'sentinel3', 650000, 'sports'),
('Seven 70', 'seven70', 39500, 'sports'),
('ETR1', 'sheava', 220000, 'super'),
('Shotaro Concept', 'shotaro', 320000, 'motorcycles'),
('Slam Van', 'slamvan3', 11500, 'muscle'),
('Sovereign', 'sovereign', 22000, 'motorcycles'),
('Stinger', 'stinger', 80000, 'sportsclassics'),
('Stinger GT', 'stingergt', 75000, 'sportsclassics'),
('Streiter', 'streiter', 500000, 'sports'),
('Stretch', 'stretch', 90000, 'sedans'),
('Stromberg', 'stromberg', 3185350, 'sports'),
('Sultan', 'sultan', 15000, 'sports'),
('Sultan RS', 'sultanrs', 65000, 'super'),
('Super Diamond', 'superd', 130000, 'sedans'),
('Surano', 'surano', 50000, 'sports'),
('Surfer', 'surfer', 12000, 'vans'),
('T20', 't20', 300000, 'super'),
('Tailgater', 'tailgater', 30000, 'sedans'),
('Tampa', 'tampa', 16000, 'muscle'),
('Drift Tampa', 'tampa2', 80000, 'sports'),
('Thrust', 'thrust', 24000, 'motorcycles'),
('Tri bike (velo)', 'tribike3', 520, 'motorcycles'),
('Trophy Truck', 'trophytruck', 60000, 'offroad'),
('Trophy Truck Limited', 'trophytruck2', 80000, 'offroad'),
('Tropos', 'tropos', 40000, 'sports'),
('Turismo R', 'turismor', 350000, 'super'),
('Tyrus', 'tyrus', 600000, 'super'),
('Vacca', 'vacca', 120000, 'super'),
('Vader', 'vader', 7200, 'motorcycles'),
('Verlierer', 'verlierer2', 70000, 'sports'),
('Vigero', 'vigero', 12500, 'muscle'),
('Virgo', 'virgo', 14000, 'muscle'),
('Viseris', 'viseris', 875000, 'sportsclassics'),
('Visione', 'visione', 2250000, 'super'),
('Voltic', 'voltic', 90000, 'super'),
('Voltic 2', 'voltic2', 3830400, 'super'),
('Voodoo', 'voodoo', 7200, 'muscle'),
('Vortex', 'vortex', 9800, 'motorcycles'),
('Warrener', 'warrener', 4000, 'sedans'),
('Washington', 'washington', 9000, 'sedans'),
('Windsor', 'windsor', 95000, 'coupes'),
('Windsor Drop', 'windsor2', 125000, 'coupes'),
('Woflsbane', 'wolfsbane', 9000, 'motorcycles'),
('XLS', 'xls', 32000, 'suvs'),
('Yosemite', 'yosemite', 485000, 'muscle'),
('Youga', 'youga', 10800, 'vans'),
('Youga Luxuary', 'youga2', 14500, 'vans'),
('Z190', 'z190', 900000, 'sportsclassics'),
('Zentorno', 'zentorno', 1500000, 'super'),
('Zion', 'zion', 36000, 'coupes'),
('Zion Cabrio', 'zion2', 45000, 'coupes'),
('Zombie', 'zombiea', 9500, 'motorcycles'),
('Zombie Luxuary', 'zombieb', 12000, 'motorcycles'),
('Z-Type', 'ztype', 220000, 'sportsclassics');

-- --------------------------------------------------------
-- Table structure & data for table `vehicle_categories`
-- --------------------------------------------------------
CREATE TABLE `vehicle_categories` (
  `name` varchar(60) NOT NULL,
  `label` varchar(60) NOT NULL
) ENGINE=InnoDB;

INSERT INTO `vehicle_categories` (`name`, `label`) VALUES
('compacts', 'Compacts'),
('coupes', 'CoupÃ©s'),
('motorcycles', 'Motos'),
('muscle', 'Muscle'),
('offroad', 'Off Road'),
('sedans', 'Sedans'),
('sports', 'Sports'),
('sportsclassics', 'Sports Classics'),
('super', 'Super'),
('suvs', 'SUVs'),
('vans', 'Vans');

-- --------------------------------------------------------
-- Indexes for Table Definitions
-- --------------------------------------------------------
ALTER TABLE `items`
  ADD PRIMARY KEY (`name`);

ALTER TABLE `jobs`
  ADD PRIMARY KEY (`name`);

ALTER TABLE `job_grades`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `licenses`
  ADD PRIMARY KEY (`type`);

ALTER TABLE `owned_vehicles`
  ADD PRIMARY KEY (`plate`),
  ADD KEY `esx_owned_vehicles_owner` (`owner`);

ALTER TABLE `users`
  ADD PRIMARY KEY (`identifier`),
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `unique_ssn` (`ssn`);

ALTER TABLE `user_licenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `esx_user_licenses_owner` (`owner`);

ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`model`);

ALTER TABLE `vehicle_categories`
  ADD PRIMARY KEY (`name`);

-- --------------------------------------------------------
-- AUTO_INCREMENT Definitions
-- --------------------------------------------------------
ALTER TABLE `job_grades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

ALTER TABLE `user_licenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

-- --------------------------------------------------------
-- Table structure for table `multicharacter_slots`
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `multicharacter_slots` (
  `identifier` varchar(60) NOT NULL,
  `slots` int(11) NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `pvp_stats` (
  `identifier` varchar(60) NOT NULL,
  `name` varchar(100) NOT NULL DEFAULT '',
  `kills` int(11) NOT NULL DEFAULT 0,
  `deaths` int(11) NOT NULL DEFAULT 0,
  `th` int(11) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Gang system (kodebykarl-gangsystem)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gang_members` (
  `identifier` varchar(100) NOT NULL,
  `gang` varchar(50) NOT NULL,
  `grade` int(11) NOT NULL DEFAULT 0,
  `name` varchar(100) NOT NULL,
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_seen` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

