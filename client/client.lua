local havePerm = nil
local playersData = {}
Citizen.CreateThread(function()
    while true do
        Wait(100)
        if NetworkIsPlayerActive(PlayerId()) then
			TriggerServerEvent('mumble-mute:server:getFirstjoinData')
			break
		end
    end
    localServerId = GetPlayerServerId(PlayerId())
end)

RegisterNetEvent('mumble-mute:client:update', function(playersList, openMenu)
    playersData = playersList

    if openMenu then
        if havePerm then
            WarMenu.OpenMenu('main')
        end
    end

end)

RegisterNetEvent('mumble-mute:client:receiveFirstjoinData', function(playersList, perms)
    playersData = playersList
    if perms then
        havePerm = perms
    end
    mainLoop()
end)


---- Menu : 
WarMenu.CreateMenu('main', _lang('mainmenu_title'), _lang('mainmenu_subtitle'))

WarMenu.CreateSubMenu('players_menu', 'main', _lang('playermenu_title'), _lang('playermenu_subtitle'))
WarMenu.CreateSubMenu('searched_players', 'main', _lang('searchmenu_title'), _lang('searchmenu_subtitle'))

function mainLoop()
    if havePerm then
        CreateThread(function()
            while true do

                if WarMenu.Begin('main') then

                    WarMenu.MenuButton(_lang('menubtn_onlineplayers'), 'players_menu', '→→→')

                    local anyInput, inputText = WarMenu.InputButton(_lang('menubtn_searchplayers'), nil, nil, 10, 2, nil)
                    if anyInput and inputText then

                        searchedPlayers = {}

                        for playerId, playerData in pairs(playersData) do

                            if string.find(string.lower(playerData.playerName), string.lower(inputText)) then
                                table.insert(searchedPlayers, playerId)
                            end
                        
                        end
                        if #searchedPlayers > 0 then
                            WarMenu.OpenMenu('searched_players')
                        else
                            showNotification(_lang('search_nohit'))
                        end
                    end

                    WarMenu.End()

                end

                if WarMenu.Begin('players_menu') then

                    for playerId, playerData in pairs(playersData) do

                        local keyPressed = WarMenu.Button(playerData.playerName, playerId)
	        		    if WarMenu.IsItemHovered() then
                            if playerData.muted then
                                WarMenu.ToolTip(_lang('playermenu_mute'))
                            else
	        		    	    WarMenu.ToolTip(_lang('playermenu_unmute'))
                            end
	        		    end
                        if keyPressed == 'right' or keyPressed == 'select' then
                            TriggerServerEvent('mumble-mute:server:un-mutePlayer', playerId, not playerData.muted)
                        elseif keyPressed == 'left' then
                            WarMenu.GoBack()
                        end
                    end

                    WarMenu.End()
                end

                if WarMenu.Begin('searched_players') then

                    for i=1, #searchedPlayers do
                        local playerData = playersData[i]
                        local keyPressed = WarMenu.Button(playerData.playerName, i)
	        		    if WarMenu.IsItemHovered() then
	        		    	if playerData.muted then
	        		    	    WarMenu.ToolTip(_lang('playermenu_mute'))
                            else
                                WarMenu.ToolTip(_lang('playermenu_unmute'))
                            end
	        		    end
                        if keyPressed == 'right' or keyPressed == 'select' then
                            TriggerServerEvent('mumble-mute:server:un-mutePlayer', i, not playerData.muted)

                        elseif keyPressed == 'left' then
                            WarMenu.GoBack()
                        end

                    end

                    WarMenu.End()
                end

                Wait(5)
            end
        end)
    end
end

if Config.showMutedOnScreen or Config.disableTalkKeyForMutedPlayers then

    CreateThread( function()

        while true do
            Wait(5)
            if playersData[localServerId] then
                if playersData[localServerId].muted then

                    if Config.showMutedOnScreen then
                        draw2DText(_lang('player_canttalk'), 0.085, 0.82)   -- message, x, y (change it if you wanna change the message location on screen)
                    end

                    if Config.disableTalkKeyForMutedPlayers then
                        DisableControlAction(0, 249, true)
                    end

                else
                    Wait(100)
                end
            else
                Wait(100)
            end
        end

    end)

end

-- exports

function IsPlayerMuted(playerId)
    if playersData[playerId] then
        return playersData[playerId].muted
    end
    return nil
end

exports('IsPlayerMuted', IsPlayerMuted)