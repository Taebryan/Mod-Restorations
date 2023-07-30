
function Update(timePassed)
	local newRoadGate = Object.Spawn("RoadGate2Large",math.floor(this.Pos.x)+2.5,math.floor(this.Pos.y)-1.5)
	this.Delete()
end
