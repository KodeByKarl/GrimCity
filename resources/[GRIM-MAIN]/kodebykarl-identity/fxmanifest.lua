fx_version 'cerulean'
lua54 'yes'
game { 'gta5' }

author 'KodeByKarl.Net'
description 'Grim City single-character identity and spawn'
version '2.0.0'

provide 'esx_identity'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib',
}
