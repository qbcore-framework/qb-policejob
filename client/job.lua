-- Variables
local currentGarage = 1
local inFingerprint = false
local FingerPrintSessionId = nil

-- Functions

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function loadAnimDict(dict) -- interactions, job,
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

local function GetClosestPlayer() -- interactions, job, tracker
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

local function Input(Titel, Placeholder, MaxLenght)
	AddTextEntry('FMMC_KEY_TIP1', Titel)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", Placeholder, "", "", "", MaxLenght)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result --Returns the result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

local function openFingerprintUI()
    SendNUIMessage({
        type = "fingerprintOpen"
    })
    inFingerprint = true
    SetNuiFocus(true, true)
end

local function SetCarItemsInfo()
	local items = {}
	for k, item in pairs(Config.CarItems) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = item.info,
			label = itemInfo["label"],
			description = itemInfo["description"] and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = item.slot,
		}
	end
	Config.CarItems = items
end

local function doCarDamage(currentVehicle, veh)
	smash = false
	damageOutside = false
	damageOutside2 = false 
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if engine < 200.0 then
		engine = 200.0
    end

    if engine  > 1000.0 then
        engine = 950.0
    end

	if body < 150.0 then
		body = 150.0
	end
	if body < 950.0 then
		smash = true
	end

	if body < 920.0 then
		damageOutside = true
	end

	if body < 920.0 then
		damageOutside2 = true
	end

    Citizen.Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.1)
	end
end

function TakeOutImpound(vehicle)
    enginePercent = round(vehicle.engine / 10, 0)
    bodyPercent = round(vehicle.body / 10, 0)
    currentFuel = vehicle.fuel
    local coords = Config.Locations["impound"][currentGarage]
    QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
        QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
            QBCore.Functions.SetVehicleProperties(veh, properties)
            SetVehicleNumberPlateText(veh, vehicle.plate)
            SetEntityHeading(veh, coords.w)
            exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
            doCarDamage(veh, vehicle)
            TriggerServerEvent('police:server:TakeOutImpound',vehicle.plate)
            closeMenuFull()
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
            SetVehicleEngineOn(veh, true, true)
        end, vehicle.plate)
    end, coords, true)
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]
    QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
	    SetCarItemsInfo()
        SetVehicleNumberPlateText(veh, "POL"..tostring(math.random(10000, 99999)))
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        TriggerServerEvent("inventory:server:addTrunkItems", GetVehicleNumberPlateText(veh), Config.CarItems)
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

local function IsArmoryWhitelist() -- being removed
    local retval = false

    if QBCore.Functions.GetPlayerData().job.name == 'police' then
        retval = true
    end
    return retval
end

local function SetWeaponSeries()
    for k, v in pairs(Config.Items.items) do
        if k < 6 then
            Config.Items.items[k].info.serie = tostring(Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4))
        end
    end
end

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-- GUI Menu Functions (being replaced)

function MenuGarage()
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", nil)
    Menu.addButton("Close menu", "closeMenuFull", nil)
end

function VehicleList()
    MenuTitle = "Vehicles:"
    ClearMenu()
    local authorizedVehicles = Config.AuthorizedVehicles[QBCore.Functions.GetPlayerData().job.grade.level]
    for k, v in pairs(authorizedVehicles) do
        Menu.addButton(authorizedVehicles[k], "TakeOutVehicle", k, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
    end
    if IsArmoryWhitelist() then
        for veh, label in pairs(Config.WhitelistedVehicles) do
            Menu.addButton(label, "TakeOutVehicle", veh, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
        end
    end

    Menu.addButton("Back", "MenuGarage",nil)
end

function MenuImpound()
    ped = PlayerPedId();
    MenuTitle = "Impounded"
    ClearMenu()
    Menu.addButton("Police Impound", "ImpoundVehicleList", nil)
    Menu.addButton("Close menu", "closeMenuFull", nil) 
end

function ImpoundVehicleList()
    QBCore.Functions.TriggerCallback("police:GetImpoundedVehicles", function(result)
        ped = PlayerPedId();
        MenuTitle = "Impounded Vehicles:"
        ClearMenu()

        if result == nil then
            QBCore.Functions.Notify("There are no impounded vehicles", "error", 5000)
            closeMenuFull()
        else
            for k, v in pairs(result) do
                enginePercent = round(v.engine / 10, 0)
                bodyPercent = round(v.body / 10, 0)
                currentFuel = v.fuel

                Menu.addButton(QBCore.Shared.Vehicles[v.vehicle]["name"], "TakeOutImpound", v, "Impounded", " Engine: " .. enginePercent .. "%", " Body: " .. bodyPercent.. "%", " Fuel: "..currentFuel.. "%")
            end
        end

        Menu.addButton("Back", "MenuImpound",nil)
    end)
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

-- NUI

RegisterNUICallback('closeFingerprint', function()
    SetNuiFocus(false, false)
    inFingerprint = false
end)

-- Events

RegisterNetEvent('police:client:showFingerprint', function(playerId)
    openFingerprintUI()
    FingerPrintSessionId = playerId
end)

RegisterNetEvent('police:client:showFingerprintId', function(fid)
    SendNUIMessage({
        type = "updateFingerprintId",
        fingerprintId = fid
    })
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNUICallback('doFingerScan', function(data)
    TriggerServerEvent('police:server:showFingerprintId', FingerPrintSessionId)
end)

RegisterNetEvent('police:client:SendEmergencyMessage', function(coords, message)
    TriggerServerEvent("police:server:SendEmergencyMessage", coords, message)
    TriggerEvent("police:client:CallAnim")
end)

RegisterNetEvent('police:client:EmergencySound', function()
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNetEvent('police:client:CallAnim', function()
    local isCalling = true
    local callCount = 5
    loadAnimDict("cellphone@")   
    TaskPlayAnim(PlayerPedId(), 'cellphone@', 'cellphone_call_listen_base', 3.0, -1, -1, 49, 0, false, false, false)
    Citizen.Wait(1000)
    Citizen.CreateThread(function()
        while isCalling do
            Citizen.Wait(1000)
            callCount = callCount - 1
            if callCount <= 0 then
                isCalling = false
                StopAnimTask(PlayerPedId(), 'cellphone@', 'cellphone_call_listen_base', 1.0)
            end
        end
    end)
end)

RegisterNetEvent('police:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
    local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
    local totalFuel = exports['LegacyFuel']:GetFuel(vehicle)
    if vehicle ~= 0 and vehicle then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerServerEvent("police:server:Impound", plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
    end
end)

RegisterNetEvent('police:client:CheckStatus', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.name == "police" then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                QBCore.Functions.TriggerCallback('police:GetPlayerStatus', function(result)
                    if result then
                        for k, v in pairs(result) do
                            QBCore.Functions.Notify(''..v..'')
                        end
                    end
                end, playerId)
            else
                QBCore.Functions.Notify("No One Nearby", "error")
            end
        end
    end)
end)

--Threads

CreateThread(function()
    while true do
        sleep = 2000
        if LocalPlayer.state['isLoggedIn'] and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["duty"]) do
                if #(pos - v) < 5 then
                    sleep = 5
                    if #(pos - v) < 1.5 then
                        if not onDuty then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Go on duty")
                        else
                            DrawText3D(v.x, v.y, v.z, "~r~E~w~ - Go off duty")
                        end
                        if IsControlJustReleased(0, 38) then
                            onDuty = not onDuty
                            TriggerServerEvent("police:server:UpdateCurrentCops")
                            TriggerServerEvent("QBCore:ToggleDuty")
                            TriggerServerEvent("police:server:UpdateBlips")
                        end
                    elseif #(pos - v) < 2.5 then
                        DrawText3D(v.x, v.y, v.z, "on/off duty")
                    end
                end
            end

            for k, v in pairs(Config.Locations["evidence"]) do
                if #(pos - v) < 2 then
                    sleep = 5
                    if #(pos - v) < 1.0 then
                        DrawText3D(v.x, v.y, v.z, "~g~E~w~ -    Evidence stash")
                        if IsControlJustReleased(0, 38) then
                            local drawer = Input("Which drawer do you want to look at?", "", 2)
                            if drawer then
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", " 1 | Drawer "..drawer, {
                                    maxweight = 4000000,
                                    slots = 500,
                                })
                                TriggerEvent("inventory:client:SetCurrentStash", " 1 | Drawer "..drawer)
                            end
                        end
                    elseif #(pos - v) < 1.5 then
                        DrawText3D(v.x, v.y, v.z, "Stash 1")
                    end
                end
            end

            for k, v in pairs(Config.Locations["evidence2"]) do
                if #(pos - v) < 2 then
                    sleep = 5
                    if #(pos - v) < 1.0 then
                        DrawText3D(v.x, v.y, v.z, "~g~E~w~ - evidence stash")
                        if IsControlJustReleased(0, 38) then
                            local drawer = Input("Which drawer do you want to look at?", "", 2)
                            if drawer then
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", " 2 | Drawer "..drawer, {
                                    maxweight = 4000000,
                                    slots = 500,
                                })
                                TriggerEvent("inventory:client:SetCurrentStash", " 2 | Drawer "..drawer)
                            end
                        end
                    elseif #(pos - v) < 1.5 then
                        DrawText3D(v.x, v.y, v.z, "Stash 2")
                    end
                end
            end

            for k, v in pairs(Config.Locations["evidence3"]) do
                if #(pos - v) < 2 then
                    sleep = 5
                    if #(pos - v) < 1.0 then
                        DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Evidence stash")
                        if IsControlJustReleased(0, 38) then
                            local drawer = Input("Which drawer do you want to look at?", "", 2)
                            if drawer then
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", " 3 | Drawer "..drawer, {
                                    maxweight = 4000000,
                                    slots = 500,
                                })
                                TriggerEvent("inventory:client:SetCurrentStash", " 3 | Drawer "..drawer)
                            end
                        end
                    elseif #(pos - v) < 1.5 then
                        DrawText3D(v.x, v.y, v.z, "Stash 3")
                    end
                end
            end

            for k, v in pairs(Config.Locations["trash"]) do
                if #(pos - v) < 2 then
                    sleep = 5
                    if #(pos - v) < 1.0 then
                        DrawText3D(v.x, v.y, v.z, "~r~E~w~ - Bin")
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", "policetrash", {
                                maxweight = 4000000,
                                slots = 300,
                            })
                            TriggerEvent("inventory:client:SetCurrentStash", "policetrash")
                        end
                    elseif #(pos - v) < 1.5 then
                        DrawText3D(v.x, v.y, v.z, "Bin")
                    end
                end
            end

            for k, v in pairs(Config.Locations["vehicle"]) do
                if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                    if onDuty then
                        sleep = 5
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Store vehicle")
                            else
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Vehicles")
                            end
                            if IsControlJustReleased(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                else
                                    MenuGarage()
                                    currentGarage = k
                                    Menu.hidden = not Menu.hidden
                                end
                            end
                            Menu.renderGUI()
                        end
                    end
                end
            end

            for k, v in pairs(Config.Locations["impound"]) do
                if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                    if onDuty then
                        sleep = 5
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Impound Vehicle")
                            else
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Police Impound")
                            end
                            if IsControlJustReleased(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                else
                                    MenuImpound()
                                    currentGarage = k
                                    Menu.hidden = not Menu.hidden
                                end
                            end
                            Menu.renderGUI()
                        end  
                    end
                end
            end

            for k, v in pairs(Config.Locations["helicopter"]) do
                if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                    if onDuty then
                        sleep = 5
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Store helicopter")
                            else
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Take a helicopter")
                            end
                            if IsControlJustReleased(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                else
                                    local coords = Config.Locations["helicopter"][k]
                                    QBCore.Functions.SpawnVehicle(Config.Helicopter, function(veh)
                                        SetVehicleLivery(veh , 0)
                                        SetVehicleMod(veh, 0, 48)
                                        SetVehicleNumberPlateText(veh, "ZULU"..tostring(math.random(1000, 9999)))
                                        SetEntityHeading(veh, coords.w)
                                        exports['LegacyFuel']:SetFuel(veh, 100.0)
                                        closeMenuFull()
                                        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                                        SetVehicleEngineOn(veh, true, true)
                                    end, coords, true)
                                end
                            end
                        end  
                    end
                end
            end

            for k, v in pairs(Config.Locations["armory"]) do
                if #(pos - v) < 4.5 then
                    if onDuty then
                        sleep = 5
                        if #(pos - v) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Armory")
                            if IsControlJustReleased(0, 38) then
                                local authorizedItems = {
                                    label = "Police Armory",
                                    slots = 30,
                                    items = {}
                                }
                                local index = 1
                                for _, armoryItem in pairs(Config.Items.items) do
                                    for i=1, #armoryItem.authorizedJobGrades do
                                        if armoryItem.authorizedJobGrades[i] == PlayerJob.grade.level then
                                            authorizedItems.items[index] = armoryItem
                                            authorizedItems.items[index].slot = index
                                            index = index + 1
                                        end
                                    end
                                end
                                SetWeaponSeries()
                                TriggerServerEvent("inventory:server:OpenInventory", "shop", "police", authorizedItems)
                            end
                        elseif #(pos - v) < 2.5 then
                            DrawText3D(v.x, v.y, v.z, "Armory")
                        end
                    end
                end
            end

            for k, v in pairs(Config.Locations["stash"]) do
                if #(pos - v) < 4.5 then
                    if onDuty then
                        sleep = 5
                        if #(pos - v) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Personal stash")
                            if IsControlJustReleased(0, 38) then
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", "policestash_"..QBCore.Functions.GetPlayerData().citizenid)
                                TriggerEvent("inventory:client:SetCurrentStash", "policestash_"..QBCore.Functions.GetPlayerData().citizenid)
                            end
                        elseif #(pos - v) < 2.5 then
                            DrawText3D(v.x, v.y, v.z, "Personal stash")
                        end
                    end
                end
            end

            for k, v in pairs(Config.Locations["fingerprint"]) do
                if #(pos - v) < 4.5 then
                    if onDuty then
                        sleep = 5
                        if #(pos - v) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Scan fingerprint")
                            if IsControlJustReleased(0, 38) then
                                local player, distance = GetClosestPlayer()
                                if player ~= -1 and distance < 2.5 then
                                    local playerId = GetPlayerServerId(player)
                                    TriggerServerEvent("police:server:showFingerprint", playerId)
                                else
                                    QBCore.Functions.Notify("No one nearby!", "error")
                                end
                            end
                        elseif #(pos - v) < 2.5 then
                            DrawText3D(v.x, v.y, v.z, "Finger scan")
                        end  
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
