
local timeTot = 0
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

function FindMyBooth()
	local nearbyObject = Find("GantryCrane2Booth",50)
	if next(nearbyObject) then
		for thatBooth, distance in pairs(nearbyObject) do
			if thatBooth.HomeUID==this.HomeUID then
				--print("MyCraneBooth found")
				MyCraneBooth=thatBooth
				break
			end
		end
	end
	nearbyObject = nil
end

function FindMyRack()
	local nearbyObject = Find("CarPartsRack2",50)
	if next(nearbyObject) then
		for thatRack, distance in pairs(nearbyObject) do
			if thatRack.HomeUID==this.HomeUID then
				--print("MyRack found")
				MyRack=thatRack
			end
		end
	end
	nearbyObject = nil
end

function FindMyEngine()
	MyEngine = nil
	Set(this,"CountDown",false)
	local nearbyObject = Find("Limo2EngineInLessonCar",3)
	if next(nearbyObject) then
		for thatEngine, distance in pairs(nearbyObject) do
			if thatEngine.Id.i==this.Slot0.i then
				--print("MyEngine found")
				MyEngine=thatEngine
				Set(this,"CountDown",true)
				MyEngine.Tooltip= { "tooltip_limo2lesson",this.CarUID,"X",this.LessonSpot,"Y" }
			end
		end
	end
	nearbyObject = nil
end

function Create()
	Set(this,"CarUID","Limo2Lesson_"..me["id-uniqueId"])
end

function JobComplete_RefurbishEngine2()
	if MyEngine == nil or MyEngine.SubType == nil then FindMyEngine() end
	if MyEngine ~= nil then
		if Get(MyEngine,"Damage") < 0.1 then
			Set(MyEngine,"Damage",0)
			Set(this,"EngineDamage",0)
			Set(this,"CountDown",false)
		else
			Set(MyEngine,"Damage",MyEngine.Damage - 0.1)
			Set(this,"EngineDamage",MyEngine.Damage)
		end
	end
end

function JobComplete_RemoveEngine2()
	if MyCraneBooth == nil then FindMyBooth() end
	Set(MyCraneBooth,"ttLessonSlot"..this.LessonSpot,"Empty Lesson Spot")
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
	if MyEngine == nil or MyEngine.SubType == nil then FindMyEngine() end
	if MyEngine ~= nil then
		this.Slot0.i = -1
		this.Slot0.u = -1
		MyEngine.CarrierId.i = -1
		MyEngine.CarrierId.u = -1
		MyEngine.Loaded = false
		MyEngine.Delete()
	end
	MyEngine = nil
	Set(this,"CountDown",false)
end
