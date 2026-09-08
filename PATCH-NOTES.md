# Grim City Patch Notes

**Latest version:** `v1.2.0`  
**Date:** September 6, 2026  
**Tag:** Major Update

---

## v1.2.0 — iPhone, Project Cars & Combat Movement

**September 6, 2026 · Major Update**

A big quality-of-life drop: a real phone, a full project-car build loop, stealth house robberies, and movement that finally feels right in a gunfight.

### New — Grim iPhone

- Grim iPhone companion shell with Dynamic Island, sitting at the **bottom-right** of your screen.
- Apps on launch: **Wallet**, **Market**, **Contacts**, **Messages**, and **Settings**.
- **Wallet** got a full dark-theme rework — bank and cash are easy to read, back button is visible again.
- **Market** now matches the Modules look. Sell **Orange**, **Wood**, and **Raw Meat** (autofarm / raven loot) with live prices. Choose **cash** or **bank** at the Market NPC.

### New — Project Cars

Build a wrecked chassis into a real garage car. Each vehicle uses **its own matching parts** (wheels, doors, engine, etc. are tagged to that car — Odyssey parts will not fit another model).

**How to finish one car**

1. Get a **Vehicle Shell** and **25 Car Blueprints**.
2. Place the shell, then install parts in order.
3. You **cannot drive it** until every part is on. When the last piece goes in, you get a finish notification and the car is yours.

**Build order**

| Step | Part | Notes |
| --- | --- | --- |
| 1 | Battery | Start here |
| 2 | Alternator | Needs battery |
| 3 | Radiator | Can go on anytime after the shell |
| 4 | Engine | Needs battery + alternator + radiator |
| 5 | Spark Plugs + Transmission | Both need the engine |
| 6 | Hood | Needs engine, spark plugs, and transmission |
| 7 | Doors (×4) | Front left / front right / rear left / rear right |
| 8 | Brakes (×4) | One per wheel corner |
| 9 | Wheels (×4) | Each wheel needs its matching brake first |

**Where to get parts**

- Playtime Shop (`F7`) now has a **Cars** tab for shells, blueprints, and project parts.
- Open a **Project Parts Box** for a full kit (progress bar, then the parts drop into your inventory).
- Part icons are cartoon-style with no black backgrounds, and they live in the **Cars** inventory category.

Current project vehicle: **Odyssey 2018**.

### New — House Robbery Stealth

- After you get inside, a **sound meter** tracks footsteps.
- Walk or run and the meter fills. **Crouch** to stay quiet.
- Fill it and you get detected.
- Successful run: **$50,000 dirty money** + **10–20 recycling materials** (rolled on the server).
- Small-store robberies no longer clutter the map. Bigger jobs show as normal (non-sticky) blips.
- Only **one major robbery** can be live at a time — it shows on the scoreboard so PD / Sheriff can respond.

### New — Loading Screen

- Custom Grim City loading screen with the city logo.
- Spotify-style player at the bottom: play, pause, and a music bar.

### Combat — Flee + Crouch

- **Flee** walking styles now actually apply to your character (all Flee variants).
- Intended loop:
  - **Standing + Flee** = Flee run (speed).
  - **Aim while crouched** = crouched shooting.
  - **Sprint again** = back to Flee run.
- No more “hunched run” crouch. Crouch is a real crouch. Flee stays the run.

### Quality of Life

- **6 hours** playtime (txAdmin / scoreboard time) → free **Sunrise1** delivered to your garage. Ped is at Legion.
- Garage no longer resets fuel, engine, and body to 100 when you take a car out.
- Orange autofarm markers now show correctly on **Region 1**.
- Health no longer auto-regens when you drop below 50%.
- Playtime Shop Cars tab pagination no longer overlaps item cards.
- Dead players drop pocket items on STL / quit (bags stay as designed).

---

## v1.1.0 — Leaderboards, Campus Portal & Business Boss

**September 6, 2026 · Major Update**

- **Live iPad Leaderboards**
  - Turf War — gang claim wins
  - Trap House — kills / deaths / KDA
  - PvP arena — arena-only K/D
  - Party — team K/D / KDA
  - Citywide Top Player
- **University Campus Portal** — brighter tablet UI, avatar profile dropdown, readable text in-game.
- **iPad Business Boss** — society funds, sales chart, hire / fire / grades, invoice logs for UWU, EM, Taco, MBOTG, and Burgershot bosses.
- World cashier / boss menus removed. Management lives on the iPad.
- Business crafting is server-owned (recipes cannot be faked from the client).

---

## v1.0.31 — PD / EMS Shops & Melee Decay

**September 5, 2026 · Feature**

- Police store, stashes, evidence locker, firing-squad coins, and clothing items configured.
- EMS / PD inventory shops, stashes, custom items, and grinding activities updated.
- All melee weapons last **3 days** (4320 minutes) with durability decay.
- Chat wrapping no longer stretches module cards.

---

## v1.0.30 — iPad, Regions, Gangs & World Events

**September 5, 2026 · Major Update**

### iPad

- Apple-style iPad shell with Dynamic Island.
- Apps: Party, PvP, Leaderboards, Economy, Police Boss / MDT, University, Organization, and more.
- **Party** — create a 4-man team, public list, optional password for friends-only.
- **PvP** — join from the iPad, one arena location, death screen then fast respawn.

### City Systems

- **Regions** — Farm / School / Turf split. Turf War and gang bases only exist on the combat regions.
- **Turf War** — gang-only claims, compact chat cards, white cylinder markers.
- **Trap House** — rotating redzones every 15 minutes with a clean top-center TextUI.
- **Gang System** — bases, stashes, claim car, crafting per gang, `/gang` as the single command. Organization app is the boss menu.
- **Airdrop** — inbound plane blip + drop location blip (no forced waypoint). Timers sit on the scoreboard with Trap House and Turf War.
- **Playtime Shop** — Grim Coins every 35 minutes online (+3 coins). Cartoon coin art.
- **VIP** — duration-based VIP from the Modules panel.
- **Autofarm HUD** — bag-full ETA while farming.
- **Damage indicators** — zone-colored hits.
- **Death screen** — clone preview of you and the killer, then a spawn timer, then pick a spawn area.

### Rules that actually stick

- Trunk is **owner-only**.
- `/doors` removed.
- Seatbelt blocks exiting the vehicle.
- Staff groups stay saved in the database after relog.
- Scoreboard world-event row shows the **active** Airdrop / Trap House / Turf War location and remaining time.

---

## Playtime Shop (quick recap)

| | |
| --- | --- |
| Open | `F7` or `/playtimeshop` |
| Coins | +3 Grim Coins every 35 minutes online |
| Items tab | Bandage, lockpick, armor, repair kit, phone, radio, water, burger |
| Cars tab | Shell, parts box, blueprints, and all project-car parts |

---

## Known loop (Project Cars)

You need **25 blueprints** before the shell can be placed. Parts must match the **same vehicle**. Mixing Odyssey wheels onto another project car will not work.

---

*Grim City Development · discord.gg/JWZ9YWPB*
