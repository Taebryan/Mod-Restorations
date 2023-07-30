
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
				Xmin = math.floor(thatCrane.OrigX) + math.ceil(thatCrane.Xmin) - 0.5
				Xmax = math.floor(thatCrane.OrigX) + math.ceil(thatCrane.Xmax) - 0.5
				Ymin = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymin) - 0.5
				Ymax = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymax) - 0.5
				
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
	
	local nearbyBooths = Find(this,"GantryCrane2BoothPreview",50)
	if next(nearbyBooths) then
		for thatBooth, dist in pairs(nearbyBooths) do
			if thatBooth.HomeUID == this.HomeUID and thatBooth.Id.i ~= this.Id.i then
				thatBooth.Delete()
			end
		end
		--print("Gantry Crane Control ok")
		this.Tooltip = "Gantry Crane Control ok at x"..this.Pos.x.." y"..this.Pos.y.. "\nXmin "..Xmin.." Xmax "..Xmax.." Ymin "..Ymin.." Ymax "..Ymax
	end
end

function Create()
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
