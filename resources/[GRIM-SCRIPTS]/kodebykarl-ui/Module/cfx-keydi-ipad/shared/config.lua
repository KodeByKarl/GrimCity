ConfigIpad = {}

ConfigIpad.OpenCommand = 'ipad'
ConfigIpad.OpenKey = 'F4'
ConfigIpad.UseProp = true
ConfigIpad.Prop = {
    model = `prop_cs_tablet`,
    bone = 28422,
    offset = vec3(0.0, 0.0, 0.0),
    rotation = vec3(0.0, 0.0, 0.0),
    dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a',
    anim = 'idle_a',
}

-- Economy app (owner / developer only)
ConfigIpad.EconomyGroups = {
    owner = true,
    developer = true,
}

-- Police MDT / Boss access
ConfigIpad.PoliceJobs = {
    police = true,
    offpolice = true,
}
ConfigIpad.PoliceBossMinGrade = 5
