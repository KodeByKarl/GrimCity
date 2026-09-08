local ESX = exports['es_extended']:getSharedObject()

local function ensureJob(name, label, salaryScale)
    if not ESX.CreateJob then return end
    local grades = {}
    for i = 1, #(ConfigPambulance.Grades or {}) do
        local row = ConfigPambulance.Grades[i]
        grades[#grades + 1] = {
            grade = row.grade,
            name = row.name,
            label = row.label,
            salary = math.floor((row.salary or 0) * (salaryScale or 1)),
            skin_male = {},
            skin_female = {},
        }
    end
    pcall(function()
        ESX.CreateJob(name, label, grades, 'ems')
    end)
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    ensureJob(ConfigPambulance.Job, ConfigPambulance.Label, 1)
    ensureJob(ConfigPambulance.OffDutyJob, ('Off-Duty %s'):format(ConfigPambulance.Label), 0)
    print('^2[kodebykarl-pambulance]^7 Paleto Ambulance online — job `' .. ConfigPambulance.Job .. '`.')
end)

exports('GetJobName', function()
    return ConfigPambulance.Job or 'pambulance'
end)

exports('GetOffDutyJobName', function()
    return ConfigPambulance.OffDutyJob or 'offpambulance'
end)
