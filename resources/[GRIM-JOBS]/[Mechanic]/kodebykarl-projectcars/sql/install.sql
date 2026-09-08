CREATE TABLE IF NOT EXISTS `kodebykarl_projectcars` (
    `plate` varchar(12) NOT NULL,
    `owner` varchar(60) NOT NULL,
    `model` varchar(50) NOT NULL,
    `coord` longtext NOT NULL,
    `status` longtext NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`plate`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
