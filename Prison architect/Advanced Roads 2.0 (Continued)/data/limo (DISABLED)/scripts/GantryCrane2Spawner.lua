
local timeInit = 0
local initTimer = 1
local Now = 0

local StartingMinute = -1
local EndingMinute = -1

local myMapSize = "UNKNOWN"
local mySlowTime = "UNKNOWN"

local myTimeWarpFactor = 0
local timeWarpFound = false

local timeTot = 0
local timeAnim = 0
local timePerAnim = 0.5
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects
local markerFound = false
local previewShown = false
local OtherGarageAvailable = false

local ConflictingX = 0
local RoadSizeUsed = "Single"
local RoadLaneUsed = "Right"

local InventoryRepairSpots = "missing"
local InventoryPartsRack = "missing"
local InventoryControl = "missing"
local InventoryServiceDesk = "missing"
local InventoryCabinet = "missing"

local TreeTypes = { "Tree", "SpookyTree", "SnowyConiferTree", "CactusTree", "SakuraTree", "PalmTree", "Bush" }

function FindMyRoadMarker()
	markerFound = false
    local roadMarkers = Find(this,"RoadMarker2",10000)
	if next(roadMarkers) then
		for thatMarker,distance in pairs(roadMarkers) do
			if thatMarker.Pos.x == this.OrigX then
				print("MyRoadMarker found at "..distance)
				MyRoadMarker = thatMarker
				Set(this,"MarkerUID",thatMarker.Id.u)
				markerFound = true
				break
			end
		end
	end
	roadMarkers = nil
	
	if markerFound == false then
		print("MyRoadMarker spawned")
		MyRoadMarker = Object.Spawn("RoadMarker2",this.OrigX,0.5000000)
		Set(MyRoadMarker,"MarkerUID",MyRoadMarker.Id.u)
		Set(this,"MarkerUID",MyRoadMarker.Id.u)
		local cell = World.GetCell(math.floor(MyRoadMarker.Pos.x-2),0)
		cell.Mat = "RoadMarkerTile"
	end
	if not Exists(MyRoadMarker) then
		print(" -- ERROR --- MyRoadMarker not found")
	end
end

-- function DeleteMyRoadMarker()
    -- local roadMarkers = Find(this,"RoadMarker2",10000)
	-- if next(roadMarkers) then
		-- for thatMarker,dist in pairs(roadMarkers) do
			-- if thatMarker.Pos.x == this.OrigX then
				-- thatMarker.Delete()
				-- break
			-- end
		-- end
	-- end
	-- roadMarkers = nil
-- end

function FindMapEdge()
	Set(this,"MapBottom",World.NumCellsY-1)
	Set(this,"MapEdge",World.NumCellsX-1)
	Set(this,"MyLeftEdge",0)
	Set(this,"MyRightEdge",World.NumCellsX-1)
	-- local endX=-1
	-- local endY=-1
	-- local foundEndX=false
	-- local foundEndY=false
	
	-- while foundEndY==false do
		-- endY=endY+1
		-- local myCell = World.GetCell(this.Pos.x,endY)
		-- if myCell.Mat==nil then
			-- foundEndY=true
			-- endY=endY-1
		-- end
	-- end
	
	-- while foundEndX==false do
		-- endX=endX+1
		-- local myCell = World.GetCell(endX,0)
		-- if myCell.Mat==nil then
			-- foundEndX=true
			-- endX=endX-1
		-- end
	-- end
	-- Set(this,"MyLeftEdge",0)
	-- Set(this,"MyRightEdge",endX)
	-- Set(this,"MapEdge",endX)
	-- Set(this,"MapBottom",endY)
end

function Create()
	Set(this,"HomeUID","GantryCrane2_"..me["id-uniqueId"])
	Set(this,"StartBuilding",false)
	Set(this,"GaragePlacement","Centre")
	Set(this,"GarageSize","Normal")
	Set(this,"RoadSize","Single")
	Set(this,"IsMilitary","No")
	Set(this,"RailLeftX",-10.5)
	Set(this,"RailRightX",11.5)
	Set(this,"RailsY",12.5)
	Set(this,"GantryCraneX",0.5)
	Set(this,"Xmin",-9.5)
	Set(this,"Xmax",10)
	Set(this,"Ymin",-5.5)
	Set(this,"Ymax",11.5)
	Set(this,"MaxLimos",8)
	this.Tooltip = "tooltip_Init_TimeWarpA"
	Set(this,"RightPlacementNotPossible",false)
	Set(this,"CentrePlacementNotPossible",false)
	Set(this,"LeftPlacementNotPossible",false)
	Set(this,"SetRoadSizeNotPossible",false)
	Set(this,"TallNotPossible",false)
	Set(this,"LeftWideNotPossible",false)
	Set(this,"RightWideNotPossible",false)
	this.HasCustomReport = true		-- comment out to get the old buttons
end

function toggleGaragePlacementLeftClicked()
	this.GaragePlacement = "Left"
	if ConflictingX > 0 and RoadSizeUsed == "Double" then
		if RoadLaneUsed == "Right" then
			--print("1RoadLaneUsed "..RoadLaneUsed.." jump to 0")
			this.OrigX = ConflictingX
			OtherGarageAvailable = true
		else
			--print("2RoadLaneUsed "..RoadLaneUsed.." jump to +3")
			this.OrigX = ConflictingX+3
			OtherGarageAvailable = false
		end
		this.RoadSize = "Double"
		Interface.SetComponentProperties( "GarageLaneSingle", { Caption = "reportButton_OptionUnavailable" } )
		Interface.SetComponentProperties( "GarageLaneDouble", { Caption = "reportButton_OptionSelected" } )
	end
	Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionSelected" } )
	Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "" } )
	if this.GarageSize == "Wide" then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
		if this.LeftWideNotPossible == true then
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
			this.GarageSize = "Normal"
		else
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionSelected" } )
		end
	else
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "" } )
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "" } )
		if this.LeftWideNotPossible == true then
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
		end
		if this.TallNotPossible == true then
			Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionUnavailable" } )
		elseif this.GarageSize == "Tall" then
			Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionSelected" } )
		end
	end
	if this.CentrePlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.RightPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionUnavailable" } )
	end
	SetCoordinates()
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGaragePlacementCentreClicked()
	this.GaragePlacement = "Centre"
	if this.GarageSize == "Wide" then
		this.GarageSize = "Normal"
		Interface.SetComponentProperties( "GarageSizeNormal", { Caption = "reportButton_OptionSelected" } )
		Interface.SetComponentProperties( "GarageSizeTall", { Caption = "" } )
	end
	if ConflictingX > 0 and RoadSizeUsed == "Double" then
		if RoadLaneUsed == "Left" then
			this.OrigX = ConflictingX
			--print("3RoadLaneUsed "..RoadLaneUsed.." jump to 0")
			OtherGarageAvailable = true
		else
			this.OrigX = ConflictingX-3
			--print("4RoadLaneUsed "..RoadLaneUsed.." jump to -3")
			OtherGarageAvailable = false
		end
		this.RoadSize = "Double"
		Interface.SetComponentProperties( "GarageLaneSingle", { Caption = "reportButton_OptionUnavailable" } )
		Interface.SetComponentProperties( "GarageLaneDouble", { Caption = "reportButton_OptionSelected" } )
	end
	Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "" } )
	Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionSelected" } )
	Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "" } )
	Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
	if this.TallNotPossible == true then
		Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionUnavailable" } )
	elseif this.GarageSize == "Tall" then
		Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionSelected" } )
	end
	if this.RightPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.LeftPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionUnavailable" } )
	end
	SetCoordinates()
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGaragePlacementRightClicked()
	this.GaragePlacement = "Right"
	if ConflictingX > 0 and RoadSizeUsed == "Double" then
		if RoadLaneUsed == "Left" then
			this.OrigX = ConflictingX
			OtherGarageAvailable = true
			--print("3RoadLaneUsed "..RoadLaneUsed.." jump to 0")
		else
			this.OrigX = ConflictingX-3
			OtherGarageAvailable = false
			--print("4RoadLaneUsed "..RoadLaneUsed.." jump to -3")
		end
		this.RoadSize = "Double"
		Interface.SetComponentProperties( "GarageLaneSingle", { Caption = "reportButton_OptionUnavailable" } )
		Interface.SetComponentProperties( "GarageLaneDouble", { Caption = "reportButton_OptionSelected" } )
	end
	Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "" } )
	Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionSelected" } )
	if this.GarageSize == "Wide" then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
		if this.RightWideNotPossible == true then
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
			this.GarageSize = "Normal"
		else
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionSelected" } )
		end
	else
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "" } )
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "" } )
		if this.RightWideNotPossible == true then
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
		end
		if this.TallNotPossible == true then
			Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionUnavailable" } )
		elseif this.GarageSize == "Tall" then
			Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionSelected" } )
		end
	end
	if this.CentrePlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.LeftPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionUnavailable" } )
	end
	SetCoordinates()
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGarageSizeNormalClicked()
	this.GarageSize = "Normal"
	Interface.SetComponentProperties( "GarageSizeNormal", { Caption = "reportButton_OptionSelected" } )
	if this.TallNotPossible == true then
		Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionUnavailable" } )
	else
		Interface.SetComponentProperties( "GarageSizeTall", { Caption = "" } )
	end
	if this.GaragePlacement == "Centre" then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionSelected" } )
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
	else
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "" } )
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "" } )
		if (this.GaragePlacement == "Left" and this.LeftWideNotPossible == true) or (this.GaragePlacement == "Right" and this.RightWideNotPossible == true) then
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
		end
	end
	if this.LeftPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.CentrePlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.RightPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionUnavailable" } )
	end
	SetCoordinates()
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGarageSizeTallClicked()
	this.GarageSize = "Tall"
	Interface.SetComponentProperties( "GarageSizeNormal", { Caption = "" } )
	Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionSelected" } )
	if this.GaragePlacement == "Centre" then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionSelected" } )
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
	else
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "" } )
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "" } )
		if (this.GaragePlacement == "Left" and this.LeftWideNotPossible == true) or (this.GaragePlacement == "Right" and this.RightWideNotPossible == true) then
			Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
		end
	end
	if this.LeftPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.CentrePlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.RightPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionUnavailable" } )
	end
	SetCoordinates()
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGarageSizeWideClicked()
	this.GarageSize = "Wide"
	if this.GaragePlacement == "Centre" then
		this.GaragePlacement = "Left"
		Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionSelected" } )
		Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "" } )
	end
	Interface.SetComponentProperties( "GarageSizeNormal", { Caption = "" } )
	if this.TallNotPossible == true then
		Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionUnavailable" } )
	else
		Interface.SetComponentProperties( "GarageSizeTall", { Caption = "" } )
	end
	if (this.GaragePlacement == "Left" and this.LeftWideNotPossible == true) or (this.GaragePlacement == "Right" and this.RightWideNotPossible == true) then
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
		this.GarageSize = "Normal"
	else
		Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionSelected" } )
	end
	Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
	if this.LeftPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.CentrePlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
	end
	if this.RightPlacementNotPossible == true then
		Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionUnavailable" } )
	end
	SetCoordinates()
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGarageLaneSingleClicked()
	if ConflictingX == 0 then
		this.RoadSize = "Single"
		Interface.SetComponentProperties( "GarageLaneSingle", { Caption = "reportButton_OptionSelected" } )
		Interface.SetComponentProperties( "GarageLaneDouble", { Caption = "" } )
		SetCoordinates()
	end
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGarageLaneDoubleClicked()
	if ConflictingX == 0 then
		this.RoadSize = "Double"
		Interface.SetComponentProperties( "GarageLaneSingle", { Caption = "" } )
		Interface.SetComponentProperties( "GarageLaneDouble", { Caption = "reportButton_OptionSelected" } )
		SetCoordinates()
	end
	if previewShown == false then
		toggleShowPreviewClicked()
	else
		toggleShowPreviewClicked()
		toggleShowPreviewClicked()
	end
end

function toggleGarageTypeNormalClicked()
	this.IsMilitary = "No"
	Interface.SetComponentProperties( "GarageTypeNormal", { Caption = "reportButton_OptionSelected" } )
	Interface.SetComponentProperties( "GarageTypeMilitary", { Caption = "" } )
end

function toggleGarageTypeMilitaryClicked()
	this.IsMilitary = "Yes"
	Interface.SetComponentProperties( "GarageTypeNormal", { Caption = "" } )
	Interface.SetComponentProperties( "GarageTypeMilitary", { Caption = "reportButton_OptionSelected" } )
end

function CheckForOtherGarages()
	FindMapEdge()
    ConflictingY = 0
    ConflictingX = 0
	local MyTop,MyBottom,OtherTop,OtherBottom = 0,0,0,0
	
	local ConflictingSize = "Normal"
	local CurrentDist = 9999
	local otherInstallers = Find("GantryCrane2Spawner",500)
	if next(otherInstallers) then
		for thatInstaller, dist in pairs(otherInstallers) do
			if thatInstaller.Id.i ~= this.Id.i then
				if Get(thatInstaller,"StartBuilding") == false then
					checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
					checker.SubType = 1
					Set(checker,"HomeUID",this.HomeUID)
					checker.Tooltip = "Other installer found.\nSpecify its size and create the floor first.\nInstaller has been removed."
					this.Delete()
					return
				end
				--print("compare "..thatInstaller.OrigX.." with "..this.OrigX)
				--print((thatInstaller.Pos.x+thatInstaller.RailLeftX).." "..(thatInstaller.Pos.x+thatInstaller.RailRightX).." "..this.OrigX)
				if thatInstaller.Pos.x+thatInstaller.RailLeftX <= this.OrigX and thatInstaller.Pos.x+thatInstaller.RailRightX >= this.OrigX then
					--OtherGarageAvailable = true
					if dist < CurrentDist then
						CurrentDist = dist
						ConflictingY = thatInstaller.OrigY
						ConflictingSize = thatInstaller.GarageSize
						this.OrigX = thatInstaller.Pos.x
						--print("ConflictingY: "..ConflictingY)
					
						ConflictingX = thatInstaller.OrigX
						RoadSizeUsed = Get(thatInstaller,"RoadSize")
						Set(this,"RoadSize",thatInstaller.RoadSize)
						Set(this,"SetRoadSizeNotPossible",true)
						--print("got roadside value "..thatInstaller.RoadSize.." from other installer, garageplacement is "..thatInstaller.GaragePlacement)
						Interface.SetComponentProperties( "DoubleLane", { Replacements = { L = "reportTooltip_RoadSize"..this.RoadSize } } )
						if RoadSizeUsed == "Double" then
							if thatInstaller.GaragePlacement == "Left" then
								RoadLaneUsed = "Right"
								this.OrigX = thatInstaller.Pos.x-3
							else
								RoadLaneUsed = "Left"
								this.OrigX = thatInstaller.Pos.x
								OtherGarageAvailable = true
							end
						else
							OtherGarageAvailable = true
						end
					end
				end
				print("thatInstaller.Ymin: "..(thatInstaller.Pos.y+thatInstaller.Ymin-0.5).."  this.Pos.x+this.Ymax+2.5: "..(this.Pos.y+this.Ymax+2.5))
			
				-- OtherTop = thatInstaller.Pos.y+thatInstaller.Ymin-0.5
				-- OtherBottom = thatInstaller.Pos.y+thatInstaller.Ymax+2.5
				-- MyTop = this.Pos.y+this.Ymin-0.5
				-- MyBottom = this.Pos.y+this.Ymax+2.5
				-- checker1 = Object.Spawn("FoundationChecker",this.Pos.x,MyTop)
				-- checker1.Tooltip = "MyTop"
				-- checker2 = Object.Spawn("FoundationChecker",this.Pos.x,MyBottom)
				-- checker2.Tooltip = "MyBottom"
				-- checker3 = Object.Spawn("FoundationChecker",this.Pos.x,OtherTop)
				-- checker3.Tooltip = "OtherTop"
				-- checker4 = Object.Spawn("FoundationChecker",this.Pos.x,OtherBottom)
				-- checker4.Tooltip = "OtherBottom"
					
				if thatInstaller.Pos.x+thatInstaller.RailLeftX >= this.OrigX then -- other installer is to the right of me
					Set(this,"MyRightEdge",thatInstaller.Pos.x+thatInstaller.RailLeftX+2)
					-- if thatInstaller.Pos.y > this.Pos.y then
						-- if OtherTop > MyBottom then
							-- Set(this,"MyRightEdge",thatInstaller.OrigX-2)
							-- if OtherTop - MyBottom < 22 then
								-- Set(this,"TallNotPossible",true)
							-- end
						-- end
					-- else
						-- if MyTop > OtherBottom then
							-- Set(this,"MyRightEdge",thatInstaller.OrigX-2)
						-- end
					-- end
				elseif thatInstaller.Pos.x+thatInstaller.RailRightX <= this.OrigX then
					Set(this,"MyLeftEdge",thatInstaller.Pos.x+thatInstaller.RailRightX-2)
					-- if thatInstaller.Pos.y > this.Pos.y then
						-- if OtherTop > MyBottom then
							-- Set(this,"MyLeftEdge",thatInstaller.OrigX+2)
							-- if OtherTop - MyBottom < 22 then
								-- Set(this,"TallNotPossible",true)
							-- end
						-- end
					-- else
						-- if MyTop > OtherBottom then
							-- Set(this,"MyLeftEdge",thatInstaller.OrigX+2)
						-- end
					-- end
				end
			end
		end
	end
	local otherGarages = Find("GantryCrane2Hook",500)
	if next(otherGarages) then
		for thatGarage, dist in pairs(otherGarages) do
			local xmin = 0
			local xmax = 0
			if thatGarage.GaragePlacement == "Centre" then
				xmin = -9.5
				xmax = 10.5
			elseif thatGarage.GaragePlacement == "Left" then
				xmin = -11.5
				xmax = 2.5
				if thatGarage.GarageSize == "Wide" then
					xmin = -17.5
				end
			else
				xmin = -2.5
				xmax = 11.5
				if this.GarageSize == "Wide" then
					xmax = 17.5
				end
			end
			--print("compare "..thatGarage.ParkX.." with "..this.OrigX)
			if thatGarage.ParkX+xmin <= this.OrigX and thatGarage.ParkX+xmax >= this.OrigX then
				--OtherGarageAvailable = true
				if dist < CurrentDist then
					CurrentDist = dist
					ConflictingY = thatGarage.ParkY
					ConflictingSize = thatGarage.GarageSize
					this.OrigX = thatGarage.ParkX
					--print("ConflictingY: "..ConflictingY)
				
					ConflictingX = thatGarage.ParkX
					if Get(thatGarage,"RoadSize") ~= nil then
						RoadSizeUsed = Get(thatGarage,"RoadSize")
						Set(this,"RoadSize",thatGarage.RoadSize)
						Set(this,"SetRoadSizeNotPossible",true)
						--print("got roadside value "..thatGarage.RoadSize.." from other garage, garageplacement is "..thatGarage.GaragePlacement)
						Interface.SetComponentProperties( "DoubleLane", { Replacements = { L = "reportTooltip_RoadSize"..this.RoadSize } } )
						if RoadSizeUsed == "Double" then
							if thatGarage.GaragePlacement == "Left" then
								RoadLaneUsed = "Right"
								this.OrigX = thatGarage.ParkX-3
							else
								RoadLaneUsed = "Left"
								this.OrigX = thatGarage.ParkX
								OtherGarageAvailable = true
							end
						else
							OtherGarageAvailable = true
						end
					end
				end
				if thatGarage.Pos.x+thatGarage.RailLeftX >= this.OrigX then
					Set(this,"MyRightEdge",math.ceil(thatGarage.Pos.x+thatGarage.RailLeftX))
				elseif thatGarage.Pos.x+thatGarage.RailRightX <= this.OrigX then
					Set(this,"MyLeftEdge",math.floor(thatGarage.Pos.x+thatGarage.RailRightX))
				end
			end
		end
	end
				
	if ConflictingY > 0 then
		if ConflictingSize == "Normal" or ConflictingSize == "Wide" then
			if ConflictingY < this.OrigY and this.OrigY < ConflictingY+22 then
				--print("Making adjacent to garage above me.")
				checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
				checker.SubType = 1
				Set(checker,"HomeUID",this.HomeUID)
				checker.Tooltip = "Making adjacent to garage above me"
				Set(this,"OrigY",math.floor(ConflictingY+20))
				if this.MapBottom - this.OrigY < 24 then
					checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
					checker.SubType = 1
					Set(checker,"HomeUID",this.HomeUID)
					checker.Tooltip = "Gantry crane can't be placed here.\nIt must be at least 24 tiles from map bottom.\nThe installer has been removed."
					this.Delete()
					return
				end
			end
			
			if ConflictingY > this.OrigY and ConflictingY-22 < this.OrigY then
				checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
				checker.SubType = 1
				Set(checker,"HomeUID",this.HomeUID)
				checker.Tooltip = "The garage below me was nearer than 22 tiles, making adjacent.\nThe installer moved to the correct position."
				--print("The garage below me was nearer than 18 tiles, making adjacent.")
				Set(this,"OrigY",math.ceil(ConflictingY-20.5))
				Set(this,"TallNotPossible",true)
			end
			if ConflictingY > this.OrigY and ConflictingY-30 < this.OrigY then
				Set(this,"TallNotPossible",true)
				--print("c"..(ConflictingY-30).." y "..this.Pos.y)
			end
			if ConflictingY > this.OrigY and (ConflictingY-32 < this.OrigY and ConflictingY-29 > this.OrigY) then
				checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
				checker.SubType = 1
				Set(checker,"HomeUID",this.HomeUID)
				checker.Tooltip = "The garage below me was between 29-32 tiles tiles, making adjacent for tall garage creation.\nThe installer moved to the correct position."
				--print("The garage below me was between 29-32 tiles tiles, making adjacent for tall garage creation.")
				Set(this,"OrigY",math.ceil(ConflictingY-30.5))
			
			end
			
		elseif ConflictingSize == "Tall" then
			if ConflictingY < this.OrigY and this.OrigY < ConflictingY+32 then
				checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
				checker.SubType = 1
				Set(checker,"HomeUID",this.HomeUID)
				checker.Tooltip = "The garage above me was nearer than 32 tiles, making adjacent.\nThe installer moved to the correct position."
				--print("Garage above me was nearer than 32 tiles, making adjacent.")
				Set(this,"OrigY",math.floor(ConflictingY+30.5))
				if this.MapBottom - this.OrigY < 20 then
					checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
					checker.SubType = 1
					Set(checker,"HomeUID",this.HomeUID)
					checker.Tooltip = "Gantry crane can't be placed here.\nIt must be at least 20 tiles from map bottom.\nThe installer has been removed."
					this.Delete()
					return
				end
			end
			
			if ConflictingY > this.OrigY and ConflictingY-22 < this.OrigY then
				checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
				checker.SubType = 1
				Set(checker,"HomeUID",this.HomeUID)
				checker.Tooltip = "The garage below me was nearer than 22 tiles, making adjacent.\nThe installer moved to the correct position."
				--print("The garage below me was nearer than 22 tiles, making adjacent.")
				Set(this,"OrigY",math.ceil(ConflictingY-20.5))
				Set(this,"TallNotPossible",true)
			end
			if ConflictingY > this.OrigY and ConflictingY-30 < this.OrigY then
				Set(this,"TallNotPossible",true)
				--print("c"..(ConflictingY-30).." y "..this.Pos.y)
			end
			if ConflictingY > this.OrigY and (ConflictingY-32 < this.OrigY and ConflictingY-29 > this.OrigY) then
				checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
				checker.SubType = 1
				Set(checker,"HomeUID",this.HomeUID)
				checker.Tooltip = "The garage below me was between 29-32 tiles tiles, making adjacent for tall garage creation.\nThe installer moved to the correct position."
				--print("The garage below me was between 29-32 tiles tiles, making adjacent for tall garage creation.")
				Set(this,"OrigY",math.ceil(ConflictingY-30.5))
			
			end
			
		end
		if this.Pos.y < 26 or this.MapBottom - this.OrigY < 24 then
			checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
			checker.SubType = 1
			Set(checker,"HomeUID",this.HomeUID)
			checker.Tooltip = "Gantry crane can't be placed here.\nIt must be at least 25 tiles from map bottom for a normal or wide garage, or at least 35 tiles for a tall garage.\nThe installer was removed."
			this.Delete()
			return
		end
		if this.MapBottom - this.OrigY < 34 then
			Set(this,"TallNotPossible",true)
		end
	else
		if this.Pos.y < 26 then
			checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
			checker.SubType = 1
			Set(checker,"HomeUID",this.HomeUID)
			checker.Tooltip = "Gantry crane can't be placed here.\nIt must be at least 26 tiles from map top.\nThe installer moved to the correct position."
			Set(this,"OrigY",26)
		end
		if this.MapBottom - this.OrigY < 24 then
			checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY)
			checker.SubType = 1
			Set(checker,"HomeUID",this.HomeUID)
			checker.Tooltip = "Gantry crane can't be placed here.\nIt must be at least 24 tiles from map bottom for a normal or wide garage, or at least 35 tiles for a tall garage.\nThe installer moved to the correct position."
			Set(this,"OrigY",this.MapBottom-20)
		end
		if this.MapBottom - this.OrigY < 34 then
			Set(this,"TallNotPossible",true)
		end
	end
	
	
	if math.floor(this.MyRightEdge)-this.Pos.x < 20 then
		checker20 = Object.Spawn("FoundationChecker",math.floor(this.MyRightEdge)-20,this.OrigY-6)
		checker20.SubType = 0
		Set(checker20,"HomeUID",this.HomeUID)
		checker20.Tooltip = "Installer position: "..this.OrigX.."\nThis position: "..(math.floor(this.MyRightEdge)-20).."\n\nGantry crane must be placed here\nbefore you can enable Placement RightWide.\n\nThe installer disabled the Placement RightWide option.\n\nIf you want a wide garage to the right of the road,\nthen mark this X position with the Planning tool\nand remove the current Limo Garage Installer.\n\nThe top wall of the garage will be created\nwhere you place the new intaller."
		Set(this,"RightWideNotPossible",true)
	end
	if math.floor(this.MyRightEdge)-this.Pos.x < 14 then
		checker14 = Object.Spawn("FoundationChecker",math.floor(this.MyRightEdge)-14,this.OrigY-6)
		checker14.SubType = 0
		Set(checker14,"HomeUID",this.HomeUID)
		checker14.Tooltip = "Installer position: "..this.OrigX.."\nThis position: "..(math.floor(this.MyRightEdge)-14).."\n\nGantry crane must be placed here\nbefore you can enable Placement Right.\n\nThe installer disabled the Placement Right option.\n\nIf you want a garage to the right of the road,\nthen mark this X position with the Planning tool\nand remove the current Limo Garage Installer.\n\nThe top wall of the garage will be created\nwhere you place the new intaller."
		Set(this,"RightPlacementNotPossible",true)
	end
	if math.floor(this.MyRightEdge)-this.Pos.x < 13 then
		checker13 = Object.Spawn("FoundationChecker",math.floor(this.MyRightEdge)-13,this.OrigY-6)
		checker13.SubType = 0
		Set(checker13,"HomeUID",this.HomeUID)
		checker13.Tooltip = "Installer position: "..this.OrigX.."\nThis position: "..(math.floor(this.MyRightEdge)-13).."\n\nGantry crane must be placed here\nbefore you can enable Placement Centre.\n\nThe installer disabled the Placement Centre option.\n\nIf you want a garage with a centred road,\nthen mark this X position with the Planning tool\nand remove the current Limo Garage Installer.\n\nThe top wall of the garage will be created\nwhere you place the new intaller."
		Set(this,"CentrePlacementNotPossible",true)
		Set(this,"RightPlacementNotPossible",true)
		Set(this,"RightWideNotPossible",true)
		Set(this,"GaragePlacement","Left")
	end
	if math.ceil(this.MyRightEdge)-this.Pos.x < 6 then
		checker5 = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY-6)
		checker5.SubType = 1
		Set(checker5,"HomeUID",this.HomeUID)
		checker5.Tooltip = "This position: "..this.Pos.x.."\n\nGantry crane should not be placed here.\n\nThe installer moved to the correct position."
		Set(this,"OrigX",math.ceil(this.MyRightEdge)-6)
		Set(this,"GaragePlacement","Left")
		Set(this,"RightPlacementNotPossible",true)
	end
	
	if this.OrigX >= this.MapEdge-22 then
		checker22 = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY-6)
		checker22.SubType = 1
		Set(checker22,"HomeUID",this.HomeUID)
		checker22.Tooltip = "Gantry crane should not be placed here.\nIt must be on the right lane of the road.\nThe installer moved to the correct position."
		Set(this,"GaragePlacement","Left")
		Set(this,"CentrePlacementNotPossible",true)
		Set(this,"RightPlacementNotPossible",true)
		if Exists(checker20) then checker20.Delete() end
		if Exists(checker14) then checker14.Delete() end
		if Exists(checker13) then checker13.Delete() end
		if Exists(checker5) then checker5.Delete() end
	end
	if this.OrigX >= this.MapEdge-13 then
		checker = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY-6)
		checker.SubType = 1
		Set(checker,"HomeUID",this.HomeUID)
		checker.Tooltip = "Gantry crane should not be placed here.\nIt must be on the right lane of the road.\nThe installer moved to the correct position."
		Set(this,"OrigX",this.MapEdge-6)
		Set(this,"GaragePlacement","Left")
		Set(this,"RoadSize","Double")
		Set(this,"SetRoadSizeNotPossible",true)
		Set(this,"CentrePlacementNotPossible",true)
		Set(this,"RightPlacementNotPossible",true)
		if Exists(checker20) then checker20.Delete() end
		if Exists(checker14) then checker14.Delete() end
		if Exists(checker13) then checker13.Delete() end
		if Exists(checker5) then checker5.Delete() end
	end
	
	
	if this.Pos.x-this.MyLeftEdge < 20 then
		checker20 = Object.Spawn("FoundationChecker",this.MyLeftEdge+20,this.OrigY-6)
		checker20.SubType = 0
		Set(checker20,"HomeUID",this.HomeUID)
		checker20.Tooltip = "Installer position: "..this.OrigX.."\nThis position: 20\n\nGantry crane must be placed here\nbefore you can enable Placement LeftWide.\n\nThe installer disabled the Placement LeftWide option.\n\nIf you want a wide garage to the left of the road,\nthen mark this X position with the Planning tool\nand remove the current Limo Garage Installer.\n\nThe top wall of the garage will be created\nwhere you place the new intaller."
		Set(this,"LeftWideNotPossible",true)
	end
	if this.Pos.x-this.MyLeftEdge < 14 then
		checker14 = Object.Spawn("FoundationChecker",this.MyLeftEdge+14,this.OrigY-6)
		checker14.SubType = 0
		Set(checker14,"HomeUID",this.HomeUID)
		checker14.Tooltip = "Installer position: "..this.OrigX.."\nThis position: 14\n\nGantry crane must be placed here\nbefore you can enable Placement Left.\n\nThe installer disabled the Placement Left option.\n\nIf you want a garage to the left of the road,\nthen mark this X position with the Planning tool\nand remove the current Limo Garage Installer.\n\nThe top wall of the garage will be created\nwhere you place the new intaller."
		Set(this,"LeftPlacementNotPossible",true)
	end
	if this.Pos.x-this.MyLeftEdge < 12 then
		checker12 = Object.Spawn("FoundationChecker",this.MyLeftEdge+12,this.OrigY-6)
		checker12.SubType = 0
		Set(checker12,"HomeUID",this.HomeUID)
		checker12.Tooltip = "Installer position: "..this.OrigX.."\nThis position: 12\n\nGantry crane must be placed here\nbefore you can enable Placement Centre.\n\nThe installer disabled the Placement Centre option.\n\nIf you want a garage with a centred road,\nthen mark this X position with the Planning tool\nand remove the current Limo Garage Installer.\n\nThe top wall of the garage will be created\nwhere you place the new intaller."
		Set(this,"CentrePlacementNotPossible",true)
		Set(this,"LeftPlacementNotPossible",true)
		Set(this,"LeftWideNotPossible",true)
		Set(this,"GaragePlacement","Right")
	end
	if this.Pos.x-this.MyLeftEdge < 5 then
		checker5 = Object.Spawn("FoundationChecker",this.Pos.x,this.OrigY-6)
		checker5.SubType = 1
		Set(checker5,"HomeUID",this.HomeUID)
		checker5.Tooltip = "This position: "..this.Pos.x.."\n\nGantry crane should not be placed here.\n\nThe installer moved to the correct position."
		Set(this,"OrigX",math.ceil(this.MyLeftEdge)+5)
		Set(this,"GaragePlacement","Right")
		Set(this,"LeftPlacementNotPossible",true)
	end
	otherInstallers = nil
	otherGarages = nil
end

function SetCoordinates()
	if this.GaragePlacement == "Centre" then
		this.RailLeftX = -10.5
		this.RailRightX = 11.5
		this.GantryCraneX = 0.5
		this.Xmin = -9.5
		this.Xmax = 10.5
		if this.GarageSize == "Normal" then
			this.RailsY = 12.5
			this.Ymin = -5.5
			this.Ymax = 11.5
			Set(this,"MaxLimos",8)
		elseif this.GarageSize == "Tall" then
			this.RailsY = 22.5
			this.Ymin = -5.5
			this.Ymax = 21.5
			Set(this,"MaxLimos",16)
		end
	elseif this.GaragePlacement == "Left" then
		this.RailLeftX = -12.5
		this.RailRightX = 3.5
		this.GantryCraneX = -4.5
		this.Xmin = -11.5
		this.Xmax = 2.5
		if this.GarageSize == "Normal" then
			this.RailsY = 12.5
			this.Ymin = -5.5
			this.Ymax = 11.5
			Set(this,"MaxLimos",8)
		elseif this.GarageSize == "Tall" then
			this.RailsY = 22.5
			this.Ymin = -5.5
			this.Ymax = 21.5
			Set(this,"MaxLimos",16)
		elseif this.GarageSize == "Wide" then
			this.RailLeftX = -18.5
			this.GantryCraneX = -7.5
			this.Xmin = -17.5
			this.RailsY = 12.5
			this.Ymin = -5.5
			this.Ymax = 11.5
			Set(this,"MaxLimos",16)
		end
	else
		this.RailLeftX = -3.5
		this.RailRightX = 12.5
		this.GantryCraneX = 4.5
		this.Xmin = -2.5
		this.Xmax = 11.5
		if this.GarageSize == "Normal" then
			this.RailsY = 12.5
			this.Ymin = -5.5
			this.Ymax = 11.5
			Set(this,"MaxLimos",8)
		elseif this.GarageSize == "Tall" then
			this.RailsY = 22.5
			this.Ymin = -5.5
			this.Ymax = 21.5
			Set(this,"MaxLimos",16)
		elseif this.GarageSize == "Wide" then
			this.RailRightX = 18.5
			this.GantryCraneX = 7.5
			this.Xmax = 17.5
			this.RailsY = 12.5
			this.Ymin = -5.5
			this.Ymax = 11.5
			Set(this,"MaxLimos",16)
		end
	end
end

function toggleShowPreviewClicked()
	if previewShown == false then
		SetCoordinates()
		if this.OrigX+this.RailLeftX <= this.MyLeftEdge then
			checker = Object.Spawn("FoundationChecker",2,this.OrigY-2)
			checker.SubType = 1
			Set(checker,"HomeUID",this.HomeUID)
			checker.Tooltip = "Gantry crane must have different placement.\nLeft wall exceeds map edge and will be open for prisoners!"
		else
			previewRailLeft = Object.Spawn("GantryRail2Preview",this.OrigX+this.RailLeftX,this.OrigY+this.RailsY)
			Set(previewRailLeft,"HomeUID",this.HomeUID)
			if this.GarageSize == "Tall" then previewRailLeft.SubType = 1 end
		end
		if this.OrigX+this.RailRightX >= this.MyRightEdge then
			checker = Object.Spawn("FoundationChecker",this.MyRightEdge-2,this.OrigY-2)
			checker.SubType = 1
			Set(checker,"HomeUID",this.HomeUID)
			checker.Tooltip = "Gantry crane must have different placement.\nRight wall exceeds map edge and will be open for prisoners!"
		else
			previewRailRight = Object.Spawn("GantryRail2Preview",this.OrigX+this.RailRightX,this.OrigY+this.RailsY)
			Set(previewRailRight,"HomeUID",this.HomeUID)
			if this.GarageSize == "Tall" then previewRailRight.SubType = 1 end
		end
		previewGantry = Object.Spawn("GantryCrane2Preview",this.OrigX+this.GantryCraneX,this.OrigY)
		Set(previewGantry,"HomeUID",this.HomeUID)
		if this.GaragePlacement ~= "Centre" then previewGantry.SubType = 1 end
		if this.GarageSize == "Wide" then previewGantry.SubType = 0 end
		
		previewGateSingleTop1 = Object.Spawn("GantryRoadGate2Preview",this.OrigX,this.OrigY+this.Ymin-1)
		Set(previewGateSingleTop1,"HomeUID",this.HomeUID)
		previewGateSingleBottom1 = Object.Spawn("GantryRoadGate2Preview",this.OrigX,this.OrigY+this.Ymax+2)
		Set(previewGateSingleBottom1,"HomeUID",this.HomeUID)
		
		if this.RoadSize == "Double" then
			if this.GaragePlacement == "Left" then
				previewGateSingleTop2 = Object.Spawn("GantryRoadGate2Preview",this.OrigX-3,this.OrigY+this.Ymin-1)
				previewGateSingleBottom2 = Object.Spawn("GantryRoadGate2Preview",this.OrigX-3,this.OrigY+this.Ymax+2)
			else
				previewGateSingleTop2 = Object.Spawn("GantryRoadGate2Preview",this.OrigX+3,this.OrigY+this.Ymin-1)
				previewGateSingleBottom2 = Object.Spawn("GantryRoadGate2Preview",this.OrigX+3,this.OrigY+this.Ymax+2)
			end
			Set(previewGateSingleTop2,"HomeUID",this.HomeUID)
			Set(previewGateSingleBottom2,"HomeUID",this.HomeUID)
		end
		previewShown = true
	else
		local FoundationCheckers = Find(this,"FoundationChecker",50)
		if next(FoundationCheckers) then
			for thatFoundationChecker, dist in pairs(FoundationCheckers) do
				if thatFoundationChecker.HomeUID == this.HomeUID then
					thatFoundationChecker.Delete()
				end
			end
		end
		local Crane = Find(this,"GantryCrane2Preview",50)
		if next(Crane) then
			for thatCrane, dist in pairs(Crane) do
				if thatCrane.HomeUID == this.HomeUID then
					thatCrane.Delete()
				end
			end
		end
		local Rails = Find(this,"GantryRail2Preview",50)
		if next(Rails) then
			for thatRail, dist in pairs(Rails) do
				if thatRail.HomeUID == this.HomeUID then
					thatRail.Delete()
				end
			end
		end
		local Gates = Find(this,"GantryRoadGate2Preview",50)
		if next(Gates) then
			for thatGate, dist in pairs(Gates) do
				if thatGate.HomeUID == this.HomeUID then
					thatGate.Delete()
				end
			end
		end
		previewShown = false
	end
end

function toggleBuildFloorClicked()
	if this.StartBuilding == false then
		SetCoordinates()
		Set(this,"StartBuilding",true)
	end
end

function FindInSquare(theObject) -- returns target objects in my garage
	local ListOfObjects = this.GetNearbyObjects(theObject,50)
	for thatObject, distance in pairs(ListOfObjects) do
		--print("scanning position for object"..theObject)
		if (thatObject.Pos.x>=math.floor(this.OrigX+this.Xmin) and thatObject.Pos.x<=math.ceil(this.OrigX+this.Xmax)) and (thatObject.Pos.y>=math.floor(this.OrigY+this.Ymin) and thatObject.Pos.y<=math.ceil(this.OrigY+this.Ymax)) then
		-- it's ok, put other stuff here if you need
		else
			ListOfObjects[thatObject]=nil -- remove the out of bounds object from the list
		end
	end
	return ListOfObjects
end

function toggleScanInventoryClicked()
	local GantryControlOK = false
	--print("find GantryCrane2BoothPreview")
    local myGantryControls = FindInSquare("GantryCrane2BoothPreview")
	if next(myGantryControls) then
		Interface.RemoveComponent(this,"Caption_PlaceBooth", "Caption", "tooltip_Caption_PlaceBooth")
		GantryControlOK = true
		InventoryControl = "OK"
		--print("GantryCrane2BoothPreview OK")
	else
		Interface.AddComponent(this,"Caption_PlaceBooth", "Caption", "tooltip_Caption_PlaceBooth")
		InventoryControl = "missing"
	end
	myGantryControls = nil
	
	local RepairSpotsOK = false
	local PaintSpotsOK = false
	--print("find Limo2Preview")
    local myRepairSpots = FindInSquare("Limo2Preview")
	if next(myRepairSpots) then
		RepairSpotsOK = true
		InventoryRepairSpots = "OK"
		--print("Limo2Preview OK")
		for thatSpot, dist in pairs(myRepairSpots) do
			if thatSpot.SpotType == "Paint" then
				PaintSpotsOK = true
			end
			break
		end
	else
		InventoryRepairSpots = "missing"
	end
	myRepairSpots = nil
	
	local RackOK = false
	--print("find CarPartsRack2Preview")
    local myRacks = FindInSquare("CarPartsRack2Preview")
	if next(myRacks) then
		RackOK = true
		--print("CarPartsRack2Preview OK")
		InventoryPartsRack = "OK"
	elseif PaintSpotsOK == true then
		RackOK = true
		--print("Paintspots found, parts rack not required, CarPartsRack2Preview OK")
		InventoryPartsRack = "OK"
	else
		InventoryPartsRack = "missing"
	end
	myRacks = nil
	
	local DeskOK = false
	--print("find ServiceDesk2Preview")
    local myDesk = FindInSquare("Limo2ServiceDeskPreview")
	if next(myDesk) then
		DeskOK = true
		--print("ServiceDesk2Preview OK")
		InventoryServiceDesk = "OK"
	else
		InventoryServiceDesk = "missing"
	end
	myDesk = nil
	
	local FilingOK = false
	--print("find Limo2FilingCabinetPreview")
    local myFiling = FindInSquare("Limo2FilingCabinetPreview")
	if next(myFiling) then
		FilingOK = true
		InventoryCabinet = "OK"
		--print("Limo2FilingCabinetPreview OK")
	else
		InventoryCabinet = "missing"
	end
	myFiling = nil
	
	Interface.SetComponentProperties( "FloorDone2", { Replacements = { A = InventoryRepairSpots, B = InventoryPartsRack, C = InventoryControl, D = InventoryServiceDesk, E = InventoryCabinet } } )
	
	if GantryControlOK == true and RackOK == true and RepairSpotsOK == true and DeskOK == true and FilingOK == true then
	
		local myGantryControls = FindInSquare("GantryCrane2BoothPreview")
		if next(myGantryControls) then
			for thatBooth, dist in pairs(myGantryControls) do
				MyCraneBooth = Object.Spawn("GantryCrane2Booth",thatBooth.Pos.x,thatBooth.Pos.y)
				Set(MyCraneBooth,"TimeWarp",this.TimeWarp)
				thatBooth.Delete()
				Set(MyCraneBooth,"HomeUID",this.HomeUID)
				Set(MyCraneBooth,"TrafficLightUpgradeV2",true)
			end
		end
		myGantryControls = nil
	
		local myRacks = FindInSquare("CarPartsRack2Preview")
		if next(myRacks) then
			for thatRack, dist in pairs(myRacks) do
				MyRack = Object.Spawn("CarPartsRack2",thatRack.Pos.x,thatRack.Pos.y)
				Set(MyRack,"HomeUID",this.HomeUID)
				Set(MyRack,"Tooltip","HomeUID: "..this.HomeUID)
				Set(MyRack,"Slot0X",thatRack.Pos.x-1.5)
				Set(MyRack,"Slot0Y",thatRack.Pos.y)
				Set(MyRack,"Slot1X",thatRack.Pos.x-0.5)
				Set(MyRack,"Slot1Y",thatRack.Pos.y)
				Set(MyRack,"Slot2X",thatRack.Pos.x+0.5)
				Set(MyRack,"Slot2Y",thatRack.Pos.y)
				Set(MyRack,"Slot3X",thatRack.Pos.x+1.5)
				Set(MyRack,"Slot3Y",thatRack.Pos.y)
				Set(MyRack,"Slot4X",thatRack.Pos.x-1.5)
				Set(MyRack,"Slot4Y",thatRack.Pos.y-1)
				Set(MyRack,"Slot5X",thatRack.Pos.x-0.5)
				Set(MyRack,"Slot5Y",thatRack.Pos.y-1)
				Set(MyRack,"Slot6X",thatRack.Pos.x+0.5)
				Set(MyRack,"Slot6Y",thatRack.Pos.y-1)
				Set(MyRack,"Slot7X",thatRack.Pos.x+1.5)
				Set(MyRack,"Slot7Y",thatRack.Pos.y-1)
				thatRack.Delete()
			end
		end
		myRacks = nil
	
		BuildGarage()
		
		local myRepairSpots = FindInSquare("Limo2Preview")
		if next(myRepairSpots) then
			local RepairSpot = 0
			for thatSpot,dist in pairs(myRepairSpots) do
				Set(MyCraneBooth,"SpotType"..RepairSpot,thatSpot.SpotType)
				if thatSpot.SpotType == "Repair" then
					MakeCarSpotsFloor(thatSpot.Pos.x-1,thatSpot.Pos.y-2)
					Set(MyCraneBooth,"Slot"..RepairSpot.."X",thatSpot.Pos.x)
					Set(MyCraneBooth,"Slot"..RepairSpot.."Y",thatSpot.Pos.y-0.5)
					Set(MyCraneBooth,"SpotType"..RepairSpot,thatSpot.SpotType)
					Set(MyCraneBooth,"ttSlot"..RepairSpot,"Empty Repair Spot")
				else
					newPaint = Object.Spawn("GantryCrane2PaintCabin",thatSpot.Pos.x,thatSpot.Pos.y)
					Set(newPaint,"HomeUID",this.HomeUID)
					Set(newPaint,"Tooltip","HomeUID: "..this.HomeUID)
					Set(MyCraneBooth,"Slot"..RepairSpot.."X",thatSpot.Pos.x)
					Set(MyCraneBooth,"Slot"..RepairSpot.."Y",thatSpot.Pos.y-0.5)
					Set(MyCraneBooth,"SpotType"..RepairSpot,thatSpot.SpotType)
					Set(MyCraneBooth,"ttSlot"..RepairSpot,"Empty Paint Spot")
				end
				newNumber = Object.Spawn("Nr"..(RepairSpot+1),thatSpot.Pos.x,thatSpot.Pos.y-0.5+1.9275)
				Set(newNumber,"HomeUID",this.HomeUID)
				RepairSpot = RepairSpot + 1
				thatSpot.Delete()
			end
		end
		
		local myLessonSpots = FindInSquare("Limo2LessonPreview")
		if next(myLessonSpots) then
			local LessonSpot = 1
			for thatSpot,dist in pairs(myLessonSpots) do
				newLessonCar = Object.Spawn("Limo2Lesson",thatSpot.Pos.x,thatSpot.Pos.y)
				if this.IsMilitary == "Yes" then newLessonCar.SubType = 3 else newLessonCar.SubType = math.random(0,2) end
				Set(newLessonCar,"HomeUID",this.HomeUID)
				Set(newLessonCar,"LessonSpot",LessonSpot)
				Set(newLessonCar,"CountDown",false)
				Set(newLessonCar,"EngineJobIssued",false)
				Set(newLessonCar,"Tooltip","HomeUID: "..this.HomeUID)
				MakeLessonCarFloor(thatSpot.Pos.x-1,thatSpot.Pos.y-1)
				Set(MyCraneBooth,"Lesson"..LessonSpot.."ID",newLessonCar.Id.i)
				Set(MyCraneBooth,"LessonSpot"..LessonSpot.."X",thatSpot.Pos.x)
				Set(MyCraneBooth,"LessonSpot"..LessonSpot.."Y",thatSpot.Pos.y-1.25)
				Set(MyCraneBooth,"ttLessonSlot"..LessonSpot,"Empty Lesson Spot")
				newNumber = Object.Spawn("Nr"..LessonSpot,thatSpot.Pos.x,thatSpot.Pos.y-1.25+1.9275)
				Set(newNumber,"HomeUID",this.HomeUID)
				LessonSpot = LessonSpot + 1
				thatSpot.Delete()
			end
		end
		
		local s = 7
		if this.GarageSize == "Tall" or this.GarageSize == "Wide" then s = 15 end
		for j=0,s do
			if Get(MyCraneBooth,"Slot"..j.."X") == nil then
				Set(MyCraneBooth,"ttSlot"..j,"(not in use)")
			end
		end
		
		for j=1,10 do
			if Get(MyCraneBooth,"LessonSpot"..j.."X") == nil then
				Set(MyCraneBooth,"ttLessonSlot"..j,"(not in use)")
			end
		end
		
		local myServiceDesks = FindInSquare("Limo2ServiceDeskPreview")
		if next(myServiceDesks) then
			for thatServiceDesk, dist in pairs(myServiceDesks) do
				MyServiceDesk = Object.Spawn("Limo2ServiceDesk",thatServiceDesk.Pos.x,thatServiceDesk.Pos.y)
				Set(MyServiceDesk,"TimeWarp",this.TimeWarp)
				if thatServiceDesk.SubType == 0 then	-- translate the RotateType 4 from the preview desk
					Set(MyServiceDesk,"Or.x",0)			-- into RotateType 1 for the real desk
					Set(MyServiceDesk,"Or.y",1)
				elseif thatServiceDesk.SubType == 1 then
					Set(MyServiceDesk,"Or.x",0)
					Set(MyServiceDesk,"Or.y",-1)
				elseif thatServiceDesk.SubType == 2 then
					MyServiceDesk.Pos.y = MyServiceDesk.Pos.y - 0.5
					Set(MyServiceDesk,"Or.x",-1)
					Set(MyServiceDesk,"Or.y",0)
				elseif thatServiceDesk.SubType == 3 then
					MyServiceDesk.Pos.y = MyServiceDesk.Pos.y - 0.5
					Set(MyServiceDesk,"Or.x",1)
					Set(MyServiceDesk,"Or.y",0)
				end
				thatServiceDesk.Delete()
				Set(MyServiceDesk,"HomeUID",this.HomeUID)
				Set(MyServiceDesk,"Tooltip","HomeUID: "..this.HomeUID)
			end
		end
		myServiceDesks = nil
	
		local myFiling = FindInSquare("Limo2FilingCabinetPreview")
		if next(myFiling) then
			for thatFiling, dist in pairs(myFiling) do
				MyFilingCabinet = Object.Spawn("Limo2FilingCabinet",thatFiling.Pos.x,thatFiling.Pos.y)
				if thatFiling.SubType == 0 then
					Set(MyFilingCabinet,"Or.x",0)
					Set(MyFilingCabinet,"Or.y",1)
				elseif thatFiling.SubType == 1 then
					Set(MyFilingCabinet,"Or.x",0)
					Set(MyFilingCabinet,"Or.y",-1)
				elseif thatFiling.SubType == 2 then
					Set(MyFilingCabinet,"Or.x",-1)
					Set(MyFilingCabinet,"Or.y",0)
				elseif thatFiling.SubType == 3 then
					Set(MyFilingCabinet,"Or.x",1)
					Set(MyFilingCabinet,"Or.y",0)
				end

				thatFiling.Delete()
				Set(MyFilingCabinet,"HomeUID",this.HomeUID)
				Set(MyFilingCabinet,"Tooltip","HomeUID: "..this.HomeUID)
			end
		end
		myFiling = nil
	
		Set(MyCraneBooth,"FloorMade",true)
		Set(StreetManager,"UpdateRoadMap",true)
		
		if previewShown == true then
			toggleShowPreviewClicked()
		end
		this.Delete()
	end
end

function RemoveTrees(from,dist)
	for j = 1, #TreeTypes do
		for thatTree in next, Find(from,TreeTypes[j],dist) do
			thatTree.Delete()
		end
	end
	-- local nearbyTrees = Find(MyTreeRemover,"Tree",4)
	-- if next(nearbyTrees) then
		-- for thatTree, distance in pairs(nearbyTrees) do
			-- thatTree.Delete()
		-- end
	-- end
	-- nearbyTrees=nil
end

function BuildMyRoad(theSide, theSize)
	FindMyRoadMarker()
	if markerFound == false then	-- if no roadmarker was on this lane yet, then build a road. otherwise a roadmarker was already placed by a cargo station
		print("BuildMyRoad "..this.RoadSize)
		local endY=-1
		local PosX = 0
		if this.RoadSize == "Single" then
			PosX = math.floor(this.OrigX)
		else
			PosX = math.floor(this.OrigX) + 1
		end
		local foundEndY=false
		MyTreeRemover = Object.Spawn("TreeRemover",PosX,1)
		local TreeRemoverPriorPosY = MyTreeRemover.Pos.y
		while foundEndY==false do
			endY=endY+1
			local myCell = World.GetCell(PosX,endY)
			if myCell.Mat==nil then
				foundEndY=true
				endY=endY-1
				RemoveTrees(MyTreeRemover,4)
				MyTreeRemover.Delete()
			elseif this.RoadSize == "Single" then
				MyTreeRemover.Pos.y = endY
				if MyTreeRemover.Pos.y >= TreeRemoverPriorPosY+3 then
					TreeRemoverPriorPosY = MyTreeRemover.Pos.y
					RemoveTrees(MyTreeRemover,4)
				end
				local myCTL = World.GetCell(PosX-2,endY)
				local myRML = World.GetCell(PosX-1,endY)
				local myRMR = World.GetCell(PosX,endY)
				local myCTR = World.GetCell(PosX+1,endY)
				myCTL.Mat="ConcreteTiles"; myRML.Mat="RoadMarkingsLeft"; myRMR.Mat="RoadMarkingsRight"; myCTR.Mat="ConcreteTiles"
			elseif this.RoadSize == "Double" then
				local myCTL = World.GetCell(PosX-3,endY)
				local myRML = World.GetCell(PosX-2,endY)
				local myRL = World.GetCell(PosX-1,endY)
				local myRC = World.GetCell(PosX,endY)
				local myRR = World.GetCell(PosX+1,endY)
				local myRMR = World.GetCell(PosX+2,endY)
				local myCTR = World.GetCell(PosX+3,endY)
				MyTreeRemover.Pos.y = endY
				if MyTreeRemover.Pos.y >= TreeRemoverPriorPosY+3 then
					TreeRemoverPriorPosY = MyTreeRemover.Pos.y
					RemoveTrees(MyTreeRemover,4)
				end
				if TickTock==false then				-- toggle for center road markings on double lane
					myCTL.Mat="ConcreteTiles"; myRML.Mat="RoadMarkingsLeft"; myRL.Mat="Road"; myRC.Mat="RoadMarkings"; myRR.Mat="Road"; myRMR.Mat="RoadMarkingsRight"; myCTR.Mat="ConcreteTiles"
					TickTock=true
				else
					myCTL.Mat="ConcreteTiles"; myRML.Mat="RoadMarkingsLeft"; myRL.Mat="Road"; myRC.Mat="Road"; myRR.Mat="Road"; myRMR.Mat="RoadMarkingsRight"; myCTR.Mat="ConcreteTiles"
					TickTock=false
				end
			end
		end
	end
end

function Update(timePassed)
	if not Get(this,"OrigXSet") then
		Set(this,"OrigX",math.floor(this.Pos.x))
		Set(this,"OrigY",math.floor(this.Pos.y)+6)
		Set(this,"OrigXSet",true)
	end
	if Get(this,"FromPrefab") == true then
		SetCoordinates()
		MakeRoadClicked()
		Set(this,"FromPrefab",nil)
	end
	this.Pos.x = this.OrigX
	this.Pos.y = this.OrigY
	if not Get(this,"TopOrBottomGarages") then
		CheckForOtherGarages()
		Set(this,"TopOrBottomGarages",true)
		return
	end
				
	timeAnim=timeAnim+timePassed
	if timeAnim > timePerAnim then
		timeAnim=0
		if this.SubType == 1 then this.SubType = 2 else this.SubType = 1 end
	end
				
	if this.TimeWarp == nil then
		if World.TimeWarpFactor ~= nil then
			Set(this,"TimeWarp",World.TimeWarpFactor)
			this.Tooltip = "tooltip_ReadyForAction"
		else
			CalculateTimeWarpFactor(timePassed)
		end
		return
	elseif timePerUpdate == nil then
		timePerUpdate = 1 / myTimeWarpFactor
		if not Get(this,"FoundationDone") then
			if not ButtonStartBuildingPressed then
				Interface.SetReportTabs( "reportTab_tab1")
			else
				Interface.SetReportTabs( "reportTab_tab1","reportTab_tab2")
			end
		else
			Interface.SetReportTabs( "reportTab_tab1","reportTab_tab2","reportTab_tab3","reportTab_tab4","reportTab_tab5")
		end
	end
	
	timeTot=timeTot+timePassed
	if timeTot>=timePerUpdate then
		timeTot=0
		if this.StartBuilding == true then
			if not Get(this,"FoundationDone") then
				CreateFoundation()
			end
		end
	end
end

function CreateFoundation()
	print("CreateFoundation")
	local x = math.floor(this.OrigX)
	local y = math.floor(this.OrigY)
	for i=math.floor(this.Ymin-1),math.ceil(this.Ymax+1) do	for j=this.Xmin-1,this.Xmax+1 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "BrickWall"; 	cell.Ind = true end	end
	for i=math.floor(this.Ymin),math.ceil(this.Ymax) do		for j=this.Xmin,this.Xmax do		local cell = World.GetCell(x+j,y+i);	cell.Mat = "ConcreteFloor"; cell.Ind = true end	end
	
	local left = x+this.Xmin
	local right = x+this.Xmax
	local up = y+this.Ymin
	local down = y+this.Ymax
	local centreX = left + ((right-left) / 2)
	local centreY = up + ((down-up) / 2)
	local rangeH = right-left
	local rangeV = down-up
	local range = rangeH
	if rangeH < rangeV then range = rangeV end
	local treeChecker = Object.Spawn("FoundationChecker",centreX,centreY)
	treeChecker.Tooltip = "TreeChecker"
	RemoveTrees(treeChecker,range/1.25)
	treeChecker.Delete()
	
	BuildMyRoad()
	MakeRoadClicked()
	
	if previewShown == false then
		toggleShowPreviewClicked()
	end
	local Crane = Find(this,"GantryCrane2Preview",50)
	if next(Crane) then
		for thatCrane, dist in pairs(Crane) do
			if thatCrane.HomeUID == this.HomeUID then
				thatCrane.Delete()
			end
		end
	end
	if this.GaragePlacement == "Left" then
		local offSetX = 0
		if this.RoadSize =="Double" then offSetX = -4 end
		newDoor = Object.Spawn("StaffDoor",this.OrigX-2.5+offSetX,this.OrigY+this.Ymin-1)
		Set(newDoor,"HomeUID",this.HomeUID)
	else
		local offSetX = 0
		if this.RoadSize =="Double" then offSetX = 4 end
		newDoor = Object.Spawn("StaffDoor",this.OrigX+2.5+offSetX,this.OrigY+this.Ymin-1)
		Set(newDoor,"Or.y",-1)
		Set(newDoor,"OpenDir.x",1)
		Set(newDoor,"OpenDir.y",0)
		Set(newDoor,"HomeUID",this.HomeUID)
	end
	
	MyRepairedLimoGate = Object.Spawn("RoadGate2Small",this.OrigX,this.OrigY+this.Ymax-4.5)
	Set(MyRepairedLimoGate,"HomeUID",this.HomeUID)
	Set(MyRepairedLimoGate,"SmallPost",true)
	Set(MyRepairedLimoGate,"ScanForStaff","YES")
	Set(MyRepairedLimoGate,"SubType",10)
	Set(MyRepairedLimoGate,"GateCreated",true)
	if this.GaragePlacement == "Left" then
		Set(MyRepairedLimoGate,"Or.y",-1)
		Set(MyRepairedLimoGate,"OpenDir.x",2)
		Set(MyRepairedLimoGate,"OpenDir.y",0)
		leftPart=Object.Spawn("RoadPoleEnd",MyRepairedLimoGate.Pos.x-1.5,MyRepairedLimoGate.Pos.y+0.5)
		rightPart=Object.Spawn("RoadPoleStart",MyRepairedLimoGate.Pos.x+2.5,MyRepairedLimoGate.Pos.y+0.5)
		MyRoadPole=Object.Spawn("SmallRoadPole",MyRepairedLimoGate.Pos.x+2,MyRepairedLimoGate.Pos.y)
		MyTrafficLightR = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x+2.5,MyRepairedLimoGate.Pos.y)
		Set(MyRoadPole,"SubType",1)
		Set(leftPart,"HomeUID",this.HomeUID)
		Set(leftPart,"Tooltip","HomeUID: "..this.HomeUID)
		Set(rightPart,"HomeUID",this.HomeUID)
		Set(rightPart,"Tooltip","HomeUID: "..this.HomeUID)
		Set(MyRoadPole,"HomeUID",this.HomeUID)
		Set(MyRoadPole,"Tooltip","HomeUID: "..this.HomeUID)
		Set(MyTrafficLightR,"HomeUID",this.HomeUID)
		Set(MyTrafficLightR,"Tooltip","HomeUID: "..this.HomeUID)
		Set(MyTrafficLightR,"SideLaneLight",true)
		Set(MyTrafficLightR,"LightType",3)
		Set(MyTrafficLightR,"SubType",3)
		rightPart.Slot0.i = MyTrafficLightR.Id.i
		rightPart.Slot0.u = MyTrafficLightR.Id.u
		MyTrafficLightR.CarrierId.i = rightPart.Id.i
		MyTrafficLightR.CarrierId.u = rightPart.Id.u
		MyTrafficLightR.Loaded = true
		
		MyTrafficLightL = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x-1.5,MyRepairedLimoGate.Pos.y)
		Set(MyTrafficLightL,"HomeUID",this.HomeUID)
		Set(MyTrafficLightL,"LightType",0)
		Set(MyTrafficLightL,"Tooltip",MyRepairedLimoGate.Tooltip)
	else
		leftPart=Object.Spawn("RoadPoleStart",MyRepairedLimoGate.Pos.x-2.5,MyRepairedLimoGate.Pos.y+0.5)
		rightPart=Object.Spawn("RoadPoleEnd",MyRepairedLimoGate.Pos.x+1.5,MyRepairedLimoGate.Pos.y+0.5)
		rightPart.SubType = 1
		MyRoadPole=Object.Spawn("SmallRoadPole",MyRepairedLimoGate.Pos.x-2,MyRepairedLimoGate.Pos.y)
		MyTrafficLightL = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x-2.5,MyRepairedLimoGate.Pos.y)
		Set(leftPart,"HomeUID",this.HomeUID)
		Set(leftPart,"Tooltip","HomeUID: "..this.HomeUID)
		Set(rightPart,"HomeUID",this.HomeUID)
		Set(rightPart,"Tooltip","HomeUID: "..this.HomeUID)
		Set(MyRoadPole,"HomeUID",this.HomeUID)
		Set(MyRoadPole,"Tooltip","HomeUID: "..this.HomeUID)
		Set(MyTrafficLightL,"HomeUID",this.HomeUID)
		Set(MyTrafficLightL,"Tooltip","HomeUID: "..this.HomeUID)
		Set(MyTrafficLightL,"SideLaneLight",true)
		Set(MyTrafficLightL,"LightType",3)
		Set(MyTrafficLightL,"SubType",3)
		leftPart.Slot0.i = MyTrafficLightL.Id.i
		leftPart.Slot0.u = MyTrafficLightL.Id.u
		MyTrafficLightL.CarrierId.i = leftPart.Id.i
		MyTrafficLightL.CarrierId.u = leftPart.Id.u
		MyTrafficLightL.Loaded = true
		MyTrafficLightR = Object.Spawn("RoadGate2TrafficLightSmall",MyRepairedLimoGate.Pos.x+1.5,MyRepairedLimoGate.Pos.y)
		Set(MyTrafficLightR,"HomeUID",this.HomeUID)
		Set(MyTrafficLightR,"LightType",0)
		Set(MyTrafficLightR,"Tooltip",MyRepairedLimoGate.Tooltip)
	end
	Set(this,"FoundationDone",true)
end

function MakeRoadClicked()
	print("MakeRoadClicked")
	local x = math.floor(this.OrigX-1)
	local y = math.floor(this.OrigY+this.Ymin-1)
	local cell = World.GetCell(x-1,y)
	if this.GaragePlacement == "Left" then
		for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
			cell = World.GetCell(x-1,y+i)	cell.Mat = "ConcreteTiles"; 	cell.Ind = true
			cell = World.GetCell(x,y+i)		cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x+1,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			cell = World.GetCell(x+2,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x+3,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
		end
		if this.RoadSize == "Double" then
			for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
				cell = World.GetCell(x-4,y+i)	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
				cell = World.GetCell(x-3,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
				cell = World.GetCell(x-2,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			end
		end
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))-4)	cell.Mat = "innerdiagroadTR";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-4)	cell.Mat = "diagsidewalkTR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-4)	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))-3)	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-3)	cell.Mat = "innerdiagroadTR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-3)	cell.Mat = "diagsidewalkTR";	cell.Ind = true
		
		cell = World.GetCell(x,y+math.floor((-this.Ymin)))		cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin)))	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTR";	cell.Ind = true 
		
		cell = World.GetCell(x+1,y+math.ceil(this.Ymax))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.ceil(this.Ymax+1))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+1))	cell.Mat = "innerdiagroadBR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+1))	cell.Mat = "diagsidewalkBR";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.ceil(this.Ymax+2))	cell.Mat = "innerdiagroadBR";	cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+2))	cell.Mat = "diagsidewalkBR";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+2))	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+3))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+3))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+4))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+4))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+5))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+5))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+6))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+6))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+2,y+math.ceil(this.Ymax+7))	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+7))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x+3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";			cell.Ind = true
		
		if this.RoadSize == "Double" then
			cell = World.GetCell(x-6,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
			cell = World.GetCell(x-4,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			
			cell = World.GetCell(x-4,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
		else
			cell = World.GetCell(x-3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			
			cell = World.GetCell(x-3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
		end
	else
		for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
			if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+i)	cell.Mat = "ConcreteTiles";	cell.Ind = true end
			cell = World.GetCell(x-2,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x-1,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			cell = World.GetCell(x,y+i)		cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
			cell = World.GetCell(x+1,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
			cell = World.GetCell(x+2,y+i)	cell.Mat = "ConcreteTiles";		cell.Ind = true
		end
		if this.RoadSize =="Double" then
			for i=0,math.floor((-this.Ymin))+math.ceil(this.Ymax+3) do
				cell = World.GetCell(x+3,y+i)	cell.Mat = "RoadMarkingsLeft";	cell.Ind = true
				cell = World.GetCell(x+4,y+i)	cell.Mat = "RoadMarkingsRight";	cell.Ind = true
				cell = World.GetCell(x+5,y+i)	cell.Mat = "yellowcrosslinesL";	cell.Ind = true
			end
		end
		cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-4)	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-4)	cell.Mat = "diagsidewalkTL";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))-4)	cell.Mat = "innerdiagroadTL";	cell.Ind = true
		cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-3)	cell.Mat = "diagsidewalkTL";	cell.Ind = true
		cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-3)	cell.Mat = "innerdiagroadTL";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))-3)	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))-2)	cell.Mat = "Road";	cell.Ind = true
		
		cell = World.GetCell(x,y+math.floor((-this.Ymin)))		cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin)))	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+1)	cell.Mat = "outercornerTR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+2)	cell.Mat = "outercornerBR";	cell.Ind = true
		cell = World.GetCell(x,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTL";	cell.Ind = true
		cell = World.GetCell(x+1,y+math.floor((-this.Ymin))+3)	cell.Mat = "outercornerTR";	cell.Ind = true
		
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x,y+math.ceil(this.Ymax))		cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x,y+math.ceil(this.Ymax+1))	cell.Mat = "Road";	cell.Ind = true
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+1))	cell.Mat = "diagsidewalkBL";	cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+1))	cell.Mat = "innerdiagroadBL";	cell.Ind = true
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+2))	cell.Mat = "ConcreteTiles";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+2))	cell.Mat = "diagsidewalkBL";	cell.Ind = true
		cell = World.GetCell(x,y+math.ceil(this.Ymax+2))	cell.Mat = "innerdiagroadBL";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+3))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+3))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+3))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+4))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+4))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+4))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+5))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+5))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+5))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+6))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+6))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+6))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true
		if this.GaragePlacement == "Centre" then cell = World.GetCell(x-3,y+math.ceil(this.Ymax+7))	cell.Mat = "ConcreteFloor";	cell.Ind = true end
		cell = World.GetCell(x-2,y+math.ceil(this.Ymax+7))	cell.Mat = "ConcreteFloor";		cell.Ind = true
		cell = World.GetCell(x-1,y+math.ceil(this.Ymax+7))	cell.Mat = "yellowcrosslinesR";	cell.Ind = true

		if this.RoadSize == "Double" then
			cell = World.GetCell(x-3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+5,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+7,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
		
			cell = World.GetCell(x-3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+5,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
		else
			cell = World.GetCell(x-3,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-1,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x-2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+2,y+math.floor((-this.Ymin))-5)	cell.Mat = "BrickWall";		cell.Ind = true
			cell = World.GetCell(x+3,y+math.floor((-this.Ymin))-5)	cell.Mat = "ConcreteTiles";	cell.Ind = true
		
			cell = World.GetCell(x-3,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x-1,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
			cell = World.GetCell(x+2,y+math.ceil(this.Ymax+8))	cell.Mat = "BrickWall";	cell.Ind = true
		end
	end
end

function BuildGarage()
	MyCrane = Object.Spawn("GantryCrane2",this.OrigX+this.GantryCraneX,this.OrigY)
	if this.GaragePlacement ~= "Centre" then MyCrane.SubType = 1 end
	if this.GarageSize == "Wide" then MyCrane.SubType = 0 end
	Set(MyCrane,"HomeUID",this.HomeUID)
	Set(MyCrane,"TimeWarp",this.TimeWarp)
	Set(MyCrane,"GarageSize",GarageSize)
	Set(MyCrane,"GaragePlacement",GaragePlacement)
	Set(MyCrane,"CraneInPosition",false)
	Set(MyCrane,"MoveToCentre",false)
	Set(MyCrane,"MoveTheCrane",false)
	Set(MyCrane,"MoveToX",this.OrigX)
	Set(MyCrane,"MoveToY",this.OrigY)
	Set(MyCrane,"MoveLeftX",this.OrigX-1.5)
	Set(MyCrane,"MoveRightX",this.OrigX+1.5)
	Set(MyCrane,"TmpLeftX",this.OrigX)
	Set(MyCrane,"TmpRightX",this.OrigX)
	Set(MyCrane,"TmpY",this.OrigY)
	Set(MyCrane,"ParkX",this.OrigX)
	Set(MyCrane,"ParkY",this.OrigY)
	Set(MyCrane,"RoadX",this.OrigX)
	Set(MyCrane,"Retry",0)
	
	MyCraneRailRight = Object.Spawn("GantryCrane2RailRight",this.OrigX+this.RailRightX,this.OrigY+this.RailsY)
	if this.GarageSize == "Tall" then MyCraneRailRight.SubType = 1 end
	Set(MyCraneRailRight,"GarageSize",this.GarageSize)
	Set(MyCraneRailRight,"GaragePlacement",this.GaragePlacement)
	Set(MyCraneRailRight,"HomeUID",this.HomeUID)
	Set(MyCraneRailRight,"Tooltip","HomeUID: "..this.HomeUID)
	
	MyCraneRailLeft = Object.Spawn("GantryCrane2RailLeft",this.OrigX+this.RailLeftX,this.OrigY+this.RailsY)
	if this.GarageSize == "Tall" then MyCraneRailLeft.SubType = 1 end
	Set(MyCraneRailLeft,"GarageSize",this.GarageSize)
	Set(MyCraneRailLeft,"GaragePlacement",this.GaragePlacement)
	Set(MyCraneRailLeft,"HomeUID",this.HomeUID)
	Set(MyCraneRailLeft,"Tooltip","HomeUID: "..this.HomeUID)
	
	Set(MyCraneBooth,"IsMilitary",this.IsMilitary)
	Set(MyCraneBooth,"GarageSize",this.GarageSize)
	Set(MyCraneBooth,"GaragePlacement",this.GaragePlacement)
	Set(MyCraneBooth,"RoadSize",this.RoadSize)
	Set(MyCraneBooth,"Xmin",this.Xmin)
	Set(MyCraneBooth,"Xmax",this.Xmax)
	Set(MyCraneBooth,"Ymin",this.Ymin)
	Set(MyCraneBooth,"Ymax",this.Ymax)
	Set(MyCraneBooth,"HomeUID",this.HomeUID)
	Set(MyCraneBooth,"FloorMade",false)
	Set(MyCraneBooth,"GarageIsFull","no")
	Set(MyCraneBooth,"PartsRackIsFull","no")
	Set(MyCraneBooth,"BusyDoingJob",false)
	Set(MyCraneBooth,"ParkX",this.OrigX)
	Set(MyCraneBooth,"ParkY",this.OrigY)
	if this.GaragePlacement == "Left" then
		Set(MyCraneBooth,"TruckParkX",this.OrigX+2)
		Set(MyCraneBooth,"TruckParkY",this.OrigY+1)
	else
		Set(MyCraneBooth,"TruckParkX",this.OrigX-2)
		Set(MyCraneBooth,"TruckParkY",this.OrigY+1)
	end
	Set(MyCraneBooth,"RoadX",this.OrigX)
	Set(MyCraneBooth,"RoadY",this.OrigY+this.Ymax-2)
	Set(MyCraneBooth,"OrderLimoAmount",0)
	Set(MyCraneBooth,"OrderPartsAmount",0)
	
	Set(MyCraneBooth,"UnloadTruckSlot0",false)
	Set(MyCraneBooth,"UnloadTruckSlot1",false)
	
	Set(MyCraneBooth,"UnloadEngineSlot0",false)
	Set(MyCraneBooth,"UnloadEngineSlot1",false)
	
	Set(MyCraneBooth,"UnloadSlot0",false)
	Set(MyCraneBooth,"UnloadSlot1",false)
	Set(MyCraneBooth,"UnloadSlot2",false)
	Set(MyCraneBooth,"UnloadSlot3",false)
	Set(MyCraneBooth,"UnloadSlot4",false)
	Set(MyCraneBooth,"UnloadSlot5",false)
	Set(MyCraneBooth,"UnloadSlot6",false)
	Set(MyCraneBooth,"UnloadSlot7",false)
	Set(MyCraneBooth,"UnloadSlot8",false)
	Set(MyCraneBooth,"UnloadSlot9",false)
	Set(MyCraneBooth,"UnloadSlot10",false)
	Set(MyCraneBooth,"UnloadSlot11",false)
	Set(MyCraneBooth,"UnloadSlot12",false)
	Set(MyCraneBooth,"UnloadSlot13",false)
	Set(MyCraneBooth,"UnloadSlot14",false)
	Set(MyCraneBooth,"UnloadSlot15",false)
	
	Set(MyCraneBooth,"BringEngine0",false)
	Set(MyCraneBooth,"BringEngine1",false)
	Set(MyCraneBooth,"BringEngine2",false)
	Set(MyCraneBooth,"BringEngine3",false)
	Set(MyCraneBooth,"BringEngine4",false)
	Set(MyCraneBooth,"BringEngine5",false)
	Set(MyCraneBooth,"BringEngine6",false)
	Set(MyCraneBooth,"BringEngine7",false)
	Set(MyCraneBooth,"BringEngine8",false)
	Set(MyCraneBooth,"BringEngine9",false)
	Set(MyCraneBooth,"BringEngine10",false)
	Set(MyCraneBooth,"BringEngine11",false)
	Set(MyCraneBooth,"BringEngine12",false)
	Set(MyCraneBooth,"BringEngine13",false)
	Set(MyCraneBooth,"BringEngine14",false)
	Set(MyCraneBooth,"BringEngine15",false)
	
	Set(MyCraneBooth,"BringToRack0",false)
	Set(MyCraneBooth,"BringToRack1",false)
	Set(MyCraneBooth,"BringToRack2",false)
	Set(MyCraneBooth,"BringToRack3",false)
	Set(MyCraneBooth,"BringToRack4",false)
	Set(MyCraneBooth,"BringToRack5",false)
	Set(MyCraneBooth,"BringToRack6",false)
	Set(MyCraneBooth,"BringToRack7",false)
	Set(MyCraneBooth,"BringToRack8",false)
	
	Set(MyCraneBooth,"PutEngineInLessonCar1",false)
	Set(MyCraneBooth,"PutEngineInLessonCar2",false)
	Set(MyCraneBooth,"PutEngineInLessonCar3",false)
	Set(MyCraneBooth,"PutEngineInLessonCar4",false)
	Set(MyCraneBooth,"PutEngineInLessonCar5",false)
	Set(MyCraneBooth,"PutEngineInLessonCar6",false)
	Set(MyCraneBooth,"PutEngineInLessonCar7",false)
	Set(MyCraneBooth,"PutEngineInLessonCar8",false)
	Set(MyCraneBooth,"PutEngineInLessonCar9",false)
	Set(MyCraneBooth,"PutEngineInLessonCar10",false)
	
	Set(MyCraneBooth,"ScanForLimoOnRoad",false)
	Set(MyCraneBooth,"GateCount",0)
	Set(MyCraneBooth,"BusyDoingJob",false)
	Set(MyCraneBooth,"LimoWaitingOnRoad","no")
	Set(MyCraneBooth,"TimeToOrderLimoTruck",0)
	Set(MyCraneBooth,"TimeToOrderPartsTruck",0)
	Set(MyCraneBooth,"LimoTruckArriving","no")
	Set(MyCraneBooth,"PartsTruckArriving","no")
	Set(MyCraneBooth,"TruckTimerLimo",15+math.random()+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
	Set(MyCraneBooth,"TruckTimerParts",35+math.random()+math.random()+math.random()+math.random()+math.random()+math.random()+math.random())
	Set(MyCraneBooth,"CurrentTask","tooltip_CraneIdle")
	
	MyHook = Object.Spawn("GantryCrane2Hook",this.OrigX,this.OrigY)
	Set(MyHook,"GarageSize",this.GarageSize)
	Set(MyHook,"GaragePlacement",this.GaragePlacement)
	Set(MyHook,"RailLeftX",this.RailLeftX)
	Set(MyHook,"RailRightX",this.RailRightX)
	Set(MyHook,"RoadSize",this.RoadSize)
	Set(MyHook,"HomeUID",this.HomeUID)
	Set(MyHook,"TimeWarp",this.TimeWarp)
	Set(MyHook,"ParkX",this.OrigX)
	Set(MyHook,"ParkY",this.OrigY)
	Set(MyHook,"RoadX",this.OrigX)
	
	MyCraneWheelLeft = Object.Spawn("GantryCrane2Wheel",this.OrigX+this.RailLeftX,this.OrigY-0.25)
	Set(MyCraneWheelLeft,"HomeUID",this.HomeUID)
	Set(MyCraneWheelLeft,"Tooltip","HomeUID: "..this.HomeUID)
	
	MyCraneWheelRight = Object.Spawn("GantryCrane2Wheel",this.OrigX+this.RailRightX,this.OrigY-0.25)
	Set(MyCraneWheelRight,"HomeUID",this.HomeUID)
	Set(MyCraneWheelRight,"Tooltip","HomeUID: "..this.HomeUID)
	
	Set(MyCrane,"Slot0.i",MyCraneWheelLeft.Id.i)
	Set(MyCrane,"Slot0.u",MyCraneWheelLeft.Id.u)
	Set(MyCraneWheelLeft,"CarrierId.i",MyCrane.Id.i)
	Set(MyCraneWheelLeft,"CarrierId.u",MyCrane.Id.u)
	Set(MyCraneWheelLeft,"Loaded",true)
	if MyCrane.SubType == 0 then	
		Set(MyCrane,"Slot2.i",MyCraneWheelRight.Id.i)
		Set(MyCrane,"Slot2.u",MyCraneWheelRight.Id.u)
		Set(MyCraneWheelRight,"CarrierId.i",MyCrane.Id.i)
		Set(MyCraneWheelRight,"CarrierId.u",MyCrane.Id.u)
		Set(MyCraneWheelRight,"Loaded",true)
	else
		Set(MyCrane,"Slot1.i",MyCraneWheelRight.Id.i)
		Set(MyCrane,"Slot1.u",MyCraneWheelRight.Id.u)
		Set(MyCraneWheelRight,"CarrierId.i",MyCrane.Id.i)
		Set(MyCraneWheelRight,"CarrierId.u",MyCrane.Id.u)
		Set(MyCraneWheelRight,"Loaded",true)
	end
	local TopgatePresent = false
	smallRoadGates = Find("RoadGate2Small",50)
	if next(smallRoadGates) then
		for thatGate, dist in pairs(smallRoadGates) do
			if thatGate.Pos.x == this.OrigX and thatGate.Pos.y == this.OrigY+this.Ymin-1 then
				MyTopGate = thatGate
				Set(MyTopGate,"HomeUID",this.HomeUID)
				TopgatePresent = true
				break
			end
		end
	end
	smallRoadGates = nil
	
	if TopgatePresent == false then
		MyTopGate = Object.Spawn("RoadGate2Small",this.OrigX,this.OrigY+this.Ymin-1)
		Set(MyTopGate,"HomeUID",this.HomeUID)
		if this.GaragePlacement == "Left" then
			Set(MyTopGate,"Or.y",-1)
			Set(MyTopGate,"OpenDir.x",2)
			Set(MyTopGate,"OpenDir.y",0)
		end
	end
	
	local BottomgatePresent = false
	smallRoadGates = Find("RoadGate2Small",50)
	if next(smallRoadGates) then
		for thatGate, dist in pairs(smallRoadGates) do
			if thatGate.Pos.x == this.OrigX and thatGate.Pos.y == this.OrigY+this.Ymax+2 then
				MyBottomGate = thatGate
				Set(MyBottomGate,"HomeUID",this.HomeUID)
				BottomgatePresent = true
				break
			end
		end
	end
	
	if BottomgatePresent == false then
		MyBottomGate = Object.Spawn("RoadGate2Small",this.OrigX,this.OrigY+this.Ymax+2)
		Set(MyBottomGate,"HomeUID",this.HomeUID)
		if this.GaragePlacement == "Left" then
			Set(MyBottomGate,"Or.y",-1)
			Set(MyBottomGate,"OpenDir.x",2)
			Set(MyBottomGate,"OpenDir.y",0)
		end
	end
	
	if this.RoadSize == "Double" then
		local TopgatePresent = false
		local offSet = 3
		if this.GaragePlacement == "Left" then offSet = -3 end
		
		smallRoadGates = Find("RoadGate2Small",50)
		if next(smallRoadGates) then
			for thatGate, dist in pairs(smallRoadGates) do
				if thatGate.Pos.x == this.OrigX+offSet and thatGate.Pos.y == this.OrigY+this.Ymin-1 then
					MyTopGate = thatGate
					Set(MyTopGate,"HomeUID",this.HomeUID)
					TopgatePresent = true
					break
				end
			end
		end
		smallRoadGates = nil
		
		if TopgatePresent == false then
			MyTopGate = Object.Spawn("RoadGate2Small",this.OrigX+offSet,this.OrigY+this.Ymin-1)
			Set(MyTopGate,"HomeUID",this.HomeUID)
			if this.GaragePlacement ~= "Left" then
				Set(MyTopGate,"Or.y",-1)
				Set(MyTopGate,"OpenDir.x",2)
				Set(MyTopGate,"OpenDir.y",0)
			end
		end
		
		local BottomgatePresent = false
		smallRoadGates = Find("RoadGate2Small",50)
		if next(smallRoadGates) then
			for thatGate, dist in pairs(smallRoadGates) do
				if thatGate.Pos.x == this.OrigX+offSet and thatGate.Pos.y == this.OrigY+this.Ymax+2 then
					MyBottomGate = thatGate
					Set(MyBottomGate,"HomeUID",this.HomeUID)
					BottomgatePresent = true
					break
				end
			end
		end
		
		if BottomgatePresent == false then
			MyBottomGate = Object.Spawn("RoadGate2Small",this.OrigX+offSet,this.OrigY+this.Ymax+2)
			Set(MyBottomGate,"HomeUID",this.HomeUID)
			if this.GaragePlacement ~= "Left" then
				Set(MyBottomGate,"Or.y",-1)
				Set(MyBottomGate,"OpenDir.x",2)
				Set(MyBottomGate,"OpenDir.y",0)
			end
		end
	
	end
	
	Set(MyHook,"RoadY",this.OrigY+this.Ymax-2)
	FindMyRoadMarker()
	-- DeleteMyRoadMarker()
	-- RoadMarker = Object.Spawn("RoadMarker2",this.OrigX,0.5000000)
	-- Set(RoadMarker,"MarkerUID",me["id-uniqueId"])
	 -- if OtherGarageAvailable == false then
		 -- Set(RoadMarker,"BuildRoad",true)
	 -- end
	-- Set(RoadMarker,"Sub",1)
	-- Set(RoadMarker,"SubType",8)
	--Set(RoadMarker,"GarageTraffic","yes")
	Set(MyCraneBooth,"MarkerUID",MyRoadMarker.Id.u)
	Set(MyCraneRailLeft,"MarkerUID",MyRoadMarker.Id.u)
	Set(MyCraneRailRight,"MarkerUID",MyRoadMarker.Id.u)
	Set(MyHook,"MarkerUID",MyRoadMarker.Id.u)
	
	Set(this,"GarageMade",true)
end

function MakeCarSpotsFloor(theX,theY)
	local x = math.floor(theX)
	local y = math.floor(theY)
	local cell = World.GetCell(x,y)	cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x+1,y+1)	cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x+1,y+2)	cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x+1,y+3)	cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x+1,y)		cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x,y+1)		cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x,y+2)		cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x,y+3)		cell.Mat = "MetalFloor";	cell.Ind = true
end

function MakeLessonCarFloor(theX,theY)
	local x = math.floor(theX)
	local y = math.floor(theY)
	local cell = World.GetCell(x,y)	cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x+1,y+1)	cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x+1,y)		cell.Mat = "MetalFloor";	cell.Ind = true
	cell = World.GetCell(x,y+1)		cell.Mat = "MetalFloor";	cell.Ind = true
end






function CalculateTimeWarpFactor(timePassed)
	if timeInit > initTimer then
	
		if timePerUpdate == nil then
			Now = math.floor(math.mod(World.TimeIndex,60))
			if not StartCountdown then
				if Now ~= StartingMinute then
				--	this.SubType = 3
					StartingMinute = Now
					if Now < 59 then
						EndingMinute = Now + 1				-- calculate TimeWarp within the next minute
						StartCountdown = true
					else
						return				-- wait another minute if object is placed 1 minute before next whole hour
					end
				end
			else
				timeTot=timeTot+timePassed
				this.Tooltip = {"tooltip_Init_TimeWarpB",StartingMinute,"A",EndingMinute,"B",Now,"C",timeTot,"D" }
				
				if Now >= StartingMinute+1 then
					if timeTot >= 5.4 then			-- the result should be around 8 (1/8) for large map with slow time enabled, compare with 5.4 to compensate for lag
						myTimeWarpFactor = 0.125
					--	this.SubType = 4
						myMapSize = "LARGE"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 4.1 then		-- the result should be around 5.33 (3/16) for medium map with slow time enabled
						myTimeWarpFactor = 0.1875
					--	this.SubType = 5
						myMapSize = "MEDIUM"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 2.1 then		-- the result should be around 4 (1/4) for small map with slow time enabled
						myTimeWarpFactor = 0.25
					--	this.SubType = 6
						myMapSize = "SMALL"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 1.4 then		-- the result should be around 2 (1/2) for large map
						myTimeWarpFactor = 0.5
					--	this.SubType = 7
						myMapSize = "LARGE"
						mySlowTime = "NO"
						timeWarpFound = true
					elseif timeTot >= 1.1 then		-- the result should be around 1.33 (3/4) for medium map
						myTimeWarpFactor = 0.75
					--	this.SubType = 8
						myMapSize = "MEDIUM"
						mySlowTime = "NO"
						timeWarpFound = true
					else							-- the result should be around 1 (1) for small map
						myTimeWarpFactor = 1
					--	this.SubType = 9
						myMapSize = "SMALL"
						mySlowTime = "NO"
						timeWarpFound = true
					end
					
					-- Instead of using the hard coded TimeWarp values (found in de saved game and mentioned above),
					-- you could also calculate your own by dividing 1 minute by the time it took to get to that minute.
					-- The result will be approximately the hard coded TimeWarp value, but can be different for each object you place,
					-- depending on how busy the game is, this is should not be used by default:
					
					--timeWarpFound = false					-- enable to see this calculation result in action
					--if timeWarpFound == false then myTimeWarpFactor = 1 / timeTot end
					
					this.Tooltip = {"tooltip_Init_TimeWarpC",StartingMinute,"A",EndingMinute,"B",Now,"C",timeTot,"D",myMapSize,"E",myTimeWarpFactor,"F",mySlowTime,"G" }	-- show results
					
					-- set the timePerUpdate here so we get out of this function
					timePerUpdate = 1 / myTimeWarpFactor	-- will show the results for 3 game minutes
				end
			end
		else		-- calculation completed, so save the results
			timeTot = timeTot+timePassed
			if timeTot > timePerUpdate then
			--	this.SubType = 0						-- change sprite back to normal
				Set(this,"TimeWarp",myTimeWarpFactor)	-- this tells function Update() to proceed
				this.Tooltip = "tooltip_ReadyForAction"
				timePerUpdate = nil				-- reset to nil so function Update() can proceed with normal activity
			end
		end
	else
		timeInit = timeInit+timePassed
		StartingMinute = math.floor(math.mod(World.TimeIndex,60))
	end
end


function SetTabNames()
	if this.StartBuilding == false then
		Interface.SetReportTabs( "reportTab_tab1")
	else
		Interface.SetReportTabs( "reportTab_tab1","reportTab_tab2","reportTab_tab3","reportTab_tab4","reportTab_tab5")
	end
end


function PopulateReport( tabIndex )
	tabIndex = tonumber( tabIndex)
    local w, h = Interface.GetReportWindowSize()
	if w == nil	or h == nil then return end
	
    w = w - 20  -- Top level canvas scrollbar
    
    local rowHeight = math.min(w, h) / 25.0
    local rowGap = rowHeight * 2
    local y = 0
    
    -- Title
    Interface.AddReportComponent( 
        {
            Type = "Title", 
            Caption = "reportTitle_GarageInstaller"
        }
    )
			
    if tabIndex == 1 then
		
		if this.TimeWarp == nil then
			
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 1.25, 
					Caption = "reportTooltip_CaptionTimeWarp",
					Centred = true
				}
			)
			y = y + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "Image", 
					Name = "ImgOverview", 
					X = (w / 2) - (w / 4),
					Y = y, 
					W = w / 2, 
					H = w / 2, 
					File = "Report/report_overview.png", 
					Colour = "White"
				}
			)
			y = y + ( w / 2 ) - rowHeight + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "MultiLineText",
					Name = "TimeWarp",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 15, 
					LineSize = rowHeight, 
					Caption = "reportTooltip_TimeWarp"
				}
			)
		else
			if this.StartBuilding == false then
				Interface.AddReportComponent( 
					{
						Type = "Caption", 
						X = 0, 
						Y = y, 
						W = w, 
						H = rowHeight * 1.25, 
						Caption = "reportTooltip_CaptionOverview",
						Centred = true
					}
				)
				y = y + rowGap
					
				Interface.AddReportComponent( 
					{
						Type = "Image", 
						Name = "ImgOverview", 
						X = (w / 2) - (w / 4),
						Y = y, 
						W = w / 2, 
						H = w / 2, 
						File = "Report/report_overview.png", 
						Colour = "White"
					}
				)
				y = y + ( w / 2 ) - rowHeight + rowGap
				
				Interface.AddReportComponent( 
					{
						Type = "MultiLineText", 
						Name = "Overview",
						X = 0, 
						Y = y, 
						W = w, 
						H = rowHeight * 5, 
						LineSize = rowHeight, 
						Caption = "reportTooltip_Overview"
					}
				)
				y = y + (rowHeight * 4) + rowGap
				
				Interface.AddReportComponent( 
					{
						Type = "Button", 
						Name = "StartBuilding",
						X = w / 4, 
						Y = y, 
						W = w / 2, 
						H = rowHeight * 2, 
						LineSize = rowHeight, 
						Caption = "reportButton_StartBuilding"
					}
				)
				y = y + rowHeight + rowGap
				
				Interface.AddReportComponent( 
					{
						Type = "Button", 
						Name = "CancelBuilding",
						X = w / 4, 
						Y = y, 
						W = w / 2, 
						H = rowHeight * 1.5, 
						LineSize = rowHeight, 
						Caption = "reportButton_CancelBuilding"
					}
				)
			else
				Interface.AddReportComponent( 
					{
						Type = "Caption", 
						X = 0, 
						Y = y, 
						W = w, 
						H = rowHeight * 1.25, 
						Caption = "reportTooltip_CaptionFoundationDone",
						Centred = true
					}
				)
				y = y + rowGap
				
				Interface.AddReportComponent( 
					{
						Type = "Image", 
						Name = "ImgOverview", 
						X = (w / 2) - (w / 4),
						Y = y, 
						W = w / 2, 
						H = w / 2, 
						File = "Report/report_overview.png", 
						Colour = "White"
					}
				)
				y = y + ( w / 2 ) - rowHeight + rowGap
				
				Interface.AddReportComponent( 
					{
						Type = "MultiLineText", 
						Name = "FloorDone",
						X = 0, 
						Y = y, 
						W = w, 
						H = rowHeight * 3, 
						LineSize = rowHeight, 
						Caption = "reportTooltip_FoundationDone"
					}
				)
				y = y + (rowHeight * 2) + rowGap
				
				Interface.AddReportComponent( 
					{
						Type = "MultiLineText", 
						Name = "FloorDone1",
						X = (w / 2) - (w / 4), 
						Y = y, 
						W = w / 3, 
						H = rowHeight * 5, 
						LineSize = rowHeight, 
						Caption = "reportTooltip_FoundationDone1"
					}
				)
				
				Interface.AddReportComponent( 
					{
						Type = "MultiLineText", 
						Name = "FloorDone2",
						X = (w / 3) + (w / 3), 
						Y = y, 
						W = w / 3, 
						H = rowHeight * 5, 
						LineSize = rowHeight, 
						Caption = "reportTooltip_FoundationDone2",
						Replacements = { A = InventoryRepairSpots, B = InventoryPartsRack, C = InventoryControl, D = InventoryServiceDesk, E = InventoryCabinet }
					}
				)
				
				y = y + (rowHeight * 4) + rowGap
				
				Interface.AddReportComponent( 
					{
						Type = "Button", 
						Name = "CheckObjects",
						X = w / 4, 
						Y = y, 
						W = w / 2, 
						H = rowHeight * 1.25, 
						LineSize = rowHeight, 
						Caption = "reportButton_CheckObjects"
					}
				)
				y = y + rowHeight + rowGap
				Interface.AddReportComponent( 
					{
						Type = "MultiLineText", 
						Name = "Objects",
						X = 0, 
						Y = y, 
						W = w, 
						H = rowHeight * 3, 
						LineSize = rowHeight, 
						Caption = "reportTooltip_FoundationDoneTips"
					}
				)
				y = y + rowHeight + rowGap
				Interface.AddReportComponent( 
					{
						Type = "Caption", 
						Name = "MyType",
						X = 0, 
						Y = y, 
						W = w, 
						H = rowHeight * 1.25,
						Caption = "reportTooltip_GarageType"
					}
				)
				
				Interface.AddReportComponent( 
					{
						Type = "Caption", 
						Name = "GarageTypeNormal",
						X = (w / 16) + (w / 4),
						Y = y, 
						W = w / 5, 
						H = rowHeight * 1.25, 
						LineSize = rowHeight,
						Caption = ""
					}
				)
				if this.IsMilitary == "No" then
					Interface.SetComponentProperties( "GarageTypeNormal", { Caption = "reportButton_OptionSelected" } )
				end
				Interface.AddReportComponent( 
					{
						Type = "Button", 
						Name = "GarageTypeNormalButton",
						X = (w / 10) + (w / 4),
						Y = y, 
						W = w / 6, 
						H = rowHeight * 1.25, 
						LineSize = rowHeight,
						Caption = "reportButton_GarageTypeNormal"
					}
				)
				Interface.AddReportComponent( 
					{
						Type = "Caption", 
						Name = "GarageTypeMilitary",
						X = (w / 16) + (w / 4)+(w / 4),
						Y = y, 
						W = w / 5, 
						H = rowHeight * 1.25, 
						LineSize = rowHeight,
						Caption = ""
					}
				)
				if this.IsMilitary == "Yes" then
					Interface.SetComponentProperties( "GarageTypeMilitary", { Caption = "reportButton_OptionSelected" } )
				end
				Interface.AddReportComponent( 
					{
						Type = "Button", 
						Name = "GarageTypeMilitaryButton",
						X = (w / 10) + (w / 4)+(w / 4),
						Y = y, 
						W = w / 6, 
						H = rowHeight * 1.25, 
						LineSize = rowHeight, 
						Caption = "reportButton_GarageTypeMilitary"
					}
				)
			end
		end
    end
	
    if tabIndex == 2 then
		if this.StartBuilding == false then
			Interface.AddReportComponent( 
				{
					Type = "Image", 
					Name = "ImgGarageSizes", 
					X = 0,
					Y = y, 
					W = w, 
					H = w / 2, 
					File = "Report/report_garagesizes.png", 
					Colour = "White"
				}
			)
			y = y + ( w / 2 ) - rowHeight + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "MultiLineText", 
					Name = "Placement",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 3, 
					LineSize = rowHeight, 
					Caption = "reportTooltip_Placement"
				}
			)
			y = y + (rowHeight) + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "MyPlacement",
					X = 0, 
					Y = y, 
					W = w / 4, 
					H = rowHeight * 1.25, 
					Caption = "reportTooltip_GaragePlacement"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GaragePlacementLeft",
					X = (w / 16) + (w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = ""
				}
			)
			if this.LeftPlacementNotPossible == true then
				Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionUnavailable" } )
			elseif this.GaragePlacement == "Left" then
				Interface.SetComponentProperties( "GaragePlacementLeft", { Caption = "reportButton_OptionSelected" } )
			end
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GaragePlacementLeftButton",
					X = (w / 10) + (w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = "reportButton_GaragePlacementLeft"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GaragePlacementCentre",
					X = (w / 16) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = ""
				}
			)
			if this.CentrePlacementNotPossible == true then
				Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionUnavailable" } )
			elseif this.GaragePlacement == "Centre" then
				Interface.SetComponentProperties( "GaragePlacementCentre", { Caption = "reportButton_OptionSelected" } )
			end
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GaragePlacementCentreButton",
					X = (w / 10) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight, 
					Caption = "reportButton_GaragePlacementCentre"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GaragePlacementRight",
					X = (w / 16) + (w / 4)+(w / 4)+(w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = ""
				}
			)
			if this.RightPlacementNotPossible == true then
				Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionUnavailable" } )
			elseif this.GaragePlacement == "Right" then
				Interface.SetComponentProperties( "GaragePlacementRight", { Caption = "reportButton_OptionSelected" } )
			end
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GaragePlacementRightButton",
					X = (w / 10) + (w / 4)+(w / 4)+(w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight, 
					Caption = "reportButton_GaragePlacementRight"
				}
			)
			y = y + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "MySize",
					X = 0, 
					Y = y, 
					W = w / 4, 
					H = rowHeight * 1.25, 
					Caption = "reportTooltip_GarageSize"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GarageSizeNormal",
					X = (w / 16) + (w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = "reportButton_OptionSelected"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GarageSizeNormalButton",
					X = (w / 10) + (w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = "reportButton_GarageSizeNormal"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GarageSizeTall",
					X = (w / 16) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = ""
				}
			)
			if this.TallNotPossible == true then
				Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionUnavailable" } )
			elseif this.GarageSize == "Tall" then
				Interface.SetComponentProperties( "GarageSizeTall", { Caption = "reportButton_OptionSelected" } )
			end
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GarageSizeTallButton",
					X = (w / 10) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight, 
					Caption = "reportButton_GarageSizeTall"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GarageSizeWide",
					X = (w / 16) + (w / 4)+(w / 4)+(w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = ""
				}
			)
			if (this.LeftWideNotPossible == true and this.GaragePlacement == "Left") or (this.RightWideNotPossible == true and this.GaragePlacement =="Right") then
				Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionUnavailable" } )
			elseif this.GarageSize == "Wide" then
				Interface.SetComponentProperties( "GarageSizeWide", { Caption = "reportButton_OptionSelected" } )
			end
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GarageSizeWideButton",
					X = (w / 10) + (w / 4)+(w / 4)+(w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight, 
					Caption = "reportButton_GarageSizeWide"
				}
			)
			y = y + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "MyLane",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 1.25,
					Caption = "reportTooltip_GarageRoadSize"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GarageLaneSingle",
					X = (w / 16) + (w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = "reportButton_OptionSelected"
				}
			)
			if this.RoadSize == "Single" then
				Interface.SetComponentProperties( "GarageLaneSingle", { Caption = "reportButton_OptionSelected" } )
			elseif this.SetRoadSizeNotPossible == true then
				Interface.SetComponentProperties( "GarageLaneSingle", { Caption = "reportButton_OptionUnavailable" } )
			end
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GarageLaneSingleButton",
					X = (w / 10) + (w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = "reportButton_GarageRoadSizeSingle"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GarageLaneDouble",
					X = (w / 16) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = ""
				}
			)
			if this.RoadSize == "Double" then
				Interface.SetComponentProperties( "GarageLaneDouble", { Caption = "reportButton_OptionSelected" } )
			elseif this.SetRoadSizeNotPossible == true then
				Interface.SetComponentProperties( "GarageLaneDouble", { Caption = "reportButton_OptionUnavailable" } )
			end
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GarageLaneDoubleButton",
					X = (w / 10) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight, 
					Caption = "reportButton_GarageRoadSizeDouble"
				}
			)
			y = y + rowGap
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "MyType",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 1.25,
					Caption = "reportTooltip_GarageType"
				}
			)
			
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GarageTypeNormal",
					X = (w / 16) + (w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = "reportButton_OptionSelected"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GarageTypeNormalButton",
					X = (w / 10) + (w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = "reportButton_GarageTypeNormal"
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "GarageTypeMilitary",
					X = (w / 16) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 5, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight,
					Caption = ""
				}
			)
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "GarageTypeMilitaryButton",
					X = (w / 10) + (w / 4)+(w / 4),
					Y = y, 
					W = w / 6, 
					H = rowHeight * 1.25, 
					LineSize = rowHeight, 
					Caption = "reportButton_GarageTypeMilitary"
				}
			)
			
			y = y + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "MultiLineText", 
					Name = "Preview",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 3, 
					LineSize = rowHeight, 
					Caption = "reportTooltip_ShowHidePreview"
				}
			)
			y = y + rowHeight + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "ShowHidePreview",
					X = w / 4,
					Y = y, 
					W = w / 2, 
					H = rowHeight, 
					LineSize = rowHeight, 
					Caption = "reportButton_ShowHidePreview"
				}
			)
			y = y + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "Caption", 
					Name = "MakeFloor",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight,
					Centred = true,
					Caption = "reportTooltip_BuildFloor"
				}
			)
			y = y + rowGap
			
			Interface.AddReportComponent( 
				{
					Type = "Button", 
					Name = "BuildFloor",
					X = w / 4,
					Y = y, 
					W = w / 2, 
					H = rowHeight, 
					LineSize = rowHeight, 
					Caption = "reportButton_BuildFloor"
				}
			)
		else
			Interface.AddReportComponent(
				{
					Type = "Caption", 
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 1.25, 
					Caption = "reportTooltip_CaptionTips",
					Centred = true
				}
			)
			y = y + rowGap
			
			Interface.AddReportComponent(
				{
					Type = "MultiLineText", 
					Name = "AdjacentGarage",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 4, 
					LineSize = rowHeight, 
					Caption = "reportTooltip_TipsAdjacent"
				}
			)
			y = y + (rowHeight * 3) + rowGap
			Interface.AddReportComponent( 
				{
					Type = "Image", 
					Name = "ImgAdjacentGarage",
					X = (w / 2) - (w / 4),
					Y = y, 
					W = w / 2, 
					H = w / 4, 
					File = "Report/report_adjacentgarage.png", 
					Colour = "White"
				}
			)
			y = y + ( w / 4 ) - rowHeight + rowGap
			
			
			Interface.AddReportComponent(
				{
					Type = "MultiLineText", 
					Name = "PathGarage",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 4, 
					LineSize = rowHeight, 
					Caption = "reportTooltip_TipsPath"
				}
			)
			y = y + (rowHeight * 3) + rowGap
			Interface.AddReportComponent( 
				{
					Type = "Image", 
					Name = "ImgPathGarage",
					X = (w / 2) - (w / 4),
					Y = y, 
					W = w / 2, 
					H = w / 4, 
					File = "Report/report_pathgarage.png", 
					Colour = "White"
				}
			)
			y = y + ( w / 4 ) - rowHeight + rowGap
			
			Interface.AddReportComponent(
				{
					Type = "MultiLineText", 
					Name = "MaxGarage",
					X = 0, 
					Y = y, 
					W = w, 
					H = rowHeight * 5, 
					LineSize = rowHeight, 
					Caption = "reportTooltip_TipsMaxGarage"
				}
			)
		end
    end
    if tabIndex == 3 then
		Interface.AddReportComponent( 
			{
				Type = "Caption", 
				X = 0, 
				Y = y, 
				W = w, 
				H = rowHeight * 1.25, 
				Caption = "reportTooltip_CaptionObjects",
				Centred = true
			}
		)
		y = y + rowGap
		
		Interface.AddReportComponent( 
			{
				Type = "Image", 
				Name = "ImgObjects", 
				X = 0,
				Y = y, 
				W = w / 2, 
				H = w / 2, 
				File = "Report/report_wall.png", 
				Colour = "White"
			}
		)
		Interface.AddReportComponent( 
			{
				Type = "Image", 
				Name = "ImgObjects2", 
				X = (w / 2),
				Y = y, 
				W = w / 2, 
				H = w / 2, 
				File = "Report/report_objects.png", 
				Colour = "White"
			}
		)
		
		y = y + ( w / 2 ) - rowHeight + rowGap
		
		Interface.AddReportComponent( 
			{
				Type = "MultiLineText", 
				Name = "Objects",
				X = 0, 
				Y = y, 
				W = w, 
				H = rowHeight * 12, 
				LineSize = rowHeight, 
				Caption = "reportTooltip_Objects"
			}
		)
		y = y + (rowHeight * 11) + rowGap
		
		Interface.AddReportComponent( 
			{
				Type = "Button", 
				Name = "CheckObjects",
				X = w / 4, 
				Y = y, 
				W = w / 2, 
				H = rowHeight * 1.25, 
				LineSize = rowHeight, 
				Caption = "reportButton_CheckObjects"
			}
		)
	end
    if tabIndex == 4 then
		Interface.AddReportComponent( 
			{
				Type = "Caption", 
				X = 0, 
				Y = y, 
				W = w, 
				H = rowHeight * 1.25, 
				Caption = "reportTooltip_CaptionDeployment",
				Centred = true
			}
		)
		y = y + rowGap
		
		Interface.AddReportComponent( 
			{
				Type = "Image", 
				Name = "ImgObjects1", 
				X = 0,
				Y = y, 
				W = w / 2, 
				H = w / 2, 
				File = "Report/report_deployment1.png", 
				Colour = "White"
			}
		)
		
		Interface.AddReportComponent( 
			{
				Type = "Image", 
				Name = "ImgObjects2", 
				X = (w / 2),
				Y = y, 
				W = w / 2, 
				H = w / 2, 
				File = "Report/report_deployment2.png", 
				Colour = "White"
			}
		)
		y = y + ( w / 2 ) + rowGap
		
		Interface.AddReportComponent( 
			{
				Type = "MultiLineText", 
				Name = "Deployment1",
				X = 0, 
				Y = y, 
				W = w, 
				H = rowHeight * 14, 
				LineSize = rowHeight, 
				Caption = "reportTooltip_Deployment"
			}
		)
	end
    if tabIndex == 5 then
		Interface.AddReportComponent( 
			{
				Type = "Caption", 
				X = 0, 
				Y = y, 
				W = w, 
				H = rowHeight * 1.25, 
				Caption = "reportTooltip_CaptionLogistics",
				Centred = true
			}
		)
		y = y + rowGap
		
		Interface.AddReportComponent( 
			{
				Type = "Image", 
				Name = "ImgObjects", 
				X = (w / 2) - (w / 4),
				Y = y, 
				W = w / 2, 
				H = w / 2, 
				File = "Report/report_work.png", 
				Colour = "White"
			}
		)
		y = y + ( w / 2 ) + rowGap
		
		Interface.AddReportComponent( 
			{
				Type = "MultiLineText", 
				Name = "Logistics",
				X = 0, 
				Y = y, 
				W = w, 
				H = rowHeight * 14, 
				LineSize = rowHeight, 
				Caption = "reportTooltip_Logistics"
			}
		)
	end
end

function ButtonPressed_StartBuilding()
	if not ButtonStartBuildingPressed then
		Interface.SetReportTabs( "reportTab_tab1","reportTab_tab2")
		local FoundationCheckers = Find(this,"FoundationChecker",50)
		if next(FoundationCheckers) then
			for thatFoundationChecker, dist in pairs(FoundationCheckers) do
				if thatFoundationChecker.HomeUID == this.HomeUID then
					thatFoundationChecker.Delete()
				end
			end
		end
		ButtonStartBuildingPressed = true
		toggleShowPreviewClicked()
	end
end

function ButtonPressed_CancelBuilding()
	if previewShown == true then
		toggleShowPreviewClicked()
	end
	local FoundationCheckers = Find(this,"FoundationChecker",50)
	if next(FoundationCheckers) then
		for thatFoundationChecker, dist in pairs(FoundationCheckers) do
			if thatFoundationChecker.HomeUID == this.HomeUID then
				thatFoundationChecker.Delete()
			end
		end
	end
	this.Delete()
end

function ButtonPressed_GaragePlacementLeftButton()
	if this.LeftPlacementNotPossible == false then
		toggleGaragePlacementLeftClicked()
	end
end

function ButtonPressed_GaragePlacementCentreButton()
	if this.CentrePlacementNotPossible == false then
		toggleGaragePlacementCentreClicked()
	end
end

function ButtonPressed_GaragePlacementRightButton()
	if this.RightPlacementNotPossible == false then
		toggleGaragePlacementRightClicked()
	end
end

function ButtonPressed_GarageSizeNormalButton()
	toggleGarageSizeNormalClicked()
end

function ButtonPressed_GarageSizeTallButton()
	if this.TallNotPossible == false then
		toggleGarageSizeTallClicked()
	end
end

function ButtonPressed_GarageSizeWideButton()
	if (this.LeftWideNotPossible == true and this.GaragePlacement == "Left") or (this.RightWideNotPossible == true and this.GaragePlacement =="Right") then
		return
	else
		toggleGarageSizeWideClicked()
	end
end

function ButtonPressed_GarageLaneSingleButton()
	if this.SetRoadSizeNotPossible == false then
		toggleGarageLaneSingleClicked()
	end
end

function ButtonPressed_GarageLaneDoubleButton()
	if this.SetRoadSizeNotPossible == false then
		toggleGarageLaneDoubleClicked()
	end
end

function ButtonPressed_GarageTypeNormalButton()
	toggleGarageTypeNormalClicked()
end

function ButtonPressed_GarageTypeMilitaryButton()
	toggleGarageTypeMilitaryClicked()
end

function ButtonPressed_ShowHidePreview()
	toggleShowPreviewClicked()
end

function ButtonPressed_BuildFloor()
	if this.TimeWarp ~= nil then
		toggleBuildFloorClicked()
		Interface.SetReportTabs( "reportTab_tab1","reportTab_tab2","reportTab_tab3","reportTab_tab4","reportTab_tab5")
		timeTot = timePerUpdate
	end
end

function ButtonPressed_CheckObjects()
	toggleScanInventoryClicked()
    Interface.SetReportTabs( "reportTab_tab1","reportTab_tab2","reportTab_tab3","reportTab_tab4","reportTab_tab5")
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
