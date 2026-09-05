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
		coords = vec3(301.3, -600.23, 43.28),
		target = {
			loc = vec3(301.82, -600.99, 43.29),
			length = 0.6,
			width = 1.8,
			heading = 340,
			minZ = 43.34,
			maxZ = 44.74,
			label = 'Open personal locker'
		},
		name = 'emslocker',
		label = 'Personal Locker',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = {['ambulance'] = 0}
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
}
