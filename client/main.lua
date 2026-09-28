local QBCore = exports['qb-core']:GetCoreObject()
local isWorking = false
local currentSpot = nil

local RoofLocations = {
    vector3(308.2, -714.5, 38.2),
    vector3(-258.1, -978.3, 31.2),
    vector3(115.4, -883.1, 31.1),
    vector3(-585.3, -711.2, 36.3)
}

CreateThread(function()
    local blip = AddBlipForCoord(338.1, -737.4, 29.3)
    SetBlipSprite(blip, 411)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Dak- & Zonnepanelen Service")
    EndTextCommandSetBlipName(blip)
end)

RegisterCommand('startdakwerk', function()
    local PlayerData = QBCore.Functions.GetPlayerData()

    if PlayerData.job.name ~= "roof_cleaner" then
        QBCore.Functions.Notify("Je bent geen dakreiniger! Haal de baan eerst bij het UWV.", "error")
        return
    end

    if not isWorking then
        isWorking = true
        QBCore.Functions.Notify("Je bent begonnen! Rij naar het gemarkeerde dak.", "success")
        SetNextRoofSpot()
    else
        isWorking = false
        if currentSpot then RemoveBlip(currentSpot.blip) end
        QBCore.Functions.Notify("Je hebt je werkdag beëindigd.", "error")
    end
end)

function SetNextRoofSpot()
    local randomSpot = RoofLocations[math.random(1, #RoofLocations)]
    local blip = AddBlipForCoord(randomSpot.x, randomSpot.y, randomSpot.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 5)
    SetRoute(blip, true)

    currentSpot = { coords = randomSpot, blip = blip }
end

CreateThread(function()
    while true do
        local wait = 1000
        if isWorking and currentSpot then
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local dist = #(pCoords - currentSpot.coords)

            if dist < 3.0 then
                wait = 0
                QBCore.Functions.DrawText3D(currentSpot.coords.x, currentSpot.coords.y, currentSpot.coords.z, "[E] Zonnepanelen Schoonmaken")

                if IsControlJustPressed(0, 38) then
                    RemoveBlip(currentSpot.blip)
                    
                    QBCore.Functions.Progressbar("clean_roof", "Zonnepanelen en dak reinigen...", 7000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "amb@world_human_janitor@male@idle_a",
                        anim = "idle_a",
                        flags = 49,
                    }, {}, {}, function()
                        ClearPedTasks(ped)
                        TriggerServerEvent('qb-roofcleaner:server:payout')
                        SetNextRoofSpot()
                    end)
                end
            end
        end
        Wait(wait)
    end
end)