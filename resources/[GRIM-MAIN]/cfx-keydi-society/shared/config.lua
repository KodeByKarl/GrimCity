Config = {}

Config.Debug = false

-- Auto-create these society accounts on resource start (jobs / gangs).
-- Balance starts at 0 unless you set startingBalance.
Config.Accounts = {
    { name = 'society_police', label = 'Police Department', startingBalance = 0 },
    { name = 'society_ambulance', label = 'EMS / Ambulance', startingBalance = 0 },
    { name = 'society_mechanic', label = 'Mechanic', startingBalance = 0 },
    { name = 'society_school', label = 'University of Los Santos', startingBalance = 0 },

    -- Gang societies (kodebykarl-gangsystem)
    { name = 'society_ballas', label = 'Ballas', startingBalance = 0 },
    { name = 'society_families', label = 'Families', startingBalance = 0 },
    { name = 'society_vagos', label = 'Vagos', startingBalance = 0 },
    { name = 'society_lostmc', label = 'Lost MC', startingBalance = 0 },
    { name = 'society_marabunta', label = 'Marabunta', startingBalance = 0 },
}

-- Map job / gang id → society account name (helpers)
Config.JobAccounts = {
    police = 'society_police',
    offpolice = 'society_police',
    ambulance = 'society_ambulance',
    offambulance = 'society_ambulance',
    mechanic = 'society_mechanic',
    offmechanic = 'society_mechanic',
    school = 'society_school',
    teacher = 'society_school',
    student = 'society_school',
}

Config.GangAccounts = {
    ballas = 'society_ballas',
    families = 'society_families',
    vagos = 'society_vagos',
    lostmc = 'society_lostmc',
    marabunta = 'society_marabunta',
}

-- Write deposit/withdraw rows to cfx_society_ledger
Config.EnableLedger = true

-- Max ledger rows returned by GetLedger export
Config.LedgerLimit = 50
