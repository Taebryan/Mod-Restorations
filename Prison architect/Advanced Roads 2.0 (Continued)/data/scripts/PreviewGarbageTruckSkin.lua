
local timePerUpdate = 3

function Create()
	this.TimeTot = 0
end

function Update(timePassed)
	this.TimeTot = this.TimeTot + timePassed
	if this.TimeTot > timePerUpdate then
		this.Delete()
	end
end
