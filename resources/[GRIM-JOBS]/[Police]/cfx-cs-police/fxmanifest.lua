server_script '@Pandorangani/src/include/server.lua'
client_script '@Pandorangani/src/include/client.lua'
fx_version 'cerulean'

games { 'rdr3', 'gta5' }
author 'Collective'
description 'cfx-cs-police'
version '2.0.0'
lua54 'yes'

ui_page 'web/build/index.html'

shared_scripts{
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts{
    'modules/**/client.lua',
    'client/*.lua'
}

server_script{
    '@oxmysql/lib/MySQL.lua',
    'modules/logs/server.lua',
    'modules/core/server.lua',
    'modules/documents/server.lua',
    'modules/menu/server.lua',
    'modules/zone/server.lua',
}

files {
    'web/build/index.html',
    'web/build/**/*',
}

