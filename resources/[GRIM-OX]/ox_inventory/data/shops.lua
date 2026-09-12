return {
	General = {
		name = 'Shop',
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, 		inventory = {
			{ name = 'burger', price = 10 },
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
			{ name = 'sugar', price = 250 },
			{ name = 'dough', price = 250 },
			{ name = 'butter', price = 250 },
			{ name = 'flour', price = 250 },
			{ name = 'cream', price = 250 },
			{ name = 'milk', price = 250 },
			{ name = 'radio', price = 1000 },
			{ name = 'bun', price = 150 },
			{ name = 'burger_patty', price = 450 },
			{ name = 'lettuce', price = 180 },
			{ name = 'tomato', price = 180 },
			{ name = 'soy_sauce', price = 150 },
			{ name = 'cheese', price = 150 },
			{ name = 'raw_meat', price = 500 },
			{ name = 'rice', price = 450 },
		}, locations = {
			vec3(25.7, -1347.3, 29.49),
		}, targets = {
			{ loc = vec3(25.06, -1347.32, 29.5), length = 0.7, width = 0.5, heading = 0.0, minZ = 29.5, maxZ = 29.9, distance = 1.5 },
		}
	},

	PoliceArmoury = {
		name = 'Police Armoury',
		groups = { ['police'] = 0 },
		inventory = {
			{ name = 'police_vitamins', price = 2, currency = 'grimpolicecoin' },
			{ name = 'police_drink', price = 2, currency = 'grimpolicecoin' },
			{ name = 'police_vest', price = 5, currency = 'grimpolicecoin' },
			{ name = 'riot_shield', price = 8, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_FLASHLIGHT', price = 1, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_NIGHTSTICK', price = 1, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_STUNGUN', price = 5, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_BZGAS', price = 3, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_HEAVYPISTOL', price = 250, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_PISTOL_MK2', price = 250, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SMG', price = 500, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SMG_MK2', price = 500, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_COMBATPDW', price = 500, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_PUMPSHOTGUN', price = 25, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_PUMPSHOTGUN_MK2', price = 30, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SPECIALCARBINE', price = 500, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SPECIALCARBINE_MK2', price = 500, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_CARBINERIFLE_MK2', price = 500, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'pd_ammo_box_9', price = 10, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_rifle', price = 15, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_rifle2', price = 15, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_shotgun', price = 12, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_45', price = 10, currency = 'grimpolicecoin' },
			{ name = 'at_flashlight', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_suppressor_light', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_suppressor_heavy', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_grip', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_barrel', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_pistol', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_smg', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_shotgun', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_rifle', price = 5, currency = 'grimpolicecoin' }
		}, locations = {
			vec3(71.5360, -390.2930, 41.6247)
		}, targets = {
			{ loc = vec3(71.5360, -390.2930, 41.6247), length = 1.0, width = 2.0, heading = 249.4090, minZ = 40.6, maxZ = 43.1, distance = 2.5 }
		}
	},

	SheriffArmoury = {
		name = 'Sheriff Armoury',
		groups = shared.police,
		inventory = {
			{ name = 'sheriff_vitamins', price = 2, currency = 'sheriff_coin' },
			{ name = 'sheriff_drink', price = 2, currency = 'sheriff_coin' },
			{ name = 'sheriff_vest', price = 5, currency = 'sheriff_coin' },
			{ name = 'armour', price = 5, currency = 'sheriff_coin' },
			{ name = 'WEAPON_FLASHLIGHT', price = 1, currency = 'sheriff_coin' },
			{ name = 'WEAPON_NIGHTSTICK', price = 1, currency = 'sheriff_coin' },
			{ name = 'WEAPON_STUNGUN', price = 5, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_BZGAS', price = 3, currency = 'sheriff_coin' },
			{ name = 'WEAPON_HEAVYPISTOL', price = 250, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_PISTOL_MK2', price = 250, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SMG', price = 500, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SMG_MK2', price = 500, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_COMBATPDW', price = 500, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_PUMPSHOTGUN', price = 25, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_PUMPSHOTGUN_MK2', price = 30, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SPECIALCARBINE', price = 500, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SPECIALCARBINE_MK2', price = 500, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_CARBINERIFLE_MK2', price = 500, currency = 'sheriff_coin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'sheriff_ammo_box_9', price = 10, currency = 'sheriff_coin' },
			{ name = 'sheriff_ammo_box_rifle', price = 15, currency = 'sheriff_coin' },
			{ name = 'sheriff_ammo_box_rifle2', price = 15, currency = 'sheriff_coin' },
			{ name = 'sheriff_ammo_box_shotgun', price = 12, currency = 'sheriff_coin' },
			{ name = 'at_flashlight', price = 3, currency = 'sheriff_coin' },
			{ name = 'at_suppressor_light', price = 8, currency = 'sheriff_coin' },
			{ name = 'at_suppressor_heavy', price = 10, currency = 'sheriff_coin' },
			{ name = 'at_grip', price = 5, currency = 'sheriff_coin' },
			{ name = 'at_barrel', price = 5, currency = 'sheriff_coin' },
			{ name = 'at_clip_extended_pistol', price = 5, currency = 'sheriff_coin' },
			{ name = 'at_clip_extended_smg', price = 6, currency = 'sheriff_coin' },
			{ name = 'at_clip_extended_shotgun', price = 6, currency = 'sheriff_coin' },
			{ name = 'at_clip_extended_rifle', price = 7, currency = 'sheriff_coin' }
		}, locations = {
			vec3(1891.7761, 3660.1177, 34.1130)
		}, targets = {
			{ loc = vec3(1891.7761, 3660.1177, 34.1130), length = 1.0, width = 2.0, heading = 178.0177, minZ = 33.1, maxZ = 35.5, distance = 2.5 }
		}
	},

	Medicine = {
		name = 'EMS Shop',
		groups = {
			['ambulance'] = 0,
			['pambulance'] = 0,
			['sambulance'] = 0,
		},
		inventory = {
			{ name = 'ems_medikit', price = 15, currency = 'grimemscoin' },
			{ name = 'bandage', price = 10, currency = 'grimemscoin' },
			{ name = 'gauze', price = 10, currency = 'grimemscoin' },
		}, locations = {
			vec3(-1048.1884, -1371.6355, 5.9474)
		}, targets = {
			{ loc = vec3(-1048.1884, -1371.6355, 5.9474), length = 1.0, width = 1.5, heading = 182.1223, minZ = 4.9, maxZ = 7.5, distance = 2.5 }
		}
	},

	WeedFarmShop = {
		name = 'Weed Farm Shop',
		inventory = {
			{ name = 'rolling_paper', price = 250 },
			{ name = 'paper_bags', price = 500 },
			{ name = 'zipper_bag', price = 250 },
			{ name = 'illegal_phone', price = 1500 },
		}, locations = {
			vec3(2224.7139, 5604.8462, 54.9226)
		}, targets = {

		}
	},

	YouTool = {
		name = 'YouTool',
		blip = {
			id = 402, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'weapon_battleaxe', price = 250 },
			{ name = 'trowel', price = 1500 },
		}, locations = {
			vec3(153.3959, 6645.4497, 31.5720)
		}, targets = {
			{ loc = vec3(153.3959, 6645.4497, 31.5720), length = 1.0, width = 1.5, heading = 141.7415, minZ = 30.57, maxZ = 33.57, distance = 2.5 }
		}
	},

	BlackMarketArms = {
		name = 'Black Market (Arms)',
		inventory = {
			{ name = 'WEAPON_DAGGER', price = 5000, metadata = { registered = false }, currency = 'black_money' },
			{ name = 'WEAPON_CERAMICPISTOL', price = 50000, metadata = { registered = false }, currency = 'black_money' },
			{ name = 'at_suppressor_light', price = 50000, currency = 'black_money' },
			{ name = 'ammo-rifle', price = 1000, currency = 'black_money' },
			{ name = 'ammo-rifle2', price = 1000, currency = 'black_money' }
		}, locations = {
			vec3(309.09, -913.75, 56.46)
		}, targets = {

		}
	},

	VendingMachineDrinks = {
		name = 'Vending Machine',
		inventory = {
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
		},
		model = {
			`prop_vend_soda_02`, `prop_vend_fridge01`, `prop_vend_water_01`, `prop_vend_soda_01`
		}
	}
}
