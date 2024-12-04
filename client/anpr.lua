local lastRadar = nil
local HasAlreadyEnteredMarker = false

local function IsInMarker(playerPos, speedCam)
	return #(playerPos - speedCam) < 20.0
end

local function HandleSpeedCam(speedCam, radarID)
	local playerPed = PlayerPedId()
	local playerPos = GetEntityCoords(playerPed)
	local isInMarker = IsInMarker(playerPos, speedCam)

	if isInMarker and not HasAlreadyEnteredMarker and lastRadar == nil then
		HasAlreadyEnteredMarker = true
		lastRadar = radarID
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		if vehicle == 0 then return end
		local is_driver = GetPedInVehicleSeat(vehicle, -1) == playerPed
		if not is_driver then return end
		if GetVehicleClass(vehicle) == 18 then return end
		local plate = QBCore.Functions.GetPlate(vehicle)
		QBCore.Functions.TriggerCallback('police:server:IsPlateFlagged', function(isFlagged)
			if isFlagged then
				local coords = Config.Radars[radarID]
				TriggerServerEvent('police:server:FlaggedPlateTriggered', coords, plate)
			end
		end, plate)
	end

	if not isInMarker and HasAlreadyEnteredMarker and lastRadar == radarID then
		HasAlreadyEnteredMarker = false
		lastRadar = nil
	end
end

if Config.EnableRadars then
	CreateThread(function()
		while true do
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				for i = 1, #Config.Radars do
					local value = Config.Radars[i]
					HandleSpeedCam(value, i)
				end
				Wait(200)
			else
				Wait(2500)
			end
		end
	end)
end
