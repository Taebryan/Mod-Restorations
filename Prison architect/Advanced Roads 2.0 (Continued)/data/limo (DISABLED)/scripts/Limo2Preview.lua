
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
				Ymin = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymin) + 1
				Ymax = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymax) - 2
	
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
	local Max = Get(MyCrane,"MaxLimos")
	local LimoCounter = 1
	local nearbyLimos = Find(this,"Limo2Preview",50)
	for thatLimo, dist in pairs(nearbyLimos) do
		if thatLimo.HomeUID == this.HomeUID and thatLimo.Id.i ~= this.Id.i then
			LimoCounter = LimoCounter + 1
		end
	end
	if LimoCounter > Max then
		this.Delete()
	else
		--print("Spot "..LimoCounter.." ok")
		this.Tooltip = "Spot "..LimoCounter.."/"..Max.." ok at x"..this.Pos.x.." y"..this.Pos.y.. "\nXmin "..Xmin.." Xmax "..Xmax.." Ymin "..Ymin.." Ymax "..Ymax
	end
end

function toggleRepairClicked()
	if this.SpotType == "Repair" then
		this.SpotType = "Paint"
		this.SubType = 2
	else
		if MyCrane.IsMilitary == "Yes" then this.SubType = 1 else this.SubType = 0 end
		this.SpotType = "Repair"
	end
	this.SetInterfaceCaption("toggleRepair", "tooltip_Button_toggleRepair","tooltip_toggleSpotType_"..this.SpotType,"X")
end

function Create()
	Set(this,"SpotType","Repair")
	this.Pos.x = this.Pos.x-1	-- this 'entity' hops to a strange spot when placed, probably because it's not a 1x1 sprite
	this.Pos.y = this.Pos.y+1	-- adjust for that, and mess with the SubType to update the sprite position
	this.SubType = 1			-- if we don't do this, the sprite stays on a weird spot, and only the 'entity' circle moved.
	Set(this,"OrigX",this.Pos.x)
	Set(this,"OrigY",this.Pos.y)
end

function Update(timePassed)
	this.Pos.x = this.OrigX
	this.Pos.y = this.OrigY
	if not Get(this,"CraneFound") then
		this.SubType = 0		-- set SubType back to 0 after the sprite is at correct position
		Interface.AddComponent(this,"Caption_toggleRepair", "Caption", "tooltip_Caption_toggleRepair")
		Interface.AddComponent(this,"toggleRepair", "Button", "tooltip_Button_toggleRepair","tooltip_toggleSpotType_"..this.SpotType,"X")
		FindMyGantryCrane()
		Set(this,"CraneFound",true)
	end
end
