
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects
local driverFound = false

function Create()
	Set(this,"HomeUID","RepairedLimo_"..me["id-uniqueId"])
	Set(this,"VelX",0)
	Set(this,"VelY",0)
	Set(this,"Tooltip","HomeUID: "..this.HomeUID.."\nWaiting for driver...")
end

function FindMyCrane()
	--print("FindMyCrane")
    nearbyObject = Find("GantryCrane2",50)
	if next(nearbyObject) then
		for thatCrane, distance in pairs(nearbyObject) do
			if thatCrane.HomeUID==this.CraneUID then
				MyCrane=thatCrane
				--print("MyCrane found")
			end
		end
	end
	nearbyObject = Find("GantryCrane2Booth",50)
	if next(nearbyObject) then
		for thatBooth, distance in pairs(nearbyObject) do
			if thatBooth.HomeUID==this.CraneUID then
				MyCraneBooth=thatBooth
				--print("MyCraneBooth found")
			end
		end
	end
	nearbyObject = nil
end

function FindMyRoadMarker()
	--print("FindMyRoadMarker")
    local nearbyObject = Find(this,"RoadMarker2",1500)
	if next(nearbyObject) then
		--print("some markers found")
		for thatMarker,dist in pairs(nearbyObject) do
			--print("marker pos.x: "..thatMarker.Pos.x.." this x: "..this.Pos.x)
			if thatMarker.Pos.x>=this.Pos.x-0.25 and thatMarker.Pos.x<=this.Pos.x+0.25 then
				MyMarker=thatMarker
				this.Pos.x = MyMarker.Pos.x
				--print("marker found")
				Set(this,"MarkerUID",Get(thatMarker,"MarkerUID"))
				markerFound = true
				break
			end
		end
	end
	nearbyObject = nil
end

function FindNextGateNr()
	--print("FindNextGateNr")
	FindMyRoadMarker()
	for i=1,10 do
		if Get(MyMarker,"GatePosY"..i) ~= nil then
			--print("comparing: "..Get(MyMarker,"GatePosY"..i).." with "..this.Pos.y)
			if this.Pos.y <= Get(MyMarker,"GatePosY"..i) then
				if i ~= this.GateCount then
					--print("Gate count was"..this.GateCount..", setting to "..i)
					Set(this,"GateCount",i)
				end
				break
			end
			--print("gatecount: "..this.GateCount)
		end
	end
end

function JobComplete_LimoDriverLeaving()
	FindMyCrane()
	Set(MyCraneBooth,"LimoWaitingOnRoad","no")
	nearbyObject = Find("Limo2DriverLeaving",500)
	if next(nearbyObject) then
		for thatEntity, distance in pairs(nearbyObject) do
			if thatEntity.CarUID == this.CarUID then
			--	thatEntity.Delete()
				MyDriver = thatEntity
				break
			end
		end
	end
	nearbyObject = nil

	FindNextGateNr()
	Set(this,"VehicleState","Processing")
	--print("release gate behind me")
	Set(MyMarker,"RequestFrom"..this.GateCount-1,"none")
	Set(MyMarker,"Authorized"..this.GateCount-1,"no")
	Set(MyMarker,"CloseGate"..this.GateCount-1,"no")
	--print("setting gatecount: "..this.GateCount)
	--print("release gate in front")
	Set(MyMarker,"RequestFrom"..this.GateCount,"none")
	Set(MyMarker,"Authorized"..this.GateCount,"no")
	Set(MyMarker,"CloseGate"..this.GateCount,"no")
		
	FreshCar = Object.Spawn("Limo2",MyMarker.Pos.x,this.Pos.y)
	Set(FreshCar,"SubType",this.SubType)
	--Set(FreshCar,"GateCount",this.GateCount)
	Set(FreshCar,"MarkerUID",this.MarkerUID)
	Set(FreshCar,"CraneUID",this.CraneUID)
	Set(FreshCar,"CarUID",this.CarUID)
	
	if MyCraneBooth.IsMilitary == "Yes" then
		Set(FreshCar,"IsMilitary","Yes")
		FreshCar.SubType = 4
		FreshCarWindow = Object.Spawn("Limo2Window",MyMarker.Pos.x,this.Pos.y)
		Set(FreshCarWindow,"CarUID",this.CarUID)
		Set(FreshCar,"Slot0.i",FreshCarWindow.Id.i)
		Set(FreshCar,"Slot0.u",FreshCarWindow.Id.u)
		Set(FreshCarWindow,"CarrierId.i",FreshCar.Id.i)
		Set(FreshCarWindow,"CarrierId.u",FreshCar.Id.u)
		FreshCarWindow.Loaded = true
		Set(FreshCar,"Slot1.i",MyDriver.Id.i)
		Set(FreshCar,"Slot1.u",MyDriver.Id.u)
		Set(MyDriver,"CarrierId.i",FreshCar.Id.i)
		Set(MyDriver,"CarrierId.u",FreshCar.Id.u)
		MyDriver.Loaded = true
	else
		MyDriver.Delete()
	end
	this.Delete()
end
