
function Update(timePassed)
	local newCargoHelipad = Object.Spawn("CargoHelipad",math.floor(this.Pos.x)+7.5,math.floor(this.Pos.y)-1.5)
	newCargoHelipad.HelipadFloor = "Large"
	newCargoHelipad.CargoType = "Intake"
	newCargoHelipad.SubType = 8
	this.Delete()
end
