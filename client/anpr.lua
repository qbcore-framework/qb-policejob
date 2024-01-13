local lastRadar = nil
local HasAlreadyEnteredMarker = false

local function IsInMarker(playerPos, speedCam)
	return #(playerPos - vector3(speedCam.x, speedCam.y, speedCam.z)) < 20.0
end

local function HandleSpeedCam(speedCam, radarID)
	local playerPed = PlayerPedId()
	local playerPos = GetEntityCoords(playerPed)
	local isInMarker = IsInMarker(playerPos, speedCam)

	if isInMarker and not HasAlreadyEnteredMarker and lastRadar == nil then
		HasAlreadyEnteredMarker = true
		lastRadar = radarID

		local vehicle = GetPlayersLastVehicle()
		if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed and GetVehicleClass(vehicle) ~= 18 then
			local plate = QBCore.Functions.GetPlate(vehicle)
			QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(isFlagged)
				if isFlagged then
					local coords = GetEntityCoords(playerPed)
					local blipsettings = {
						x = coords.x,
						y = coords.y,
						z = coords.z,
						sprite = 488,
						color = 1,
						scale = 0.9,
						text = Lang:t('info.camera_speed', { radarid = radarID})
					}
					local street1, street2 = table.unpack(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
					TriggerServerEvent('police:server:FlaggedPlateTriggered', radarID, plate, street1, street2, blipsettings)
				end
			end, plate)
		end
	end

	if not isInMarker and HasAlreadyEnteredMarker and lastRadar == radarID then
		HasAlreadyEnteredMarker = false
		lastRadar = nil
	end
end

CreateThread(function()
	while true do
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			for key, value in pairs(Config.Radars) do
				HandleSpeedCam(value, key)
			end
			Wait(200)
		else
			Wait(2500)
		end
	end
end)
