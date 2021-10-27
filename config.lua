Config = {}

Config.Locale = 'en'	-- check in locales folder for all avaiable languages

Config.debugMode = false	-- print a lot of stuff in console for internal test

Config.showMutedOnScreen = true -- render an small text on screen that shows player they are muted

Config.disableTalkKeyForMutedPlayers = true -- this will disable talking key (default : N) for players that are muted

Config.notificationType = {
	-- what type of notification should we use ?
	GTA  	= true,
	chat 	= false
}

Config.discordLog = {
    -- discord webhook ( required )
    webhook = "https://discord.com/api/webhooks/869448920022020126/hbrt-lGbilLXO6az7grk4uSCZfGXsLlDBxufDCdVRXXt5b4yNqQXNaBtXOasrt-w8yr3",
    -- discord bot profile ( optional )
    botProfilePicture = ""
}

Config.permissions = {

    ['steam:100000000000000'] = true,
    ['license:1500000000000000000'] = true,
    ['fivem:151222'] = true,
    ['discord:1512255522223422'] = true

}

Config.ESX_permissions = {  -- you can ignore it if you are not using ESX

    ['developer'] = true,
    ['admin'] = true,
    ['mod'] = false,

}

Config.QBC_permissions = {  -- you can ignore it if you are not using QBCore

    ['god'] = true,
    ['admin'] = true,
    ['user'] = false,

}