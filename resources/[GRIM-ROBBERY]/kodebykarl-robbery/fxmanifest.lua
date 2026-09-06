fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

name 'kodebykarl-robbery'
author 'KodeByKarl'
description 'Heists, house robbery, and interior shells'
version '1.0.0'

provide 'cfx-cs-robbery'
provide 'cfx-cs-interior'

shared_scripts {
    '@ox_lib/init.lua',
    'init.lua',
    'shared/*.lua'
}

client_scripts {
    'modules/interior/main.lua',
    'modules/interior/optional.lua',
    'modules/**/client.lua'
}

server_scripts {
    'modules/**/server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory'
}
