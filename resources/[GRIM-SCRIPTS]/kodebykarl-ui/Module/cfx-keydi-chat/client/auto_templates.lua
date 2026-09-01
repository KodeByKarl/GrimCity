local ESX = exports['es_extended']:getSharedObject()

local function getPlayerJob()
    local data = ESX.GetPlayerData()
    return data and data.job or nil
end

local function resolveJobTemplates(jobName)
    local cfg = ConfigChat and ConfigChat.jobAutoTemplates
    if not cfg or not cfg.enabled or not cfg.jobs or not jobName then
        return nil
    end

    if cfg.jobs[jobName] then
        return cfg.jobs[jobName]
    end

    if jobName == 'sambulance' and cfg.jobs['ambulance'] then
        return cfg.jobs['ambulance']
    end

    if jobName == 'sheriff' and cfg.jobs['police'] then
        return cfg.jobs['police']
    end

    return nil
end

local function postTemplateMessage(message)
    local cmd = (ConfigChat.jobTemplate and ConfigChat.jobTemplate.command) or 'wl'
    if not message or message == '' then return end
    ExecuteCommand(('%s %s'):format(cmd, message))
end

local function fillTemplatePlaceholders(text, values)
    local result = text
    if values.postal and values.postal ~= '' then
        result = result:gsub('%[POSTAL#%]', values.postal)
        result = result:gsub('%[POSTAL%]', values.postal)
        result = result:gsub('{POSTAL}', values.postal)
        result = result:gsub('%(POSTAL#%)', values.postal)
    else
        result = result:gsub('%[POSTAL#%]', '')
        result = result:gsub('%[POSTAL%]', '')
        result = result:gsub('{POSTAL}', '')
        result = result:gsub('%(POSTAL#%)', '')
    end

    if values.location and values.location ~= '' then
        result = result:gsub('%[LOCATION%]', values.location)
        result = result:gsub('{LOCATION}', values.location)
    end

    if values.reason and values.reason ~= '' then
        result = result:gsub('%[REASON%]', values.reason)
        result = result:gsub('{REASON}', values.reason)
    end

    -- Clean up double spaces from empty postal
    result = result:gsub('%s+', ' ')
    return result:match('^%s*(.-)%s*$') or result
end

local function openFillDialog(template)
    local fields = template.fields or {}
    local needsPostal = fields.needsPostal
    local needsLocation = fields.needsLocation
    local needsReason = fields.needsReason

    if not needsPostal and not needsLocation and not needsReason then
        postTemplateMessage(template.message)
        return
    end

    local inputs = {}

    if needsLocation then
        inputs[#inputs + 1] = {
            type = 'input',
            label = 'Location',
            placeholder = 'Legion Square / Highway',
            required = true,
        }
    end

    if needsPostal then
        inputs[#inputs + 1] = {
            type = 'input',
            label = 'Postal Code / Number',
            placeholder = 'e.g. 7231 or 647',
            required = true,
        }
    end

    if needsReason then
        inputs[#inputs + 1] = {
            type = 'input',
            label = 'Reason / Description',
            placeholder = 'BIG BANK / Armed Robbery / Reckless Driving',
            required = true,
        }
    end

    local result = lib.inputDialog(template.title or 'Announcement Details', inputs)
    if not result then return end

    local idx = 1
    local values = {}

    if needsLocation then
        values.location = result[idx]
        idx = idx + 1
    end

    if needsPostal then
        values.postal = result[idx]
        idx = idx + 1
    end

    if needsReason then
        values.reason = result[idx]
        idx = idx + 1
    end

    local finalMessage = fillTemplatePlaceholders(template.message, values)
    postTemplateMessage(finalMessage)
end

local function groupTemplatesByCategory(templates)
    local cats, order = {}, {}
    for i = 1, #templates do
        local t = templates[i]
        local cat = t.category or 'General'
        if not cats[cat] then
            cats[cat] = {}
            order[#order + 1] = cat
        end
        cats[cat][#cats[cat] + 1] = t
    end
    return cats, order
end

local function openCategoryMenu(category, templates, rootMenuId)
    local options = {}
    for i = 1, #templates do
        local t = templates[i]
        options[#options + 1] = {
            title = t.title or t.id or ('Template %s'):format(i),
            description = t.description or (t.message and t.message:sub(1, 75) .. '…') or '',
            icon = t.icon or 'message',
            onSelect = function()
                openFillDialog(t)
            end,
        }
    end

    local menuId = 'job_tp_cat_' .. category:gsub('%s+', '_'):lower()
    lib.registerContext({
        id = menuId,
        title = category,
        menu = rootMenuId,
        options = options,
    })
    lib.showContext(menuId)
end

local function openJobAutoTemplates(templates, jobLabel)
    local cats, order = groupTemplatesByCategory(templates)

    -- If only 1 category and few items, open directly
    if #order == 1 and #templates <= 8 then
        local cat = order[1]
        local options = {}
        for i = 1, #templates do
            local t = templates[i]
            options[#options + 1] = {
                title = t.title or t.id or ('Template %s'):format(i),
                description = t.description or (t.message and t.message:sub(1, 75) .. '…') or '',
                icon = t.icon or 'message',
                onSelect = function()
                    openFillDialog(t)
                end,
            }
        end

        lib.registerContext({
            id = 'job_tp_root',
            title = ('%s Templates'):format(jobLabel or 'Job'),
            options = options,
        })
        lib.showContext('job_tp_root')
        return
    end

    local options = {}
    for i = 1, #order do
        local cat = order[i]
        local count = #cats[cat]
        options[#options + 1] = {
            title = cat,
            description = ('%s template(s)'):format(count),
            icon = 'folder',
            arrow = true,
            onSelect = function()
                openCategoryMenu(cat, cats[cat], 'job_tp_root')
            end,
        }
    end

    lib.registerContext({
        id = 'job_tp_root',
        title = ('%s Templates'):format(jobLabel or 'Job'),
        options = options,
    })
    lib.showContext('job_tp_root')
end

local function tryOpenTemplatesForJob(targetJob)
    local job = getPlayerJob()
    local jobName = (job and job.name) or nil
    local jobLabel = (job and job.label) or jobName

    if targetJob and targetJob ~= '' then
        if jobName ~= targetJob and not (targetJob == 'ambulance' and jobName == 'sambulance') and not (targetJob == 'police' and jobName == 'sheriff') then
            lib.notify({ title = 'Job Templates', description = ('You are not authorized for %s templates.'):format(targetJob:upper()), type = 'error' })
            return
        end
    end

    local templates = resolveJobTemplates(jobName)
    if not templates or #templates == 0 then
        lib.notify({ title = 'Job Templates', description = 'No templates configured for your job.', type = 'error' })
        return
    end

    openJobAutoTemplates(templates, jobLabel)
end

RegisterNetEvent('cfx-keydi-chat:openJobAutoTemplates', function(targetJob)
    local cfg = ConfigChat and ConfigChat.jobAutoTemplates
    if not cfg or not cfg.enabled then
        lib.notify({ title = 'Auto Templates', description = 'Auto Templates are disabled.', type = 'error' })
        return
    end

    tryOpenTemplatesForJob(targetJob)
end)

-- /ems or /hospital command
RegisterCommand('ems', function(source, args)
    if #args > 0 then
        local msg = table.concat(args, ' ')
        ExecuteCommand(('wl %s'):format(msg))
    else
        tryOpenTemplatesForJob('ambulance')
    end
end, false)

RegisterCommand('hospital', function(source, args)
    if #args > 0 then
        local msg = table.concat(args, ' ')
        ExecuteCommand(('wl %s'):format(msg))
    else
        tryOpenTemplatesForJob('ambulance')
    end
end, false)

-- /pd or /police command
RegisterCommand('pd', function(source, args)
    if #args > 0 then
        local msg = table.concat(args, ' ')
        ExecuteCommand(('wl %s'):format(msg))
    else
        tryOpenTemplatesForJob('police')
    end
end, false)

RegisterCommand('police', function(source, args)
    if #args > 0 then
        local msg = table.concat(args, ' ')
        ExecuteCommand(('wl %s'):format(msg))
    else
        tryOpenTemplatesForJob('police')
    end
end, false)

-- /mech or /mechanic command
RegisterCommand('mech', function(source, args)
    if #args > 0 then
        local msg = table.concat(args, ' ')
        ExecuteCommand(('wl %s'):format(msg))
    else
        tryOpenTemplatesForJob('mechanic')
    end
end, false)

RegisterCommand('mechanic', function(source, args)
    if #args > 0 then
        local msg = table.concat(args, ' ')
        ExecuteCommand(('wl %s'):format(msg))
    else
        tryOpenTemplatesForJob('mechanic')
    end
end, false)

-- /jobtp or /job command
RegisterCommand('jobtp', function(source, args)
    tryOpenTemplatesForJob(nil)
end, false)

RegisterCommand('job', function(source, args)
    tryOpenTemplatesForJob(nil)
end, false)
