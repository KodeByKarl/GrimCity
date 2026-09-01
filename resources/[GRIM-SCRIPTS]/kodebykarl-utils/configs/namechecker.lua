--[[
    NameChecker — require FiveM display name to match Discord nickname/username.
    See modules/namechecker/README.md for bot setup.
]]
return {
    Enabled = true,

    -- Discord bot (enable Server Members Intent)
    BotToken = 'MTUzNTMwMzIxMTA2ODY5NDUyOQ.GGvn6j.OBVZ2DlCdGNS4R1IzAwF9URZbnL-0R_WJGSsWk',
    GuildID = '1526937565926654065',

    -- Comparison
    CaseInsensitive = true,
    TrimSpaces = true,
    FallbackToUsername = true,
    RequireGuildMembership = true,

    DiscordInvite = 'https://discord.gg/your-invite',

    Messages = {
        Checking = 'Checking Discord name…',
        NoDiscord = 'You must link Discord to FiveM (Settings → Linked Accounts) before joining.\nJoin our Discord: %s',
        NotInGuild = 'You must join our Discord server before connecting.\nInvite: %s',
        ApiError = 'Could not verify your Discord membership right now. Please try again in a moment.',
        Mismatch = 'Your FiveM name does not match your Discord name.\n\nSet your FiveM name to: %s\n(FiveM → Settings → Display Name)\n\nThen reconnect.',
        Accepted = 'Name check passed. Welcome!',
        NotConfigured = 'NameChecker is not configured. Contact staff.',
    },
}
