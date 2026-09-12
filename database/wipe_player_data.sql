-- ============================================================
-- GrimCity — PLAYER DATA WIPE (official launch reset)
-- Keeps jobs, items, vehicle catalog, dealership stock, doors.
-- Wipes characters, cars, freecars, inventory, VIP, phone, etc.
-- ============================================================
-- Run via RESET_PLAYER_DATA.bat  OR:
--   mysql -uroot grimcity < database/wipe_player_data.sql
-- STOP FXServer before running.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

-- ---------- Core characters / accounts ----------
TRUNCATE TABLE `users`;
TRUNCATE TABLE `user_licenses`;
TRUNCATE TABLE `user_groups`;
TRUNCATE TABLE `multicharacter_slots`;
TRUNCATE TABLE `player_multijobs`;

-- ---------- Vehicles / freecars / garage ----------
TRUNCATE TABLE `owned_vehicles`;
TRUNCATE TABLE `player_priv_garages`;
TRUNCATE TABLE `cfx-keydi-betacars`;
TRUNCATE TABLE `cfx-keydi-playtimereward`;
TRUNCATE TABLE `cfx-keydi-newplayerkit`;
TRUNCATE TABLE `kodebykarl_projectcars`;
TRUNCATE TABLE `mechanic_vehicledata`;

-- ---------- Appearance ----------
TRUNCATE TABLE `playerskins`;
TRUNCATE TABLE `player_outfits`;
TRUNCATE TABLE `player_outfit_codes`;
TRUNCATE TABLE `management_outfits`;

-- ---------- Inventory / locks ----------
TRUNCATE TABLE `ox_inventory`;
TRUNCATE TABLE `keydi_locks`;

-- ---------- Economy / VIP / playtime shop ----------
TRUNCATE TABLE `grim_playtime_coins`;
TRUNCATE TABLE `grim_vip`;
TRUNCATE TABLE `cfx-keydi-banking-pins`;
TRUNCATE TABLE `cfx-keydi-transactions`;
TRUNCATE TABLE `keydi_invoices`;

-- Reset society money (keep account rows)
UPDATE `cfx_society_accounts` SET `balance` = 0 WHERE 1=1;
TRUNCATE TABLE `cfx_society_ledger`;

-- ---------- Phone / regions / parties / leaderboards ----------
TRUNCATE TABLE `grim_phone_contacts`;
TRUNCATE TABLE `grim_phone_messages`;
TRUNCATE TABLE `grim_player_regions`;
TRUNCATE TABLE `grim_parties`;
TRUNCATE TABLE `grim_party_members`;
TRUNCATE TABLE `grim_lb_players`;
TRUNCATE TABLE `grim_lb_party`;
TRUNCATE TABLE `grim_lb_traphouse`;
TRUNCATE TABLE `grim_lb_turfwar`;

-- ---------- Gangs / PVP / prison / comserv ----------
TRUNCATE TABLE `gang_members`;
TRUNCATE TABLE `gang_discord_map`;
TRUNCATE TABLE `pvp_stats`;
TRUNCATE TABLE `xt_prison`;
TRUNCATE TABLE `xt_prison_items`;
TRUNCATE TABLE `cfx-keydi-comserv`;
TRUNCATE TABLE `cfx-keydi-comserv-restore`;

-- ---------- Jobs / MDT / documents / reports ----------
TRUNCATE TABLE `k5_documents`;
TRUNCATE TABLE `cfx-keydi-report`;
TRUNCATE TABLE `grim_mdt_cases`;
TRUNCATE TABLE `grim_ipad_dept_bolos`;
TRUNCATE TABLE `grim_ipad_dept_announcements`;
TRUNCATE TABLE `cfx_keydi_bed`;

-- ---------- University (player records) ----------
TRUNCATE TABLE `university_students`;
TRUNCATE TABLE `university_applications`;
TRUNCATE TABLE `university_teachers`;

-- ---------- Dealership / mechanic player activity ----------
TRUNCATE TABLE `dealership_sales`;
TRUNCATE TABLE `dealership_coupon_usage`;
TRUNCATE TABLE `dealership_employees`;
TRUNCATE TABLE `dealership_orders`;
TRUNCATE TABLE `mechanic_employees`;
TRUNCATE TABLE `mechanic_invoices`;
TRUNCATE TABLE `mechanic_orders`;
TRUNCATE TABLE `mechanic_servicing_history`;

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

-- Done. Catalog tables kept:
-- items, jobs, job_grades, licenses, vehicles, vehicle_categories,
-- dealership_locations/vehicles/stock/dispveh/coupons,
-- mechanic_data/settings, ox_doorlock, university_announcements,
-- k5_document_templates, grim_market_items
