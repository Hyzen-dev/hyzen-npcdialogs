function LoadFramework()
    Citizen.CreateThread(function()
        if Config.Framework:lower() == 'qbcore' then
            if GetResourceState('qb-core') ~= 'started' then
                if GetResourceState('es_extended') == 'started' then
                    print(Locale['errors']['another_framework_detected']:format('es_extended'))
                    Config.Framework = 'esx'
                    Framework = exports['es_extended']:getSharedObject()
                    while not Framework do
                        Framework = exports['es_extended']:getSharedObject()
                        Citizen.Wait(1)
                    end
                else
                    print(Locale['errors']['framework_not_found']:format('qbcore'))
                    return
                end
            else
                while not Framework do
                    Framework = exports['qb-core']:GetCoreObject()
                    Citizen.Wait(1)
                end
                Framework = exports['qb-core']:GetCoreObject()
            end
        elseif Config.Framework:lower() == 'esx' then
            if GetResourceState('es_extended') ~= 'started' then
                if GetResourceState('qb-core') == 'started' then
                    print(Locale['errors']['another_framework_detected']:format('qbcore'))
                    Config.Framework = 'qbcore'
                    Framework = exports['qb-core']:GetCoreObject()
                    while not Framework do
                        Framework = exports['qb-core']:GetCoreObject()
                        Citizen.Wait(1)
                    end
                else
                    print(Locale['errors']['framework_not_found']:format('es_extended'))
                    return
                end
            else
                while not Framework do
                    Framework = exports['es_extended']:getSharedObject()
                    Citizen.Wait(1)
                end
                Framework = exports['es_extended']:getSharedObject()
            end
        else
            print(Locale['errors']['no_framework_found']:format(Config.Framework))
            return
        end
        return
    end)
end

function ShowHelpNotification(msg, playerPed)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function ShowAdvancedNotification(title, subject, msg, icon, iconType)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(msg)
    SetNotificationMessage(icon, icon, false, iconType, title, subject)
    DrawNotification(false, true)
end

function GetPedMugshot(ped)
    local mugshot = RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Citizen.Wait(0)
    end

    return mugshot, GetPedheadshotTxdString(mugshot)
end

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = (string.len(text)) / 370

    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
end

function GenerateNpc(npc)
    if not npc or not npc["dialog"] or not npc["coords"] or not npc["heading"] or not npc["model"] then
        return
    end

    local npcCoords, npcHeading, npcModel, npcDialog = npc["coords"], npc["heading"], npc["model"], npc["dialog"]
    local npcAnimated, npcAnimationDict, npcAnimation = npc["hasAnimation"], npc["animationDict"], npc["animation"]
    local npcWeapon, npcHasWeapon = npc["weapon"], npc["hasWeapon"]
    local npcObject, npcHasObject = npc["object"], npc["hasObject"]

    local model = GetHashKey(npcModel)
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(500)
    end
    local ped = CreatePed(4, model, npcCoords.x, npcCoords.y, npcCoords.z - 0.98, npcHeading, false, false)

    SetEntityInvincible(ped, true)
    SetEntityHeading(ped, npcHeading)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if npcAnimated then
        RequestAnimDict(npcAnimationDict)

        while not HasAnimDictLoaded(npcAnimationDict) do
            Wait(500)
        end

        TaskPlayAnim(ped, npcAnimationDict, npcAnimation, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    end

    if npcHasWeapon and not npcHasObject then
        local weapon = GetHashKey(npcWeapon)

        GiveWeaponToPed(ped, weapon, 1000, false, true)
        SetCurrentPedWeapon(ped, weapon, true)
    elseif npcHasObject and not npcHasWeapon then
        local object = GetHashKey(npcObject)

        RequestModel(object)

        while not HasModelLoaded(object) do
            Wait(500)
        end

        local obj = CreateObject(object, npcCoords.x, npcCoords.y, npcCoords.z - 0.98, true, true, true)

        AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true,
            true, 1, true)

        SetModelAsNoLongerNeeded(object)

        table.insert(objects, obj)
    elseif npcHasObject and npcHasWeapon then
        local weapon = GetHashKey(npcWeapon)

        GiveWeaponToPed(ped, weapon, 1000, false, true)
        SetCurrentPedWeapon(ped, weapon, true)
    end

    SetModelAsNoLongerNeeded(model)

    if not DoesEntityExist(ped) then
        return
    end

    if Config.UseTarget then
        InitializeTarget(npc, ped, npcDialog)
    else
        if npcDialog then
            NpcDialog(ped, npc)
        end
        Citizen.CreateThread(function()
            while true do
                Wait(500)
                playerPed = PlayerPedId()
                if IsEntityDead(ped) then
                    SetTimeout(5000, function()
                        DeletePed(ped)
                    end)
                    Wait(5000)
                    break
                    return
                end
                if not DoesEntityExist(ped) then
                    break
                    return
                end
            end
        end)
    end

    return ped
end

function NpcDialog(ped, npc)
    local sleep = 100
    local isTextVisible = false
    Citizen.CreateThread(function()
        while DoesEntityExist(ped) do
            Citizen.Wait(sleep)

            local playerPed = PlayerPedId()
            local pX, pY, pZ = table.unpack(GetEntityCoords(playerPed))

            local nX, nY, nZ = table.unpack(npc.coords)

            local distance = GetDistanceBetweenCoords(pX, pY, pZ, nX, nY, nZ, true)
            local dialog = Config.Dialogs[npc.dialog]

            if not dialog or type(dialog) ~= 'table' then
                return
            end

            if distance <= (npc.dialogDistance or 2.0) then
                sleep = 0
                if not isDialogActive then
                    if Config.ShowDialogActionType:lower() == 'draw3dtext' then
                        Draw3DText(nX, nY, nZ, Locale['texts']['dialog_action']:format("~b~E~w~", npc.name))
                    elseif Config.ShowDialogActionType:lower() == 'notification' then
                        ShowHelpNotification(Locale['texts']['dialog_action']:format("~INPUT_CONTEXT~", npc.name))
                    elseif Config.ShowDialogActionType:lower() == 'drawtext' then
                        if Config.Framework:lower() == 'qbcore' then
                            exports['qb-core']:DrawText(Locale['texts']['dialog_action']:format("[E]", npc.name),
                                Config.ShowDialogPosition or 'left')
                            isTextVisible = true
                        elseif Config.Framework:lower() == 'esx' then
                            Framework.TextUI(Locale['texts']['dialog_action']:format("[E]", npc.name))
                            isTextVisible = true
                        end
                    end
                else
                    if Config.ShowDialogActionType:lower() == 'drawtext' then
                        if Config.Framework:lower() == 'qbcore' then
                            exports['qb-core']:HideText()
                            isTextVisible = false
                        elseif Config.Framework:lower() == 'esx' then
                            Framework.HideUI()
                            isTextVisible = false
                        end
                    end
                end

                if IsControlJustPressed(0, 38) then
                    ShowFirstDialog(npc, ped, dialog)
                end
            else
                if Config.ShowDialogActionType:lower() == 'drawtext' and isTextVisible then
                    if Config.Framework:lower() == 'qbcore' then
                        exports['qb-core']:HideText()
                        isTextVisible = false
                    elseif Config.Framework:lower() == 'esx' then
                        Framework.HideUI()
                        isTextVisible = false
                    end
                end
                sleep = 100
            end
        end
    end)
end

function ShowFirstDialog(npc, ped, dialog)
    local mugshot, mugshotStr = GetPedMugshot(ped)
    isDialogActive = true
    if Config.DialogDisplayType:lower() == 'mugshot' then
        if not dialog.hasChoices then
            ShowAdvancedNotification(npc.name, Locale['texts']['mugshot_conversation_title'], dialog.noChoiceText,
                mugshotStr, 1)
            isDialogActive = false
        else
            ShowDialog(npc, ped, dialog)
        end
        UnregisterPedheadshot(mugshot)
    elseif Config.DialogDisplayType:lower() == 'text' then
        if not dialog.hasChoices then
            ShowMissionText(dialog.noChoiceText, 5000)
            isDialogActive = false
        else
            ShowDialog(npc, ped, dialog)
        end
    end
end

function ShowDialog(npc, ped, dialog)
    local dialogStep = 1

    if Config.DialogDisplayType == 'mugshot' then
        local mugshot, mugshotStr = GetPedMugshot(ped)
        ShowAdvancedNotification(npc.name, Locale['texts']['mugshot_conversation_title'],
            dialog.dialog[dialogStep].text, mugshotStr, 1)

        UnregisterPedheadshot(mugshot)
    elseif Config.DialogDisplayType == 'text' then
        ShowMissionText(dialog.dialog[dialogStep].text, 5000)
    end

    ShowAnswerMenu(dialog.dialog, dialogStep, ped, npc)
end

function ShowAnswerMenu(dialog, dialogStep, ped, npc)
    if not dialog[dialogStep] then
        return nil
    end

    if Config.DialogAnswerMenu:lower() == 'qb-menu' then
        local responses = {}
        for k, v in pairs(dialog[dialogStep].choices) do
            responses[#responses + 1] = {
                header = v.text,
                params = {
                    event = 'hyzen_dialogs:client:ChooseAnswer', -- event name
                    args = {
                        npc = npc,
                        ped = ped,
                        dialog = dialog,
                        newStep = v.value
                    }
                }
            }
        end
        exports['qb-menu']:openMenu(responses)
    elseif Config.DialogAnswerMenu:lower() == 'esx-menu' then
        local responses = {}
        for k, v in pairs(dialog[dialogStep].choices) do
            responses[#responses + 1] = {
                label = v.text,
                name = k
            }
        end

        Framework.UI.Menu.Open("default", GetCurrentResourceName(), Locale['texts']['esx_menu_title'], {
            title = Locale['texts']['esx_menu_title'],
            align = Config.ShowDialogPosition or 'top-right',
            elements = responses
        }, function(data, menu)
            for k, v in pairs(dialog[dialogStep].choices) do
                if data.current.name == k then
                    menu.close()
                    TriggerEvent('hyzen_dialogs:client:ChooseAnswer', {
                        npc = npc,
                        ped = ped,
                        dialog = dialog,
                        newStep = v.value
                    })
                end
            end
        end)
    end
end

RegisterNetEvent('hyzen_dialogs:client:ChooseAnswer', function(args)
    local npc, ped, dialog, newStep = args.npc, args.ped, args.dialog, args.newStep

    if not dialog or not newStep then
        return
    end

    if newStep == 0 or not dialog[newStep] then
        isDialogActive = false
        return
    end

    if Config.DialogDisplayType == 'mugshot' then
        local mugshot, mugshotStr = GetPedMugshot(ped)
        ShowAdvancedNotification(npc.name, Locale['texts']['mugshot_conversation_title'], dialog[newStep].text,
            mugshotStr, 1)

        UnregisterPedheadshot(mugshot)
    elseif Config.DialogDisplayType == 'text' then
        ShowMissionText(dialog[newStep].text, 5000)
    end

    ShowAnswerMenu(dialog, newStep, ped, npc)
end)

function ShowMissionText(text, time)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(time, 1)
end

function InitializeTarget(npc, ped, dialog)
    local dialog = dialog
    if not ped or ped == 0 then
        return
    end

    dialog = Config.Dialogs[dialog]

    if not dialog or type(dialog) ~= 'table' then
        return
    end

    if Config.TargetScript == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {{
                icon = 'fas fa-comment',
                label = Locale['texts']['target_action_label'],
                action = function(entity)
                    ShowFirstDialog(npc, ped, dialog)
                end
            }},
            distance = npc.dialogDistance or 2.0
        })
    elseif Config.TargetScript == 'ox-target' then
        if NetworkGetEntityIsNetworked(ped) then
            local netId = NetworkGetNetworkIdFromEntity(ped)
            exports.ox_target:addEntity(netId, {
                event = 'hyzen_dialogs:client:ShowFirstDialog',
                args = {
                    npc = npc,
                    ped = ped,
                    dialog = dialog
                },
                label = Locale['texts']['target_action_label'],
                name = "hyzen_dialog:ShowDialog",
                icon = "fas fa-comment",
                distance = npc.dialogDistance or 2.0,
                canInteract = function()
                    return not isDialogActive
                end
            })
        else
            exports.ox_target:addLocalEntity(ped, {
                event = 'hyzen_dialogs:client:ShowFirstDialog',
                args = {
                    npc = npc,
                    ped = ped,
                    dialog = dialog
                },
                label = Locale['texts']['target_action_label'],
                name = "hyzen_dialog:ShowDialog",
                icon = "fas fa-comment",
                distance = npc.dialogDistance or 2.0,
                canInteract = function()
                    return not isDialogActive
                end
            })
        end
    end
end

RegisterNetEvent('hyzen_dialogs:client:ShowFirstDialog', function(data)
    local args = data.args
    local npc, ped, dialog = args.npc, args.ped, args.dialog

    isDialogActive = true
    if not ped or ped == 0 or not dialog or type(dialog) ~= 'table' or not npc or type(npc) ~= 'table' then
        isDialogActive = false
        return
    end
    ShowFirstDialog(npc, ped, dialog)
end)
