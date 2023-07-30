
local timeTot = 0
local MySubType=0
local Get=Object.GetProperty
local Set=Object.SetProperty
local Find=this.GetNearbyObjects

function FindMyRoadGate()
	local nearbyObject = Find("RoadGate2Small",4)
	if next(nearbyObject) then
		--print("Found some SmallRoadGates")
		for thatGate, distance in pairs(nearbyObject) do
			if this.GateUID ~= nil and thatGate.GateUID == this.GateUID then
				MyRoadGate = thatGate
				--print("Found gate with GateUID "..thatGate.GateUID.." at dist "..distance)
				break
			elseif this.HomeUID ~= nil and thatGate.HomeUID == this.HomeUID then
				if thatGate.OpenDir.x == 2 and this.Pos.x < thatGate.Pos.x then
					MyRoadGate = thatGate
					--print("Found gate to the right with HomeUID "..thatGate.HomeUID.." at dist "..distance)
					break
				elseif thatGate.OpenDir.x == -2 and this.Pos.x > thatGate.Pos.x then
					MyRoadGate = thatGate
					--print("Found gate to the left with HomeUID "..thatGate.HomeUID.." at dist "..distance)
					break
				elseif this.SideLaneLight == true then
					MyRoadGate = thatGate
					--print("I'm a sidelane light with HomeUID "..thatGate.HomeUID.." at dist "..distance)
					break
				end
			end
		end
	end
	if MyRoadGate == nil then
		RemoveLeftOvers()
	end
end

function Create()
end

function Update(timePassed)
	if timePerUpdate==nil then
		FindMyRoadGate()
		CrossingTimer = 0
		PeopleCrossing = true
		if not this.SideLaneLight then
			timePerUpdate = 0.2 / World.TimeWarpFactor
			CheckCrossing = true
		else
			timePerUpdate = 1
			CheckCrossing = false
		end
		--MySubType = Get(this,"LightType")
	end
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		if CheckCrossing == true then
			if ( this.Triggered or 0 ) > 0 then
				MyRoadGate.PeopleCrossingStreet = true
				-- if MyRoadGate.Traffic == nil then
					-- MyRoadGate.Mode = 1
					-- MyRoadGate.CloseTimer = 0.1
				-- end
				CrossingTimer = 1
				PeopleCrossing = true
			end
			if CrossingTimer > 0 then
				if this.SubType == this.LightType then this.SubType = this.LightType + 2 else this.SubType = this.LightType end
				CrossingTimer = CrossingTimer - 1
			else
				if PeopleCrossing == true then
					PeopleCrossing = false
					this.SubType = this.LightType
					MyRoadGate.PeopleCrossingStreet = nil
				end
				this.SubType = this.LightType + math.ceil(MyRoadGate.Open)
			end
			this.Tooltip = MyRoadGate.Tooltip
		end
	end
end
