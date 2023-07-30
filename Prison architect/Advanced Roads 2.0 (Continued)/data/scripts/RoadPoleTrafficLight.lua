
local timeTot = 0
local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

function Update(timePassed)
	if timePerUpdate==nil then
		timePerUpdate = 0.5 / World.TimeWarpFactor
	end
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		if this.SubType < 2 then
			MyTrafficLight = Object.Spawn("RoadGate2TrafficLightSmall",this.Pos.x,this.Pos.y)
			MyTrafficLight.SubType = this.SubType
			Set(MyTrafficLight,"LightType",0)
			Set(MyTrafficLight,"HomeUID",this.HomeUID)
			Set(MyTrafficLight,"Tooltip",this.Tooltip)
			if Get(this,"SideLaneLight") == true then
				Set(MyTrafficLight,"SideLaneLight",this.SideLaneLight)
				local nearbyObject = Find("RoadPoleStart",5)
				if next(nearbyObject) then
					for thatPole, distance in pairs(nearbyObject) do
						if thatPole.HomeUID == this.HomeUID then
							Set(MyTrafficLight,"LightType",2)
							Set(MyTrafficLight,"SubType",2)
							thatPole.Slot0.i = MyTrafficLight.Id.i
							thatPole.Slot0.u = MyTrafficLight.Id.u
							MyTrafficLight.CarrierId.i = thatPole.Id.i
							MyTrafficLight.CarrierId.u = thatPole.Id.u
							MyTrafficLight.Loaded = true
							break
						end
					end
				end
				nearbyObject = nil
			end
		end
		this.Delete()
	end
end
