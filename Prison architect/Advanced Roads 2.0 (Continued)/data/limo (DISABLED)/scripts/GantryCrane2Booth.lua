
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects
local timeTot = 0
local timeToReset = 0
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects
local MyMarker = {}
local Limo2RepairOrderPapersNr = 0
local truckFound = false
local rackFound = false
local Limo0 = ""
local Limo1 = ""
local Limo2 = ""
local Limo3 = ""
local Limo4 = ""
local Limo5 = ""
local Limo6 = ""
local Limo7 = ""
local Limo8 = ""
local Limo9 = ""
local Limo10 = ""
local Limo11 = ""
local Limo12 = ""
local Limo13 = ""
local Limo14 = ""
local Limo15 = ""

-------------------- Find Stuff -------------------------

function FindMyCrane()
	--print("FindMyCrane")
	local craneFound = false
	local hookFound = false
	local nearbyObject = Find("GantryCrane2",50)
	if next(nearbyObject) then
		for thatCrane, distance in pairs(nearbyObject) do
			if thatCrane.HomeUID==this.HomeUID then
				--print("GantryCrane2 found")
				craneFound = true
				MyCrane=thatCrane
				break
			end
		end
	end
	nearbyObject=nil
	local nearbyObject = Find("GantryCrane2Hook",50)
	if next(nearbyObject) then
		for thatHook, distance in pairs(nearbyObject) do
			if thatHook.HomeUID==this.HomeUID then
				--print("GantryCrane2Hook found")
				hookFound = true
				MyHook=thatHook
				break
			end
		end
	end
	nearbyObject=nil
	if craneFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Crane not found.") end
	if hookFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Hook not found.") end
		
end

function FindMyRack()
	--print("FindMyRack")
	rackFound = false	-- NOT a local but a global
	local nearbyObject = Find("CarPartsRack2",50)
	if next(nearbyObject) then
		for thatRack, distance in pairs(nearbyObject) do
			if thatRack.HomeUID==this.HomeUID then
				--print("CarPartsRack2 found")
				rackFound = true
				MyRack=thatRack
				break
			end
		end
	end
	nearbyObject=nil
	--if rackFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  No Rack available.") end
end

function FindMyRails()
	--print("FindMyRails")
	local railsFoundL = false
	local railsFoundR = false
	local nearbyObject = Find("GantryCrane2RailLeft",50)
	if next(nearbyObject) then
		for thatRail, distance in pairs(nearbyObject) do
			if thatRail.HomeUID==this.HomeUID then
				--print("GantryCrane2RailLeft found")
				railsFoundL = true
				MyCraneRailLeft=thatRail
				break
			end
		end
	end
	nearbyObject=nil
	local nearbyObject = Find("GantryCrane2RailRight",50)
	if next(nearbyObject) then
		for thatRail, distance in pairs(nearbyObject) do
			if thatRail.HomeUID==this.HomeUID then
				--print("GantryCrane2RailRight found")
				MyCraneRailRight=thatRail
				railsFoundLR = true
				break
			end
		end
	end
	nearbyObject=nil
	if railsFoundL == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Left rails not found.") end
	if railsFoundR == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Right rails not found.") end
end

function FindMyRoadPoles()
	MyPoleStart = nil
	MyPoleEnd = nil
	MyRoadPole = nil
	local nearbyObject = Find(MyRepairedLimoGate,"RoadPoleStart",3)
	if next(nearbyObject) then
		for thatPost, distance in pairs(nearbyObject) do
			if thatPost.GateUID==this.GateUID then
				MyPoleStart=thatPost
			end
		end
	end
	nearbyObject = Find(MyRepairedLimoGate,"RoadPoleEnd",3)
	if next(nearbyObject) then
		for thatPost, distance in pairs(nearbyObject) do
			if thatPost.GateUID==this.GateUID then
				MyPoleEnd=thatPost
			end
		end
	end
	nearbyObject = Find(MyRepairedLimoGate,"SmallRoadPole",3)
	if next(nearbyObject) then
		for thatPost, distance in pairs(nearbyObject) do
			if thatPost.GateUID==this.GateUID then
				MyRoadPole=thatPost
			end
		end
	end
	nearbyObject = nil
end

function FindMyGates()
	print("FindMyGates")
	local gateFound = false
	local nearbyObject = Find("RoadGate2Small",50)
	if next(nearbyObject) then
		for thatGate, distance in pairs(nearbyObject) do
			if thatGate.HomeUID==this.HomeUID and thatGate.SubType == 10 then
				print("MyRepairedLimoGate found")
				MyRepairedLimoGate=thatGate
				gateFound = true
				--break
			elseif thatGate.Pos.x == this.ParkX and thatGate.Pos.y == this.ParkY+this.Ymin-1 then
				print("MyTopGate1 found")
				MyTopGate1 = thatGate
			elseif thatGate.Pos.x == this.ParkX and thatGate.Pos.y == this.ParkY+this.Ymax+2 then
				print("MyBottomGate1 found")
				MyBottomGate1 = thatGate
			else
				if this.RoadSize == "Double" then
					local offSet = 3
					if this.GaragePlacement == "Left" then offSet = -3 end
					if thatGate.Pos.x == this.ParkX+offSet and thatGate.Pos.y == this.ParkY+this.Ymin-1 then
						print("MyTopGate2 found")
						MyTopGate2 = thatGate
					elseif thatGate.Pos.x == this.ParkX+offSet and thatGate.Pos.y == this.ParkY+this.Ymax+2 then
						print("MyBottomGate2 found")
						MyBottomGate2 = thatGate
					end
				end
			end
		end
	end
	nearbyObject = nil
	if gateFound == false then
		--print("Gate was removed, spawn new")
		MyRepairedLimoGate = Object.Spawn("RoadGate2Small",this.ParkX,this.ParkY+this.Ymax-4.5)
		Set(MyRepairedLimoGate,"HomeUID",this.HomeUID)
		Set(MyRepairedLimoGate,"SmallPost",true)
		Set(MyRepairedLimoGate,"ScanForStaff","YES")
		Set(MyRepairedLimoGate,"SubType",10)
		Set(MyRepairedLimoGate,"GateCreated",true)
		if this.GaragePlacement == "Left" then
			Set(MyRepairedLimoGate,"Or.y",-1)
			Set(MyRepairedLimoGate,"OpenDir.x",2)
			Set(MyRepairedLimoGate,"OpenDir.y",0)
			
			FindMyRoadPoles()
			if not Exists(MyPoleStart) then
				MyPoleStart=Object.Spawn("RoadPoleStart",MyRepairedLimoGate.Pos.x+2.5,MyRepairedLimoGate.Pos.y+0.5)
				Set(MyPoleStart,"HomeUID",this.HomeUID)
				Set(MyPoleStart,"Tooltip","HomeUID: "..this.HomeUID)
			end
			if not Exists(MyPoleEnd) then
				MyPoleEnd=Object.Spawn("RoadPoleEnd",MyRepairedLimoGate.Pos.x-1.5,MyRepairedLimoGate.Pos.y+0.5)
				Set(MyPoleEnd,"HomeUID",this.HomeUID)
				Set(MyPoleEnd,"Tooltip","HomeUID: "..this.HomeUID)
			end
			if not Exists(MyRoadPole) then
				MyRoadPole=Object.Spawn("SmallRoadPole",MyRepairedLimoGate.Pos.x+2,MyRepairedLimoGate.Pos.y)
				Set(MyRoadPole,"SubType",1)
				Set(MyRoadPole,"HomeUID",this.HomeUID)
				Set(MyRoadPole,"Tooltip","HomeUID: "..this.HomeUID)
			end
			
			MySideLaneTrafficLight = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x+2.5,MyRepairedLimoGate.Pos.y)
			Set(MySideLaneTrafficLight,"LightType",3)
			Set(MySideLaneTrafficLight,"HomeUID",this.HomeUID)
			Set(MySideLaneTrafficLight,"SubType",3)
			Set(MySideLaneTrafficLight,"SideLaneLight",true)
			Set(MySideLaneTrafficLight,"Tooltip","HomeUID: "..this.HomeUID)
			MyPoleStart.Slot0.i = MySideLaneTrafficLight.Id.i
			MyPoleStart.Slot0.u = MySideLaneTrafficLight.Id.u
			MySideLaneTrafficLight.CarrierId.i = MyPoleStart.Id.i
			MySideLaneTrafficLight.CarrierId.u = MyPoleStart.Id.u
			MySideLaneTrafficLight.Loaded = true
			
			MyRoadTrafficLight = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x-1.5,MyRepairedLimoGate.Pos.y)
			Set(MyRoadTrafficLight,"HomeUID",this.HomeUID)
			Set(MyRoadTrafficLight,"LightType",0)
			Set(MyRoadTrafficLight,"Tooltip",MyRepairedLimoGate.Tooltip)
		else
			FindMyRoadPoles()
			if not Exists(MyPoleStart) then
				MyPoleStart=Object.Spawn("RoadPoleStart",MyRepairedLimoGate.Pos.x-2.5,MyRepairedLimoGate.Pos.y+0.5)
				Set(MyPoleStart,"HomeUID",this.HomeUID)
				Set(MyPoleStart,"Tooltip","HomeUID: "..this.HomeUID)
			end
			if not Exists(MyPoleEnd) then
				MyPoleEnd=Object.Spawn("RoadPoleEnd",MyRepairedLimoGate.Pos.x+1.5,MyRepairedLimoGate.Pos.y+0.5)
				Set(MyPoleEnd,"HomeUID",this.HomeUID)
				Set(MyPoleEnd,"Tooltip","HomeUID: "..this.HomeUID)
				MyPoleEnd.SubType = 1
			end
			if not Exists(MyRoadPole) then
				MyRoadPole=Object.Spawn("SmallRoadPole",MyRepairedLimoGate.Pos.x-2,MyRepairedLimoGate.Pos.y)
				Set(MyRoadPole,"HomeUID",this.HomeUID)
				Set(MyRoadPole,"Tooltip","HomeUID: "..this.HomeUID)
			end
			
			MySideLaneTrafficLight = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x-2.5,MyRepairedLimoGate.Pos.y)
			Set(MySideLaneTrafficLight,"LightType",3)
			Set(MySideLaneTrafficLight,"SubType",3)
			Set(MySideLaneTrafficLight,"HomeUID",this.HomeUID)
			Set(MySideLaneTrafficLight,"SideLaneLight",true)
			Set(MySideLaneTrafficLight,"Tooltip","HomeUID: "..this.HomeUID)
			MyPoleStart.Slot0.i = MySideLaneTrafficLight.Id.i
			MyPoleStart.Slot0.u = MySideLaneTrafficLight.Id.u
			MySideLaneTrafficLight.CarrierId.i = MyPoleStart.Id.i
			MySideLaneTrafficLight.CarrierId.u = MyPoleStart.Id.u
			MySideLaneTrafficLight.Loaded = true
			
			MyRoadTrafficLight = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x+1.5,MyRepairedLimoGate.Pos.y)
			Set(MyRoadTrafficLight,"LightType",0)
			Set(MyRoadTrafficLight,"HomeUID",this.HomeUID)
			Set(MyRoadTrafficLight,"Tooltip",MyRepairedLimoGate.Tooltip)
		end
	end
end

function UpgradeTrafficLight()
	local nearbyObject = Find("RoadGate2TrafficLightSmall",50)
	if next(nearbyObject) then
		for thatLight, distance in pairs(nearbyObject) do
			if thatLight.HomeUID==this.HomeUID then
				if not thatLight.SideLaneLight then
					--print("RoadGate2TrafficLightSmall found")
					MyRoadTrafficLight=thatLight
				else
					print("SideLaneTrafficLight found")
					MySideLaneTrafficLight=thatLight
				end
			end
		end
	end
	nearbyObject = nil
	if MySideLaneTrafficLight == nil then
		MySideLaneTrafficLight = Object.Spawn("RoadGate2TrafficLightSmall",this.Pos.x,this.Pos.y)
		Set(MySideLaneTrafficLight,"HomeUID",this.HomeUID)
		Set(MySideLaneTrafficLight,"SideLaneLight",true)
		Set(MySideLaneTrafficLight,"Tooltip","Side Light")
	end
	if not MySideLaneTrafficLight.Loaded then
		local nearbyObject = Find("RoadPoleStart",50)
		if next(nearbyObject) then
			for thatPole, distance in pairs(nearbyObject) do
				if thatPole.HomeUID == this.HomeUID then
					Set(MySideLaneTrafficLight,"LightType",3)
					Set(MySideLaneTrafficLight,"SubType",3)
					thatPole.Slot0.i = MySideLaneTrafficLight.Id.i
					thatPole.Slot0.u = MySideLaneTrafficLight.Id.u
					MySideLaneTrafficLight.CarrierId.i = thatPole.Id.i
					MySideLaneTrafficLight.CarrierId.u = thatPole.Id.u
					MySideLaneTrafficLight.Loaded = true
					break
				end
			end
		end
		nearbyObject = nil
	end
end

function FindMyLimoTruck()
	print("FindMyLimoTruck")
	truckFound = false
	local nearbyObject = Find("CargoStationTruck",1500)
	if next(nearbyObject) then
		--print("Some trucks found")
		for thatTruck, distance in pairs(nearbyObject) do
			--print(thatTruck.CraneUID)
			--print(thatTruck.VehicleState)
			if Get(thatTruck,"CraneUID") == this.HomeUID and Get(thatTruck,"SkinType") == "LimoTow" and Get(thatTruck,"VehicleState") ~= "Leaving" then
				print("TowTruck2WithLimo found")
				newLimoTruck=thatTruck
				truckFound = true
				break
			end
		end
	end
	nearbyObject = nil
	--if truckFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  TowTruck2WithLimo not found.") end
end

function FindMyPartsTruck()
	print("FindMyPartsTruck")
	truckFound = false
	local nearbyObject = Find("CargoStationTruck",1500)
	if next(nearbyObject) then
		--print("Some trucks found")
		for thatTruck, distance in pairs(nearbyObject) do
			--print(thatTruck.CraneUID)
			--print(thatTruck.VehicleState)
			if Get(thatTruck,"CraneUID") == this.HomeUID and Get(thatTruck,"SkinType") == "CarPartsTow" and Get(thatTruck,"VehicleState") ~= "Leaving" then
				print("TowTruck2WithCarParts found")
				newEngineTruck=thatTruck
				truckFound = true
				break
			end
		end
	end
	nearbyObject = nil
	--if truckFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  TowTruck2WithCarParts not found.") end
end

function FindMyRoadMarker()
	local markerFound = false
    local nearbyObject = Find(this,"RoadMarker2",1500)
	if next(nearbyObject) then
		for name,dist in pairs(nearbyObject) do
			if Get(MyHook,"MarkerUID") == Get(name,"MarkerUID") then
				--print("marker found")
				MyMarker=name
				Set(this,"MarkerUID",Get(name,"MarkerUID"))
				markerFound = true
				break
			end
		end
	end
	nearbyObject = nil
	if markerFound == false then
		-- local nearbyObject = Find(this,"StreetManager2",1500)
		-- if next(nearbyObject) then
			-- for thatManager,dist in pairs(nearbyObject) do
				-- print("Reset StreetManager")
				-- thatManager.Delete()
			-- end
		-- end
		-- nearbyObject = nil
		-- Set(this,"ErrorLog",this.ErrorLog.."\n |  RoadMarker not found, StreetManager reset.")
		-- return
	end
end

function FindMyDesk()
	local deskFound = false
	local nearbyObject = Find("Limo2ServiceDesk",50)
	if next(nearbyObject) then
		for thatDesk, distance in pairs(nearbyObject) do
			if thatDesk.HomeUID==this.HomeUID then
				deskFound = true
				MyDesk=thatDesk
				print("MyDesk found")
			end
		end
	end
	nearbyObject = nil
	if deskFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Limo2ServiceDesk not found.") end
end

function FindMyLimo2RepairedOnRoad()
	if Get(this,"LimoWaitingOnRoad") == "yes" then
		local limoWaitingFound = false
		local nearbyObject = Find("Limo2RepairedOnRoad",50)
		if next(nearbyObject) then
			for thatLimo, distance in pairs(nearbyObject) do
				if thatLimo.CraneUID==this.HomeUID then
					limoWaitingFound = true
					MyLimo=thatLimo
					print("MyLimo found")
				end
			end
		end
		nearbyObject = nil
		if limoWaitingFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Limo2RepairedOnRoad not found.") end
		if MyLimo == nil then Set(this,"LimoWaitingOnRoad","no") end
		MyLimo = nil
	end
end


-------------------- Order stuff  ----------------------

function CheckOrder(cargotype)
	if cargotype == "limo" then
		local OrderLimoAmount = 0
		local s = 7
		if this.GarageSize == "Tall" or this.GarageSize == "Wide" then s = 15 end
		for j=0,s do
			if Get(this,"Limo"..j.."ID") == "None" and Get(this,"Slot"..j.."X") ~= nil then
				OrderLimoAmount = OrderLimoAmount+1
			end
		end
		if OrderLimoAmount > 0 then
			Set(this,"GarageIsFull","no")
			
			local newLimoTruck = Object.Spawn("CargoStationTruck",MyHook.ParkX,4)
			Set(newLimoTruck,"HomeUID","TowTruck_"..newLimoTruck.Id.u)
			Set(newLimoTruck,"TruckID",newLimoTruck.Id.u)
			Set(newLimoTruck,"Tail",8.5)
			Set(newLimoTruck,"Head",1.5)
			Set(newLimoTruck,"RoadX",MyHook.ParkX)
			Set(newLimoTruck,"MyType","Garage")
			Set(newLimoTruck,"SkinType","LimoTow")
			Set(newLimoTruck,"CargoStationID",0)
			Set(newLimoTruck,"CraneUID",this.HomeUID)
			Set(newLimoTruck,"MarkerUID",this.MarkerUID)
			Set(newLimoTruck,"GaragePosY",this.ParkY)
			--Set(newLimoTruck,"TruckY",2)
			
			local newTruckSkin = Object.Spawn("LimoTowTruckSkin",MyHook.ParkX,newLimoTruck.Pos.y)
			if this.IsMilitary == "Yes" then newTruckSkin.SubType = 3 end
			Set(newTruckSkin,"HomeUID",newLimoTruck.HomeUID)
			Set(newTruckSkin,"Slot0.i",newLimoTruck.Id.i)
			Set(newTruckSkin,"Slot0.u",newLimoTruck.Id.u)
			Set(newLimoTruck,"CarrierId.i",newTruckSkin.Id.i)
			Set(newLimoTruck,"CarrierId.u",newTruckSkin.Id.u)
			Set(newLimoTruck,"Loaded",true)

			local newHL = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
			Set(newHL,"HomeUID",newLimoTruck.HomeUID)
			Set(newTruckSkin,"Slot1.i",newHL.Id.i)
			Set(newTruckSkin,"Slot1.u",newHL.Id.u)
			Set(newHL,"CarrierId.i",newTruckSkin.Id.i)
			Set(newHL,"CarrierId.u",newTruckSkin.Id.u)
			Set(newHL,"Loaded",true)
			local newHR = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
			Set(newHR,"HomeUID",newLimoTruck.HomeUID)
			Set(newTruckSkin,"Slot2.i",newHR.Id.i)
			Set(newTruckSkin,"Slot2.u",newHR.Id.u)
			Set(newHR,"CarrierId.i",newTruckSkin.Id.i)
			Set(newHR,"CarrierId.u",newTruckSkin.Id.u)
			Set(newHR,"Loaded",true)
	
			NewLimo1 = Object.Spawn("Limo2Broken",this.Pos.x,0)
			if this.IsMilitary == "Yes" then NewLimo1.SubType = 3 else NewLimo1.SubType = math.random(0,2) end
			Set(NewLimo1,"CraneUID",this.HomeUID)
			
			Set(newTruckSkin,"Slot3.i",Get(NewLimo1,"Id.i"))
			Set(newTruckSkin,"Slot3.u",Get(NewLimo1,"Id.u"))
			Set(NewLimo1,"CarrierId.i",Get(newTruckSkin,"Id.i"))
			Set(NewLimo1,"CarrierId.u",Get(newTruckSkin,"Id.u"))
			Set(NewLimo1,"Loaded",true)
				
			if OrderLimoAmount > 1 then				
				NewLimo2 = Object.Spawn("Limo2Broken",this.Pos.x,0)
				if this.IsMilitary == "Yes" then NewLimo2.SubType = 3 else NewLimo2.SubType = math.random(0,2) end
				Set(NewLimo2,"CraneUID",this.HomeUID)
				
				Set(newTruckSkin,"Slot4.i",Get(NewLimo2,"Id.i"))
				Set(newTruckSkin,"Slot4.u",Get(NewLimo2,"Id.u"))
				Set(NewLimo2,"CarrierId.i",Get(newTruckSkin,"Id.i"))
				Set(NewLimo2,"CarrierId.u",Get(newTruckSkin,"Id.u"))
				Set(NewLimo2,"Loaded",true)
			end
				
			Set(newLimoTruck,"LimoSpawned",true)
			Set(newLimoTruck,"Number",999)
		end
	elseif cargotype == "parts" then
		-- order car parts
	--	if MyRack == nil then FindMyRack() end
		
		if rackFound == true then
			local OrderPartsAmount = 0
			for i=0,7 do
				if Get(MyRack,"Slot"..i..".i") == -1 and not Get(MyRack,"Slot"..i.."Reserved") then
					OrderPartsAmount = OrderPartsAmount+1
				end
			end
			
			if OrderPartsAmount > 0 then
				Set(this,"PartsRackIsFull","no")
			
				local newEngineTruck = Object.Spawn("CargoStationTruck",MyHook.ParkX,4)
				Set(newEngineTruck,"HomeUID","TowTruck_"..newEngineTruck.Id.u)
				Set(newEngineTruck,"TruckID",newEngineTruck.Id.u)
				Set(newEngineTruck,"Tail",4.75)
				Set(newEngineTruck,"Head",1.5)
				Set(newEngineTruck,"RoadX",MyHook.ParkX)
				Set(newEngineTruck,"MyType","Garage")
				Set(newEngineTruck,"CargoStationID",0)
				Set(newEngineTruck,"SkinType","CarPartsTow")
				Set(newEngineTruck,"CraneUID",this.HomeUID)
				Set(newEngineTruck,"MarkerUID",this.MarkerUID)
				Set(newEngineTruck,"GaragePosY",this.ParkY)
				--Set(newEngineTruck,"TruckY",2)
				
				local newTruckSkin = Object.Spawn("CarPartsTowTruckSkin",MyHook.ParkX,newEngineTruck.Pos.y)
				if this.IsMilitary == "Yes" then newTruckSkin.SubType = 3 end
				Set(newTruckSkin,"HomeUID",newEngineTruck.HomeUID)
				Set(newTruckSkin,"Slot0.i",newEngineTruck.Id.i)
				Set(newTruckSkin,"Slot0.u",newEngineTruck.Id.u)
				Set(newEngineTruck,"CarrierId.i",newTruckSkin.Id.i)
				Set(newEngineTruck,"CarrierId.u",newTruckSkin.Id.u)
				Set(newEngineTruck,"Loaded",true)

				local newHL = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
				Set(newHL,"HomeUID",newEngineTruck.HomeUID)
				Set(newTruckSkin,"Slot1.i",newHL.Id.i)
				Set(newTruckSkin,"Slot1.u",newHL.Id.u)
				Set(newHL,"CarrierId.i",newTruckSkin.Id.i)
				Set(newHL,"CarrierId.u",newTruckSkin.Id.u)
				Set(newHL,"Loaded",true)
				local newHR = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
				Set(newHR,"HomeUID",newEngineTruck.HomeUID)
				Set(newTruckSkin,"Slot2.i",newHR.Id.i)
				Set(newTruckSkin,"Slot2.u",newHR.Id.u)
				Set(newHR,"CarrierId.i",newTruckSkin.Id.i)
				Set(newHR,"CarrierId.u",newTruckSkin.Id.u)
				Set(newHR,"Loaded",true)
		
				NewEngine1 = Object.Spawn("Limo2EngineOnTruck",this.Pos.x,0)
				Set(NewEngine1,"CraneUID",this.HomeUID)
				rndNumber=math.random(0,10)
				if rndNumber>=6 then Set(NewEngine1,"SubType",1) end
				
				Set(newTruckSkin,"Slot3.i",Get(NewEngine1,"Id.i"))
				Set(newTruckSkin,"Slot3.u",Get(NewEngine1,"Id.u"))
				Set(NewEngine1,"CarrierId.i",Get(newTruckSkin,"Id.i"))
				Set(NewEngine1,"CarrierId.u",Get(newTruckSkin,"Id.u"))
				Set(NewEngine1,"Loaded",true)
				
				if OrderPartsAmount > 1 then
					NewEngine2 = Object.Spawn("Limo2EngineOnTruck",this.Pos.x,0)
					Set(NewEngine2,"CraneUID",this.HomeUID)
					rndNumber=math.random(0,10)
					if rndNumber>=6 then Set(NewEngine2,"SubType",1) end
					
					Set(newTruckSkin,"Slot4.i",Get(NewEngine2,"Id.i"))
					Set(newTruckSkin,"Slot4.u",Get(NewEngine2,"Id.u"))
					Set(NewEngine2,"CarrierId.i",Get(newTruckSkin,"Id.i"))
					Set(NewEngine2,"CarrierId.u",Get(newTruckSkin,"Id.u"))
					Set(NewEngine2,"Loaded",true)
				end
				Set(newEngineTruck,"PartsSpawned",true)
				Set(newEngineTruck,"Number",999)
			end
		end
	end
end

function toggleCraneSpeedClicked()
	if not Exists(MyCrane) then FindMyCrane() end
	if MyCrane.CraneSpeed == 1.5 then
		Set(MyCrane,"CraneSpeed",2.75)
	elseif MyCrane.CraneSpeed == 2.75 then
		Set(MyCrane,"CraneSpeed",4)
	else
		Set(MyCrane,"CraneSpeed",1.5)
	end
	this.SetInterfaceCaption("toggleCraneSpeed", "tooltip_button_cranespeed","tooltip_cranespeed_"..MyCrane.CraneSpeed,"X")
end

function GateIsClosed(theNr)
	if not Exists(MyRepairedLimoGate) then FindMyGates() end
	--if MyTrafficLight == nil or MyTrafficLight.SubType == nil then FindMyTrafficLight() end
	if not Exists(MyMarker) then
		--print("roadmarker was not found")
		FindMyRoadMarker()
		return false
	end
	
	if Get(MyRepairedLimoGate,"GatePosition") == nil then return false end
	
	if Get(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition")) == "no" and Get(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition")) == "none" then
		--print("Gate: Authorizing Repair Spot "..theNr)
		Set(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition"),"Repair Spot "..theNr)
		Set(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition"),this.HomeUID)
		Set(MyMarker,"CloseGate"..Get(MyRepairedLimoGate,"GatePosition"),"yes")
		Set(MyRepairedLimoGate,"Mode",1)
		return true
	elseif Get(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition")) == this.HomeUID and Get(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition")) == "Repair Spot "..theNr then
		--print("Gate: Authorized Repair Spot "..theNr.." OK")
		return true
	else
		--print("Gate: "..Get(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition")).." is not Repair Spot "..theNr)
		return false
	end
end

function Create()
	Set(this,"Limo0ID","None")
	Set(this,"Limo1ID","None")
	Set(this,"Limo2ID","None")
	Set(this,"Limo3ID","None")
	Set(this,"Limo4ID","None")
	Set(this,"Limo5ID","None")
	Set(this,"Limo6ID","None")
	Set(this,"Limo7ID","None")
	Set(this,"Limo8ID","None")
	Set(this,"Limo9ID","None")
	Set(this,"Limo10ID","None")
	Set(this,"Limo11ID","None")
	Set(this,"Limo12ID","None")
	Set(this,"Limo13ID","None")
	Set(this,"Limo14ID","None")
	Set(this,"Limo15ID","None")
end

function EnginesInPartsRack(LimoNr)
	local AvailableEngines = 0
	if not Exists(MyRack) then FindMyRack() end
	for j=0,7 do
		if Get(MyRack,"Slot"..j..".i") ~= -1 and not Get(MyRack,"Slot"..j.."Reserved") then
			Set(MyRack,"Slot"..j.."Reserved","Limo "..LimoNr+1)
			--print("MyRack slot "..j.." has engine")
			AvailableEngines = AvailableEngines+1
			break
		end
	end
	--print("AvailableEngines: "..AvailableEngines)
	return AvailableEngines
end

function CheckAvailableEngineSlots(theCar,theNr)
	--print("CheckAvailableEngineSlots for lesson"..theNr)
	local AvailableEngineSlots = 0
	if not Exists(MyRack) then FindMyRack() end
	for i=0,7 do
		if Get(MyRack,"Slot"..i..".i") == -1 and not Get(MyRack,"Slot"..i.."Reserved") then
			Set(MyRack,"Slot"..i.."Reserved","Lesson "..theNr)
			--print("MyRack slot "..i.." now reserved for lesson car" ..theNr)
			AvailableEngineSlots = AvailableEngineSlots+1
			break
		end
	end
	if AvailableEngineSlots > 0 then
		--print("Lesson"..theNr..": Place engine in rack")
		Set(this,"BringToRack"..theNr,true)
		Set(this,"ttLessonSlot"..theNr,"Place engine in rack")
		Set(theCar,"EngineDamage",nil)
		Set(theCar,"CountDown",false)
		--Set(theCar,"EngineJobIssued",false)
	else
		--print("Lesson"..theNr..": rack full, RemoveEngine2 job issued")
		Object.CreateJob(theCar,"RemoveEngine2")
		Set(this,"ttLessonSlot"..theNr,"Remove engine")
		Set(theCar,"EngineDamage",nil)
		Set(theCar,"CountDown",false)
		--Set(theCar,"EngineJobIssued",false)
	end
end

function CheckCarStatus(theCar,theNr)
	if theCar.Type == "Limo2OnFloor" then
		--print("CheckCarStatus of "..theCar.Type.." "..(theNr+1))
		if theCar.SpotType == "Repair" then
			if theCar.HoodOpen == false then
				--print("Limo"..(theNr+1)..": hood not opened yet")
				Set(this,"ttSlot"..theNr,"Repair in progress")
				Object.CreateJob(theCar,"OpenHood2")
			elseif theCar.CountDown == true then
				--print("Limo"..(theNr+1)..": hood is open, countdown active")
				--if not Get(theCar,"EngineJobIssued") and theCar.EngineDamage ~= nil and theCar.EngineDamage > 0 then
				if theCar.EngineDamage ~= nil and theCar.EngineDamage > 0 then
					Set(this,"ttSlot"..theNr,"Engine damage: "..(tonumber(string.sub(theCar.EngineDamage,0,4))*100).."%")
					if theCar.EngineDamage == 0.69 then
						--print("Limo"..(theNr+1)..": RemoveEngine2 job issued, damage is "..theCar.EngineDamage)
						Object.CreateJob(theCar,"RemoveEngine2")
					else
						--print("Limo"..(theNr+1)..": RepairEngine2 job issued, damage is "..theCar.EngineDamage)
						Object.CreateJob(theCar,"RepairEngine2")
						--print("RepairEngine2")
					end
					--Set(theCar,"EngineJobIssued",true)
				end
			elseif theCar.NeedEngine == true then
				--print("Limo"..(theNr+1)..": needs new engine")
				if EnginesInPartsRack(theNr) > 0 then
					--print("CheckAvailableEngines for limo"..(theNr+1))
					--print("Set crane: BringEngine"..(theNr+1))
					Set(this,"ttSlot"..theNr,"Place engine in limo "..(theNr+1))
					--Set(this,"ttSlot"..theNr,"Refurbish in progress")
					Set(this,"BringEngine"..theNr,true)
					Set(theCar,"NeedEngine",false)
				else
					Set(this,"ttSlot"..theNr,"Requesting new engine")
					Set(this,"BringEngine"..theNr,false)
				end
				--CheckAvailableEngines(theCar,theNr)
			elseif theCar.CloseHood == true and not Get(theCar,"CloseHoodIssued") then
				--print("Limo"..(theNr+1)..": close hood")
				Set(this,"ttSlot"..theNr,"Repaired, close hood and write bill...")
				Object.CreateJob(theCar,"CloseHood2")
				Set(theCar,"CloseHoodIssued",true)
			end
		elseif not Get(theCar,"PaintJobIssued") then	-- paint the car
			Object.CreateJob(theCar,"PaintCar2")
			Set(this,"ttSlot"..theNr,"Painting in progress")
			Set(theCar,"PaintJobIssued",true)
		else
			if theCar.PaintJobPercentageDone == nil then Set(theCar,"PaintJobPercentageDone",0) end
			--print("Limo"..(theNr+1)..": PaintCar2 job issued, progress is "..theCar.PaintJobPercentageDone)
			Set(this,"ttSlot"..theNr,"Paint job: "..theCar.PaintJobPercentageDone.."%")
		end
	elseif theCar.Type == "Limo2Lesson" then
		if Get(theCar,"CountDown") == true then
			--print("CheckCarStatus of "..theCar.Type.." "..theNr)
			--if Get(theCar,"EngineJobIssued") == false and theCar.EngineDamage > 0 then
			if theCar.EngineDamage > 0 then
				--print("Lesson"..(theNr)..": RefurbishEngine2 job issued, damage is "..theCar.EngineDamage)
				Set(this,"ttLessonSlot"..theNr,"Engine damage: "..(tonumber(string.sub(theCar.EngineDamage,0,4))*100).."%")
				Object.CreateJob(theCar,"RefurbishEngine2")
				--Set(theCar,"EngineJobIssued",true)
			end
		elseif Get(theCar,"CountDown") == false and Get(theCar,"EngineDamage") == 0 then
			--print("CheckCarStatus of "..theCar.Type.." "..theNr)
			--print("Lesson"..(theNr)..": checking space in rack")
			CheckAvailableEngineSlots(theCar,theNr)
			Set(theCar,"EngineDamage",nil)
		--elseif theCar.Slot0.i == -1 and Get(this,"ttLessonSlot"..theNr) ~= "Empty Lesson Spot" and Get(this,"ttLessonSlot"..theNr) ~= "Waiting for engine..." then
		--	Set(this,"ttLessonSlot"..theNr,"Empty Lesson Spot")
		end
	end
end

function ResetSpot(theNr)
	--print("===Limo"..(theNr+1).." not available, clean up===")
	--print("RemoveLeftOverEngine"..(theNr+1))
	local nearbyObject = Find("Limo2Engine",50)
	if next(nearbyObject) then
		for thatEngine, dist in pairs(nearbyObject) do
			if Get(thatEngine,"CraneUID") == this.HomeUID and Get(thatEngine,"SlotNr") == theNr then
				thatEngine.Delete()
				--print("Engine"..(theNr+1).." deleted")
				break
			end
		end
	end
	local nearbyObject = Find("Limo2EngineInCar",50)
	if next(nearbyObject) then
		for thatEngine, dist in pairs(nearbyObject) do
			if Get(thatEngine,"CraneUID") == this.HomeUID and Get(thatEngine,"SlotNr") == theNr then
				thatEngine.Delete()
				--print("Engine"..(theNr+1).." deleted")
				break
			end
		end
	end
	nearbyObject = nil
	Set(this,"Limo"..theNr.."ID","None")
	Set(this,"UnloadSlot"..theNr,false)
	Set(this,"BringEngine"..theNr,false)
	Set(this,"PutEngineInLessonCar"..theNr,false)
	if Get(this,"SpotType"..theNr) == "Repair" then
		Set(this,"ttSlot"..theNr,"Empty Repair Spot")
	elseif Get(this,"SpotType"..theNr) == "Paint" then
		Set(this,"ttSlot"..theNr,"Empty Paint Spot")
	else
		Set(this,"ttSlot"..theNr,"Alien Spot")
	end
end

function CheckCars()
	--print("CheckCars")
	if not Exists(Limo0) and this.Limo0ID ~= "None" and this.Slot0X ~= nil then		 ResetSpot(0)	elseif Exists(Limo0) then CheckCarStatus(Limo0,0) end
	if not Exists(Limo1) and this.Limo1ID ~= "None" and this.Slot1X ~= nil then		 ResetSpot(1)	elseif Exists(Limo1) then  CheckCarStatus(Limo1,1) end
	if not Exists(Limo2) and this.Limo2ID ~= "None" and this.Slot2X ~= nil then		 ResetSpot(2)	elseif Exists(Limo2) then  CheckCarStatus(Limo2,2) end
	if not Exists(Limo3) and this.Limo3ID ~= "None" and this.Slot3X ~= nil then		 ResetSpot(3)	elseif Exists(Limo3) then  CheckCarStatus(Limo3,3) end
	if not Exists(Limo4) and this.Limo4ID ~= "None" and this.Slot4X ~= nil then		 ResetSpot(4)	elseif Exists(Limo4) then  CheckCarStatus(Limo4,4) end
	if not Exists(Limo5) and this.Limo5ID ~= "None" and this.Slot5X ~= nil then		 ResetSpot(5)	elseif Exists(Limo5) then  CheckCarStatus(Limo5,5) end
	if not Exists(Limo6) and this.Limo6ID ~= "None" and this.Slot6X ~= nil then		 ResetSpot(6)	elseif Exists(Limo6) then  CheckCarStatus(Limo6,6) end
	if not Exists(Limo7) and this.Limo7ID ~= "None" and this.Slot7X ~= nil then		 ResetSpot(7)	elseif Exists(Limo7) then  CheckCarStatus(Limo7,7) end
	if not Exists(Limo8) and this.Limo8ID ~= "None" and this.Slot8X ~= nil then		 ResetSpot(8)	elseif Exists(Limo8) then  CheckCarStatus(Limo8,8) end
	if not Exists(Limo9) and this.Limo9ID ~= "None" and this.Slot9X ~= nil then		 ResetSpot(9)	elseif Exists(Limo9) then  CheckCarStatus(Limo9,9) end
	if not Exists(Limo10) and this.Limo10ID ~= "None" and this.Slot10X ~= nil then	 ResetSpot(10)	elseif Exists(Limo10) then  CheckCarStatus(Limo10,10) end
	if not Exists(Limo11) and this.Limo11ID ~= "None" and this.Slot11X ~= nil then	 ResetSpot(11)	elseif Exists(Limo11) then  CheckCarStatus(Limo11,11) end
	if not Exists(Limo12) and this.Limo12ID ~= "None" and this.Slot12X ~= nil then	 ResetSpot(12)	elseif Exists(Limo12) then  CheckCarStatus(Limo12,12) end
	if not Exists(Limo13) and this.Limo13ID ~= "None" and this.Slot13X ~= nil then	 ResetSpot(13)	elseif Exists(Limo13) then  CheckCarStatus(Limo13,13) end
	if not Exists(Limo14) and this.Limo14ID ~= "None" and this.Slot14X ~= nil then	 ResetSpot(14)	elseif Exists(Limo14) then  CheckCarStatus(Limo14,14) end
	if not Exists(Limo15) and this.Limo15ID ~= "None" and this.Slot15X ~= nil then	 ResetSpot(15)	elseif Exists(Limo15) then  CheckCarStatus(Limo15,15) end
	
	if Exists(Lesson1) then CheckCarStatus(Lesson1,1) end
	if Exists(Lesson2) then CheckCarStatus(Lesson2,2) end
	if Exists(Lesson3) then CheckCarStatus(Lesson3,3) end
	if Exists(Lesson4) then CheckCarStatus(Lesson4,4) end
	if Exists(Lesson5) then CheckCarStatus(Lesson5,5) end
	if Exists(Lesson6) then CheckCarStatus(Lesson6,6) end
	if Exists(Lesson7) then CheckCarStatus(Lesson7,7) end
	if Exists(Lesson8) then CheckCarStatus(Lesson8,8) end
	if Exists(Lesson9) then CheckCarStatus(Lesson9,9) end
	if Exists(Lesson10) then CheckCarStatus(Lesson10,10) end
end

function LoadCars(TypeOfCar)
	--print("LoadCars with type "..TypeOfCar)
	--print("HomeUID: "..this.HomeUID)
	
	local nearbyObject = Find(TypeOfCar,50)
	if next(nearbyObject) then
		local s = 7
		if this.GarageSize == "Tall" or this.GarageSize == "Wide" then s = 15 end
		for j=0,s do
			if Get(this,"Limo"..j.."ID") == nil then	-- for compatibility with prior version
			
				Set(this,"ttSlot"..j,"(something else)")
				--print("old spot "..(j+1).." found, getting info from rails")
				if not Exists(MyCraneRailLeft) then FindMyRails() end
				--print(Get(MyCraneRailLeft,"ttSlot"..j))
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotReserved" then Set(this,"ttSlot"..j,"(not in use)") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotFree" then Set(this,"ttSlot"..j,"Empty Repair Spot") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotLoading" then Set(this,"ttSlot"..j,"Getting car from truck") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_PaintSpotFree" then Set(this,"ttSlot"..j,"Empty Paint Spot") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotInUse" then Set(this,"ttSlot"..j,"Repair in progress") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_PaintSpotInUse" then Set(this,"ttSlot"..j,"Painting in progress") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RequestNewEngine" then Set(this,"ttSlot"..j,"Requesting new engine") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_BringNewEngine" then Set(this,"ttSlot"..j,"Getting a new engine") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_MountNewEngine" then Set(this,"ttSlot"..j,"Mount new engine") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RefurbishEngine" then Set(this,"ttSlot"..j,"Refurbish engine in lesson car") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotDone" then Set(this,"ttSlot"..j,"Repaired, waiting for bill...") end
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotPaid" then Set(this,"ttSlot"..j,"Bill paid, waiting for crane...") end
				
				if Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotFree" or Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_PaintSpotFree" or Get(MyCraneRailLeft,"ttSlot"..j) == "tooltip_RepairSpotReserved" then
					Set(this,"Limo"..j.."ID","None")
				else
					local limoFound = false
					for thatLimo, dist in pairs(nearbyObject) do
						if thatLimo.CraneUID == this.HomeUID and thatLimo.SlotNr == j then
							--print("old Limo"..(j+1).."found, setting Limo"..(j+1).."ID")
							Set(this,"Limo"..j.."ID",thatLimo.Id.i)
							Set(thatLimo,"Tooltip","CraneUID: "..this.HomeUID.."\nCarUID: "..thatLimo.CarUID.."\nRepair Spot: "..(thatLimo.SlotNr+1))
							limoFound = true
							
							--print("load engine")
							local nearbyObject = Find(thatLimo,"Limo2EngineInCar",1)
							if next(nearbyObject) then
								for thatEngine, dist in pairs(nearbyObject) do
									--print("Limo2EngineInCar found at distance "..dist)
									if Get(thatEngine,"CarUID") == Get(thatLimo,"CarUID") then
										thatEngine.Tooltip = { "tooltip_limo2engine",thatEngine.CarUID,"X",thatEngine.SlotNr+1,"Y" }
										if Get(thatEngine,"Damage") < 0.1 then Set(thatLimo,"EngineDamage",0) else Set(thatLimo,"EngineDamage",thatEngine.Damage) Set(this,"ttSlot"..j,"Engine damage: "..(tonumber(string.sub(thatLimo.EngineDamage,0,4))*100).."%") end
									end
								end
							end
							nearbyObject = nil
							if j == 0 then Limo0 = thatLimo
								elseif j == 1 then Limo1 = thatLimo
								elseif j == 2 then Limo2 = thatLimo
								elseif j == 3 then Limo3 = thatLimo
								elseif j == 4 then Limo4 = thatLimo
								elseif j == 5 then Limo5 = thatLimo
								elseif j == 6 then Limo6 = thatLimo
								elseif j == 7 then Limo7 = thatLimo
								elseif j == 8 then Limo8 = thatLimo
								elseif j == 9 then Limo9 = thatLimo
								elseif j == 10 then Limo10 = thatLimo
								elseif j == 11 then Limo11 = thatLimo
								elseif j == 12 then Limo12 = thatLimo
								elseif j == 13 then Limo13 = thatLimo
								elseif j == 14 then Limo14 = thatLimo
								elseif j == 15 then Limo15 = thatLimo
							end
						end
					end
				end
			elseif Get(this,"Limo"..j.."ID") ~= "None" then
				local limoFound = false
				--print("searching "..TypeOfCar.." "..(j+1))
				for thatLimo, dist in pairs(nearbyObject) do
					if thatLimo.CraneUID == this.HomeUID and thatLimo.Id.i == Get(this,"Limo"..j.."ID") then
						limoFound = true
						--print(TypeOfCar.." "..(j+1).." found")
						--print("load engine")
						local nearbyObject = Find(thatLimo,"Limo2EngineInCar",1)
						if next(nearbyObject) then
							for thatEngine, dist in pairs(nearbyObject) do
								--print("Limo2EngineInCar found at distance "..dist)
								if Get(thatEngine,"CarUID") == Get(thatLimo,"CarUID") then
									thatEngine.Tooltip = { "tooltip_limo2engine",thatEngine.CarUID,"X",thatEngine.SlotNr+1,"Y" }
								end
							end
						end
						nearbyObject = nil
						if j == 0 then Limo0 = thatLimo
							elseif j == 1 then Limo1 = thatLimo
							elseif j == 2 then Limo2 = thatLimo
							elseif j == 3 then Limo3 = thatLimo
							elseif j == 4 then Limo4 = thatLimo
							elseif j == 5 then Limo5 = thatLimo
							elseif j == 6 then Limo6 = thatLimo
							elseif j == 7 then Limo7 = thatLimo
							elseif j == 8 then Limo8 = thatLimo
							elseif j == 9 then Limo9 = thatLimo
							elseif j == 10 then Limo10 = thatLimo
							elseif j == 11 then Limo11 = thatLimo
							elseif j == 12 then Limo12 = thatLimo
							elseif j == 13 then Limo13 = thatLimo
							elseif j == 14 then Limo14 = thatLimo
							elseif j == 15 then Limo15 = thatLimo
						end
					end
				end
			end
		end
	end
	nearbyObject = nil
end

function FindLessonSpots()
	--print("FindLessonSpots")
	--print("HomeUID: "..this.HomeUID)
	local nearbyObject = Find("Limo2Lesson",50)
	if next(nearbyObject) then
		for j=1,10 do
			if Get(this,"Lesson"..j.."ID") == nil then	-- for compatibility with prior version
				--print("old Lesson spot "..j.." found")
				Set(this,"Lesson"..j.."ID","None")
				Set(this,"ttLessonSlot"..j,"(something else)")
				if Get(this,"LessonSpot"..j.."X") == nil then
					Set(this,"ttLessonSlot"..j,"(not in use)")
				end
				local limoFound = false
				for thatLesson, dist in pairs(nearbyObject) do
					if thatLesson.HomeUID == this.HomeUID and thatLesson.LessonSpot == j then
						--print("setting Lesson"..j.."ID")
						Set(this,"Lesson"..j.."ID",thatLesson.Id.i)
						Set(thatLesson,"Tooltip","CraneUID: "..this.HomeUID.."\nCarUID: "..thatLesson.CarUID.."\nLesson Spot: "..thatLesson.LessonSpot)
						if Get(thatLesson,"SlotReserved") == "yes" then Set(this,"ttLessonSlot"..j,"Waiting for engine...") end
						if Get(thatLesson,"CountDown") == true then Set(this,"ttLessonSlot"..j,"Refurbish in progress") end
						if Get(thatLesson,"CountDown") == false and Get(thatLesson,"EngineJobIssued") == nil then Set(this,"ttLessonSlot"..j,"Empty Lesson Spot") end
						if Get(thatLesson,"CountDown") == false and Get(thatLesson,"EngineJobIssued") == true then Set(this,"ttLessonSlot"..j,"Engine refurbished") end
						--print("load engine")
						local nearbyObject = Find(thatLesson,"Limo2EngineInLessonCar",1)
						if next(nearbyObject) then
							for thatEngine, dist in pairs(nearbyObject) do
								--print("Limo2EngineInLessonCar found at distance "..dist)
								if Get(thatEngine,"CarUID") == Get(thatLesson,"CarUID") then
									thatEngine.Tooltip = { "tooltip_limo2engine",thatEngine.CarUID,"X",thatEngine.LessonSpot,"Y" }
									if not Get(thatEngine,"Damage") or Get(thatEngine,"Damage") < 0.1 then Set(thatLesson,"EngineDamage",0) else Set(thatLesson,"EngineDamage",thatEngine.Damage) Set(this,"ttLessonSlot"..j,"Engine damage: "..(tonumber(string.sub(thatLesson.EngineDamage,0,4))*100).."%") end
								end
							end
						end
						nearbyObject = nil
						if j == 1 then Lesson1 = thatLesson
							elseif j == 2 then Lesson2 = thatLesson
							elseif j == 3 then Lesson3 = thatLesson
							elseif j == 4 then Lesson4 = thatLesson
							elseif j == 5 then Lesson5 = thatLesson
							elseif j == 6 then Lesson6 = thatLesson
							elseif j == 7 then Lesson7 = thatLesson
							elseif j == 8 then Lesson8 = thatLesson
							elseif j == 9 then Lesson9 = thatLesson
							elseif j == 10 then Lesson10 = thatLesson
						end
						limoFound = true
					end
				end
			elseif Get(this,"Lesson"..j.."ID") ~= "None" then
				local limoFound = false
				--print("searching Lesson "..j)
				for thatLesson, dist in pairs(nearbyObject) do
					if thatLesson.HomeUID == this.HomeUID and thatLesson.Id.i == Get(this,"Lesson"..j.."ID") then
						limoFound = true
						--print("Lesson "..j.." found")
						local nearbyObject = Find(thatLesson,"Limo2EngineInLessonCar",1)
						if next(nearbyObject) then
							for thatEngine, dist in pairs(nearbyObject) do
								--print("Limo2EngineInLessonCar found at distance "..dist)
								if Get(thatEngine,"CarUID") == Get(thatLesson,"CarUID") then
									thatEngine.Tooltip = { "tooltip_limo2engine",thatEngine.CarUID,"X",thatEngine.LessonSpot,"Y" }
								end
							end
						end
						nearbyObject = nil
						if j == 1 then Lesson1 = thatLesson
							elseif j == 2 then Lesson2 = thatLesson
							elseif j == 3 then Lesson3 = thatLesson
							elseif j == 4 then Lesson4 = thatLesson
							elseif j == 5 then Lesson5 = thatLesson
							elseif j == 6 then Lesson6 = thatLesson
							elseif j == 7 then Lesson7 = thatLesson
							elseif j == 8 then Lesson8 = thatLesson
							elseif j == 9 then Lesson9 = thatLesson
							elseif j == 10 then Lesson10 = thatLesson
						end
					end
				end
			end
		end
	end
	nearbyObject = nil
end

function Update(timePassed)
	if timePerUpdate==nil then
		if Get(this,"FloorMade") == true then
			Set(this,"ErrorLog"," ")
			FindMyCrane()
			FindMyRack()
			FindMyDesk()
			FindMyRoadMarker()
			FindMyGates()
			FindMyLimoTruck()
			FindMyPartsTruck()
			if not this.TrafficLightUpgradeV2 then
				UpgradeTrafficLight()
				Set(this,"TrafficLightUpgradeV2",true)
			end
			if this.ShowLimo2BoothInfo == nil then
				Set(this,"ShowLimo2BoothInfo","Yes")
				Set(this,"ShowLimo2CraneInfo","No")
				Set(this,"ShowLimo2HookInfo","No")
				Set(this,"ShowLimo2RackInfo","No")
				Set(this,"ShowLimo2TruckInfo","No")
			end
			FindLessonSpots()
			--print("loading cars at startup")
			LoadCars("Limo2OnFloor")
			Set(this,"LoadNewCars",false)
			LoadCars("Limo2Repaired")
			Set(this,"LoadRepairedCars",false)
			FindMyLimo2RepairedOnRoad()
			CheckCars()
			Interface.AddComponent(this,"DismantleAll", "Button", "tooltip_Button_DeleteGarage")
			Interface.AddComponent(this,"Caption_separator2", "Caption", "tooltip_Caption_GarageSetup")
			Interface.AddComponent(this,"MakeRoad", "Button", "tooltip_Button_MakeRoad")
			Interface.AddComponent(this,"ShowRepairSpots", "Button", "tooltip_Button_ShowRepairSpots")
			Interface.AddComponent(this,"toggleCraneSpeed", "Button", "tooltip_button_cranespeed","tooltip_cranespeed_"..MyCrane.CraneSpeed,"X")
			Interface.AddComponent(this,"Caption_separator1", "Caption", "tooltip_Caption_GarageTools")
			Interface.AddComponent(this,"ResetGates", "Button", "tooltip_Button_ResetGate")
			Interface.AddComponent(this,"UnloadTruck", "Button", "tooltip_Button_UnloadTruck")
			Interface.AddComponent(this,"ClearErrorLogs", "Button", "tooltip_Button_ClearErrorLogs")
			Interface.AddComponent(this,"ResetTheGarage", "Button", "tooltip_Button_ResetGarage")
			Interface.AddComponent(this,"Caption_separator3", "Caption", "tooltip_Caption_GarageTooltipInfo")
			Interface.AddComponent(this,"toggleBoothTooltip", "Button", "tooltip_ShowLimo2BoothInfo",this.ShowLimo2BoothInfo,"X")
			Interface.AddComponent(this,"toggleRackTooltip", "Button", "tooltip_ShowLimo2RackInfo",this.ShowLimo2RackInfo,"X")
			Interface.AddComponent(this,"toggleCraneTooltip", "Button", "tooltip_ShowLimo2CraneInfo",this.ShowLimo2CraneInfo,"X")
			Interface.AddComponent(this,"toggleHookTooltip", "Button", "tooltip_ShowLimo2HookInfo",this.ShowLimo2HookInfo,"X")
			Interface.AddComponent(this,"toggleTruckTooltip", "Button", "tooltip_ShowLimo2TruckInfo",this.ShowLimo2TruckInfo,"X")
			
			BuildTooltip("Initialising")
			
			timePerUpdate = 0.5 / this.TimeWarp
		else
			return
		end
	end
	
	timeTot=timeTot+timePassed
	if timeTot>=timePerUpdate then
		timeTot=0
		if not Get(this,"RoadMade") then
			MakeRoadClicked()
			Set(this,"RoadMade",true)
		end
		
		-- if not Exists(MyMarker) or MyMarker.GarageTraffic == nil then FindMyRoadMarker() return end
		if not Exists(MyMarker) then FindMyRoadMarker() return end
		if not Exists(MyRepairedLimoGate) then FindMyGates() return end
		
		if Get(this,"LoadNewCars") == true then
			--print("Load new cars requested by hook")
			LoadCars("Limo2OnFloor")
			Set(this,"LoadNewCars",false)
		end
		if Get(this,"LoadRepairedCars") == true then
			--print("Load repaired cars requested by limo")
			LoadCars("Limo2Repaired")
			Set(this,"LoadRepairedCars",false)
		end
		
		CheckCars()
		
		
		if this.Timer < 1 then
			BuildTooltip(this.CurrentTask)
		end
		
		this.TimeToOrderLimoTruck=this.TimeToOrderLimoTruck+(timePerUpdate / this.TimeWarp)
		if this.TimeToOrderLimoTruck >= this.TruckTimerLimo then
			Set(this,"TimeToOrderLimoTruck",0)
			Set(this,"TruckTimerLimo",math.random(10,20)+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
			--print("Order limo truck...")
			if not Exists(newLimoTruck) then
				newLimoTruck = nil
				--print("No limotruck found...")
				Set(this,"LimoTruckArriving","no")
			end
			if Get(this,"LimoTruckArriving") == "no" and Get(this,"PartsTruckArriving") == "no" and Get(this,"GarageIsFull") == "no" then
				--print("limo truck arriving")
				Set(this,"LimoTruckArriving","yes")
				Set(this,"TimeToOrderLimoTruck",0)
				Set(this,"TruckTimerLimo",math.random(60,360)+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
				--print("order limotruck now")
				CheckOrder("limo")
			end
		end
		
		if rackFound == true then
			this.TimeToOrderPartsTruck=this.TimeToOrderPartsTruck+(timePerUpdate / this.TimeWarp)
			if this.TimeToOrderPartsTruck >= this.TruckTimerParts then
				Set(this,"TimeToOrderPartsTruck",0)
				Set(this,"TruckTimerParts",math.random(10,20)+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
				--print("Order parts truck...")
				if not Exists(newEngineTruck) then
					newEngineTruck = nil
					--print("No partstruck found...")
					Set(this,"PartsTruckArriving","no")
				end
				if Get(this,"PartsTruckArriving") == "no" and Get(this,"LimoTruckArriving") == "no" and Get(this,"PartsRackIsFull") == "no" then
					--print("parts truck arriving")
					Set(this,"PartsTruckArriving","yes")
					Set(this,"TimeToOrderPartsTruck",0)
					Set(this,"TruckTimerParts",math.random(60,360)+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
					--print("order partstruck now")
					CheckOrder("parts")
				end
			end
		end
		
		if Get(this,"BusyDoingJob") == false then
							-- put a repaired car back on the road
			for i=0,15 do
				if Get(this,"UnloadSlot"..i) == true and Get(this,"LimoWaitingOnRoad") == "no" and GateIsClosed(i+1) == true then
					timePerUpdate = 1 / this.TimeWarp
					if not Get(this,"OrderSpawned") then
						NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
						Set(this,"Slot1.i",NewOrder.Id.i)
						Set(this,"Slot1.u",NewOrder.Id.u)
						Set(this,"Timer",0)
						NewOrder.Loaded = true
						NewOrder.Hidden = true
						Set(this,"OrderSpawned",true)
					end
					if this.Timer > 1 then
						this.SubType = 1
						Set(MyCrane,"GiveJob","GrabLimoFromFloor")
						Set(MyHook,"SlotNr",i)
						Set(MyCrane,"MoveToX",Get(this,"Slot"..i.."X"))
						Set(MyCrane,"MoveToY",Get(this,"Slot"..i.."Y"))
						Set(MyCrane,"MoveTheCrane",true)
						Set(this,"BusyDoingJob",true)
						BuildTooltip("tooltip_Placingrepairedlimo"..i)
					end
					return
				end
			end
							-- unload first car from truck and put it in a free car spot
			if Get(this,"UnloadTruckSlot0") == true and Get(this,"GarageIsFull") == "no" then
				timePerUpdate = 1 / this.TimeWarp
				if not Get(this,"OrderSpawned") then
					NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
					Set(this,"Slot1.i",NewOrder.Id.i)	-- spawn something into the Processor, so it gets a Timer which can be read out
					Set(this,"Slot1.u",NewOrder.Id.u)	-- when creating a job via Object.CreateJob() the booth would not get a Timer, so that would not work in this case, hence this very creative usage of a Processor instead of a normal job.
					Set(this,"Timer",0)					-- Reset the operating Timer to 0
					NewOrder.Loaded = true
					NewOrder.Hidden = true		-- don't need to see this stuff
					Set(this,"OrderSpawned",true)
				end
				if this.Timer > 1 then	-- when the Timer is running, it means the Processor is operated by someone, so the crane can start moving
					this.SubType = 1		-- light up its display to show its operating
					Set(MyCrane,"GiveJob","GrabLimoFromTruck")
					Set(MyHook,"TruckSlotNr",0)
					FindCargoOnTruck("Limo2Broken",0)
					Set(MyCrane,"MoveToX",Get(this,"Truck0X"))
					Set(MyCrane,"MoveToY",Get(this,"Truck0Y"))
					--print("Moving hook to x: "..this.Truck0X.." y: "..this.Truck0Y)
					Set(MyCrane,"MoveTheCrane",true)
					Set(this,"BusyDoingJob",true)
					BuildTooltip("tooltip_FetchingLimofromTowTruckspot1")
				end
							-- then unload second car from truck and load it into a free slot
			elseif Get(this,"UnloadTruckSlot1") == true and Get(this,"GarageIsFull") == "no" then
				timePerUpdate = 1 / this.TimeWarp
				if not Get(this,"OrderSpawned") then
					NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
					Set(this,"Slot1.i",NewOrder.Id.i)
					Set(this,"Slot1.u",NewOrder.Id.u)
					Set(this,"Timer",0)
					NewOrder.Loaded = true
					NewOrder.Hidden = true
					Set(this,"OrderSpawned",true)
				end
				if this.Timer > 1 then
					this.SubType = 1
					Set(MyCrane,"GiveJob","GrabLimoFromTruck")
					Set(MyHook,"TruckSlotNr",1)
					FindCargoOnTruck("Limo2Broken",1)
					Set(MyCrane,"MoveToX",Get(this,"Truck1X"))
					Set(MyCrane,"MoveToY",Get(this,"Truck1Y"))
					--print("Moving hook to x: "..this.Truck1X.." y: "..this.Truck1Y)
					Set(MyCrane,"MoveTheCrane",true)
					Set(this,"BusyDoingJob",true)
					BuildTooltip("tooltip_FetchingLimofromTowTruckspot2")
				end
				
							-- unload car engine from truck and load it into carpartsrack
			elseif Get(this,"UnloadEngineSlot0") == true and Get(this,"PartsRackIsFull") == "no" then
				timePerUpdate = 1 / this.TimeWarp
				if not Get(this,"OrderSpawned") then
					NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
					Set(this,"Slot1.i",NewOrder.Id.i)
					Set(this,"Slot1.u",NewOrder.Id.u)
					Set(this,"Timer",0)
					NewOrder.Loaded = true
					NewOrder.Hidden = true
					Set(this,"OrderSpawned",true)
				end
				if this.Timer > 1 then
					this.SubType = 1
					Set(MyCrane,"GiveJob","GrabEngineFromTruck")
					Set(MyHook,"TruckSlotNr",0)
					FindCargoOnTruck("Limo2EngineOnTruck",0)
					Set(MyCrane,"MoveToX",Get(this,"Truck0X"))
					Set(MyCrane,"MoveToY",Get(this,"Truck0Y"))
					--print("Moving hook to x: "..this.Truck0X.." y: "..this.Truck0Y)
					Set(MyCrane,"MoveTheCrane",true)
					Set(this,"BusyDoingJob",true)
					BuildTooltip("tooltip_FetchingEnginefromTowTruckspot1")
				end

							-- unload car engine from truck and load it into carpartsrack
			elseif Get(this,"UnloadEngineSlot1") == true and Get(this,"PartsRackIsFull") == "no" then
				timePerUpdate = 1 / this.TimeWarp
				if not Get(this,"OrderSpawned") then
					NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
					Set(this,"Slot1.i",NewOrder.Id.i)
					Set(this,"Slot1.u",NewOrder.Id.u)
					Set(this,"Timer",0)
					NewOrder.Loaded = true
					NewOrder.Hidden = true
					Set(this,"OrderSpawned",true)
				end
				if this.Timer > 1 then
					this.SubType = 1
					Set(MyCrane,"GiveJob","GrabEngineFromTruck")
					Set(MyHook,"TruckSlotNr",1)
					FindCargoOnTruck("Limo2EngineOnTruck",1)
					Set(MyCrane,"MoveToX",Get(this,"Truck1X"))
					Set(MyCrane,"MoveToY",Get(this,"Truck1Y"))
					--print("Moving hook to x: "..this.Truck1X.." y: "..this.Truck1Y)
					Set(MyCrane,"MoveTheCrane",true)
					Set(this,"BusyDoingJob",true)
					BuildTooltip("tooltip_FetchingEnginefromTowTruckspot2")
				end
				
			else
							-- or grab damaged engine from car and put it in lesson car
				for i=0,15 do
					if Get(this,"PutEngineInLessonCar"..i) == true then
						timePerUpdate = 1 / this.TimeWarp
						if not Get(this,"OrderSpawned") then
							NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
							Set(this,"Slot1.i",NewOrder.Id.i)
							Set(this,"Slot1.u",NewOrder.Id.u)
							Set(this,"Timer",0)
							NewOrder.Loaded = true
							NewOrder.Hidden = true
							Set(this,"OrderSpawned",true)
						end
						if this.Timer > 1 then
							this.SubType = 1
							Set(MyCrane,"GiveJob","GrabEngineFromCar")
							Set(MyHook,"SlotNr",i)
							Set(MyCrane,"MoveToX",Get(this,"Slot"..i.."X"))
							Set(MyCrane,"MoveToY",Get(this,"Slot"..i.."Y")+1.17)
							Set(MyCrane,"MoveTheCrane",true)
							Set(this,"BusyDoingJob",true)
							BuildTooltip("tooltip_Placingenginefromlimo"..i)
						end
						return
					end
				end

							-- or grab engine from lesson car and put it into rack
				for i=1,10 do
					if Get(this,"BringToRack"..i) == true then
						timePerUpdate = 1 / this.TimeWarp
						if not Get(this,"OrderSpawned") then
							NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
							Set(this,"Slot1.i",NewOrder.Id.i)
							Set(this,"Slot1.u",NewOrder.Id.u)
							Set(this,"Timer",0)
							NewOrder.Loaded = true
							NewOrder.Hidden = true
							Set(this,"OrderSpawned",true)
						end
						if this.Timer > 1 then
							this.SubType = 1
							Set(MyCrane,"GiveJob","BringEngineToRack")
							Set(MyHook,"SlotNr",i)
							Set(MyCrane,"MoveToX",Get(this,"LessonSpot"..i.."X"))
							Set(MyCrane,"MoveToY",Get(this,"LessonSpot"..i.."Y")+1.17)
							Set(MyCrane,"MoveTheCrane",true)
							Set(this,"BusyDoingJob",true)
							BuildTooltip("tooltip_Placingenginefromlessoncar"..i)
						end
						return
					end
				end

							-- or grab engine from rack and put it into a car
				for i=0,15 do
					if Get(this,"BringEngine"..i) == true then --and EnginesInPartsRack() > 0 then
						timePerUpdate = 1 / this.TimeWarp
						if not Get(this,"OrderSpawned") then
							NewOrder = Object.Spawn("GantryCrane2BoothOrder",this.Pos.x,this.Pos.y)
							Set(this,"Slot1.i",NewOrder.Id.i)
							Set(this,"Slot1.u",NewOrder.Id.u)
							Set(this,"Timer",0)
							NewOrder.Loaded = true
							NewOrder.Hidden = true
							Set(this,"OrderSpawned",true)
						end
						if this.Timer > 1 then
							this.SubType = 1
							if not Exists(MyRack) then FindMyRack() end
							Set(MyCrane,"GiveJob","GrabEngineFromRack")
							Set(MyHook,"SlotNr",i)
							Set(MyCrane,"MoveToX",MyRack.Pos.x-1.5)
							Set(MyCrane,"MoveToY",MyRack.Pos.y)
							Set(MyCrane,"MoveTheCrane",true)
							Set(this,"BusyDoingJob",true)
							BuildTooltip("tooltip_Fetchengineforlimo"..i)
						end
						return
					elseif Get(this,"BringEngine"..i) == true and EnginesInPartsRack(i) == 0 then
						Set(this,"ttSlot"..i,"Requesting new engine")
						Set(this,"BringEngine"..i,false)
					end
				end
			end
		else
			Set(this,"OrderSpawned", nil)
			timeTot = 0
			timePerUpdate = 0.5 / this.TimeWarp
		end
		
	end
end

function FindCargoOnTruck(theCargo,theSlotNr)
	local TrucksProcessing = {}
	local TruckSkins = {}
	local CargoToProcess = {}
	cargoLimoFound = false
	cargoEngineFound = false
	truckProcessingFound = false
	TrucksProcessing = Find("CargoStationTruck",50)
	if next(TrucksProcessing) then
		for thatTruck, distance in pairs(TrucksProcessing) do
			if thatTruck.CraneUID == this.HomeUID and thatTruck.VehicleState == "ProcessingGarage" then
				if theCargo == "Limo2Broken" then
					TruckSkins = Find(thatTruck,"LimoTowTruckSkin",10)
				else
					TruckSkins = Find(thatTruck,"CarPartsTowTruckSkin",10)
				end
				if next(TruckSkins) then
					for thatSkin, dist in pairs(TruckSkins) do
						if thatSkin.HomeUID == thatTruck.HomeUID then
							MyTruckSkin = thatSkin
							print(MyTruckSkin.Type.." found at distance "..dist)
							break
						end
					end
				end
				MyProcessingTruck=thatTruck
				print(MyProcessingTruck.HomeUID.." found at distance "..distance)
				truckProcessingFound = true
				break
			end
		end
	end
	TrucksProcessing = nil
	if truckProcessingFound == true then
		CargoToProcess = Find(MyTruckSkin,theCargo,5)
		for thatCargo, distance in pairs(CargoToProcess) do
			--print(thatCargo.Type.." found at distance "..distance)
			if theCargo == "Limo2Broken" and Get(thatCargo,"Id.i") == Get(MyTruckSkin,"Slot"..(theSlotNr+3)..".i") then
				Set(this,"Truck"..theSlotNr.."X",thatCargo.Pos.x)
				Set(this,"Truck"..theSlotNr.."Y",thatCargo.Pos.y-0.75)
				--print("Limo2Broken "..theSlotNr.." found")
				cargoLimoFound = true
				break
			elseif theCargo == "Limo2EngineOnTruck" and Get(thatCargo,"Id.i") == Get(MyTruckSkin,"Slot"..(theSlotNr+3)..".i") then
				Set(this,"Truck"..theSlotNr.."X",thatCargo.Pos.x)
				Set(this,"Truck"..theSlotNr.."Y",thatCargo.Pos.y-0.17)
				--print("Limo2EngineOnTruck "..theSlotNr.." found")
				cargoEngineFound = true
				break
			end
		end
		--if theCar == "Limo2Broken" and cargoLimoFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Limo cargo "..theSlotNr.." not found.") end
		--if theCar == "Limo2EngineOnTruck" and cargoEngineFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  Engine cargo "..theSlotNr.." not found.") end
		CargoToProcess = nil
		MyTruckSkin = nil
		MyProcessingTruck = nil
	else
		Set(this,"ErrorLog",this.ErrorLog.."\n |  Processing truck not found.")
	end	
end

function UnloadTruckClicked()
	FindCargoOnTruck("Limo2Broken",0) if cargoLimoFound == true then Set(this,"UnloadTruckSlot0",true) end
	FindCargoOnTruck("Limo2Broken",1) if cargoLimoFound == true then Set(this,"UnloadTruckSlot1",true) end
	FindCargoOnTruck("Limo2EngineOnTruck",0) if cargoEngineFound == true then Set(this,"UnloadEngineSlot0",true) end
	FindCargoOnTruck("Limo2EngineOnTruck",1) if cargoEngineFound == true then Set(this,"UnloadEngineSlot1",true) end
end

function BuildTooltip(CurrentTask)
	--print("BuildTooltip")
	if Exists(MyDesk) then Set(MyDesk,"BuildTooltip",CurrentTask) end
end





function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end





-------------------

function ShowRepairSpotsClicked()
	for i = 0,15 do
		if Get(this,"Slot"..i.."X") ~= nil then
			if Get(this,"SpotType"..i) == "Repair" then
				MakeCarSpotsFloor(Get(this,"Slot"..i.."X")-1,Get(this,"Slot"..i.."Y")-1)
			end
			newNumber = Object.Spawn("Nr"..(i+1),Get(this,"Slot"..i.."X"),Get(this,"Slot"..i.."Y")+1.9275)
			Set(newNumber,"HomeUID",this.HomeUID)
		end
	end
	for i = 1,10 do
		if Get(this,"LessonSpot"..i.."X") ~= nil then
			MakeLessonCarFloor(Get(this,"LessonSpot"..i.."X")-1,Get(this,"LessonSpot"..i.."Y")+1)
			newNumber = Object.Spawn("Nr"..i,Get(this,"LessonSpot"..i.."X"),Get(this,"LessonSpot"..i.."Y")+1.9275)
			Set(newNumber,"HomeUID",this.HomeUID)
		end
	end
end

function MakeRoadClicked()
	local x = math.floor(this.ParkX-1)
	local y = math.floor(this.ParkY+this.Ymin-1)
	local cell = World.GetCell(x-1,y)
	if this.GaragePlacement == "Left" then
		for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
			cell = World.GetCell(x-1,y+i)	cell.Mat = "ConcreteTiles";		cell.Ind = true
			cell = World.GetCell(x,y+i)		cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x+1,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			cell = World.GetCell(x+2,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x+3,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
		end
		if this.RoadSize == "Double" then
			for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
				cell = World.GetCell(x-4,y+i)	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
				cell = World.GetCell(x-3,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
				cell = World.GetCell(x-2,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			end
		end
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))-4)	cell.Mat = "innerdiagroadTR";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-4)	cell.Mat = "diagsidewalkTR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-4)	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))-3)	cell.Mat = "Road";				cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";				cell.Ind = true
		cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";				cell.Ind = true
		cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-3)	cell.Mat = "innerdiagroadTR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-3)	cell.Mat = "diagsidewalkTR";	cell.Ind = true
		
		cell = World.GetCell(x,y+math.floor((-this.Ymin)))		cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin)))	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTR";	cell.Ind = true
		
		cell = World.GetCell(x+1,y+math.ceil(this.Ymax))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.ceil(this.Ymax+1))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+1))	cell.Mat = "innerdiagroadBR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+1))	cell.Mat = "diagsidewalkBR";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.ceil(this.Ymax+2))	cell.Mat = "innerdiagroadBR";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+2))	cell.Mat = "diagsidewalkBR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+2))	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+3))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+3))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+4))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+4))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+5))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+5))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+6))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+6))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+7))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+7))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
		
		if this.RoadSize == "Double" then
			cell = World.GetCell(x-6,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
			cell = World.GetCell(x-4,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			
			cell = World.GetCell(x-4,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
		else
			cell = World.GetCell(x-3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			
			cell = World.GetCell(x-3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
			cell = World.GetCell(x-2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
		end
	else
		for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
			if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+i)	cell.Mat = "ConcreteTiles";	cell.Ind = true end
			cell = World.GetCell(x-2,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x-1,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			cell = World.GetCell(x,y+i)		cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x+1,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			cell = World.GetCell(x+2,y+i)	cell.Mat = "ConcreteTiles";		cell.Ind = true
		end
		if this.RoadSize =="Double" then
			for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
				cell = World.GetCell(x+3,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
				cell = World.GetCell(x+4,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
				cell = World.GetCell(x+5,y+i)	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
			end
		end
		cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-4)	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-4)	cell.Mat = "diagsidewalkTL";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))-4)	cell.Mat = "innerdiagroadTL";	cell.Ind = true
		cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-3)	cell.Mat = "diagsidewalkTL";	cell.Ind = true
		cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-3)	cell.Mat = "innerdiagroadTL";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))-3)	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";	cell.Ind = true
		
		cell = World.GetCell(x,y+math.floor((-this.Ymin)))		cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin)))	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTR";	cell.Ind = true
		
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x,y+math.ceil(this.Ymax))		cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x,y+math.ceil(this.Ymax+1))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+1))	cell.Mat = "diagsidewalkBL";	cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+1))	cell.Mat = "innerdiagroadBL";	cell.Ind = true
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+2))	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+2))	cell.Mat = "diagsidewalkBL";	cell.Ind = true
		cell = World.GetCell(x,y+math.ceil(this.Ymax+2))	cell.Mat = "innerdiagroadBL";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+3))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+3))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+3))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+4))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+4))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+4))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+5))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+5))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+5))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+6))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+6))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+6))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+7))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+7))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+7))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true

		if this.RoadSize == "Double" then
			cell = World.GetCell(x-3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+5,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+7,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
		
			cell = World.GetCell(x-3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+5,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
		else
			cell = World.GetCell(x-3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
		
			cell = World.GetCell(x-3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
		end
	end
end

function MakeCarSpotsFloor(theX,theY)
	local x = math.floor(theX)
	local y = math.floor(theY)
	local cell = World.GetCell(x,y)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x+1,y+1)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x+1,y+2)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x+1,y+3)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x+1,y)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x,y+1)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x,y+2)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x,y+3)	cell.Mat = "MetalFloor"
end

function MakeLessonCarFloor(theX,theY)
	local x = math.floor(theX)
	local y = math.floor(theY)
	local cell = World.GetCell(x,y)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x+1,y+1)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x+1,y)	cell.Mat = "MetalFloor"
	cell = World.GetCell(x,y+1)	cell.Mat = "MetalFloor"
end

function RemoveBuilding()
	local x = math.floor(this.ParkX)
	local y = math.floor(this.ParkY)
	for i=math.floor(this.Ymin-1),math.ceil(this.Ymax+1) do	for j=this.Xmin-1,this.Xmax+1 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "Dirt"; cell.Ind = false end	end
end

function CleanIndoorBuilding()
	local x = math.floor(this.ParkX)
	local y = math.floor(this.ParkY)
	for i=math.floor(this.Ymin-1),math.ceil(this.Ymax+1) do	for j=this.Xmin-1,this.Xmax+1 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "BrickWall" end	end
	for i=math.floor(this.Ymin),math.ceil(this.Ymax) do		for j=this.Xmin,this.Xmax do		local cell = World.GetCell(x+j,y+i);	cell.Mat = "ConcreteFloor"	end	end
end

function DismantleAllClicked()
	DeleteMyOldStuff()
end

function DeleteMyOldStuff()
	MyMarker.Delete()
	RemoveBuilding()
	GroupOfOldObjects = { "Limo2","Limo2Broken","Limo2OnFloor","Limo2Repaired","Limo2RepairedOnRoad","Limo2OnCrane","GantryRail2SlotFiller","Limo2RepairPapersCopy","Limo2Lesson","Limo2Front","Limo2Engine","Limo2EngineInCar","Limo2EngineInLessonCar","Limo2EngineInRack","Limo2EngineOnTruck","Limo2EngineOnCrane","CarPartsRack2","GantryCrane2","GantryCrane2Hook","GantryCrane2Wheel","GantryCrane2RailRight","GantryCrane2PaintCabin","GantryCrane2Booth","Limo2ServiceDesk","Limo2Driver1","Limo2Driver2","Limo2Driver3","Limo2Driver4","Limo2Driver5","Limo2Driver6","Limo2Driver7","Limo2Driver8","Limo2Driver9","Limo2Driver10","Limo2Driver11","Limo2Driver12","Limo2Driver13","Limo2Driver14","Limo2Driver15","Limo2Driver16","Limo2DriverLeaving","CargoStationTruck","Limo2Papers","Limo2RepairPapers","Limo2Bill1","Limo2Bill2","Limo2Bill3","Limo2Bill4","Limo2Bill5","Limo2Bill6","Limo2Bill7","Limo2Bill8","Limo2Bill9","Limo2Bill10","Limo2Receipt","Nr1","Nr2","Nr3","Nr4","Nr5","Nr6","Nr7","Nr8","Nr9","Nr10","CarMechanic2","CraneOperator2","Limo2FilingCabinet","StaffDoor","Radio","TowTruck2Driver","GantryCrane2BoothOrder","RoadGate2Small","RoadGate2TrafficLightSmall","RoadGate2PostLeftSmall","RoadGate2PostRightSmall","RoadGate2PostLeftLarge","RoadGate2PostRightLarge","RoadGate2PostLeftPoW","RoadGate2PostRightPoW","RoadPoleStart","RoadPoleEnd","SmallRoadPole", "GantryCrane2RailLeft" }
	for _, typ in pairs(GroupOfOldObjects) do
		nearbyObject = Find(typ,500)
		for thatObject, _ in pairs(nearbyObject) do
			if thatObject.Type == "CargoStationTruck" then
				if Get(thatObject,"CraneUID") == this.HomeUID then
					Set(thatObject,"DeleteMe",true)
				end
			elseif Get(thatObject,"HomeUID") == this.HomeUID or Get(thatObject,"CraneUID") == this.HomeUID then
				thatObject.Delete()
			end
		end
		nearbyObject = nil
	end
	this.Delete()
end

function ResetTheGarageClicked()
	GroupOfOldObjects = { "Limo2","Limo2Broken","Limo2OnFloor","Limo2Repaired","Limo2RepairedOnRoad","Limo2OnCrane","CargoStationTruck","GantryRail2SlotFiller","Limo2RepairPapersCopy","Limo2Front","Limo2Engine","Limo2EngineInCar","Limo2EngineInLessonCar","Limo2EngineInRack","Limo2EngineOnTruck","Limo2EngineOnCrane","Limo2Driver1","Limo2Driver2","Limo2Driver3","Limo2Driver4","Limo2Driver5","Limo2Driver6","Limo2Driver7","Limo2Driver8","Limo2Driver9","Limo2Driver10","Limo2Driver11","Limo2Driver12","Limo2Driver13","Limo2Driver14","Limo2Driver15","Limo2Driver16","Limo2DriverLeaving","Limo2Papers","Limo2RepairPapers","Limo2Bill1","Limo2Bill2","Limo2Bill3","Limo2Bill4","Limo2Bill5","Limo2Bill6","Limo2Bill7","Limo2Bill8","Limo2Bill9","Limo2Bill10","Limo2Receipt","Nr1","Nr2","Nr3","Nr4","Nr5","Nr6","Nr7","Nr8","Nr9","Nr10","TowTruck2Driver","GantryCrane2BoothOrder" }
	for _, typ in pairs(GroupOfOldObjects) do
		nearbyObject = Find(typ,50)
		for thatObject, _ in pairs(nearbyObject) do
			if thatObject.Type == "CargoStationTruck" then
				if Get(thatObject,"CraneUID") == this.HomeUID then
					Set(thatObject,"DeleteMe",true)
				end
			elseif Get(thatObject,"HomeUID") == this.HomeUID or Get(thatObject,"CraneUID") == this.HomeUID then
				thatObject.Delete()
			end
		end
		nearbyObject = nil
	end
	
	if Exists(MyRepairedLimoGate) then
		Set(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyRepairedLimoGate,"GatePosition"),"no")
		Set(MyRepairedLimoGate,"Mode",0)
	end
	
	if Exists(MyTopGate1) then
		Set(MyMarker,"RequestFrom"..Get(MyTopGate1,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyTopGate1,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyTopGate1,"GatePosition"),"no")
		Set(MyTopGate1,"Mode",0)
	end
	if Exists(MyTopGate2) then
		Set(MyMarker,"RequestFrom"..Get(MyTopGate2,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyTopGate2,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyTopGate2,"GatePosition"),"no")
		Set(MyTopGate2,"Mode",0)
	end
	
	if Exists(MyBottomGate1) then
		Set(MyMarker,"RequestFrom"..Get(MyBottomGate1,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyBottomGate1,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyBottomGate1,"GatePosition"),"no")
		Set(MyBottomGate1,"Mode",0)
	end
	
	if Exists(MyBottomGate2) then
		Set(MyMarker,"RequestFrom"..Get(MyBottomGate2,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyBottomGate2,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyBottomGate2,"GatePosition"),"no")
		Set(MyBottomGate2,"Mode",0)
	end
	
	
	Set(MyCrane,"MoveToCentre",false)
	Set(MyCrane,"TmpX",nil)
	Set(MyCrane,"TmpY",nil)
	Set(MyCrane,"ResetCargo",true)
	Set(MyCrane,"DirectionSet",nil)
	Set(MyCrane,"StartingFrom",nil)
	Set(MyCrane,"CraneInPosition",false)
	Set(MyCrane,"MoveToX",this.ParkX)
	Set(MyCrane,"MoveToY",this.ParkY)
	Set(MyCrane,"MoveTheCrane",true)
	Set(MyCrane,"GiveJob","ParkHook")
	
	Set(MyHook,"GrabLimoFromTruck",false)
	Set(MyHook,"SpawnLimoOnFloor",false)
	Set(MyHook,"GrabLimoFromFloor",false)
	Set(MyHook,"UnloadCar",false)
	Set(MyHook,"GrabEngineFromTruck",false)
	Set(MyHook,"SpawnEngineInRack",false)
	Set(MyHook,"GrabEngineFromRack",false)
	Set(MyHook,"GrabEngineFromCar",false)
	Set(MyHook,"BringEngineToRack",false)
	Set(MyHook,"BringEngineToLimo",false)
	Set(MyHook,"UnloadEngine",false)
	Set(MyHook,"ParkHook",false)
	Set(MyHook,"TruckSlotNr",nil)
	Set(MyHook,"SlotNr",nil)
	Set(MyHook,"LessonNr",nil)
	
	Set(this,"GarageIsFull","no")
	Set(this,"PartsRackIsFull","no")
	
	Limo0 = ""
	Limo1 = ""
	Limo2 = ""
	Limo3 = ""
	Limo4 = ""
	Limo5 = ""
	Limo6 = ""
	Limo7 = ""
	Limo8 = ""
	Limo9 = ""
	Limo10 = ""
	Limo11 = ""
	Limo12 = ""
	Limo13 = ""
	Limo14 = ""
	Limo15 = ""
	
	if this.Slot0X ~= nil then ResetSpot(0) end
	if this.Slot1X ~= nil then ResetSpot(1) end
	if this.Slot2X ~= nil then ResetSpot(2) end
	if this.Slot3X ~= nil then ResetSpot(3) end
	if this.Slot4X ~= nil then ResetSpot(4) end
	if this.Slot5X ~= nil then ResetSpot(5) end
	if this.Slot6X ~= nil then ResetSpot(6) end
	if this.Slot7X ~= nil then ResetSpot(7) end
	if this.Slot8X ~= nil then ResetSpot(8) end
	if this.Slot9X ~= nil then ResetSpot(9) end
	if this.Slot10X ~= nil then ResetSpot(10) end
	if this.Slot11X ~= nil then ResetSpot(11) end
	if this.Slot12X ~= nil then ResetSpot(12) end
	if this.Slot13X ~= nil then ResetSpot(13) end
	if this.Slot14X ~= nil then ResetSpot(14) end
	if this.Slot15X ~= nil then ResetSpot(15) end
	
	if Exists(Lesson1) then Set(Lesson1,"CountDown",false); Set(Lesson1,"EngineDamage",nil); Object.CancelJob(Lesson1,"RefurbishEngine2"); Object.CancelJob(Lesson1,"RemoveEngine2"); Set(this,"ttLessonSlot1","Empty Lesson Spot") end
	if Exists(Lesson2) then Set(Lesson2,"CountDown",false); Set(Lesson2,"EngineDamage",nil); Object.CancelJob(Lesson2,"RefurbishEngine2"); Object.CancelJob(Lesson2,"RemoveEngine2"); Set(this,"ttLessonSlot2","Empty Lesson Spot") end
	if Exists(Lesson3) then Set(Lesson3,"CountDown",false); Set(Lesson3,"EngineDamage",nil); Object.CancelJob(Lesson3,"RefurbishEngine2"); Object.CancelJob(Lesson3,"RemoveEngine2"); Set(this,"ttLessonSlot3","Empty Lesson Spot") end
	if Exists(Lesson4) then Set(Lesson4,"CountDown",false); Set(Lesson4,"EngineDamage",nil); Object.CancelJob(Lesson4,"RefurbishEngine2"); Object.CancelJob(Lesson4,"RemoveEngine2"); Set(this,"ttLessonSlot4","Empty Lesson Spot") end
	if Exists(Lesson5) then Set(Lesson5,"CountDown",false); Set(Lesson5,"EngineDamage",nil); Object.CancelJob(Lesson5,"RefurbishEngine2"); Object.CancelJob(Lesson5,"RemoveEngine2"); Set(this,"ttLessonSlot5","Empty Lesson Spot") end
	if Exists(Lesson6) then Set(Lesson6,"CountDown",false); Set(Lesson6,"EngineDamage",nil); Object.CancelJob(Lesson6,"RefurbishEngine2"); Object.CancelJob(Lesson6,"RemoveEngine2"); Set(this,"ttLessonSlot6","Empty Lesson Spot") end
	if Exists(Lesson7) then Set(Lesson7,"CountDown",false); Set(Lesson7,"EngineDamage",nil); Object.CancelJob(Lesson7,"RefurbishEngine2"); Object.CancelJob(Lesson7,"RemoveEngine2"); Set(this,"ttLessonSlot7","Empty Lesson Spot") end
	if Exists(Lesson8) then Set(Lesson8,"CountDown",false); Set(Lesson8,"EngineDamage",nil); Object.CancelJob(Lesson8,"RefurbishEngine2"); Object.CancelJob(Lesson8,"RemoveEngine2"); Set(this,"ttLessonSlot8","Empty Lesson Spot") end
	if Exists(Lesson9) then Set(Lesson9,"CountDown",false); Set(Lesson9,"EngineDamage",nil); Object.CancelJob(Lesson9,"RefurbishEngine2"); Object.CancelJob(Lesson9,"RemoveEngine2"); Set(this,"ttLessonSlot9","Empty Lesson Spot") end
	if Exists(Lesson10) then Set(Lesson10,"CountDown",false); Set(Lesson10,"EngineDamage",nil); Object.CancelJob(Lesson10,"RefurbishEngine2"); Object.CancelJob(Lesson10,"RemoveEngine2"); Set(this,"ttLessonSlot10","Empty Lesson Spot") end
	
	
	for i=0,7 do
		Set(MyRack,"Slot"..i.."Reserved",nil)
	end
	
	if Exists(MyDesk) then
		MyNewServiceDesk = Object.Spawn("Limo2ServiceDesk",MyDesk.Pos.x,MyDesk.Pos.y)
		Set(MyNewServiceDesk,"Or.x",MyDesk.Or.x)
		Set(MyNewServiceDesk,"Or.y",MyDesk.Or.y)
		Set(MyNewServiceDesk,"TimeWarp",this.TimeWarp)
		Set(MyNewServiceDesk,"HomeUID",this.HomeUID)
		Set(MyNewServiceDesk,"Tooltip","HomeUID: "..this.HomeUID)
		MyDesk.Delete()
		MyDesk = nil
		MyDesk = MyNewServiceDesk
	end
	Set(this,"OrderLimoAmount",0)
	Set(this,"OrderPartsAmount",0)
	Set(this,"LoadNewCars",false)
	Set(this,"LoadRepairedCars",false)
	
	Set(this,"UnloadTruckSlot0",false)
	Set(this,"UnloadTruckSlot1",false)
	
	Set(this,"UnloadEngineSlot0",false)
	Set(this,"UnloadEngineSlot1",false)
	
	Set(this,"BringToRack0",false)
	Set(this,"BringToRack1",false)
	Set(this,"BringToRack2",false)
	Set(this,"BringToRack3",false)
	Set(this,"BringToRack4",false)
	Set(this,"BringToRack5",false)
	Set(this,"BringToRack6",false)
	Set(this,"BringToRack7",false)
	Set(this,"BringToRack8",false)
	
	Set(this,"Slot1.i",-1)
	Set(this,"Slot1.u",-1)
	Set(this,"OrderSpawned", nil)
	Set(this,"ScanForLimoOnRoad",false)
	Set(this,"SubType",0)
	Set(this,"Timer",0)
	Set(this,"GateCount",0)
	Set(this,"BusyDoingJob",false)
	Set(this,"LimoWaitingOnRoad","no")
	Set(this,"TimeToOrderLimoTruck",0)
	Set(this,"TimeToOrderPartsTruck",0)
	Set(this,"LimoTruckArriving","no")
	Set(this,"PartsTruckArriving","no")
	Set(this,"TruckTimerLimo",math.random(10,20)+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
	Set(this,"TruckTimerParts",math.random(10,20)+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
	
	Set(this,"CurrentTask","tooltip_CraneIdle")
	BuildTooltip("tooltip_GantryCraneReset")
	--print("Reset done")
end

function ClearErrorLogsClicked()
	Set(MyHook,"ErrorLog"," ")
	Set(MyCrane,"ErrorLog"," ")
	Set(this,"ErrorLog"," ")
end

function ResetGatesClicked()
	if not Exists(MyRepairedLimoGate) then
		FindMyGates()
	else
		if Exists(MyRepairedLimoGate) then
			Set(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition"),"none")
			Set(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition"),"no")
			Set(MyMarker,"CloseGate"..Get(MyRepairedLimoGate,"GatePosition"),"no")
			Set(MyRepairedLimoGate,"Mode",0)
		end
	end
	if Exists(MyTopGate1) then
		Set(MyMarker,"RequestFrom"..Get(MyTopGate1,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyTopGate1,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyTopGate1,"GatePosition"),"no")
		Set(MyTopGate1,"Mode",0)
	end
	if Exists(MyTopGate2) then
		Set(MyMarker,"RequestFrom"..Get(MyTopGate2,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyTopGate2,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyTopGate2,"GatePosition"),"no")
		Set(MyTopGate2,"Mode",0)
	end
	
	if Exists(MyBottomGate1) then
		Set(MyMarker,"RequestFrom"..Get(MyBottomGate1,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyBottomGate1,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyBottomGate1,"GatePosition"),"no")
		Set(MyBottomGate1,"Mode",0)
	end
	
	if Exists(MyBottomGate2) then
		Set(MyMarker,"RequestFrom"..Get(MyBottomGate2,"GatePosition"),"none")
		Set(MyMarker,"Authorized"..Get(MyBottomGate2,"GatePosition"),"no")
		Set(MyMarker,"CloseGate"..Get(MyBottomGate2,"GatePosition"),"no")
		Set(MyBottomGate2,"Mode",0)
	end
end

function toggleBoothTooltipClicked()
	if this.ShowLimo2BoothInfo == "No" then this.ShowLimo2BoothInfo = "Yes" else this.ShowLimo2BoothInfo = "No" end
	this.SetInterfaceCaption("toggleBoothTooltip", "tooltip_ShowLimo2BoothInfo","tooltip_Button_ShowLimo2Info"..this.ShowLimo2BoothInfo,"X")
	BuildTooltip("Booth Tooltip: "..this.ShowLimo2BoothInfo)
end

function toggleCraneTooltipClicked()
	if this.ShowLimo2CraneInfo == "No" then this.ShowLimo2CraneInfo = "Yes" else this.ShowLimo2CraneInfo = "No" end
	this.SetInterfaceCaption("toggleCraneTooltip", "tooltip_ShowLimo2CraneInfo","tooltip_Button_ShowLimo2Info"..this.ShowLimo2CraneInfo,"X")
	BuildTooltip("Crane Tooltip: "..this.ShowLimo2CraneInfo)
end

function toggleHookTooltipClicked()
	if this.ShowLimo2HookInfo == "No" then this.ShowLimo2HookInfo = "Yes" else this.ShowLimo2HookInfo = "No" end
	this.SetInterfaceCaption("toggleHookTooltip", "tooltip_ShowLimo2HookInfo","tooltip_Button_ShowLimo2Info"..this.ShowLimo2HookInfo,"X")
	BuildTooltip("Hook Tooltip: "..this.ShowLimo2HookInfo)
end

function toggleRackTooltipClicked()
	if this.ShowLimo2RackInfo == "No" then this.ShowLimo2RackInfo = "Yes" else this.ShowLimo2RackInfo = "No" end
	this.SetInterfaceCaption("toggleRackTooltip", "tooltip_ShowLimo2RackInfo","tooltip_Button_ShowLimo2Info"..this.ShowLimo2RackInfo,"X")
	BuildTooltip("Rack Tooltip: "..this.ShowLimo2RackInfo)
end

function toggleTruckTooltipClicked()
	if this.ShowLimo2TruckInfo == "No" then this.ShowLimo2TruckInfo = "Yes" else this.ShowLimo2TruckInfo = "No" end
	this.SetInterfaceCaption("toggleTruckTooltip", "tooltip_ShowLimo2TruckInfo","tooltip_Button_ShowLimo2Info"..this.ShowLimo2TruckInfo,"X")
	BuildTooltip("Truck Tooltip: "..this.ShowLimo2TruckInfo)
end
