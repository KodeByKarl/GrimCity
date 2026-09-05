client_script '@Pandorangani/src/include/client.lua'
-- Developed by clxsx999 - C-Scripts --
fx_version "cerulean"
game "gta5"
lua54 "yes"
name "cfx-cs-maps"
author "clxsx999"
version "0.0.1"
this_is_a_map 'yes'

files{
    'timecycle/gabz_timecycle_mods.xml',
    'timecycle/sanhje_prison_timecycle.xml'
}

client_scripts {
    'client/*.lua'
}

data_file 'TIMECYCLEMOD_FILE' 'timecycle/gabz_timecycle_mods.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/sanhje_prison_timecycle.xml'
