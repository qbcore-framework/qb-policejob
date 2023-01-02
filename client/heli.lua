local fov_max = 80.0
local fov_min = 10.0 -- max zoom level (smaller fov is more zoom)
local zoomspeed = 2.0 -- camera zoom speed
local speed_lr = 3.0 -- speed by which the camera pans left-right
local speed_ud = 3.0 -- speed by which the camera pans up-down
local toggle_helicam = 51 -- control id of the button by which to toggle the helicam mode. Default: INPUT_CONTEXT (E)
local toggle_vision = 25 -- control id to toggle vision mode. Default: INPUT_AIM (Right mouse btn)
local toggle_rappel = 154 -- control id to rappel out of the heli. Default: INPUT_DUCK (X)
local toggle_spotlight = 74 -- control id to toggle the front spotlight Default: INPUT_VEH_HEADLIGHT (H)
local toggle_lock_on = 22 -- control id to lock onto a vehicle with the camera. Default is INPUT_SPRINT (spacebar)
local spotlight_state = false

-- Script starts here
local helicam = false
local fov = (fov_max+fov_min)*0.5
local vision_state = 0 -- 0 is normal, 1 is nightmode, 2 is thermal vision

local isScanning = false
local isScanned = false
local scanValue = 0

local vehicle_detected = nil
local locked_on_vehicle = nil

-- Functions
local function IsPlayerInPolmav()
	local lPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(lPed)
	return IsVehicleModel(vehicle, GetHashKey(Config.PoliceHelicopter))
end

local function IsHeliHighEnough(heli)
	return GetEntityHeightAboveGround(heli) > 1.5
end

local function ChangeVision()
	if vision_state == 0 then
		SetNightvision(true)
		vision_state = 1
	elseif vision_state == 1 then
		SetNightvision(false)
		SetSeethrough(true)
		vision_state = 2
	else
		SetSeethrough(false)
		vision_state = 0
	end
end

local function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(19) -- weapon wheel
	HideHudComponentThisFrame(1) -- Wanted Stars
	HideHudComponentThisFrame(2) -- Weapon icon
	HideHudComponentThisFrame(3) -- Cash
	HideHudComponentThisFrame(4) -- MP CASH
	HideHudComponentThisFrame(13) -- Cash Change
	HideHudComponentThisFrame(11) -- Floating Help Text
	HideHudComponentThisFrame(12) -- more floating help text
	HideHudComponentThisFrame(15) -- Subtitle Text
	HideHudComponentThisFrame(18) -- Game Stream
end

local function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		local new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		local new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5) -- Clamping at top (cant see top of heli) and at bottom (doesn't glitch out in -90deg)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

local function HandleZoom(cam)
	if IsControlJustPressed(0,241) then -- Scrollup
		fov = math.max(fov - zoomspeed, fov_min)
	end
	if IsControlJustPressed(0,242) then
		fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
	end
	local current_fov = GetCamFov(cam)
	if math.abs(fov-current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
		fov = current_fov
	end
	SetCamFov(cam, current_fov + (fov - current_fov)*0.05) -- Smoothing of camera zoom
end

local function RotAnglesToVec(rot) -- input vector3
	local z = math.rad(rot.z)
	local x = math.rad(rot.x)
	local num = math.abs(math.cos(x))
	return vector3(-math.sin(z)*num, math.cos(z)*num, math.sin(x))
end

local function GetVehicleInView(cam)
	local coords = GetCamCoord(cam)
	local forward_vector = RotAnglesToVec(GetCamRot(cam, 2))
	--DrawLine(coords, coords+(forward_vector*100.0), 255,0,0,255) -- debug line to show LOS of cam
	local rayhandle = CastRayPointToPoint(coords, coords+(forward_vector*400.0), 10, GetVehiclePedIsIn(PlayerPedId()), 0)
	local _, _, _, _, entityHit = GetRaycastResult(rayhandle)
	if entityHit>0 and IsEntityAVehicle(entityHit) then
		return entityHit
	else
		return nil
	end
end

local function RenderVehicleInfo(vehicle)
	local pos = GetEntityCoords(vehicle)
	local model = GetEntityModel(vehicle)
	local vehname = GetLabelText(GetDisplayNameFromVehicleModel(model))
	local licenseplate = QBCore.Functions.GetPlate(vehicle)
	local speed = math.ceil(GetEntitySpeed(vehicle) * 3.6)
	local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
	local streetLabel = GetStreetNameFromHashKey(street1)
	if street2 ~= 0 then
		streetLabel = streetLabel .. " | " .. GetStreetNameFromHashKey(street2)
	end
	SendNUIMessage({
		type = "heliupdateinfo",
		model = vehname,
		plate = licenseplate,
		speed = speed,
		street = streetLabel,
	})
end

-- Events
RegisterNetEvent('heli:spotlight', function(serverID, state)
	local heli = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(serverID)), false)
	SetVehicleSearchlight(heli, state, false)
end)

-- Threads
CreateThread(function()
	while true do
		Wait(0)
		if LocalPlayer.state.isLoggedIn then
			if PlayerJob.name == 'police' and PlayerJob.onduty then
				if IsPlayerInPolmav() then
					local lPed = PlayerPedId()
					local heli = GetVehiclePedIsIn(lPed)

					if IsHeliHighEnough(heli) then
						if IsControlJustPressed(0, toggle_helicam) then -- Toggle Helicam
							PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
							helicam = true
							SendNUIMessage({
								type = "heliopen",
							})
						end

						if IsControlJustPressed(0, toggle_rappel) then -- Initiate rappel
							if GetPedInVehicleSeat(heli, 1) == lPed or GetPedInVehicleSeat(heli, 2) == lPed then
								PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
								TaskRappelFromHeli(PlayerPedId(), 1)
							end
						end
					end

					if IsControlJustPressed(0, toggle_spotlight) and (GetPedInVehicleSeat(heli, -1) == lPed or GetPedInVehicleSeat(heli, 0) == lPed) then
						spotlight_state = not spotlight_state
						TriggerServerEvent("heli:spotlight", spotlight_state)
						PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					end

					if helicam then
						SetTimecycleModifier("heliGunCam")
						SetTimecycleModifierStrength(0.3)
						local scaleform = RequestScaleformMovie("HELI_CAM")
						while not HasScaleformMovieLoaded(scaleform) do
							Wait(0)
						end
						local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
						AttachCamToEntity(cam, heli, 0.0,0.0,-1.5, true)
						SetCamRot(cam, 0.0,0.0,GetEntityHeading(heli))
						SetCamFov(cam, fov)
						RenderScriptCams(true, false, 0, 1, 0)
						PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
						PushScaleformMovieFunctionParameterInt(0) -- 0 for nothing, 1 for LSPD logo
						PopScaleformMovieFunctionVoid()
						locked_on_vehicle = nil
						while helicam and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == heli) and IsHeliHighEnough(heli) do
							if IsControlJustPressed(0, toggle_helicam) then -- Toggle Helicam
								PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
								helicam = false
								isScanned = false
								scanValue = 0
								SendNUIMessage({
									type = "disablescan",
								})
								SendNUIMessage({
									type = "heliclose",
								})
							end
							if IsControlJustPressed(0, toggle_vision) then
								PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
								ChangeVision()
							end
							local zoomvalue = 0
							if locked_on_vehicle then
								if DoesEntityExist(locked_on_vehicle) then
									PointCamAtEntity(cam, locked_on_vehicle, 0.0, 0.0, 0.0, true)
									if IsControlJustPressed(0, toggle_lock_on) then
										PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
										locked_on_vehicle = nil
										local rot = GetCamRot(cam, 2) -- All this because I can't seem to get the camera unlocked from the entity
										fov = GetCamFov(cam)
										local old_cam = cam
										DestroyCam(old_cam, false)
										cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
										AttachCamToEntity(cam, heli, 0.0,0.0,-1.5, true)
										SetCamRot(cam, rot, 2)
										SetCamFov(cam, fov)
										RenderScriptCams(true, false, 0, 1, 0)
										isScanned = false
										scanValue = 0
										SendNUIMessage({
											type = "disablescan",
										})
									end
								else
									isScanned = false
									SendNUIMessage({
										type = "disablescan",
									})
									locked_on_vehicle = nil -- Cam will auto unlock when entity doesn't exist anyway
								end
							else
								zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
								CheckInputRotation(cam, zoomvalue)
								vehicle_detected = GetVehicleInView(cam)
								if DoesEntityExist(vehicle_detected) then
									isScanning = true
								else
									isScanning = false
								end
							end
							HandleZoom(cam)
							HideHUDThisFrame()
							PushScaleformMovieFunction(scaleform, "SET_ALT_FOV_HEADING")
							PushScaleformMovieFunctionParameterFloat(GetEntityCoords(heli).z)
							PushScaleformMovieFunctionParameterFloat(zoomvalue)
							PushScaleformMovieFunctionParameterFloat(GetCamRot(cam, 2).z)
							PopScaleformMovieFunctionVoid()
							DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
							Wait(0)
						end
						helicam = false
						ClearTimecycleModifier()
						fov = (fov_max+fov_min)*0.5 -- reset to starting zoom level
						RenderScriptCams(false, false, 0, 1, 0) -- Return to gameplay camera
						SetScaleformMovieAsNoLongerNeeded(scaleform) -- Cleanly release the scaleform
						DestroyCam(cam, false)
						SetNightvision(false)
						SetSeethrough(false)
					end
				else
					Wait(2000)
				end
			else
				Wait(2000)
			end
		else
			Wait(2000)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1)
		if helicam then
			if isScanning and not isScanned then
				if scanValue < 100 then
					scanValue = scanValue + 1
					SendNUIMessage({
						type = "heliscan",
						scanvalue = scanValue,
					})
					if scanValue == 100 then
						PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
						locked_on_vehicle = vehicle_detected
						isScanning = false
						isScanned = true
					end
					Wait(10)
				end
			elseif isScanned and not isScanning and locked_on_vehicle then
				scanValue = 100
				RenderVehicleInfo(locked_on_vehicle)
				isScanning = false
				Wait(100)
			else
				scanValue = 0
				Wait(500)
			end
		else
			Wait(1000)
		end
	end
end)
