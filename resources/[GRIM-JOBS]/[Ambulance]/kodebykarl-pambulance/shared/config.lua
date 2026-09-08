ConfigPambulance = {}

ConfigPambulance.Job = 'pambulance'
ConfigPambulance.OffDutyJob = 'offpambulance'
ConfigPambulance.Label = 'Paleto Ambulance'
ConfigPambulance.ShortLabel = 'PAMS'

-- Paleto Bay hospital (Blaine County EMS)
ConfigPambulance.Station = {
    Location = {
        coords = vector3(-243.7424, 6317.6816, 32.4270),
        heading = 221.6605,
    },
    Blip = {
        Coords = vector3(-243.7424, 6317.6816, 32.4270),
        Sprite = 61,
        Display = 4,
        Scale = 0.8,
        Colour = 1,
        Label = 'Paleto Ambulance',
    },
    BossMenu = {
        coords = vector3(-243.7424, 6317.6816, 32.4270),
        heading = 221.6605,
        minGrade = 5,
        label = 'Paleto EMS Boss Menu',
        icon = 'fa-solid fa-briefcase',
    },
    PublicStash = {
        coords = vector3(-253.1091, 6322.1353, 32.4327),
        heading = 131.6333,
        label = 'Paleto EMS Shared Locker',
    },
    PersonalStash = {
        coords = vector3(-251.7234, 6320.7090, 32.4327),
        heading = 163.8817,
        label = 'Paleto EMS Personal Locker',
    },
    Wardrobe = {
        coords = vector3(-251.9285, 6313.0410, 32.4273),
        heading = 337.7322,
        size = vector3(1.2, 2.0, 2.5),
        label = 'Paleto EMS Wardrobe',
        icon = 'fa-solid fa-shirt',
    },
    Bed = {
        coords = vector4(-264.4805, 6325.2949, 33.2788, 161.4241),
    },
    Respawn = {
        coords = vector4(-283.6857, 6325.4751, 32.3472, 278.8888),
    },
    Garage = {
        access = vector3(-273.5200, 6318.0293, 32.4212),
        heading = 206.0106,
        spawn = vector4(-268.4462, 6309.9468, 32.3824, 215.0898),
        label = 'Paleto EMS Garage',
        garageId = 'Paleto EMS Garage',
    },
}

-- Same ranks as city EMS (created on resource start if missing)
ConfigPambulance.Grades = {
    { grade = 0, name = 'intern', label = 'Intern', salary = 65000 },
    { grade = 1, name = 'nurse', label = 'Nurse', salary = 70000 },
    { grade = 2, name = 'head_nurse', label = 'Head Nurse', salary = 75000 },
    { grade = 3, name = 'resident_doctor', label = 'Resident Doctor', salary = 80000 },
    { grade = 4, name = 'senior_resident_doctor', label = 'Senior Resident Doctor', salary = 85000 },
    { grade = 5, name = 'assistant_director', label = 'Assistant Director', salary = 90000 },
    { grade = 6, name = 'boss', label = 'Medical Director', salary = 100000 },
}
