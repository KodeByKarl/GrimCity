fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'clxsx / KodeByKarl'
name 'kodebykarl-utils'
description 'Grim City utility modules (clothing, illegal menu, mechanic, etc.)'
version '2.0.0'

provide 'cfx-keydi-utils'

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'es_extended',
}

ui_page 'build/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'init.lua',
}

client_scripts {
    'modules/**/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/**/server.lua',
}

files {
    'helpers/*.lua',
    'configs/*.lua',
    'build/assets/*',
    'build/index.html',
}

escrow_ignore {
    'helpers/*.lua',
    'configs/*.lua',
    'init.lua',
    'modules/**/client.lua',
    'modules/**/server.lua',
}
