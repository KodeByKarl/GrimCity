-- ==========================================================
-- GrimCity: Blaine County Sheriff (BCSO) jobs & grades
-- Run once on live DB. Also mirrored in seed_jobs_and_grades.sql
-- ==========================================================

INSERT INTO `jobs` (`name`, `label`, `type`, `whitelisted`) VALUES
('sheriff', 'Sheriff', 'leo', 1),
('offsheriff', 'Off-Duty Sheriff', 'leo', 0)
ON DUPLICATE KEY UPDATE
    `label` = VALUES(`label`),
    `type` = VALUES(`type`),
    `whitelisted` = VALUES(`whitelisted`);

DELETE FROM `job_grades` WHERE `job_name` IN ('sheriff', 'offsheriff');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
-- SHERIFF (on-duty) — 30-min state paycheck (same scale as PD)
('sheriff', 0, 'cadet', 'Deputy Cadet', 60000, '{}', '{}'),
('sheriff', 1, 'deputy', 'Deputy Sheriff', 65000, '{}', '{}'),
('sheriff', 2, 'senior', 'Senior Deputy', 70000, '{}', '{}'),
('sheriff', 3, 'sergeant', 'Sergeant', 75000, '{}', '{}'),
('sheriff', 4, 'lieutenant', 'Lieutenant', 80000, '{}', '{}'),
('sheriff', 5, 'captain', 'Captain', 100000, '{}', '{}'),
('sheriff', 6, 'boss', 'Sheriff', 120000, '{}', '{}'),

-- SHERIFF OFF-DUTY
('offsheriff', 0, 'cadet', 'Deputy Cadet', 0, '{}', '{}'),
('offsheriff', 1, 'deputy', 'Deputy Sheriff', 0, '{}', '{}'),
('offsheriff', 2, 'senior', 'Senior Deputy', 0, '{}', '{}'),
('offsheriff', 3, 'sergeant', 'Sergeant', 0, '{}', '{}'),
('offsheriff', 4, 'lieutenant', 'Lieutenant', 0, '{}', '{}'),
('offsheriff', 5, 'captain', 'Captain', 0, '{}', '{}'),
('offsheriff', 6, 'boss', 'Sheriff', 0, '{}', '{}');
