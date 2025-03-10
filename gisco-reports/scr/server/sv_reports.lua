ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('gisco-reports:submitReport', function(category, reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.Async.fetchScalar('SELECT COUNT(1) FROM gisco_reports', {}, function(result)
        local maxnumber = tonumber(result) + 1

        MySQL.Async.execute("INSERT INTO gisco_reports (reportnumber, identifier, state, category, reason) VALUES (@reportnumber, @identifier, @state, @category, @reason)", {
            ['@reportnumber'] = maxnumber,
            ['@identifier'] = xPlayer.getIdentifier(),
            ['@state'] = "open", 
            ['@category'] = category,
            ['@reason'] = reason
        }, function(rowsChanged)
            if rowsChanged > 0 then

                TriggerClientEvent('gisco-reports:client:notify', source, 'success', TranslateCap('notify_title'), TranslateCap('report_successfully_sended'), 5000)

                local title = TranslateCap('new_report') .. ": #" .. maxnumber
                local description = TranslateCap('category') .. ": " .. category .. "\n" ..
                                     TranslateCap('reason') .. ": " .. reason .. "\n" ..
                                     TranslateCap('made_by') .. ": " .. GetPlayerName(source)
                local additionalText = TranslateCap('player_ingame_name') .. ": " .. xPlayer.getName()                

                sendToDiscord(title, description, additionalText)

                local xPlayers = ESX.GetPlayers()
                for i=1, #xPlayers do
                    local adminPlayer = ESX.GetPlayerFromId(xPlayers[i])
                    if adminPlayer and adminPlayer.getGroup() == "admin" then
                        TriggerClientEvent('gisco-reports:client:notify', adminPlayer.source, 'info', TranslateCap('notify_title'), TranslateCap('new_report_notify'), 5000)
                    end
                end
            else
                TriggerClientEvent('gisco-reports:client:notify', adminPlayer.source, 'error', 'ERROR', "There is a mistake with this system contact a developer!.", 5000)
            end
        end)        
    end)
end)


RegisterCommand(Config.Reports.CreateReportCommand, function(source)
    if source == 0 then 
        return 
    end
    TriggerClientEvent('gisco-reports:createReportMenu', source)
end)
RegisterCommand(Config.Reports.StaffReportsCommand, function(source)
    if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getGroup() == "admin" then
            MySQL.Async.fetchAll("SELECT reportnumber, identifier, reason, category FROM gisco_reports WHERE state = @state ORDER BY reportnumber", {['@state'] = "open"}, function(result)
                if #result > 0 then
                    local reports = {}
                    local pendingQueries = #result

                    for x = 1, #result do
                        local id = result[x].identifier
                        local player = ESX.GetPlayerFromIdentifier(id)

                        if player then
                            table.insert(reports, {
                                id = result[x].reportnumber,
                                reason = result[x].reason,
                                category = result[x].category,
                                playerId = player.source,
                                name = GetPlayerName(player.source)
                            })
                        else
                        end

                        pendingQueries = pendingQueries - 1
                        if pendingQueries == 0 then
                            TriggerClientEvent("gisco-reports:openMenu", source, reports)
                        end
                    end
                else
                    TriggerClientEvent('gisco-reports:client:notify', source, 'info', TranslateCap('notify_title'), TranslateCap('no_open_reports'), 5000)
                end
            end)
        else 
            TriggerClientEvent('gisco-reports:client:notify', source, 'error', TranslateCap('notify_title'), TranslateCap('no_perms'), 5000)
        end
    end
end)


RegisterNetEvent("gisco-reports:sendMessageToPlayer", function(playerId, message)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayerPed = GetPlayerPed(playerId)

    if targetPlayerPed then
        TriggerClientEvent('gisco-reports:client:notify', playerId, 'info', TranslateCap('notify_title'), TranslateCap('admin_message'), 5000)
    else
        TriggerClientEvent('gisco-reports:client:notify', source, 'error', TranslateCap('notify_title'), TranslateCap('not_online'), 5000)
    end
end)



RegisterNetEvent("gisco-reports:closeReport", function(reportId)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    MySQL.Async.execute("UPDATE gisco_reports SET state = 'closed' WHERE reportnumber = @reportId", {
        ['@reportId'] = reportId
    }, function(affectedRows)
        if affectedRows > 0 then
            if xPlayer then
                TriggerClientEvent('gisco-reports:client:notify', xPlayer.source, 'success', TranslateCap('notify_title'), TranslateCap('report_closed'), 5000)

                local title = TranslateCap('closed_report') .. " : #" .. reportId
                local description = GetPlayerName(xPlayer.source) .. " " .. TranslateCap('has_closed_report')
                local additionalText = ""


                sendToDiscord(title, description, additionalText)
            else
            end
        else
            if xPlayer then
                TriggerClientEvent('gisco-reports:client:notify', xPlayer.source, 'error', TranslateCap('notify_title'), "There was a problem with closing this report.", 5000)
            else
            end
        end
    end)
end)


RegisterCommand(Config.Reports.ClosedReportsCommand, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == "admin" then
        MySQL.Async.fetchAll("SELECT reportnumber, identifier, reason, category FROM gisco_reports WHERE state = @state ORDER BY reportnumber", {['@state'] = "closed"}, function(result)
            if #result > 0 then
                local reports = {}
                local pendingQueries = #result

                for x = 1, #result do
                    local id = result[x].identifier
                    local player = ESX.GetPlayerFromIdentifier(id)

                    if player then
                        table.insert(reports, {
                            id = result[x].reportnumber,
                            reason = result[x].reason,
                            category = result[x].category,
                            playerId = player.source,
                            name = GetPlayerName(player.source) 
                        })
                    else
                        table.insert(reports, {
                            id = result[x].reportnumber,
                            reason = result[x].reason,
                            category = result[x].category,
                            playerId = id,
                            name = "Player Offline"
                        })
                    end

                    pendingQueries = pendingQueries - 1
                    if pendingQueries == 0 then
                        TriggerClientEvent("gisco-reports:openClosedReportsMenu", source, reports)
                    end
                end
            else
                TriggerClientEvent('gisco-reports:client:notify', source, 'info', TranslateCap('notify_title'), TranslateCap('no_closed_reports'), 5000)
            end
        end)
    else 
        TriggerClientEvent('gisco-reports:client:notify', source, 'error', TranslateCap('notify_title'), TranslateCap('no_perms'), 5000)
    end
end)

RegisterNetEvent("gisco-reports:deleteReport", function(reportId)
    local _source = source 

    if not _source or _source == 0 then
        return
    end

    if not reportId or type(reportId) ~= "number" then
        TriggerClientEvent('gisco-reports:client:notify', _source, 'error', TranslateCap('notify_title'), "Ongeldig report ID ontvangen op de server.", 5000)
        return
    end

    MySQL.Async.execute("DELETE FROM gisco_reports WHERE reportnumber = @reportId", {
        ['@reportId'] = reportId
    }, function(affectedRows)
        if affectedRows > 0 then

            -- Stuur de notificatie naar de juiste speler
            TriggerClientEvent('gisco-reports:client:notify', _source, 'success', TranslateCap('notify_title'), TranslateCap('report_deleted'), 5000)
        else
            TriggerClientEvent('gisco-reports:client:notify', _source, 'success', TranslateCap('notify_title'), 'There is a problem with deleting this report.', 5000)
        end
    end)
end)

RegisterNetEvent("gisco-reports:closeAllReports", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    MySQL.Async.execute("UPDATE gisco_reports SET state = 'closed' WHERE state = 'open'", {}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('gisco-reports:client:notify', xPlayer.source, 'success', TranslateCap('notify_title'), TranslateCap('all_reports_closed'), 5000)
        else
            TriggerClientEvent('gisco-reports:client:notify', xPlayer.source, 'error', TranslateCap('notify_title'), TranslateCap('no_reports_to_close'), 5000)
        end
    end)
end)

RegisterNetEvent("gisco-reports:deleteAllClosedReports", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    MySQL.Async.execute("DELETE FROM gisco_reports WHERE state = 'closed'", {}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('gisco-reports:client:notify', xPlayer.source, 'success', TranslateCap('notify_title'), TranslateCap('closed_reports_deleted'), 5000)
        else
            TriggerClientEvent('gisco-reports:client:notify', xPlayer.source, 'error', TranslateCap('notify_title'), TranslateCap('no_reports_to_delete'), 5000)
        end
    end)
end)
