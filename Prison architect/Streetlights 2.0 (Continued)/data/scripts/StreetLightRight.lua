
function Create()
	newLight = Object.Spawn( "Light", this.Pos.x-0.550000,this.Pos.y-1.32000)
	Object.SetProperty(newLight,"Or.x",-1)
	Object.SetProperty(newLight,"Or.y",0)
end
