local ESX = exports["es_extended"]:getSharedObject()
local isVisible = false

local function ToggleReport(state, openReport, isAdmin, allReports, adminDutyStatus)
    if isIdentityOpen then return end
    isVisible = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = state and "cfx-keydi-report:show" or "cfx-keydi-report:hide",
        openReport = openReport,
        isAdmin = isAdmin,
        allReports = allReports,
        adminDutyStatus = adminDutyStatus,
        categories = ConfigReport.Categories,
        maxDescription = ConfigReport.MaxDescriptionLength,
        maxTitle = ConfigReport.MaxTitleLength,
    })
end

local function OpenReportMenu()
    ESX.TriggerServerCallback("cfx-keydi-report:getInitialData", function(data)
        if data then
            ToggleReport(true, data.openReport, data.isAdmin, data.allReports, data.adminDutyStatus)
        else
            ToggleReport(true, nil, false, {}, false)
        end
    end)
end

exports("ToggleReport", function(state)
    if state then
        OpenReportMenu()
    else
        ToggleReport(false)
    end
end)

RegisterNUICallback("cfx-keydi-report:close", function(_, cb)
    ToggleReport(false)
    cb("ok")
end)

RegisterNUICallback("cfx-keydi-report:submit", function(data, cb)
    TriggerServerEvent("cfx-keydi-report:submitReport", data)
    cb("ok")
end)

RegisterNUICallback("cfx-keydi-report:sendMessage", function(data, cb)
    TriggerServerEvent("cfx-keydi-report:server:sendMessage", data.playerIdentifier, data.messageText)
    cb("ok")
end)

RegisterNUICallback("cfx-keydi-report:toggleDuty", function(data, cb)
    TriggerServerEvent("cfx-keydi-report:server:toggleDuty", data.status)
    cb("ok")
end)

RegisterNUICallback("cfx-keydi-report:resolveReport", function(data, cb)
    TriggerServerEvent("cfx-keydi-report:server:resolveReport", data.playerIdentifier)
    cb("ok")
end)

RegisterNetEvent("cfx-keydi-report:client:reportSaved", function(report)
    SendNUIMessage({
        action = "cfx-keydi-report:update",
        openReport = report,
    })
end)

RegisterNetEvent("cfx-keydi-report:client:updateReport", function(report)
    SendNUIMessage({
        action = "cfx-keydi-report:updateReport",
        openReport = report,
    })
end)

RegisterNetEvent("cfx-keydi-report:client:reportClosed", function()
    SendNUIMessage({
        action = "cfx-keydi-report:reportClosed",
    })
end)

RegisterNetEvent("cfx-keydi-report:client:adminUpdateReports", function(playerIdentifier, report)
    SendNUIMessage({
        action = "cfx-keydi-report:adminUpdateReport",
        playerIdentifier = playerIdentifier,
        report = report,
    })
end)

RegisterNetEvent("cfx-keydi-report:client:adminRemoveReport", function(playerIdentifier)
    SendNUIMessage({
        action = "cfx-keydi-report:adminRemoveReport",
        playerIdentifier = playerIdentifier,
    })
end)

RegisterCommand(ConfigReport.OpenCommand, function()
    if isVisible then
        ToggleReport(false)
    else
        OpenReportMenu()
    end
end, false)

if ConfigReport.ToggleKey and ConfigReport.ToggleKey ~= "" then
    RegisterKeyMapping(ConfigReport.OpenCommand, "Toggle Player Report Menu", "keyboard", ConfigReport.ToggleKey)
end
