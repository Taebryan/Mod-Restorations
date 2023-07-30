
local timeTot = 0
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

function FindMyGantryCrane()
	local craneFound = false
    local nearbyCranes = Find(this,"GantryCrane2Spawner",50)
	if next(nearbyCranes) then
		for thatCrane,dist in pairs(nearbyCranes) do
			if Get(thatCrane,"FoundationDone") == true then
				Xmin = math.floor(thatCrane.OrigX) + math.ceil(thatCrane.Xmin)
				Xmax = math.floor(thatCrane.OrigX) + math.ceil(thatCrane.Xmax) - 1
				Ymin = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymin)
				Ymax = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymax) - 1
				
				if this.Pos.x >= Xmin and this.Pos.x <= Xmax and this.Pos.y >= Ymin and this.Pos.y <= Ymax then
					Set(this,"HomeUID",thatCrane.HomeUID)
					MyCrane = thatCrane
					craneFound = true
					break
				end
			end
		end
		if craneFound == false then
			--print("no crane found, delete")
			this.Delete()
		end
	else
		--print("no crane found, delete")
		this.Delete()
	end
	
	if MyCrane.IsMilitary == "Yes" then this.SubType = 1 end
	local Max = 10
	local LimoCounter = 1
	local nearbyLimos = Find(this,"Limo2LessonPreview",50)
	for thatLimo, dist in pairs(nearbyLimos) do
		if thatLimo.HomeUID == this.HomeUID and thatLimo.Id.i ~= this.Id.i then
			LimoCounter = LimoCounter + 1
		end
	end
	if LimoCounter > Max then
		this.Delete()
	else
		Set(this,"LessonSpot",LimoCounter)
		--print("Spot "..LimoCounter.." ok")
		this.Tooltip = "Spot "..LimoCounter.."/"..Max.." ok at x"..this.Pos.x.." y"..this.Pos.y.. "\nXmin "..Xmin.." Xmax "..Xmax.." Ymin "..Ymin.." Ymax "..Ymax
	end
end

function Create()
	Set(this,"SpotType","Repair")
	Set(this,"OrigX",this.Pos.x)
	Set(this,"OrigY",this.Pos.y)
end

function Update(timePassed)
	this.Pos.x = this.OrigX
	this.Pos.y = this.OrigY
	if not Get(this,"CraneFound") then
		FindMyGantryCrane()
		Set(this,"CraneFound",true)
	end
end
