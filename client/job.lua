-- Variables
local currentGarage = 0
local inFingerprint = false
local FingerPrintSessionId = nil
local inStash = false
local inTrash = false
local inArmoury = false
local inHelicopter = false
local inImpound = false
local inGarage = false
local inEvidence = false

local function loadAnimDict(dict) -- interactions, job,
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(10)
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
        type = 'fingerprintOpen'
    })
    inFingerprint = true
    SetNuiFocus(true, true)
end

local function SetCarItemsInfo()
    local items = {}
    for _, item in pairs(Config.CarItems) do
        local itemInfo = QBCore.Shared.Items[item.name:lower()]
        if itemInfo then
            items[#items + 1] = {
                name = itemInfo.name,
                amount = tonumber(item.amount),
                info = item.info or {},
                label = itemInfo.label,
                description = itemInfo.description or '',
                weight = itemInfo.weight,
                type = itemInfo.type,
                unique = itemInfo.unique,
                useable = itemInfo.useable,
                image = itemInfo.image,
                slot = #items + 1,
            }
        end
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
    if engine > 1000.0 then engine = 950.0 end
    if body < 150.0 then body = 150.0 end
    if body < 950.0 then smash = true end
    if body < 920.0 then damageOutside = true end
    if body < 920.0 then damageOutside2 = true end

    Wait(100)
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
    local coords = Config.Locations['impound'][currentGarage]
    if coords then
        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
            local veh = NetToVeh(netId)
            QBCore.Functions.SetVehicleProperties(veh, json.decode(vehicle.mods))
            SetVehicleNumberPlateText(veh, vehicle.plate)
            SetVehicleDirtLevel(veh, 0.0)
            SetEntityHeading(veh, coords.w)
            exports[Config.FuelResource]:SetFuel(veh, vehicle.fuel)
            doCarDamage(veh, vehicle)
            TriggerServerEvent('police:server:TakeOutImpound', vehicle.plate, currentGarage)
            closeMenuFull()
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, true, true)
        end, vehicle.vehicle, coords, true)
    end
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations['vehicle'][currentGarage]
    if coords then
        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
            local veh = NetToVeh(netId)
            SetCarItemsInfo()
            SetVehicleNumberPlateText(veh, Lang:t('info.police_plate') .. tostring(math.random(1000, 9999)))
            SetEntityHeading(veh, coords.w)
            exports[Config.FuelResource]:SetFuel(veh, 100.0)
            closeMenuFull()
            if Config.VehicleSettings[vehicleInfo] ~= nil then
                if Config.VehicleSettings[vehicleInfo].extras ~= nil then
                    QBCore.Shared.SetDefaultVehicleExtras(veh, Config.VehicleSettings[vehicleInfo].extras)
                end
                if Config.VehicleSettings[vehicleInfo].livery ~= nil then
                    SetVehicleLivery(veh, Config.VehicleSettings[vehicleInfo].livery)
                end
            end
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
            TriggerServerEvent('inventory:server:addTrunkItems', QBCore.Functions.GetPlate(veh), Config.CarItems)
            SetVehicleEngineOn(veh, true, true)
        end, vehicleInfo, coords, true)
    end
end

function MenuGarage(currentSelection)
    local vehicleMenu = {
        {
            header = Lang:t('menu.garage_title'),
            isMenuHeader = true
        }
    }

    local playerGrade = QBCore.Functions.GetPlayerData().job.grade.level
    for grade = 0, playerGrade do
        local authorizedVehicles = Config.AuthorizedVehicles[grade]
        if authorizedVehicles then
            for veh, label in pairs(authorizedVehicles) do
                vehicleMenu[#vehicleMenu + 1] = {
                    header = label,
                    txt = '',
                    params = {
                        event = 'police:client:TakeOutVehicle',
                        args = {
                            vehicle = veh,
                            currentSelection = currentSelection
                        }
                    }
                }
            end
        end
    end

    vehicleMenu[#vehicleMenu + 1] = {
        header = Lang:t('menu.close'),
        txt = '',
        params = {
            event = 'qb-menu:client:closeMenu'
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
    QBCore.Functions.TriggerCallback('police:GetImpoundedVehicles', function(result)
        local shouldContinue = false
        if result == nil then
            QBCore.Functions.Notify(Lang:t('error.no_impound'), 'error', 5000)
        else
            shouldContinue = true
            for _, v in pairs(result) do
                local enginePercent = QBCore.Shared.Round(v.engine / 10, 0)
                local currentFuel = v.fuel
                local vname = QBCore.Shared.Vehicles[v.vehicle].name

                impoundMenu[#impoundMenu + 1] = {
                    header = vname .. ' [' .. v.plate .. ']',
                    txt = Lang:t('info.vehicle_info', { value = enginePercent, value2 = currentFuel }),
                    params = {
                        event = 'police:client:TakeOutImpound',
                        args = {
                            vehicle = v,
                            currentSelection = currentSelection
                        }
                    }
                }
            end
        end

        if shouldContinue then
            impoundMenu[#impoundMenu + 1] = {
                header = Lang:t('menu.close'),
                txt = '',
                params = {
                    event = 'qb-menu:client:closeMenu'
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
RegisterNUICallback('closeFingerprint', function(_, cb)
    SetNuiFocus(false, false)
    inFingerprint = false
    cb('ok')
end)

--Events
RegisterNetEvent('police:client:showFingerprint', function(playerId)
    openFingerprintUI()
    FingerPrintSessionId = playerId
end)

RegisterNetEvent('police:client:showFingerprintId', function(fid)
    SendNUIMessage({
        type = 'updateFingerprintId',
        fingerprintId = fid
    })
    PlaySound(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', 0, 0, 1)
end)

RegisterNUICallback('doFingerScan', function(_, cb)
    TriggerServerEvent('police:server:showFingerprintId', FingerPrintSessionId)
    cb('ok')
end)

RegisterNetEvent('police:client:SendEmergencyMessage', function(coords, message)
    TriggerServerEvent('police:server:SendEmergencyMessage', coords, message)
    TriggerEvent('police:client:CallAnim')
end)

RegisterNetEvent('police:client:EmergencySound', function()
    PlaySound(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', 0, 0, 1)
end)

RegisterNetEvent('police:client:CallAnim', function()
    local isCalling = true
    local callCount = 5
    loadAnimDict('cellphone@')
    TaskPlayAnim(PlayerPedId(), 'cellphone@', 'cellphone_call_listen_base', 3.0, -1, -1, 49, 0, false, false, false)
    Wait(1000)
    CreateThread(function()
        while isCalling do
            Wait(1000)
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
    local totalFuel = exports[Config.FuelResource]:GetFuel(vehicle)
    if vehicle ~= 0 and vehicle then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            QBCore.Functions.Progressbar('impound', Lang:t('progressbar.impound'), 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = 'missheistdockssetup1clipboard@base',
                anim = 'base',
                flags = 1,
            }, {
                model = 'prop_notepad_01',
                bone = 18905,
                coords = { x = 0.1, y = 0.02, z = 0.05 },
                rotation = { x = 10.0, y = 0.0, z = 0.0 },
            }, {
                model = 'prop_pencil_01',
                bone = 58866,
                coords = { x = 0.11, y = -0.02, z = 0.001 },
                rotation = { x = -120.0, y = 0.0, z = 0.0 },
            }, function() -- Play When Done
                local plate = QBCore.Functions.GetPlate(vehicle)
                TriggerServerEvent('police:server:Impound', plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)
                while NetworkGetEntityOwner(vehicle) ~= 128 do -- Ensure we have entity ownership to prevent inconsistent vehicle deletion
                    NetworkRequestControlOfEntity(vehicle)
                    Wait(100)
                end
                QBCore.Functions.DeleteVehicle(vehicle)
                TriggerEvent('QBCore:Notify', Lang:t('success.impounded'), 'success')
                ClearPedTasks(ped)
            end, function() -- Play When Cancel
                ClearPedTasks(ped)
                TriggerEvent('QBCore:Notify', Lang:t('error.canceled'), 'error')
            end)
        end
    end
end)

RegisterNetEvent('police:client:CheckStatus', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.type == 'leo' then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                QBCore.Functions.TriggerCallback('police:GetPlayerStatus', function(result)
                    if result then
                        for _, v in pairs(result) do
                            QBCore.Functions.Notify('' .. v .. '')
                        end
                    end
                end, playerId)
            else
                QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
            end
        end
    end)
end)

RegisterNetEvent('police:client:VehicleMenuHeader', function(data)
    MenuGarage(data.currentSelection)
    currentGarage = data.currentSelection
end)


RegisterNetEvent('police:client:ImpoundMenuHeader', function(data)
    MenuImpound(data.currentSelection)
    currentGarage = data.currentSelection
end)

RegisterNetEvent('police:client:TakeOutImpound', function(data)
    if inImpound then
        local vehicle = data.vehicle
        TakeOutImpound(vehicle)
    end
end)

RegisterNetEvent('police:client:TakeOutVehicle', function(data)
    if inGarage then
        local vehicle = data.vehicle
        TakeOutVehicle(vehicle)
    end
end)

RegisterNetEvent('police:client:EvidenceStashDrawer', function()
    local pos = GetEntityCoords(PlayerPedId())
    local currentEvidence = 0
    for k, v in pairs(Config.Locations['evidence']) do
        if #(pos - v) < 2 then
            currentEvidence = k
        end
    end
    local takeLoc = Config.Locations['evidence'][currentEvidence]

    if not takeLoc then return end

    if #(pos - takeLoc) <= 1.0 then
        local drawer = exports['qb-input']:ShowInput({
            header = Lang:t('info.evidence_stash', { value = currentEvidence }),
            submitText = 'open',
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
            TriggerServerEvent('inventory:server:OpenInventory', 'stash', Lang:t('info.current_evidence', { value = currentEvidence, value2 = drawer.slot }), {
                maxweight = 4000000,
                slots = 500,
            })
            TriggerEvent('inventory:client:SetCurrentStash', Lang:t('info.current_evidence', { value = currentEvidence, value2 = drawer.slot }))
        end
    else
        exports['qb-menu']:closeMenu()
    end
end)

RegisterNetEvent('qb-policejob:ToggleDuty', function()
    TriggerServerEvent('QBCore:ToggleDuty')
    TriggerServerEvent('police:server:UpdateCurrentCops')
    TriggerServerEvent('police:server:UpdateBlips')
end)

RegisterNetEvent('qb-police:client:scanFingerPrint', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('police:server:showFingerprint', playerId)
    else
        QBCore.Functions.Notify(Lang:t('error.none_nearby'), 'error')
    end
end)

RegisterNetEvent('qb-police:client:openArmoury', function()
    local authorizedItemsList = {}
    local playerGrade = PlayerJob.grade.level
    for grade = 0, playerGrade do
        if Config.Items[grade] then
            for _, item in ipairs(Config.Items[grade]) do
                local itemInfo = QBCore.Shared.Items[item.name]
                if itemInfo then
                    authorizedItemsList[#authorizedItemsList + 1] = {
                        name = item.name,
                        price = item.price,
                        amount = item.amount,
                        info = item.info or {},
                        type = itemInfo.type,
                        slot = #authorizedItemsList + 1
                    }
                end
            end
        end
    end
    local authorizedItems = {
        label = 'Police Armory',
        slots = #authorizedItemsList,
        items = authorizedItemsList
    }
    TriggerServerEvent('inventory:server:OpenInventory', 'shop', 'police', authorizedItems)
end)

RegisterNetEvent('qb-police:client:spawnHelicopter', function(k)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
    else
        local coords = Config.Locations['helicopter'][k]
        if not coords then coords = GetEntityCoords(PlayerPedId()) end
        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
            local veh = NetToVeh(netId)
            SetVehicleLivery(veh, 0)
            SetVehicleMod(veh, 0, 48)
            SetVehicleNumberPlateText(veh, 'ZULU' .. tostring(math.random(1000, 9999)))
            SetEntityHeading(veh, coords.w)
            exports[Config.FuelResource]:SetFuel(veh, 100.0)
            closeMenuFull()
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, true)
        end, Config.PoliceHelicopter, coords, true)
    end
end)

RegisterNetEvent('qb-police:client:openStash', function()
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'policestash_' .. QBCore.Functions.GetPlayerData().citizenid)
    TriggerEvent('inventory:client:SetCurrentStash', 'policestash_' .. QBCore.Functions.GetPlayerData().citizenid)
end)

RegisterNetEvent('qb-police:client:openTrash', function()
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'policetrash', {
        maxweight = 4000000,
        slots = 300,
    })
    TriggerEvent('inventory:client:SetCurrentStash', 'policetrash')
end)

--##### Threads #####--

local dutylisten = false
local function dutylistener()
    dutylisten = true
    CreateThread(function()
        while dutylisten do
            if PlayerJob.type == 'leo' then
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('QBCore:ToggleDuty')
                    TriggerServerEvent('police:server:UpdateCurrentCops')
                    TriggerServerEvent('police:server:UpdateBlips')
                    dutylisten = false
                    break
                end
            else
                break
            end
            Wait(0)
        end
    end)
end

-- Personal Stash Thread
local function stash()
    CreateThread(function()
        while true do
            Wait(0)
            if inStash and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'policestash_' .. QBCore.Functions.GetPlayerData().citizenid)
                    TriggerEvent('inventory:client:SetCurrentStash', 'policestash_' .. QBCore.Functions.GetPlayerData().citizenid)
                    break
                end
            else
                break
            end
        end
    end)
end

-- Police Trash Thread
local function trash()
    CreateThread(function()
        while true do
            Wait(0)
            if inTrash and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'policetrash', {
                        maxweight = 4000000,
                        slots = 300,
                    })
                    TriggerEvent('inventory:client:SetCurrentStash', 'policetrash')
                    break
                end
            else
                break
            end
        end
    end)
end

-- Fingerprint Thread
local function fingerprint()
    CreateThread(function()
        while true do
            Wait(0)
            if inFingerprint and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qb-police:client:scanFingerPrint')
                    break
                end
            else
                break
            end
        end
    end)
end

-- Armoury Thread
local function armoury()
    CreateThread(function()
        while true do
            Wait(0)
            if inArmoury and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qb-police:client:openArmoury')
                    break
                end
            else
                break
            end
        end
    end)
end

-- Evidence Thread
local function evidence()
    CreateThread(function()
        while true do
            Wait(0)
            if inEvidence and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('police:client:EvidenceStashDrawer')
                    break
                end
            else
                break
            end
        end
    end)
end

-- Helicopter Thread
local function heli()
    CreateThread(function()
        while true do
            Wait(0)
            if inHelicopter and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qb-police:client:spawnHelicopter')
                    break
                end
            else
                break
            end
        end
    end)
end

-- Police Impound Thread
local function impound()
    CreateThread(function()
        while true do
            Wait(0)
            if inImpound and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    if IsControlJustReleased(0, 38) then
                        QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                        break
                    end
                end
            else
                break
            end
        end
    end)
end

-- Police Garage Thread
local function garage()
    CreateThread(function()
        while true do
            Wait(0)
            if inGarage and PlayerJob.type == 'leo' then
                if PlayerJob.onduty then sleep = 5 end
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    if IsControlJustReleased(0, 38) then
                        QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                        break
                    end
                end
            else
                break
            end
        end
    end)
end

if Config.UseTarget then
    CreateThread(function()
        -- Toggle Duty
        for k, v in pairs(Config.Locations['duty']) do
            exports['qb-target']:AddCircleZone('PoliceDuty_' .. k, vector3(v.x, v.y, v.z), 0.5, {
                name = 'PoliceDuty_' .. k,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'qb-policejob:ToggleDuty',
                        icon = 'fas fa-sign-in-alt',
                        label = Lang:t('target.sign_in'),
                        jobType = 'leo',
                    },
                },
                distance = 1.5
            })
        end

        -- Personal Stash
        for k, v in pairs(Config.Locations['stash']) do
            exports['qb-target']:AddCircleZone('PoliceStash_' .. k, vector3(v.x, v.y, v.z), 1.0, {
                name = 'PoliceStash_' .. k,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'qb-police:client:openStash',
                        icon = 'fas fa-dungeon',
                        label = Lang:t('target.open_personal_stash'),
                        jobType = 'leo',
                    },
                },
                distance = 1.5
            })
        end

        -- Police Trash
        for k, v in pairs(Config.Locations['trash']) do
            exports['qb-target']:AddCircleZone('PoliceTrash_' .. k, vector3(v.x, v.y, v.z), 0.5, {
                name = 'PoliceTrash_' .. k,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'qb-police:client:openTrash',
                        icon = 'fas fa-trash',
                        label = Lang:t('target.open_trash'),
                        jobType = 'leo',
                    },
                },
                distance = 1.5
            })
        end

        -- Fingerprint
        for k, v in pairs(Config.Locations['fingerprint']) do
            exports['qb-target']:AddCircleZone('PoliceFingerprint_' .. k, vector3(v.x, v.y, v.z), 0.5, {
                name = 'PoliceFingerprint_' .. k,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'qb-police:client:scanFingerPrint',
                        icon = 'fas fa-fingerprint',
                        label = Lang:t('target.open_fingerprint'),
                        jobType = 'leo',
                    },
                },
                distance = 1.5
            })
        end

        -- Armoury
        for k, v in pairs(Config.Locations['armory']) do
            exports['qb-target']:AddCircleZone('PoliceArmory_' .. k, vector3(v.x, v.y, v.z), 1.0, {
                name = 'PoliceArmory_' .. k,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'qb-police:client:openArmoury',
                        icon = 'fas fa-gun',
                        label = Lang:t('target.open_armory'),
                        jobType = 'leo',
                    },
                },
                distance = 1.5
            })
        end

        -- Evidence
        for k, v in pairs(Config.Locations['evidence']) do
            exports['qb-target']:AddCircleZone('PoliceEvidence_' .. k, vector3(v.x, v.y, v.z), 0.5, {
                name = 'PoliceEvidence_' .. k,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'police:client:EvidenceStashDrawer',
                        icon = 'fas fa-dungeon',
                        label = Lang:t('target.open_evidence_stash'),
                        jobType = 'leo',
                    },
                },
                distance = 1.5
            })
        end
    end)
else
    -- Toggle Duty
    local dutyZones = {}
    for _, v in pairs(Config.Locations['duty']) do
        dutyZones[#dutyZones + 1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 1.75, 1, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local dutyCombo = ComboZone:Create(dutyZones, { name = 'dutyCombo', debugPoly = false })
    dutyCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            dutylisten = true
            if not PlayerJob.onduty then
                exports['qb-core']:DrawText(Lang:t('info.on_duty'), 'left')
                dutylistener()
            else
                exports['qb-core']:DrawText(Lang:t('info.off_duty'), 'left')
                dutylistener()
            end
        else
            dutylisten = false
            exports['qb-core']:HideText()
        end
    end)

    -- Personal Stash
    local stashZones = {}
    for _, v in pairs(Config.Locations['stash']) do
        stashZones[#stashZones + 1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 1.5, 1.5, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local stashCombo = ComboZone:Create(stashZones, { name = 'stashCombo', debugPoly = false })
    stashCombo:onPlayerInOut(function(isPointInside, _, _)
        if isPointInside then
            inStash = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-core']:DrawText(Lang:t('info.stash_enter'), 'left')
                stash()
            end
        else
            inStash = false
            exports['qb-core']:HideText()
        end
    end)

    -- Police Trash
    local trashZones = {}
    for _, v in pairs(Config.Locations['trash']) do
        trashZones[#trashZones + 1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 1, 1.75, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local trashCombo = ComboZone:Create(trashZones, { name = 'trashCombo', debugPoly = false })
    trashCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            inTrash = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-core']:DrawText(Lang:t('info.trash_enter'), 'left')
                trash()
            end
        else
            inTrash = false
            exports['qb-core']:HideText()
        end
    end)

    -- Fingerprints
    local fingerprintZones = {}
    for _, v in pairs(Config.Locations['fingerprint']) do
        fingerprintZones[#fingerprintZones + 1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 2, 1, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local fingerprintCombo = ComboZone:Create(fingerprintZones, { name = 'fingerprintCombo', debugPoly = false })
    fingerprintCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            inFingerprint = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-core']:DrawText(Lang:t('info.scan_fingerprint'), 'left')
                fingerprint()
            end
        else
            inFingerprint = false
            exports['qb-core']:HideText()
        end
    end)

    -- Armoury
    local armouryZones = {}
    for _, v in pairs(Config.Locations['armory']) do
        armouryZones[#armouryZones + 1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 5, 1, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local armouryCombo = ComboZone:Create(armouryZones, { name = 'armouryCombo', debugPoly = false })
    armouryCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            inArmoury = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-core']:DrawText(Lang:t('info.enter_armory'), 'left')
                armoury()
            end
        else
            inArmoury = false
            exports['qb-core']:HideText()
        end
    end)

    -- Evidence
    local evidenceZones = {}
    for _, v in pairs(Config.Locations['evidence']) do
        evidenceZones[#evidenceZones + 1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 2, 1, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local evidenceCombo = ComboZone:Create(evidenceZones, { name = 'evidenceCombo', debugPoly = false })
    evidenceCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            inEvidence = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-core']:DrawText(Lang:t('info.evidence_stash_prompt'), 'left')
                evidence()
            end
        else
            inEvidence = false
            exports['qb-core']:HideText()
        end
    end)
end

CreateThread(function()
    -- Helicopter
    local helicopterZones = {}
    for _, v in pairs(Config.Locations['helicopter']) do
        helicopterZones[#helicopterZones + 1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 10, 10, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local helicopterCombo = ComboZone:Create(helicopterZones, { name = 'helicopterCombo', debugPoly = false })
    helicopterCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            inHelicopter = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    exports['qb-core']:HideText()
                    exports['qb-core']:DrawText(Lang:t('info.store_heli'), 'left')
                    heli()
                else
                    exports['qb-core']:DrawText(Lang:t('info.take_heli'), 'left')
                    heli()
                end
            end
        else
            inHelicopter = false
            exports['qb-core']:HideText()
        end
    end)

    -- Police Impound
    local impoundZones = {}
    for _, v in pairs(Config.Locations['impound']) do
        impoundZones[#impoundZones + 1] = BoxZone:Create(
            vector3(v.x, v.y, v.z), 1, 1, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
                heading = 180,
            })
    end

    local impoundCombo = ComboZone:Create(impoundZones, { name = 'impoundCombo', debugPoly = false })
    impoundCombo:onPlayerInOut(function(isPointInside, point)
        if isPointInside then
            inImpound = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    exports['qb-core']:DrawText(Lang:t('info.impound_veh'), 'left')
                    impound()
                else
                    local currentSelection = 0

                    for k, v in pairs(Config.Locations['impound']) do
                        if #(point - vector3(v.x, v.y, v.z)) < 4 then
                            currentSelection = k
                        end
                    end
                    exports['qb-menu']:showHeader({
                        {
                            header = Lang:t('menu.pol_impound'),
                            params = {
                                event = 'police:client:ImpoundMenuHeader',
                                args = {
                                    currentSelection = currentSelection,
                                }
                            }
                        }
                    })
                end
            end
        else
            inImpound = false
            exports['qb-menu']:closeMenu()
            exports['qb-core']:HideText()
        end
    end)

    -- Police Garage
    local garageZones = {}
    for _, v in pairs(Config.Locations['vehicle']) do
        garageZones[#garageZones + 1] = BoxZone:Create(
            vector3(v.x, v.y, v.z), 3, 3, {
                name = 'box_zone',
                debugPoly = false,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
    end

    local garageCombo = ComboZone:Create(garageZones, { name = 'garageCombo', debugPoly = false })
    garageCombo:onPlayerInOut(function(isPointInside, point)
        if isPointInside then
            inGarage = true
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    exports['qb-core']:DrawText(Lang:t('info.store_veh'), 'left')
                    garage()
                else
                    local currentSelection = 0

                    for k, v in pairs(Config.Locations['vehicle']) do
                        if #(point - vector3(v.x, v.y, v.z)) < 4 then
                            currentSelection = k
                        end
                    end
                    exports['qb-menu']:showHeader({
                        {
                            header = Lang:t('menu.pol_garage'),
                            params = {
                                event = 'police:client:VehicleMenuHeader',
                                args = {
                                    currentSelection = currentSelection,
                                }
                            }
                        }
                    })
                end
            end
        else
            inGarage = false
            exports['qb-menu']:closeMenu()
            exports['qb-core']:HideText()
        end
    end)
end)
