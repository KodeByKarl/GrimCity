ConfigReport = {}

ConfigReport.Debug = false
ConfigReport.OpenCommand = "report"
ConfigReport.ToggleKey = ""
ConfigReport.MaxDescriptionLength = 500
ConfigReport.MaxTitleLength = 80
ConfigReport.WebhookConvar = "modules_report_webhook"

ConfigReport.Categories = {
    { id = "bug", label = "Bug Reports" },
    { id = "rp", label = "RP Issues" },
    { id = "other", label = "Others" },
}

ConfigReport.StaffGroups = {
    developer = true,
    owner = true,
    admin = true,
    superadmin = true,
    mod = true,
}
