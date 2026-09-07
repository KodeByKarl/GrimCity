return {
	General = {
		name = 'Shop',
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'burger', price = 10 },
			{ name = 'water', price = 10 },
			{ name = 'cola', price = 10 },
		}, locations = {
			vec3(25.7, -1347.3, 29.49),
		}, targets = {
			{ loc = vec3(25.06, -1347.32, 29.5), length = 0.7, width = 0.5, heading = 0.0, minZ = 29.5, maxZ = 29.9, distance = 1.5 },
		}
	},

	PoliceArmoury = {
		name = 'Police Armoury',
		groups = shared.police,
		inventory = {
			{ name = 'police_vitamins', price = 2, currency = 'grimpolicecoin' },
			{ name = 'police_drink', price = 2, currency = 'grimpolicecoin' },
			{ name = 'police_vest', price = 5, currency = 'grimpolicecoin' },
			{ name = 'armour', price = 5, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_FLASHLIGHT', price = 1, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_NIGHTSTICK', price = 1, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_STUNGUN', price = 5, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_BZGAS', price = 3, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_HEAVYPISTOL', price = 15, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_PISTOL_MK2', price = 18, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SMG', price = 25, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SMG_MK2', price = 30, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_COMBATPDW', price = 28, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_PUMPSHOTGUN', price = 25, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_PUMPSHOTGUN_MK2', price = 30, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SPECIALCARBINE', price = 40, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_SPECIALCARBINE_MK2', price = 45, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'WEAPON_CARBINERIFLE_MK2', price = 45, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'POL' } },
			{ name = 'pd_ammo_box_9', price = 10, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_rifle', price = 15, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_rifle2', price = 15, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_shotgun', price = 12, currency = 'grimpolicecoin' },
			{ name = 'at_flashlight', price = 3, currency = 'grimpolicecoin' },
			{ name = 'at_suppressor_light', price = 8, currency = 'grimpolicecoin' },
			{ name = 'at_suppressor_heavy', price = 10, currency = 'grimpolicecoin' },
			{ name = 'at_grip', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_barrel', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_pistol', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_smg', price = 6, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_shotgun', price = 6, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_rifle', price = 7, currency = 'grimpolicecoin' }
		}, locations = {
			vec3(13.0845, -424.3956, 33.5622)
		}, targets = {
			{ loc = vec3(13.0845, -424.3956, 33.5622), length = 0.5, width = 3.0, heading = 270.0, minZ = 30.5, maxZ = 32.0, distance = 6 }
		}
	},

	SheriffArmoury = {
		name = 'Sheriff Armoury',
		groups = shared.police,
		inventory = {
			{ name = 'police_vitamins', price = 2, currency = 'grimpolicecoin' },
			{ name = 'police_drink', price = 2, currency = 'grimpolicecoin' },
			{ name = 'police_vest', price = 5, currency = 'grimpolicecoin' },
			{ name = 'armour', price = 5, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_FLASHLIGHT', price = 1, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_NIGHTSTICK', price = 1, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_STUNGUN', price = 5, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_BZGAS', price = 3, currency = 'grimpolicecoin' },
			{ name = 'WEAPON_HEAVYPISTOL', price = 15, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_PISTOL_MK2', price = 18, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SMG', price = 25, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SMG_MK2', price = 30, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_COMBATPDW', price = 28, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_PUMPSHOTGUN', price = 25, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_PUMPSHOTGUN_MK2', price = 30, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SPECIALCARBINE', price = 40, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_SPECIALCARBINE_MK2', price = 45, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'WEAPON_CARBINERIFLE_MK2', price = 45, currency = 'grimpolicecoin', metadata = { registered = true, serial = 'BCSO' } },
			{ name = 'pd_ammo_box_9', price = 10, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_rifle', price = 15, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_rifle2', price = 15, currency = 'grimpolicecoin' },
			{ name = 'pd_ammo_box_shotgun', price = 12, currency = 'grimpolicecoin' },
			{ name = 'at_flashlight', price = 3, currency = 'grimpolicecoin' },
			{ name = 'at_suppressor_light', price = 8, currency = 'grimpolicecoin' },
			{ name = 'at_suppressor_heavy', price = 10, currency = 'grimpolicecoin' },
			{ name = 'at_grip', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_barrel', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_pistol', price = 5, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_smg', price = 6, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_shotgun', price = 6, currency = 'grimpolicecoin' },
			{ name = 'at_clip_extended_rifle', price = 7, currency = 'grimpolicecoin' }
		}, locations = {
			vec3(1891.7761, 3660.1177, 34.1130)
		}, targets = {
			{ loc = vec3(1891.7761, 3660.1177, 34.1130), length = 1.0, width = 2.0, heading = 178.0177, minZ = 33.1, maxZ = 35.5, distance = 2.5 }
		}
	},

	Medicine = {
		name = 'Medicine Cabinet',
		groups = {
			['ambulance'] = 0
		},
		blip = {
			id = 403, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'medikit', price = 26 },
			{ name = 'bandage', price = 5 }
		}, locations = {
			vec3(306.3687, -601.5139, 43.28406)
		}, targets = {

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
