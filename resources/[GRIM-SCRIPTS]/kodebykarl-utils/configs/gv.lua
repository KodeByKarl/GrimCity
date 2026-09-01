return {
    Enabled = true,
    Command = 'Gv',
    NotifyTitle = 'GIVE ITEM',
    MaxAmount = 50,
    --- ESX groups allowed to use /Gv (server-enforced)
    AllowedGroups = {
        owner = true,
        developer = true,
    },
    --- Whitelisted box items staff can give (server rejects anything else)
    Items = {
        'betabox',
        'ayuda_box',
        'old_player_box',
        'hightable_box1',
        'hightable_box2',
        'hightable_box3',
        'hightable_box4',
        'panties', -- test item
    },
}
