
function Update(timePassed)
	local newRoadGate = Object.Spawn("RoadGate2Small",math.floor(this.Pos.x)+1,math.floor(this.Pos.y)-0.5)
	this.Delete()
end
