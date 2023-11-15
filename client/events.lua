AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        print("Hyzen Dialogs started")
        LoadFramework()
        
        while not Framework do
            if Config.Framework:lower() == 'qbcore' then
                Framework = exports['qb-core']:GetCoreObject()
            elseif Config.Framework:lower() == 'esx' then
                Framework = exports['es_extended']:getSharedObject()
            end
            Citizen.Wait(1)
        end
        TriggerEvent('hyzen_dialogs:client:LoadNpcs')
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerEvent('hyzen_dialogs:client:UnloadNpcs')
    end
end)

if Config.Framework == 'qbcore' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        LoadFramework()

        while not Framework do
            Framework = exports['qb-core']:GetCoreObject()
            Citizen.Wait(1)
        end

        TriggerEvent('hyzen_dialogs:client:LoadNpcs')
    end)
elseif Config.Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function()
        LoadFramework()

        while not Framework do
            Framework = exports['es_extended']:getSharedObject()
            Citizen.Wait(1)
        end
        TriggerEvent('hyzen_dialogs:client:LoadNpcs')
    end)
end
