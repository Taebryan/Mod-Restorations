
local timeTot = 0
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

-------------------- Find Stuff -------------------------

function FindMyRoadMarker()
	local markerFound = false
    local nearbyObject = Find(this,"RoadMarker2",1500)
	if next(nearbyObject) then
		for name,dist in pairs(nearbyObject) do
			if Get(this,"MarkerUID") == Get(name,"MarkerUID") then
				--print("marker found")
				MyMarker=name
				markerFound = true
				break
			end
		end
	end
	nearbyObject = nil
	if markerFound == false then
		-- local nearbyObject = Find(this,"StreetManager",1500)
		-- if next(nearbyObject) then
			-- for thatManager,dist in pairs(nearbyObject) do
				-- print("Reset StreetManager")
				-- thatManager.Delete()
			-- end
		-- end
		-- nearbyObject = nil
		-- Set(this,"ErrorLog",this.ErrorLog.."\n |  00 RoadMarker not found, StreetManager reset.")
		-- return
	end
end

function FindMyGate()
	local gateFound = false
	local nearbyObject = Find("RoadGate2Small",50)
	if next(nearbyObject) then
		for thatGate, distance in pairs(nearbyObject) do
			if thatGate.HomeUID==this.HomeUID and thatGate.SubType == 10 then
				MyRepairedLimoGate=thatGate
				gateFound = true
				break
			end
		end
	end
	if gateFound == false then
		--print("Gate not found")
	end
	nearbyObject = nil
end

function FindMyCrane()
	--print("FindMyCrane")
	local craneFound = false
    local nearbyObject = Find("GantryCrane2",50)
	if next(nearbyObject) then
		for thatCrane, distance in pairs(nearbyObject) do
			if thatCrane.HomeUID==this.HomeUID then
				MyCrane=thatCrane
				craneFound = true
				--print("MyCrane found")
				break
			end
		end
	end
	nearbyObject=nil
	if craneFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  01 Crane not found.") end
end

function FindMyRack()
	local rackFound = false
	local nearbyObject = Find("CarPartsRack2",50)
	if next(nearbyObject) then
		for thatRack, distance in pairs(nearbyObject) do
			if thatRack.HomeUID==this.HomeUID then
				MyRack=thatRack
				rackFound = true
				--print("MyRack found")
				break
			end
		end
	end
	nearbyObject = nil
	--if rackFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  No Rack available.") end
end

function FindMyBooth()
	--print("FindMyBooth")
	local boothFound = false
	local nearbyObject = Find("GantryCrane2Booth",50)
	if next(nearbyObject) then
		for thatBooth, distance in pairs(nearbyObject) do
			if thatBooth.HomeUID==this.HomeUID then
				MyCraneBooth=thatBooth
				boothFound = true
				--print("MyCraneBooth found")
				break
			end
		end
	end
	nearbyObject = nil
	if boothFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  02 Booth not found.") end
end

function FindMyDesk()
	local deskFound = false
	local nearbyObject = Find("Limo2ServiceDesk",50)
	if next(nearbyObject) then
		for thatDesk, distance in pairs(nearbyObject) do
			if thatDesk.HomeUID==this.HomeUID then
				MyDesk=thatDesk
				deskFound = true
				print("MyDesk found")
			end
		end
	end
	nearbyObject = nil
	if deskFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  03 Limo2ServiceDesk not found.") end
end

function FindMyLimoTruck()
	--print("FindMyLimoTruck")
	local nearbyObject = Find("CargoStationTruck",50)
	truckLimoFound = false
	if next(nearbyObject) then
		for thatTruck, distance in pairs(nearbyObject) do
			if thatTruck.CraneUID == this.HomeUID and Get(thatTruck,"SkinType") == "LimoTow" and thatTruck.VehicleState == "ProcessingGarage" then
				MyLimoTruck=thatTruck
				print("CargoStationTruck found")
				TruckSkins = Find(thatTruck,"LimoTowTruckSkin",10)
				if next(TruckSkins) then
					for thatSkin, dist in pairs(TruckSkins) do
						if thatSkin.HomeUID == thatTruck.HomeUID then
							MyTruckSkin = thatSkin
							print(MyTruckSkin.Type.." found at distance "..dist)
							break
						end
					end
				end
				truckLimoFound = true
				break
			end
		end
	end
	nearbyObject = nil
	if truckFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  04 TowTruck2WithLimo not found.") end
end

function FindMyPartsTruck()
	--print("FindMyPartsTruck")
	truckPartsFound = false
	local nearbyObject = Find("CargoStationTruck",50)
	if next(nearbyObject) then
		for thatTruck, distance in pairs(nearbyObject) do
			if thatTruck.CraneUID == this.HomeUID and Get(thatTruck,"SkinType") == "CarPartsTow" and thatTruck.VehicleState == "ProcessingGarage" then
				MyPartsTruck=thatTruck
				print("CargoStationTruck found")
				TruckSkins = Find(thatTruck,"CarPartsTowTruckSkin",10)
				if next(TruckSkins) then
					for thatSkin, dist in pairs(TruckSkins) do
						if thatSkin.HomeUID == thatTruck.HomeUID then
							MyTruckSkin = thatSkin
							print(MyTruckSkin.Type.." found at distance "..dist)
							break
						end
					end
				end
				truckPartsFound = true
				break
			end
		end
	end
	nearbyObject = nil
	if truckPartsFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  05 TowTruck2WithCarParts not found.") end
	--if truckFound == false then --print("no truck found") end
end

function FindMyCar()
	--print("FindMyCar")
	local carFound = false
	local nearbyObject = Find("Limo2OnCrane",1)
	if next(nearbyObject) then
		for thatCar, distance in pairs(nearbyObject) do
			MyCarOnCrane=thatCar
			--print("MyCarOnCrane found at distance "..distance)
			carFound = true
		end
	end
	nearbyObject=nil
	if carFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  06 Limo2OnCrane not found.") end
	--if carFound == false then --print("no Limo2OnCrane found") end
end

function FindMyEngine()
	--print("FindMyEngine")
	local engineFound = false
	local nearbyObject = Find("Limo2EngineOnCrane",1)
	if next(nearbyObject) then
		for thatEngine, distance in pairs(nearbyObject) do
			MyEngine=thatEngine
			--print("MyEngine found at distance "..distance)
			engineFound = true
		end
	end
	nearbyObject = nil
	if engineFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  07 Limo2EngineOnCrane not found.") end
	--if engineFound == false then --print("no Limo2EngineOnCrane found") end
end

function CheckFreeSlots(FromLessonCar,FromTruck)
	--print("CheckFreeSlots")
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	if MyRack == nil or MyRack.SubType == nil then FindMyRack() end
	FreeEngineSlots = 0
	ReservedEngineSlots = 0
	if not FromLessonCar then
		if not FromTruck then
			for i=0,7 do
				if Get(MyRack,"Slot"..i..".i") == -1 and not Get(MyRack,"Slot"..i.."Reserved") then
					--print("MyRack slot "..i.." is free")
					FreeEngineSlots = FreeEngineSlots+1
					break
				end
			end
		else
			for i=0,7 do
				if Get(MyRack,"Slot"..i..".i") == -1 and not Get(MyRack,"Slot"..i.."Reserved") then
					Set(MyRack,"Slot"..i.."Reserved","Truck "..this.TruckSlotNr+1)
					--print("MyRack slot "..i.." is free")
					FreeEngineSlots = FreeEngineSlots+1
					break
				end
			end
		end
		if FreeEngineSlots == 0 then
			Set(MyCraneBooth,"PartsRackIsFull","yes")
			Set(MyCraneBooth,"UnloadEngineSlot0",false)
			Set(MyCraneBooth,"UnloadEngineSlot1",false)
			--print("PartsRackIsFull true")
		else
			Set(MyCraneBooth,"PartsRackIsFull","no")
			--print("PartsRackIsFull false")
		end
	else
		for i=0,7 do
			if Get(MyRack,"Slot"..i..".i") == -1 and Get(MyRack,"Slot"..i.."Reserved") == "Lesson "..this.SlotNr then
				--print("MyRack slot "..i.." is reserved by lesson car "..this.SlotNr)
				ReservedEngineSlots = ReservedEngineSlots+1
			end
		end
	end
	
	FreeCarSlots = 0
	local s = 7
	if this.GarageSize == "Tall" or this.GarageSize == "Wide" then s = 15 end
	for j=0,s do
		if Get(MyCraneBooth,"Limo"..j.."ID") == "None" and Get(MyCraneBooth,"Slot"..j.."X") ~= nil then
			FreeCarSlots = FreeCarSlots+1
		end
	end
	if FreeCarSlots == 0 then
		Set(MyCraneBooth,"GarageIsFull","yes")
		Set(MyCraneBooth,"UnloadTruckSlot0",false)
		Set(MyCraneBooth,"UnloadTruckSlot1",false)
		--print("GarageIsFull true")
	else
		Set(MyCraneBooth,"GarageIsFull","no")
		--print("GarageIsFull false")
	end
end

function CheckFreeLessonSlots()
	--print("CheckFreeLessonSlots")
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	FreeLessonSlots = 0
	for j=1,10 do
		--print("lesson slot"..j..": "..Get(MyCraneBooth,"ttLessonSlot"..j))
		if Get(MyCraneBooth,"Lesson"..j.."ID") ~= "None" and Get(MyCraneBooth,"ttLessonSlot"..j) == "Waiting for engine..." then
			--print("Lesson slot "..j.." is free")
			Set(MyCraneBooth,"ttLessonSlot"..j,"Getting engine to refurbish")
			Set(this,"LessonNr",j)
			FreeLessonSlots = FreeLessonSlots+1
			--print(FreeLessonSlots.." FreeLessonSlots found")
			break
		end
	end
	--if FreeLessonSlots == 0 then --print("No free Limo2Lesson found") end
end

function LoadFreeCarSlot()
	--print("LoadFreeCarSlot")
	if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	if MyRack == nil or MyRack.SubType == nil then FindMyRack() end
	local SpotFound = false
	
	local s = 7
	if this.GarageSize == "Tall" or this.GarageSize == "Wide" then s = 15 end
	for j=0,s do
		if Get(MyCraneBooth,"Limo"..j.."ID") == "None" and Get(MyCraneBooth,"Slot"..j.."X") ~= nil then
			--print("MyCraneBooth slot "..j.." is free")
			Set(this,"SlotNr",j)
			Set(MyCrane,"MoveToX",Get(MyCraneBooth,"Slot"..j.."X"))
			Set(MyCrane,"MoveToY",Get(MyCraneBooth,"Slot"..j.."Y"))
			Set(MyCrane,"GiveJob","SpawnLimoOnFloor")
			Set(MyCrane,"MoveTheCrane",true)
			SpotFound = true
			Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Getting car from truck")
			BuildTooltip("tooltip_Placinglimoonrepairspot"..j)
			--print("Placing limo on repair spot "..j.." x "..MyCrane.MoveToX.." y "..MyCrane.MoveToY)
			break
		end
	end
	if SpotFound == false then
		Set(MyCraneBooth,"GarageIsFull","no")
		Set(MyCraneBooth,"UnloadTruckSlot0",false)
		Set(MyCraneBooth,"UnloadTruckSlot1",false)
		--print("SpotFound false, GarageIsFull true")
	end
end

function LoadFreePartsSlot(FromLessonCar)
	--print("LoadFreePartsSlot")
	if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	if MyRack == nil or MyRack.SubType == nil then FindMyRack() end
	local SpotFound = false
	if not FromLessonCar then
		for j=0,7 do
			if Get(MyRack,"Slot"..j..".i") == -1 and Get(MyRack,"Slot"..j.."Reserved") == "Truck "..this.TruckSlotNr+1 then
				--print("MyRack slot "..j.." is free")
				Set(this,"SlotNr",j)
				Set(MyCrane,"MoveToX",Get(MyRack,"Slot"..j.."X"))
				Set(MyCrane,"MoveToY",Get(MyRack,"Slot"..j.."Y"))
				Set(MyCrane,"GiveJob","SpawnEngineInRack")
				Set(MyCrane,"MoveTheCrane",true)
				BuildTooltip("tooltip_Placingengineinrackspot"..j)
				SpotFound = true
				--print("Placing engine in rack spot "..j.." x "..MyCrane.MoveToX.." y "..MyCrane.MoveToY)
				break
			end
		end
		if SpotFound == false then Set(MyCraneBooth,"PartsRackIsFull","yes")
			Set(MyCraneBooth,"UnloadEngineSlot0",false)
			Set(MyCraneBooth,"UnloadEngineSlot1",false)
			--print("SpotFound false, PartsRackIsFull true")
		end
	else
		for j=0,7 do
			if Get(MyRack,"Slot"..j..".i") == -1 and Get(MyRack,"Slot"..j.."Reserved") == "Lesson "..this.SlotNr then
				--print("MyRack slot "..j.." is free")
				Set(this,"SlotNr",j)
				Set(MyCrane,"MoveToX",Get(MyRack,"Slot"..j.."X"))
				Set(MyCrane,"MoveToY",Get(MyRack,"Slot"..j.."Y"))
				Set(MyCrane,"GiveJob","SpawnEngineInRack")
				Set(MyCrane,"MoveTheCrane",true)
				BuildTooltip("tooltip_Placingengineinrackspot"..j)
				SpotFound = true
				--print("Placing engine in rack spot "..j.." x "..MyCrane.MoveToX.." y "..MyCrane.MoveToY)
				break
			end
		end
	end
end

function GrabEngineFromRack()
	--print("GrabEngineFromRack")
	if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	if MyRack == nil or MyRack.SubType == nil then FindMyRack() end
	for j=0,7 do
		if tonumber(Get(MyRack,"Slot"..j..".i")) > 0 and Get(MyRack,"Slot"..j.."Reserved") == "Limo "..this.SlotNr+1 then
			--print("MyRack slot "..j.." has engine loaded for limo "..this.SlotNr)
			Set(this,"RackSlotNr",j)
			Set(MyCrane,"MoveToX",Get(MyRack,"Slot"..j.."X"))
			Set(MyCrane,"MoveToY",Get(MyRack,"Slot"..j.."Y"))
			Set(MyCrane,"GiveJob","BringEngineToLimo")
			Set(MyCrane,"MoveTheCrane",true)
			BuildTooltip("tooltip_Fetchingenginefromrackspot"..j)
			--print("Fetching engine from rack spot "..j.." x "..MyCrane.MoveToX.." y "..MyCrane.MoveToY)
			break
		end
	end
	Set(this,"GrabEngineFromRack",false)
end

function MoveCarToCentre()
	--print("MoveCarToCentre")
	if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	Set(MyCrane,"MoveToX",this.RoadX)
	Set(MyCrane,"MoveToY",this.RoadY)
	Set(MyCrane,"GiveJob","UnloadCar")
	Set(MyCrane,"MoveTheCrane",true)
	Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Placing repaired limo "..(this.SlotNr+1).." on the road")
	BuildTooltip("tooltip_Placingrepairedlimo"..this.SlotNr)
	--print("Placing repaired limo "..this.SlotNr.." on the road.  x "..MyCrane.MoveToX.." y "..MyCrane.MoveToY)
end

function MoveEngineToCar()
	--print("MoveEngineToCar")
	if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	Set(MyCrane,"MoveToX",Get(MyCraneBooth,"Slot"..this.SlotNr.."X"))
	Set(MyCrane,"MoveToY",Get(MyCraneBooth,"Slot"..this.SlotNr.."Y")+1.17)
	Set(MyCrane,"GiveJob","UnloadEngine")
	Set(MyCrane,"MoveTheCrane",true)
	Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Placing engine in limo "..(this.SlotNr+1))
	BuildTooltip("tooltip_Placingengineinlimo"..this.SlotNr)
	--print("Placing engine in limo "..this.SlotNr.." x "..MyCrane.MoveToX.." y "..MyCrane.MoveToY)
end

function MoveEngineToLessonCar()
	--print("MoveEngineToLessonCar")
	if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	--print("LessonNr is "..this.LessonNr)
	Set(MyCrane,"MoveToX",Get(MyCraneBooth,"LessonSpot"..this.LessonNr.."X"))
	Set(MyCrane,"MoveToY",Get(MyCraneBooth,"LessonSpot"..this.LessonNr.."Y")+1.17)
	Set(MyCrane,"GiveJob","UnloadEngine")
	Set(MyCrane,"MoveTheCrane",true)
	Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Requesting new engine")
	BuildTooltip("tooltip_Placingengineinlessoncar"..this.LessonNr)
	--print("Placing engine in lesson car "..this.LessonNr.." x "..MyCrane.MoveToX.." y "..MyCrane.MoveToY)
end

-------------------- Done finding  ----------------------


function GrabLimoFromTruck()
	--print("GrabLimoFromTruck")
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	local carFound = false
	CheckFreeSlots()
	if FreeCarSlots > 0 then
		FindMyLimoTruck()
		local nearbyObject = Find("Limo2Broken",5)
		if next(nearbyObject) then
			for thatCar, distance in pairs(nearbyObject) do
				if Get(thatCar,"Id.i") == Get(MyTruckSkin,"Slot"..(this.TruckSlotNr+3)..".i") then
					--print("Limo2Broken "..this.TruckSlotNr.." found at distance "..distance)
					MyCarOnCrane = Object.Spawn("Limo2OnCrane",this.Pos.x,this.Pos.y+0.75)
					MyCarOnCrane.SubType = thatCar.SubType
					Set(MyCrane,"CargoOnHook",true)
					Set(MyCarOnCrane,"GateCount",Get(thatCar,"GateCount"))
					Set(MyCarOnCrane,"CraneUID",Get(thatCar,"CraneUID"))
					Set(MyTruckSkin,"Slot"..(this.TruckSlotNr+3)..".i",-1)
					Set(MyTruckSkin,"Slot"..(this.TruckSlotNr+3)..".u",-1)
					Set(thatCar,"CarrierId.i",-1)
					Set(thatCar,"CarrierId.u",-1)
					Set(thatCar,"Loaded",false)
					thatCar.Delete()
					Set(MyCraneBooth,"UnloadTruckSlot"..this.TruckSlotNr,false)
					LoadFreeCarSlot()
					carFound = true
					break
				end
			end
			if carFound == false then
				Set(this,"ErrorLog",this.ErrorLog.."\n |  A1 Broken limo "..this.TruckSlotNr.." not found.\n |  Hook X: "..this.Pos.x.."  Y: "..this.Pos.y)
				--print("=== ERROR === Limo2Broken not found")
				Set(MyCraneBooth,"UnloadTruckSlot"..this.TruckSlotNr,false)
				PreparePark()
			end
		else
			Set(this,"ErrorLog",this.ErrorLog.."\n |  A2 Broken limo "..this.TruckSlotNr.." not found.\n |  Hook X: "..this.Pos.x.."  Y: "..this.Pos.y)
			--print("=== ERROR === Limo2Broken not found")
			Set(MyCraneBooth,"UnloadTruckSlot"..this.TruckSlotNr,false)
			PreparePark()
		end
		nearbyObject = nil
	else
		PreparePark()
	end
	Set(this,"GrabLimoFromTruck",false)
end

function SpawnLimoOnFloor()
	--print("SpawnLimoOnFloor")
	local carFound = false
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	if MyCarOnCrane == nil or MyCarOnCrane.SubType == nil then		-- find my car after loadgame
		local nearbyObject = Find("Limo2OnCrane",2)
		--print("finding Limo2OnCrane")
		if next(nearbyObject) then
			for thatCar, distance in pairs(nearbyObject) do
				--print("Limo2OnCrane found at distance "..distance)
				MyCarOnCrane = thatCar
				carFound = true
			end
		--else
		--	--print("=== ERROR === Limo2OnCrane not found")
		end
		nearbyObject = nil
		if carFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  B1 Limo2OnCrane not found.") end
	else
		carFound = true
		--print("Limo2OnCrane found")
	end
	
	if carFound == true then
		LimoOnFloor = Object.Spawn("Limo2OnFloor",Get(MyCraneBooth,"Slot"..this.SlotNr.."X"),Get(MyCraneBooth,"Slot"..this.SlotNr.."Y")+0.75)
		LimoOnFloor.SubType = MyCarOnCrane.SubType
		Set(LimoOnFloor,"CraneUID",Get(MyCarOnCrane,"CraneUID"))	--name it craneUID instead of HomeUID on this car
		Set(LimoOnFloor,"GateCount",Get(MyCarOnCrane,"GateCount"))
		Set(LimoOnFloor,"SlotNr",this.SlotNr)
		Set(LimoOnFloor,"TimeWarp",this.TimeWarp)
		Set(LimoOnFloor,"SpotType",Get(MyCraneBooth,"SpotType"..this.SlotNr))
		Set(LimoOnFloor,"Tooltip","CarUID: "..LimoOnFloor.CarUID.."\nRepair Spot: "..(this.SlotNr+1))
		Set(MyCrane,"CargoOnHook",nil)
		MyCarOnCrane.Delete()
		MyCarOnCrane = nil

		Set(MyCraneBooth,"Limo"..this.SlotNr.."ID",LimoOnFloor.Id.i)
		if Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Repair" then
			Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Repair in progress")
		elseif Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Paint" then
			Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Painting in progress")
		end
		Set(MyCraneBooth,"LoadNewCars",true)
		
		CheckFreeSlots()
	end
	PreparePark()
	Set(this,"SpawnLimoOnFloor",false)
end

function GrabLimoFromFloor()
	--print("GrabLimoFromFloor")
	local carFound = false
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	--print("finding Limo2OnCrane")
	local nearbyObject = Find("Limo2OnCrane",2)		-- find car after loadgame
	if next(nearbyObject) then
		for thatCarOnHook, distance in pairs(nearbyObject) do
			--print("Limo2OnCrane found at distance "..distance)
			MyCarOnCrane = thatCarOnHook
			MoveCarToCentre()
		end
	else
		--print("Limo2OnCrane not found, finding Limo2Repaired")
		local nearbyObject = Find("Limo2Repaired",2)
		if next(nearbyObject) then
			for thatCarOnFloor, distance in pairs(nearbyObject) do
				if thatCarOnFloor.SlotNr == this.SlotNr then
					--print("Limo2Repaired found at distance "..distance..", spawn Limo2OnCrane")
				
					MyCarOnCrane = Object.Spawn("Limo2OnCrane",this.Pos.x,this.Pos.y+0.75)
					MyCarOnCrane.SubType = thatCarOnFloor.SubType
					Set(MyCrane,"CargoOnHook",true)
					Set(MyCarOnCrane,"CraneUID",Get(thatCarOnFloor,"CraneUID"))
					Set(MyCarOnCrane,"CarUID",Get(thatCarOnFloor,"CarUID"))
					Set(MyCarOnCrane,"GateCount",Get(thatCarOnFloor,"GateCount"))
					Set(MyCarOnCrane,"Tooltip","CarUID: "..MyCarOnCrane.CarUID.."\nRepair Spot: "..this.SlotNr+1)
					thatCarOnFloor.Delete()
					carFound = true
					MoveCarToCentre()
					break
				end
			end
			if carFound == false then
				Set(this,"ErrorLog",this.ErrorLog.."\n |  C1 Limo2Repaired not found.")
				--print("=== ERROR === Limo2Repaired not found")
				--print("releasing MyCraneBooth slot"..this.SlotNr)
				Set(MyCraneBooth,"GarageIsFull","no")
				Set(MyCraneBooth,"UnloadSlot"..this.SlotNr,false)
				Set(MyCraneBooth,"Limo"..this.SlotNr.."ID","None")
				
				if Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Repair" then
					Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Empty Repair Spot")
				elseif Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Paint" then
					Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Empty Paint Spot")
				end
				if MyMarker == nil or MyMarker.SubType == nil then FindMyRoadMarker() end
				if MyRepairedLimoGate == nil or MyRepairedLimoGate.SubType == nil then FindMyGate() end
				if Get(MyRepairedLimoGate,"GatePosition") ~= nil then
					Set(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition"),"none")
					Set(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition"),"no")
					Set(MyMarker,"CloseGate"..Get(MyRepairedLimoGate,"GatePosition"),"no")
				end
				PreparePark()
			end
		else
			Set(this,"ErrorLog",this.ErrorLog.."\n |  C2 Limo2Repaired not found.")
			--print("=== ERROR === Limo2Repaired not found")
			--print("releasing MyCraneBooth slot"..this.SlotNr)
			Set(MyCraneBooth,"GarageIsFull","no")
			Set(MyCraneBooth,"UnloadSlot"..this.SlotNr,false)
			Set(MyCraneBooth,"Limo"..this.SlotNr.."ID","None")
			
			if Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Repair" then
				Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Empty Repair Spot")
			elseif Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Paint" then
				Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Empty Paint Spot")
			end
			if MyMarker == nil or MyMarker.SubType == nil then FindMyRoadMarker() end
			if MyRepairedLimoGate == nil or MyRepairedLimoGate.SubType == nil then FindMyGate() end
			if Get(MyRepairedLimoGate,"GatePosition") ~= nil then
				Set(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition"),"none")
				Set(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition"),"no")
				Set(MyMarker,"CloseGate"..Get(MyRepairedLimoGate,"GatePosition"),"no")
			end
			PreparePark()
		end
		nearbyObject = nil
	end
	nearbyObject = nil
	
	CheckFreeSlots()
	Set(this,"GrabLimoFromFloor",false)
end

function UnloadCar()
	--print("UnloadCar")
	local carFound = false
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	Set(MyCraneBooth,"UnloadSlot"..this.SlotNr,false)
	
	Set(MyCraneBooth,"Limo"..this.SlotNr.."ID","None")
	
	if Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Repair" then
		Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Empty Repair Spot")
	elseif Get(MyCraneBooth,"SpotType"..this.SlotNr) == "Paint" then
		Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Empty Paint Spot")
	end
	
	if MyCarOnCrane == nil or MyCarOnCrane.Loaded == nil then 		-- find car after loadgame
		--print("finding Limo2OnCrane")
		local nearbyObject = Find("Limo2OnCrane",2)
		if next(nearbyObject) then
			for thatCarOnHook, distance in pairs(nearbyObject) do
				--print("Limo2OnCrane found at distance "..distance)
				MyCarOnCrane = thatCarOnHook
				carFound = true
			end
		--	if carFound == false then
		--		--print("=== ERROR === Limo2OnCrane not found")
		--	end
		--else
		--	--print("=== ERROR === Limo2OnCrane not found")
		end
		nearbyObject = nil
		if carFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  D1 Limo2OnCrane not found.") end
	else
		--print("Limo2OnCrane found")
		carFound = true
	end
	
	if carFound == true then
		Set(MyCraneBooth,"LimoWaitingOnRoad","yes")
		FreshCar = Object.Spawn("Limo2RepairedOnRoad",this.RoadX,this.RoadY+0.75)
		Set(FreshCar,"HomeUID",MyCarOnCrane.CarUID)
		Set(FreshCar,"SubType",MyCarOnCrane.SubType)
		Set(FreshCar,"CraneUID",MyCarOnCrane.CraneUID)
		Set(FreshCar,"TimeWarp",this.TimeWarp)
		Set(FreshCar,"CarUID",MyCarOnCrane.CarUID)
		Set(FreshCar,"GateCount",MyCarOnCrane.GateCount)
		Set(FreshCar,"MarkerUID",this.MarkerUID)
		Set(FreshCar,"SlotNr",this.SlotNr)
		Object.CreateJob(FreshCar,"LimoDriverLeaving")
		Set(MyCrane,"CargoOnHook",nil)
		MyCarOnCrane.Delete()
		MyCarOnCrane = nil
		if MyRepairedLimoGate == nil or MyRepairedLimoGate.SubType == nil then FindMyGate() end
		if MyMarker == nil or MyMarker.SubType == nil then FindMyRoadMarker() end
		
		if Get(MyRepairedLimoGate,"GatePosition") ~= nil then
			Set(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition"),FreshCar.HomeUID)
			Set(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition"),"yes")
			Set(MyMarker,"CloseGate"..Get(MyRepairedLimoGate,"GatePosition"),"yes")
			Set(MyRepairedLimoGate,"Mode",1)
		end
	end
	PreparePark()
	CheckFreeSlots()
	Set(this,"UnloadCar",false)
end

function GrabEngineFromTruck()
	--print("GrabEngineFromTruck")
	local engineFound = false
	CheckFreeSlots(false,true)
	if FreeEngineSlots > 0 then
		FindMyPartsTruck()
		--print("FreeEngineSlots "..FreeEngineSlots)
		local nearbyObject = Find("Limo2EngineOnTruck",5)
		if next(nearbyObject) then
			for thatEngine, distance in pairs(nearbyObject) do
				--if Get(thatEngine,"CraneUID") == this.HomeUID and Get(thatEngine,"UnloadEngineSlot"..this.TruckSlotNr) == true then
				if Get(thatEngine,"Id.i") == Get(MyTruckSkin,"Slot"..(this.TruckSlotNr+3)..".i") then
					--print("Limo2Engine found at distance "..distance)
					MyEngineOnCrane = Object.Spawn("Limo2EngineOnCrane",this.Pos.x,this.Pos.y+0.17)
					MyEngineOnCrane.SubType = thatEngine.SubType
					Set(MyCrane,"CargoOnHook",true)
					Set(MyEngineOnCrane,"CraneUID",this.HomeUID)
					Set(MyTruckSkin,"Slot"..(this.TruckSlotNr+3)..".i",-1)
					Set(MyTruckSkin,"Slot"..(this.TruckSlotNr+3)..".u",-1)
					Set(thatEngine,"CarrierId.i",-1)
					Set(thatEngine,"CarrierId.u",-1)
					Set(thatEngine,"Loaded",false)
					thatEngine.Delete()
					Set(MyCraneBooth,"UnloadEngineSlot"..this.TruckSlotNr,false)
					LoadFreePartsSlot()
					engineFound = true
					break
				end
			end
			if engineFound == false then
				Set(this,"ErrorLog",this.ErrorLog.."\n |  E1 Engine "..this.TruckSlotNr.." not found.\n |  Hook X: "..this.Pos.x.."  Y: "..this.Pos.y)
				--print("=== ERROR === Limo2EngineOnTruck not found")
				Set(MyCraneBooth,"UnloadEngineSlot"..this.TruckSlotNr,false)
				PreparePark()
			end
		else
			Set(this,"ErrorLog",this.ErrorLog.."\n |  E2 Engine "..this.TruckSlotNr.." not found.\n |  Hook X: "..this.Pos.x.."  Y: "..this.Pos.y)
			--print("=== ERROR === Limo2EngineOnTruck not found")
			Set(MyCraneBooth,"UnloadEngineSlot"..this.TruckSlotNr,false)
			PreparePark()
		end
		nearbyObject = nil
	else
		PreparePark()
	end
	Set(this,"GrabEngineFromTruck",false)
end

function GrabEngineFromCar()
	--print("GrabEngineFromCar")
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	local engineFound = false
	CheckFreeLessonSlots()
	if FreeLessonSlots > 0 then
		--print("finding Limo2Engine")
		local nearbyObject = Find("Limo2EngineInCar",2)
		if next(nearbyObject) then
			for thatEngine, distance in pairs(nearbyObject) do
				if Get(thatEngine,"SlotNr") == Get(this,"SlotNr") then
					--print("Limo2EngineInCar found at distance "..distance..", spawn Limo2EngineOnCrane")
					MyEngineOnCrane = Object.Spawn("Limo2EngineOnCrane",this.Pos.x,this.Pos.y+0.17)
					MyEngineOnCrane.SubType = thatEngine.SubType
					Set(MyCrane,"CargoOnHook",true)
					Set(MyEngineOnCrane,"Damage",Get(thatEngine,"Damage"))
					thatEngine.CarrierId.i = -1
					thatEngine.CarrierId.u = -1
					thatEngine.Loaded = false
					thatEngine.Delete()
					Set(MyEngineOnCrane,"CraneUID",this.HomeUID)
					engineFound = true
					local nearbyObject = Find("Limo2OnFloor",2)
					--print("finding Limo2OnFloor")
					if next(nearbyObject) then
						for thatLimoOnFloor, distance in pairs(nearbyObject) do
							--print("Limo2OnFloor found at distance "..distance)
							if Get(thatLimoOnFloor,"SlotNr") == Get(this,"SlotNr") then
								Set(thatLimoOnFloor,"NeedEngine",true)
							end
						end
					end
					nearbyObject = nil
					Set(MyCraneBooth,"PutEngineInLessonCar"..this.SlotNr,false)
					MoveEngineToLessonCar()
					break
				end
			end
			if engineFound == false then
				Set(this,"ErrorLog",this.ErrorLog.."\n |  F1 Limo2EngineInCar not found.")
				--print("=== ERROR === Limo2Engine not found")
				Set(MyCraneBooth,"PutEngineInLessonCar"..this.SlotNr,false)
				PreparePark()
			end
		else
			Set(this,"ErrorLog",this.ErrorLog.."\n |  F2 Limo2EngineInCar not found.")
			--print("=== ERROR === Limo2Engine not found")
			Set(MyCraneBooth,"PutEngineInLessonCar"..this.SlotNr,false)
			PreparePark()
		end
		nearbyObject = nil
	else
		Set(MyCraneBooth,"PutEngineInLessonCar"..this.SlotNr,false)
		local nearbyObject = Find("Limo2OnFloor",2)
		--print("finding Limo2OnFloor")
		if next(nearbyObject) then
			for thatLimoOnFloor, distance in pairs(nearbyObject) do
				--print("Limo2OnFloor found at distance "..distance)
				if Get(thatLimoOnFloor,"SlotNr") == Get(this,"SlotNr") then
					Object.CreateJob(thatLimoOnFloor,"RemoveEngine2")
					Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Remove engine")
					Set(thatLimoOnFloor,"EngineDamage",nil)
					Set(thatLimoOnFloor,"CountDown",false)
					break
				end
			end
		end
		PreparePark()
	end
	Set(this,"GrabEngineFromCar",false)
end

function SpawnEngineInRack()
	--print("SpawnEngineInRack")
	local engineFound = false
	if MyRack == nil or MyRack.SubType == nil then FindMyRack() end
	if MyEngineOnCrane == nil or MyEngineOnCrane.Loaded == nil then		-- find my car after loadgame
		--print("finding Limo2EngineOnCrane")
		local nearbyObject = Find("Limo2EngineOnCrane",2)
		if next(nearbyObject) then
			for thatEngine, distance in pairs(nearbyObject) do
				--print("Limo2EngineOnCrane found at distance "..distance)
				MyEngineOnCrane = thatEngine
				engineFound = true
			end
			if engineFound == false then
				Set(this,"ErrorLog",this.ErrorLog.."\n |  G1 Limo2EngineOnCrane not found.")
				Set(MyCraneBooth,"PartsRackIsFull","no")
				--print("=== ERROR === Limo2EngineOnCrane not found")
			end
		else
			Set(this,"ErrorLog",this.ErrorLog.."\n |  G2 Limo2EngineOnCrane not found.")
			Set(MyCraneBooth,"PartsRackIsFull","no")
			--print("=== ERROR === Limo2EngineOnCrane not found")
		end
		nearbyObject = nil
	else
		--print("Limo2EngineOnCrane found")
		engineFound = true
	end

	if engineFound == true then
	--print("spawn Limo2Engine")
		EngineInRack = Object.Spawn("Limo2EngineInRack",MyEngineOnCrane.Pos.x,MyEngineOnCrane.Pos.y)
		Set(EngineInRack,"SubType",Get(MyEngineOnCrane,"SubType"))
		Set(EngineInRack,"CraneUID",this.HomeUID)	--name it craneUID instead of HomeUID on this engine
		Set(MyCrane,"CargoOnHook",nil)
		MyEngineOnCrane.Delete()
		MyEngineOnCrane = nil
					
		Set(MyRack,"Slot"..this.SlotNr.."Reserved",nil)
		Set(MyRack,"Slot"..this.SlotNr..".i",Get(EngineInRack,"Id.i"))
		Set(MyRack,"Slot"..this.SlotNr..".u",Get(EngineInRack,"Id.u"))
		Set(EngineInRack,"CarrierId.i",Get(MyRack,"Id.i"))
		Set(EngineInRack,"CarrierId.u",Get(MyRack,"Id.u"))
		Set(EngineInRack,"Loaded",true)
					
		Set(EngineInRack,"SlotNr",this.SlotNr)
	end
	PreparePark()
	CheckFreeSlots()
	Set(this,"SpawnEngineInRack",false)
end

function BringEngineToLimo()
	--print("BringEngineToLimo")
	local engineFound = false
	if MyRack == nil or MyRack.SubType == nil then FindMyRack() end
	local nearbyObject = Find("Limo2EngineOnCrane",2)		-- find engine after loadgame 
	--print("finding Limo2EngineOnCrane")
	if next(nearbyObject) then
		for thatEngineOnHook, distance in pairs(nearbyObject) do
			--print("Limo2EngineOnCrane found at distance "..distance)
			
			MyEngineOnCrane = thatEngineOnHook
			engineFound = true
			MoveEngineToCar()
		end
	--	if engineFound == false then
	--		--print("info: Limo2EngineOnCrane not found (nothing to worry about)")
	--	end
	else
		--print("Limo2EngineOnCrane not found, finding Limo2Engine")
															-- find engine in rack and grab it
		local nearbyObject = Find("Limo2EngineInRack",4)
		--print("finding Limo2Engine")
		if next(nearbyObject) then
			for thatEngineInRack, distance in pairs(nearbyObject) do
				--print("Limo2EngineInRack found at distance "..distance)
				if thatEngineInRack.Id.i == Get(MyRack,"Slot"..this.RackSlotNr..".i") then
					--print("Limo2EngineInRack found at distance "..distance..", spawn Limo2EngineOnCrane")
					MyEngineOnCrane = Object.Spawn("Limo2EngineOnCrane",this.Pos.x,this.Pos.y+0.17)
					Set(MyEngineOnCrane,"CraneUID",this.HomeUID)
					Set(MyCrane,"CargoOnHook",true)
					Set(MyEngineOnCrane,"SubType",Get(thatEngineInRack,"SubType"))
					Set(MyRack,"Slot"..this.RackSlotNr.."Reserved",nil)
					Set(MyRack,"Slot"..this.RackSlotNr..".i",-1)
					Set(MyRack,"Slot"..this.RackSlotNr..".u",-1)
					Set(thatEngineInRack,"CarrierId.i",-1)
					Set(thatEngineInRack,"CarrierId.u",-1)
					thatEngineInRack.Loaded = false
					thatEngineInRack.Delete()
					MoveEngineToCar()
					engineFound = true
				end
			end
			if engineFound == false then
				Set(this,"ErrorLog",this.ErrorLog.."\n |  H1 Limo2EngineInRack not found.")
				--print("=== ERROR === Limo2Engine not found")
				PreparePark()
			end
		else
			Set(this,"ErrorLog",this.ErrorLog.."\n |  H2 Limo2EngineInRack not found.")
			--print("=== ERROR === Limo2Engine not found")
			PreparePark()
		end
		nearbyObject = nil
	end
	nearbyObject = nil
	
	CheckFreeSlots()
	Set(this,"BringEngineToLimo",false)
end

function BringEngineToRack()
	--print("BringEngineToRack")
	local engineFound = false
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	
	CheckFreeSlots(true)
	if ReservedEngineSlots > 0 then
		--print("finding Limo2Engine")
		local nearbyObject = Find("Limo2EngineInLessonCar",2)
		if next(nearbyObject) then
			for thatEngine, distance in pairs(nearbyObject) do
				--print("found this engine: ")
				--print(thatEngine.LessonSpot)
				--print(thatEngine.SlotNr)
				if Get(thatEngine,"LessonSpot") == Get(this,"SlotNr") then
					Set(MyCraneBooth,"ttLessonSlot"..this.SlotNr,"Empty Lesson Spot")
					--print("Limo2Engine found at distance "..distance..", spawn Limo2EngineOnCrane")
					MyEngineOnCrane = Object.Spawn("Limo2EngineOnCrane",Get(MyCraneBooth,"LessonSpot"..this.SlotNr.."X"),Get(MyCraneBooth,"LessonSpot"..this.SlotNr.."Y")+1.17)
					MyEngineOnCrane.SubType = thatEngine.SubType
					Set(MyCrane,"CargoOnHook",true)
					Set(MyEngineOnCrane,"CraneUID",this.HomeUID)
					thatEngine.Delete()
					Set(MyCraneBooth,"BringToRack"..this.SlotNr,false)
					LoadFreePartsSlot(true)
					engineFound = true
					break
				end
			end
			if engineFound == false then
				Set(MyCraneBooth,"BringToRack"..this.SlotNr,false)
				Set(this,"ErrorLog",this.ErrorLog.."\n |  i1 Limo2EngineInLessonCar not found.")
				--print("=== ERROR === Limo2Engine not found")
				PreparePark()
			end
		else
			Set(MyCraneBooth,"BringToRack"..this.SlotNr,false)
			Set(this,"ErrorLog",this.ErrorLog.."\n |  i2 Limo2EngineInLessonCar not found.")
			--print("=== ERROR === Limo2Engine not found")
			PreparePark()
		end
		nearbyObject = nil
	else
		Set(MyCraneBooth,"BringToRack"..this.SlotNr,false)
		local nearbyObject = Find("Limo2Lesson",2)
		--print("finding Limo2Lesson")
		if next(nearbyObject) then
			for thatLimo2Lesson, distance in pairs(nearbyObject) do
				--print("Limo2Lesson found at distance "..distance)
				if Get(thatLimo2Lesson,"LessonSpot") == Get(this,"SlotNr") then
					Object.CreateJob(thatLimo2Lesson,"RemoveEngine2")
					Set(MyCraneBooth,"ttLessonSlot"..this.SlotNr,"Remove engine")
					Set(thatLimo2Lesson,"EngineDamage",nil)
					Set(thatLimo2Lesson,"CountDown",false)
					break
				end
			end
		end
		PreparePark()
	end
	
	Set(this,"BringEngineToRack",false)
end

function UnloadEngine()
	--print("UnloadEngine")
	local engineFound = false
	local carFrontFound = false
	local carFound = false
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	if MyEngineOnCrane == nil or MyEngineOnCrane.Loaded == nil then
		--print("finding Limo2EngineOnCrane")
		local nearbyObject = Find("Limo2EngineOnCrane",2)		-- find engine after loadgame
		if next(nearbyObject) then
			for thatEngineOnHook, distance in pairs(nearbyObject) do
				--print("Limo2EngineOnCrane found at distance "..distance)
				MyEngineOnCrane = thatEngineOnHook
				engineFound = true
			end
			if engineFound == false then
				Set(this,"ErrorLog",this.ErrorLog.."\n |  J1 Limo2EngineOnCrane not found.")
				--print("=== ERROR === Limo2EngineOnCrane not found")
			end
		else
			Set(this,"ErrorLog",this.ErrorLog.."\n |  J2 Limo2EngineOnCrane not found.")
		--	--print("=== ERROR === Limo2EngineOnCrane not found")
		end
		nearbyObject = nil
	else
		--print("Limo2EngineOnCrane found")
		engineFound = true
	end
	
	if engineFound == true then
		local nearbyObject = Find("Limo2OnFloor",2)
		--print("finding Limo2OnFloor")
		if next(nearbyObject) then
			for thatLimoOnFloor, distance in pairs(nearbyObject) do
				--print("Limo2OnFloor found at distance "..distance)
				if Get(thatLimoOnFloor,"SlotNr") == Get(this,"SlotNr") then
					--print("Limo2OnFloor "..this.SlotNr.." found")
					FreshEngine = Object.Spawn("Limo2EngineInCar",Get(MyCraneBooth,"Slot"..this.SlotNr.."X"),Get(MyCraneBooth,"Slot"..this.SlotNr.."Y"))
					Set(FreshEngine,"SubType",MyEngineOnCrane.SubType)
					Set(FreshEngine,"CraneUID",this.HomeUID)
					Set(thatLimoOnFloor,"Slot0.i",Get(FreshEngine,"Id.i"))
					Set(thatLimoOnFloor,"Slot0.u",Get(FreshEngine,"Id.u"))
					Set(FreshEngine,"CarrierId.i",Get(thatLimoOnFloor,"Id.i"))
					Set(FreshEngine,"CarrierId.u",Get(thatLimoOnFloor,"Id.u"))
					Set(FreshEngine,"SlotNr",thatLimoOnFloor.SlotNr)
					Set(FreshEngine,"Loaded",true)
					Set(FreshEngine,"CarUID",Get(thatLimoOnFloor,"CarUID"))
					FreshEngine.Tooltip= { "tooltip_limo2engine",FreshEngine.CarUID,"X",FreshEngine.SlotNr+1,"Y" }
					Set(thatLimoOnFloor,"NeedEngine",nil)
					Set(MyCraneBooth,"BringEngine"..this.SlotNr,false)
					Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Mount new engine")
					carFrontFound = true
					Object.CreateJob(thatLimoOnFloor,"MountNewEngine2")
					nearbyObject = nil
					break
				end
			end
			if carFrontFound == false then
				local nearbyObject = Find("Limo2Lesson",2)
				--print("finding Limo2Lesson")
				if next(nearbyObject) then
					for thatLimo2Lesson, distance in pairs(nearbyObject) do
						--print("Limo2Lesson found at distance "..distance)
						if Get(thatLimo2Lesson,"LessonSpot") == Get(this,"LessonNr") then
							--print("Limo2Lesson "..this.LessonNr.." found")
							FreshEngine = Object.Spawn("Limo2EngineInLessonCar",Get(MyCraneBooth,"LessonSpot"..this.LessonNr.."X"),Get(MyCraneBooth,"LessonSpot"..this.LessonNr.."Y")+1.17)
							Set(FreshEngine,"SubType",MyEngineOnCrane.SubType)
							Set(FreshEngine,"CraneUID",this.HomeUID)
							Set(thatLimo2Lesson,"Slot0.i",Get(FreshEngine,"Id.i"))
							Set(thatLimo2Lesson,"Slot0.u",Get(FreshEngine,"Id.u"))
							Set(FreshEngine,"CarrierId.i",Get(thatLimo2Lesson,"Id.i"))
							Set(FreshEngine,"CarrierId.u",Get(thatLimo2Lesson,"Id.u"))
							Set(FreshEngine,"Loaded",true)
							Set(FreshEngine,"CarUID",Get(thatLimo2Lesson,"CarUID"))
							Set(FreshEngine,"LessonSpot",Get(thatLimo2Lesson,"LessonSpot"))
							Set(FreshEngine,"Damage",Get(MyEngineOnCrane,"Damage"))
							Set(thatLimo2Lesson,"EngineDamage",0.69)
							FreshEngine.Tooltip= { "tooltip_limo2lesson",FreshEngine.CarUID,"X",FreshEngine.LessonSpot,"Y" }
							Set(MyCraneBooth,"ttLessonSlot"..this.LessonNr,"Refurbish in progress")
							Set(thatLimo2Lesson,"CountDown",true)
							Set(thatLimo2Lesson,"EngineJobIssued",true)
							Object.CreateJob(thatLimo2Lesson,"RefurbishEngine2")
							Set(MyCraneBooth,"PutEngineInLessonCar"..this.SlotNr,false)
							Set(this,"LessonNr",nil)
							carFound = true
							break
						end
					end
					if carFound == false then
						Set(this,"ErrorLog",this.ErrorLog.."\n |  J3 Limo2Lesson not found.")
						--print("=== ERROR === Limo2Lesson not found")
						Set(MyCraneBooth,"PutEngineInLessonCar"..this.LessonNr,false)
					end
				else
					Set(this,"ErrorLog",this.ErrorLog.."\n |  J4  Limo2Lesson not found.")
					--print("=== ERROR === Limo2Lesson not found")
					Set(MyCraneBooth,"PutEngineInLessonCar"..this.LessonNr,false)
				end
				nearbyObject = nil
			end
		else
			local nearbyObject = Find("Limo2Lesson",2)
			--print("finding Limo2Lesson")
			if next(nearbyObject) then
				for thatLimo2Lesson, distance in pairs(nearbyObject) do
					--print("Limo2Lesson found at distance "..distance)
					if Get(thatLimo2Lesson,"LessonSpot") == Get(this,"LessonNr") then
						--print("Limo2Lesson "..this.LessonNr.." found")
						FreshEngine = Object.Spawn("Limo2EngineInLessonCar",Get(MyCraneBooth,"LessonSpot"..this.LessonNr.."X"),Get(MyCraneBooth,"LessonSpot"..this.LessonNr.."Y")+1.17)
						Set(FreshEngine,"SubType",MyEngineOnCrane.SubType)
						Set(FreshEngine,"CraneUID",this.HomeUID)
						Set(thatLimo2Lesson,"Slot0.i",Get(FreshEngine,"Id.i"))
						Set(thatLimo2Lesson,"Slot0.u",Get(FreshEngine,"Id.u"))
						Set(FreshEngine,"CarrierId.i",Get(thatLimo2Lesson,"Id.i"))
						Set(FreshEngine,"CarrierId.u",Get(thatLimo2Lesson,"Id.u"))
						Set(FreshEngine,"Loaded",true)
						Set(FreshEngine,"CarUID",Get(thatLimo2Lesson,"CarUID"))
						Set(FreshEngine,"LessonSpot",Get(thatLimo2Lesson,"LessonSpot"))
						Set(FreshEngine,"Damage",Get(MyEngineOnCrane,"Damage"))
						Set(thatLimo2Lesson,"EngineDamage",0.69)
						FreshEngine.Tooltip= { "tooltip_limo2lesson",FreshEngine.CarUID,"X",FreshEngine.LessonSpot,"Y" }
						Set(MyCraneBooth,"ttLessonSlot"..this.LessonNr,"Refurbish in progress")
						Set(thatLimo2Lesson,"CountDown",true)
						Set(thatLimo2Lesson,"EngineJobIssued",true)
						Object.CreateJob(thatLimo2Lesson,"RefurbishEngine2")
						Set(MyCraneBooth,"PutEngineInLessonCar"..this.SlotNr,false)
						Set(this,"LessonNr",nil)
						carFound = true
						break
					end
				end
				if carFound == false then
					Set(this,"ErrorLog",this.ErrorLog.."\n |  J5 Limo2Lesson not found.")
					--print("=== ERROR === Limo2Lesson not found")
					Set(MyCraneBooth,"PutEngineInLessonCar"..this.LessonNr,false)
				end
			else
				Set(this,"ErrorLog",this.ErrorLog.."\n |  J6 Limo2Lesson/Limo2OnFloor not found.")
				--print("=== ERROR === Limo2Lesson/Limo2OnFloor not found")
				Set(MyCraneBooth,"BringEngine"..this.SlotNr,false)
				Set(MyCraneBooth,"PutEngineInLessonCar"..this.LessonNr,false)
			end
			nearbyObject = nil
		end
		nearbyObject = nil
		if FreshEngine.CarrierId.i == -1 then
			Set(MyCraneBooth,"BringEngine"..this.SlotNr,false)
			Set(MyCraneBooth,"PutEngineInLessonCar"..this.LessonNr,false)
			--print("=== ERROR === FreshEngine not loaded, something went wrong")
			FreshEngine.Delete()
		end
		Set(MyCrane,"CargoOnHook",nil)
		MyEngineOnCrane.Delete()
		MyEngineOnCrane = nil
	end

	PreparePark()
	Set(this,"UnloadEngine",false)
end

function GateIsClosed(theNr)
	if MyRepairedLimoGate == nil or MyRepairedLimoGate.SubType == nil then FindMyGate() end
	if MyMarker == nil or MyMarker.SubType == nil then
		--print("roadmarker was not found")
		FindMyRoadMarker()
		return false
	end
	
	if Get(MyRepairedLimoGate,"GatePosition") == nil then return false end
	
	if Get(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition")) == "no" and Get(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition")) == "none" then
		Set(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition"),"Repair Spot "..theNr)
		Set(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition"),this.HomeUID)
		Set(MyMarker,"CloseGate"..Get(MyRepairedLimoGate,"GatePosition"),"yes")
		Set(MyRepairedLimoGate,"Mode",1)
		return true
	elseif Get(MyMarker,"Authorized"..Get(MyRepairedLimoGate,"GatePosition")) == this.HomeUID and Get(MyMarker,"RequestFrom"..Get(MyRepairedLimoGate,"GatePosition")) == "Repair Spot "..theNr then
		return true
	else
		return false
	end
end

function PreparePark()
	--print("PreparePark")
	local canPark = true
	if MyMarker == nil or MyMarker.SubType == nil then FindMyRoadMarker() end
	for i=0,15 do
		if Get(MyCraneBooth,"UnloadSlot"..i) == true and Get(MyCraneBooth,"LimoWaitingOnRoad") == "no" and GateIsClosed(i+1) == true then
			canPark = false
			--print("cannot park: must put limo"..(i+1).." on road")
		end
	end
	if (Get(MyCraneBooth,"UnloadTruckSlot0") == true or Get(MyCraneBooth,"UnloadTruckSlot1") == true or Get(MyCraneBooth,"UnloadEngineSlot0") == true or Get(MyCraneBooth,"UnloadEngineSlot1") == true) then
		canPark = false
		--print("cannot park: must unload truck")
	end
	for i=0,15 do
		if Get(MyCraneBooth,"PutEngineInLessonCar"..i) == true then
			canPark = false
			--print("cannot park: must put engine from limo"..(i+1).." in lesson car")
		end
	end
	for i=1,10 do
		if Get(MyCraneBooth,"BringToRack"..i) == true then
			canPark = false
			--print("cannot park: must bring engine from lesson car"..i.." to rack")
		end
	end	
	for i=0,15 do
		if Get(MyCraneBooth,"BringEngine"..i) == true then
			canPark = false
			--print("cannot park: must grab / bring engine to limo"..(i+1))
		end
	end
	if canPark == true then
		--print("preparing park")
		if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
		Set(MyCrane,"MoveToX",this.ParkX)
		Set(MyCrane,"MoveToY",this.ParkY)
		Set(MyCrane,"MoveTheCrane",true)
		BuildTooltip("tooltip_Parkingthecrane")
		Set(MyCrane,"GiveJob","ParkHook")
	else
		Set(MyCraneBooth,"SubType",0)
		Set(MyCraneBooth,"Timer",1.1)
		Set(MyCraneBooth,"BusyDoingJob",false)
	end
end

function ParkHook()
	--print("ParkHook")
	if MyCrane == nil or MyCrane.SubType == nil then FindMyCrane() end
	if MyCraneBooth == nil or MyCraneBooth.SubType == nil then FindMyBooth() end
	Set(MyCrane,"CargoOnHook",nil)
	Set(MyCrane,"Retry",0)
	Set(MyCrane,"GiveJob",nil)
	Set(this,"TruckSlotNr",nil)
	Set(this,"SlotNr",nil)
	Set(this,"LessonNr",nil)
	Set(this,"ParkHook",false)
	BuildTooltip("tooltip_CraneIdle")
	local nearbyObject = Find("GantryCrane2BoothOrder",50)
	if next(nearbyObject) then
		for thatOrder, distance in pairs(nearbyObject) do
			if thatOrder.CarrierId.i == MyCraneBooth.Id.i then
				thatOrder.Delete()	-- Remove the order material on the Processor, so it knows it's done. This cancels the Operate job on this processor.
				--print("Booth order removed")
			end
		end
	end
	nearbyObject = nil
	Set(MyCraneBooth,"SubType",0)
	Set(MyCraneBooth,"Timer",0)
	Set(MyCraneBooth,"BusyDoingJob",false)
end

function Create()
	Set(this,"GrabLimoFromTruck",false)
	Set(this,"GrabLimoFromFloor",false)
	Set(this,"SpawnLimoOnFloor",false)
	Set(this,"UnloadCar",false)
	Set(this,"GrabEngineFromTruck",false)
	Set(this,"GrabEngineFromCar",false)
	Set(this,"SpawnEngineInRack",false)
	Set(this,"GrabEngineFromRack",false)
	Set(this,"BringEngineToRack",false)
	Set(this,"BringEngineToLimo",false)
	Set(this,"UnloadEngine",false)
	Set(this,"ParkHook",false)
	Set(this,"VelX",0)
end

function BuildTooltip(CurrentTask)
	if MyDesk == nil then FindMyDesk() end
	if MyDesk ~= nil then Set(MyDesk,"BuildTooltip",CurrentTask) end
end

function Update(timePassed)
	if timePerUpdate == nil then
		Set(this,"Tooltip","HomeUID: "..this.HomeUID)
		Set(this,"ErrorLog"," ")
		timePerUpdate = 0.5 / this.TimeWarp
		FindMyCrane()
	end
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		if Get(MyCrane,"CraneInPosition") == true then
			if Get(this,"GrabLimoFromTruck") == true then
				GrabLimoFromTruck()
			elseif Get(this,"SpawnLimoOnFloor") == true then
				SpawnLimoOnFloor()
			elseif Get(this,"GrabLimoFromFloor") == true then
				GrabLimoFromFloor()
			elseif Get(this,"UnloadCar") == true then
				UnloadCar()
			elseif Get(this,"GrabEngineFromTruck") == true then
				GrabEngineFromTruck()
			elseif Get(this,"SpawnEngineInRack") == true then
				SpawnEngineInRack()
			elseif Get(this,"GrabEngineFromRack") == true then
				GrabEngineFromRack()
			elseif Get(this,"GrabEngineFromCar") == true then
				GrabEngineFromCar()
			elseif Get(this,"BringEngineToRack") == true then
				BringEngineToRack()
			elseif Get(this,"BringEngineToLimo") == true then
				BringEngineToLimo()
			elseif Get(this,"UnloadEngine") == true then
				UnloadEngine()
			elseif Get(this,"ParkHook") == true then
				ParkHook()
			end
		end
	end
end

	