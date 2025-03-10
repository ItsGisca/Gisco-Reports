Config = {}
Config.Locale = 'en' -- /"en"/"nl"/
Config.Notify = 'ox' -- /"esx"/"ox"/"okok"/"a-notify"/"custom"/

Config.Reports = {
    -- Discord Webhook Url
    WebhookURL = "PLACE_YOUR_WEBHOOK_HERE",

    -- Categories for reports
    ReportCategories = {
        {label = 'Player Report', value = "Player Report"},
        {label = 'Question', value = "Question"},
        {label = 'Bug Report', value = "Bug Report"},
    },

    -- Commands
    CreateReportCommand = "report", -- For creating a report
    StaffReportsCommand = "reports", -- For checking reports | ADMIN
    ClosedReportsCommand = "closedreports", -- For checking closed reports

}