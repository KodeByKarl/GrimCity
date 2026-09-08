local ESX = exports['es_extended']:getSharedObject()

local function templateColors(data)
    local color = (data and data.color) or "#ffffff"
    local headerColor = (data and data.headerColor) or color
    return color, headerColor
end

local function templateBackground(data, fallback)
    if data and data.gif then
        -- Fixed compact card: image covers the box (crop), badge/logo side kept visible.
        return "background-image: linear-gradient(90deg, rgba(0,0,0,0.62) 0%, rgba(0,0,0,0.35) 45%, rgba(0,0,0,0.15) 100%), url('"
            .. data.gif
            .. "'); background-size: cover; background-position: center right; background-repeat: no-repeat;"
    end
    if data and data.background and data.background ~= 'nil' then
        return "background: " .. data.background .. ";"
    end
    return "background: " .. (fallback or "#0f0f13") .. ";"
end

--- Compact size matched to Traphouse chat cards (padding 8x12, ~single-block height).
local ANNOUNCE_CARD_STYLE = "height: 52px; min-height: 52px; max-height: 52px; overflow: hidden; box-sizing: border-box; border-radius: 8px; padding: 8px 12px; margin-bottom: 6px; font-family: 'Outfit', sans-serif; position: relative; display: flex; flex-direction: column; justify-content: center; gap: 2px; max-width: 100%; flex-shrink: 0; box-shadow: 0 4px 15px rgba(0,0,0,0.5);"

--- Freestyle job banner. Per-job colors/gifs override default.
function ResolveJobTemplate(jobName, jobLabel)
    local cfg = ConfigChat.jobTemplate
    if not cfg or not cfg.enabled then return nil end

    jobName = type(jobName) == 'string' and jobName:lower() or nil
    if not jobName or jobName == '' then
        return nil
    end

    if cfg.blockedJobs and cfg.blockedJobs[jobName] then
        return nil
    end

    local data = cfg.jobs and cfg.jobs[jobName]
    if data then
        return data
    end

    if cfg.allowAnyJob == false then
        return nil
    end

    local fallback = cfg.default or {}
    return {
        label = jobLabel or jobName:upper(),
        gif = fallback.gif,
        background = fallback.background or '#111111',
        color = fallback.color or '#ffffff',
        headerColor = fallback.headerColor or '#cfcfcf',
    }
end

--- Any assigned ESX gang can post. Custom gif/colors override the free default.
function ResolveGangTemplate(gangName, gangLabel)
    local cfg = ConfigChat.gangTemplate
    if not cfg or not cfg.enabled then return nil end

    gangName = type(gangName) == 'string' and gangName:lower() or nil
    if not gangName or gangName == '' or gangName == 'none' then
        return nil
    end

    local data = cfg.gangs and cfg.gangs[gangName]
    if data then
        return data
    end

    if cfg.allowAnyGang == false then
        return nil
    end

    local fallback = cfg.default or {}
    return {
        label = gangLabel or gangName:upper(),
        gif = fallback.gif,
        background = fallback.background or '#111111',
        color = fallback.color or '#ffffff',
        headerColor = fallback.headerColor or '#cfcfcf',
    }
end

function BuildAnnouncementHtml(data, headerLeft, fallbackBg, borderColor)
    local color, headerColor = templateColors(data)
    local backgroundStyle = templateBackground(data, fallbackBg)
    local border = borderColor or "rgba(255, 255, 255, 0.08)"
    local overlay = (data and data.gif) and "" or "box-shadow: inset 0 0 40px rgba(0,0,0,0.45), 0 4px 15px rgba(0,0,0,0.5);"

    return '<div style="' .. backgroundStyle .. ' color: ' .. color .. '; border: 1px solid ' .. border .. '; ' .. ANNOUNCE_CARD_STYLE .. ' ' .. overlay .. '">'
        .. '  <div style="display: flex; justify-content: space-between; align-items: center; gap: 8px; font-size: 10px; color: ' .. headerColor .. '; font-weight: 600; text-transform: uppercase; letter-spacing: 0.3px; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">'
        .. '    <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; min-width: 0;">' .. headerLeft .. '</span>'
        .. '    <span style="flex-shrink: 0; opacity: 0.9;">{2}</span>'
        .. '  </div>'
        .. '  <div style="color: ' .. color .. '; font-size: 12px; font-weight: 700; text-transform: uppercase; line-height: 1.25; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{1}</div>'
        .. '</div>'
end

-- Clear command
if ConfigChat.clearCommand or true then
    RegisterCommand('clear', function(source, args, rawCommand)
        TriggerClientEvent('chat:clear', source)
    end, false)
end

-- Me Command (3D Text Display)
local meConfig = ConfigChat.Me3D or {}
local meLanguage = ConfigChat.Me3DLanguage or 'en'
local meLang = ConfigChat.Me3DLanguages and ConfigChat.Me3DLanguages[meLanguage] or {}

if meLang and meLang.commandName then
    GlobalState.SlashMe = {}

    RegisterCommand(meLang.commandName, function(source, args, rawCommand)
        local text = table.concat(args, " ")
        if text == '' then return end
        if text:find('¦') or text:find('~') then return end
        
        -- Log /me usage
        if GetResourceState('discord-logs') == 'started' then
            pcall(function()
                exports['discord-logs']:LogChatMessage(source, "/me " .. text)
            end)
        elseif GetResourceState('ox_lib') == 'started' then
            pcall(function()
                lib.logger(source, '/me Log', '"'..GetPlayerName(source)..'" ['..source..'] said: "'..text..'"')
            end)
        end
        
        GlobalState.SlashMe = {
            text = text,
            target = source
        }
    end, false)
end

-- WL (Job Announcement Command)
if ConfigChat.jobTemplate.enabled then
    RegisterCommand(ConfigChat.jobTemplate.command, function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        local jobName = xPlayer.job and xPlayer.job.name
        local jobLabel = xPlayer.job and xPlayer.job.label or (jobName and jobName:gsub("^%l", string.upper) or "JOB")
        local gradeLabel = xPlayer.job and xPlayer.job.grade_label or "Region 4"
        local message = table.concat(args, " ")
        local time = os.date("%H:%M")

        local jobData = ResolveJobTemplate(jobName, jobLabel)
        if not jobData then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #ff3b30; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] Your job does not have authorization to use this announcement!</div>'
            })
            return
        end

        if message == "" then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #e3a71b; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] Please enter a message! Format: /' .. ConfigChat.jobTemplate.command .. ' [message]</div>'
            })
            return
        end

        local template = BuildAnnouncementHtml(jobData, 'FEED • ' .. jobLabel .. ' | {0} | ' .. gradeLabel)

        TriggerClientEvent('chat:addMessage', -1, {
            template = template,
            args = { xPlayer.getName(), message, time }
        })

        if GetResourceState('discord-logs') == 'started' then
            pcall(function()
                exports['discord-logs']:LogChatMessage(source, "[" .. jobLabel .. "] " .. message)
            end)
        end
    end, false)
end

-- Gang announcement styling is enabled; the slash command is /gang only (kodebykarl-gangsystem).
if ConfigChat.gangTemplate.enabled and type(ConfigChat.gangTemplate.command) == 'string' and ConfigChat.gangTemplate.command ~= '' and ConfigChat.gangTemplate.command ~= 'gang' then
    RegisterCommand(ConfigChat.gangTemplate.command, function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        local gangName = nil
        local gangLabel = nil
        local gradeLabel = nil
        local gangObj = nil

        if type(xPlayer.getGang) == 'function' then
            gangObj = xPlayer.getGang()
        end
        if type(gangObj) ~= 'table' then
            gangObj = xPlayer.gang
        end

        if type(gangObj) == 'table' then
            gangName = gangObj.name
            gangLabel = gangObj.label
            gradeLabel = gangObj.grade_label
        elseif type(gangObj) == 'string' then
            gangName = gangObj
        end

        gangName = type(gangName) == 'string' and gangName:lower() or nil

        local message = table.concat(args, " ")
        local time = os.date("%H:%M")

        if message == "" then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #e3a71b; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] Please enter a message! Format: /' .. ConfigChat.gangTemplate.command .. ' [message]</div>'
            })
            return
        end

        if not gangName or gangName == '' or gangName == 'none' then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #ff3b30; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] You are not assigned to a gang.</div>'
            })
            return
        end

        local gangData = ResolveGangTemplate(gangName, gangLabel)
        if not gangData then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #ff3b30; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] You are not assigned to a gang.</div>'
            })
            return
        end

        gangLabel = gangData.label or gangLabel or gangName:upper()
        gradeLabel = gradeLabel or ""

        local headerLeft = 'FEED • ' .. gangLabel
        if gradeLabel ~= "" then
            headerLeft = headerLeft .. ' | {0} | ' .. gradeLabel
        else
            headerLeft = headerLeft .. ' | {0}'
        end

        local template = BuildAnnouncementHtml(gangData, headerLeft)

        TriggerClientEvent('chat:addMessage', -1, {
            template = template,
            args = { xPlayer.getName(), message, time }
        })

        if GetResourceState('discord-logs') == 'started' then
            pcall(function()
                exports['discord-logs']:LogChatMessage(source, "[" .. gangLabel .. "] " .. message)
            end)
        end
    end, false)
end

-- Admin Command (Admin Announcement)
if ConfigChat.adminTemplate.enabled then
    RegisterCommand(ConfigChat.adminTemplate.command, function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        local playerGroup = xPlayer.getGroup()
        local isAllowed = false

        for _, permission in ipairs(ConfigChat.adminTemplate.permissions) do
            if permission == "group." .. playerGroup then
                isAllowed = true
                break
            end
            if IsPlayerAceAllowed(source, permission) then
                isAllowed = true
                break
            end
        end

        if not isAllowed then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #ff3b30; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] You do not have permission to run this command!</div>'
            })
            return
        end

        local message = table.concat(args, " ")
        local time = os.date("%H:%M")
        if message == "" then 
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #e3a71b; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] Please enter a message! Format: /' .. ConfigChat.adminTemplate.command .. ' [message]</div>'
            })
            return 
        end

        local adminData = ConfigChat.adminTemplate
        local template = BuildAnnouncementHtml(adminData, 'FEED • ADMIN ANNOUNCEMENT | {0}', "#DC143C")

        TriggerClientEvent('chat:addMessage', -1, {
            template = template,
            args = { xPlayer.getName(), message, time }
        })

        if GetResourceState('discord-logs') == 'started' then
            pcall(function()
                exports['discord-logs']:LogChatMessage(source, "[ADMIN] " .. message)
            end)
        end
    end, false)
end

------------------------------------------------------------------
-- Staff helpers
------------------------------------------------------------------
local function isStaffGroup(group, allowedGroups)
    if not group or not allowedGroups then return false end
    for _, g in ipairs(allowedGroups) do
        if g == group then return true end
    end
    return false
end

local function getStaffSources(allowedGroups)
    local list = {}
    for _, xP in ipairs(ESX.GetExtendedPlayers()) do
        if isStaffGroup(xP.getGroup(), allowedGroups) then
            list[#list + 1] = xP.source
        end
    end
    return list
end

------------------------------------------------------------------
-- /staff — public staff announcement (all players see it)
------------------------------------------------------------------
if ConfigChat.staffTemplate and ConfigChat.staffTemplate.enabled then
    RegisterCommand(ConfigChat.staffTemplate.command, function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        if not isStaffGroup(xPlayer.getGroup(), ConfigChat.staffTemplate.groups) then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #ff3b30; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] You do not have permission to use /staff!</div>'
            })
            return
        end

        local message = table.concat(args, " ")
        local time = os.date("%H:%M")
        if message == "" then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #e3a71b; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] Format: /' .. ConfigChat.staffTemplate.command .. ' [message]</div>'
            })
            return
        end

        local data = ConfigChat.staffTemplate
        local rankLabel = (xPlayer.getGroup() or "staff"):gsub("^%l", string.upper)
        local template = BuildAnnouncementHtml(data, 'FEED • STAFF | {0} | ' .. rankLabel, "#7C3AED")

        TriggerClientEvent('chat:addMessage', -1, {
            template = template,
            args = { xPlayer.getName(), message, time }
        })

        if GetResourceState('discord-logs') == 'started' then
            pcall(function()
                exports['discord-logs']:LogChatMessage(source, "[STAFF] " .. message)
            end)
        end
    end, false)
end

------------------------------------------------------------------
-- /staffo — staff-only chat (only staff groups can see)
------------------------------------------------------------------
if ConfigChat.staffOnlyTemplate and ConfigChat.staffOnlyTemplate.enabled then
    RegisterCommand(ConfigChat.staffOnlyTemplate.command, function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end

        if not isStaffGroup(xPlayer.getGroup(), ConfigChat.staffOnlyTemplate.groups) then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #ff3b30; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] You do not have permission to use /staffo!</div>'
            })
            return
        end

        local message = table.concat(args, " ")
        local time = os.date("%H:%M")
        if message == "" then
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="color: #e3a71b; font-weight: bold; background: rgba(0,0,0,0.6); padding: 8px; border-radius: 6px;">[SYSTEM] Format: /' .. ConfigChat.staffOnlyTemplate.command .. ' [message]</div>'
            })
            return
        end

        local data = ConfigChat.staffOnlyTemplate
        local rankLabel = (xPlayer.getGroup() or "staff"):gsub("^%l", string.upper)
        local template = BuildAnnouncementHtml(data, 'STAFF ONLY • {0} | ' .. rankLabel, "#1E3A5F", "rgba(96, 165, 250, 0.35)")

        local staffSources = getStaffSources(ConfigChat.staffOnlyTemplate.groups)
        for i = 1, #staffSources do
            TriggerClientEvent('chat:addMessage', staffSources[i], {
                template = template,
                args = { xPlayer.getName(), message, time }
            })
        end

        if GetResourceState('discord-logs') == 'started' then
            pcall(function()
                exports['discord-logs']:LogChatMessage(source, "[STAFF ONLY] " .. message)
            end)
        end
    end, false)
end
