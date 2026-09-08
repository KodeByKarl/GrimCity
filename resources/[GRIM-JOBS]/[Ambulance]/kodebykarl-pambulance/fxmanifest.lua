fx_version 'cerulean'
game 'gta5'

name 'kodebykarl-pambulance'
author 'KodeByKarl'
description 'Paleto Ambulance — station (boss, stash, wardrobe, garage). Death/EMS actions stay on kodebykarl-ambulance.'
version '1.0.0'
lua54 'yes'

dependency 'es_extended'
dependency 'ox_lib'
dependency 'kodebykarl-ambulance'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}
