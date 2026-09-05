CREATE TABLE IF NOT EXISTS `grim_parties` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(32) NOT NULL,
    `leader_identifier` VARCHAR(72) NOT NULL,
    `password` VARCHAR(32) DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_grim_parties_leader` (`leader_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `grim_party_members` (
    `party_id` INT NOT NULL,
    `identifier` VARCHAR(72) NOT NULL,
    `name` VARCHAR(64) NOT NULL DEFAULT '',
    `is_leader` TINYINT(1) NOT NULL DEFAULT 0,
    `joined_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`),
    INDEX `idx_grim_party_members_party` (`party_id`),
    CONSTRAINT `fk_grim_party_members_party`
        FOREIGN KEY (`party_id`) REFERENCES `grim_parties` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
