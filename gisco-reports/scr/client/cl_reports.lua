ESX = nil
ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Reports.CreateReportCommand, TranslateCap('create_report_suggestion'))
    TriggerEvent('chat:addSuggestion', '/' .. Config.Reports.StaffReportsCommand, TranslateCap('staff_report_suggestion'))
    TriggerEvent('chat:addSuggestion', '/' .. Config.Reports.ClosedReportsCommand, TranslateCap('closed_report_suggestion'))
end)

RegisterNetEvent("gisco-reports:openMenu", function(reports)
    local options = {}

    for _, report in ipairs(reports) do
        table.insert(options, {
            title = TranslateCap('report_id') .. ": " .. report.id,
            icon = 'fas fa-list-check',
            description = 
             TranslateCap('made_by') .. ": " .. report.name ..
            "\n" .. TranslateCap('category') .. ": " .. (report.category or TranslateCap('unknown')) ..
            "\n" .. TranslateCap('reason') .. ": " .. report.reason,
            onSelect = function()
                showReportOptions(report.id, report.playerId)
            end
        })
    end

    table.insert(options, {
        title = TranslateCap('close_all_reports'),
        icon = 'fas fa-ban',
        onSelect = function()
            TriggerServerEvent("gisco-reports:closeAllReports")
        end
    })

    if #options > 0 then
        lib.registerContext({
            id = 'reportmenu',
            title = TranslateCap('context_title'),
            options = options
        })

        lib.showContext('reportmenu')
    else
        TriggerEvent('gisco-reports:client:notify', 'info', TranslateCap('notify_title'), TranslateCap('no_reports_available'), 5000)
    end
end)

function showReportOptions(reportId, playerId)
    local options = {
        {
            title = TranslateCap('player_actions'),
            icon = 'fas fa-user',
            onSelect = function()
                ExecuteCommand('tx ' .. playerId)
            end
        },
        {
            title = TranslateCap('close_report'),
            icon = 'fas fa-circle-xmark',
            onSelect = function()
                TriggerServerEvent("gisco-reports:closeReport", reportId)
            end
        }
    }

    lib.registerContext({
        id = 'reportOptions',
        title = TranslateCap('options_reportid_title') .. reportId,
        menu = 'reportmenu',
        options = options
    })

    lib.showContext('reportOptions')
end

RegisterNetEvent("gisco-reports:createReportMenu", function()
    local categories = Config.Reports.ReportCategories or {}
    local categoryOptions = {}
    for _, category in ipairs(categories) do
        table.insert(categoryOptions, {label = category.label, value = category.value})
    end

    local input = lib.inputDialog('Report Menu', {
        {
            type = 'select',
            label = TranslateCap('category_reportmenu'),
            description = TranslateCap('category_reportmenu_desc'),
            options = categoryOptions, 
            required = true
        },
        {
            type = 'textarea',
            label = TranslateCap('reason_reportmenu'),
            description = TranslateCap('reason_reportmenu_desc'),
            required = true,
            min = 1,
            max = 150
        }
    })

    if not input then return end

    TriggerServerEvent("gisco-reports:submitReport", input[1], input[2])
end)


function GetPlayerFromName(playerName)
    for _, playerId in ipairs(GetPlayers()) do
        if GetPlayerName(playerId) == playerName then
            return playerId
        end
    end
    return nil
end


RegisterNetEvent("gisco-reports:openClosedReportsMenu", function(reports)
    if #reports == 0 then
        TriggerEvent('gisco-reports:client:notify', 'info', TranslateCap('notify_title'), TranslateCap('no_closed_reports'), 5000)
        return
    end

    local options = {}

    for _, report in ipairs(reports) do
        table.insert(options, {
            title = TranslateCap('report_id') .. ": " .. report.id,
            icon = 'fas fa-list-check',
description =  TranslateCap('made_by') .. ": " .. report.name ..
"\n" .. TranslateCap('category') .. ": " .. (report.category or TranslateCap('unknown')) ..
"\n" .. TranslateCap('reason') .. ": " .. report.reason,
            args = {
                reportId = report.id,
                playerId = report.playerId,
            },
            onSelect = function(data)
                local selectedReportId = data.reportId

                if not selectedReportId or type(selectedReportId) ~= "number" then
                    print("ERROR: Invalid report ID selected", selectedReportId)
                    TriggerEvent('gisco-reports:client:notify', 'error', TranslateCap('notify_title'), "Ongeldig report ID geselecteerd.", 5000)
                    return
                end

                local menuOptions = {
                    {
                        title = TranslateCap('delete_report'),
                        icon = 'fas fa-circle-xmark',
                        onSelect = function()
                            TriggerServerEvent("gisco-reports:deleteReport", selectedReportId)
                        end
                    }
                }

                lib.registerContext({
                    id = "reportActions_" .. selectedReportId,
                    title = TranslateCap('report_actions'),
                    menu = 'closedReportsMenu',
                    options = menuOptions
                })
                lib.showContext("reportActions_" .. selectedReportId)
            end
        })
    end

    table.insert(options, {
        title = TranslateCap('delete_all_closed_reports'),
        icon = 'fas fa-ban',
        onSelect = function()
            TriggerServerEvent("gisco-reports:deleteAllClosedReports")
        end
    })

    lib.registerContext({
        id = "closedReportsMenu",
        title = TranslateCap('closed_reports'),
        options = options
    })

    lib.showContext("closedReportsMenu")
end)


