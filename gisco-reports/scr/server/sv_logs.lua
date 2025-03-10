local webhookURL = Config.Reports.WebhookURL

function sendToDiscord(title, description, additionalText, username, avatarURL)
    local embed = {
        {
            ["color"] = 36863,
            ["title"] = title,
            ["description"] = description,
            ["footer"] = {
                ["text"] = additionalText
            }
        }
    }

    local payload = {
        ["username"] = "Gisco Reports", -- Default username
        ["avatar_url"] = "https://i.ibb.co/VcPnhp6y/G-frameworktrans.png", -- Default profile picture
        ["embeds"] = embed
    }

    PerformHttpRequest(webhookURL, function(err, text, headers)
    end, "POST", json.encode(payload), {["Content-Type"] = "application/json"})
end
