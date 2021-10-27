convertTable = {
	{
		gta   = '~s~',
		fivem = '^0',
		html  = 'white'
	},
	{
		gta   = '~r~',
		fivem = '^1',
		html  = 'red'
	},
	{
		gta   = '~g~',
		fivem = '^2',
		html  = 'green'
	},
	{
		gta   = '~y~',
		fivem = '^3',
		html  = 'yellow'
	},
	{
		gta   = '~b~',
		fivem = '^4',
		html  = 'blue'
	},
	{
		gta   = '~HUD_COLOUR_BLUELIGHT~',
		fivem = '^5',
		html  = 'lightblue'
	},
	{
		gta   = '~p~',
		fivem = '^6',
		html  = 'Purple'
	},
	{
		gta   = '~w~',
		fivem = '^7',
		html  = 'white'
	},
	{
		gta   = '~o~',
		fivem = '^8',
		html  = 'orange'
	},
	{
		gta   = '~c~',
		fivem = '^9',
		html  = 'Grey'
	},
	{
		gta   = '~u~',
		fivem = '^10',
		html  = 'black'
	}
	
}

--- Convert color from one type to another
---@param message string message to be converted
---@param patternFrom string pattern to be replaced with patternTo : gta | fivem
---@param patternTo string pattern to get replaced with patternFrom : gta | fivem | html
function convertColor(message, patternFrom, patternTo)
	-- this is one of the most scuffed scripts i wrote to this day -_-
	if message then
		local constMessage = message
		if patternFrom then
			if patternFrom ~= 'html' then
				toHtmlData = {}
				for i=1, #convertTable do
					local colorsMetaData = convertTable[i]
					if patternTo ~= 'html' then
						-- look for GTA pattern ~r~
						if string.find(message, colorsMetaData[patternFrom]) then
							message = string.gsub(message, colorsMetaData[patternFrom], colorsMetaData[patternTo] or '')
						end
						-- look for Fivem pattern with escape or it will not work	^1
						if string.find(message, '%'..colorsMetaData[patternFrom]) then
							message = string.gsub(message, '%'..colorsMetaData[patternFrom], colorsMetaData[patternTo] or '')
						end
					else
						-- look for GTA pattern ~r~
						if string.find(message, colorsMetaData[patternFrom]) then
							local first, last = message:find(colorsMetaData[patternFrom])
							table.insert(toHtmlData, {startAt = first, endAt = last, color = colorsMetaData[patternTo]})
						end
						-- look for Fivem pattern with escape or it will not work	^1
						if string.find(message, '%'..colorsMetaData[patternFrom]) then
						--	message = string.gsub(message, '%'..colorsMetaData[patternFrom], colorsMetaData[patternTo] or '')
						end
					end
				end

				if #toHtmlData > 0 then
					message = ''
					for i=1, #toHtmlData do
						local text = constMessage:sub(toHtmlData[i].endAt + 1, toHtmlData[i + 1] and (toHtmlData[i + 1].startAt -1) or constMessage:len())
						local finalText = "<span style='color:"..toHtmlData[i].color..";'>"..text.."</span>"
						message = message .. finalText
					end
				end
			end
		end
	end
	return message
end

if IsDuplicityVersion() then

	function showNotification(playerId, message)
		if not playerId or playerId and playerId == 0 then
			dprint(message, true)
		else
			TriggerClientEvent("mumble-mute:client:showNotification",playerId , message)
		end
	end

	function log(message)
        if message then
            local botProfilePicture = Config.discordLog.botProfilePicture or nil
            local botName = "Mumble-mute"
            local embeds = {
                    {
                        ["title"] = "",
                        ["description"] = convertColor(message, 'fivem', "gta"),
                        ["color"] = 2640854,
                        ["footer"] = {
                            ["text"] = GetCurrentResourceName()
                        },
                    }
                }
            PerformHttpRequest(Config.discordLog.webhook, function(err, text, headers) end, 'POST', json.encode({username = botName, embeds = embeds, avatar_url = botProfilePicture}), { ['Content-Type'] = 'application/json' })
        end
    end

    RegisterNetEvent("mumble-mute:server:log")
    AddEventHandler("mumble-mute:server:log", function(message)
        log(message)
	end)
	
else

	local function addLongString(text)
		for i = 100, string.len(text), 99 do
			local subStr = string.sub(text, i, i + 99)
			AddTextComponentSubstringPlayerName(subStr)
		end
	end

	function showNotification(message)
		if Config.notificationType.GTA then

			AddTextEntry('mumble-mute:ATE:notification', convertColor(message, 'fivem', "gta"))
			BeginTextCommandThefeedPost('mumble-mute:ATE:notification')

			EndTextCommandThefeedPostTicker(true, true)
		end

		if Config.notificationType.chat then
			TriggerEvent('chatMessage', "Mumble-mute ", { 155, 0, 0 }, convertColor(message, "gta",'fivem'))
		end
	end
	
	RegisterNetEvent("mumble-mute:client:showNotification")
  	AddEventHandler("mumble-mute:client:showNotification", function(message)
   	   showNotification(message)
	end)

	function log(message)
		TriggerServerEvent("mumble-mute:server:log", message)
	end

	function showHelpNotification(message)
		AddTextEntry('mumble-mute:ATE:SHN', message)
		DisplayHelpTextThisFrame('mumble-mute:ATE:SHN', false)
	end

	function draw2DText(msg, x, y)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextScale(0.0, 0.30)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
		SetTextCentre(true)
		SetTextEntry("STRING")
		AddTextComponentString(msg)
		if string.len(msg) > 99 then
			addLongString(msg)
		end
		EndTextCommandDisplayText(x, y)
	end

end

function dprint(message, force, logging)
	if Config.debugMode or force then
		Citizen.Trace(convertColor("^4[DEBUG:"..GetCurrentResourceName().."]: ^0"..tostring(message).."~s~\n", "gta", 'fivem'))
		if logging then
			logMessage = "NULL"
			if IsDuplicityVersion() then
				logMessage = "[DEBUG:"..GetCurrentResourceName().."] (serverside log): "..tostring(message).."\n"
			else
				logMessage = "[DEBUG:"..GetCurrentResourceName().."] (client log : #"..GetPlayerServerId(PlayerId()).."): "..tostring(message).."\n"
			end
			log(logMessage)
		end
	end
end

function _lang(str_code, tbl)
	
	local firstStep = Config.languagePack[str_code]
	if firstStep then
		secondStep = Config.languagePack[str_code][Config.language]
		if secondStep and secondStep ~= "" then
			text = secondStep
		elseif Config.languagePack[str_code]['en'] then
			text = Config.languagePack[str_code]['en']
		else
			text = "Translation for ["..str_code.."] not found, neither [en] translation..."
		end
	else
		text = "Translation for ["..str_code.."] not found!"
	end
	local finalText, _ = string.gsub(text, "%$%a+", tbl or {})

	return finalText
end