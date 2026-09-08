Config = {}

Config.Locale = 'en'
Config.GarageId = 'Legion Square'
Config.FinishFuel = 100
Config.MaxProjects = 1
Config.SpawnDistance = 60.0
Config.InteractDistance = 2.15
Config.DrawDistance = 8.0
Config.InstallDuration = 4500
Config.DefaultModel = 'ody18'

-- Blueprint required when placing a vehicle shell (each project craft)
Config.BlueprintItem = 'car_blueprint'
Config.BlueprintAmount = 25
Config.BlueprintLabel = 'Car Blueprint'

-- Display names for project vehicles (metadata "Vehicle: …")
-- Keys MUST be lowercase spawncodes from kodebykarl-cars vehicles.meta
Config.Vehicles = {
    -- Honda / Civic
    ody18 = { label = 'Odyssey 2018' },
    ['74civrswb'] = { label = 'Honda Civic RS' },

    -- Dodge / Chevy / GMC
    ['16charger'] = { label = 'Dodge Charger 2016' },
    ['17silvk9rb'] = { label = 'Silverado K9' },
    ['21sierra'] = { label = 'GMC Sierra 2021' },
    ['2nddragg'] = { label = 'Drag Car', loot = false }, -- no stream models yet

    -- Mercedes / Land Rover / Genesis
    ['16topcargle'] = { label = 'Mercedes GLE TopCar' },
    ['17mansorypnmr'] = { label = 'Mansory Panamera' },
    ['18velar'] = { label = 'Range Rover Velar' },
    ['19gv80'] = { label = 'Genesis GV80' },
    ['22g63'] = { label = 'Mercedes-AMG G63' },

    -- Audi
    ['18rs7'] = { label = 'Audi RS7' },
    ['21rsq8'] = { label = 'Audi RS Q8' },

    -- BMW
    ['17m760i'] = { label = 'BMW 760i' },
    ['20xb7'] = { label = 'Alpina XB7' },
    ['22m5'] = { label = 'BMW M5' },
    ['2ncsx7'] = { label = 'BMW X7', loot = false }, -- no stream models yet
    ['2ncsbmwm8'] = { label = 'BMW M8', loot = false }, -- no stream models yet

    -- Exotic
    ['18performante'] = { label = 'Huracan Performante' },
    ['22arturac'] = { label = 'McLaren Artura' },

    -- Fast & Furious pack (data/2f2fgtr34) — metas only, no stream yet
    ['2f2fgtr34'] = { label = 'Nissan GTR R34', loot = false },
    ['2f2fgts'] = { label = 'Spyder GTS', loot = false },
    ['2f2fmk4'] = { label = 'Toyota Supra', loot = false },
    ['2f2fmle7'] = { label = 'Lancer Evo 7', loot = false },
    ['ff4wrx'] = { label = 'Subaru WRX', loot = false },
    ['fnf4r34'] = { label = 'Nissan Skyline R34', loot = false },
    ['fnfmk4'] = { label = 'Toyota Supra', loot = false },
    ['fnfrx7'] = { label = 'Mazda RX-7', loot = false },
    ['fnfmits'] = { label = 'Mitsubishi Eclipse', loot = false },
}

-- Inventory tooltip titles (metadata.label) — same item name, different vehicle
Config.PartItemLabels = {
    car_battery = 'Project Vehicle Battery',
    car_alternator = 'Project Vehicle Alternator',
    car_radiator = 'Project Vehicle Radiator',
    car_engine_part = 'Project Vehicle Engine',
    spark_plugs = 'Project Vehicle Spark Plugs',
    car_transmission = 'Project Vehicle Transmission',
    car_hood = 'Project Vehicle Hood',
    car_door = 'Project Vehicle Door',
    brake_pads = 'Project Vehicle Brakes',
    car_wheel = 'Project Vehicle Wheel',
    car_blueprint = 'Project Vehicle Blueprint',
    project_parts_box = 'Project Parts Box',
    project_ayuda_box = 'Project Ayuda Box',
}

-- If true, shells can only be placed inside Config.BuildZones
Config.EnableZoneOnly = false
Config.BuildZones = {
    { label = 'Sandy Shores Yard', coords = vector3(1730.56, 3310.72, 41.22), radius = 150.0 },
}

Config.AdminGroups = {
    developer = true,
    owner = true,
    superadmin = true,
    admin = true,
    mod = true,
    god = true,
}

Config.DeleteCommand = 'destroyprojectcar'
Config.GiveShellCommand = 'giveshell'

Config.Parts = {
    battery = {
        item = 'car_battery',
        label = 'Battery',
    },
    alternator = {
        item = 'car_alternator',
        label = 'Alternator',
        requires = { 'battery' },
    },
    radiator = {
        item = 'car_radiator',
        label = 'Radiator',
    },
    engine = {
        item = 'car_engine_part',
        label = 'Engine',
        requires = { 'battery', 'alternator', 'radiator' },
    },
    sparkplugs = {
        item = 'spark_plugs',
        label = 'Spark Plugs',
        requires = { 'engine' },
    },
    transmission = {
        item = 'car_transmission',
        label = 'Transmission',
        requires = { 'engine' },
    },
    hood = {
        item = 'car_hood',
        label = 'Hood',
        door = 4,
        requires = { 'engine', 'sparkplugs', 'transmission' },
    },
    door = {
        item = 'car_door',
        label = 'Door',
        bones = {
            [0] = { bone = 'door_dside_f', label = 'Front Left Door' },
            [1] = { bone = 'door_pside_f', label = 'Front Right Door' },
            [2] = { bone = 'door_dside_r', label = 'Rear Left Door' },
            [3] = { bone = 'door_pside_r', label = 'Rear Right Door' },
        },
    },
    brake = {
        item = 'brake_pads',
        label = 'Brake',
        bones = {
            [0] = { bone = 'wheel_lf', label = 'Front Left Brake' },
            [1] = { bone = 'wheel_rf', label = 'Front Right Brake' },
            [2] = { bone = 'wheel_lr', label = 'Rear Left Brake' },
            [3] = { bone = 'wheel_rr', label = 'Rear Right Brake' },
        },
    },
    wheel = {
        item = 'car_wheel',
        label = 'Wheel',
        bones = {
            [0] = { bone = 'wheel_lf', label = 'Front Left Wheel' },
            [1] = { bone = 'wheel_rf', label = 'Front Right Wheel' },
            [2] = { bone = 'wheel_lr', label = 'Rear Left Wheel' },
            [3] = { bone = 'wheel_rr', label = 'Rear Right Wheel' },
        },
        requiresIndex = 'brake',
    },
}

Config.DoorBones = {
    [0] = 'door_dside_f',
    [1] = 'door_pside_f',
    [2] = 'door_dside_r',
    [3] = 'door_pside_r',
    [4] = 'bonnet',
    [5] = 'boot',
}

Config.WheelBones = {
    [0] = 'wheel_lf',
    [1] = 'wheel_rf',
    [2] = 'wheel_lr',
    [3] = 'wheel_rr',
}

--- Shared helper — used by shop / boxes / chop / install
---@param itemName string
---@param model string|nil
---@return table
function BuildProjectPartMetadata(itemName, model)
    model = tostring(model or Config.DefaultModel or 'ody18'):lower():gsub('%s+', '')
    local vehicleLabel = (Config.Vehicles[model] and Config.Vehicles[model].label) or model:upper()
    local meta = {
        model = model,
        vehicle = vehicleLabel,
    }

    if itemName == 'vehicle_shell' then
        meta.label = ('%s Shell'):format(vehicleLabel)
        meta.description = ('Wrecked %s chassis — place it and install matching parts.'):format(vehicleLabel)
    else
        local partLabel = Config.PartItemLabels and Config.PartItemLabels[itemName]
        if partLabel then
            meta.label = partLabel
        end
        meta.description = ('Fits %s project cars only.'):format(vehicleLabel)
    end

    return meta
end

function GetProjectVehicleLabel(model)
    model = tostring(model or Config.DefaultModel or 'ody18'):lower():gsub('%s+', '')
    if Config.Vehicles[model] and Config.Vehicles[model].label then
        return Config.Vehicles[model].label
    end
    return model:upper()
end

function NormalizeProjectModel(model)
    return tostring(model or ''):lower():gsub('%s+', '')
end

function IsProjectVehicle(model)
    model = NormalizeProjectModel(model)
    return model ~= '' and Config.Vehicles[model] ~= nil
end

--- Cars that can actually spawn (have stream). Used for random part/shop loot.
function IsLootProjectVehicle(model)
    model = NormalizeProjectModel(model)
    local data = Config.Vehicles[model]
    return data ~= nil and data.loot ~= false
end

function GetLootProjectModels()
    local list = {}
    for spawnName, data in pairs(Config.Vehicles) do
        if data and data.loot ~= false then
            list[#list + 1] = spawnName
        end
    end
    table.sort(list)
    return list
end

function PickRandomProjectModel()
    local list = GetLootProjectModels()
    if #list < 1 then
        return Config.DefaultModel or 'ody18'
    end
    return list[math.random(1, #list)]
end
