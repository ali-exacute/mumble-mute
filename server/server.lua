TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local ESXTimeout = {}
local playersData = {}
local playersWithPerms = {}

RegisterCommand('mute', function(source, args, raw)

    if havePermission(source) then

        if args[1] then
            local playerId = tonumber(args[1])
            if playerId then
                if playerId > 0 and GetPlayerName(playerId) then
                    if MumbleIsPlayerMuted(playerId) then
                        showNotification(source, _lang('already_muted'))
                    else
                        MutePlayer(source, playerId)
                    end

                else
                    showNotification(source, _lang('no_player'))
                end
            else
                showNotification(source, _lang('id_not_int'))

            end

        else
            TriggerClientEvent('mumble-mute:client:update', source, playersData, true)
        end

    end

end, false)

RegisterCommand('unmute', function(source, args, raw)

    if havePermission(source) then

        if args[1] then
            local playerId = tonumber(args[1])
            if playerId then
                if playerId > 0 and GetPlayerName(playerId) then
                    if not MumbleIsPlayerMuted(playerId) then
                        showNotification(source, _lang('already_unmuted'))
                    else
                        UnmutePlayer(source, playerId)
                    end

                else
                    showNotification(source, _lang('no_player'))
                end
            else
                showNotification(source, _lang('id_not_int'))

            end

        else
            TriggerClientEvent('mumble-mute:client:update', source, playersData, true)
        end

    end

end, false)

function MutePlayer(source, playerId)
    MumbleSetPlayerMuted(playerId, true)
    if playersData[playerId] then
        playersData[playerId].muted = true
        TriggerClientEvent('mumble-mute:client:update', -1, playersData)
        showNotification(source, _lang('player_muted_admin', { ['$name'] = playersData[playerId].playerName, ['$id'] = playerId }))
        showNotification(playerId, _lang('player_muted_client'))
        log(_lang('log_muted', { ['$name'] = playersData[playerId].playerName, ['$id'] = playerId, ['$adminname'] = GetPlayerName(source), ['$adminid'] = source }))
    end
end

function UnmutePlayer(source, playerId)
    MumbleSetPlayerMuted(playerId, false)
    if playersData[playerId] then
        playersData[playerId].muted = false
        TriggerClientEvent('mumble-mute:client:update', -1, playersData)
        showNotification(source, _lang('player_unmuted_admin', { ['$name'] = playersData[playerId].playerName, ['$id'] = playerId }))
        showNotification(playerId, _lang('player_unmuted_client'))
        log(_lang('log_unmuted', { ['$name'] = playersData[playerId].playerName, ['$id'] = playerId, ['$adminname'] = GetPlayerName(source), ['$adminid'] = source }))
    end
end

function havePermission(playerId)

    if playerId == 0 then   -- console have permission to mute
        return true
    end

    local havePerm = false

    if ESX then
        SetTimeout(5000, function()
            ESXTimeout[playerId] = true
        end)
        while not ESX.GetPlayerFromId(playerId) do  -- workaround for multicharacter system on ESX
            Wait(10)
            if ESXTimeout[playerId] then
                ESXTimeout[playerId] = nil
                break
            end
        end
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local xpGroup = xPlayer.group
            for rank, perms in pairs(Config.ESX_permissions) do
                if xpGroup == rank then
                    havePerm = perms
                    break
                end
            end

        end
    end

    if QBCore then
        local QBC_group = QBCore.Functions.GetPermission(playerId)
        for rank, perms in pairs(Config.QBCore_permissions) do
            if QBC_group == rank then
                havePerm = perms
                break
            end
        end
    end

    local ids = GetPlayerIdentifiers(playerId)
    for i=1, #ids do
        local identifier = ids[i]
        if Config.permissions[identifier] then
            havePerm = Config.permissions[identifier]
            break
        end
    end

    return havePerm

end

RegisterNetEvent('mumble-mute:server:getFirstjoinData', function()
    local source = source
    local permission = havePermission(source)

    playersData[source] = {
        playerName = GetPlayerName(source),
        muted = MumbleIsPlayerMuted(source),
        permission = permission
    }

    TriggerClientEvent('mumble-mute:client:receiveFirstjoinData', source, playersData, permission)
end)

RegisterNetEvent('mumble-mute:server:un-mutePlayer', function(playerId, mute)
    if playersData[source].permission then
        if mute then
            MutePlayer(source, playerId)
        else
            UnmutePlayer(source, playerId)
        end
    else
        log(_lang('log_mute_noperm', { ['$name'] = playersData[playerId].playerName, ['$id'] = playerId }))
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    if playersData[source] then
        playersData[source] = nil
    end
end)