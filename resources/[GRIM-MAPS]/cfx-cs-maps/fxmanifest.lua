client_script '@Pandorangani/src/include/client.lua'
-- Developed by clxsx999 - C-Scripts --
fx_version "cerulean"
game "gta5"
lua54 "yes"
name "cfx-cs-maps"
author "clxsx999"
version "0.0.1"
this_is_a_map 'yes'

files {
    'timecycle/gabz_timecycle_mods.xml',
    'timecycle/sanhje_prison_timecycle.xml',
    'audio/86AC3600_game.dat151.rel',
    'audio/95BA89A9_game.dat151.rel',
    'audio/B2EC67AA_game.dat151.rel',
    'audio/B7820164_game.dat151.rel',
    'audio/D2000800_game.dat151.rel',
    'audio/door_neox_sheriff-hospital_game.dat151.rel',
    'audio/mrpd_door_sound_game.dat151.rel'
}

client_scripts {
    'client/*.lua'
}

data_file 'TIMECYCLEMOD_FILE' 'timecycle/gabz_timecycle_mods.xml'
data_file 'TIMECYCLEMOD_FILE' 'timecycle/sanhje_prison_timecycle.xml'

data_file 'AUDIO_GAMEDATA' 'audio/86AC3600_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/95BA89A9_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/B2EC67AA_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/B7820164_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/D2000800_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/door_neox_sheriff-hospital_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/mrpd_door_sound_game.dat'