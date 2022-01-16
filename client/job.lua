-- Variables
local currentGarage = 0
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
	local smash = false
	local damageOutside = false
	local damageOutside2 = false
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0

	if engine < 200.0 then engine = 200.0 end
    if engine  > 1000.0 then engine = 950.0 end
	if body < 150.0 then body = 150.0 end
	if body < 950.0 then smash = true end
	if body < 920.0 then damageOutside = true end
	if body < 920.0 then damageOutside2 = true end

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
    local coords = Config.Locations["impound"][currentGarage]
    if coords then
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
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
            end, vehicle.plate)
        end, coords, true)
    end
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]
    if coords then
        QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
            SetCarItemsInfo()
            SetVehicleNumberPlateText(veh, Lang:t('info.police_plate')..tostring(math.random(1000, 9999)))
            SetEntityHeading(veh, coords.w)
            exports['LegacyFuel']:SetFuel(veh, 100.0)
            closeMenuFull()
            if Config.VehicleSettings[vehicleInfo] ~= nil then
                QBCore.Shared.SetDefaultVehicleExtras(veh, Config.VehicleSettings[vehicleInfo].extras)
            end
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
            TriggerServerEvent("inventory:server:addTrunkItems", QBCore.Functions.GetPlate(veh), Config.CarItems)
            SetVehicleEngineOn(veh, true, true)
        end, coords, true)
    end
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
            Config.Items.items[k].info.serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
        end
    end
end

function MenuGarage(currentSelection)
    local vehicleMenu = {
        {
            header = Lang:t('menu.garage_title'),
            isMenuHeader = true
        }
    }

    local authorizedVehicles = Config.AuthorizedVehicles[QBCore.Functions.GetPlayerData().job.grade.level]
    for veh, label in pairs(authorizedVehicles) do
        vehicleMenu[#vehicleMenu+1] = {
            header = label,
            txt = "",
            params = {
                event = "police:client:TakeOutVehicle",
                args = {
                    vehicle = veh,
                    currentSelection = currentSelection
                }
            }
        }
    end

    if IsArmoryWhitelist() then
        for veh, label in pairs(Config.WhitelistedVehicles) do
            vehicleMenu[#vehicleMenu+1] = {
                header = label,
                txt = "",
                params = {
                    event = "police:client:TakeOutVehicle",
                    args = {
                        vehicle = veh,
                        currentSelection = currentSelection
                    }
                }
            }
        end
    end

    vehicleMenu[#vehicleMenu+1] = {
        header = Lang:t('menu.close'),
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }

    }
    exports['qb-menu']:openMenu(vehicleMenu)
end

function MenuImpound(currentSelection)
    local impoundMenu = {
        {
            header = Lang:t('menu.impound'),
            isMenuHeader = true
        }
    }
    QBCore.Functions.TriggerCallback("police:GetImpoundedVehicles", function(result)
        local shouldContinue = false
        if result == nil then
            QBCore.Functions.Notify(Lang:t("error.no_impound"), "error", 5000)
        else
            shouldContinue = true
            for _ , v in pairs(result) do
                local enginePercent = QBCore.Shared.Round(v.engine / 10, 0)
                local bodyPercent = QBCore.Shared.Round(v.body / 10, 0)
                local currentFuel = v.fuel
                local vname = QBCore.Shared.Vehicles[v.vehicle].name

                impoundMenu[#impoundMenu+1] = {
                    header = vname.." ["..v.plate.."]",
                    txt =  Lang:t('info.vehicle_info', {value = enginePercent, value2 = currentFuel}),
                    params = {
                        event = "police:client:TakeOutImpound",
                        args = {
                            vehicle = v,
                            currentSelection = currentSelection
                        }
                    }
                }
            end
        end


        if shouldContinue then
            impoundMenu[#impoundMenu+1] = {
                header = Lang:t('menu.close'),
                txt = "",
                params = {
                    event = "qb-menu:client:closeMenu"
                }
            }
            exports['qb-menu']:openMenu(impoundMenu)
        end
    end)

end

function closeMenuFull()
    exports['qb-menu']:closeMenu()
end

--NUI Callbacks
RegisterNUICallback('closeFingerprint', function()
    SetNuiFocus(false, false)
    inFingerprint = false
end)

--Events
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
            local plate = QBCore.Functions.GetPlate(vehicle)
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
                QBCore.Functions.Notify(Lang:t("error.none_nearby"), "error")
            end
        end
    end)
end)

RegisterNetEvent("police:client:VehicleMenuHeader", function (data)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local takeDist = Config.Locations['vehicle'][data.currentSelection]
    takeDist = vector3(takeDist.x, takeDist.y,  takeDist.z)
    if #(pos - takeDist) <= 1.5 then
        MenuGarage(data.currentSelection)
        currentGarage = data.currentSelection
    end
end)


RegisterNetEvent("police:client:ImpoundMenuHeader", function (data)
    local pos = GetEntityCoords(PlayerPedId())
    local takeDist = Config.Locations['impound'][data.currentSelection]
    takeDist = vector3(takeDist.x, takeDist.y,  takeDist.z)
    if #(pos - takeDist) <= 1.5 then
        MenuImpound(data.currentSelection)
        currentGarage = data.currentSelection
    end
end)

RegisterNetEvent('police:client:TakeOutImpound', function(data)
    local pos = GetEntityCoords(PlayerPedId())
    local takeDist = Config.Locations['impound'][data.currentSelection]
    takeDist = vector3(takeDist.x, takeDist.y,  takeDist.z)
    if #(pos - takeDist) <= 1.5 then
        local vehicle = data.vehicle
        TakeOutImpound(vehicle)
    end
end)

RegisterNetEvent('police:client:TakeOutVehicle', function(data)
    local pos = GetEntityCoords(PlayerPedId())
    local takeDist = Config.Locations['vehicle'][data.currentSelection]
    takeDist = vector3(takeDist.x, takeDist.y,  takeDist.z)
    if #(pos - takeDist) <= 1.5 then
        local vehicle = data.vehicle
        TakeOutVehicle(vehicle)
    end
end)

RegisterNetEvent('police:client:EvidenceStashDrawer', function(data)
    local currentEvidence = data.currentEvidence
    local pos = GetEntityCoords(PlayerPedId())
    local takeLoc = Config.Locations["evidence"][currentEvidence]

    if not takeLoc then return end

    if #(pos - takeLoc) <= 1.0 then
        local drawer = exports['qb-input']:ShowInput({
            header = Lang:t('info.evidence_stash', {value = currentEvidence}),
            submitText = "open",
            inputs = {
                {
                    type = 'number',
                    isRequired = true,
                    name = 'slot',
                    text = Lang:t('info.slot')
                }
            }
        })
        if drawer then
            if not drawer.slot then return end
            TriggerServerEvent("inventory:server:OpenInventory", "stash", Lang:t('info.current_evidence', {value = currentEvidence, value2 = drawer.slot}), {
                maxweight = 4000000,
                slots = 500,
            })
            TriggerEvent("inventory:client:SetCurrentStash", Lang:t('info.current_evidence', {value = currentEvidence, value2 = drawer.slot}))
        end
    else
        exports['qb-menu']:closeMenu()
    end
end)

-- Threads
-- Toggle Duty in an event.
RegisterNetEvent('qb-policejob:ToggleDuty', function()
    onDuty = not onDuty
    TriggerServerEvent("police:server:UpdateCurrentCops")
    TriggerServerEvent("police:server:UpdateBlips")
    TriggerServerEvent("QBCore:ToggleDuty")
end)

-- Toggle Duty in an event.
RegisterNetEvent('qb-policejob:ToggleDuty', function()
    onDuty = not onDuty
    TriggerServerEvent("police:server:UpdateCurrentCops")
    TriggerServerEvent("police:server:UpdateBlips")
    TriggerServerEvent("QBCore:ToggleDuty")
end)

-- Toggle Duty
CreateThread(function()
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())

            for k, v in pairs(Config.Locations["duty"]) do
                if #(pos - v) < 5 then
                    sleep = 5
                    if #(pos - v) < 1.5 then
                        if not onDuty then
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.on_duty'))
                        else
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.off_duty'))
                        end
                        if IsControlJustReleased(0, 38) then
                            onDuty = not onDuty
                            TriggerServerEvent("police:server:UpdateCurrentCops")
                            TriggerServerEvent("QBCore:ToggleDuty")
                            TriggerServerEvent("police:server:UpdateBlips")
                        end
                    elseif #(pos - v) < 2.5 then
                        DrawText3D(v.x, v.y, v.z, Lang:t('info.onoff_duty'))
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Stash 1
CreateThread(function()
    Wait(1000)
    local headerDrawn = false

    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["evidence"]) do
                if #(pos - v) < 2 then
                    sleep = 5
                    if #(pos - v) < 1.0 then
                        if not headerDrawn then
                            headerDrawn = true
                            exports['qb-menu']:showHeader({
                                {
                                    header = Lang:t('info.evidence_stash', {value = k}),
                                    params = {
                                        event = 'police:client:EvidenceStashDrawer',
                                        args = {
                                            currentEvidence = k
                                        }
                                    }
                                }
                            })
                        end
                    elseif #(pos - v) < 1.5 then
                        DrawText3D(v.x, v.y, v.z, Lang:t('info.evidence_stash', {value = k}))
                        if headerDrawn then
                            headerDrawn = false
                            exports['qb-menu']:closeMenu()
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Personal Stash
CreateThread(function()
    Wait(1000)
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["stash"]) do
                if #(pos - v) < 4.5 then
                    if onDuty then
                        sleep = 5
                        if #(pos - v) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.stash_enter'))
                            if IsControlJustReleased(0, 38) then
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", "policestash_"..QBCore.Functions.GetPlayerData().citizenid)
                                TriggerEvent("inventory:client:SetCurrentStash", "policestash_"..QBCore.Functions.GetPlayerData().citizenid)
                            end
                        elseif #(pos - v) < 2.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.stash'))
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Police Trash
CreateThread(function()
    Wait(1000)
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["trash"]) do
                if #(pos - v) < 2 then
                    sleep = 5
                    if #(pos - v) < 1.0 then
                        DrawText3D(v.x, v.y, v.z, Lang:t('info.trash_enter'))
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", "policetrash", {
                                maxweight = 4000000,
                                slots = 300,
                            })
                            TriggerEvent("inventory:client:SetCurrentStash", "policetrash")
                        end
                    elseif #(pos - v) < 1.5 then
                        DrawText3D(v.x, v.y, v.z, Lang:t('info.trash'))
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Fingerprint
CreateThread(function()
    Wait(1000)
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["fingerprint"]) do
                if #(pos - v) < 4.5 then
                    if onDuty then
                        sleep = 5
                        if #(pos - v) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.scan_fingerprint'))
                            if IsControlJustReleased(0, 38) then
                                local player, distance = GetClosestPlayer()
                                if player ~= -1 and distance < 2.5 then
                                    local playerId = GetPlayerServerId(player)
                                    TriggerServerEvent("police:server:showFingerprint", playerId)
                                else
                                    QBCore.Functions.Notify(Lang:t("error.none_nearby"), "error")
                                end
                            end
                        elseif #(pos - v) < 2.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.finger_scan'))
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Armory
CreateThread(function()
    Wait(1000)
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["armory"]) do
                if #(pos - v) < 4.5 then
                    if onDuty then
                        sleep = 5
                        if #(pos - v) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.enter_armory'))
                            if IsControlJustReleased(0, 38) then
                                local authorizedItems = {
                                    label = Lang:t('menu.pol_armory'),
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
                            DrawText3D(v.x, v.y, v.z, Lang:t('info.armory'))
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Helicopter
CreateThread(function()
    Wait(1000)
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["helicopter"]) do
                if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                    if onDuty then
                        sleep = 5
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                DrawText3D(v.x, v.y, v.z, Lang:t('info.store_heli'))
                            else
                                DrawText3D(v.x, v.y, v.z, Lang:t('info.take_heli'))
                            end
                            if IsControlJustReleased(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                else
                                    local coords = Config.Locations["helicopter"][k]
                                    QBCore.Functions.SpawnVehicle(Config.PoliceHelicopter, function(veh)
                                        SetVehicleLivery(veh , 0)
                                        SetVehicleMod(veh, 0, 48)
                                        SetVehicleNumberPlateText(veh, "ZULU"..tostring(math.random(1000, 9999)))
                                        SetEntityHeading(veh, coords.w)
                                        exports['LegacyFuel']:SetFuel(veh, 100.0)
                                        closeMenuFull()
                                        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                                        SetVehicleEngineOn(veh, true, true)
                                    end, coords, true)
                                end
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Police Impound
CreateThread(function()
    Wait(1000)
    local headerDrawn = false

    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["impound"]) do
                if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                    if onDuty then
                        sleep = 5
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) <= 1.5 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                DrawText3D(v.x, v.y, v.z, Lang:t('info.impound_veh'))
                            else
                                if not headerDrawn then
                                    headerDrawn = true
                                    exports['qb-menu']:showHeader({
                                        {
                                            header = Lang:t('menu.pol_impound'),
                                            params = {
                                                event = 'police:client:ImpoundMenuHeader',
                                                args = {
                                                    currentSelection = k,
                                                }
                                            }
                                        }
                                    })
                                end
                            end
                            if IsControlJustReleased(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                end
                            end
                        else
                            if headerDrawn then
                                headerDrawn = false
                                exports['qb-menu']:closeMenu()
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Police Vehicle Garage
CreateThread(function()
    Wait(1000)
    local headerDrawn = false
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "police" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["vehicle"]) do
                if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                    if onDuty then
                        sleep = 5
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                DrawText3D(v.x, v.y, v.z, Lang:t('info.store_veh'))
                            else
                                if not headerDrawn then
                                    headerDrawn = true
                                    exports['qb-menu']:showHeader({
                                        {
                                            header = Lang:t('menu.pol_garage'),
                                            params = {
                                                event = 'police:client:VehicleMenuHeader',
                                                args = {
                                                    currentSelection = k,
                                                }
                                            }
                                        }
                                    })
                                end
                            end
                            if IsControlJustReleased(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                end
                            end
                        else
                            if headerDrawn then
                                headerDrawn = false
                                exports['qb-menu']:closeMenu()
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)