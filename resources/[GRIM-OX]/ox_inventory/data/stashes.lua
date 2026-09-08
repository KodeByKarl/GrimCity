return {
	{
		coords = vec3(452.3, -991.4, 30.7),
		target = {
			loc = vec3(451.25, -994.28, 30.69),
			length = 1.2,
			width = 5.6,
			heading = 0,
			minZ = 29.49,
			maxZ = 32.09,
			label = 'Open personal locker'
		},
		name = 'policelocker',
		label = 'Personal locker',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = shared.police
	},

	{
		coords = vec3(-1036.3583, -1356.8684, 5.9473),
		target = {
			loc = vec3(-1036.3583, -1356.8684, 5.9473),
			length = 1.0,
			width = 1.8,
			heading = 190.6459,
			minZ = 4.9,
			maxZ = 7.5,
			label = 'Open personal locker'
		},
		name = 'emslocker',
		label = 'Personal Locker',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = {['ambulance'] = 0, ['pambulance'] = 0, ['sambulance'] = 0}
	},

	{
		coords = vec3(-1040.5308, -1355.7512, 5.9474),
		target = {
			loc = vec3(-1040.5308, -1355.7512, 5.9474),
			length = 1.0,
			width = 2.0,
			heading = 169.9048,
			minZ = 4.9,
			maxZ = 7.5,
			label = 'Open shared locker'
		},
		name = 'emsshared',
		label = 'EMS Shared Locker',
		owner = false,
		slots = 150,
		weight = 300000,
		groups = {['ambulance'] = 0, ['pambulance'] = 0, ['sambulance'] = 0}
	},

	{
		coords = vec3(454.4, -980.1, 30.7),
		target = {
			loc = vec3(454.4, -980.1, 30.7),
			length = 1.0,
			width = 2.0,
			heading = 90,
			minZ = 29.5,
			maxZ = 32.0,
			label = 'Open shared locker'
		},
		name = 'policeshared',
		label = 'Police Shared Locker',
		owner = false,
		slots = 150,
		weight = 300000,
		groups = shared.police
	},

	{
		coords = vec3(460.8, -985.4, 30.7),
		target = {
			loc = vec3(460.8, -985.4, 30.7),
			length = 1.0,
			width = 1.5,
			heading = 0,
			minZ = 29.5,
			maxZ = 32.0,
			label = 'Open boss locker'
		},
		name = 'policeboss',
		label = 'Police Boss Locker',
		owner = false,
		slots = 100,
		weight = 200000,
		groups = { ['police'] = 6 }
	},

	{
		coords = vec3(1891.9514, 3661.7656, 34.1129),
		target = {
			loc = vec3(1891.9514, 3661.7656, 34.1129),
			length = 1.0,
			width = 1.8,
			heading = 277.9326,
			minZ = 33.1,
			maxZ = 35.5,
			label = 'Open personal locker'
		},
		name = 'sherifflocker',
		label = 'Personal Locker',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = { ['sheriff'] = 0 }
	},

	{
		coords = vec3(1890.9138, 3663.4829, 34.1129),
		target = {
			loc = vec3(1890.9138, 3663.4829, 34.1129),
			length = 1.0,
			width = 2.0,
			heading = 304.5840,
			minZ = 33.1,
			maxZ = 35.5,
			label = 'Open shared locker'
		},
		name = 'sheriffshared',
		label = 'Sheriff Shared Locker',
		owner = false,
		slots = 150,
		weight = 300000,
		groups = { ['sheriff'] = 0 }
	},

	{
		coords = vec3(1877.5516, 3659.5029, 37.3998),
		target = {
			loc = vec3(1877.5516, 3659.5029, 37.3998),
			length = 1.0,
			width = 1.5,
			heading = 119.8286,
			minZ = 36.4,
			maxZ = 38.6,
			label = 'Open boss locker'
		},
		name = 'sheriffboss',
		label = 'Sheriff Boss Locker',
		owner = false,
		slots = 100,
		weight = 200000,
		groups = { ['sheriff'] = 6 }
	},

	{
		coords = vec3(-251.7234, 6320.7090, 32.4327),
		target = {
			loc = vec3(-251.7234, 6320.7090, 32.4327),
			length = 1.0,
			width = 1.8,
			heading = 163.8817,
			minZ = 31.4,
			maxZ = 34.0,
			label = 'Open personal locker'
		},
		name = 'pambulancelocker',
		label = 'Personal Locker',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = { ['pambulance'] = 0, ['sambulance'] = 0 }
	},

	{
		coords = vec3(-253.1091, 6322.1353, 32.4327),
		target = {
			loc = vec3(-253.1091, 6322.1353, 32.4327),
			length = 1.0,
			width = 2.0,
			heading = 131.6333,
			minZ = 31.4,
			maxZ = 34.0,
			label = 'Open shared locker'
		},
		name = 'pambulanceshared',
		label = 'Paleto EMS Shared Locker',
		owner = false,
		slots = 150,
		weight = 300000,
		groups = { ['pambulance'] = 0, ['sambulance'] = 0 }
	},
}
