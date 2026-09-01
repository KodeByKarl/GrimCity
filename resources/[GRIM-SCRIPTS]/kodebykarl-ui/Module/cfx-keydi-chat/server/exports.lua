local ESX = exports['es_extended']:getSharedObject()

local function getJobLabel(jobName)
    if ESX.GetJobs then
        local jobs = ESX.GetJobs()
        if jobs[jobName] and jobs[jobName].label then
            return jobs[jobName].label
        end
    end

    return jobName and jobName:gsub('^%l', string.upper) or 'JOB'
end

local function buildJobTemplate(jobData, jobLabel, message, time)
    local backgroundStyle = 'background: #0f0f13;'

    if jobData then
        if jobData.gif then
            backgroundStyle = ("background-image: url('%s'); background-size: cover; background-position: center;"):format(jobData.gif)
        elseif jobData.background then
            backgroundStyle = 'background: ' .. jobData.background .. ';'
        end
    end

    return '<div style="' .. backgroundStyle .. ' border-radius: 4px; border: 1px solid rgba(255, 255, 255, 0.05); padding: 10px; margin-bottom: 8px; font-family: sans-serif; position: relative; box-shadow: inset 0 0 100px rgba(0,0,0,0.8);">'
        .. '  <div style="display: flex; justify-content: space-between; font-size: 11px; color: #a1a1a8; font-weight: 600; text-transform: uppercase;">'
        .. '    <span>FEED • ' .. jobLabel .. ' | SYSTEM</span>'
        .. '    <span>{1}</span>'
        .. '  </div>'
        .. '  <div style="color: #ffffff; font-size: 13px; font-weight: 700; text-transform: uppercase; margin-top: 6px; line-height: 1.4; text-shadow: 0 2px 4px rgba(0,0,0,0.85);">{0}</div>'
        .. '</div>'
end

local function resolvePlayerGang(xPlayer)
    local gangName, gangLabel, gradeLabel = nil, nil, 'Region 3'

    if xPlayer.gang then
        if type(xPlayer.gang) == 'table' then
            gangName = xPlayer.gang.name
            gangLabel = xPlayer.gang.label
            gradeLabel = xPlayer.gang.grade_label or 'Region 3'
        elseif type(xPlayer.gang) == 'string' then
            gangName = xPlayer.gang
        end
    elseif xPlayer.getGang then
        local gangObj = xPlayer.getGang()
        if type(gangObj) == 'table' then
            gangName = gangObj.name
            gangLabel = gangObj.label
            gradeLabel = gangObj.grade_label or 'Region 3'
        elseif type(gangObj) == 'string' then
            gangName = gangObj
        end
    end

    if not gangLabel or gangLabel == '' then
        gangLabel = gangName and gangName:gsub('^%l', string.upper) or 'GANG'
    end

    return gangName, gangLabel, gradeLabel
end

--- System job announcement without a player source (drop-in for cfx-cs-chat JobTemplateWithoutID)
function JobTemplateWithoutID(jobName, message)
    if type(jobName) ~= 'string' or jobName == '' or type(message) ~= 'string' or message == '' then
        return
    end

    local jobData = ConfigChat.jobTemplate and ConfigChat.jobTemplate.jobs and ConfigChat.jobTemplate.jobs[jobName]
    local jobLabel = getJobLabel(jobName)
    local time = os.date('%H:%M')
    local template = buildJobTemplate(jobData, jobLabel, message, time)

    TriggerClientEvent('chat:addMessage', -1, {
        template = template,
        args = { message, time }
    })
end

--- Post a gang announcement as a player (same look as /gc)
---@param source number
---@param message string
---@return boolean success, string|nil error
function GangTemplateFromSource(source, message)
    if type(message) ~= 'string' or message == '' then
        return false, 'empty'
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false, 'no_player'
    end

    if not ConfigChat.gangTemplate or not ConfigChat.gangTemplate.enabled then
        return false, 'disabled'
    end

    local gangName, gangLabel, gradeLabel = resolvePlayerGang(xPlayer)
    gangName = type(gangName) == 'string' and gangName:lower() or nil
    local gangData = ResolveGangTemplate(gangName, gangLabel)
    if not gangData then
        return false, 'unauthorized'
    end

    gangLabel = gangData.label or gangLabel or gangName:upper()
    gradeLabel = gradeLabel or ''

    local headerLeft = 'FEED • ' .. gangLabel
    if gradeLabel ~= '' then
        headerLeft = headerLeft .. ' | {0} | ' .. gradeLabel
    else
        headerLeft = headerLeft .. ' | {0}'
    end

    local time = os.date('%H:%M')
    local speaker = xPlayer.getName and xPlayer.getName() or xPlayer.name or 'Unknown'
    local template = BuildAnnouncementHtml(gangData, headerLeft)

    TriggerClientEvent('chat:addMessage', -1, {
        template = template,
        args = { speaker, message:upper(), time }
    })

    if GetResourceState('discord-logs') == 'started' then
        pcall(function()
            exports['discord-logs']:LogChatMessage(source, '[' .. gangLabel .. '] ' .. message)
        end)
    end

    return true
end

exports('JobTemplateWithoutID', JobTemplateWithoutID)
exports('GangTemplateFromSource', GangTemplateFromSource)

-- Event fallback (same-server) if export isn't refreshed yet
AddEventHandler('cfx-keydi-ui:GangTemplateFromSource', function(src, message, cb)
    local ok, err = GangTemplateFromSource(src, message)
    if cb then cb(ok, err) end
end)
