local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-roofcleaner:server:payout', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player and Player.PlayerData.job.name == 'roof_cleaner' then
        local reward = math.random(180, 320)
        Player.Functions.AddMoney('bank', reward, "dak-schoongemaakt")
        TriggerClientEvent('QBCore:Notify', src, "Dak & zonnepanelen gereinigd! Je hebt €" .. reward .. " ontvangen op je bank.", "success")
    end
end)