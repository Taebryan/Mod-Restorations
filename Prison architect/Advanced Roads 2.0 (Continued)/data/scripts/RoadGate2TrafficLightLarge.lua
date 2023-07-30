
local timeTot = 0
local MySubType=0
local Get=Object.GetProperty
local Set=Object.SetProperty
local Find=this.GetNearbyObjects

function FindMyRoadGate()
	local nearbyObject = Find("RoadGate2Large",4)
	if next(nearbyObject) then
		for thatGate, distance in pairs(nearbyObject) do
			if this.GateUID ~= nil and thatGate.GateUID == this.GateUID then
				MyRoadGate = thatGate
				print("Found RoadGate2Large with GateUID "..thatGate.GateUID.." at dist "..distance)
				break
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
		timePerUpdate = 0.2 / World.TimeWarpFactor
	end
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		if ( this.Triggered or 0 ) > 0 then
			MyRoadGate.PeopleCrossingStreet = true
			-- if MyRoadGate.TrafficL == nil and MyRoadGate.TrafficR == nil then
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
				CrossingTimer = 0
				this.SubType = this.LightType
				MyRoadGate.PeopleCrossingStreet = nil
			elseif this.LeftSide == true and MyRoadGate.TrafficL == true then
				this.SubType = this.LightType + math.ceil(MyRoadGate.Open)
			elseif this.RightSide == true and MyRoadGate.TrafficR == true then
				this.SubType = this.LightType + math.ceil(MyRoadGate.Open)
			else
				this.SubType = this.LightType
			end
		end
		this.Tooltip = MyRoadGate.Tooltip
	end
end
