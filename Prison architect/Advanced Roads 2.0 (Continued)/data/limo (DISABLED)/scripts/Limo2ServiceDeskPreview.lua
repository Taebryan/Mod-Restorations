
local timeTot = 0
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects
local rotateToggle = 0

function FindMyGantryCrane()
	local craneFound = false
    local nearbyCranes = Find(this,"GantryCrane2Spawner",50)
	if next(nearbyCranes) then
		for thatCrane,dist in pairs(nearbyCranes) do
			if Get(thatCrane,"FoundationDone") == true then
				Xmin = math.floor(thatCrane.OrigX) + math.ceil(thatCrane.Xmin) + 0.5
				Xmax = math.floor(thatCrane.OrigX) + math.ceil(thatCrane.Xmax) - 1
				Ymin = math.floor(thatCrane.OrigY) + math.ceil(thatCrane.Ymin) + 0.5
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
	
	local nearbyServiceDesk = Find(this,"Limo2ServiceDeskPreview",50)
	if next(nearbyServiceDesk) then
		for thatDesk, dist in pairs(nearbyServiceDesk) do
			if thatDesk.HomeUID == this.HomeUID and thatDesk.Id.i ~= this.Id.i then
				thatDesk.Delete()
			end
		end
		--print("Service Desk ok")
		this.Tooltip = "Service Desk ok at x"..this.Pos.x.." y"..this.Pos.y.. "\nXmin "..Xmin.." Xmax "..Xmax.." Ymin "..Ymin.." Ymax "..Ymax
	end
end

function toggleRotateClicked()
	rotateToggle = rotateToggle + 1
	if rotateToggle >= 4 then rotateToggle = 0 end
	this.SubType = rotateToggle
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
		Interface.AddComponent(this,"toggleRotate", "Button", "tooltip_Button_toggleRotate")
	end
end
