-- Police Dealership Installation SQL for jg-dealerships-v2

INSERT INTO `dealership_locations` (
  `id`,
  `name`,
  `type`,
  `disabled`,
  `job_name`,
  `balance`,
  `showroom_coords`,
  `purchase_vehicle_coords`,
  `test_drive_coords`,
  `categories`,
  `camera_data`,
  `enable_purchase`,
  `enable_finance`,
  `enable_test_drive`,
  `enable_sell_vehicle`,
  `showroom_job_whitelist`,
  `society_purchase_job_whitelist`,
  `payment_methods`
) VALUES (
  'police_dealership',
  'Police Dealership',
  'self-service',
  0,
  'police',
  0,
  '{"x": 463.9792, "y": -1019.6293, "z": 28.1011, "h": 94.5021, "size": 3.0}',
  '{"x": 435.8250, "y": -1022.2808, "z": 28.6763, "h": 98.7247}',
  '{"x": 435.8250, "y": -1022.2808, "z": 28.6763, "h": 98.7247}',
  '["emergency", "police"]',
  '{"name": "Car", "coords": {"x": -146.6166, "y": -596.6301, "z": 166.0, "h": 270.0}, "positions": [5.0, 8.0, 12.0, 8.0]}',
  1,
  0,
  1,
  0,
  '["police"]',
  '["police"]',
  '["bank", "cash"]'
) ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `showroom_coords` = VALUES(`showroom_coords`),
  `purchase_vehicle_coords` = VALUES(`purchase_vehicle_coords`),
  `categories` = VALUES(`categories`),
  `showroom_job_whitelist` = VALUES(`showroom_job_whitelist`),
  `society_purchase_job_whitelist` = VALUES(`society_purchase_job_whitelist`);

-- Vehicles Definition
INSERT INTO `dealership_vehicles` (`spawn_code`, `brand`, `model`, `category`, `price`, `unlimited_stock`) VALUES
  ('oycdefenderp', 'Police', 'Defender PD', 'emergency', 75000, 1),
  ('polgs350', 'Police', 'Lexus GS350 PD', 'emergency', 60000, 1),
  ('pranger', 'Police', 'Police Ranger', 'emergency', 50000, 1)
ON DUPLICATE KEY UPDATE
  `brand` = VALUES(`brand`),
  `model` = VALUES(`model`),
  `category` = VALUES(`category`),
  `price` = VALUES(`price`);

-- Dealership Stock
INSERT INTO `dealership_stock` (`dealership`, `vehicle`, `stock`, `price`) VALUES
  ('police_dealership', 'oycdefenderp', 999, 75000),
  ('police_dealership', 'polgs350', 999, 60000),
  ('police_dealership', 'pranger', 999, 50000)
ON DUPLICATE KEY UPDATE
  `stock` = VALUES(`stock`),
  `price` = VALUES(`price`);
