fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'NoLimits Scripts'
description 'Placeable whiteboards with gizmo placement, item-based, draw support'
version '3.0'

dependencies {
  'cr-3dnui',
  'ox_lib',
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'shared/inventory_bridge.lua',
}

client_scripts {
  'client/dataview.lua',
  'client/gizmo.lua',
  'client/main.lua',
  'client/placement.lua',
}

server_scripts {
  'server/main.lua',
}

ui_page 'html/blank.html'

files {
  'html/blank.html',
  'html/index.html',
  'html/style.css',
  'html/app.js',
}

dependency '/assetpacks'