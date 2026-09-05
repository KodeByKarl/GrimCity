fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.7'

author 'NoLimits Scripts'
description 'NoLimits University System (nl-university)'

files {
    'html/index.html',
    'html/bossmenu_dui.html',
    'html/app.js',
    'html/sounds/*.ogg',
    'html/style.css',
    'stream/*.ytd',
    'locales/*.json'
}

ui_page 'html/index.html'

shared_scripts {
    --  '@lation_ui/init.lua', -- if you have lation ui uncomment this line
    '@ox_lib/init.lua', -- and comment this line
    'shared/config.lua',
    'shared/framework.lua',
    'shared/inventory.lua',
    --  '@es_extended/imports.lua' -- REMOVED: crashes on non-ESX servers (qb-core / qb-inventory).
    --                                ESX is initialised manually inside framework.lua instead.
}

client_scripts {
    'client/main.lua',
    'client/locker.lua',
    'client/printer.lua',
    'client/backpack.lua',
    'client/announcement.lua',
    'client/chair.lua',
    'client/bossmenu_monitor.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/locker.lua',
    'server/printer.lua',
    'server/backpack.lua',
    'server/shop.lua',
    'server/announcement.lua',
    'server/updater.lua',
}

dependencies {
    'ox_lib',
    'oxmysql',
    'cr-3dnui',
}

escrow_ignore {
    'shared/config.lua',
    'shared/framework.lua',
    'shared/inventory.lua',
    'client/chair.lua'
}

dependency '/assetpacks'