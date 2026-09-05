local ESX = exports['es_extended']:getSharedObject()

local jobsCache = nil
local jobsCacheAt = 0
local JOBS_CACHE_MS = 15000

local function isOwnerDev(xPlayer)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    local groups = ConfigIpad.EconomyGroups or { owner = true, developer = true }
    return groups[group] == true
end

local function isPoliceJob(jobName)
    local map = ConfigIpad.PoliceJobs or { police = true, offpolice = true }
    return jobName and map[jobName] == true
end

local function isPoliceBoss(xPlayer)
    if not xPlayer or not xPlayer.job then return false end
    if not isPoliceJob(xPlayer.job.name) then return false end
    local gradeName = xPlayer.job.grade_name
    if gradeName == 'boss' or gradeName == 'director' or gradeName == 'chief' then
        return true
    end
    local minGrade = tonumber(ConfigIpad.PoliceBossMinGrade) or 5
    return (tonumber(xPlayer.job.grade) or 0) >= minGrade
end

local function resolveUniversityRole(xPlayer)
    if not xPlayer or not xPlayer.job then return 'visitor' end
    local jobName = xPlayer.job.name
    local jobs = ConfigIpad.UniversityJobs or { school = true, student = true, teacher = true }
    if not jobs[jobName] then
        return 'visitor'
    end

    local gradeName = type(xPlayer.job.grade_name) == 'string' and xPlayer.job.grade_name:lower() or ''
    local map = ConfigIpad.UniversityGradeRoles or {}
    if map[gradeName] then
        return map[gradeName]
    end

    if jobName == 'student' then return 'student' end
    if jobName == 'teacher' then
        local grade = tonumber(xPlayer.job.grade) or 0
        return grade >= 1 and 'dean' or 'teacher'
    end

    -- school job fallback by numeric grade (install SQL: 0 student, 1 professor, 2 director)
    local grade = tonumber(xPlayer.job.grade) or 0
    if grade >= 2 then return 'director' end
    if grade >= 1 then return 'teacher' end
    return 'student'
end

local function serializeJobs()
    local now = GetGameTimer()
    if jobsCache and (now - jobsCacheAt) < JOBS_CACHE_MS then
        return jobsCache
    end

    local jobs = ESX.GetJobs() or {}
    local list = {}

    for name, job in pairs(jobs) do
        local grades = {}
        for gradeKey, grade in pairs(job.grades or {}) do
            grades[#grades + 1] = {
                grade = tonumber(grade.grade) or tonumber(gradeKey) or 0,
                name = grade.name or tostring(gradeKey),
                label = grade.label or grade.name or ('Grade ' .. tostring(gradeKey)),
                salary = tonumber(grade.salary) or 0,
            }
        end
        table.sort(grades, function(a, b)
            return a.grade < b.grade
        end)

        list[#list + 1] = {
            name = name,
            label = job.label or name,
            grades = grades,
        }
    end

    table.sort(list, function(a, b)
        return (a.label or a.name):lower() < (b.label or b.name):lower()
    end)

    jobsCache = list
    jobsCacheAt = now
    return list
end

local function invalidateJobsCache()
    jobsCache = nil
    jobsCacheAt = 0
end

local function syncOnlineJobPlayers(jobName, grade)
    local players = ESX.GetExtendedPlayers('job', jobName) or {}
    for i = 1, #players do
        local xP = players[i]
        if xP and xP.job and tonumber(xP.job.grade) == tonumber(grade) then
            local onDuty = xP.job.onDuty
            if onDuty == nil then onDuty = true end
            xP.setJob(jobName, grade, onDuty)
        end
    end
end

--- Single lightweight open-session payload (permissions only — client fills cash/job locally)
lib.callback.register('cfx-keydi-ipad:session', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return {
            canEditEconomy = false,
            canPoliceBoss = false,
            canPoliceMdt = false,
            universityRole = 'visitor',
        }
    end

    local jobName = xPlayer.job and xPlayer.job.name or nil
    return {
        canEditEconomy = isOwnerDev(xPlayer),
        canPoliceBoss = isPoliceBoss(xPlayer),
        canPoliceMdt = isPoliceJob(jobName),
        universityRole = resolveUniversityRole(xPlayer),
    }
end)

lib.callback.register('cfx-keydi-ipad:economy:canAccess', function(source)
    return isOwnerDev(ESX.GetPlayerFromId(source))
end)

lib.callback.register('cfx-keydi-ipad:economy:getJobs', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not isOwnerDev(xPlayer) then
        return { ok = false, error = 'denied', jobs = {} }
    end
    return { ok = true, jobs = serializeJobs() }
end)

lib.callback.register('cfx-keydi-ipad:economy:setSalary', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not isOwnerDev(xPlayer) then
        return { ok = false, error = 'denied' }
    end

    local jobName = type(data) == 'table' and data.job or nil
    local grade = type(data) == 'table' and tonumber(data.grade) or nil
    local salary = type(data) == 'table' and tonumber(data.salary) or nil

    if not jobName or grade == nil or salary == nil then
        return { ok = false, error = 'invalid' }
    end

    if salary < 0 then salary = 0 end
    salary = math.floor(salary)

    local jobs = ESX.GetJobs() or {}
    local job = jobs[jobName]
    if not job or not job.grades then
        return { ok = false, error = 'job_not_found' }
    end

    local gradeData = job.grades[tostring(grade)]
    if not gradeData then
        return { ok = false, error = 'grade_not_found' }
    end

    local affected = MySQL.update.await(
        'UPDATE job_grades SET salary = ? WHERE job_name = ? AND grade = ?',
        { salary, jobName, grade }
    )

    if not affected or affected < 1 then
        return { ok = false, error = 'db_failed' }
    end

    gradeData.salary = salary
    invalidateJobsCache()
    syncOnlineJobPlayers(jobName, grade)

    return {
        ok = true,
        job = jobName,
        grade = grade,
        salary = salary,
        jobs = serializeJobs(),
    }
end)
