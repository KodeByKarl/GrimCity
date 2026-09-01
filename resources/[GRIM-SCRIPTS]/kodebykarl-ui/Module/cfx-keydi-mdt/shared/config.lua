ConfigMDT = {}

-- Keybind and Command to open the Police MDT
ConfigMDT.OpenCommand = 'mdt'
ConfigMDT.OpenKey = 'F10' -- Default keybind mapped via FiveM key mapping

-- Allowed Jobs to access the MDT
ConfigMDT.AllowedJobs = {
    ['police'] = true,
    ['sheriff'] = true,
    ['state'] = true,
    ['fib'] = true,
}

-- Law Enforcement Departments
ConfigMDT.Departments = {
    { id = 'LSPD', name = 'Los Santos Police Department', badge = 'LSPD' },
    { id = 'BCSO', name = 'Blaine County Sheriff Office', badge = 'BCSO' },
    { id = 'SASP', name = 'San Andreas State Police', badge = 'SASP' },
    { id = 'SAHP', name = 'San Andreas Highway Patrol', badge = 'SAHP' },
    { id = 'FIB',  name = 'Federal Investigation Bureau', badge = 'FIB' },
}

-- Minimum grade required for specific privileged actions
ConfigMDT.Permissions = {
    view_mdt            = 0, -- All cadets / officers can open MDT
    create_incident     = 0, -- Any on-duty officer can write reports
    edit_incident       = 0, -- Author or higher
    delete_incident     = 3, -- Lieutenant / Captain / Chief only
    create_warrant      = 1, -- Officer II+
    delete_warrant      = 2, -- Sergeant+
    create_bolo         = 0, -- Any officer
    delete_bolo         = 1, -- Officer II+
    create_vehicle_flag = 0, -- Any officer
    delete_vehicle_flag = 1, -- Officer II+
    edit_penal_codes    = 4, -- Command Staff only
    manage_licenses     = 2, -- Sergeant+
    send_announcement   = 2, -- Sergeant+
}

-- Standard 10-Codes and Unit Statuses
ConfigMDT.Statuses = {
    { code = "10-8",  label = "In Service / Available", color = "#10b981", badge = "AVAILABLE" },
    { code = "10-6",  label = "Busy / In Traffic Stop", color = "#f59e0b", badge = "BUSY" },
    { code = "10-97", label = "On Scene / Responding",   color = "#06b6d4", badge = "ON SCENE" },
    { code = "10-7",  label = "Out of Service / Off Duty", color = "#64748b", badge = "OFF DUTY" },
    { code = "10-99", label = "Officer In Distress / Panic", color = "#ef4444", badge = "PANIC" },
}

-- Tablet Animation & Prop
ConfigMDT.Tablet = {
    enabled = true,
    model = `prop_cs_tablet`,
    bone = 28422, -- Right hand
    offset = vector3(0.0, -0.03, 0.0),
    rotation = vector3(20.0, -90.0, 0.0),
    dict = "amb@world_human_seat_wall_tablet@female@base",
    anim = "base"
}

-- Dispatch Priorities
ConfigMDT.DispatchPriorities = {
    ['low']    = { label = "Code 1 (Low)", color = "#10b981" },
    ['medium'] = { label = "Code 2 (Medium)", color = "#f59e0b" },
    ['high']   = { label = "Code 3 (Urgent)", color = "#f97316" },
    ['urgent'] = { label = "Code 99 (Emergency)", color = "#ef4444" },
}
