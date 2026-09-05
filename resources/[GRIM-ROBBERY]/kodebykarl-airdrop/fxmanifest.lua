fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kodebykarl-airdrop'
author 'KodeByKarl'
description 'Configurable world-event airdrop system for GrimCity'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@es_extended/imports.lua',
    'server/webhook.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory'
}
