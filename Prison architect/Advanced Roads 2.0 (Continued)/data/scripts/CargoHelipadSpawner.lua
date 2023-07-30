
function Update(timePassed)
	local newCargoHelipad = Object.Spawn("CargoHelipad",math.floor(this.Pos.x)+0.5,math.floor(this.Pos.y)+4.5)
	newCargoHelipad.HelipadFloor = "Compact"
	newCargoHelipad.CargoType = "Deliveries"
	newCargoHelipad.SubType = 8
	this.Delete()
end
