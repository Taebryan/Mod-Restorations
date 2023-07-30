
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects
local timeTot = 0
local timeAnim = 0
local offSet = 0
local reachedY = false
local reachedX = false

-------------------- Find Stuff -------------------------

function FindMyCrane()
    local nearbyObject = Find("GantryCrane2Hook",50)
	if next(nearbyObject) then
		for thatHook, distance in pairs(nearbyObject) do
			if thatHook.HomeUID==this.HomeUID then
				MyHook=thatHook
			end
		end
	end
    nearbyObject = Find("GantryCrane2Wheel",50)
	if next(nearbyObject) then
		for thatCraneWheel, distance in pairs(nearbyObject) do
			if thatCraneWheel.HomeUID==this.HomeUID and thatCraneWheel.Pos.x<this.Pos.x then
				MyCraneWheelLeft=thatCraneWheel
			end
			if thatCraneWheel.HomeUID==this.HomeUID and thatCraneWheel.Pos.x>this.Pos.x then
				MyCraneWheelRight=thatCraneWheel
			end
		end
	end
	nearbyObject = nil
	
	timePerUpdate = 2 / this.TimeWarp
end

function FindMyCargo()
	if not Get(this,"CargoOnHook") then
		cargoFound = false
		Set(this,"Retry",0)
		--Set(this,"ErrorLog"," ")
	else
		cargoFound = nil
		local nearbyObject = Find(MyHook,"Limo2OnCrane",this.Retry+1)
		if next(nearbyObject) then
			for thatCargo, distance in pairs(nearbyObject) do
				--print("Limo2OnCrane found at distance "..distance)
				MyCargo = thatCargo
				cargoFound = true
				offSet = 0.75
				nearbyObject=nil
				break
			end
		end
		nearbyObject=nil
		if cargoFound == nil then
			local nearbyObject = Find(MyHook,"Limo2EngineOnCrane",this.Retry+1)
			if next(nearbyObject) then
				for thatCargo, distance in pairs(nearbyObject) do
					--print("Limo2EngineOnCrane found at distance "..distance)
					MyCargo = thatCargo
					cargoFound = true
					offSet = 0.17
					break
				end
			end
			nearbyObject=nil
		end
		if cargoFound == nil then
			this.Retry = this.Retry+1
			Set(this,"ErrorLog","\n |  Cargo not found, retry: "..this.Retry)
			timePerUpdate = 2 / this.TimeWarp
			if this.Retry > 10 then cargoFound = false end
		else
			MyCargo.Pos.y = MyHook.Pos.y+offSet
			MyCargo.Pos.x = MyHook.Pos.x
			timePerUpdate = 0.5 / this.TimeWarp
		end
	end
end
	
-------------------- Done finding  ----------------------


-------------------- Animate crane ----------------------

function AnimCrane()
	if timeAnim > 0.25 then
		if MyHook.SubType==1 then MyHook.SubType=2 else MyHook.SubType=1 end
		timeAnim = 0
	end
end

function AnimWheel()
	if timeAnim > 0.25 then
		if MyHook.SubType==1 then MyHook.SubType=2 else MyHook.SubType=1 end
		if MyCraneWheelLeft.SubType==1 then
			MyCraneWheelLeft.SubType=0
			MyCraneWheelRight.SubType=0
		else
			MyCraneWheelLeft.SubType=1
			MyCraneWheelRight.SubType=1
		end
		timeAnim = 0
	end
end

-------------------- End Animation ----------------------


-------------------- Move Crane -------------------------

function MoveCraneY(TargetPos)
	local ToPosY = 0
	if TargetPos == this.MoveToY then ToPosY = this.MoveToY else ToPosY = this.TmpY end
	if cargoFound == nil then FindMyCargo() return end
	
	if this.Pos.y >= ToPosY-0.01 and this.Pos.y <= ToPosY+0.01 and reachedY == false then
		Object.ApplyVelocity(this,0,0)
		Object.ApplyVelocity(MyHook,0,0)
		Object.ApplyVelocity(MyCraneWheelLeft,0,0)
		Object.ApplyVelocity(MyCraneWheelRight,0,0)
		if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.y = ToPosY+offSet end
		this.Pos.y = ToPosY
		MyHook.Pos.y = ToPosY
		MyCraneWheelLeft.Pos.y = ToPosY-0.25
		MyCraneWheelRight.Pos.y = ToPosY-0.25
		reachedY=true
		this.DirectionSet = nil
		--print("--MoveTheCrane: this.Pos.y: "..this.Pos.y.." ToPosY: "..ToPosY.." crane is at target Y position")
	elseif reachedY == false then
		AnimWheel()
		if this.Pos.y >= ToPosY then
			if (this.StartingFrom - this.Pos.y < this.CraneSpeed) and (this.Pos.y - ToPosY > this.CraneSpeed) then
				Object.ApplyVelocity(this,0,-(this.StartingFrom+0.75 - this.Pos.y))
				Object.ApplyVelocity(MyHook,0,-(this.StartingFrom+0.75 - this.Pos.y))
				Object.ApplyVelocity(MyCraneWheelLeft,0,-(this.StartingFrom+0.75 - this.Pos.y))
				Object.ApplyVelocity(MyCraneWheelRight,0,-(this.StartingFrom+0.75 - this.Pos.y))
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,-(this.StartingFrom+0.75 - this.Pos.y),false) end
				--print("--MoveTheCrane: this.Pos.y >= ToPosY -- Move "..this.Direction.." at speed: "..(this.StartingFrom+0.75 - this.Pos.y))
			elseif (this.StartingFrom - this.Pos.y < this.CraneSpeed) and (this.StartingFrom - ToPosY < this.CraneSpeed) then
				Object.ApplyVelocity(this,0,-0.75)
				Object.ApplyVelocity(MyHook,0,-0.75)
				Object.ApplyVelocity(MyCraneWheelLeft,0,-0.75)
				Object.ApplyVelocity(MyCraneWheelRight,0,-0.75)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,-0.75,false) end
				--print("--MoveTheCrane: this.Pos.y >= ToPosY -- Move "..this.Direction.." at speed: 0.75")
			elseif this.Pos.y - ToPosY > this.CraneSpeed then
				Object.ApplyVelocity(this,0,-this.CraneSpeed)
				Object.ApplyVelocity(MyHook,0,-this.CraneSpeed)
				Object.ApplyVelocity(MyCraneWheelLeft,0,-this.CraneSpeed)
				Object.ApplyVelocity(MyCraneWheelRight,0,-this.CraneSpeed)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,-this.CraneSpeed,false) end
				--print("--MoveTheCrane: Move "..this.Direction.." at full crane speed")
			elseif this.Pos.y - ToPosY > 0 then
				Object.ApplyVelocity(this,0,-(this.Pos.y+0.75 - ToPosY))
				Object.ApplyVelocity(MyHook,0,-(this.Pos.y+0.75 - ToPosY))
				Object.ApplyVelocity(MyCraneWheelLeft,0,-(this.Pos.y+0.75 - ToPosY))
				Object.ApplyVelocity(MyCraneWheelRight,0,-(this.Pos.y+0.75 - ToPosY))
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,-(this.Pos.y+0.75 - ToPosY),false) end
				--print("--MoveTheCrane: Move "..this.Direction.." at speed: "..(this.Pos.y+0.75 - ToPosY))
			else
				Object.ApplyVelocity(this,0,0)
				Object.ApplyVelocity(MyHook,0,0)
				Object.ApplyVelocity(MyCraneWheelLeft,0,0)
				Object.ApplyVelocity(MyCraneWheelRight,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.y = ToPosY+offSet end
				this.Pos.y = ToPosY
				MyHook.Pos.y = ToPosY
				MyCraneWheelLeft.Pos.y = ToPosY-0.25
				MyCraneWheelRight.Pos.y = ToPosY-0.25
				reachedY=true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane arrived at target Y position")
			end
			if this.Direction == "down" and reachedY == false then	-- if crane went too fast then lock it to its target position (this can happen when game speed is set to fast forward)
				Object.ApplyVelocity(this,0,0)
				Object.ApplyVelocity(MyHook,0,0)
				Object.ApplyVelocity(MyCraneWheelLeft,0,0)
				Object.ApplyVelocity(MyCraneWheelRight,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.y = ToPosY+offSet end
				this.Pos.y = ToPosY
				MyHook.Pos.y = ToPosY
				MyCraneWheelLeft.Pos.y = ToPosY-0.25
				MyCraneWheelRight.Pos.y = ToPosY-0.25
				reachedY=true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane went down too fast, locking at target Y position")
			end
		elseif this.Pos.y <= ToPosY then
			if (this.Pos.y - this.StartingFrom < this.CraneSpeed) and (ToPosY - this.Pos.y > this.CraneSpeed) then
				Object.ApplyVelocity(this,0,this.Pos.y+0.75 - this.StartingFrom)
				Object.ApplyVelocity(MyHook,0,this.Pos.y+0.75 - this.StartingFrom)
				Object.ApplyVelocity(MyCraneWheelLeft,0,this.Pos.y+0.75 - this.StartingFrom)
				Object.ApplyVelocity(MyCraneWheelRight,0,this.Pos.y+0.75 - this.StartingFrom)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,this.Pos.y+0.75 - this.StartingFrom,false) end
				--print("--MoveTheCrane: this.Pos.y <= ToPosY -- Move "..this.Direction.." at speed: "..(this.Pos.y+0.75 - this.StartingFrom))
			elseif (this.Pos.y - this.StartingFrom < this.CraneSpeed) and (ToPosY - this.StartingFrom < this.CraneSpeed) then
				Object.ApplyVelocity(this,0,0.75)
				Object.ApplyVelocity(MyHook,0,0.75)
				Object.ApplyVelocity(MyCraneWheelLeft,0,0.75)
				Object.ApplyVelocity(MyCraneWheelRight,0,0.75)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0.75,false) end
				--print("--MoveTheCrane: this.Pos.y <= ToPosY -- Move "..this.Direction.." at speed: 0.75")
			elseif ToPosY - this.Pos.y > this.CraneSpeed then
				Object.ApplyVelocity(this,0,this.CraneSpeed)
				Object.ApplyVelocity(MyHook,0,this.CraneSpeed)
				Object.ApplyVelocity(MyCraneWheelLeft,0,this.CraneSpeed)
				Object.ApplyVelocity(MyCraneWheelRight,0,this.CraneSpeed)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,this.CraneSpeed,false) end
				--print("--MoveTheCrane: Move "..this.Direction.." at full crane speed")
			elseif ToPosY - this.Pos.y > 0 then
				Object.ApplyVelocity(this,0,ToPosY+0.75 - this.Pos.y)
				Object.ApplyVelocity(MyHook,0,ToPosY+0.75 - this.Pos.y)
				Object.ApplyVelocity(MyCraneWheelLeft,0,ToPosY+0.75 - this.Pos.y)
				Object.ApplyVelocity(MyCraneWheelRight,0,ToPosY+0.75 - this.Pos.y)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,ToPosY+0.75 - this.Pos.y,false) end
				--print("--MoveTheCrane: Move "..this.Direction.." at speed: "..(ToPosY+0.75 - this.Pos.y))
			else
				Object.ApplyVelocity(this,0,0)
				Object.ApplyVelocity(MyHook,0,0)
				Object.ApplyVelocity(MyCraneWheelLeft,0,0)
				Object.ApplyVelocity(MyCraneWheelRight,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.y = ToPosY+offSet end
				this.Pos.y = ToPosY
				MyHook.Pos.y = ToPosY
				MyCraneWheelLeft.Pos.y = ToPosY-0.25
				MyCraneWheelRight.Pos.y = ToPosY-0.25
				reachedY=true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane arrived at target Y position")
			end
			if this.Direction == "up" and reachedY == false then	-- if crane went too fast then lock it to its target position (this can happen when game speed is set to fast forward)
				Object.ApplyVelocity(this,0,0)
				Object.ApplyVelocity(MyHook,0,0)
				Object.ApplyVelocity(MyCraneWheelLeft,0,0)
				Object.ApplyVelocity(MyCraneWheelRight,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.y = ToPosY+offSet end
				this.Pos.y = ToPosY
				MyHook.Pos.y = ToPosY
				MyCraneWheelLeft.Pos.y = ToPosY-0.25
				MyCraneWheelRight.Pos.y = ToPosY-0.25
				reachedY=true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane went up too fast, locking at target Y position")
			end
		end
	end
end

function MoveCraneX(TargetPos)
	local ToPosX = 0
	if TargetPos == this.MoveToX then ToPosX = this.MoveToX else ToPosX = this.TmpX end
	if cargoFound == nil then FindMyCargo() return end
	
	if MyHook.Pos.x >= ToPosX-0.01 and MyHook.Pos.x <= ToPosX+0.01 and reachedX == false then
		Object.ApplyVelocity(MyHook,0,0)
		if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.x = ToPosX end
		MyHook.Pos.x = ToPosX
		reachedX = true
		this.DirectionSet = nil
		--print("--MoveTheCrane: MyHook.Pos.x: "..MyHook.Pos.x.." ToPosX: "..ToPosX.." crane is at target X position")
	elseif reachedX == false then
		AnimCrane()
		if MyHook.Pos.x > ToPosX then
			if this.StartingFrom - MyHook.Pos.x < this.CraneSpeed and (MyHook.Pos.x - ToPosX > this.CraneSpeed) then
				Object.ApplyVelocity(MyHook,-(this.StartingFrom+0.75 - MyHook.Pos.x),0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,-(this.StartingFrom+0.75 - MyHook.Pos.x),0,false) end
				--print("--MoveTheCrane: MyHook.Pos.x > ToPosX -- Move "..this.Direction.." at speed: "..(this.StartingFrom+0.75 - MyHook.Pos.x))
			elseif this.StartingFrom - MyHook.Pos.x < this.CraneSpeed and (this.StartingFrom - ToPosX < this.CraneSpeed) then
				Object.ApplyVelocity(MyHook,-0.75,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,-0.75,0,false) end
				--print("--MoveTheCrane: MyHook.Pos.x > ToPosX -- Move "..this.Direction.." at speed: 0.75")
			elseif MyHook.Pos.x - ToPosX > this.CraneSpeed then
				Object.ApplyVelocity(MyHook,-this.CraneSpeed,0)
				--print("--MoveTheCrane: Move "..this.Direction.." at full crane speed")
				if cargoFound == true then Object.ApplyVelocity(MyCargo,-this.CraneSpeed,0,false) end
			elseif MyHook.Pos.x - ToPosX > 0 then
				Object.ApplyVelocity(MyHook,-(MyHook.Pos.x+0.75 - ToPosX),0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,-(MyHook.Pos.x+0.75 - ToPosX),0,false) end
				--print("--MoveTheCrane: Move "..this.Direction.." at speed: "..(MyHook.Pos.x+0.75 - ToPosX))
			else
				Object.ApplyVelocity(MyHook,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.x = ToPosX end
				MyHook.Pos.x = ToPosX
				reachedX = true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane arrived at target X position")
			end
			if this.Direction == "right" and reachedX == false then	-- if crane went too fast then lock it to its target position (this can happen when game speed is set to fast forward)
				Object.ApplyVelocity(MyHook,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.x = ToPosX end
				MyHook.Pos.x = ToPosX
				reachedX = true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane went too fast to the right, locking at target X position")
			end
			MyHook.Triggered = 2
		elseif MyHook.Pos.x < ToPosX then
			if MyHook.Pos.x - this.StartingFrom < this.CraneSpeed and (ToPosX - MyHook.Pos.x > this.CraneSpeed) then
				Object.ApplyVelocity(MyHook,MyHook.Pos.x+0.75 - this.StartingFrom,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,MyHook.Pos.x+0.75 - this.StartingFrom,0,false) end
				--print("--MoveTheCrane: MyHook.Pos.x < ToPosX -- Move "..this.Direction.." at speed: "..(MyHook.Pos.x+0.75 - this.StartingFrom))
			elseif MyHook.Pos.x - this.StartingFrom < this.CraneSpeed and (ToPosX - this.StartingFrom < this.CraneSpeed) then
				Object.ApplyVelocity(MyHook,0.75,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0.75,0,false) end
				--print("--MoveTheCrane: MyHook.Pos.x < ToPosX -- Move "..this.Direction.." at speed: 0.75")
			elseif ToPosX - MyHook.Pos.x > this.CraneSpeed then
				Object.ApplyVelocity(MyHook,this.CraneSpeed,0)
				--print("--MoveTheCrane: Move "..this.Direction.." at full crane speed")
				if cargoFound == true then Object.ApplyVelocity(MyCargo,this.CraneSpeed,0,false) end
			elseif ToPosX - MyHook.Pos.x > 0 then
				Object.ApplyVelocity(MyHook,ToPosX+0.75 - MyHook.Pos.x,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,ToPosX+0.75 - MyHook.Pos.x,0,false) end
				--print("--MoveTheCrane: Move "..this.Direction.." at speed: "..(ToPosX+0.75 - MyHook.Pos.x))
			else
				Object.ApplyVelocity(MyHook,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.x = ToPosX end
				MyHook.Pos.x = ToPosX
				reachedX = true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane arrived at target X position")
			end
			if this.Direction == "left" and reachedX == false then	-- if crane went too fast then lock it to its target position (this can happen when game speed is set to fast forward)
				Object.ApplyVelocity(MyHook,0,0)
				if cargoFound == true then Object.ApplyVelocity(MyCargo,0,0,false); MyCargo.Pos.x = ToPosX end
				MyHook.Pos.x = ToPosX
				reachedX = true
				this.DirectionSet = nil
				--print("--MoveTheCrane: Crane went too fast to the left, locking at target X position")
			end
		end
	end
end

function MoveTheCrane()
	if cargoFound == nil then FindMyCargo() return end
	timePerUpdate = 0
	Set(this,"CraneInPosition",false)
	if Get(this,"CraneInPosition") == false then
		if not this.DirectionSet then
			if this.Pos.y < this.MoveToY then
				Set(this,"Direction","down")
			elseif this.Pos.y > this.MoveToY then
				Set(this,"Direction","up")
			end
			Set(this,"StartingFrom",this.Pos.y)
			--print("StartingFromY "..this.Pos.y.." and moving to Y "..this.MoveToY)
			this.DirectionSet = true
		end
		MoveCraneY(this.MoveToY)
		if reachedY == true then
			if not this.DirectionSet then
				if MyHook.Pos.x < this.MoveToX then
					Set(this,"Direction","right")
				elseif MyHook.Pos.x > this.MoveToX then
					Set(this,"Direction","left")
				end
				Set(this,"StartingFrom",MyHook.Pos.x)
				--print("StartingFromX: "..MyHook.Pos.x.." and moving to X "..this.MoveToX)
				this.DirectionSet = true
			end
			MoveCraneX(this.MoveToX)
		end
		if reachedX == true and reachedY == true then
			MyHook.SubType=0
			Set(this,"CraneInPosition",true)
			Set(this,"MoveTheCrane",false)
			Set(this,"StartingFrom",nil)
			Set(this,"MoveToX",nil)
			Set(this,"MoveToY",nil)
			Set(this,"Retry",0)
			cargoFound = nil
			reachedY = false
			reachedX = false
			Set(MyHook,this.GiveJob,true)
			--print("--MoveTheCrane: Crane in position")
		end
	end
end

-------------------- Done moving -------------------------


-------------------- Create and Update -------------------------

function Create()
	Set(this,"CraneSpeed",1.5)
end

function Update(timePassed)
	if timePerUpdate == nil then
		if this.Retry == nil then Set(this,"Retry",0) end
		Set(this,"ErrorLog"," ")
		Set(this,"Tooltip","HomeUID: "..this.HomeUID)
		FindMyCrane()
		if Get(this,"CraneInPosition") == true and Get(this,"GiveJob") ~= nil then Set(MyHook,this.GiveJob,true) end
	end
	timeAnim = timeAnim + timePassed
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		
		if this.ResetCargo == true then
			cargoFound = nil
			reachedY = false
			reachedX = false
			this.ResetCargo = false
			this.CargoOnHook = nil
			this.Retry = 0
		end
		
		if Get(this,"MoveTheCrane") == true and (this.MoveToY or 0) > 0 then
			MoveTheCrane()
		else
			timePerUpdate = 0.5 / this.TimeWarp
		end
	end
end

