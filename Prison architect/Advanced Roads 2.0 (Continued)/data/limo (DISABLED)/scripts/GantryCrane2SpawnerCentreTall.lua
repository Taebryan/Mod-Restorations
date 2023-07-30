
local Set = Object.SetProperty
local Get = Object.GetProperty
local timeTot = 0
local timePerUpdate = 1

function Create()
end

function Update(timePassed)
	timeTot = timeTot+timePassed
	if timeTot >= timePerUpdate then
		if not Get(this,"InstallerSpawned") then
			newInstaller = Object.Spawn("GantryCrane2Spawner",this.Pos.x,this.Pos.y)
			Set(newInstaller,"OrigX",this.Pos.x)
			Set(newInstaller,"OrigY",this.Pos.y)
			Set(newInstaller,"OrigXSet",true)
			Set(newInstaller,"GarageSize","Tall")
			Set(newInstaller,"GaragePlacement","Centre")
			Set(newInstaller,"RoadSize","Single")
			Set(newInstaller,"FromPrefab",true)
			Set(newInstaller,"TopOrBottomGarages",true)
			Set(newInstaller,"StartBuilding",true)
			Set(newInstaller,"FoundationDone",true)
			Set(this,"InstallerSpawned",true)
		else
			this.Delete()
		end
	end
end
