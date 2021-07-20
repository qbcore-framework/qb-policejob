function DrawText3D(x, y, z, text)
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

function Input(Titel, Placeholder, MaxLenght)
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

local currentGarage = 1
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if isLoggedIn then
            if PlayerJob.name == "police" then
                local pos = GetEntityCoords(PlayerPedId())

                for k, v in pairs(Config.Locations["duty"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 5 then
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            if not onDuty then
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Get on duty")
                            else
                                DrawText3D(v.x, v.y, v.z, "~r~E~w~ - Get off duty")
                            end
                            if IsControlJustReleased(0, 38) then
                                onDuty = not onDuty
                                TriggerServerEvent("police:server:UpdateCurrentCops")
                                TriggerServerEvent("QBCore:ToggleDuty")
                                TriggerServerEvent("police:server:UpdateBlips")
                                TriggerEvent('qb-policealerts:ToggleDuty', onDuty)
                                if onDuty then
                                    exports["rp-radio"]:GivePlayerAccessToFrequencies(1, 2)
                                else
                                    exports["rp-radio"]:RemovePlayerAccessToFrequencies(1, 2)
                                end
                            end
                        elseif #(pos - vector3(v.x, v.y, v.z)) < 2.5 then
                            DrawText3D(v.x, v.y, v.z, "on/off duty")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["evidence"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 2 then
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.0 then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ -    Evidence stash")
                            if IsControlJustReleased(0, 38) then
                                local drawer = Input("Which drawer do you want to look at?", "", 2)
                                if drawer ~= nil then
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", " 1 | Drawer "..drawer, {
                                        maxweight = 4000000,
                                        slots = 500,
                                    })
                                    TriggerEvent("inventory:client:SetCurrentStash", " 1 | Drawer "..drawer)
                                end
                            end
                        elseif #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "Stash 1")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["evidence2"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 2 then
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.0 then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ - evidence stash")
                            if IsControlJustReleased(0, 38) then
                                local drawer = Input("Which drawer do you want to look at?", "", 2)
                                if drawer ~= nil then
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", " 2 | Drawer "..drawer, {
                                        maxweight = 4000000,
                                        slots = 500,
                                    })
                                    TriggerEvent("inventory:client:SetCurrentStash", " 2 | Drawer "..drawer)
                                end
                            end
                        elseif #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "Stash 2")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["evidence3"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 2 then
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.0 then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Evidence stash")
                            if IsControlJustReleased(0, 38) then
                                local drawer = Input("Which drawer do you want to look at?", "", 2)
                                if drawer ~= nil then
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", " 3 | Drawer "..drawer, {
                                        maxweight = 4000000,
                                        slots = 500,
                                    })
                                    TriggerEvent("inventory:client:SetCurrentStash", " 3 | Drawer "..drawer)
                                end
                            end
                        elseif #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "Stash 3")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["trash"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 2 then
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.0 then
                            DrawText3D(v.x, v.y, v.z, "~r~E~w~ - Bin")
                            if IsControlJustReleased(0, 38) then
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", "policetrash", {
                                    maxweight = 4000000,
                                    slots = 300,
                                })
                                TriggerEvent("inventory:client:SetCurrentStash", "policetrash")
                            end
                        elseif #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "Bin")
                        end
                    end
                end

                for k, v in pairs(Config.Locations["vehicle"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                         if onDuty then
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
                    if #(pos - vector3(v.x, v.y, v.z)) < 4.5 and IsArmoryWhitelist() then
                        if onDuty then
                            if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Armory")
                                if IsControlJustReleased(0, 38) then
                                    SetWeaponSeries()
                                    TriggerServerEvent("inventory:server:OpenInventory", "shop", "police", Config.Items)
                                end
                            elseif #(pos - vector3(v.x, v.y, v.z)) < 2.5 then
                                DrawText3D(v.x, v.y, v.z, "Armory")
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["stash"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 4.5 then
                        if onDuty then
                            if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                                DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Personal stash")
                                if IsControlJustReleased(0, 38) then
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", "policestash_"..QBCore.Functions.GetPlayerData().citizenid)
                                    TriggerEvent("inventory:client:SetCurrentStash", "policestash_"..QBCore.Functions.GetPlayerData().citizenid)
                                end
                            elseif #(pos - vector3(v.x, v.y, v.z)) < 2.5 then
                                DrawText3D(v.x, v.y, v.z, "Personal stash")
                            end  
                        end
                    end
                end

                for k, v in pairs(Config.Locations["fingerprint"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 4.5 then
                        if onDuty then
                            if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
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
                            elseif #(pos - vector3(v.x, v.y, v.z)) < 2.5 then
                                DrawText3D(v.x, v.y, v.z, "Finger scan")
                            end  
                        end
                    end
                end
            else
                Citizen.Wait(2000)
            end
        end
    end
end)

local inFingerprint = false
local FingerPrintSessionId = nil

RegisterNetEvent('police:client:showFingerprint')
AddEventHandler('police:client:showFingerprint', function(playerId)
    openFingerprintUI()
    FingerPrintSessionId = playerId
end)

RegisterNetEvent('police:client:showFingerprintId')
AddEventHandler('police:client:showFingerprintId', function(fid)
    SendNUIMessage({
        type = "updateFingerprintId",
        fingerprintId = fid
    })
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNUICallback('doFingerScan', function(data)
    TriggerServerEvent('police:server:showFingerprintId', FingerPrintSessionId)
end)

function openFingerprintUI()
    SendNUIMessage({
        type = "fingerprintOpen"
    })
    inFingerprint = true
    SetNuiFocus(true, true)
end

RegisterNUICallback('closeFingerprint', function()
    SetNuiFocus(false, false)
    inFingerprint = false
end)

RegisterNetEvent('police:client:SendEmergencyMessage')
AddEventHandler('police:client:SendEmergencyMessage', function(message)
    local coords = GetEntityCoords(PlayerPedId())
    
    TriggerServerEvent("police:server:SendEmergencyMessage", coords, message)
    TriggerEvent("police:client:CallAnim")
end)

RegisterNetEvent('police:client:EmergencySound')
AddEventHandler('police:client:EmergencySound', function()
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNetEvent('police:client:CallAnim')
AddEventHandler('police:client:CallAnim', function()
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

RegisterNetEvent('police:client:ImpoundVehicle')
AddEventHandler('police:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if vehicle ~= 0 and vehicle ~= nil then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerServerEvent("police:server:Impound", plate, fullImpound, price)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
    end
end)

RegisterNetEvent('police:client:CheckStatus')
AddEventHandler('police:client:CheckStatus', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.name == "police" then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                QBCore.Functions.TriggerCallback('police:GetPlayerStatus', function(result)
                    if result ~= nil then
                        for k, v in pairs(result) do
                            TriggerEvent("chatMessage", "STATUS", "warning", v)
                        end
                    end
                end, playerId)
            else
                QBCore.Functions.Notify("No One Nearby", "error")
            end
        end
    end)
end)

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

function MenuOutfits()
    ped = PlayerPedId();
    MenuTitle = "Outfits"
    ClearMenu()
    Menu.addButton("My Outfits", "OutfitsLijst", nil)
    Menu.addButton("Close menu", "closeMenuFull", nil) 
end

function changeOutfit()
	Wait(200)
    loadAnimDict("clothingshirt")    	
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Wait(3100)
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function OutfitsLijst()
    QBCore.Functions.TriggerCallback('apartments:GetOutfits', function(outfits)
        ped = PlayerPedId();
        MenuTitle = "My Outfits :"
        ClearMenu()

        if outfits == nil then
            QBCore.Functions.Notify("You have no outfits saved...", "error", 3500)
            closeMenuFull()
        else
            for k, v in pairs(outfits) do
                Menu.addButton(outfits[k].outfitname, "optionMenu", outfits[k]) 
            end
        end
        Menu.addButton("Back", "MenuOutfits",nil)
    end)
end

function optionMenu(outfitData)
    ped = PlayerPedId();
    MenuTitle = "What now?"
    ClearMenu()

    Menu.addButton("Choose Outfit", "selectOutfit", outfitData) 
    Menu.addButton("Delete Outfit", "removeOutfit", outfitData) 
    Menu.addButton("Back", "OutfitsLijst",nil)
end

function selectOutfit(oData)
    TriggerServerEvent('clothes:selectOutfit', oData.model, oData.skin)
    QBCore.Functions.Notify(oData.outfitname.." chosen", "success", 2500)
    closeMenuFull()
    changeOutfit()
end

function removeOutfit(oData)
    TriggerServerEvent('clothes:removeOutfit', oData.outfitname)
    QBCore.Functions.Notify(oData.outfitname.." is deleted", "success", 2500)
    closeMenuFull()
end

function MenuGarage()
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", nil)
    Menu.addButton("Close menu", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    ped = PlayerPedId();
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Config.Vehicles) do
        Menu.addButton(Config.Vehicles[k], "TakeOutVehicle", k, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
    end
    if IsArmoryWhitelist() then
        for veh, label in pairs(Config.WhitelistedVehicles) do
            Menu.addButton(label, "TakeOutVehicle", veh, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
        end
    end
        
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]

    QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, "PLZI"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        TriggerServerEvent("inventory:server:addTrunkItems", GetVehicleNumberPlateText(veh), Config.CarItems)
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function doCarDamage(currentVehicle, veh)
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

function SetCarItemsInfo()
	local items = {}
	for k, item in pairs(Config.CarItems) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = item.info,
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
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

function IsArmoryWhitelist()
    local retval = false

    if QBCore.Functions.GetPlayerData().job.name == 'police' then
        retval = true
    end

--[[     local citizenid = QBCore.Functions.GetPlayerData().citizenid
    for k, v in pairs(Config.ArmoryWhitelist) do
        if v == citizenid then
            retval = true
            break
        end
    end ]]

    return retval
end

function SetWeaponSeries()
    for k, v in pairs(Config.Items.items) do
        if k < 6 then
            Config.Items.items[k].info.serie = tostring(Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4))
        end
    end
end

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end
