return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		weight = 100,
		description = 'Restores 50% health. Cannot revive.',
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = false, combat = false, car = false },
			usetime = 2500,
		},
		server = {
			export = 'ox_inventory.bandage'
		}
	},

	['gauze'] = {
		label = 'Medical Gauze',
		weight = 50,
		description = 'Sterile medical gauze wrap used to stop bleeding and dress wounds.',
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			disable = { move = false, combat = false, car = false },
			usetime = 2000,
		}
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
		stack = true,
		close = true,
		server = {
			exportRemove = true,
			export = 'ox_inventory.lockpick'
		}
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['police_vest'] = {
		label = 'Police Tactical Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['mastercard'] = {
		label = 'Fleeca Card',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
		stack = true,
		close = true,
		description = 'Twisted metal pulled from chopped vehicles.',
	},

	['car_door'] = {
		label = 'Car Door',
		weight = 2500,
		stack = true,
		close = true,
		description = 'A stripped vehicle door panel.',
	},

	['car_hood'] = {
		label = 'Car Hood',
		weight = 4000,
		stack = true,
		close = true,
		description = 'A detached vehicle hood.',
	},

	['car_wheel'] = {
		label = 'Car Wheel',
		weight = 1800,
		stack = true,
		close = true,
		description = 'A used tire and rim.',
	},

	['car_battery'] = {
		label = 'Car Battery',
		weight = 900,
		stack = true,
		close = true,
		description = 'A 12V vehicle battery.',
	},

	['car_alternator'] = {
		label = 'Alternator',
		weight = 700,
		stack = true,
		close = true,
		description = 'A salvaged vehicle alternator.',
	},

	['car_radiator'] = {
		label = 'Radiator',
		weight = 1200,
		stack = true,
		close = true,
		description = 'A vehicle cooling radiator.',
	},

	['car_engine_part'] = {
		label = 'Engine Part',
		weight = 1500,
		stack = true,
		close = true,
		description = 'A usable chunk of an engine block.',
	},

	['brake_pads'] = {
		label = 'Brake Pads',
		weight = 250,
		stack = true,
		close = true,
		description = 'A pair of used brake pads.',
	},

	['spark_plugs'] = {
		label = 'Spark Plugs',
		weight = 80,
		stack = true,
		close = true,
		description = 'Salvaged ignition spark plugs.',
	},

	["alive_chicken"] = {
		label = "Living chicken",
		weight = 1,
		stack = true,
		close = true,
	},

	["blowpipe"] = {
		label = "Blowtorch",
		weight = 2,
		stack = true,
		close = true,
	},

	["bread"] = {
		label = "Bread",
		weight = 1,
		stack = true,
		close = true,
	},

	["cannabis"] = {
		label = "Cannabis",
		weight = 3,
		stack = true,
		close = true,
	},

	["carokit"] = {
		label = "Body Kit",
		weight = 3,
		stack = true,
		close = true,
	},

	["carotool"] = {
		label = "Tools",
		weight = 2,
		stack = true,
		close = true,
	},

	["clothe"] = {
		label = "Cloth",
		weight = 1,
		stack = true,
		close = true,
	},

	["copper"] = {
		label = "Copper",
		weight = 1,
		stack = true,
		close = true,
	},

	["cutted_wood"] = {
		label = "Cut wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["diamond"] = {
		label = "Diamond",
		weight = 1,
		stack = true,
		close = true,
	},

	["essence"] = {
		label = "Gas",
		weight = 1,
		stack = true,
		close = true,
	},

	["fabric"] = {
		label = "Fabric",
		weight = 1,
		stack = true,
		close = true,
	},

	["fish"] = {
		label = "Fish",
		weight = 1,
		stack = true,
		close = true,
	},

	["fixkit"] = {
		label = "Repair Kit",
		weight = 3,
		stack = true,
		close = true,
	},

	["fixtool"] = {
		label = "Repair Tools",
		weight = 2,
		stack = true,
		close = true,
	},

	["gazbottle"] = {
		label = "Gas Bottle",
		weight = 2,
		stack = true,
		close = true,
	},

	["gold"] = {
		label = "Gold",
		weight = 1,
		stack = true,
		close = true,
	},

	["iron"] = {
		label = "Iron",
		weight = 1,
		stack = true,
		close = true,
	},

	["marijuana"] = {
		label = "Marijuana",
		weight = 2,
		stack = true,
		close = true,
	},

	["medikit"] = {
		label = "Medikit",
		weight = 250,
		stack = true,
		close = true,
		description = 'Use on a downed player with ox_target to revive them.',
		server = {
			export = 'ox_inventory.medikit'
		}
	},

	["medkit"] = {
		label = "Medkit",
		weight = 250,
		stack = true,
		close = true,
		description = 'Use on a downed player with ox_target to revive them.',
		client = {
			image = 'medikit.png'
		},
		server = {
			export = 'ox_inventory.medikit'
		}
	},

	["packaged_chicken"] = {
		label = "Chicken fillet",
		weight = 1,
		stack = true,
		close = true,
	},

	["packaged_plank"] = {
		label = "Packaged wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["petrol"] = {
		label = "Oil",
		weight = 1,
		stack = true,
		close = true,
	},

	["petrol_raffin"] = {
		label = "Processed oil",
		weight = 1,
		stack = true,
		close = true,
	},

	["slaughtered_chicken"] = {
		label = "Slaughtered chicken",
		weight = 1,
		stack = true,
		close = true,
	},

	["stone"] = {
		label = "Stone",
		weight = 1,
		stack = true,
		close = true,
	},

	["washed_stone"] = {
		label = "Washed stone",
		weight = 1,
		stack = true,
		close = true,
	},

	["wood"] = {
		label = "Wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["wool"] = {
		label = "Wool",
		weight = 1,
		stack = true,
		close = true,
	},

	['weed_bud'] = {
		label = 'Weed Bud',
		weight = 20,
		stack = true,
		close = true,
	},

	['packaged_weed'] = {
		label = 'Packaged Weed',
		weight = 25,
		stack = true,
		close = true,
	},

	['zipper_bag'] = {
		label = 'Zip-lock Bag',
		weight = 5,
		stack = true,
		close = true,
	},

	['rolling_paper'] = {
		label = 'Rolling Paper',
		weight = 2,
		stack = true,
		close = true,
	},

	['joint'] = {
		label = 'Joint',
		weight = 5,
		stack = true,
		close = true,
		consume = 1,
		allowArmed = true,
		client = {
			usetime = 5000,
			anim = { dict = 'amb@world_human_smoking@male@male_a@idle_a', clip = 'idle_a', flag = 49 },
			notification = 'You smoked a joint'
		},
		server = {
			export = 'ox_inventory.joint'
		}
	},


	['item_free_car'] = {
		label = 'New Player Vehicle',
		weight = 160,
		close = true,
		server = {
			exportRemove = true,
			export = 'ox_inventory.item_free_car'
		}
	},

	['item_beta_car'] = {
		label = 'Beta Vehicle Token',
		weight = 160,
		close = true,
		description = 'One-time beta reward vehicle (separate from new player free car).',
		server = {
			exportRemove = true,
			export = 'ox_inventory.item_beta_car'
		}
	},

	['welcome_kit'] = {
		label = 'Welcome Kit',
		weight = 1,
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 },
			usetime = 1500,
		},
		server = {
			exportRemove = true,
			export = 'ox_inventory.itemBoxes'
		}
	},

	['betabox'] = {
		label = 'Beta Box',
		weight = 1,
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 },
			usetime = 1500,
		},
		server = {
			exportRemove = true,
			export = 'ox_inventory.itemBoxes'
		}
	},

	['old_player_box'] = {
		label = 'Compensation Box',
		weight = 1,
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 },
			usetime = 1500,
		},
		server = {
			exportRemove = true,
			export = 'ox_inventory.itemBoxes'
		}
	},

	['ayuda_box'] = {
		label = 'Nightlife Box',
		weight = 1,
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 },
			usetime = 1500,
		},
		server = {
			exportRemove = true,
			export = 'ox_inventory.itemBoxes'
		}
	},

	['new_player_card'] = {
		label = 'New Player Card',
		degrade = 4320,
		decay = true,
		stack = false,
	},

	['reskin_card'] = {
		label = 'Reskin Card',
		stack = false,
		close = true,
		description = 'One-time card to fully change your ped, face, and appearance.',
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a' },
			usetime = 2500
		},
		server = {
			export = 'ox_inventory.reskin_card'
		}
	},

	['ems_medikit'] = {
		label = 'Medkit',
		weight = 100,
		description = 'EMS only. Use on a downed player with ox_target to revive.',
		server = {
			export = 'ox_inventory.ems_medikit'
		}
	},

	['gauze'] = {
		label = 'Gauze',
		weight = 100,
		description = 'Stops bleeding only.',
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			usetime = 2500,
		},
		server = {
			export = 'ox_inventory.gauze'
		}
	},

	['stresstabs'] = {
		label = 'Stresstabs',
		weight = 150,
		description = 'Reduces current stress by 50%.',
		degrade = 4320,
		decay = true,
		stack = true,
		consume = 1,
		allowArmed = true,
		client = {
			anim = { dict = 'mp_suicide', clip = 'pill_fp' },
			usetime = 3000
		},
		server = {
			export = 'ox_inventory.stresstabs'
		}
	},

	['stresstab'] = {
		label = 'Stresstab',
		weight = 150,
		description = 'Reduces current stress by 50%.',
		degrade = 4320,
		decay = true,
		stack = true,
		consume = 1,
		allowArmed = true,
		client = {
			image = 'stresstabs.png',
			anim = { dict = 'mp_suicide', clip = 'pill_fp' },
			usetime = 3000
		},
		server = {
			export = 'ox_inventory.stresstabs'
		}
	},

	['police_bandage'] = {
		label = 'Police Bandage',
		weight = 100,
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			usetime = 2500,
		},
		server = {
			export = 'ox_inventory.police_bandage'
		}
	},

	['police_gauze'] = {
		label = 'Police Gauze',
		weight = 100,
		allowArmed = true,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			usetime = 2500,
		},
		server = {
			export = 'ox_inventory.police_gauze'
		}
	},

	['police_sting'] = {
		label = 'Police Sting',
		weight = 50,
		allowArmed = true,
		client = {
			usetime = 1500,
		},
		server = {
			export = 'ox_inventory.police_sting'
		}
	},

	['police_kevlar'] = {
		label = 'Police Kevlar',
		weight = 2000,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500,
		},
		server = {
			export = 'ox_inventory.police_kevlar'
		}
	},

	['police_pill'] = {
		label = 'Police Pill',
		weight = 50,
		allowArmed = true,
		client = {
			anim = { dict = 'mp_suicide', clip = 'pill_fp' },
			usetime = 2500,
		},
		server = {
			export = 'ox_inventory.police_pill'
		}
	},

	['police_vest'] = {
		label = 'Police Vest',
		weight = 3000,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500,
		},
		server = {
			export = 'ox_inventory.police_vest'
		}
	},

	['police_vitamins'] = {
		label = 'Police Vitamins',
		weight = 100,
		description = 'Tactical vitamins: Cures bleeding, restores 100% health and full 100 armor.',
		stack = true,
		consume = 1,
		allowArmed = true,
		client = {
			image = 'police_vitamins.png',
			anim = { dict = 'mp_suicide', clip = 'pill_fp' },
			usetime = 2000,
		},
		server = {
			export = 'ox_inventory.police_vitamins'
		}
	},

	['police_drink'] = {
		label = 'Police Speed Drink',
		weight = 250,
		description = 'Tactical energy drink: Grants 2x sprint speed for 10 seconds.',
		stack = true,
		consume = 1,
		allowArmed = true,
		client = {
			image = 'police_drink.png',
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2000,
		},
		server = {
			export = 'ox_inventory.police_drink'
		}
	},

	['bulletproof'] = {
		label = 'Bulletproof Vest',
		weight = 5000,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 5000,
		},
		server = {
			export = 'ox_inventory.bulletproof'
		}
	},

	['bulletproof_25'] = {
		label = 'Bulletproof Vest (25%)',
		weight = 2000,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 4000,
		},
		server = {
			export = 'ox_inventory.bulletproof_25'
		}
	},

	['bulletproof_50'] = {
		label = 'Bulletproof Vest (50%)',
		weight = 3000,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 4500,
		},
		server = {
			export = 'ox_inventory.bulletproof_50'
		}
	},

	['bulletproof_75'] = {
		label = 'Bulletproof Vest (75%)',
		weight = 4000,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 5000,
		},
		server = {
			export = 'ox_inventory.bulletproof_75'
		}
	},

	['bulletproof_100'] = {
		label = 'Bulletproof Vest (100%)',
		weight = 5000,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 5500,
		},
		server = {
			export = 'ox_inventory.bulletproof_100'
		}
	},

	['half_vest'] = {
		label = 'Half Vest',
		weight = 2500,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500,
		},
		server = {
			export = 'ox_inventory.half_vest'
		}
	},

	['ammo-box1'] = {
		label = 'Ammo Box 9mm',
		weight = 200,
		stack = true,
		close = true,
		description = 'Contains 200x 9mm rounds',
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a' },
			usetime = 2500
		},
		server = {
			export = 'ox_inventory.ammo_box1'
		}
	},

	['ammo-box-smg'] = {
		label = 'Ammo Box SMG',
		weight = 200,
		stack = true,
		close = true,
		description = 'Contains 300x 9mm rounds',
		client = {
			image = 'ammo-box1.png',
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a' },
			usetime = 2500
		},
		server = {
			export = 'ox_inventory.ammo_box_smg'
		}
	},

	['ammo-box2'] = {
		label = 'Ammo Box Rifle',
		weight = 200,
		stack = true,
		close = true,
		description = 'Contains 500x rifle rounds',
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a' },
			usetime = 2500
		},
		server = {
			export = 'ox_inventory.ammo_box2'
		}
	},

	['ammo-box3'] = {
		label = 'Ammo Box Rifle 2',
		weight = 200,
		stack = true,
		close = true,
		description = 'Contains 500x rifle2 rounds',
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a' },
			usetime = 2500
		},
		server = {
			export = 'ox_inventory.ammo_box3'
		}
	},

	['ammo-box4'] = {
		label = 'Ammo Box .50',
		weight = 200,
		stack = true,
		close = true,
		description = 'Contains 200x .50 rounds',
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a' },
			usetime = 2500
		},
		server = {
			export = 'ox_inventory.ammo_box4'
		}
	},

	['ammo-box5'] = {
		label = 'Ammo Box .45',
		weight = 200,
		stack = true,
		close = true,
		description = 'Contains 200x .45 rounds',
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a' },
			usetime = 2500
		},
		server = {
			export = 'ox_inventory.ammo_box5'
		}
	},

	['energy_drink'] = {
		label = 'Energy Drink',
		weight = 250,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_energy_drink`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 3000,
			notification = 'You feel a rush. Speed boosted for 5 seconds.'
		},
		server = {
			export = 'ox_inventory.energy_drink'
		}
	},

	['oxy'] = {
		label = 'Oxy',
		weight = 50,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'mp_suicide', clip = 'pill_fp' },
			usetime = 3000,
		},
		server = {
			export = 'ox_inventory.oxy'
		}
	},

	['cocaine'] = {
		label = 'Cocaine',
		weight = 50,
		stack = true,
		allowArmed = true,
		client = {
			usetime = 4000,
		},
		server = {
			export = 'ox_inventory.cocaine'
		}
	},

	['ecstasy'] = {
		label = 'Ecstasy',
		weight = 50,
		stack = true,
		allowArmed = true,
		client = {
			anim = { dict = 'mp_suicide', clip = 'pill_fp' },
			usetime = 3000,
		},
		server = {
			export = 'ox_inventory.ecstasy'
		}
	},

	['handcuff'] = {
		label = 'Handcuff',
		weight = 50,
		stack = true,
		server = {
			exportRemove = true,
			export = 'ox_inventory.handcuff'
		}
	},

	['handcuff_keys'] = {
		label = 'Handcuff Keys',
		weight = 50,
		stack = true,
		server = {
			exportRemove = true,
			export = 'ox_inventory.handcuff_keys'
		}
	},

	['boombox'] = {
		label = 'Boombox',
		weight = 2000,
		stack = false,
		client = {
			usetime = 1500,
		},
		server = {
			export = 'ox_inventory.boombox'
		}
	},

	['documents'] = {
		label = 'Documents',
		weight = 0,
		stack = false,
		close = true,
		server = {
			exportRemove = true,
			export = 'ox_inventory.documents'
		}
	},

	['stash_car'] = {
		label = 'Stash Car',
		weight = 50,
		stack = true,
		close = true,
		server = {
			exportRemove = true,
			export = 'ox_inventory.stash_car'
		}
	},

	['hightable_box1'] = {
		label = 'Hightable: Class 1',
		weight = 1,
		allowArmed = true,
		client = { anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 }, usetime = 1500 },
		server = { exportRemove = true, export = 'ox_inventory.itemBoxes' }
	},

	['hightable_box2'] = {
		label = 'Hightable: Class 2',
		weight = 1,
		allowArmed = true,
		client = { anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 }, usetime = 1500 },
		server = { exportRemove = true, export = 'ox_inventory.itemBoxes' }
	},

	['hightable_box3'] = {
		label = 'Hightable: Class 3',
		weight = 1,
		allowArmed = true,
		client = { anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 }, usetime = 1500 },
		server = { exportRemove = true, export = 'ox_inventory.itemBoxes' }
	},

	['hightable_box4'] = {
		label = 'Hightable: Robbery Package',
		weight = 1,
		allowArmed = true,
		client = { anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 }, usetime = 1500 },
		server = { exportRemove = true, export = 'ox_inventory.itemBoxes' }
	},

	['mechanic_box'] = {
		label = 'Mechanic Supply Box',
		weight = 1000,
		stack = true,
		close = true,
		allowArmed = true,
		client = { anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 }, usetime = 1500 },
		server = { exportRemove = true, export = 'ox_inventory.itemBoxes' }
	},

	['orange'] = {
		label = 'Orange',
		weight = 100,
		stack = true,
		close = true,
		description = 'A fresh, juicy orange.',
		client = {
			status = { hunger = 100000, thirst = 50000 },
			anim = 'eating',
			prop = 'prop_food_orange',
			usetime = 2500,
			notification = 'You ate a delicious fresh orange'
		}
	},

	['trowel'] = {
		label = 'Garden Trowel',
		weight = 500,
		stack = false,
		close = true,
		durability = 100,
		description = 'A small hand tool used for digging and harvesting.'
	},

	['wood'] = {
		label = 'Wood',
		weight = 500,
		stack = true,
		close = true,
		description = 'Raw wood log harvested from trees.'
	},

	['battleaxe'] = {
		label = 'Battle Axe',
		weight = 6500,
		stack = false,
		close = true,
		durability = 100,
		description = 'A heavy battle axe, ideal for chopping wood.'
	},
}