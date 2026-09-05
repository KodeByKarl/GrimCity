-- ==========================================================
-- GrimCity Roleplay: Police & EMS Paycheck and Ranks Update
-- Execute this file in your MySQL database (HeidiSQL, phpMyAdmin, etc.)
-- ==========================================================

-- Clean up existing police and ambulance job grades
DELETE FROM `job_grades` WHERE `job_name` IN ('police', 'offpolice', 'ambulance', 'offambulance');

-- Insert updated police and EMS ranks with exact paychecks
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
-- POLICE (PD) - Paid every 30 minutes
('police', 0, 'cadet', 'Cadet', 60000, '{}', '{}'),
('police', 1, 'officer', 'Police Officer', 65000, '{}', '{}'),
('police', 2, 'senior', 'Senior Police Officer', 70000, '{}', '{}'),
('police', 3, 'captain', 'Captain', 75000, '{}', '{}'),
('police', 4, 'deputy', 'Deputy Chief', 80000, '{}', '{}'),
('police', 5, 'chief', 'Chief of Police', 100000, '{}', '{}'),
('police', 6, 'boss', 'Director', 120000, '{}', '{}'),

-- POLICE OFF-DUTY
('offpolice', 0, 'cadet', 'Cadet', 0, '{}', '{}'),
('offpolice', 1, 'officer', 'Police Officer', 0, '{}', '{}'),
('offpolice', 2, 'senior', 'Senior Police Officer', 0, '{}', '{}'),
('offpolice', 3, 'captain', 'Captain', 0, '{}', '{}'),
('offpolice', 4, 'deputy', 'Deputy Chief', 0, '{}', '{}'),
('offpolice', 5, 'chief', 'Chief of Police', 0, '{}', '{}'),
('offpolice', 6, 'boss', 'Director', 0, '{}', '{}'),

-- EMS - Paid every 30 minutes
('ambulance', 0, 'intern', 'Intern', 65000, '{}', '{}'),
('ambulance', 1, 'nurse', 'Nurse', 70000, '{}', '{}'),
('ambulance', 2, 'head_nurse', 'Head Nurse', 75000, '{}', '{}'),
('ambulance', 3, 'resident_doctor', 'Resident Doctor', 80000, '{}', '{}'),
('ambulance', 4, 'senior_resident_doctor', 'Senior Resident Doctor', 85000, '{}', '{}'),
('ambulance', 5, 'assistant_director', 'Assistant Director', 90000, '{}', '{}'),
('ambulance', 6, 'boss', 'Medical Director', 100000, '{}', '{}'),

-- EMS OFF-DUTY
('offambulance', 0, 'intern', 'Intern', 0, '{}', '{}'),
('offambulance', 1, 'nurse', 'Nurse', 0, '{}', '{}'),
('offambulance', 2, 'head_nurse', 'Head Nurse', 0, '{}', '{}'),
('offambulance', 3, 'resident_doctor', 'Resident Doctor', 0, '{}', '{}'),
('offambulance', 4, 'senior_resident_doctor', 'Senior Resident Doctor', 0, '{}', '{}'),
('offambulance', 5, 'assistant_director', 'Assistant Director', 0, '{}', '{}'),
('offambulance', 6, 'boss', 'Medical Director', 0, '{}', '{}');
