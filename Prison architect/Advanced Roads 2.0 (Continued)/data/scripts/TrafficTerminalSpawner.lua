
function Update(timePassed)
	local PosX = math.floor(this.Pos.x)+0.5
	local PosY = math.floor(this.Pos.y)-0.5
	print("PosX: "..PosX.." CellsX: "..World.NumCellsX)
	print("PosY: "..PosY.." CellsY: "..World.NumCellsY)
	if PosX+6.5 >= World.NumCellsX then
		PosX = World.NumCellsX-6.5 
	elseif PosX < 5.5 then
		PosX = 5.5
	end
	
	if PosY+5.5 >= World.NumCellsY then
		PosY = World.NumCellsY-5.5
	elseif PosY-5.5 <= 0 then
		PosY = 5.5
	end
	
	local newTrafficTerminal = Object.Spawn("TrafficTerminal",PosX,PosY)
	this.Delete()
end
