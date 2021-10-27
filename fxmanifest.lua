fx_version 'cerulean'

game 'gta5'
author 'Ali Exacute#2588'
discord 'https://discord.com/invite/Mgyg2nVRhC'
description 'Mute player from talking in game'
version '1.0.0'

shared_scripts {
    "config.lua",
	'shared/utils.lua',
	'shared/translations.lua',
}

client_scripts {
    "client/warmenu.lua",
    "client/client.lua",
}

server_scripts {
    "server/server.lua",
}