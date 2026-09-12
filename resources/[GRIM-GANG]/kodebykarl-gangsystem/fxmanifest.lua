fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kodebykarl-gangsystem'
author 'KodeByKarl'
description 'Keydi gang system — ESX gangs, stashes, crafting (Region 1)'
version '1.0.0'

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql',
    'ox_inventory',
    'kodebykarl-ui',
}

provide 'cfx-keydi-gang'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared/main.lua',
    'shared/crafting.lua',
    'shared/region.lua',
}

client_scripts {
    'client/main.lua',
    'client/redzones.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/logs.lua',
    'server/main.lua',
    'server/crafting.lua',
}

exports {
    'GetGangs',
    'GetPlayerGang',
}
