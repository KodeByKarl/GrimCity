fx_version 'cerulean'
lua54 'yes'
game { 'gta5' }

author 'KodeByKarl.Net'
description 'Grim School Roleplay Standalone Multicharacter System'
version '1.0.0'

provide 'esx_multicharacter'
provide 'esx_identity'

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/**/*',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
    'client/nui.lua',
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
