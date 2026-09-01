Config = Config or {}

Config.GiveCar = {
    Command = 'givecar',
    -- Groups allowed to use /givecar (ESX getGroup)
    Groups = { 'superadmin', 'owner', 'developer' },
    -- Must match a jg-advancedgarages public garage name
    GarageId = 'Legion Square',
    NotificationTitle = 'GIVE CAR',
}
