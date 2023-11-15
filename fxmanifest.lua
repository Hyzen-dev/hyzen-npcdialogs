fx_version 'adamant'
games { 'gta5' }

author 'Hyzen Team'

description 'Hyzen Dialogs : You can create your own dialogs between players and NPCs'

shared_scripts {
    'shared/config.lua',
    'locale/*.lua',
    'shared/locale.lua',
};

client_scripts {
    'client/variables.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/main.lua'
};