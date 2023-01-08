-- Variables
local ObjectList = {}
local closestStinger = 0
local wheels = {
    ["wheel_lf"] = 0,
    ["wheel_rf"] = 1,
    ["wheel_lm"] = 2,
    ["wheel_rm"] = 3,
    ["wheel_lr"] = 4,
    ["wheel_rr"] = 5,
}
-- Functions
local function LoadDict(Dict)
    while not HasAnimDictLoaded(Dict) do 
        Wait(0)
        RequestAnimDict(Dict)
    end

    return Dict
end

local function LoadModel(model)
    model = type(model) == "string" and GetHashKey(model) or model
    if not HasModelLoaded(model) and IsModelInCdimage(model) then
        local timer = GetGameTimer() + 20000 -- 20 seconds to load
        RequestModel(model)
        while not HasModelLoaded(model) and timer >= GetGameTimer() do -- wait for the model to load
            Wait(50)
        end
    end
    return {loaded = HasModelLoaded(model), model = model}
end

local function GetClosestPoliceObject()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil

    for id, _ in pairs(ObjectList) do
        local dist2 = #(pos - ObjectList[id].coords)
        if current then
            if dist2 < dist then
                current = id
                dist = dist2
            end
        else
            dist = dist2
            current = id
        end
    end
    return current, dist
end

local function DeployStinger()
    local stinger = CreateObject(LoadModel("p_ld_stinger_s").model, GetOffsetFromEntityInWorldCoords(PlayerPedId(), -0.2, 2.0, 0.0), true, true, 0)
    SetEntityAsMissionEntity(stinger, true, true)
    SetEntityHeading(stinger, GetEntityHeading(PlayerPedId()))
    FreezeEntityPosition(stinger, true)
    PlaceObjectOnGroundProperly(stinger)
    SetEntityVisible(stinger, false)

    -- init scene
    local scene = NetworkCreateSynchronisedScene(GetEntityCoords(PlayerPedId()), GetEntityRotation(PlayerPedId(), 2), 2, false, false, 1065353216, 0, 1.0)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, LoadDict("amb@medic@standing@kneel@enter"), "enter", 8.0, -8.0, 3341, 16, 1148846080, 0)
    NetworkStartSynchronisedScene(scene)
    -- wait for the scene to start
    while not IsSynchronizedSceneRunning(NetworkConvertSynchronisedSceneToSynchronizedScene(scene)) do
        Wait(0)
    end
    -- make the scene faster (looks better)
    SetSynchronizedSceneRate(NetworkConvertSynchronisedSceneToSynchronizedScene(scene), 3.0)
    -- wait a bit
    while GetSynchronizedScenePhase(NetworkConvertSynchronisedSceneToSynchronizedScene(scene)) < 0.14 do
        Wait(0)
    end
    -- stop the scene early
    NetworkStopSynchronisedScene(scene)

    -- play deploy animation for stinger
    PlayEntityAnim(stinger, "P_Stinger_S_Deploy", LoadDict("p_ld_stinger_s"), 1000.0, false, true, 0, 0.0, 0)
    while not IsEntityPlayingAnim(stinger, "p_ld_stinger_s", "P_Stinger_S_Deploy", 3) do
        Wait(0)
    end
    SetEntityVisible(stinger, true)
    while IsEntityPlayingAnim(stinger, "p_ld_stinger_s", "P_Stinger_S_Deploy", 3) and GetEntityAnimCurrentTime(stinger, "p_ld_stinger_s", "P_Stinger_S_Deploy") <= 0.99 do
        Wait(0)
    end
    PlayEntityAnim(stinger, "p_stinger_s_idle_deployed", LoadDict("p_ld_stinger_s"), 1000.0, false, true, 0, 0.99, 0)

    return stinger
end

local function RemoveStinger()
    if DoesEntityExist(closestStinger) then
        NetworkRequestControlOfEntity(closestStinger)
        SetEntityAsMissionEntity(closestStinger, true, true)
        DeleteEntity(closestStinger)

        Wait(250)
        if not DoesEntityExist(closestStinger) then
            TriggerServerEvent("police:server:pickupspikes")
        end
    end
end

local function TouchingStinger(coords, stinger)
    local min, max = GetModelDimensions(GetEntityModel(stinger))
    local size = max - min
    local w, l, h = size.x, size.y, size.z

    local offset1 = GetOffsetFromEntityInWorldCoords(stinger, 0.0, l/2, h*-1)
    local offset2 = GetOffsetFromEntityInWorldCoords(stinger, 0.0, l/2 * -1, h)

    return IsPointInAngledArea(coords, offset1, offset2, w*2, 0, false)
end



-- Events
RegisterNetEvent('police:client:usespikes',function()
    local player = QBCore.Functions.GetPlayerData()
    if QBCore.Functions.HasItem then 
        QBCore.Functions.Progressbar("spawn_object", Lang:t("progressbar.place_spike"), 2500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            if player.job.name == 'police' then 
                DeployStinger()
                TriggerServerEvent('police:server:removespikes')
            else 
                QBCore.Functions.Notify('You are not trained to use this', 'error', 7500)
            end
        end, function() -- Cancel

        end)
    else 
        QBCore.Functions.Notify(Lang:t("error.no_spikestripe"), 'error')
    end
end)

RegisterNetEvent("police:client:removespike", function()
    RemoveStinger()
end)

RegisterNetEvent('police:client:spawnCone', function()
    QBCore.Functions.Progressbar("spawn_object", Lang:t("progressbar.place_object"), 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@narcotics@trash",
        anim = "drop_front",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        TriggerServerEvent("police:server:spawnObject", "cone")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
    end)
end)

RegisterNetEvent('police:client:spawnBarrier', function()
    QBCore.Functions.Progressbar("spawn_object", Lang:t("progressbar.place_object"), 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@narcotics@trash",
        anim = "drop_front",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        TriggerServerEvent("police:server:spawnObject", "barrier")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
    end)
end)

RegisterNetEvent('police:client:spawnRoadSign', function()
    QBCore.Functions.Progressbar("spawn_object", Lang:t("progressbar.place_object"), 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@narcotics@trash",
        anim = "drop_front",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        TriggerServerEvent("police:server:spawnObject", "roadsign")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
    end)
end)

RegisterNetEvent('police:client:spawnTent', function()
    QBCore.Functions.Progressbar("spawn_object", Lang:t("progressbar.place_object"), 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@narcotics@trash",
        anim = "drop_front",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        TriggerServerEvent("police:server:spawnObject", "tent")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
    end)
end)

RegisterNetEvent('police:client:spawnLight', function()
    QBCore.Functions.Progressbar("spawn_object", Lang:t("progressbar.place_object"), 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@narcotics@trash",
        anim = "drop_front",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        TriggerServerEvent("police:server:spawnObject", "light")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
        QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
    end)
end)

RegisterNetEvent('police:client:deleteObject', function()
    local objectId, dist = GetClosestPoliceObject()
    if dist < 5.0 then
        QBCore.Functions.Progressbar("remove_object", Lang:t('progressbar.remove_object'), 2500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
            anim = "plant_floor",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0)
            TriggerServerEvent("police:server:deleteObject", objectId)
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0)
            QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
        end)
    end
end)

RegisterNetEvent('police:client:removeObject', function(objectId)
    NetworkRequestControlOfEntity(ObjectList[objectId].object)
    DeleteObject(ObjectList[objectId].object)
    ObjectList[objectId] = nil
end)

RegisterNetEvent('police:client:spawnObject', function(objectId, type, player)
    local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
    local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(coords + forward * 0.5)
    local spawnedObj = CreateObject(Config.Objects[type].model, x, y, z, true, false, false)
    PlaceObjectOnGroundProperly(spawnedObj)
    SetEntityHeading(spawnedObj, heading)
    FreezeEntityPosition(spawnedObj, Config.Objects[type].freeze)
    ObjectList[objectId] = {
        id = objectId,
        object = spawnedObj,
        coords = vector3(x, y, z - 0.3),
    }
end)



-- Threads
-- thread to find the closest stinger / spikestrip
Citizen.CreateThread(function()
    while true do
        local driving = DoesEntityExist(GetVehiclePedIsUsing(PlayerPedId()))
        Wait((driving and 50) or 1000)
        local coords = GetEntityCoords((driving and GetVehiclePedIsUsing(PlayerPedId())) or PlayerPedId())

        local stinger = GetClosestObjectOfType(coords, 10.0, GetHashKey("p_ld_stinger_s"), false, false, false)
        if DoesEntityExist(stinger) then
            closestStinger = stinger
            closestStingerDistance = #(coords - GetEntityCoords(stinger))
        end

        if not DoesEntityExist(closestStinger) or #(coords - GetEntityCoords(closestStinger)) > 10.0 then
            closestStinger = 0
        end
    end
end)

-- This while loop manages bursting tyres.
CreateThread(function()
    while true do
        Wait(1500)
        while DoesEntityExist(GetVehiclePedIsUsing(PlayerPedId())) do
            Wait(50)
            local vehicle = GetVehiclePedIsUsing(PlayerPedId())
            while DoesEntityExist(closestStinger) and closestStingerDistance <= 5.0 do
                Wait(5)
                if IsEntityTouchingEntity(vehicle, closestStinger) then
                    for boneName, wheelId in pairs(wheels) do
                        if not IsVehicleTyreBurst(vehicle, wheelId, false) then
                            if TouchingStinger(GetWorldPositionOfEntityBone(vehicle,
                                GetEntityBoneIndexByName(vehicle, boneName)), closestStinger) then
                                SetVehicleTyreBurst(vehicle, wheelId, 1, 1148846080)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- target
exports['qb-target']:AddTargetModel('p_ld_stinger_s', {
    options = {
      {
        num = 1,
        event = 'police:client:removespike',
        icon = "fa fa fa-circle",
        label = Lang:t("info.pickup_spike"),
        job = 'police',
      },
    },
    distance = 2.0
})

