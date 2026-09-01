server_script '@Pandorangani/src/include/server.lua'
client_script '@Pandorangani/src/include/client.lua'
fx_version 'cerulean'

games {'gta5'}
author 'clxsx'
name 'cfx-keydi-utils'
description 'cfx-keydi-utils'
version '2.0.0'
lua54 'yes'

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'es_extended',
}

ui_page 'build/index.html'

shared_scripts{
    '@ox_lib/init.lua',
    'init.lua' 
}

client_scripts{
    'configs/*.lua',
    'modules/**/client.lua',
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'configs/*.lua',
    'modules/**/server.lua'
}

files {
    'helpers/*.lua',
    'configs/*.lua',
    'build/assets/*',
    'build/index.html'
}

escrow_ignore{
    'helpers/*.lua',
    'configs/*.lua',
    'init.lua',
    'modules/**/server.lua'
}
