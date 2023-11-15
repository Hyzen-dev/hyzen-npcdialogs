RegisterNetEvent('hyzen_dialogs:client:LoadNpcs', function()    
    if not Config.Npcs or type(Config.Npcs) ~= 'table' or #Config.Npcs <= 0 then
        return
    end
    
    for _, npc in pairs(Config.Npcs) do
        print("Name : ")
        print(npc.name)
        -- print(json.encode(npc))
        -- print(npc.coords, npc.heading, npc.model)
        local newNpc = GenerateNpc(npc)
        -- print(newNpc)

        -- if not newNpc or newNpc == 0 then
            -- return
        -- end
        table.insert(npcs, newNpc)
    end
end)

RegisterNetEvent('hyzen_dialogs:client:UnloadNpcs', function()
    for k, v in pairs(npcs) do
        if v and DoesEntityExist(v) then
            DeletePed(v)
        end
    end

    for k, v in pairs(objects) do
        if v and DoesEntityExist(v) then
            DeleteObject(v)
        end
    end
end)