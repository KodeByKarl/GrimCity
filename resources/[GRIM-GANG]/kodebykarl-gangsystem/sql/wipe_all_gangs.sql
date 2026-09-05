-- Wipe all gang memberships / player gang fields.
-- Run once in HeidiSQL / phpMyAdmin after removing Config.Gangs.

DELETE FROM `gang_members`;

UPDATE `users`
SET `gang` = 'none',
    `gang_grade` = 0
WHERE `gang` IS NOT NULL
  AND `gang` <> 'none'
  AND `gang` <> '';

-- Optional: clear Discord role map if you use it
-- DELETE FROM `gang_discord_map`;
