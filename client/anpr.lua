QBCore = exports['qb-core']:GetCoreObject()
local lastRadar = nil
-- Determines if player is close enough to trigger cam
function HandlespeedCam(speedCam, hasBeenBusted)
	local myPed = PlayerPedId()
	local playerPos = GetEntityCoords(myPed)
	local isInMarker  = false
	if #(playerPos - vector3(speedCam.coords.x, speedCam.coords.y, speedCam.coords.z)) < 20.0 then
		isInMarker  = true
	end

	if isInMarker and not HasAlreadyEnteredMarker and lastRadar == nil then
		HasAlreadyEnteredMarker = true
		lastRadar = hasBeenBusted

		local vehicle = GetPlayersLastVehicle() -- gets the current vehicle the player is in.
		if IsPedInAnyVehicle(myPed, false) then
			if GetPedInVehicleSeat(vehicle, -1) == myPed then
				if GetVehicleClass(vehicle) ~= 18 then
					local fine = 0
                    local plate = QBCore.Functions.GetPlate(vehicle)
					local speed = GetEntitySpeed(vehicle) * 2.23694

					QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(result)
						if result then
							local coords = GetEntityCoords(PlayerPedId())
							local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
							local street1 = GetStreetNameFromHashKey(s1)
							local street2 = GetStreetNameFromHashKey(s2)
							TriggerServerEvent("police:server:FlaggedPlateTriggered", hasBeenBusted, plate, street1, street2, coords)
						end
                    end, plate)
					rangeSpeed = speed - speedCam.speed
					SpeedRange(rangeSpeed, fine)
				end
			end
		end
	end

	if not isInMarker and HasAlreadyEnteredMarker and lastRadar == hasBeenBusted then
		HasAlreadyEnteredMarker = false
		lastRadar = nil
	end
end

function SpeedRange(speed, fine)
	speed = math.ceil(speed)
	for k,v in pairs(Config.SpeedFines) do
		if (speed > v.speedAvg[1] and speed < v.speedAvg[2]) then
			fine = v.fine
			TriggerServerEvent('police:server:BillPlayer', GetPlayerServerId(PlayerId()), fine)
		end
	end
end

CreateThread(function()
	while true do
		Wait(1)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			for key,value in pairs(Config.Radars) do
				HandlespeedCam(value, key)
			end
			Wait(200)
		else
			Wait(2500)
		end
	end
end)