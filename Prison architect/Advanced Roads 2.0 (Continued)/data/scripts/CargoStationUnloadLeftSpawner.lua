
local Set = Object.SetProperty

function Update(timePassed)
	local PosX = math.floor(this.Pos.x)+4.5
	local PosY = math.floor(this.Pos.y)+0.5
	print("PosX: "..PosX.." CellsX: "..World.NumCellsX)
	print("PosY: "..PosY.." CellsY: "..World.NumCellsY)
	if PosX+8.5 >= World.NumCellsX then
		PosX = World.NumCellsX-8.5 
	elseif PosX < 5.5 then
		PosX = 5.5
	end
	
	if PosY+9.5 >= World.NumCellsY then
		PosY = World.NumCellsY-9.5
	elseif PosY-17.5 <= 0 then
		PosY = 17.5
	end
	
	local newCargoStation = Object.Spawn("CargoStation",PosX,PosY)
	Set(newCargoStation,"CargoSide","LEFT")
	Set(newCargoStation,"CargoFloor","COMPACT")
	Set(newCargoStation,"SubType",5)
	this.Delete()
end
