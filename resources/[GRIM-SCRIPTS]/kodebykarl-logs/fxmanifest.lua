fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kodebykarl-logs'
author 'KodeByKarl'
description 'Universal Discord logging for Grim City'
version '1.0.0'

provide 'discord-logs'

shared_script 'config.lua'

server_scripts {
    'server/discord.lua',
    'server/api.lua',
    'server/player.lua',
    'server/inventory.lua',
}
