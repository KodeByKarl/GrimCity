fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kodebykarl-airdropv2'
author 'KodeByKarl'
description 'GrimCity airdrop system (Infinity base) with scoreboard sync'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'kodebykarl-ui',
}
