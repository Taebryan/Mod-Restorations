
local timeTot = 0
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

function FindMyCraneRail()
	--print("FindMyCrane")
	local nearbyObject = Find("GantryCrane2RailLeft",50)
	if next(nearbyObject) then
		for thatRail, distance in pairs(nearbyObject) do
			if thatRail.HomeUID==this.CraneUID then
				MyCraneRailLeft=thatRail
				--print("MyCraneRailLeft found")
			end
		end
	end
	nearbyObject = nil
end

function FindMyBooth()
	local nearbyObject = Find("GantryCrane2Booth",50)
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

function FindMyRack()
	local nearbyObject = Find("CarPartsRack2",50)
	if next(nearbyObject) then
		for thatRack, distance in pairs(nearbyObject) do
			if thatRack.HomeUID==this.CraneUID then
				MyRack=thatRack
				--print("MyRack found")
			end
		end
	end
	nearbyObject = nil
end

function FindMyDesk()
	local nearbyObject = Find("Limo2ServiceDesk",50)
	if next(nearbyObject) then
		for thatDesk, distance in pairs(nearbyObject) do
			if thatDesk.HomeUID==this.CraneUID then
				MyDesk=thatDesk
				--print("MyDesk found")
			end
		end
	end
	nearbyObject = nil
end

function FindMyFiller()
	local nearbyObject = Find("GantryRail2SlotFiller",50)
	if next(nearbyObject) then
		for thatFiller, distance in pairs(nearbyObject) do
			if thatFiller.HomeUID==this.CraneUID and thatFiller.SlotNr == this.SlotNr then
				MyFiller=thatFiller
				--print("MyFiller found")
			end
		end
	end
	nearbyObject = nil
end

function FindMyEngine()
	MyEngine = nil
	Set(this,"CountDown",false)
	local nearbyObject = Find("Limo2EngineInCar",3)
	if next(nearbyObject) then
		for thatEngine, distance in pairs(nearbyObject) do
			if thatEngine.CarrierId.i == this.Id.i then
				MyEngine=thatEngine
				Set(this,"CountDown",true)
				MyEngine.Tooltip= { "tooltip_limo2engine",this.CarUID,"X",this.SlotNr+1,"Y" }
				--print("MyEngine found")
			end
		end
	end
	nearbyObject = nil
end

function DeleteMyEngine()
	local nearbyObject = Find("Limo2EngineInCar",3)
	if next(nearbyObject) then
		for thatEngine, distance in pairs(nearbyObject) do
			if thatEngine.CarrierId.i == this.Id.i then
				thatEngine.Delete()
			end
		end
	end
	nearbyObject = nil
	MyEngine = nil
end

function CheckForEngine()
	local itemMissing = false
	if this.CountDown == true and not this.NeedEngine and (MyEngine == nil or MyEngine.SubType == nil) then
		itemMissing = true
	end
	if itemMissing == true then
		if MyCraneBooth == nil then FindMyBooth() end
		Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Empty Repair Spot")
		DeleteMyEngine()
		FindMyFiller()
		MyFiller.Delete()
		this.Delete()
		return
	end
end

function CheckAvailableLessonCars()
	AvailableLessonCars = 0
	if MyCraneBooth == nil then FindMyBooth() end
	for j=1,10 do
		if Get(MyCraneBooth,"Lesson"..j.."ID") ~= "None" and Get(MyCraneBooth,"ttLessonSlot"..j) == "Empty Lesson Spot" then
			--print("Lesson slot "..j.." is free")
			Set(MyCraneBooth,"ttLessonSlot"..j,"Waiting for engine...")
			Set(MyCraneBooth,"PutEngineInLessonCar"..this.SlotNr,true)
			Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Refurbish engine in lesson car")
			AvailableLessonCars = AvailableLessonCars+1
			break
		end
	end
	if AvailableLessonCars == 0 then
		newRubbish = Object.Spawn("Rubble",this.Pos.x+math.random(-1,1),this.Pos.y+1+math.random(-1,1))
		local velX = -1.0 + math.random() + math.random()
		local velY = -1.0 + math.random() + math.random()
		Object.ApplyVelocity(newRubbish, velX, velY)
		newRubbish = Object.Spawn("Rubble",this.Pos.x+math.random(-1,1),this.Pos.y+1+math.random(-1,1))
		local velX = -1.0 + math.random() + math.random()
		local velY = -1.0 + math.random() + math.random()
		Object.ApplyVelocity(newRubbish, velX, velY)
		newRubbish = Object.Spawn("Rubble",this.Pos.x+math.random(-1,1),this.Pos.y+1+math.random(-1,1))
		local velX = -1.0 + math.random() + math.random()
		local velY = -1.0 + math.random() + math.random()
		Object.ApplyVelocity(newRubbish, velX, velY)
		DeleteMyEngine()
		Set(this,"NeedEngine",true)
	end
	Set(this,"CountDown",false)
	nearbyObject = nil
end

function Create()
	Set(this,"CarUID","Limo2_"..me["id-uniqueId"])
	Set(this,"CountDown",false)
	Set(this,"HoodOpen",false)
	Set(this,"CloseHood",false)
	Set(this,"PaintJobPercentageDone",0)
end

function JobComplete_OpenHood2()
	this.SubType = this.SubType + 4
	Set(this,"NeedEngine",false)
	MyEngine = Object.Spawn("Limo2EngineInCar",this.Pos.x+0.250000,this.Pos.y+0.50000)
	Set(MyEngine,"SlotNr",this.SlotNr)
	Set(MyEngine,"CraneUID",Get(this,"CraneUID"))
	Set(MyEngine,"CarUID",Get(this,"CarUID"))
	Set(this,"Slot0.i",Get(MyEngine,"Id.i"))
	Set(this,"Slot0.u",Get(MyEngine,"Id.u"))
	Set(MyEngine,"CarrierId.i",Get(this,"Id.i"))
	Set(MyEngine,"CarrierId.u",Get(this,"Id.u"))
	Set(MyEngine,"Loaded",true)
	MyEngine.Tooltip= { "tooltip_limo2engine",MyEngine.CarUID,"X",MyEngine.SlotNr+1,"Y" }
	tmpDmg = math.random()
	if tmpDmg > 0.69 then tmpDmg = 0.69 end		-- limit damage to 69%, otherwise the engine gets a dump job by the game
	if tmpDmg < 0.10 then tmpDmg = 0.10 end
	Set(MyEngine,"Damage",tmpDmg)
	Set(this,"EngineDamage",MyEngine.Damage)
	Set(MyEngine,"RepairBill",1)
	for i=1,7 do
		if MyEngine.Damage >= i/10 then
			Set(MyEngine,"RepairBill",i)
		end
	end
	if MyDesk == nil then FindMyDesk() end
	if MyEngine.Damage == 0.69 then
		Set(MyDesk,"RepairBill"..this.SlotNr,10)
	else
		Set(MyDesk,"RepairBill"..this.SlotNr,Get(MyEngine,"RepairBill"))
	end
	Set(this,"CountDown",true)
	Set(this,"HoodOpen",true)
end

function JobComplete_CloseHood2()
	DeleteMyEngine()
	this.SubType = this.SubType - 4
	Set(this,"CloseHood",false)
	newLimoRepaired = Object.Spawn("Limo2Repaired", this.Pos.x,this.Pos.y)
	Set(newLimoRepaired,"CarUID",Get(this,"CarUID"))
	Set(newLimoRepaired,"Tooltip",Get(newLimoRepaired,"CarUID"))
	Set(newLimoRepaired,"SubType",Get(this,"SubType"))
	Set(newLimoRepaired,"CraneUID",Get(this,"CraneUID"))
	Set(newLimoRepaired,"GateCount",Get(this,"GateCount"))
	Set(newLimoRepaired,"SlotNr",Get(this,"SlotNr"))
	Set(newLimoRepaired,"Tooltip","CarUID: "..newLimoRepaired.CarUID.."\nRepair Spot: "..(newLimoRepaired.SlotNr+1).."\n\nWaiting for Gantry Crane")
	if MyDesk == nil then FindMyDesk() end
	Set(MyDesk,"WriteBill"..this.SlotNr,true)
	Set(MyDesk,"CarUID"..this.SlotNr,Get(this,"CarUID"))
	if MyCraneBooth == nil then FindMyBooth() end
	Set(MyCraneBooth,"Limo"..this.SlotNr.."ID",newLimoRepaired.Id.i)
	Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Repaired, waiting for bill...")
	Set(MyCraneBooth,"LoadRepairedCars",true)
	this.Delete()
end

function JobComplete_RepairEngine2()
	if MyEngine == nil or MyEngine.SubType == nil then FindMyEngine() end
	if MyEngine ~= nil then
		if Get(MyEngine,"Damage") <= 0.1 then
			Set(MyEngine,"Damage",0)
			Set(this,"EngineDamage",0)
			Set(this,"CountDown",false)
			Set(this,"CloseHood",true)
		else
			Set(MyEngine,"Damage",MyEngine.Damage - 0.1)
			Set(this,"EngineDamage",MyEngine.Damage)
		end
	else
		Set(this,"CountDown",false)
		Set(this,"NeedEngine",true)
		Set(this,"EngineDamage",nil)
		this.Delete()
	end
end

function JobComplete_PaintCar2()
	if this.PaintJobPercentageDone == nil then Set(this,"PaintJobPercentageDone",0) end
	Set(this,"PaintJobPercentageDone",this.PaintJobPercentageDone+25)
	if this.PaintJobPercentageDone >= 100 then
		if MyCraneBooth == nil then FindMyBooth() end
		if MyCraneBooth.IsMilitary == "No" then
			if Get(this,"SubType") <= 1 then
				Set(this,"SubType",this.SubType+1)
			else
				Set(this,"SubType",0)
			end
		end
		newLimoRepaired = Object.Spawn("Limo2Repaired", this.Pos.x,this.Pos.y)
		Set(newLimoRepaired,"CarUID",Get(this,"CarUID"))
		Set(newLimoRepaired,"Tooltip",newLimoRepaired.CarUID)
		Set(newLimoRepaired,"SubType",this.SubType)
		Set(newLimoRepaired,"CraneUID",this.CraneUID)
		Set(newLimoRepaired,"GateCount",this.GateCount)
		Set(newLimoRepaired,"SlotNr",this.SlotNr)
		Set(newLimoRepaired,"Tooltip","CarUID: "..newLimoRepaired.CarUID.."\Paint Spot: "..(newLimoRepaired.SlotNr+1).."\n\nWaiting for Gantry Crane")
		if MyDesk == nil then FindMyDesk() end
		Set(MyDesk,"RepairBill"..this.SlotNr,math.random(1,4))
		Set(MyDesk,"WriteBill"..this.SlotNr,true)
		Set(MyDesk,"CarUID"..this.SlotNr,Get(this,"CarUID"))
		Set(MyCraneBooth,"Limo"..this.SlotNr.."ID",newLimoRepaired.Id.i)
		Set(MyCraneBooth,"ttSlot"..this.SlotNr,"Painted, waiting for bill...")
		Set(MyCraneBooth,"LoadRepairedCars",true)
		this.Delete()
	else
		Set(this,"PaintJobIssued",nil)
	end
end

function JobComplete_MountNewEngine2()
	Set(this,"CloseHood",true)
end

function JobComplete_RemoveEngine2()
	CheckAvailableLessonCars()
end

