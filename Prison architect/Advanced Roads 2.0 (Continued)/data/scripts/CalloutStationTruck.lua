
local retryCounter = 0
local foundCalloutStation = false
local foundOptionalWayPoint = false

local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

local CalloutEntitiesToFind = { "Fireman", "Paramedic", "RiotGuard", "ArmedGuard", "Soldier", "EliteOps" }
local CalloutSkinTypes = { ["Fireman"] = "FireEngine", ["Paramedic"] = "Ambulance", ["RiotGuard"] = "RiotVan", ["ArmedGuard"] = "RiotVan", ["Soldier"] = "Troop", ["EliteOps"] = "RiotVan" }
local MyEntities = {}

function Create()
end

function Update(timePassed)
	if InitDone == nil then
		retryCounter = retryCounter + 1
		if retryCounter <= 10 then
			InitMyCalloutEntities()
			return
		else
			this.Delete()
		end
	else
		if CalloutCompleted == true then
			this.Delete()
		else
			FindOptionalWayPoint()
			FindNearestCargoStation()
			if foundCalloutStation == true then
				CompleteTheCallout()
			else
				AbortCallout()
			end
		end
	end
end

function InitMyCalloutEntities()
	print("InitMyCalloutEntities")
	for T, typ in pairs(CalloutEntitiesToFind) do
		print("Looking for call-out "..CalloutEntitiesToFind[T])
		local nearbyObjects = Find(this,typ,9)
		for thatEntity, distance in pairs(nearbyObjects) do
			if this.Slot0.u == thatEntity.Id.u		 then MyEntity1 = thatEntity; MyEntities[1] = MyEntity1; print("MyEntity1 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot1.u == thatEntity.Id.u	 then MyEntity2 = thatEntity; MyEntities[2] = MyEntity2; print("MyEntity2 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot2.u == thatEntity.Id.u	 then MyEntity3 = thatEntity; MyEntities[3] = MyEntity3; print("MyEntity3 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot3.u == thatEntity.Id.u	 then MyEntity4 = thatEntity; MyEntities[4] = MyEntity4; print("MyEntity4 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot4.u == thatEntity.Id.u	 then MyEntity5 = thatEntity; MyEntities[5] = MyEntity5; print("MyEntity5 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot5.u == thatEntity.Id.u	 then MyEntity6 = thatEntity; MyEntities[6] = MyEntity6; print("MyEntity6 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot6.u == thatEntity.Id.u	 then MyEntity7 = thatEntity; MyEntities[7] = MyEntity7; print("MyEntity7 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot7.u == thatEntity.Id.u	 then MyEntity8 = thatEntity; MyEntities[8] = MyEntity8; print("MyEntity8 "..thatEntity.Type.." found at "..distance)
			end
		end
		nearbyObjects = nil
		if Exists(MyEntity1) and Exists(MyEntity2) and Exists(MyEntity3) and Exists(MyEntity4) and Exists(MyEntity5) and Exists(MyEntity6) and Exists(MyEntity7) and Exists(MyEntity8) then
			Set(this,"MyType",CalloutEntitiesToFind[T])
			Set(this,"SkinType",CalloutSkinTypes[CalloutEntitiesToFind[T]])
			InitDone = true
			break
		end
	end
end

function FindOptionalWayPoint()
	print("FindOptionalWayPoint")
	local CalloutHelipads = Find(this,"CalloutHelipad",10000)
	if next(CalloutHelipads) then
		for thatCH, distance in pairs(CalloutHelipads) do
			if thatCH.InUse == "no" and thatCH.TrafficEnabled == "yes" then
				MyOptionalWayPoint = thatCH
				Set(MyOptionalWayPoint,"MyType",this.MyType)
				Set(MyOptionalWayPoint,"InUse","yes")
				Set(this,"CalloutX",MyOptionalWayPoint.Pos.x)
				Set(this,"CalloutY",MyOptionalWayPoint.Pos.y)
				foundOptionalWayPoint = true
				print("MyOptionalWayPoint found at "..distance..", using it for temporary call-out ("..this.MyType..")")
				break
			end
		end
	end
	CalloutHelipads = nil
	if foundOptionalWayPoint == false then
		print("No optional waypoint found")
	end
end

function FindNearestCargoStation()
	print("FindNearestCargoStation")
	local CurrDist = 10000
	if foundOptionalWayPoint == true then
		local CargoStations = Find(MyOptionalWayPoint,"CargoStopSign",10000)
		if next(CargoStations) then
			for thatCS, distance in pairs(CargoStations) do
				if distance < CurrDist and thatCS.CargoType == "Emergency" and thatCS.TrafficEnabled == "yes" and thatCS.InUse == "no" and thatCS.WaitForFiremen == false then
					CurrDist = distance
					MyCalloutStation = thatCS
					print("Potentional "..MyCalloutStation.CargoType.." CargoStation found at "..distance)
				end
			end
		end
	else
		local CargoStations = Find(this,"CargoStopSign",10000)
		if next(CargoStations) then
			for thatCS, distance in pairs(CargoStations) do
				if thatCS.CargoType == "Emergency" and thatCS.TrafficEnabled == "yes" and thatCS.InUse == "no" and thatCS.WaitForFiremen == false then
					CurrDist = distance
					MyCalloutStation = thatCS
					print("Idle "..MyCalloutStation.CargoType.." CargoStation found at "..distance)
					break
				end
			end
		end
	end
	if Exists(MyCalloutStation) then
		print("Search completed, using "..MyCalloutStation.CargoType.." CargoStation found at "..CurrDist.." for temporary call-out ("..this.MyType..")")
		Set(MyCalloutStation,"InUse","yes")
		foundCalloutStation = true
	end
	CargoStations = nil
end

function CompleteTheCallout()
	local TruckSub = 0
	local nearbyTerminals = Find("TrafficTerminal",10000)
	if next(nearbyTerminals) then
		for thatTerminal, distance in pairs(nearbyTerminals) do
			print("MyTrafficTerminal found at "..distance)
			MyTrafficTerminal = thatTerminal
			TruckSub = Get(MyTrafficTerminal,"SubType_"..this.SkinType)
			print("TruckSub: "..TruckSub)
			break
		end
	end
	nearbyTerminals = nil
	
	local MyTruck = Object.Spawn("CargoStationTruck",MyCalloutStation.RoadX,math.random(5,6) + (math.random(10,99) / 100) + (math.random(10,99) / 100))
	Set(MyTruck,"HomeUID",this.MyType.."Truck_"..MyTruck.Id.u)
	Set(MyTruck,"TruckID",MyTruck.Id.u)
	Set(MyTruck,"CargoStationID",MyCalloutStation.CargoStationID)
	Set(MyTruck,"MyType","Callout")
	Set(MyTruck,"CalloutEntities",this.MyType)
	Set(MyTruck,"IsCallOut",true)
	Set(MyTruck,"SkinType",this.SkinType)
	if this.SkinType == "Ambulance" or this.SkinType == "RiotVan" or this.SkinType == "Troop" then
		Set(MyTruck,"Tail",3.75)
		Set(MyTruck,"Head",1.5)
	else -- FireEngine
		Set(MyTruck,"Tail",7)
		Set(MyTruck,"Head",1.25)
	end
	Set(MyTruck,"TruckY",0.25)
	Set(MyTruck,"RoadX",MyCalloutStation.RoadX)
	Set(MyTruck,"TotalCargoAmount",8)
	
	if foundOptionalWayPoint == true then
		Set(MyTruck,"CalloutX",this.CalloutX)
		Set(MyTruck,"CalloutY",this.CalloutY)
		if Exists(MyOptionalWayPoint) then
			MyOptionalWayPoint.Delete()
		end
	end
	
	local newTruckSkin = Object.Spawn(this.SkinType.."TruckSkin",MyTruck.Pos.x,MyTruck.Pos.y)
	newTruckSkin.SubType = TruckSub
	Set(newTruckSkin,"HomeUID",MyTruck.HomeUID)
	Set(newTruckSkin,"Slot0.i",MyTruck.Id.i)
	Set(newTruckSkin,"Slot0.u",MyTruck.Id.u)
	Set(MyTruck,"CarrierId.i",newTruckSkin.Id.i)
	Set(MyTruck,"CarrierId.u",newTruckSkin.Id.u)
	Set(MyTruck,"Loaded",true)
	newTruckSkin.Tooltip = { "tooltip_CargoStationTruck_TruckSkin",MyCalloutStation.HomeUID,"H" }

	local newHL = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
	Set(newTruckSkin,"Slot1.i",newHL.Id.i)
	Set(newTruckSkin,"Slot1.u",newHL.Id.u)
	Set(newHL,"CarrierId.i",newTruckSkin.Id.i)
	Set(newHL,"CarrierId.u",newTruckSkin.Id.u)
	Set(newHL,"Loaded",true)
	Set(newHL,"HomeUID",this.HomeUID)
	local newHR = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
	Set(newTruckSkin,"Slot2.i",newHR.Id.i)
	Set(newTruckSkin,"Slot2.u",newHR.Id.u)
	Set(newHR,"CarrierId.i",newTruckSkin.Id.i)
	Set(newHR,"CarrierId.u",newTruckSkin.Id.u)
	Set(newHR,"Loaded",true)
	Set(newHR,"HomeUID",this.HomeUID)
	
	MyTruckBay1 = Object.Spawn("CalloutTruckBay",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
	
	for i = 0,7 do
		Set(this,"Slot"..i..".i",-1)
		Set(this,"Slot"..i..".u",-1)
		MyEntities[i+1].CarrierId.i = -1
		MyEntities[i+1].CarrierId.u = -1
		MyEntities[i+1].Loaded = false
		MyEntities[i+1].Pos.x = MyTruckBay1.Pos.x
		MyEntities[i+1].Pos.y = MyTruckBay1.Pos.y
	end
	
	for i = 0,7 do
		Set(MyTruckBay1,"Slot"..i..".i",MyEntities[i+1].Id.i)
		Set(MyTruckBay1,"Slot"..i..".u",MyEntities[i+1].Id.u)
		MyEntities[i+1].CarrierId.i = MyTruckBay1.Id.i
		MyEntities[i+1].CarrierId.u = MyTruckBay1.Id.u
		MyEntities[i+1].Loaded = true
		Set(MyEntities[i+1],"HomeUID",MyTruck.HomeUID)
		Set(MyEntities[i+1],"CargoStationID",MyTruck.CargoStationID)
		Set(MyEntities[i+1],"Number",i+1)
		Set(MyEntities[i+1],"Tooltip","HomeUID: "..MyTruck.HomeUID)
		if MyEntities[i+1].Type == "Fireman" then MyEntities[i+1].Equipment = 0 end 
	end
	
	Set(newTruckSkin,"Slot3.i",MyTruckBay1.Id.i)
	Set(newTruckSkin,"Slot3.u",MyTruckBay1.Id.u)
	Set(MyTruckBay1,"CarrierId.i",newTruckSkin.Id.i)
	Set(MyTruckBay1,"CarrierId.u",newTruckSkin.Id.u)
	Set(MyTruckBay1,"Loaded",true)
	Set(MyTruckBay1,"HomeUID",MyTruck.HomeUID)
	Set(MyTruckBay1,"TruckBayNr",1)
	Set(MyTruckBay1,"CargoAmount",8)
	Set(MyTruckBay1,"CalloutEntities",this.MyType)
	
	Set(MyTruckBay1,"CargoStationID",MyTruck.CargoStationID)
	for i = 0,7 do
		Set(MyTruckBay1,"CargoLoad"..i,MyTruck.CargoStationID)
	end
	MyTruckBay1.Tooltip = { "tooltip_Bay",MyTruck.HomeUID,"H",MyTruck.CargoStationID,"I",1,"N",8,"A" }
	
	Set(MyCalloutStation,"VehicleSpawned","yes")
	Set(MyCalloutStation,"Status","ON ROUTE")
	for thatControl in next, Find(MyCalloutStation,"CargoStationControl",8) do
		if thatControl.MarkerUID == MyCalloutStation.MarkerUID and thatControl.HomeUID == MyCalloutStation.HomeUID then
			Set(thatControl,"SubType",20)
			break
		end
	end
			
	Set(MyTruck,"Number",MyCalloutStation.Number)
	CalloutCompleted = true
end

function AbortCallout()
	for I = 1,8 do
		if Exists(MyEntities[I]) then
			MyEntities[I].Delete()
		end
	end
	if Exists(MyOptionalWayPoint) then
		MyOptionalWayPoint.Delete()
	end
	CalloutCompleted = true
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
