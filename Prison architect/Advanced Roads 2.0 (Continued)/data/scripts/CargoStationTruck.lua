
--    All vehicles use same script

local timePos = 0
local timeTot=0
local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects
local MarkerFound=false

local CalloutEntitiesToFind = { "Fireman", "Paramedic", "RiotGuard", "ArmedGuard", "Soldier", "EliteOps" }
local CalloutSkinTypes = { ["Fireman"] = "FireEngine", ["Paramedic"] = "Ambulance", ["RiotGuard"] = "RiotVan", ["ArmedGuard"] = "RiotVan", ["Soldier"] = "Troop", ["EliteOps"] = "RiotVan" }
local MyEntities = {}

local EntitySpots = { [1] = 1.475, [2] = 1.975, [3] = 2.475, [4] = 2.975, [5] = 1.475, [6] = 1.975, [7] = 2.475, [8] = 2.975 }

local blinkTimer = 0
local nextGarageFound=false
local ThisIsMyGarage = false
local NewEngine1 = {}
local NewEngine2 = {}
local NewLimo1 = {}
local NewLimo2 = {}
local Limo2RepairOrderPapersNr = 0

function Create()
	Set(this,"GateCount",1)
	Set(this,"CargoStopCount",1)
	
	Set(this,"CraneUID",0)
	Set(this,"GarageCount",0)
	Set(this,"LimoSpawned",false)
	Set(this,"PartsSpawned",false)
	Set(this,"nextGarageFound",false)
	Set(this,"OrderAmount",0)
	Set(this,"issueLeaveJob",false)
	
	Set(this,"VehicleState","Arriving")
	Set(this,"UpdateVehicleBehind",false)
	Set(this,"DistanceBehind",0)
	Set(this,"VehicleTypeBehind","None")
	Set(this,"UpdateVehicleInFront",false)
	Set(this,"DistanceInFront",0)
	Set(this,"VehicleTypeInFront","None")
	Set(this,"VelX",0)
	Set(this,"VelY",0)
	Set(this,"FollowingID",-1)
	Set(this,"FollowUpID",-1)
end

function Update(timePassed)
	if timePerGateUpdate==nil then
		Init()
		return
	end
		
	timeTot = timeTot+timePassed
	timePos = timePos+timePassed
	blinkTimer = blinkTimer+timePassed

	if timePos >= timePerPositionUpdate then
		timePos = 0
		
		if this.DeleteMe == true then DeleteTruckClicked() return end

		MyTailLights = this.Pos.y - this.Tail
		MyHeadLights = this.Pos.y + this.Head
		
		if IsCallOut and not CalloutUnloaded then KeepEntitiesLoaded() end
		
		 -- newT.Pos.y = MyTailLights
		 -- newH.Pos.y = MyHeadLights
		
		
		if Get(this,"UpdateVehicleBehind") == true then
			LoadVehicleBehindMe()
		end
		if Get(this,"UpdateVehicleInFront") == true then
			LoadVehicleInFront()
		end
		if Exists(MyVehicleBehind) then
			VehicleHeadLights = MyVehicleBehind.Pos.y + MyVehicleBehind.Head
		end
		if Exists(MyVehicleInFront) then
			VehicleTailLights = MyVehicleInFront.Pos.y - MyVehicleInFront.Tail
		end

		
		if not ForcedClearAuthDone then
			if MyHeadLights >= MapEdge-11 and not Get(this,"LeavingMap") then
				StopTheVehicle = true
				this.VelY = 0
				Set(this,"GateCount",TotalGates)
				print("Forced close gates")
				CloseGateBehindMe(true)
				ClearAuthGateBehindMe(true)
				if Exists(MyTruckBay1) then SpawnSupplyTruck(MyTruckBay1) end
				if Exists(MyTruckBay2) then SpawnSupplyTruck(MyTruckBay2) end
				if Exists(MyTruckSkin) then MyTruckSkin.Delete() end
				---
				-- if Get(this,"PartsSpawned") == true then
					-- DeleteGarageCargo()
					-- Set(MyCraneBooth,"PartsTruckArriving","no")
				-- elseif Get(this,"LimoSpawned") == true then
					-- DeleteGarageCargo()
					-- Set(MyCraneBooth,"LimoTruckArriving","no")
				-- end
				---
				timeTot = 0
				return
			else
				if StopTheVehicle then 
					this.VelY = 0
					timePos = timePerPositionUpdate
					
				elseif not IsGarageTruck and NextCargoStopY - MyHeadLights <= 1 then 			-- stop vehicle and unload stuff at Cargo stop --
					StopTheVehicle = true
					CheckCurrentCargoStop = true
				elseif not IsGarageTruck and NextCargoStopY - MyHeadLights <= 3 then			-- slow down when arriving at Cargo stop --
					this.VelY = (NextCargoStopY - MyHeadLights) - 0.25
					-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_SlowingDownForStation",this.HomeUID,"H",this.CargoStationID,"I",this.VelY,"S" }

				---
				-- elseif IsGarageTruck and this.VehicleState=="Arriving" and MyCraneBooth.TruckParkY-MyHeadLights <= 0 then
					-- this.VehicleState = "EnteringGarage"
					-- if not Get(this,"VehiclesUpdated") then
						-- UpdateFollowUps()
					-- end
				-- elseif IsGarageTruck and this.VehicleState == "EnteringGarage" and MyCraneBooth.TruckParkY-MyHeadLights <= 0 then
					-- BlinkLight()
					-- TurnIn()
				-- elseif IsGarageTruck and this.VehicleState == "ProcessingGarage" then
					-- this.VelY = 0
				-- elseif IsGarageTruck and this.VehicleState == "LeavingGarage" then
					-- BlinkLight()
					-- if Exists(MyMarker) and Get(MyMarker,"Authorized"..this.RepairedLimoGate) == this.HomeUID then
						-- TurnOut()
					-- elseif NextGateY - MyHeadLights > 1 then
						-- this.VelX = 0
						-- if this.VelY < 3 then
							-- this.VelY = this.VelY+0.1
						-- end
						-- if this.VelY > 3 then this.VelY = 3 end
					-- elseif Exists(MyVehicleInFront) and VehicleTailLights - MyHeadLights <= 8.5 then
						-- this.VelX = 0
						-- this.VelY = 0
						-- MyTruckSkin.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nStopped and waiting for "..MyVehicleInFront.HomeUID
					-- elseif NextGateY - MyHeadLights <= 1 then		-- stop vehicle and request to open gate --
						-- StopTheVehicle = true
					-- end
				---
					
				elseif NextGateY - MyHeadLights <= 1 then		-- stop vehicle and request to open gate --
					StopTheVehicle = true
				elseif NextGateY - MyHeadLights <= 3 then		-- slow down when arriving at gate --
					this.VelY = (NextGateY - MyHeadLights) - 0.25
					-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_SlowingDownForGate",this.HomeUID,"H",this.CargoStationID,"I",this.VelY,"S" }
					
				elseif Exists(MyVehicleInFront) and VehicleTailLights - MyHeadLights <= 3 then
					this.VelY = VehicleTailLights - MyHeadLights - 0.5
					if this.VelY < 0.01 then
						this.VelY = 0
						-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_StoppedForVehicle",this.HomeUID,"H",this.CargoStationID,"I",MyVehicleInFront.HomeUID,"F" }
					-- else
						-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_SlowingDownForVehicle",this.HomeUID,"H",this.CargoStationID,"I",MyVehicleInFront.HomeUID,"F",this.VelY,"S" }
					end
				elseif not Get(this,"LeavingMap") then
					if this.VelY < 3 then
						this.VelY = this.VelY+0.1
					end
					if this.VelY > 3 then this.VelY = 3 end		-- speed limiter for all vehicles
					----MyTruckSkin.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nDistance to next gate ("..this.GateCount..") is: "..math.floor(NextGateY-MyHeadLights).."  Speed: "..this.Speed

					-- local tmpGC = this.GateCount
					-- local tmpDistG = 0
					-- if TotalGates >= this.GateCount then tmpDistG = GateList[this.GateCount].GatePosY - MyHeadLights end
					-- local tmpBehind = "none"
					-- local tmpDistB = 0
					-- if MyVehicleBehind ~= nil and MyVehicleBehind.SubType ~= nil then tmpBehind = MyVehicleBehind.HomeUID; tmpDistB = MyTailLights - VehicleHeadLights end
					-- local tmpFront = "none"
					-- local tmpDistF = 0
					-- if MyVehicleInFront ~= nil and MyVehicleInFront.SubType ~= nil then tmpFront = MyVehicleInFront.HomeUID; tmpDistF = VehicleTailLights - MyHeadLights end
					
					-- if TotalGates ~= nil and TotalGates >= this.GateCount then
						-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_DrivingWithGates",this.HomeUID,"H",this.CargoStationID,"I",this.VehicleState,"A",tmpGC,"G",tmpDistG,"X",this.VelY,"S",tmpBehind,"B",tmpDistB,"Y",tmpFront,"F",tmpDistF,"Z" }
						
					-- else
						-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_DrivingNoGates",this.HomeUID,"H",this.CargoStationID,"I",this.VehicleState,"A",this.VelY,"S",tmpBehind,"B",tmpDistB,"Y",tmpFront,"F",tmpDistF,"Z" }
					-- end
				end
				
				if PriorGateY > 0 and not Get(this,"LeavingMap") then
					if PriorGateY <= MyTailLights+1 then
						--MyTruckSkin.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nDistance to prior stop ("..(this.GateCount-1)..") is: "..(MyTailLights - PriorGateY).." Distance to next stop ("..this.GateCount..") is: "..(NextGateY-MyHeadLights).."  Speed: "..this.Speed
						if MyTailLights - PriorGateY >= 5 then
							ClearAuthGateBehindMe()
						elseif MyTailLights - PriorGateY >= -1 then
							CloseGateBehindMe()
						end
					end
				end
			end
		else
			print("truck deleted")
			this.Delete()
		end
	end
	
	Object.ApplyVelocity(MyTruckSkin,this.VelX,this.VelY,false)
	
	if timeTot >= timePerGateUpdate then
		timeTot = 0
		
		if this.VehicleState=="Arriving" or this.VehicleState=="Leaving" or this.VehicleState == "EnteringGarage" or this.VehicleState=="LeavingGarage" then
			if Exists(MyMarker) and GatesHash == MyMarker.GatesHash and StationsHash == MyMarker.StationsHash then
				if not Get(this,"LeavingMap") then
					if not IsGarageTruck and StopTheVehicle == true and not StopCheckingCargoStops and CheckCurrentCargoStop == true then
						-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_StoppedAndProcessing",this.HomeUID,"H",this.CargoStationID,"I" }
						WaitForCargoStation()
					elseif not StopOpeningGates and StopTheVehicle == true then
						-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_StoppedAndWaiting",this.HomeUID,"H",this.CargoStationID,"I" }
						WaitForGateToOpen()
					end
				end
			else
				if MarkerFound==true then
					ResetGates()
					return
				else
					this.DeleteMe = true
					DeleteTruckClicked()
					MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_NoRoadMarker",this.HomeUID,"H" }
				end							-- else there were no markers at all, so do nothing
			end
			
		elseif this.VehicleState == "Processing" and not IsGarageTruck then
			WaitForCargoStation()
			
		---
		-- elseif IsGarageTruck and not Get(this,"ReadyToLeave") then
		
			-- WaitForGarage()
		
			-- if MyTruckSkin.Slot3.i == -1 then Set(this,"UnloadTruckSlot0",false); Set(this,"UnloadEngineSlot0",false); Set(this,"Slot0IsAtX",nil); Set(this,"Slot0IsAtY",nil) end
			-- if MyTruckSkin.Slot4.i == -1 then Set(this,"UnloadTruckSlot1",false); Set(this,"UnloadEngineSlot1",false); Set(this,"Slot1IsAtX",nil); Set(this,"Slot1IsAtY",nil) end
			
			-- if Get(MyCraneBooth,"GarageIsFull") == "yes" and Get(this,"LimoSpawned") == true then			-- limo truck
				-- print("GarageIsFull, leaving")
				-- Set(MyCraneBooth,"UnloadTruckSlot0",false)
				-- Set(MyCraneBooth,"UnloadTruckSlot1",false)
				-- Set(this,"UnloadTruckSlot0",false)
				-- Set(this,"UnloadTruckSlot1",false)
			-- end
			-- if Get(MyCraneBooth,"PartsRackIsFull") == "yes" and Get(this,"PartsSpawned") == true then	-- engines truck
				-- print("PartsRackIsFull, leaving")
				-- Set(MyCraneBooth,"UnloadEngineSlot0",false)
				-- Set(MyCraneBooth,"UnloadEngineSlot1",false)
				-- Set(this,"UnloadEngineSlot0",false)
				-- Set(this,"UnloadEngineSlot1",false)
			-- end
			-- if Get(this,"PartsSpawned") == true and this.UnloadEngineSlot0 == false and this.UnloadEngineSlot1 == false then
				-- Set(this,"ReadyToLeave",true)
				-- Set(this,"issueLeaveJob",true)
			-- end
			-- if Get(this,"LimoSpawned") == true and this.UnloadTruckSlot0 == false and this.UnloadTruckSlot1 == false then
				-- Set(this,"ReadyToLeave",true)
				-- Set(this,"issueLeaveJob",true)
			-- end
		-- elseif IsGarageTruck and Get(this,"issueLeaveJob") == true then
			-- if MyCraneBooth.IsMilitary == "Yes" then
				-- Object.CreateJob(this,"TruckDriverLeavingMilitary")
			-- else
				-- Object.CreateJob(this,"TruckDriverLeaving")
			-- end
		---
		end
	end
end

function KeepEntitiesLoaded()
	for L = 0,7 do
		Set(MyTruckBay1,"Slot"..L..".i",MyEntities[L+1].Id.i)
		Set(MyTruckBay1,"Slot"..L..".u",MyEntities[L+1].Id.u)
		MyEntities[L+1].Loaded = true
		MyEntities[L+1].ClearRouting()
		MyEntities[L+1].AISetTarget = false
	end
	if this.CalloutUnloaded == true then CalloutUnloaded = true end
end

function Init()
	if this.Number == nil then return end
	
	if Get(this,"IsCallOut") == true then IsCallOut = true end
	if IsCallOut then FindMyCalloutEntities() end

	Interface.AddComponent(this,"SeparatorTruck", "Caption", "tooltip_CargoStationTruck_Separatorline")
	Interface.AddComponent(this,"DeleteTruck", "Button", "Delete")
	
	if Get(this,"MyType") == "Garage" then IsGarageTruck = true end
	
	Set(this,"ErrorLog"," ")
	if Get(this,"VelY")==nil then
		Set(this,"VelX",0)
		Set(this,"VelY",0)
	end
	if Get(this,"MyType") == "Cargo" or Get(this,"MyType") == "Exports" or Get(this,"MyType") == "Garbage" then
		Set(this,"Tail",6.5)
		Set(this,"Head",1.5)
	elseif Get(this,"MyType") == "Intake" then
		Set(this,"Tail",4)
		Set(this,"Head",1.25)
	elseif Get(this,"MyType") == "Emergency" then
		Set(this,"Tail",3.75)
		Set(this,"Head",1.5)
				---
	-- elseif Get(this,"MyType") == "Garage" then
		-- if Get(this,"SkinType") == "LimoTow" then
			-- Set(this,"Tail",7)
			-- Set(this,"Head",1.75)
		-- else -- limo engine truck
			-- Set(this,"Tail",4.5)
			-- Set(this,"Head",1.5)
		-- end
				---
	elseif Get(this,"MyType") == "Callout" then
		if Get(this,"SkinType") == "Ambulance" or Get(this,"SkinType") == "RiotVan" or Get(this,"SkinType") == "Troop" then
			Set(this,"Tail",3.75)
			Set(this,"Head",1.5)
		else -- FireEngine
			Set(this,"Tail",7)
			Set(this,"Head",1.25)
		end
	end
	FindMyTruckSkin()
	MapEdge = World.NumCellsY+10
	NextGateY = MapEdge
	PriorGateY = 0
	NextCargoStopY = MapEdge
	PriorCargoStopY = 0
	MyTailLights = this.Pos.y - this.Tail
	MyHeadLights = this.Pos.y + this.Head
	 -- newT = Object.Spawn("HeadTailChecker",this.Pos.x,MyTailLights)
	 -- newH = Object.Spawn("HeadTailChecker",this.Pos.x,MyHeadLights)
	FindMyRoadMarker()
	GetGates()
	GetCargoStops()
	if IsGarageTruck then
				---
		-- FindMyCrane()
		-- if this.VehicleState ~= "ProcessingGarage" then
			-- if Get(this,"FollowingID") == -1 then
				-- FindVehicleInFront()
			-- else
				-- LoadVehicleInFront()
			-- end
			-- if Get(this,"FollowUpID") == -1 then
				-- FindVehicleBehindMe()
			-- else
				-- LoadVehicleBehindMe()
			-- end
		-- end
				---
	else
		FindMyTruckBays()
		if Get(this,"FollowingID") == -1 then
			FindVehicleInFront()
		else
			LoadVehicleInFront()
		end
		if Get(this,"FollowUpID") == -1 then
			FindVehicleBehindMe()
		else
			LoadVehicleBehindMe()
		end
	end
	this.Tooltip = { "tooltip_CargoStationTruck_TruckSkin",this.HomeUID,"H" }
	MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_TruckSkin",this.HomeUID,"H" }
	timePerPositionUpdate = 0.1
	timePerGateUpdate = 1
	print("[00] -- "..this.HomeUID.." Init done")
end

function FindMyCalloutEntities()
	print("FindMyCalloutEntities")
	print("Finding "..this.CalloutEntities)
	local nearbyObjects = Find(this,this.CalloutEntities,9)
	for thatEntity, distance in pairs(nearbyObjects) do
		if thatEntity.HomeUID == this.HomeUID then
			if thatEntity.Number == 1	  then MyEntity1 = thatEntity; MyEntities[1] = MyEntity1; print("MyEntity1 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 2 then MyEntity2 = thatEntity; MyEntities[2] = MyEntity2; print("MyEntity2 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 3 then MyEntity3 = thatEntity; MyEntities[3] = MyEntity3; print("MyEntity3 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 4 then MyEntity4 = thatEntity; MyEntities[4] = MyEntity4; print("MyEntity4 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 5 then MyEntity5 = thatEntity; MyEntities[5] = MyEntity5; print("MyEntity5 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 6 then MyEntity6 = thatEntity; MyEntities[6] = MyEntity6; print("MyEntity6 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 7 then MyEntity7 = thatEntity; MyEntities[7] = MyEntity7; print("MyEntity7 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 8 then MyEntity8 = thatEntity; MyEntities[8] = MyEntity8; print("MyEntity8 "..thatEntity.Type.." found at "..distance)
			end
		end
	end
	nearbyObjects = nil
	if not Exists(MyEntity1) then
		print(" -- ERROR --- MyEntity1 not found")
	end
	if not Exists(MyEntity2) then
		print(" -- ERROR --- MyEntity2 not found")
	end
	if not Exists(MyEntity3) then
		print(" -- ERROR --- MyEntity3 not found")
	end
	if not Exists(MyEntity4) then
		print(" -- ERROR --- MyEntity4 not found")
	end
	if not Exists(MyEntity5) then
		print(" -- ERROR --- MyEntity5 not found")
	end
	if not Exists(MyEntity6) then
		print(" -- ERROR --- MyEntity6 not found")
	end
	if not Exists(MyEntity7) then
		print(" -- ERROR --- MyEntity7 not found")
	end
	if not Exists(MyEntity8) then
		print(" -- ERROR --- MyEntity8 not found")
	end
end

function ResetGates()
	print("[H1] -- "..this.HomeUID.." Marker got removed or Gates were added or removed on this lane, reset gates and vehicle")
	-- this.VelY = 0
	-- MyTruckSkin.Pos.y = 6
	
	-- MyTailLights = 0
	-- MyHeadLights = 6
	for i = 1,TotalGates do
		Set(this,"ClearedAuth"..i,nil)
		Set(this,"ClosedGate"..i,nil)
	end
	for i = 1,TotalCargoStops do
		Set(this,"CargoStationChecked"..i,nil)
		Set(this,"CargoStationDone"..i,nil)
	end
	Set(this,"GateCount",1)
	Set(this,"CargoStopCount",1)
	Set(this,"GateBehindMeClosed",nil)
	Set(this,"Ready",nil)
	GateList = nil
	CargoStopList = nil
	FindMyRoadMarker()
	if Exists(MyMarker) then
		GetGates()
		GetCargoStops()
	end
	StopTheVehicle = nil
	StopOpeningGates = nil
	StopCheckingCargoStops = nil
	CheckCurrentCargoStop = false
	ForcedClearAuthDone = nil
	this.VehicleState = "Arriving"
	Set(this,"LeavingMap",nil)
end

function FindMyRoadMarker()
	print("FindMyRoadMarker")
    local roadMarkers = Find(this,"RoadMarker2",10000)
	MarkerFound = false
    if next(roadMarkers) then
		for thatMarker,dist in pairs(roadMarkers) do
			if thatMarker.Pos.x == this.Pos.x or thatMarker.MarkerUID == this.MarkerUID then
				print("[A1] -- "..this.HomeUID.." Marker found")
				MyMarker = thatMarker
				Set(this,"MarkerUID",thatMarker.Id.u)
				if this.RoadX == nil then Set(this,"RoadX",thatMarker.Pos.x) end
				if this.VehicleState=="Arriving" or this.VehicleState=="Leaving" then
					this.Pos.x = thatMarker.Pos.x
				end
				MarkerFound = true
				break
			end
		end
	end
	roadMarkers = nil
	if not Exists(MyMarker) then
		print(" -- ERROR --- MyMarker not found")
		--DeleteTruckClicked()
	end
end

function FindMyTruckSkin()
	local skinFound = false
	local nearbyObject = Find(this.SkinType.."TruckSkin",9)
	if next(nearbyObject) then
		for thatSkin, distance in pairs(nearbyObject) do
			if thatSkin.HomeUID == this.HomeUID then
				MyTruckSkin = thatSkin
				print("Skin found at "..distance)
				-- Set(MyTruckSkin,"Slot0.i",this.Id.i)
				-- Set(MyTruckSkin,"Slot0.u",this.Id.u)
				-- Set(this,"CarrierId.i",MyTruckSkin.Id.i)
				-- Set(this,"CarrierId.u",MyTruckSkin.Id.u)
				-- Set(this,"Loaded",true)
				skinFound = true
				break
			end
		end
	end
	if skinFound == false then
		MyTruckSkin = Object.Spawn(this.SkinType.."TruckSkin",this.Pos.x,1)
		Set(MyTruckSkin,"HomeUID",this.HomeUID)
		Set(MyTruckSkin,"Slot0.i",this.Id.i)
		Set(MyTruckSkin,"Slot0.u",this.Id.u)
		Set(this,"CarrierId.i",MyTruckSkin.Id.i)
		Set(this,"CarrierId.u",MyTruckSkin.Id.u)
		Set(this,"Loaded",true)
	end
end

function FindMyTruckBays(Load)
	print("FindMyTruckBay")
	local bay1Found = false
	local bay2Found = false
	local nearbyObject = Find(this.MyType.."TruckBay",8)
	if next(nearbyObject) then
		for thatBay, distance in pairs(nearbyObject) do
			if thatBay.HomeUID == this.HomeUID and thatBay.TruckBayNr == 1 then
				MyTruckBay1 = thatBay
				Set(MyTruckBay1,"MarkerUID",Get(this,"MarkerUID"))
				if Load == true then
					Set(MyTruckSkin,"Slot3.i",MyTruckBay1.Id.i)	-- loading it again after the terminal just loaded this already seems to
					Set(MyTruckSkin,"Slot3.u",MyTruckBay1.Id.u)	-- produce a bug where objects gets loaded in wrong markers defined on the sprite
					Set(MyTruckBay1,"CarrierId.i",MyTruckSkin.Id.i)
					Set(MyTruckBay1,"CarrierId.u",MyTruckSkin.Id.u)
					Set(MyTruckBay1,"Loaded",true)
				end
				MyTruckBay1.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",MyTruckBay1.TruckBayNr,"N",MyTruckBay1.CargoAmount,"A" }
				bay1Found = true
				print("bay 1 found at "..distance)
			end
			if thatBay.HomeUID == this.HomeUID and thatBay.TruckBayNr == 2 then
				MyTruckBay2 = thatBay
				Set(MyTruckBay2,"MarkerUID",Get(this,"MarkerUID"))
				if Load == true then
					Set(MyTruckSkin,"Slot4.i",MyTruckBay2.Id.i)
					Set(MyTruckSkin,"Slot4.u",MyTruckBay2.Id.u)
					Set(MyTruckBay2,"CarrierId.i",MyTruckSkin.Id.i)
					Set(MyTruckBay2,"CarrierId.u",MyTruckSkin.Id.u)
					Set(MyTruckBay2,"Loaded",true)
				end
				MyTruckBay2.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",MyTruckBay2.TruckBayNr,"N",MyTruckBay2.CargoAmount,"A" }
				bay2Found = true
				print("bay 2 found at "..distance)
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyTruckBay1) then
		print(" -- ERROR --- My"..this.MyType.."TruckBay1 not found")
	end
	if not Exists(MyTruckBay2) then
		print(" -- ERROR --- My"..this.MyType.."TruckBay2 not found")
	end
end

function FillUpTruckBay(theBay) -- obsolete?
	for F = 0,7 do
		if Get(theBay,"Slot"..F..".i") == -1 then
			local NewStackHolder = Object.Spawn("DeliveryStackHolder",theBay.Pos.x,theBay.Pos.y)
			Set(NewStackHolder,"Tooltip","Contents: dummyload")
			Set(theBay,"Slot"..F..".i",NewStackHolder.Id.i)
			Set(theBay,"Slot"..F..".u",NewStackHolder.Id.u)
			Set(NewStackHolder,"CarrierId.i",theBay.Id.i)
			Set(NewStackHolder,"CarrierId.u",theBay.Id.u)
			Set(NewStackHolder,"Loaded",true)
			NewStackHolder = nil
		end
	end
end

function GetGates()
	print("[G1] -- "..this.HomeUID.." Update gates list")
	GateList = {}
	PriorGateY = 0
	local i = 1
	local listComplete = false
	while not listComplete do
		if Get(MyMarker,"GatePosY"..i) ~= nil then
			GateList[i] = {}
			GateList[i]["GatePosY"] = Get(MyMarker,"GatePosY"..i)
			GateList[i]["GatePosX"] = Get(MyMarker,"GatePosX"..i)
			GateList[i]["LinkGate"] = Get(MyMarker,"LinkGate"..i)
			GateList[i]["LargeGate"] = Get(MyMarker,"LargeGate"..i)
			if i == 1 then
				PriorGateY = GateList[1].GatePosY
			elseif GateList[i].GatePosY <= MyTailLights then
				PriorGateY = GateList[i].GatePosY
			end
			print("[G2] -- "..this.HomeUID.." Marker X "..MyMarker.Pos.x.." - Gate: "..i.."   X "..GateList[i].GatePosX.."   Y "..GateList[i].GatePosY.."   large "..GateList[i].LargeGate.."   linked "..GateList[i].LinkGate)
			i = i + 1
		else
			listComplete = true
		end
	end
	
	TotalGates = Get(MyMarker,"TotalGates")
	GatesHash = Get(MyMarker,"GatesHash")
	if GatesHash ~= nil and TotalGates ~= nil then
		if this.GateCount <= TotalGates and TotalGates > 0 then
			if Get(this,"GateCount") == 1 then
				for i = 1,TotalGates do
					if GateList[i].GatePosY <= MyHeadLights then
						Set(this,"ClosedGate"..i,true)
						Set(this,"ClearedAuth"..i,true)
						Set(this,"GateCount",this.GateCount+1)
						if i == TotalGates then
							if i > 1 then PriorGateY = GateList[this.GateCount-1].GatePosY end
							NextGateY = MapEdge
							StopOpeningGates = true
							break
						else
							PriorGateY = GateList[this.GateCount].GatePosY
						end
					else
						NextGateY = GateList[i].GatePosY
						break
					end
				end
			else
				NextGateY = GateList[this.GateCount].GatePosY
			end
		else
			NextGateY = MapEdge
			StopOpeningGates = true
		end
		print("[G4] -- "..this.HomeUID.." GatesHash: "..GatesHash)
		print("[G4] -- Prior Gate: "..PriorGateY.."  Next Gate: "..NextGateY.."  TotalGates for my marker: "..TotalGates)
	else
		TotalGates = 0
		PriorGateY = 0
		NextGateY = MapEdge
		StopOpeningGates = true
		print("[G6] -- "..this.HomeUID.." Missing GatesHash or no gates on this lane")
	end
end

function GetCargoStops()
	print("[J1] -- "..this.HomeUID.." Update CargoStops list")
	CargoStopList = {}
	PriorCargoStopY = 0
	local i = 1
	local listComplete = false
	while not listComplete do
		if Get(MyMarker,"CargoPosY"..i) ~= nil then
			CargoStopList[i] = {}
			CargoStopList[i]["CargoPosY"] = Get(MyMarker,"CargoPosY"..i) + 1.5 - (math.random(15,65) / 100)
			CargoStopList[i]["CargoPosX"] = Get(MyMarker,"CargoPosX"..i)
			CargoStopList[i]["CargoStationID"] = Get(MyMarker,"CargoStationID"..i)
			CargoStopList[i]["CargoType"] = Get(MyMarker,"CargoType"..i)
			if i == 1 then
				PriorCargoStopY = CargoStopList[1].CargoPosY
			elseif CargoStopList[i].CargoPosY <= MyTailLights then
				PriorCargoStopY = CargoStopList[i].CargoPosY
			end
			print("[J2] -- "..this.HomeUID.." Marker X "..MyMarker.Pos.x.." - CargoStop: "..i.." ("..CargoStopList[i].CargoType..")   X "..CargoStopList[i].CargoPosX.."   Y "..CargoStopList[i].CargoPosY.."   ID "..CargoStopList[i].CargoStationID)
			i = i + 1
		else
			listComplete = true
		end
	end
	
	TotalCargoStops = Get(MyMarker,"TotalCargoStops")
	StationsHash = Get(MyMarker,"StationsHash")
	if StationsHash ~= nil and TotalCargoStops ~= nil then
		if this.CargoStopCount <= TotalCargoStops and TotalCargoStops > 0 then
			if Get(this,"CargoStopCount") == 1 then
				for j = 1,TotalCargoStops do
					if CargoStopList[j].CargoPosY <= MyHeadLights then
						Set(this,"CargoStationChecked"..j,true)
						Set(this,"CargoStopCount",this.CargoStopCount+1)
						if j == TotalCargoStops then
							if j > 1 then PriorCargoStopY = CargoStopList[this.CargoStopCount-1].CargoPosY end
							NextCargoStopY = MapEdge
							StopCheckingCargoStops = true
							break
						else
							PriorCargoStopY = CargoStopList[this.CargoStopCount].CargoPosY
						end
					else
						NextCargoStopY = CargoStopList[j].CargoPosY
						break
					end
				end
			else
				NextCargoStopY = CargoStopList[this.CargoStopCount].CargoPosY
			end
		else
			NextCargoStopY = MapEdge
			StopCheckingCargoStops = true
		end
		print("[J4] -- "..this.HomeUID.." StationsHash: "..StationsHash)
		print("[J4] -- Prior CargoStop: "..PriorCargoStopY.."  Next CargoStop: "..NextCargoStopY.."  Total CargoStops for my marker: "..TotalCargoStops)
	else
		TotalCargoStops = 0
		PriorCargoStopY = 0
		NextCargoStopY = MapEdge
		StopCheckingCargoStops = true
		print("[J6] -- "..this.HomeUID.." Missing StationsHash or no CargoStops on this lane")
	end
end

function FindMyCargoStopSign()
	print("FindMyCargoStopSign")
	local signFound = false
	local nearbyObject = Find("CargoStopSign",5)
	if next(nearbyObject) then
		for thatSign, distance in pairs(nearbyObject) do
			if Get(thatSign,"MarkerUID") == Get(this,"MarkerUID") then
				MyCargoStopSign = thatSign
				signFound = true
				print("Sign found at dist "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyCargoStopSign) then
		print(" -- ERROR --- MyCargoStopSign not found")
		DeleteTruckClicked()
	end
end

function FindMyCargoStationControl()
	print("FindMyCargoStationControl")
	local controlFound = false
	local nearbyObject = Find("CargoStationControl",5)
	if next(nearbyObject) then
		for thatBooth, distance in pairs(nearbyObject) do
			if Get(thatBooth,"MarkerUID") == Get(this,"MarkerUID") then
				MyCargoStationControl=thatBooth
				controlFound = true
				print("MyCargoStationControl found at dist "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyCargoStationControl) then
		print(" -- ERROR --- MyCargoStationControl not found")
		DeleteTruckClicked()
	end
end

function SetRequestForGate(theGateNr)
	if GateList[theGateNr].LargeGate == "no" then
	
		if Get(MyMarker,"RequestFrom"..theGateNr) == "none" and Get(MyMarker,"Authorized"..theGateNr) ~= this.HomeUID then
			if not Get(MyMarker,"WriteLock"..theGateNr) then
				Set(MyMarker,"RequestFrom"..theGateNr,this.HomeUID)
				print("[B1] -- "..this.HomeUID.." stopped. Request for SmallGate "..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate)
			else
				print("[B2] -- "..this.HomeUID.." stopped. Request for SmallGate"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
			end
		end
		
	elseif GateList[theGateNr].LargeGate == "yes" then
	
		if GateList[theGateNr].GatePosX == this.Pos.x+1.5 then
		
			if Get(MyMarker,"RequestFromL"..theGateNr) == "none" and Get(MyMarker,"AuthorizedL"..theGateNr) ~= this.HomeUID then
				if not Get(MyMarker,"WriteLock"..theGateNr) then
					Set(MyMarker,"RequestFromL"..theGateNr,this.HomeUID)
					print("[B3] -- "..this.HomeUID.." stopped. Request for LargeGate L"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate)
				else
					print("[B4] -- "..this.HomeUID.." stopped. Request for LargeGate L"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
				end
			end
			
		elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 then
		
			if Get(MyMarker,"RequestFromR"..theGateNr) == "none" and Get(MyMarker,"AuthorizedR"..theGateNr) ~= this.HomeUID then
				if not Get(MyMarker,"WriteLock"..theGateNr) then
					Set(MyMarker,"RequestFromR"..theGateNr,this.HomeUID)
					print("[B5] -- "..this.HomeUID.." stopped. Request for LargeGate R"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate)
				else
					print("[B6] -- "..this.HomeUID.." stopped. Request for LargeGate R"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
				end
			end
		end
	end
end

function SetRequestForLinkedGates(theGateNr)
	local LinkID = GateList[theGateNr].LinkGate
	for j=theGateNr,TotalGates do
		if GateList[j].LinkGate == LinkID then
			SetRequestForGate(j)
		end
	end
end

function AuthorizedForGate(theGateNr)
	local isAuthorized = false
	if GateList[theGateNr].LargeGate == "no" then
		if Get(MyMarker,"Authorized"..theGateNr) == this.HomeUID then
			print("[C1] -- "..this.HomeUID.." Authorized for SmallGate "..theGateNr..", update gate counter to "..(theGateNr+1).."  Linked: "..GateList[theGateNr].LinkGate)
			isAuthorized = true
		end
	elseif GateList[theGateNr].LargeGate == "yes" then
		if GateList[theGateNr].GatePosX == this.Pos.x+1.5 and Get(MyMarker,"AuthorizedL"..theGateNr) == this.HomeUID then
			print("[C2] -- "..this.HomeUID.." Authorized for LargeGate L"..theGateNr..", update gate counter to "..(theGateNr+1).."  Linked: "..GateList[theGateNr].LinkGate)
			isAuthorized = true
		elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 and Get(MyMarker,"AuthorizedR"..theGateNr) == this.HomeUID then
			print("[C3] -- "..this.HomeUID.." Authorized for LargeGate R"..theGateNr..", update gate counter to "..(theGateNr+1).."  Linked: "..GateList[theGateNr].LinkGate)
			isAuthorized = true
		end
	end
	if isAuthorized == true then
		Set(this,"GateCount",this.GateCount+1)
		if this.GateCount <= TotalGates then
			NextGateY = GateList[this.GateCount].GatePosY
		else
			NextGateY = MapEdge
		end
	end
	return isAuthorized
end

function AuthorizedForLinkedGates(theGateNr)
	local LinkID = GateList[theGateNr].LinkGate
	local linkedgatescounter = 0
	local gatesopencounter = 0
	for j=theGateNr,TotalGates do
		if GateList[j].LinkGate == LinkID then
			linkedgatescounter = linkedgatescounter + 1
		
			if GateList[j].LargeGate == "no" then -- linked SmallGate, check if authorized --
			
				if Get(MyMarker,"Authorized"..j) == this.HomeUID then -- and Get(MyMarker,"GateOpen"..j) == 1 then
					gatesopencounter = gatesopencounter+1
					print("[D1] -- "..this.HomeUID.." Authorized for linked SmallGate "..j.."  Linked: "..GateList[j].LinkGate)
				end
				
			elseif GateList[j].LargeGate == "yes" then -- linked LargeGate, check if authorized --
			
				if GateList[j].GatePosX == this.Pos.x+1.5 and Get(MyMarker,"AuthorizedL"..j) == this.HomeUID then
					gatesopencounter = gatesopencounter+1
					print("[D2] -- "..this.HomeUID.." Authorized for linked LargeGate L"..j.."  Linked: "..GateList[j].LinkGate)
					
				elseif GateList[j].GatePosX == this.Pos.x-1.5 and Get(MyMarker,"AuthorizedR"..j) == this.HomeUID then
					gatesopencounter = gatesopencounter+1
					print("[D3] -- "..this.HomeUID.." Authorized for linked LargeGate R"..j.."  Linked: "..GateList[j].LinkGate)
				end
			end
		end
	end
	print("[D4] -- "..this.HomeUID.." linkedgatescounter: "..linkedgatescounter.."  gatesopencounter: "..gatesopencounter)
	if linkedgatescounter == gatesopencounter then
		Set(this,"GateCount",this.GateCount+linkedgatescounter)
		if this.GateCount <= TotalGates then
			NextGateY = GateList[this.GateCount].GatePosY
			print("NextGateY: "..NextGateY)
		else
			NextGateY = MapEdge
		end
		print("[D5] -- "..this.HomeUID.." Authorized for all linked gates, update gate counter to "..this.GateCount)
		return true
	else
		return false
	end
end

function WaitForGateToOpen()
	if this.GateCount <= TotalGates then
		if not Get(MyMarker,"PeopleCrossingStreet"..this.GateCount) then
		
			print("WaitForGateToOpen")
			if GateList[this.GateCount].LinkGate == "no" then
		
				if not AuthorizedForGate(this.GateCount) then
					SetRequestForGate(this.GateCount)
				else
					StopTheVehicle = nil
				end
				
			else
				
				if not AuthorizedForLinkedGates(this.GateCount) then
					SetRequestForLinkedGates(this.GateCount)
				else
					StopTheVehicle = nil
				end
			end
			
		else
			-- MyTruckSkin.Tooltip = { "tooltip_CargoStationTruck_StoppedForPeople",this.HomeUID,"H",this.CargoStationID,"I" }
			print("[B0] -- "..this.HomeUID.." stopped. Waiting for people crossing the road...")
			
		end
	else
		StopOpeningGates = true
	end
end

function CloseGateBehindMe(Forced)
	if not ForcedCloseGateDone then
	
		local GateCounter = this.GateCount-1
		if Forced == true then
			GateCounter = TotalGates
			print("[F0] -- "..this.HomeUID.." Forced close, TotalGates = "..TotalGates)
		end
		if GateCounter ~= nil and GateCounter > 0 then
			for theGateNr=1,GateCounter do
			
				if GateList[theGateNr].GatePosY <= MyTailLights+1 or Forced == true then
				
					if not Get(this,"ClosedGate"..theGateNr) then -- don't force this one...
					
						print("CloseGateBehindMe "..theGateNr)
						if GateList[theGateNr].LargeGate == "no" then
						
							Set(MyMarker,"CloseGate"..theGateNr,"yes")
							Set(this,"ClosedGate"..theGateNr,true)
							print("[E1] -- "..this.HomeUID.." ClosedGate "..theGateNr)
							
						elseif GateList[theGateNr].GatePosX == this.Pos.x+1.5 then
						
							Set(MyMarker,"CloseGateL"..theGateNr,"yes")
							Set(this,"ClosedGate"..theGateNr,true)
							print("[E2] -- "..this.HomeUID.." ClosedGate L"..theGateNr)
							
						elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 then
						
							Set(MyMarker,"CloseGateR"..theGateNr,"yes")
							Set(this,"ClosedGate"..theGateNr,true)
							print("[E3] -- "..this.HomeUID.." ClosedGate R"..theGateNr)
						end
					end
				end
			end
		end
		if Forced == true and not ForcedCloseGateDone then ForcedCloseGateDone = true end
	end
end

function ClearAuthGateBehindMe(Forced)
	if not ForcedClearAuthDone then
	
		local GateCounter = this.GateCount-1
		local AllAuthCleared = true
		
		if Forced == true then
			GateCounter = TotalGates
			print("[F0] -- "..this.HomeUID.." Forced ClearAuth, TotalGates = "..TotalGates)
		end
		
		if GateCounter ~= nil and GateCounter > 0 then
	
			for theGateNr=1,GateCounter do
			
				if GateList[theGateNr].GatePosY <= MyTailLights-5 or Forced == true then
				
					if not Get(this,"ClearedAuth"..theGateNr) or Forced == true then
					
						print("ClearAuthGateBehindMe "..theGateNr)
						if GateList[theGateNr].LargeGate == "no" then
							if Get(MyMarker,"Authorized"..theGateNr) == this.HomeUID then
								if not Get(MyMarker,"WriteLock"..theGateNr) then
									Set(MyMarker,"Authorized"..theGateNr,"no")
									Set(this,"ClearedAuth"..theGateNr,true)
									print("[F1] -- "..this.HomeUID.." ClearedAuth "..theGateNr)
								else
									AllAuthCleared = false
									print("[F2] -- "..this.HomeUID.." stopped. ClearedAuth for SmallGate"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
								end
							else
								Set(this,"ClearedAuth"..theGateNr,true)
							end
							
						elseif GateList[theGateNr].GatePosX == this.Pos.x+1.5 then
						
							if Get(MyMarker,"AuthorizedL"..theGateNr) == this.HomeUID then
								if not Get(MyMarker,"WriteLock"..theGateNr) then
									Set(MyMarker,"AuthorizedL"..theGateNr,"no")
									Set(this,"ClearedAuth"..theGateNr,true)
									print("[F3] -- "..this.HomeUID.." ClearedAuth L"..theGateNr)
								else
									AllAuthCleared = false
									print("[F4] -- "..this.HomeUID.." stopped. ClearedAuth for LargeGate L"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
								end
							else
								Set(this,"ClearedAuth"..theGateNr,true)
							end

						elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 then
						
							if Get(MyMarker,"AuthorizedR"..theGateNr) == this.HomeUID then
								if not Get(MyMarker,"WriteLock"..theGateNr) then
									Set(MyMarker,"AuthorizedR"..theGateNr,"no")
									Set(this,"ClearedAuth"..theGateNr,true)
									print("[F5] -- "..this.HomeUID.." ClearedAuth R"..theGateNr)
								else
									AllAuthCleared = false
									print("[F6] -- "..this.HomeUID.." stopped. ClearedAuth for LargeGate R"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
								end
							else
								Set(this,"ClearedAuth"..theGateNr,true)
							end
						end
					end
				end
			end
		end
		
		if Forced == true and not ForcedClearAuthDone then
			if AllAuthCleared == true then
				ForcedClearAuthDone = true
				NextGateY = MapEdge+10
				PriorGateY = MapEdge+10
				StopTheVehicle = nil
				Set(this,"LeavingMap",true)
				local loadedHeadlights=Find(this,"WallLight",8)
				for thatLight, distance in pairs(loadedHeadlights) do
					if Get(thatLight,"HomeUID") == this.HomeUID or thatLight.Id.i == MyTruckSkin.Slot1.i or thatLight.Id.i == MyTruckSkin.Slot2.i then
						thatLight.Delete()
					end
				end
				print("Forced ClearAuth Done")
				-- MyTruckSkin.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nLeaving Map"
			else
				print("Forced ClearAuth Failed")
				-- MyTruckSkin.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nAllAuthCleared = false"
			end
		elseif not Forced and not ForcedClearAuthDone then
			for i = 1,TotalGates do
				if not Get(this,"ClearedAuth"..i) then
					PriorGateY = GateList[i].GatePosY
					print("[F7] -- "..this.HomeUID.." PriorGateY: "..PriorGateY)
					break
				end
			end
		end
	end
end

function SpawnSupplyTruck(theBay)
	local NewSupplyTruck = Object.Spawn("SupplyTruck",World.NumCellsX-1,World.NumCellsY-4+math.random()+math.random())
	Set(NewSupplyTruck,"StackTransferred",true)
	Set(NewSupplyTruck,"State","Leaving")
	Set(NewSupplyTruck,"Hidden",true)
	for H = 0,7 do
		Set(NewSupplyTruck,"Slot"..H..".i",Get(theBay,"Slot"..H..".i"))
		Set(NewSupplyTruck,"Slot"..H..".u",Get(theBay,"Slot"..H..".u"))
		Set(theBay,"Slot"..H..".i",-1)
		Set(theBay,"Slot"..H..".u",-1)
	end
	theBay.Delete()
	NewSupplyTruck.Speed = 5
end

function UpdateFollowUps()
	--print("UpdateFollowUps")
	Set(this,"FollowUpID",-1)
	Set(this,"FollowingID",-1)
	if Exists(MyVehicleInFront) then
		if Exists(MyVehicleBehind) then
			Set(MyVehicleBehind,"VehicleTypeInFront",MyVehicleInFront.Type)
			Set(MyVehicleBehind,"DistanceInFront",(this.Pos.y - MyVehicleBehind.Pos.y) + (MyVehicleInFront.Pos.y - this.Pos.y) + 5)
			Set(MyVehicleInFront,"VehicleTypeBehind",MyVehicleBehind.Type)
			Set(MyVehicleInFront,"DistanceBehind",(this.Pos.y - MyVehicleBehind.Pos.y) + (MyVehicleInFront.Pos.y - this.Pos.y) + 5)
			Set(MyVehicleInFront,"FollowUpID",MyVehicleBehind.Id.i)
			Set(MyVehicleBehind,"FollowingID",MyVehicleInFront.Id.i)
			Set(MyVehicleInFront,"UpdateVehicleBehind",true)
			Set(MyVehicleBehind,"UpdateVehicleInFront",true)
		else
			Set(MyVehicleInFront,"VehicleTypeBehind","None")
			Set(MyVehicleInFront,"FollowUpID",-1)
			Set(MyVehicleInFront,"UpdateVehicleBehind",true)
		end
	else
		if Exists(MyVehicleBehind) then
			Set(MyVehicleBehind,"VehicleTypeInFront","None")
			Set(MyVehicleBehind,"FollowingID",-1)
			Set(MyVehicleBehind,"UpdateVehicleInFront",true)
		end
	end
	MyVehicleInFront = nil
	MyVehicleBehind = nil
	VehicleTailLights = nil
	Set(this,"VehiclesUpdated",true)
end

function FindVehicleBehindMe()
	print("FindVehicleBehindMe")
	local CurrDist = 9999
	local tmpMyVehicleBehind = nil
	local group = { "CargoStationTruck" }--,"Limo2" }
	for _, typ in pairs(group) do
		local nearbyObject = Find(typ,500)
		for V, distance in pairs(nearbyObject) do
			if V.Id.i ~= this.Id.i and V.Pos.x == this.RoadX and V.Id.u > this.Id.u and distance < CurrDist then -- and V.VehicleState ~= "ProcessingGarage" and V.VehicleState ~= "EnteringGarage"
				CurrDist = distance
				tmpMyVehicleBehind=V
				print("My x: "..this.Pos.x.."  My y: "..this.Pos.y.."   "..V.HomeUID.." found behind me at x: "..V.Pos.x.." y: "..V.Pos.y.." Dist: "..CurrDist)
			end
		end
	end
	nearbyObject=nil
	if Exists(tmpMyVehicleBehind) then
		MyVehicleBehind = tmpMyVehicleBehind
		Set(MyVehicleBehind,"VehicleTypeInFront",this.Type)
		Set(MyVehicleBehind,"DistanceInFront",CurrDist+5)
		Set(MyVehicleBehind,"FollowingID",this.Id.i)
		Set(this,"FollowUpID",MyVehicleBehind.Id.i)
		Set(MyVehicleBehind,"UpdateVehicleInFront",true)
		VehicleHeadLights = MyVehicleBehind.Pos.y + MyVehicleBehind.Head
		print("MyVehicleBehind is "..MyVehicleBehind.HomeUID)
	else
		MyVehicleBehind = nil
	end
end

function FindVehicleInFront()
	print("FindVehicleInFront")
	local CurrDist = 9999
	local tmpMyVehicleInFront = nil
	local group = { "CargoStationTruck" }--,"Limo2" }
	for _, typ in pairs(group) do
		local nearbyObject = Find(typ,500)
		for V, distance in pairs(nearbyObject) do
			if V.Id.i ~= this.Id.i and V.Pos.x == this.RoadX and V.Id.u < this.Id.u and distance < CurrDist then -- and V.VehicleState ~= "ProcessingGarage" and V.VehicleState ~= "EnteringGarage"
				if V.FollowUpID == -1 then
					CurrDist = distance
					tmpMyVehicleInFront=V
					print("My x: "..this.Pos.x.."  My y: "..this.Pos.y.."   "..V.HomeUID.." found in front at x: "..V.Pos.x.." y: "..V.Pos.y.." Dist: "..CurrDist)
				end
			end
		end
	end
	nearbyObject=nil
	if Exists(tmpMyVehicleInFront) then
		MyVehicleInFront = tmpMyVehicleInFront
		Set(MyVehicleInFront,"VehicleTypeBehind",this.Type)
		Set(MyVehicleInFront,"DistanceBehind",CurrDist+5)
		Set(MyVehicleInFront,"FollowUpID",this.Id.i)
		Set(this,"FollowingID",MyVehicleInFront.Id.i)
		Set(MyVehicleInFront,"UpdateVehicleBehind",true)
		VehicleTailLights = MyVehicleInFront.Pos.y - MyVehicleInFront.Tail
		print("MyVehicleInFront is "..MyVehicleInFront.HomeUID)
	else
		MyVehicleInFront = nil
	end
end

function LoadVehicleBehindMe()
	print("LoadVehicleBehind")
	local vFound = false
	if this.VehicleTypeBehind ~= "None" then
		print("trying to find "..this.VehicleTypeBehind.." at distance "..this.DistanceBehind)
		local vehicles = Find(this.VehicleTypeBehind,this.DistanceBehind)
		for V, _ in pairs(vehicles) do
			if Get(V,"FollowingID") == this.Id.i and this.FollowUpID == V.Id.i then
				tmpMyVehicleBehind=V
				vFound = true
				break
			end
		end
		vehicles=nil
	end
	if vFound == true then
		MyVehicleBehind = tmpMyVehicleBehind
		VehicleHeadLights = MyVehicleBehind.Pos.y + MyVehicleBehind.Head
		print("MyVehicleBehind is "..MyVehicleBehind.HomeUID)
	else
		MyVehicleBehind = nil
		print("MyVehicleBehind not found")
		FindVehicleBehindMe()
	end
	Set(this,"UpdateVehicleBehind",false)
end

function LoadVehicleInFront()
	print("LoadVehicleInFront")
	local vFound = false
	if this.VehicleTypeInFront ~= "None" then
		print("trying to find "..this.VehicleTypeInFront.." at distance "..this.DistanceInFront)
		local vehicles = Find(this.VehicleTypeInFront,this.DistanceInFront)
		for V, _ in pairs(vehicles) do
			if Get(V,"FollowUpID") == this.Id.i and this.FollowingID == V.Id.i then
				tmpMyVehicleInFront=V
				vFound = true
				break
			end
		end
		vehicles=nil
	end
	if vFound == true then
		MyVehicleInFront = tmpMyVehicleInFront
		VehicleTailLights = MyVehicleInFront.Pos.y - MyVehicleInFront.Tail
		print("MyVehicleInFront is "..MyVehicleInFront.HomeUID)
	else
		MyVehicleInFront = nil
		print("MyVehicleInFront not found")
		FindVehicleInFront()
	end
	Set(this,"UpdateVehicleInFront",false)
end

function WaitForCargoStation()
	print("WaitForCargoStation")
	if not Get(this,"GateBehindMeClosed") then
		Set(this,"GateBehindMeClosed",true)
		timeTot = timePerGateUpdate
	elseif not Get(this,"CargoStationChecked"..this.CargoStopCount) then
		FindMyCargoStopSign()
		-- FindMyCargoStationControl()
		if Get(MyCargoStopSign,"CargoStationID") == Get(this,"CargoStationID") then	-- truck arrives at designated cargo station
			this.VehicleState = "Processing"
			SpawnMyTruckDriver(true)
			
			-- local X = 1
			-- if MyCargoStopSign.Pos.x > this.Pos.x then X = -1 end
			-- if Get(this,"MyType") == "Callout" then
				-- MyTruckDriver = Object.Spawn("CalloutTruckDriver",this.Pos.x+X,this.Pos.y)
				-- Set(MyTruckDriver,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"TruckID",this.Id.u)
				-- -- MyTruckDriver.NavigateTo(MyCargoStationControl.Pos.x,MyCargoStationControl.Pos.y)
				-- -- Object.CreateJob(MyCargoStationControl,"ActivateCalloutStation")
				-- -- MyCargoStationControl.PrepareCallout = true
				-- print("Stopped at my Callout station")			
			-- elseif Get(MyCargoStopSign,"CargoType") == "Deliveries" then
				-- MyTruckDriver = Object.Spawn("DeliveriesTruckDriver",this.Pos.x+X,this.Pos.y)
				-- Set(MyTruckDriver,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"ActivateJob","ActivateDeliveriesStation")
				-- -- MyTruckDriver.NavigateTo(MyCargoStationControl.Pos.x,MyCargoStationControl.Pos.y)
				-- -- Object.CreateJob(MyCargoStationControl,"ActivateDeliveriesStation")
				-- -- MyCargoStationControl.PrepareDeliveries = true
				-- print("Stopped at my Deliveries station")
			-- elseif Get(MyCargoStopSign,"CargoType") == "Garbage" then
				-- MyTruckDriver = Object.Spawn("GarbageTruckDriver",this.Pos.x+X,this.Pos.y)
				-- Set(MyTruckDriver,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"ActivateJob","ActivateGarbageStation")
				-- -- MyTruckDriver.NavigateTo(MyCargoStationControl.Pos.x,MyCargoStationControl.Pos.y)
				-- -- Object.CreateJob(MyCargoStationControl,"ActivateGarbageStation")
				-- -- MyCargoStationControl.PrepareGarbage = true
				-- print("Stopped at my Garbage station")
			-- elseif Get(MyCargoStopSign,"CargoType") == "Exports" then
				-- MyTruckDriver = Object.Spawn("ExportsTruckDriver",this.Pos.x+X,this.Pos.y)
				-- Set(MyTruckDriver,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"ActivateJob","ActivateExportsStation")
				-- -- MyTruckDriver.NavigateTo(MyCargoStationControl.Pos.x,MyCargoStationControl.Pos.y)
				-- -- Object.CreateJob(MyCargoStationControl,"ActivateExportsStation")
				-- -- MyCargoStationControl.PrepareExports = true
				-- print("Stopped at my Exports station")
			-- elseif Get(MyCargoStopSign,"CargoType") == "Emergency" then
				-- MyTruckDriver = Object.Spawn("EmergencyTruckDriver",this.Pos.x+X,this.Pos.y)
				-- Set(MyTruckDriver,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"ActivateJob","ActivateEmergencyStation")
				-- -- MyTruckDriver.NavigateTo(MyCargoStationControl.Pos.x,MyCargoStationControl.Pos.y)
				-- -- Object.CreateJob(MyCargoStationControl,"ActivateEmergencyStation")
				-- -- MyCargoStationControl.PrepareEmergency = true
				-- print("Stopped at my Emergency station")
			-- elseif Get(MyCargoStopSign,"CargoType") == "Intake" then
				-- MyTruckDriver = Object.Spawn("IntakeTruckDriver",this.Pos.x+X,this.Pos.y)
				-- Set(MyTruckDriver,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"TruckID",this.Id.u)
				-- Set(MyCargoStationControl,"ActivateJob","ActivateIntakeStation")
				-- -- MyTruckDriver.NavigateTo(MyCargoStationControl.Pos.x,MyCargoStationControl.Pos.y)
				-- Object.CreateJob(MyCargoStationControl,"ActivateIntakeStaActivateIntakeStationtion")
				-- -- MyCargoStationControl.PrepareIntake = true
			-- else
				-- NotMyStation = true
			-- end
		else
			print("This is not my Deliveries station, continue driving...")		-- truck arrives at other Deliveries station, no need to stop here
			NotMyStation = true
		end
		Set(this,"CargoStationChecked"..this.CargoStopCount,true)
		
		if NotMyStation then	-- skip the last two elseif below me to drive away faster, no need to wait for this.ready if it can be ready here as well
			Set(this,"CargoStationDone"..this.CargoStopCount,true)
			Set(this,"CargoStopCount",this.CargoStopCount+1)
			GetCargoStops()
			if NextCargoStopY == MapEdge then
				Set(this,"VehicleState","Leaving")
			else
				Set(this,"VehicleState","Arriving")
			end
			Set(this,"GateBehindMeClosed",nil)
			Set(this,"StationDone",nil)
			Set(this,"Ready",nil)
			MyCargoStopSign = nil
			CheckCurrentCargoStop = false
			StopTheVehicle = nil
			NotMyStation = nil
			timeTot = timePerGateUpdate
		end
	elseif not Get(this,"CargoStationDone"..this.CargoStopCount) then
		if this.StationDone == true then
			if not DriverBack then
				if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
				if not Exists(MyTruckDriver) then FindMyTruckDriver() end
				if Get(this,"MyType") == "Callout" then
					print("CreateJob: LeaveCalloutStation")
					Object.CreateJob(this,"LeaveCalloutStation")
				else
					print("CreateJob: Leave"..MyCargoStopSign.CargoType.."Station")
					Object.CreateJob(this,"Leave"..MyCargoStopSign.CargoType.."Station")
				end
			else
				MyTruckDriver = nil
				DriverBack = nil
				timeTot = timePerGateUpdate
				Set(this,"CargoStationDone"..this.CargoStopCount,true)
				Set(this,"Ready",true)
				timePerGateUpdate = 1
			end
		else
			if not Exists(MyTruckDriver) then FindMyTruckDriver() end
		end
	elseif this.Ready == true then
		FindMyTruckBays(true)
		Set(this,"CargoStopCount",this.CargoStopCount+1)
		GetCargoStops()
		if NextCargoStopY == MapEdge then
			Set(this,"VehicleState","Leaving")
		else
			Set(this,"VehicleState","Arriving")
		end
		Set(this,"GateBehindMeClosed",nil)
		Set(this,"StationDone",nil)
		Set(this,"Ready",nil)
		MyTruckDriver = nil
		MyCargoStopSign = nil
		CheckCurrentCargoStop = false
		StopTheVehicle = nil
		timeTot = timePerGateUpdate
	end
end

function JobComplete_LeaveDeliveriesStation()
	Object.CancelJob(this,"LeaveDeliveriesStation")
	Set(this,"CargoStationID",0)
	if not Exists(MyTruckDriver) then FindMyTruckDriver() end
	MyTruckDriver.Delete()
	DriverBack = true
end

function JobComplete_LeaveExportsStation()
	Object.CancelJob(this,"LeaveExportsStation")
	Set(this,"CargoStationID",0)
	if not Exists(MyTruckDriver) then FindMyTruckDriver() end
	MyTruckDriver.Delete()
	DriverBack = true
end

function JobComplete_LeaveGarbageStation()
	Object.CancelJob(this,"LeaveGarbageStation")
	Set(this,"CargoStationID",0)
	if not Exists(MyTruckDriver) then FindMyTruckDriver() end
	MyTruckDriver.Delete()
	DriverBack = true
end

function JobComplete_LeaveEmergencyStation()
	Object.CancelJob(this,"LeaveEmergencyStation")
	Set(this,"CargoStationID",0)
	if not Exists(MyTruckDriver) then FindMyTruckDriver() end
	MyTruckDriver.Delete()
	DriverBack = true
end

function JobComplete_LeaveIntakeStation()
	Object.CancelJob(this,"LeaveIntakeStation")
	Set(this,"CargoStationID",0)
	Set(this,"TotalCargoAmount",16) -- make sure it doesn't stop at another station after unloading the prisoners
	if not Exists(MyTruckDriver) then FindMyTruckDriver() end
	MyTruckDriver.Delete()
	DriverBack = true
end

function JobComplete_LeaveCalloutStation()
	Object.CancelJob(this,"LeaveCalloutStation")
	Set(this,"CargoStationID",0)
	if not Exists(MyTruckDriver) then FindMyTruckDriver() end
	MyTruckDriver.Delete()
	DriverBack = true
end

function SpawnMyTruckDriver(Activate)
	print("SpawnMyTruckDriver")
	print(Activate)
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	if not Exists(MyCargoStationControl) then FindMyCargoStationControl() end
	local X = 1
	if MyCargoStopSign.Pos.x > this.Pos.x then X = -1 end
	local T = Get(MyCargoStopSign,"CargoType")
	if Get(this,"MyType") == "Callout" then
		T = "Callout"
	end
	MyTruckDriver = Object.Spawn(T.."TruckDriver",this.Pos.x+X,this.Pos.y)
	Set(MyTruckDriver,"TruckID",this.Id.u)
	MyTruckDriver.NavigateTo(MyCargoStationControl.Pos.x,MyCargoStationControl.Pos.y+0.5)
	if Activate then
		print("Activate CargoStationControl")
		FindMyCargoStationControl()
		Set(MyCargoStationControl,"TruckID",this.Id.u)
		Set(MyCargoStationControl,"ActivateJob","Activate"..T.."Station")
	end
end

function FindMyTruckDriver()
	print("FindMyTruckDriver")
	local DriverTypes = { "DeliveriesTruckDriver", "ExportsTruckDriver", "GarbageTruckDriver", "EmergencyTruckDriver", "IntakeTruckDriver", "CalloutTruckDriver" }
	local found = false
	MyTruckDriver = nil
	for _, typ in pairs(DriverTypes) do
		local nearbyObjects = Find(this,typ,5)
		for thatDriver, _ in pairs(nearbyObjects) do 
			if Get(thatDriver,"TruckID") == this.Id.u then
				MyTruckDriver = thatDriver
				print("Found MyTruckDriver nearby")
				found = true
				break
			end
		end
		if found == true then break end
	end
	if found == false then
		for _, typ in pairs(DriverTypes) do
			local nearbyObjects = Find(this,typ,9999)
			for thatDriver, _ in pairs(nearbyObjects) do 
				if Get(thatDriver,"TruckID") == this.Id.u then
					MyTruckDriver = thatDriver
					print("Found MyTruckDriver further away")
					found = true
					break
				end
			end
			if found == true then break end
		end
		if found == false then 
			print("MyTruckDriver not found, spawning new")
			SpawnMyTruckDriver()
		end
	end
end

function DeleteTruckClicked()
	if Exists(MyMarker) and TotalGates ~= nil and TotalGates > 0 then
		Set(this,"GateCount",TotalGates)
		CloseGateBehindMe(true)
		ClearAuthGateBehindMe(true)
	end
	if Get(this,"CargoStationID") == 0 then						-- the truck visited its target cargo station already
		local loadedHeadlights=Find(this,"WallLight",4)
		for thatLight, distance in pairs(loadedHeadlights) do
			if Get(thatLight,"HomeUID") == this.HomeUID or thatLight.Id.i == MyTruckSkin.Slot1.i or thatLight.Id.i == MyTruckSkin.Slot2.i then
				thatLight.Delete()
			end
		end
		
		if Get(this,"PartsSpawned") == true then
			nearbyObject = Find(MyTruckSkin,"Limo2Engine",5)
			if next(nearbyObject) then
				for thatEngine, distance in pairs(nearbyObject) do
					if thatEngine.Id.i == MyTruckSkin.Slot3.i or thatEngine.Id.i == MyTruckSkin.Slot4.i then
						thatEngine.Delete()
					end
				end
			end
			nearbyObject = Find(MyTruckSkin,"Limo2EngineOnTruck",5)
			if next(nearbyObject) then
				for thatEngine, distance in pairs(nearbyObject) do
					if thatEngine.Id.i == MyTruckSkin.Slot3.i or thatEngine.Id.i == MyTruckSkin.Slot4.i then
						thatEngine.Delete()
					end
				end
			end
			Set(MyCraneBooth,"PartsTruckArriving","no")
		elseif Get(this,"LimoSpawned") == true then
			nearbyObject = Find(MyTruckSkin,"Limo2Broken",5)
			if next(nearbyObject) then
				for thatEngine, distance in pairs(nearbyObject) do
					if thatEngine.Id.i == MyTruckSkin.Slot3.i or thatEngine.Id.i == MyTruckSkin.Slot4.i then
						thatEngine.Delete()
					end
				end
			end
			Set(MyCraneBooth,"LimoTruckArriving","no")
		end
	
		if Exists(MyTruckBay1) then SpawnSupplyTruck(MyTruckBay1) end
		if Exists(MyTruckBay2) then SpawnSupplyTruck(MyTruckBay2) end
		if Exists(MyTruckSkin) then MyTruckSkin.Delete() end
		this.Delete()
	else
		if this.MyType == "Cargo" then							-- move incoming deliveries back to terminal
			local nearbyTowers = {}
			nearbyTowers = Find("TrafficTerminal",10000)
			if next(nearbyTowers) then
				for thatTower, distance in pairs(nearbyTowers) do
					MyTrafficTerminal = thatTower
					print("Found MyTrafficTerminal at distance "..distance)
					break
				end
				
				local NewDeliveriesFound = false
				local DummyBoxes = Find(this,"CargoDeliveries",6)
				for thatDummy, dist in pairs(DummyBoxes) do
					if thatDummy.HomeUID == this.HomeUID then
						thatDummy.Delete()
						NewDeliveriesFound = true
					end
				end
				if NewDeliveriesFound == true then	-- new deliveries method with CargoDeliveries boxes
					local RealDeliveries = Find(MyTrafficTerminal,"TmpCargoTruckBay",5)
					for thatBay, dist in pairs(RealDeliveries) do
						if thatBay.HomeUID == this.HomeUID then
							local S = math.random(0,7)
							thatBay.Pos.x,thatBay.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y-3
							thatBay.Delete()
						end
					end
				else								-- for compatibility with old deliveries method with real stack on trucks
					local loadedStack=Find(this,"Stack",6)
					local loadedBox=Find(this,"Box",6)
					local loadedMail=Find(this,"MailSatchel",6)
					if next(loadedStack) then
						for thatStack, distance in pairs(loadedStack) do
							local unloaded = false
							local S = 0
							for A = 0,7 do
								if thatStack.Id.i == Get(MyTruckBay1,"Slot"..A..".i") then
									print("Unloading stack "..A.." from MyTruckBay1")
									Set(MyTruckBay1,"Slot"..A..".i",-1)
									Set(MyTruckBay1,"Slot"..A..".u",-1)
									unloaded = true
									S = A
									break
								elseif thatStack.Id.i == Get(MyTruckBay2,"Slot"..A..".i") then
									print("Unloading stack "..A.." from MyTruckBay2")
									Set(MyTruckBay2,"Slot"..A..".i",-1)
									Set(MyTruckBay2,"Slot"..A..".u",-1)
									unloaded = true
									S = A
									break
								end
							end
							if unloaded == true then
								print("Transferring stack to MyTrafficTerminal")
								Set(thatStack,"CarrierId.i",-1)
								Set(thatStack,"CarrierId.u",-1)
								Set(thatStack,"Loaded",false)
								if math.random() > 0.75 then
									thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y-3
								elseif math.random() > 0.5 then
									thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y-1
								elseif math.random() > 0.25 then
									thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y
								else
									thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y+1
								end
								thatStack = nil
							end
						end
					end
					if next(loadedBox) then
						for thatBox, distance in pairs(loadedBox) do
							local unloaded = false
							local S = 0
							for A = 0,7 do
								if thatBox.Id.i == Get(MyTruckBay1,"Slot"..A..".i") then
									print("Unloading box "..A.." from MyTruckBay1")
									Set(MyTruckBay1,"Slot"..A..".i",-1)
									Set(MyTruckBay1,"Slot"..A..".u",-1)
									unloaded = true
									S = A
									break
								elseif thatBox.Id.i == Get(MyTruckBay2,"Slot"..A..".i") then
									print("Unloading box "..A.." from MyTruckBay2")
									Set(MyTruckBay2,"Slot"..A..".i",-1)
									Set(MyTruckBay2,"Slot"..A..".u",-1)
									unloaded = true
									S = A
									break
								end
							end
							if unloaded == true then
								print("Transferring stack to MyTrafficTerminal")
								Set(thatBox,"CarrierId.i",-1)
								Set(thatBox,"CarrierId.u",-1)
								Set(thatBox,"Loaded",false)
								if math.random() > 0.75 then
									thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y+1
								elseif math.random() > 0.5 then
									thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y
								elseif math.random() > 0.25 then
									thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y-1
								else
									thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y-3
								end
								thatBox = nil
							end
						end
					end
					if next(loadedMail) then
						for thatMail, distance in pairs(loadedMail) do
							local unloaded = false
							for A = 0,7 do
								if thatMail.Id.i == Get(MyTruckBay1,"Slot"..A..".i") then
									Set(MyTruckBay1,"Slot"..A..".i",-1)
									Set(MyTruckBay1,"Slot"..A..".u",-1)
									unloaded = true
									break
								elseif thatMail.Id.i == Get(MyTruckBay2,"Slot"..A..".i") then
									Set(MyTruckBay2,"Slot"..A..".i",-1)
									Set(MyTruckBay2,"Slot"..A..".u",-1)
									unloaded = true
									break
								end
							end
							if unloaded == true then
								Set(thatMail,"CarrierId.i",-1)
								Set(thatMail,"CarrierId.u",-1)
								Set(thatMail,"Loaded",false)
								thatMail.Pos.x,thatMail.Pos.y = MyTrafficTerminal.Pos.x-4.5+math.random(1,8),MyTrafficTerminal.Pos.y+3
								thatMail = nil
								break
							end
						end
					end
				end
				Interface.RemoveComponent(this,"SeparatorTruck")
				Interface.RemoveComponent(this,"DeleteVehicle")
				Interface.RemoveComponent(this,"TransferDelivery")
				local loadedCargoGarbage=Find(this,"CargoGarbage",6)
				for thatGarbage, distance in pairs(loadedCargoGarbage) do
					if thatGarbage.CarrierId.i == MyTruckBay1.Id.i or thatGarbage.CarrierId.i == MyTruckBay2.Id.i then
						thatGarbage.Delete()
					end
				end
			end
		elseif this.MyType == "Intake" then									-- move incoming prisoners back to terminal
			local nearbyTowers = {}
			nearbyTowers = Find("TrafficTerminal",10000)
			if next(nearbyTowers) then
				for thatTower, distance in pairs(nearbyTowers) do
					MyTrafficTerminal = thatTower
					break
				end
				local loadedPrisoners=Find(this,"PrisonerStackHolder",5)
				for thatPrisonerHolder, distance in pairs(loadedPrisoners) do
					if thatPrisonerHolder.CarrierId.i == MyTruckBay1.Id.i or thatPrisonerHolder.CarrierId.i == MyTruckBay2.Id.i then
						print("Loaded "..thatPrisonerHolder.HolderCategory.." prisoner ID "..thatPrisonerHolder.Slot0.i.." back to terminal")
						Set(thatPrisonerHolder,"CarrierId.i",-1)
						Set(thatPrisonerHolder,"CarrierId.u",-1)
						Set(thatPrisonerHolder,"Loaded",false)
						Set(thatPrisonerHolder,"Pos.y",MyTrafficTerminal.Pos.y+2)
						Set(thatPrisonerHolder,"Pos.x",MyTrafficTerminal.Pos.x-3)
					end
				end
				for H = 0,7 do
					Set(MyTruckBay1,"Slot"..H..".i",-1)
					Set(MyTruckBay1,"Slot"..H..".u",-1)
					Set(MyTruckBay2,"Slot"..H..".i",-1)
					Set(MyTruckBay2,"Slot"..H..".u",-1)
				end
				Interface.RemoveComponent(this,"SeparatorTruck")
				Interface.RemoveComponent(this,"DeleteVehicle")
				Interface.RemoveComponent(this,"TransferDelivery")
			end
		end
		
		
		print("FindMyCargoStopSign")
		local nearbySign = Find("CargoStopSign",10000)
		if next(nearbySign) then
			for thatSign, distance in pairs(nearbySign) do
				if Get(thatSign,"CargoStationID") == Get(this,"CargoStationID") then
					MyCargoStopSign = thatSign
					print("CargoStopSign found at dist "..distance)
					Set(MyCargoStopSign,"LoadAvailable",false)
					Set(MyCargoStopSign,"VehicleSpawned","no")
					Set(MyCargoStopSign,"InUse","no")
					Set(MyCargoStopSign,"Status","Waiting...")
					MyCargoStopSign.Tooltip = { "tooltip_CargoStopSign",MyCargoStopSign.HomeUID,"X",MyCargoStopSign.CargoStationID,"Y",MyCargoStopSign.Number,"Z" }
					
					print("FindMyCargoControl")
					local nearbyControl = Find(MyCargoStopSign,"CargoStationControl",3)
					if next(nearbyControl) then
						for thatControl, distance in pairs(nearbyControl) do
							if Get(thatControl,"CargoStationID") == Get(this,"CargoStationID") then
								MyCargoControl = thatControl
								Set(MyCargoControl,"ActivateJob",nil)
								print("CargoStationControl found at "..distance)
								if Get(this,"MyType") == "Cargo" or Get(this,"MyType") == "Exports" or Get(this,"MyType") == "Garbage" then
									Set(MyCargoControl,"SubType",0)
								elseif Get(this,"MyType") == "Emergency" or Get(this,"MyType") == "Callout" then
									Set(MyCargoControl,"SubType",19)
								elseif Get(this,"MyType") == "Intake" then
									local StopSignTypes = { ["MinSec"] = 9, ["Normal"] = 10, ["MaxSec"] = 11, ["SuperMax"] = 12, ["Protected"] = 13, ["DeathRow"] = 14, ["Insane"] = 15, ["ALL"] = 16 }
									Set(MyCargoControl,"SubType",StopSignTypes[MyCargoStopSign.SecLevel])
								end
								break
							end
						end
					end
					nearbyControl = nil
					
					break
				end
			end
		end
		nearbySign = nil
		
		local loadedHeadlights=Find(this,"WallLight",8)
		for thatLight, distance in pairs(loadedHeadlights) do
			if Get(thatLight,"HomeUID") == this.HomeUID or thatLight.Id.i == MyTruckSkin.Slot1.i or thatLight.Id.i == MyTruckSkin.Slot2.i then
				thatLight.Delete()
			end
		end
		
		if Exists(MyTruckBay1) then MyTruckBay1.Delete() end
		if Exists(MyTruckBay2) then MyTruckBay2.Delete() end
		if Exists(MyTruckSkin) then MyTruckSkin.Delete() end
		this.Delete()
	end
	return
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end


-- Limo Garage related stuff

-- function FindMyCrane()
	-- print("FindMyCrane")
	-- local craneFound = false
	-- local nearbyObject = Find("GantryCrane2Booth",1500)
	-- if next(nearbyObject) then
		-- for thatBooth, distance in pairs(nearbyObject) do
			-- if thatBooth.HomeUID==this.CraneUID then
				-- MyCraneBooth=thatBooth
				-- craneFound = true
				-- print("booth found")
				-- break
			-- end
		-- end
	-- end
	-- nearbyObject = nil
	-- if craneFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  GantryCrane2Booth not found.") end
-- end

-- function FindMyTrafficLight()
	-- local roadlightFound = false
	-- local sidelightFound = false
	-- local nearbyObject = Find("RoadGate2TrafficLightSmall",50)
	-- if next(nearbyObject) then
		-- for thatLight, distance in pairs(nearbyObject) do
			-- if thatLight.HomeUID==this.CraneUID then
				-- if not thatLight.SideLaneLight then
					-- --print("RoadPoleTrafficLight found")
					-- MyRoadTrafficLight=thatLight
					-- roadlightFound = true
				-- else
					-- --print("SideLaneTrafficLight found")
					-- MySideLaneTrafficLight=thatLight
					-- sidelightFound = true
				-- end
			-- end
		-- end
	-- end
	-- nearbyObject = nil
-- end

-- function FindStackNumber()
	-- --print("FindStackNumber")
	-- local newStack = Object.Spawn("Stack", this.Pos.x-1, this.Pos.y)
	-- for i = 1,2000 do
		-- Set(newStack,"Quantity",2)
		-- Set(newStack,"Contents",i)
		-- if newStack.Contents == "Limo2RepairOrderPapers" then
			-- Limo2RepairOrderPapersNr = i
		-- end
		-- if Limo2RepairOrderPapersNr > 1 then
			-- newStack.Delete()
			-- --print("Stack Limo2RepairOrderPapers: "..Limo2RepairOrderPapersNr)
			-- break
		-- end
	-- end
-- end

-- function FindGarageCargo(cargoType)
	-- print("FindMyCargo")
	-- if cargoType == "Engine" then
		-- local engineFound = false
		-- nearbyObject = Find(MyTruckSkin,"Limo2EngineOnTruck",5)
		-- if next(nearbyObject) then
			-- for thatEngine, distance in pairs(nearbyObject) do
				-- if Get(thatEngine,"Id.i") == Get(MyTruckSkin,"Slot3.i") then
					-- NewCargo1 = thatEngine
					-- engineFound = true
					-- print("engine1 found")
				-- elseif Get(thatEngine,"Id.i") == Get(MyTruckSkin,"Slot4.i") then
					-- NewCargo2 = thatEngine
					-- engineFound = true
					-- print("engine2 found")
				-- end
			-- end
		-- end
		-- nearbyObject = nil
		-- if engineFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Limo2EngineOnTruck not found.") end
	-- elseif cargoType == "Limo" then
		-- local carFound = false
		-- nearbyObject = Find(MyTruckSkin,"Limo2Broken",5)
		-- if next(nearbyObject) then
			-- for thatCar, distance in pairs(nearbyObject) do
				-- Set(thatCar,"GateCount",Get(this,"GateCount"))
				-- if Get(thatCar,"Id.i") == Get(MyTruckSkin,"Slot3.i") then
					-- NewCargo1 = thatCar
					-- carFound = true
					-- print("limo1 found")
				-- elseif Get(thatCar,"Id.i") == Get(MyTruckSkin,"Slot4.i") then
					-- NewCargo2 = thatCar
					-- carFound = true
					-- print("limo2 found")
				-- end
			-- end
		-- end
		-- nearbyObject = nil
		-- if carFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Limo2Broken not found.") end
	-- end
-- end

-- function DeleteGarageCargo()
	-- --print("DeleteGarageCargo")
	-- nearbyObject = Find("Limo2Engine",5)
	-- if next(nearbyObject) then
		-- for thatEngine, distance in pairs(nearbyObject) do
			-- if Get(thatEngine,"Id.i") == Get(MyTruckSkin,"Slot3.i") then
				-- thatEngine.Delete()
				-- --print("engine1 deleted")
			-- elseif Get(thatEngine,"Id.i") == Get(MyTruckSkin,"Slot4.i") then
				-- thatEngine.Delete()
				-- --print("engine2 deleted")
			-- end
		-- end
	-- end
	-- nearbyObject = Find("Limo2EngineOnTruck",5)
	-- if next(nearbyObject) then
		-- for thatEngine, distance in pairs(nearbyObject) do
			-- if Get(thatEngine,"Id.i") == Get(MyTruckSkin,"Slot3.i") then
				-- thatEngine.Delete()
				-- --print("engine1 deleted")
			-- elseif Get(thatEngine,"Id.i") == Get(MyTruckSkin,"Slot4.i") then
				-- thatEngine.Delete()
				-- --print("engine2 deleted")
			-- end
		-- end
	-- end
	-- nearbyObject = Find("Limo2Broken",5)
	-- if next(nearbyObject) then
		-- for thatCar, distance in pairs(nearbyObject) do
			-- if Get(thatCar,"Id.i") == Get(MyTruckSkin,"Slot3.i") then
				-- thatCar.Delete()
				-- --print("limo1 deleted")
			-- elseif Get(thatCar,"Id.i") == Get(MyTruckSkin,"Slot4.i") then
				-- thatCar.Delete()
				-- --print("limo2 deleted")
			-- end
		-- end
	-- end
	-- nearbyObject = nil
-- end

-- function WaitForGarage()
	-- print("WaitForGarage")
	-- if not Get(this,"DriverSpawned") then
		-- --print("Spawn driver and unload")
		-- FindMyTrafficLight()
		-- if Exists(MySideLaneTrafficLight) then MySideLaneTrafficLight.SubType = 3 end
		-- CloseGateBehindMe()
		-- local theGateNr = this.GateCount-1
		-- if GateList[theGateNr].LargeGate == "no" then
			-- if Get(MyMarker,"Authorized"..theGateNr) == this.HomeUID then
				-- if not Get(MyMarker,"WriteLock"..theGateNr) then
					-- Set(MyMarker,"Authorized"..theGateNr,"no")
					-- Set(this,"ClearedAuth"..theGateNr,true)
					-- print("[F1] -- "..this.HomeUID.." ClearedAuth "..theGateNr)
				-- else
					-- AllAuthCleared = false
					-- print("[F2] -- "..this.HomeUID.." stopped. ClearedAuth for SmallGate"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
				-- end
			-- else
				-- Set(this,"ClearedAuth"..theGateNr,true)
			-- end
			
		-- elseif GateList[theGateNr].GatePosX == MyMarker.Pos.x+1.5 then
		
			-- if Get(MyMarker,"AuthorizedL"..theGateNr) == this.HomeUID then
				-- if not Get(MyMarker,"WriteLock"..theGateNr) then
					-- Set(MyMarker,"AuthorizedL"..theGateNr,"no")
					-- Set(this,"ClearedAuth"..theGateNr,true)
					-- print("[F3] -- "..this.HomeUID.." ClearedAuth L"..theGateNr)
				-- else
					-- AllAuthCleared = false
					-- print("[F4] -- "..this.HomeUID.." stopped. ClearedAuth for LargeGate L"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
				-- end
			-- else
				-- Set(this,"ClearedAuth"..theGateNr,true)
			-- end

		-- elseif GateList[theGateNr].GatePosX == MyMarker.Pos.x-1.5 then
		
			-- if Get(MyMarker,"AuthorizedR"..theGateNr) == this.HomeUID then
				-- if not Get(MyMarker,"WriteLock"..theGateNr) then
					-- Set(MyMarker,"AuthorizedR"..theGateNr,"no")
					-- Set(this,"ClearedAuth"..theGateNr,true)
					-- print("[F5] -- "..this.HomeUID.." ClearedAuth R"..theGateNr)
				-- else
					-- AllAuthCleared = false
					-- print("[F6] -- "..this.HomeUID.." stopped. ClearedAuth for LargeGate R"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
				-- end
			-- else
				-- Set(this,"ClearedAuth"..theGateNr,true)
			-- end
		-- end
		
		-- if Get(this,"PartsSpawned") == true and Get(MyCraneBooth,"PartsRackIsFull") == "no" then		-- car engines on truck
			-- FindGarageCargo("Engine")
			-- if MyTruckSkin.Slot3.i ~= -1 then
				-- --print("UnloadEngineSlot0 = true")
				-- Set(this,"UnloadEngineSlot0",true)
				-- Set(MyCraneBooth,"UnloadEngineSlot0",true)
				-- Set(this,"Slot0IsAtX",string.sub(NewCargo1.Pos.x,0,6))
				-- Set(this,"Slot0IsAtY",string.sub(NewCargo1.Pos.y,0,6))
			-- end
			
			-- if MyTruckSkin.Slot4.i ~= -1 then
				-- --print("UnloadEngineSlot1 = true")
				-- Set(this,"UnloadEngineSlot1",true)
				-- Set(MyCraneBooth,"UnloadEngineSlot1",true)
				-- Set(this,"Slot1IsAtX",string.sub(NewCargo2.Pos.x,0,6))
				-- Set(this,"Slot1IsAtY",string.sub(NewCargo2.Pos.y,0,6))
			-- end
		
		-- elseif Get(this,"LimoSpawned") == true and Get(MyCraneBooth,"GarageIsFull") == "no" then
			-- FindGarageCargo("Limo")
			
			-- if Get(MyCraneBooth,"GarageIsFull") == "no" then
				-- if MyTruckSkin.Slot3.i ~= -1 then
					-- --print("UnloadTruckSlot0 = true")
					-- Set(this,"UnloadTruckSlot0",true)
					-- Set(MyCraneBooth,"UnloadTruckSlot0",true)
					-- Set(this,"Slot0IsAtX",string.sub(NewCargo1.Pos.x,0,6))
					-- Set(this,"Slot0IsAtY",string.sub(NewCargo1.Pos.y,0,6))
				-- end
				-- if MyTruckSkin.Slot4.i ~= -1 then
					-- --print("UnloadTruckSlot1 = true")
					-- Set(this,"UnloadTruckSlot1",true)
					-- Set(MyCraneBooth,"UnloadTruckSlot1",true)
					-- Set(this,"Slot1IsAtX",string.sub(NewCargo2.Pos.x,0,6))
					-- Set(this,"Slot1IsAtY",string.sub(NewCargo2.Pos.y,0,6))
				-- end
			-- end
		-- end
		
		-- if MyCraneBooth.IsMilitary == "Yes" then
			-- myTruckDriver = Object.Spawn("TowTruck2DriverMilitary",this.Pos.x,this.Pos.y+5.5)
		-- else
			-- myTruckDriver = Object.Spawn("TowTruck2Driver",this.Pos.x,this.Pos.y+5.5)
		-- end
		-- Set(myTruckDriver,"HomeUID",Get(this,"CraneUID"))
		-- Set(myTruckDriver,"TruckID",this.Id.i)
		-- Set(this,"DriverSpawned",true)
	-- end
-- end

-- function BlinkLight()
	-- if blinkTimer > 0.25 then
		-- blinkTimer = 0
		-- if this.VehicleState == "EnteringGarage" then
			-- if MyCraneBooth.GaragePlacement == "Right" or MyCraneBooth.GaragePlacement == "Centre" then
				-- if MyCraneBooth.IsMilitary == "No" then
					-- --print("1. entering, right or centre")
					-- if MyTruckSkin.SubType == 0 then MyTruckSkin.SubType = 1 else MyTruckSkin.SubType = 0 end
				-- else
					-- --print("1. entering, right or centre, military")
					-- if MyTruckSkin.SubType == 3 then MyTruckSkin.SubType = 4 else MyTruckSkin.SubType = 3 end
				-- end
			-- elseif MyCraneBooth.GaragePlacement == "Left" then
				-- if MyCraneBooth.IsMilitary == "No" then
					-- --print("1. entering, left")
					-- if MyTruckSkin.SubType == 0 then MyTruckSkin.SubType = 2 else MyTruckSkin.SubType = 0 end
				-- else
					-- --print("1. entering, left, military")
					-- if MyTruckSkin.SubType == 3 then MyTruckSkin.SubType = 5 else MyTruckSkin.SubType = 3 end
				-- end
			-- end
		-- else
			-- if MyCraneBooth.GaragePlacement == "Right" or MyCraneBooth.GaragePlacement == "Centre" then
				-- if MyCraneBooth.IsMilitary == "No" then
					-- --print("2. leaving, right or centre")
					-- if MyTruckSkin.SubType == 0 then MyTruckSkin.SubType = 2 else MyTruckSkin.SubType = 0 end
				-- else
					-- --print("2. leaving, right or centre, military")
					-- if MyTruckSkin.SubType == 3 then MyTruckSkin.SubType = 5 else MyTruckSkin.SubType = 3 end
				-- end
			-- elseif MyCraneBooth.GaragePlacement == "Left" then
				-- if MyCraneBooth.IsMilitary == "No" then
					-- --print("2. leaving, left")
					-- if MyTruckSkin.SubType == 0 then MyTruckSkin.SubType = 1 else MyTruckSkin.SubType = 0 end
				-- else
					-- --print("2. leaving, left, military")
					-- if MyTruckSkin.SubType == 3 then MyTruckSkin.SubType = 4 else MyTruckSkin.SubType = 3 end
				-- end
			-- end
		-- end
	-- end
-- end

-- function TurnIn()
	-- --print("TurnIn")
	-- if MyCraneBooth.GaragePlacement == "Left" and MyCraneBooth.TruckParkX > this.Pos.x then
		-- this.VelX = 1.25
		-- this.VelY = 1.85
	-- elseif MyCraneBooth.GaragePlacement == "Right" and MyCraneBooth.TruckParkX < this.Pos.x then
		-- this.VelX = -1.25
		-- this.VelY = 1.85
	-- elseif MyCraneBooth.GaragePlacement == "Centre" and MyCraneBooth.TruckParkX < this.Pos.x then
		-- this.VelX = -1.25
		-- this.VelY = 1.85
	-- elseif not this.ProcessingInGarage then
		-- this.VelX = 0
		-- this.VelY = 0
		-- if MyCraneBooth.IsMilitary == "No" then
			-- this.SubType = 0
		-- else
			-- this.SubType = 3
		-- end
		-- this.VehicleState = "ProcessingGarage"
		-- MyTruckSkin.Tooltip="\nVehicle ID: "..this.HomeUID.."\nCrane ID: "..this.CraneUID.."\n\nStatus: Processing\n\nVehicle behind me: None\nVehicle in front: None"
		-- Set(this,"ProcessingInGarage",true)
	-- end
-- end

-- function TurnOut()
	-- --print("TurnOut")
	-- if MyCraneBooth.GaragePlacement == "Left" and MyCraneBooth.RoadX < this.Pos.x-0.1 then
		-- this.VelX = -1.25
		-- this.VelY = 1.85
	-- elseif MyCraneBooth.GaragePlacement == "Right" and MyCraneBooth.RoadX > this.Pos.x+0.1 then
		-- this.VelX = 1.25
		-- this.VelY = 1.85
	-- elseif MyCraneBooth.GaragePlacement == "Centre" and MyCraneBooth.RoadX > this.Pos.x+0.1 then
		-- this.VelX = 1.25
		-- this.VelY = 1.85
	-- else
		-- --print("leaving")
		-- this.VelX = 0
		-- this.VelY = 1.5
		-- this.Pos.x = MyCraneBooth.RoadX
		-- this.VehicleState = "Leaving"
		-- if MyCraneBooth.IsMilitary == "No" then
			-- this.SubType = 0
		-- else
			-- this.SubType = 3
		-- end
	-- end
-- end

				---
-- function JobComplete_TruckDriverLeaving()
	-- if timePerGateUpdate==nil then
		-- Init()
	-- end
	-- Set(this,"issueLeaveJob",false)
	-- if MyMarker ~= nil and MyMarker.GarageTraffic == nil then FindMyRoadMarker() end -- marker got replaced, find new
	-- Set(this,"GateCount",1)
	-- GetGates()
	-- for i = 1,TotalGates do
		-- if not Get(this,"ClearedAuth"..i) then
			-- PriorGateY = GateList[i].GatePosY
			-- print("[J1] -- "..this.HomeUID.." PriorGateY: "..PriorGateY)
			-- break
		-- end
	-- end
	-- print("[J2] -- "..this.HomeUID.." GateCount: "..this.GateCount)
	-- Set(this,"RepairedLimoGate",this.GateCount)
	-- Set(this,"VehicleState","LeavingGarage")
	-- FindVehicleInFront()
	-- FindVehicleBehindMe()
    -- nearbyObject = Find("TowTruck2Driver",5)
	-- if next(nearbyObject) then
		-- for thatEntity, distance in pairs(nearbyObject) do
			-- --if Get(thatEntity,"HomeUID") == Get(this,"CraneUID") and Get(thatEntity,"TruckID") == this.Id.i then
				-- thatEntity.Delete() -- just get rid of 1 truck driver since a driver from another truck could have taken the job
				-- break
			-- --end
		-- end
	-- end
	-- FindMyTrafficLight()
	-- if Exists(MySideLaneTrafficLight) then MySideLaneTrafficLight.SubType = 4 end
-- end

-- function JobComplete_TruckDriverLeavingMilitary()
	-- if timePerGateUpdate==nil then
		-- Init()
	-- end
	-- Set(this,"issueLeaveJob",false)
	-- if MyMarker ~= nil and MyMarker.GarageTraffic == nil then FindMyRoadMarker() end -- marker got replaced, find new
	-- Set(this,"GateCount",1)
	-- GetGates()
	-- for i = 1,TotalGates do
		-- if not Get(this,"ClearedAuth"..i) then
			-- PriorGateY = GateList[i].GatePosY
			-- print("[J3] -- "..this.HomeUID.." PriorGateY: "..PriorGateY)
			-- break
		-- end
	-- end
	-- print("[J4] -- "..this.HomeUID.." GateCount: "..this.GateCount)
	-- Set(this,"RepairedLimoGate",this.GateCount)
	-- Set(this,"VehicleState","LeavingGarage")
	-- FindVehicleInFront()
	-- FindVehicleBehindMe()
    -- nearbyObject = Find("TowTruck2DriverMilitary",5)
	-- if next(nearbyObject) then
		-- for thatEntity, distance in pairs(nearbyObject) do
			-- --if Get(thatEntity,"HomeUID") == Get(this,"CraneUID") and Get(thatEntity,"TruckID") == this.Id.i then
				-- thatEntity.Delete() -- just get rid of 1 truck driver since a driver from another truck could have taken the job
				-- break
			-- --end
		-- end
	-- end
	-- FindMyTrafficLight()
	-- if Exists(MySideLaneTrafficLight) then MySideLaneTrafficLight.SubType = 4 end
-- end
				---

---