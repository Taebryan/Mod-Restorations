
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
				Xmax = math.floor(thatCrane.OrigX) + math.ceil(thatCrane.Xmax) - 2
				Ymin = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymin)
				Ymax = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymax)
				
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
	
	local nearbyRacks = Find(this,"CarPartsRack2Preview",50)
	if next(nearbyRacks) then
		for thatRack, dist in pairs(nearbyRacks) do
			if thatRack.HomeUID == this.HomeUID and thatRack.Id.i ~= this.Id.i then
				thatRack.Delete()
			end
		end
		--print("Car Parts Rack ok")
		this.Tooltip = "Car Parts Rack ok at x"..this.Pos.x.." y"..this.Pos.y.. "\nXmin "..Xmin.." Xmax "..Xmax.." Ymin "..Ymin.." Ymax "..Ymax
	end
end

function Create()
	this.Pos.x = this.Pos.x+1
	this.Pos.y = this.Pos.y-1
	this.SubType = 1
	Set(this,"OrigX",this.Pos.x)
	Set(this,"OrigY",this.Pos.y)
end

function Update(timePassed)
	this.Pos.x = this.OrigX
	this.Pos.y = this.OrigY
	if not Get(this,"CraneFound") then
		this.SubType = 0
		FindMyGantryCrane()
		Set(this,"CraneFound",true)
	end
end
