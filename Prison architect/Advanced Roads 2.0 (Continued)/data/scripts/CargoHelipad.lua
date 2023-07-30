
local timeTot = 0
local timeLoad = 0
local timeFlash = 0
local timePerLoadUpdate = math.random() * 15

local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

local TreeTypes = { "Tree", "SpookyTree", "SnowyConiferTree", "CactusTree", "SakuraTree", "PalmTree", "Bush" }

local HelipadTypes = { ["Deliveries"] = 1, ["Exports"] = 2, ["Garbage"] = 3, ["Emergency"] = 4, ["Intake"] = 5 }

local StopSignTypes = { ["Deliveries"] = 0, ["Exports"] = 1, ["Garbage"] = 2, ["Intake"] = 3, ["Emergency"] = 4 }

local HookObjects = { "ExportsChinookHook", "EmergencyChinookHook" }

local ObjectsToLoad = { "Garbage", "Stack", "Box", "RecyclingBag",													-- Default stuff

						"GraveCoffin",  "CrematoriumUrn",															-- Cemetery mods
						
						"WigBox", "RedWigBox",																		-- Barber mods

						"Jeans", "RawCotton",																		-- Manufactury mods
						
						"GardenCucumber", "GardenTomato", "GardenLily", "GardenRose", "Apple", "Cherry",			-- Recycling mods
						"SortedGarbageExport", "GreenGarbage", "FertilizerGarden", "R4_SortedGarbageExport",
						
						"Orange", "WaterBottleEmpty", "VendingEarnings",											-- Vending Machines
						
						"VendingApple", "VendingCherry",															-- Vending Machines 2.0 / Prison Lottery
						"Win5000", "Lost5000", "LotteryJackpot", "PrisonLotterySuperJackpot",
						"PrisonLotteryMegaJackpot", "SylvesterLotterySuperJackpot", "SylvesterLotteryMegaJackpot",
						
						"DocumentExport",																			-- Computers and More
						
						"ImportantDocumentsExport", "UselessDocumentsExport",										-- Servers and More
						
						"AssembledSmartPhone", "SeizedSmartPhone",													-- Explosive "Smart" Phones
						
						"CashBack",																					-- Prison FireBrigade
						
						"MetroStationEarnings",																		-- Metro Stations 2.0
						 
						"DepletedTeslaBattery",																		-- Tesla-Matic 2.0
						
						"Limo2Bill1", "Limo2Bill2", "Limo2Bill3", "Limo2Bill4", "Limo2Bill5",
						"Limo2Bill6", "Limo2Bill7", "Limo2Bill8", "Limo2Bill9","Limo2Bill10",						-- Limo Garage 2.0
						
						"LimoBill1", "LimoBill2", "LimoBill3", "LimoBill4", "LimoBill5",
						"LimoBill6", "LimoBill7", "LimoBill8", "LimoBill9", "LimoBill10",							-- Limo Garage
						
						"GrantCheckerTerminal", "GrantCheckerTerminalI", "GrantCheckerDeliveries", "GrantCheckerBuilding",
						"GrantCheckerFloors", "GrantCheckerLaundry", "GrantCheckerFood",
						"GrantCheckerForest","GrantCheckerVending", "GrantCheckerMedSec", "GrantCheckerMinSec",
						"GrantCheckerWorkshop", "GrantCheckerOther", "GrantCheckerGarbage",
						"GrantCheckerExports", "GrantCheckerIntake", "GrantCheckerEmergency"						-- Grants checkers
					}

function Create()
	Set(this,"HomeUID","Helipad_"..string.sub(me["id-uniqueId"],-2))
	Set(this,"TrafficTerminalID","None")
	this.Tooltip = "tooltip_CargoHelipad_Placement"
end

function BuildHelipadClicked()
	CreateHelipadFloor()
	InitSettings()
	Interface.RemoveComponent(this,"BuildHelipad")
	Interface.RemoveComponent(this,"SeparatorOr")
	Interface.RemoveComponent(this,"DeleteHelipad")
	Interface.AddComponent(this,"RemoveHelipad", "Button", "tooltip_CargoHelipad_Button_Delete")
	Interface.AddComponent(this,"SeparatorPad0", "Caption", "tooltip_CargoHelipad_Separatorline")
	Interface.AddComponent(this,"RemoveStack", "Button", "tooltip_CargoHelipad_Button_DeleteStack")
	Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_CargoHelipad_Button_FloorType","tooltip_CargoHelipad_FloorType_"..this.HelipadFloor,"X")
	Interface.AddComponent(this,"SeparatorPad1", "Caption", "tooltip_CargoHelipad_Separatorline")
	Interface.AddComponent(this,"toggleCargoType", "Button", "tooltip_CargoStation_Button_CargoType","tooltip_CargoStation_Button_"..this.CargoType,"X")
	Interface.AddComponent(this,"toggleTraffic", "Button", "tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..this.TrafficEnabled,"X")
	if this.CargoType == "Deliveries" then
		Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoHelipad_Separatorline")
		Interface.AddComponent(this,"toggleFoodDelivery", "Button", "tooltip_CargoStation_Button_FoodDelivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleVendingDelivery", "Button", "tooltip_CargoStation_Button_VendingDelivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleBuildingDelivery", "Button", "tooltip_CargoStation_Button_BuildingDelivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleFloorsDelivery", "Button", "tooltip_CargoStation_Button_FloorsDelivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleLaundryDelivery", "Button", "tooltip_CargoStation_Button_LaundryDelivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleForestDelivery", "Button", "tooltip_CargoStation_Button_ForestDelivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleWorkshop1Delivery", "Button", "tooltip_CargoStation_Button_Workshop1Delivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleWorkshop2Delivery", "Button", "tooltip_CargoStation_Button_Workshop2Delivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleWorkshop3Delivery", "Button", "tooltip_CargoStation_Button_Workshop3Delivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleWorkshop4Delivery", "Button", "tooltip_CargoStation_Button_Workshop4Delivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleWorkshop5Delivery", "Button", "tooltip_CargoStation_Button_Workshop5Delivery","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleOtherDelivery", "Button", "tooltip_CargoStation_Button_Otherdelivery","tooltip_CargoStation_Button_Delivery_no","X")
	elseif this.CargoType == "Intake" then
		Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoHelipad_Separatorline")
		Interface.AddComponent(this,"toggleSecLevel1", "Button", "tooltip_CargoStation_Button_SecLevel1","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleSecLevel2", "Button", "tooltip_CargoStation_Button_SecLevel2","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleSecLevel3", "Button", "tooltip_CargoStation_Button_SecLevel3","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleSecLevel4", "Button", "tooltip_CargoStation_Button_SecLevel4","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleSecLevel5", "Button", "tooltip_CargoStation_Button_SecLevel5","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleSecLevel6", "Button", "tooltip_CargoStation_Button_SecLevel6","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleSecLevel7", "Button", "tooltip_CargoStation_Button_SecLevel7","tooltip_CargoStation_Button_Delivery_no","X")
		Interface.AddComponent(this,"toggleIsIntake", "Button", "tooltip_CargoStation_Button_IsIntake","tooltip_CargoStation_Button_"..this.IsIntake,"X")
	end

	Set(this,"HelipadMade",true)
	FindMyTrafficTerminal()
	UpdateTooltip()
end

function CreateHelipadFloor()
	-- a drawing of the helipad foundation, each number represents a certain floor tile
local CompactFloor = {
			{ 1, 1, 1, 1,24, 1, 1, 1, 1},
			{ 1, 1, 6,10,10,10, 3, 1, 1},
			{ 1, 6,14, 2, 2, 2,11, 3, 1},
			{ 1, 9, 2,15,16,17, 2, 7, 1},
			{24, 9, 2,18,19,20, 2, 7,24},
			{ 1, 9, 2,21,22,23, 2, 7, 1},
			{ 1, 5,13, 2, 2, 2,12, 4, 1},
			{ 1, 1, 5, 8, 8, 8, 4, 1, 1},
			{ 1, 1, 1, 1,24, 1, 1, 1, 1},
			}
			
local LargeFloor = {
			{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
			{ 1, 6,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10, 3, 1},
			{ 1, 9,25, 2,27, 2,27, 2,27, 2, 2, 2, 2, 2, 2, 2,27, 2, 2,26, 7, 1},
			{ 1, 9,25, 2, 2, 2,27, 2,27, 2, 2, 2, 2, 2, 2, 2,27, 2, 2,26, 7, 1},
			{ 1, 9,25, 2, 2, 2, 2, 2,27, 2, 2,15,16,17, 2, 2,27, 2, 2,26, 7, 1},
			{ 1, 9,25, 2, 2, 2, 2, 2, 2, 2, 2,18,19,20, 2, 2, 2, 2, 2,26, 7, 1},
			{ 1, 9,25, 2, 2, 2, 2, 2,27, 2, 2,21,22,23, 2, 2,27, 2, 2,26, 7, 1},
			{ 1, 9,25, 2, 2, 2,27, 2,27, 2, 2, 2, 2, 2, 2, 2,27, 2, 2,26, 7, 1},
			{ 1, 9,25, 2,27, 2,27, 2,27, 2, 2, 2, 2, 2, 2, 2,27, 2, 2,26, 7, 1},
			{ 1, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 1},
			{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24,24,24, 1, 1, 1, 1, 1, 1, 1, 1},
			}
			
local Tiles = {
			[1] = "TiledFence",
			[2] = "Road",
			[3] = "outercornerTR",
			[4] = "outercornerBR",
			[5] = "outercornerBL",
			[6] = "outercornerTL",
			[7] = "RoadMarkingsRight",
			[8] = "outerlineB",
			[9] = "RoadMarkingsLeft",
			[10] = "outerlineT",
			[11] = "innerwhitecornerBL",
			[12] = "innerwhitecornerTL",
			[13] = "innerwhitecornerTR",
			[14] = "innerwhitecornerBR",
			[15] = "Heli_TL",
			[16] = "Heli_TC",
			[17] = "Heli_TR",
			[18] = "Heli_CL",
			[19] = "Heli_CC",
			[20] = "Heli_CR",
			[21] = "Heli_BL",
			[22] = "Heli_BC",
			[23] = "Heli_BR",
			[24] = "ConcreteTiles",
			[25] = "RoadCrossingLeft",
			[26] = "RoadCrossingRight",
			[27] = "RoadMarkings"
			}


	if this.HelipadFloor == "Compact" then
		local x = this.Pos.x-5
		local y = this.Pos.y-9
			
		for X = 1,9 do
			for Y = 1,9 do
				local cell = World.GetCell(x+X,y+Y)
				cell.Mat = Tiles[CompactFloor[Y][X]]
				cell.Ind = true
			end
		end
		
		local newMD1 = Object.Spawn("MetalDetector", this.Pos.x, this.Pos.y-8)
		newMD1.HomeUID = this.HomeUID
		local newMD2 = Object.Spawn("MetalDetector", this.Pos.x-4, this.Pos.y-4)
		newMD2.Or.x,newMD2.Or.y = -1,0
		newMD2.HomeUID = this.HomeUID
		local newMD3 = Object.Spawn("MetalDetector", this.Pos.x+4, this.Pos.y-4)
		newMD3.Or.x,newMD3.Or.y = -1,0
		newMD3.HomeUID = this.HomeUID
		local newMD4 = Object.Spawn("MetalDetector", this.Pos.x, this.Pos.y)
		newMD4.HomeUID = this.HomeUID
		
		local newLight1 = Object.Spawn("Light", this.Pos.x+2, this.Pos.y-2)
		newLight1.HomeUID = this.HomeUID
		local newLight2 = Object.Spawn("Light", this.Pos.x+2, this.Pos.y-6)
		newLight2.HomeUID = this.HomeUID
		local newLight3 = Object.Spawn("Light", this.Pos.x-2, this.Pos.y-2)
		newLight3.HomeUID = this.HomeUID
		local newLight4 = Object.Spawn("Light", this.Pos.x-2, this.Pos.y-6)
		newLight4.HomeUID = this.HomeUID
		
		RemoveTrees(newLight1,4)
		RemoveTrees(newLight2,4)
		RemoveTrees(newLight3,4)
		RemoveTrees(newLight4,4)
		
		MyCargoStopSign = Object.Spawn("CargoStopSignHelipad", this.Pos.x+3.5, this.Pos.y-0.55)
		MyCargoStopSign.HomeUID = this.HomeUID		
	else
		local x = this.Pos.x-13
		local y = this.Pos.y-10
		for X = 1,22 do
			for Y = 1,11 do
				local cell = World.GetCell(x+X,y+Y)
				cell.Mat = Tiles[LargeFloor[Y][X]]
				cell.Ind = true
			end
		end
		
		local newMD1 = Object.Spawn("MetalDetector", this.Pos.x-1, this.Pos.y+1)
		newMD1.HomeUID = this.HomeUID
		local newMD2 = Object.Spawn("MetalDetector", this.Pos.x, this.Pos.y+1)
		newMD2.HomeUID = this.HomeUID
		local newMD3 = Object.Spawn("MetalDetector", this.Pos.x+1, this.Pos.y+1)
		newMD3.HomeUID = this.HomeUID
		
		local newLight1 = Object.Spawn("Light", this.Pos.x-11, this.Pos.y-7)
		newLight1.HomeUID = this.HomeUID
		local newLight2 = Object.Spawn("Light", this.Pos.x-11, this.Pos.y-4)
		newLight2.HomeUID = this.HomeUID
		local newLight3 = Object.Spawn("Light", this.Pos.x-11, this.Pos.y-1)
		newLight3.HomeUID = this.HomeUID
		
		local newLight4 = Object.Spawn("Light", this.Pos.x+8, this.Pos.y-7)
		newLight4.HomeUID = this.HomeUID
		local newLight5 = Object.Spawn("Light", this.Pos.x+8, this.Pos.y-4)
		newLight5.HomeUID = this.HomeUID
		local newLight6 = Object.Spawn("Light", this.Pos.x+8, this.Pos.y-1)
		newLight6.HomeUID = this.HomeUID
		
		
		local newLight7 = Object.Spawn("Light", this.Pos.x, this.Pos.y-7)
		newLight7.HomeUID = this.HomeUID
		local newLight8 = Object.Spawn("Light", this.Pos.x-2, this.Pos.y-6)
		newLight8.HomeUID = this.HomeUID
		local newLight9 = Object.Spawn("Light", this.Pos.x+2, this.Pos.y-6)
		newLight9.HomeUID = this.HomeUID
		local newLight10 = Object.Spawn("Light", this.Pos.x-3, this.Pos.y-4)
		newLight10.HomeUID = this.HomeUID
		local newLight11 = Object.Spawn("Light", this.Pos.x+3, this.Pos.y-4)
		newLight11.HomeUID = this.HomeUID
		local newLight12 = Object.Spawn("Light", this.Pos.x-2, this.Pos.y-2)
		newLight12.HomeUID = this.HomeUID
		local newLight13 = Object.Spawn("Light", this.Pos.x+2, this.Pos.y-2)
		newLight13.HomeUID = this.HomeUID
		local newLight14 = Object.Spawn("Light", this.Pos.x, this.Pos.y-1)
		newLight14.HomeUID = this.HomeUID
		
		RemoveTrees(newLight2,7)
		RemoveTrees(newLight5,7)
		RemoveTrees(newLight8,7)
		RemoveTrees(newLight13,7)
		
		MyCargoStopSign = Object.Spawn("CargoStopSignHelipad", this.Pos.x+9, this.Pos.y+0.45)
		MyCargoStopSign.HomeUID = this.HomeUID
	end
	if this.TrafficEnabled == "yes" then
		MyCargoStopSign.SubType = StopSignTypes[this.CargoType]
	else
		MyCargoStopSign.SubType = 5
	end
end

function BackupHelipadFloor()
	BackupCompactFloor = {
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0},
			}
			
	BackupCompactFloorInd = {
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false},
			}
			
	BackupLargeFloor = {
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			}
			
	BackupLargeFloorInd = {
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
			}


	if this.HelipadFloor == "Compact" then
		local x = this.Pos.x-5
		local y = this.Pos.y-9
		
		for X = 1,9 do
			for Y = 1,9 do
				local cell = World.GetCell(x+X,y+Y)
				BackupCompactFloor[Y][X] = cell.Mat
				BackupCompactFloorInd[Y][X] = cell.Ind
			end
		end	
	else
		local x = this.Pos.x-13
		local y = this.Pos.y-10
		for X = 1,22 do
			for Y = 1,11 do
				local cell = World.GetCell(x+X,y+Y)
				BackupLargeFloor[Y][X] = cell.Mat
				BackupLargeFloorInd[Y][X] = cell.Ind
			end
		end
	end
end

function RestoreHelipadFloor()
	if this.HelipadFloor == "Compact" then
		local x = this.Pos.x-5
		local y = this.Pos.y-9
		
		for X = 1,9 do
			for Y = 1,9 do
				local cell = World.GetCell(x+X,y+Y)
				cell.Mat = BackupCompactFloor[Y][X]
				cell.Ind = BackupCompactFloorInd[Y][X]
			end
		end	
	else
		local x = this.Pos.x-13
		local y = this.Pos.y-10
		for X = 1,22 do
			for Y = 1,11 do
				local cell = World.GetCell(x+X,y+Y)
				cell.Mat = BackupLargeFloor[Y][X]
				cell.Ind = BackupLargeFloorInd[Y][X]
			end
		end
	end
end

function InitSettings()
    Set(this,"ChinookStatus","None")
    Set(this,"FuelStocked",0)
    Set(this,"TrafficTerminalID","None")
    Set(this,"InUse","no")
    Set(this,"Number",0)
	Set(this,"TrafficEnabled","no")
	Set(this,"FoodDelivery","no")
	Set(this,"FoodQuantity",0)
	Set(this,"VendingDelivery","no")
	Set(this,"VendingQuantity",0)
	Set(this,"BuildingDelivery","no")
	Set(this,"BuildingQuantity",0)
	Set(this,"FloorDelivery","no")
	Set(this,"FloorQuantity",0)
	Set(this,"ForestDelivery","no")
	Set(this,"ForestQuantity",0)
	Set(this,"LaundryDelivery","no")
	Set(this,"LaundryQuantity",0)
	Set(this,"Workshop1Delivery","no")
	Set(this,"WorkshopQuantity",0)
	Set(this,"Workshop2Delivery","no")
	Set(this,"Workshop2Quantity",0)
	Set(this,"Workshop3Delivery","no")
	Set(this,"Workshop3Quantity",0)
	Set(this,"Workshop4Delivery","no")
	Set(this,"Workshop4uantity",0)
	Set(this,"Workshop5Delivery","no")
	Set(this,"Workshop5Quantity",0)
	Set(this,"OtherDelivery","no")
	Set(this,"OtherQuantity",0)
	Set(this,"AllQuantity",0)
	Set(this,"Status","DISABLED")
	Set(this,"Tooltip","tooltip_CargoHelipad_TrafficTerminalRequired")
	Set(this,"HookType","Exports")
	Set(this,"VehicleSpawned","no")
	Set(this,"LoadAvailable",false)
	Set(this,"CargoStored",0)
	
	Set(this,"IDtoRemove","None")
	Set(this,"IntakeCancelled",false)
	Set(this,"SecLevel","ALL")
	Set(this,"IntakeMinSec","no")
	Set(this,"IntakeNormal","no")
	Set(this,"IntakeMaxSec","no")
	Set(this,"IntakeSuperMax","no")
	Set(this,"IntakeProtected","no")
	Set(this,"IntakeDeathRow","no")
	Set(this,"IntakeInsane","no")
	Set(this,"IsIntake","NO")
	Set(this,"PrisQuantity",0)
	this.SubType = 0
end

function FindMyTrafficTerminal()
	print("FindMyTrafficTerminal")
	local nearbyTerminals = Find(this,"TrafficTerminal",10000)
	for thatTerminal, distance in pairs(nearbyTerminals) do
		MyTrafficTerminal = thatTerminal
		print("MyTrafficTerminal found at "..distance)
		if Get(this,"TrafficTerminalID") == "None" then
			Set(this,"TrafficTerminalID",thatTerminal.Id.i)
			Set(thatTerminal,"UpdateTraffic",true)
		end
	end
	if not Exists(MyTrafficTerminal) then
		print(" -- ERROR --- MyTrafficTerminal not found")
		Set(this,"Tooltip","tooltip_CargoHelipad_TrafficTerminalRequired")
	end
end

function FindMyCargoStopSign()
	print("FindMyCargoStopSign")
	local signFound = false
	local nearbyObject = Find("CargoStopSignHelipad",10)
	if next(nearbyObject) then
		for thatSign, distance in pairs(nearbyObject) do
			if thatSign.HomeUID == this.HomeUID then
				MyCargoStopSign = thatSign
				signFound = true
				print("Sign found at dist "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyCargoStopSign) then
		print(" -- ERROR --- MyCargoStopSign not found")
	end
end

function Update(timePassed)
	if timePerUpdate == nil then
		if this.HelipadMade == true then
			UpdateTooltip()
			UpgradeSecLevels()	-- add new intake values for compatibility
			Interface.AddComponent(this,"RemoveHelipad", "Button", "tooltip_CargoHelipad_Button_Delete")
			Interface.AddComponent(this,"SeparatorPad0", "Caption", "tooltip_CargoHelipad_Separatorline")
			Interface.AddComponent(this,"RemoveStack", "Button", "tooltip_CargoHelipad_Button_DeleteStack")
			Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_CargoHelipad_Button_FloorType","tooltip_CargoHelipad_FloorType_"..this.HelipadFloor,"X")
			Interface.AddComponent(this,"SeparatorPad1", "Caption", "tooltip_CargoHelipad_Separatorline")
			Interface.AddComponent(this,"toggleCargoType", "Button", "tooltip_CargoStation_Button_CargoType","tooltip_CargoStation_Button_"..this.CargoType,"X")
			Interface.AddComponent(this,"toggleTraffic", "Button", "tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..this.TrafficEnabled,"X")
			if this.CargoType == "Deliveries" then
				Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoHelipad_Separatorline")
				Interface.AddComponent(this,"toggleFoodDelivery", "Button", "tooltip_CargoStation_Button_FoodDelivery","tooltip_CargoStation_Button_Delivery_"..this.FoodDelivery,"X")
				Interface.AddComponent(this,"toggleVendingDelivery", "Button", "tooltip_CargoStation_Button_VendingDelivery","tooltip_CargoStation_Button_Delivery_"..this.VendingDelivery,"X")
				Interface.AddComponent(this,"toggleBuildingDelivery", "Button", "tooltip_CargoStation_Button_BuildingDelivery","tooltip_CargoStation_Button_Delivery_"..this.BuildingDelivery,"X")
				Interface.AddComponent(this,"toggleFloorsDelivery", "Button", "tooltip_CargoStation_Button_FloorsDelivery","tooltip_CargoStation_Button_Delivery_"..this.FloorDelivery,"X")
				Interface.AddComponent(this,"toggleLaundryDelivery", "Button", "tooltip_CargoStation_Button_LaundryDelivery","tooltip_CargoStation_Button_Delivery_"..this.LaundryDelivery,"X")
				Interface.AddComponent(this,"toggleForestDelivery", "Button", "tooltip_CargoStation_Button_ForestDelivery","tooltip_CargoStation_Button_Delivery_"..this.ForestDelivery,"X")
				Interface.AddComponent(this,"toggleWorkshop1Delivery", "Button", "tooltip_CargoStation_Button_Workshop1Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop1Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop2Delivery", "Button", "tooltip_CargoStation_Button_Workshop2Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop2Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop3Delivery", "Button", "tooltip_CargoStation_Button_Workshop3Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop3Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop4Delivery", "Button", "tooltip_CargoStation_Button_Workshop4Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop4Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop5Delivery", "Button", "tooltip_CargoStation_Button_Workshop5Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop5Delivery,"X")
				Interface.AddComponent(this,"toggleOtherDelivery", "Button", "tooltip_CargoStation_Button_OtherDelivery","tooltip_CargoStation_Button_Delivery_"..this.OtherDelivery,"X")
			elseif this.CargoType == "Intake" then
				Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoHelipad_Separatorline")
				Interface.AddComponent(this,"toggleSecLevel1", "Button", "tooltip_CargoStation_Button_SecLevel1","tooltip_CargoStation_Button_Delivery_"..this.IntakeMinSec,"X")
				Interface.AddComponent(this,"toggleSecLevel2", "Button", "tooltip_CargoStation_Button_SecLevel2","tooltip_CargoStation_Button_Delivery_"..this.IntakeNormal,"X")
				Interface.AddComponent(this,"toggleSecLevel3", "Button", "tooltip_CargoStation_Button_SecLevel3","tooltip_CargoStation_Button_Delivery_"..this.IntakeMaxSec,"X")
				Interface.AddComponent(this,"toggleSecLevel4", "Button", "tooltip_CargoStation_Button_SecLevel4","tooltip_CargoStation_Button_Delivery_"..this.IntakeProtected,"X")
				Interface.AddComponent(this,"toggleSecLevel5", "Button", "tooltip_CargoStation_Button_SecLevel5","tooltip_CargoStation_Button_Delivery_"..this.IntakeSuperMax,"X")
				Interface.AddComponent(this,"toggleSecLevel6", "Button", "tooltip_CargoStation_Button_SecLevel6","tooltip_CargoStation_Button_Delivery_"..this.IntakeDeathRow,"X")
				Interface.AddComponent(this,"toggleSecLevel7", "Button", "tooltip_CargoStation_Button_SecLevel7","tooltip_CargoStation_Button_Delivery_"..this.IntakeInsane,"X")
				Interface.AddComponent(this,"toggleIsIntake", "Button", "tooltip_CargoStation_Button_IsIntake","tooltip_CargoStation_Button_"..this.IsIntake,"X")
			end
			FindMyChinook()
			if this.AllQuantity > 0 then
				this.Tooltip = { "tooltip_CargoHelipad_DeliveriesArriving",this.HomeUID,"Y",this.Number,"Z",this.BuildingQuantity,"A",this.FloorQuantity,"B",this.FoodQuantity,"C",this.LaundryQuantity,"D",this.ForestQuantity,"E",this.VendingQuantity,"F",this.Workshop1Quantity,"G",this.Workshop2Quantity,"H",this.Workshop3Quantity,"I",this.Workshop4Quantity,"J",this.Workshop5Quantity,"K",this.OtherQuantity,"L" }
			elseif this.PrisQuantity > 0 then
				this.Tooltip = { "tooltip_CargoHelipad_PrisonersArriving",this.HomeUID,"Y",this.Number,"Z",this.PrisQuantity,"T",this.MinSecQuantity,"A",this.NormalQuantity,"B",this.MaxSecQuantity,"C",this.ProtectedQuantity,"D",this.SuperMaxQuantity,"E",this.DeathRowQuantity,"F",this.InsaneQuantity,"G" }
			else
				this.Tooltip = { "tooltip_CargoHelipad",this.HomeUID,"Y",this.Number,"Z" }
			end
		else
			Interface.AddComponent(this,"DeleteHelipad", "Button", "tooltip_CargoHelipad_Button_Delete")
			Interface.AddComponent(this,"SeparatorOr", "Caption", "tooltip_CargoHelipad_Or")
			Interface.AddComponent(this,"BuildHelipad", "Button", "tooltip_CargoHelipad_Button_BuildHelipad")
		end
		timePerUpdate = 1 / World.TimeWarpFactor
	end
	timeFlash = timeFlash + timePassed
	if timeFlash >= timePerUpdate then
		timeFlash = 0
		if this.InUse == "yes" then
			if this.SubType == 6 then this.SubType = 7 else this.SubType = 6 end
		else
			if this.SubType ~= 0 and this.SubType ~= 8 then
				this.SubType = HelipadTypes[this.CargoType]
			end
		end
	end
	if this.CargoType ~= "Intake" and this.CargoType ~= "Deliveries" then
		timeTot = timeTot + timePassed
		if timeTot >= timePerUpdate then
			timeTot = 0
			if this.TrafficEnabled == "yes" then 
				timeLoad = timeLoad + 1
				if timeLoad >= timePerLoadUpdate then
					timeLoad = 0
					if this.InUse == "no" then
						LookForCargo()
						if this.LoadAvailable == true then
							OrderChinook()
						end
					else
						if this.LoadAvailable == true and not Exists(MyChinook) then
							OrderChinook()
						end
					end						
				end
			end
		end
	end
end

function UpgradeSecLevels()
	if this.IntakeMinSec == nil then	-- upgrade values for compatibility
		if this.SecLevel == "ALL" or this.SecLevel == "MinSec" then Set(this,"IntakeMinSec","yes") else Set(this,"IntakeMinSec","no") end
		if this.SecLevel == "ALL" or this.SecLevel == "Normal" then Set(this,"IntakeNormal","yes") else Set(this,"IntakeNormal","no") end
		if this.SecLevel == "ALL" or this.SecLevel == "MaxSec" then Set(this,"IntakeMaxSec","yes") else Set(this,"IntakeMaxSec","no") end
		if this.SecLevel == "ALL" or this.SecLevel == "SuperMax" then Set(this,"IntakeSuperMax","yes") else Set(this,"IntakeSuperMax","no") end
		if this.SecLevel == "ALL" or this.SecLevel == "Protected" then Set(this,"IntakeProtected","yes") else Set(this,"IntakeProtected","no") end
		if this.SecLevel == "ALL" or this.SecLevel == "DeathRow" then Set(this,"IntakeDeathRow","yes") else Set(this,"IntakeDeathRow","no") end
		if this.SecLevel == "ALL" or this.SecLevel == "Insane" then Set(this,"IntakeInsane","yes") else Set(this,"IntakeInsane","no") end
		Set(this,"SecLevel","ALL")
	end
end

function FindMyLoaders()
	print("FindMyLoaders "..this.HookType)
	local found = false
	Loaders = {}
	Loaders[3] = {}
	Loaders[4] = {}
	Loaders[5] = {}
	Loaders[6] = {}
	local nearbyObjects = Find(this,this.HookType.."ChinookHook",10)
	if next(nearbyObjects) then
		for thatLoader, distance in pairs(nearbyObjects) do
			if thatLoader.HomeUID == this.HomeUID and thatLoader.HookNr >= 3 then -- and thatLoader.CargoAmount < 8 then
				Loaders[thatLoader.HookNr] = thatLoader
				print("My"..this.HookType.."Loader"..thatLoader.HookNr.." found at "..distance)
			elseif thatLoader.HomeUID == this.HomeUID and thatLoader.HookNr == 1 then
				TakeAwayLoader1 = thatLoader
				print("TakeAwayLoader "..thatLoader.HookNr.." found at "..distance)
			elseif thatLoader.HomeUID == this.HomeUID and thatLoader.HookNr == 2 then
				TakeAwayLoader2 = thatLoader
				print("TakeAwayLoader "..thatLoader.HookNr.." found at "..distance)
			end
		end
	else
		SpawnLoader(3)
		SpawnLoader(4)
		SpawnLoader(5)
		SpawnLoader(6)
	end
	for L = 3,6 do
		if not Exists(Loaders[L]) then SpawnLoader(L) end
	end
	nearbyObjects = nil
end

function LookForCargo()
	if Loaders == nil then FindMyLoaders() end
	if this.SubType == 2 or this.SubType == 3 then		-- exports and garbage are loaded on ExportsChinookHook
		if not this.AllLoadersFilled then
			Set(this,"HookType","Exports")
			print("LookForCargo "..this.HookType)
			if this.HelipadFloor == "Compact" then
				local MyChecker = Object.Spawn("LoadChecker",this.Pos.x,this.Pos.y-4)
				for _, typ in pairs(ObjectsToLoad) do
					local nearbyObjects = Find(MyChecker,typ,5)
					for thatObject, _ in pairs(nearbyObjects) do
						if not thatObject.Loaded then
							FillMyLoader(thatObject)
						end
						if this.AllLoadersFilled == true then break end
					end
					nearbyObjects = nil
					if this.AllLoadersFilled == true then break end
				end
				MyChecker.Delete()
			else
				local MyChecker = Object.Spawn("LoadChecker",this.Pos.x-7,this.Pos.y-4)
				local Done = false
				while not Done do
					print("MyChecker "..MyChecker.Pos.x)
					for _, typ in pairs(ObjectsToLoad) do
						local nearbyObjects = Find(MyChecker,typ,6)
						for thatObject, _ in pairs(nearbyObjects) do
							if not thatObject.Loaded then
								FillMyLoader(thatObject)
							end
							if this.AllLoadersFilled == true then break end
						end
						nearbyObjects = nil
						if this.AllLoadersFilled == true then break end
					end
					MyChecker.Pos.x = MyChecker.Pos.x + 4
					if this.AllLoadersFilled == true or MyChecker.Pos.x >= this.Pos.x+8 then Done = true end
				end
				MyChecker.Delete()
			end
		else
			print("AllLoadersFilled")
		end
		CheckMyLoaders()
	elseif this.SubType == 4 then						-- dead entities are loaded on EmergencyChinookHook
		Set(this,"HookType","Emergency")
		print("LookForCargo "..this.HookType)
		CheckMyLoaders()
	end
end

function CheckMyLoaders()
	print("CheckMyLoaders "..this.HookType)
	local consolidate = false
	local totalAmount = 0
	local amount = 0
	for L = 3,6 do
		amount = 0
		if not Exists(Loaders[L]) then SpawnLoader(L) end
		for S = 0,7 do
			if Get(Loaders[L],"Slot"..S..".i") > -1 then
				amount = amount + 1
				Set(Loaders[L],"CargoLoad"..S,this.HomeUID)
			else
				Set(Loaders[L],"CargoLoad"..S,0)
			end
		end
		Set(Loaders[L],"CargoAmount",amount)
		Loaders[L].Tooltip = { "tooltip_ChinookHook",this.HomeUID,"H",L,"N",amount,"A" }
		totalAmount = totalAmount + amount
	end
	if totalAmount > 0 then ConsolidateLoaders() else Set(this,"AllLoadersFilled",nil) end
	if this.HookType == "Emergency" and this.CargoStored > 0 then
		Set(this,"LoadAvailable",true)
	elseif this.CargoStored >= 8 then
		Set(this,"LoadAvailable",true)
	end
end

function FillMyLoader(withCargo)
	print("FillMyLoader "..withCargo.Type)
	local filled = false
	for L = 3,6 do
		if Exists(Loaders[L]) then
			for S = 7,0,-1 do
				if Get(Loaders[L],"Slot"..S..".i") == -1 then
					if withCargo.Type == "Garbage" then
						local newGarbage = Object.Spawn("CargoGarbage",withCargo.Pos.x,withCargo.Pos.y)
						newGarbage.SubType = withCargo.SubType
						withCargo.Delete()
						withCargo = newGarbage
					end
					print("Loading "..withCargo.Type.." in "..Loaders[L].Type.." "..L.." Slot "..S)
					Set(Loaders[L],"Slot"..S..".i",withCargo.Id.i)
					Set(Loaders[L],"Slot"..S..".u",withCargo.Id.u)
					Set(withCargo,"CarrierId.i",Loaders[L].Id.i)
					Set(withCargo,"CarrierId.u",Loaders[L].Id.u)
					Set(withCargo,"Loaded",true)
					Set(Loaders[L],"CargoLoad"..S,this.HomeUID)
					filled = true
					break
				end
			end
			if filled == true then break end
		end
	end
	if filled == false then
		Set(this,"AllLoadersFilled",true)
		print("Unable to load cargo, all Loaders were filled")
	end
end

function SpawnLoader(HookNr)
	print("SpawnLoader "..this.HookType.." "..HookNr)
	Loaders[HookNr] = {}
	local MyLoader = Object.Spawn(this.HookType.."ChinookHook",this.Pos.x,this.Pos.y-3)
	Set(MyLoader,"HomeUID",this.HomeUID)
	Set(MyLoader,"HookNr",HookNr)
	Set(MyLoader,"SubType",3)
	Set(MyLoader,"CargoAmount",0)
	for i = 0,7 do
		Set(MyLoader,"CargoLoad"..i,0)
	end
	MyLoader.Tooltip = { "tooltip_ChinookHook",this.HomeUID,"H",HookNr,"N",amount,"A" }
	Loaders[HookNr] = MyLoader
	print(" -- MyLoader "..HookNr.." spawned")
end

function ConsolidateLoaders()
	print("ConsolidateLoaders "..this.HookType.."ChinookHook")
	Set(this,"CargoStored",0)
	
	if not Exists(TakeAwayLoader1) then
		TakeAwayLoader1 = Object.Spawn(this.HookType.."ChinookHook",this.Pos.x,this.Pos.y-3)
		Set(TakeAwayLoader1,"HomeUID",this.HomeUID)
		TakeAwayLoader1.Tooltip = { "tooltip_ChinookHook",this.HomeUID,"H",1,"N",0,"A" }
		Set(TakeAwayLoader1,"SubType",2)
		Set(TakeAwayLoader1,"HookNr",1)
		for i = 0,7 do
			Set(TakeAwayLoader1,"CargoLoad"..i,0)
		end
	end
	FillTakeAway(TakeAwayLoader1,1)
	Set(this,"CargoStored",TakeAwayLoader1.CargoAmount)
	
	if not Exists(TakeAwayLoader2) then
		TakeAwayLoader2 = Object.Spawn(this.HookType.."ChinookHook",this.Pos.x+0.1,this.Pos.y-3)
		Set(TakeAwayLoader2,"HomeUID",this.HomeUID)
		TakeAwayLoader2.Tooltip = { "tooltip_ChinookHook",this.HomeUID,"H",2,"N",0,"A" }
		Set(TakeAwayLoader2,"SubType",2)
		Set(TakeAwayLoader2,"HookNr",2)
		for i = 0,7 do
			Set(TakeAwayLoader2,"CargoLoad"..i,0)
		end
	end
	FillTakeAway(TakeAwayLoader2,2)
	Set(this,"CargoStored",this.CargoStored + TakeAwayLoader2.CargoAmount)
end

function FillTakeAway(theTakeAway,theHookNr)
	local amount = 0
	local L = 3
	local E = 0
	while E <= 7 do
		if Get(theTakeAway,"Slot"..E..".i") == -1 then
			for L = 3,6 do
				local loaderamount = 0
				for S = 0,7 do
					if Get(Loaders[L],"Slot"..S..".i") > -1 then
						local I,U = Get(Loaders[L],"Slot"..S..".i"),Get(Loaders[L],"Slot"..S..".u")
						Set(Loaders[L],"Slot"..S..".i",-1)
						Set(Loaders[L],"Slot"..S..".u",-1)
						Set(Loaders[L],"CargoLoad"..S,0)
						print("Fill TakeAwayLoader"..theHookNr.." slot "..E.." with loader"..L.." slot "..S)
						Set(theTakeAway,"Slot"..E..".i",I)
						Set(theTakeAway,"Slot"..E..".u",U)
						Set(theTakeAway,"CargoLoad"..E,this.HomeUID)
						loaded = true
						break
					end
					if Get(Loaders[L],"CargoLoad"..S) == this.HomeUID then
						loaderamount = loaderamount + 1
					end
				end
				Set(Loaders[L],"CargoAmount",loaderamount)
				Set(Loaders[L],"Tooltip","\nHomeUID: "..this.HomeUID.."\nHook Number "..L.."\nAmount: "..loaderamount)
				if loaded then break end
			end
		end
		loaded = nil
		E = E + 1
	end
	for i = 0,7 do
		if Get(theTakeAway,"CargoLoad"..i) == this.HomeUID then
			amount = amount + 1
		end
	end
	Set(theTakeAway,"CargoAmount",amount)
	theTakeAway.Tooltip = { "tooltip_ChinookHook",this.HomeUID,"H",theHookNr,"N",amount,"A" }
end

function OrderChinook()
	print("OrderChinook")
	if not Exists(MyTrafficTerminal) then FindMyTrafficTerminal() end
	MyChinook = Object.Spawn("Chinook2",3,this.Pos.y-8)
	Set(MyChinook,"HomeUID",this.HookType.."Chinook_"..string.sub(MyChinook.Id.u,-2))
	Set(MyChinook,"MyType",this.HookType)
	Set(MyChinook,"Loaded",true)
	if Get(MyTrafficTerminal,"AnimateChinook") == "yes" then
		local ChinookLightBack = Object.Spawn("StatusLight",MyChinook.Pos.x-2.9,MyChinook.Pos.y-1)
		Set(ChinookLightBack,"HomeUID",MyChinook.HomeUID)
		Set(ChinookLightBack,"Spot","Back")
		Set(ChinookLightBack,"Or.x",0)
		Set(ChinookLightBack,"Or.y",-1)
		Set(MyChinook,"Slot0.i",ChinookLightBack.Id.i)
		Set(MyChinook,"Slot0.u",ChinookLightBack.Id.u)
		Set(ChinookLightBack,"Loaded",true)
		
		local ChinookLightFront = Object.Spawn("StatusLight",MyChinook.Pos.x+5.85,MyChinook.Pos.y-1)
		Set(ChinookLightFront,"HomeUID",MyChinook.HomeUID)
		Set(ChinookLightFront,"Spot","Front")
		Set(ChinookLightFront,"Or.x",0)
		Set(ChinookLightFront,"Or.y",-1)
		Set(MyChinook,"Slot1.i",ChinookLightFront.Id.i)
		Set(MyChinook,"Slot1.u",ChinookLightFront.Id.u)
		Set(ChinookLightFront,"Loaded",true)
	end
	
	local ChinookHook = Object.Spawn(this.HookType.."ChinookHook",MyChinook.Pos.x+2.1,MyChinook.Pos.y-2.7)
	Set(ChinookHook,"HomeUID",MyChinook.HomeUID)
	ChinookHook.Tooltip = { "tooltip_ChinookHook",ChinookHook.HomeUID,"H",1,"N",0,"A" }
	Set(ChinookHook,"HookNr",1)
	Set(ChinookHook,"SubType",1)
	Set(ChinookHook,"CargoAmount",0)
	for i = 0,7 do
		Set(ChinookHook,"CargoLoad"..i,0)
	end
	Set(MyChinook,"TotalCargoAmount",0)
	-- fill with dummy if hearse chinook
	Set(MyChinook,"Slot2.i",ChinookHook.Id.i)
	Set(MyChinook,"Slot2.u",ChinookHook.Id.u)
	Set(ChinookHook,"Loaded",true)
	
	ChinookHook = Object.Spawn(this.HookType.."ChinookHook",MyChinook.Pos.x+2.1,MyChinook.Pos.y-2.7)
	Set(ChinookHook,"HomeUID",MyChinook.HomeUID)
	ChinookHook.Tooltip = { "tooltip_ChinookHook",ChinookHook.HomeUID,"H",2,"N",0,"A" }
	Set(ChinookHook,"HookNr",2)
	Set(ChinookHook,"SubType",1)
	Set(ChinookHook,"CargoAmount",0)
	for i = 0,7 do
		Set(ChinookHook,"CargoLoad"..i,0)
	end
	
	Set(MyChinook,"Slot3.i",ChinookHook.Id.i)
	Set(MyChinook,"Slot3.u",ChinookHook.Id.u)
	Set(ChinookHook,"Loaded",true)
		
	Set(MyChinook,"PadX",this.Pos.x-0.15)
	Set(MyChinook,"PadY",this.Pos.y-5.42)
	Set(MyChinook,"HeliPadID",this.HomeUID)
	Set(MyChinook,"EdgeX",World.NumCellsX - 6)
	Set(MyChinook,"EdgeY",MyChinook.PadY)
	Set(MyChinook,"AnimateChinook",MyTrafficTerminal.AnimateChinook)
	Set(MyChinook,"VehicleState","ToHelipad")
	Set(MyChinook,"Number",this.Number)
	MyChinook.Tooltip = { "tooltip_Chinook2_Status",MyChinook.HomeUID,"X",MyChinook.VehicleState,"Y" }
	
	Set(this,"CargoStored",0)
	Set(this,"AllLoadersFilled",nil)
	Set(this,"InUse","yes")
	Set(this,"Status","ON ROUTE")
	
	TakeAwayLoader1 = nil
	TakeAwayLoader2 = nil
	timePerLoadUpdate = math.random() * 10
end

function FindMyChinook()
	print("FindMyChinook")
	local nearbyObjects = Find(this,"Chinook2",10000)
	for thatChinook, distance in pairs(nearbyObjects) do
		if thatChinook.HeliPadID == this.HomeUID then
			MyChinook = thatChinook
			print("MyChinook found at "..distance)
			break
		end
	end
	nearbyObject = nil
	if not Exists(MyChinook) then
		print(" -- ERROR --- MyChinook not found")
	end
end

function RemoveStackClicked()
	if Get(this,"InUse") == "no" then
		for j = 1, #ObjectsToLoad do
			for thatObject in next, Find(this,ObjectsToLoad[j],6) do
				thatObject.Delete()
			end
		end
	end
end

function RemoveLoaders()
	print("RemoveLoaders")
	for j = 1, #HookObjects do
		for thatObject in next, Find(this,HookObjects[j],6) do
			if thatObject.HomeUID == this.HomeUID then
				thatObject.Delete()
			end
		end
	end
end

function DeleteHelipadClicked()
	this.Delete()
end

function RemoveTrees(from,dist)
	for j = 1, #TreeTypes do
		for thatTree in next, Find(from,TreeTypes[j],dist) do
			thatTree.Delete()
		end
	end
end

function RemoveHelipadClicked()
	if not Exists(MyChinook) then FindMyChinook() end
	RemoveLoaders()
	RemoveStackClicked()
	RemoveHelipadFloor()
	if Exists(MyChinook) then Set(MyChinook,"DeleteMe",true) end
	this.Delete()
end

function RemoveHelipadFloor()
	if this.HelipadFloor ==  "Compact" then
		local x = this.Pos.x-5
		local y = this.Pos.y-9
		
		for X = 1,9 do
			for Y = 1,9 do
				local cell = World.GetCell(x+X,y+Y)
				cell.Mat = "Dirt"
				cell.Ind = false
			end
		end
	else
		local x = this.Pos.x-13
		local y = this.Pos.y-10
		for X = 1,22 do
			for Y = 1,11 do
				local cell = World.GetCell(x+X,y+Y)
				cell.Mat = "Dirt"
				cell.Ind = false
			end
		end
	end
	myMDs = Find(this,"MetalDetector",10)
	for thatMD, dist in pairs(myMDs) do
		if thatMD.HomeUID == this.HomeUID then
			thatMD.Delete()
		end
	end
	myLights = Find(this,"Light",14)
	for thatLight, dist in pairs(myLights) do
		if thatLight.HomeUID == this.HomeUID then
			thatLight.Delete()
		end
	end
	myStopSigns = Find(this,"CargoStopSignHelipad",10)
	for thatSign, dist in pairs(myStopSigns) do
		if thatSign.HomeUID == this.HomeUID then
			thatSign.Delete()
		end
	end	
end

function toggleFloorTypeClicked()
	if Get(this,"InUse") == "no" then
		if Get(this,"HelipadFloor") == "Compact" then
			if BackupCompactFloor == nil then
				RemoveHelipadFloor()
			else
				RemoveHelipadFloor()
				RestoreHelipadFloor()
			end
			Set(this,"HelipadFloor","Large")
			BackupHelipadFloor()
			CreateHelipadFloor()
		else
			if BackupLargeFloor == nil then
				RemoveHelipadFloor()
			else
				RemoveHelipadFloor()
				RestoreHelipadFloor()
			end
			Set(this,"HelipadFloor","Compact")
			BackupHelipadFloor()
			CreateHelipadFloor()
		end
		this.SetInterfaceCaption("toggleFloorType","tooltip_CargoHelipad_Button_FloorType","tooltip_CargoHelipad_FloorType_"..this.HelipadFloor,"X")
		this.Sound("_Deployment","SetNone")
	end
end

function toggleCargoTypeClicked()
	RemoveLoaders()
	if Get(this,"InUse") == "no" then
		if Get(this,"CargoType") == "Deliveries" then
			Interface.RemoveComponent(this,"SeparatorPad2")
			Interface.RemoveComponent(this,"toggleFoodDelivery")
			Interface.RemoveComponent(this,"toggleVendingDelivery")
			Interface.RemoveComponent(this,"toggleBuildingDelivery")
			Interface.RemoveComponent(this,"toggleFloorsDelivery")
			Interface.RemoveComponent(this,"toggleForestDelivery")
			Interface.RemoveComponent(this,"toggleLaundryDelivery")
			Interface.RemoveComponent(this,"toggleWorkshop1Delivery")
			Interface.RemoveComponent(this,"toggleWorkshop2Delivery")
			Interface.RemoveComponent(this,"toggleWorkshop3Delivery")
			Interface.RemoveComponent(this,"toggleWorkshop4Delivery")
			Interface.RemoveComponent(this,"toggleWorkshop5Delivery")
			Interface.RemoveComponent(this,"toggleOtherDelivery")
			Set(this,"HookType","Exports")
			Set(this,"CargoType","Exports")
			Set(this,"LoadAvailable",false)
			Set(this,"Tooltip","\nHomeUID: "..this.HomeUID)
			Set(this,"Number",0)
		elseif Get(this,"CargoType") == "Exports" then
			Set(this,"HookType","Exports")
			Set(this,"CargoType","Garbage")
			Set(this,"LoadAvailable",false)
		elseif Get(this,"CargoType") == "Garbage" then
			Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoHelipad_Separatorline")
			Interface.AddComponent(this,"toggleSecLevel1", "Button", "tooltip_CargoStation_Button_SecLevel1","tooltip_CargoStation_Button_Delivery_"..this.IntakeMinSec,"X")
			Interface.AddComponent(this,"toggleSecLevel2", "Button", "tooltip_CargoStation_Button_SecLevel2","tooltip_CargoStation_Button_Delivery_"..this.IntakeNormal,"X")
			Interface.AddComponent(this,"toggleSecLevel3", "Button", "tooltip_CargoStation_Button_SecLevel3","tooltip_CargoStation_Button_Delivery_"..this.IntakeMaxSec,"X")
			Interface.AddComponent(this,"toggleSecLevel4", "Button", "tooltip_CargoStation_Button_SecLevel4","tooltip_CargoStation_Button_Delivery_"..this.IntakeProtected,"X")
			Interface.AddComponent(this,"toggleSecLevel5", "Button", "tooltip_CargoStation_Button_SecLevel5","tooltip_CargoStation_Button_Delivery_"..this.IntakeSuperMax,"X")
			Interface.AddComponent(this,"toggleSecLevel6", "Button", "tooltip_CargoStation_Button_SecLevel6","tooltip_CargoStation_Button_Delivery_"..this.IntakeDeathRow,"X")
			Interface.AddComponent(this,"toggleSecLevel7", "Button", "tooltip_CargoStation_Button_SecLevel7","tooltip_CargoStation_Button_Delivery_"..this.IntakeInsane,"X")
			Interface.AddComponent(this,"toggleIsIntake", "Button", "tooltip_CargoStation_Button_IsIntake","tooltip_CargoStation_Button_"..this.IsIntake,"X")
			Set(this,"CargoType","Intake")
			Set(this,"Tooltip","\nHomeUID: "..this.HomeUID)
		elseif Get(this,"CargoType") == "Intake" then
			Interface.RemoveComponent(this,"SeparatorPad2")
			Interface.RemoveComponent(this,"toggleSecLevel1")
			Interface.RemoveComponent(this,"toggleSecLevel2")
			Interface.RemoveComponent(this,"toggleSecLevel3")
			Interface.RemoveComponent(this,"toggleSecLevel4")
			Interface.RemoveComponent(this,"toggleSecLevel5")
			Interface.RemoveComponent(this,"toggleSecLevel6")
			Interface.RemoveComponent(this,"toggleSecLevel7")
			Interface.RemoveComponent(this,"toggleIsIntake")
			Set(this,"HookType","Emergency")
			Set(this,"CargoType","Emergency")
			Set(this,"LoadAvailable",false)
			Set(this,"Tooltip","\nHomeUID: "..this.HomeUID)
		elseif Get(this,"CargoType") == "Emergency" then
			Set(this,"FoodQuantity",0)
			Set(this,"VendingQuantity",0)
			Set(this,"BuildingQuantity",0)
			Set(this,"FloorQuantity",0)
			Set(this,"ForestQuantity",0)
			Set(this,"LaundryQuantity",0)
			Set(this,"Workshop1Quantity",0)
			Set(this,"Workshop2Quantity",0)
			Set(this,"Workshop3Quantity",0)
			Set(this,"Workshop4Quantity",0)
			Set(this,"Workshop5Quantity",0)
			Set(this,"OtherQuantity",0)
			Set(this,"AllQuantity",0)
			Set(this,"InUse","no")
			Set(this,"VehicleSpawned","no")
			Set(this,"Status","Waiting...")
			
			Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoHelipad_Separatorline")
			Interface.AddComponent(this,"toggleFoodDelivery", "Button", "tooltip_CargoStation_Button_FoodDelivery","tooltip_CargoStation_Button_Delivery_"..this.FoodDelivery,"X")
			Interface.AddComponent(this,"toggleVendingDelivery", "Button", "tooltip_CargoStation_Button_VendingDelivery","tooltip_CargoStation_Button_Delivery_"..this.VendingDelivery,"X")
			Interface.AddComponent(this,"toggleBuildingDelivery", "Button", "tooltip_CargoStation_Button_BuildingDelivery","tooltip_CargoStation_Button_Delivery_"..this.BuildingDelivery,"X")
			Interface.AddComponent(this,"toggleFloorsDelivery", "Button", "tooltip_CargoStation_Button_FloorsDelivery","tooltip_CargoStation_Button_Delivery_"..this.FloorDelivery,"X")
			Interface.AddComponent(this,"toggleLaundryDelivery", "Button", "tooltip_CargoStation_Button_LaundryDelivery","tooltip_CargoStation_Button_Delivery_"..this.LaundryDelivery,"X")
			Interface.AddComponent(this,"toggleForestDelivery", "Button", "tooltip_CargoStation_Button_ForestDelivery","tooltip_CargoStation_Button_Delivery_"..this.ForestDelivery,"X")
			Interface.AddComponent(this,"toggleWorkshop1Delivery", "Button", "tooltip_CargoStation_Button_Workshop1Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop1Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop2Delivery", "Button", "tooltip_CargoStation_Button_Workshop2Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop2Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop3Delivery", "Button", "tooltip_CargoStation_Button_Workshop3Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop3Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop4Delivery", "Button", "tooltip_CargoStation_Button_Workshop4Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop4Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop5Delivery", "Button", "tooltip_CargoStation_Button_Workshop5Delivery","tooltip_CargoStation_Button_Delivery_"..this.Workshop5Delivery,"X")
			Interface.AddComponent(this,"toggleOtherDelivery", "Button", "tooltip_CargoStation_Button_OtherDelivery","tooltip_CargoStation_Button_Delivery_"..this.OtherDelivery,"X")
			Set(this,"HookType","Exports")
			Set(this,"CargoType","Deliveries")
		end
		if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
		if Get(this,"TrafficEnabled") == "yes" then
			this.SubType = HelipadTypes[this.CargoType]
			MyCargoStopSign.SubType = StopSignTypes[this.CargoType]
		else
			MyCargoStopSign.SubType = 5
		end
		this.SetInterfaceCaption("toggleCargoType","tooltip_CargoStation_Button_CargoType","tooltip_CargoStation_Button_"..this.CargoType,"X")

		UpdateTooltip()
		this.Sound("_Deployment","SetNone")
	end
end

function toggleTrafficClicked()
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	if Get(this,"InUse") == "no" then
		if Get(this,"TrafficEnabled") == "no" then
			Set(this,"TrafficEnabled","yes")
			Set(this,"Status","Waiting...")
			this.SubType = HelipadTypes[this.CargoType]
			MyCargoStopSign.SubType = StopSignTypes[this.CargoType]
			if not this.GrantCheckerSpawned then
				for MyStreetManager in next, Find(this,"StreetManager2",10000) do
					local GrantChecker = Object.Spawn("GrantChecker"..this.CargoType,MyStreetManager.Pos.x-0.5,MyStreetManager.Pos.y+2)
					Set(this,"GrantCheckerSpawned",true)
				end
			end
		else
			Set(this,"TrafficEnabled","no")
			Set(this,"Status","DISABLED")
			this.SubType = 0
			MyCargoStopSign.SubType = 5
		end
		this.SetInterfaceCaption("toggleTraffic","tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..this.TrafficEnabled,"X")
		UpdateTooltip()
		this.Sound("_Deployment","SetNone")
	end
end

function ToggleYesNo(property,var)
	local Property = Get(this,property)
	if Property == "yes" then Property = "no" else Property = "yes" end
	Set(this,property,Property)
	var = Property
	this.Sound("_Deployment","SetNone")
	return var
end

function toggleFoodDeliveryClicked()	
	this.SetInterfaceCaption("toggleFoodDelivery","tooltip_CargoStation_Button_FoodDelivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("FoodDelivery"),"X")
	if not Exists(GrantCheckerFood) then
		GrantCheckerFood = Object.Spawn("GrantCheckerFood",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerFood.Delete()
	end
end

function toggleForestDeliveryClicked()
	this.SetInterfaceCaption("toggleForestDelivery","tooltip_CargoStation_Button_ForestDelivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("ForestDelivery"),"X")
	if not Exists(GrantCheckerForest) then
		GrantCheckerForest = Object.Spawn("GrantCheckerForest",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerForest.Delete()
	end
end

function toggleVendingDeliveryClicked()
	this.SetInterfaceCaption("toggleVendingDelivery","tooltip_CargoStation_Button_VendingDelivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("VendingDelivery"),"X")
	if not Exists(GrantCheckerVending) then
		GrantCheckerVending = Object.Spawn("GrantCheckerVending",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerVending.Delete()
	end
end

function toggleBuildingDeliveryClicked()
	this.SetInterfaceCaption("toggleBuildingDelivery","tooltip_CargoStation_Button_BuildingDelivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("BuildingDelivery"),"X")
	if not Exists(GrantCheckerBuilding) then
		GrantCheckerBuilding = Object.Spawn("GrantCheckerBuilding",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerBuilding.Delete()
	end
end

function toggleFloorsDeliveryClicked()
	this.SetInterfaceCaption("toggleFloorsDelivery","tooltip_CargoStation_Button_FloorsDelivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("FloorDelivery"),"X")
	if not Exists(GrantCheckerFloors) then
		GrantCheckerFloors = Object.Spawn("GrantCheckerFloors",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerFloors.Delete()
	end
end

function toggleLaundryDeliveryClicked()
	this.SetInterfaceCaption("toggleLaundryDelivery","tooltip_CargoStation_Button_LaundryDelivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("LaundryDelivery"),"X")
	if not Exists(GrantCheckerLaundry) then
		GrantCheckerLaundry = Object.Spawn("GrantCheckerLaundry",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerLaundry.Delete()
	end
end

function toggleWorkshop1DeliveryClicked()
	this.SetInterfaceCaption("toggleWorkshop1Delivery","tooltip_CargoStation_Button_Workshop1Delivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("Workshop1Delivery"),"X")
	if not Exists(GrantCheckerWorkshop) then
		GrantCheckerWorkshop = Object.Spawn("GrantCheckerWorkshop",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerWorkshop.Delete()
	end
end

function toggleWorkshop2DeliveryClicked()
	this.SetInterfaceCaption("toggleWorkshop2Delivery","tooltip_CargoStation_Button_Workshop2Delivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("Workshop2Delivery"),"X")
end

function toggleWorkshop3DeliveryClicked()
	this.SetInterfaceCaption("toggleWorkshop3Delivery","tooltip_CargoStation_Button_Workshop3Delivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("Workshop3Delivery"),"X")
end

function toggleWorkshop4DeliveryClicked()
	this.SetInterfaceCaption("toggleWorkshop4Delivery","tooltip_CargoStation_Button_Workshop4Delivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("Workshop4Delivery"),"X")
end

function toggleWorkshop5DeliveryClicked()
	this.SetInterfaceCaption("toggleWorkshop5Delivery","tooltip_CargoStation_Button_Workshop5Delivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("Workshop5Delivery"),"X")
end

function toggleOtherDeliveryClicked()
	this.SetInterfaceCaption("toggleOtherDelivery","tooltip_CargoStation_Button_OtherDelivery","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("OtherDelivery"),"X")
	if not Exists(GrantCheckerOther) then
		GrantCheckerOther = Object.Spawn("GrantCheckerOther",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerOther.Delete()
	end
end

function toggleSecLevel1Clicked()
	this.SetInterfaceCaption("toggleSecLevel1","tooltip_CargoStation_Button_SecLevel1","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("IntakeMinSec"),"X")
	if not Exists(GrantCheckerMinSec) then
		GrantCheckerMinSec = Object.Spawn("GrantCheckerMinSec",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerMinSec.Delete()
	end
end

function toggleSecLevel2Clicked()
	this.SetInterfaceCaption("toggleSecLevel2","tooltip_CargoStation_Button_SecLevel2","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("IntakeNormal"),"X")
	if not Exists(GrantCheckerMedSec) then
		GrantCheckerMedSec = Object.Spawn("GrantCheckerMedSec",this.Pos.x-0.5,this.Pos.y+2)
	else
		GrantCheckerMedSec.Delete()
	end
end

function toggleSecLevel3Clicked()
	this.SetInterfaceCaption("toggleSecLevel3","tooltip_CargoStation_Button_SecLevel3","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("IntakeMaxSec"),"X")
end

function toggleSecLevel4Clicked()
	this.SetInterfaceCaption("toggleSecLevel4","tooltip_CargoStation_Button_SecLevel4","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("IntakeProtected"),"X")
end

function toggleSecLevel5Clicked()
	this.SetInterfaceCaption("toggleSecLevel5","tooltip_CargoStation_Button_SecLevel5","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("IntakeSuperMax"),"X")
end

function toggleSecLevel6Clicked()
	this.SetInterfaceCaption("toggleSecLevel6","tooltip_CargoStation_Button_SecLevel6","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("IntakeDeathRow"),"X")
end

function toggleSecLevel7Clicked()
	this.SetInterfaceCaption("toggleSecLevel7","tooltip_CargoStation_Button_SecLevel7","tooltip_CargoStation_Button_Delivery_"..ToggleYesNo("IntakeInsane"),"X")
end

function toggleIsIntakeClicked()
	this.SetInterfaceCaption("toggleIsIntake", "tooltip_CargoStation_Button_IsIntake","tooltip_CargoStation_Button_"..ToggleYesNo("IsIntake"),"X")
end

function UpdateTooltip()
	if this.CargoType == "Deliveries" then
		if this.AllQuantity > 0 then
			this.Tooltip = { "tooltip_CargoHelipad_DeliveriesArriving",this.HomeUID,"Y",this.Number,"Z",this.BuildingQuantity,"A",this.FloorQuantity,"B",this.FoodQuantity,"C",this.LaundryQuantity,"D",this.ForestQuantity,"E",this.VendingQuantity,"F",this.Workshop1Quantity,"G",this.Workshop2Quantity,"H",this.Workshop3Quantity,"I",this.Workshop4Quantity,"J",this.Workshop5Quantity,"K",this.OtherQuantity,"L" }
		else
			this.Tooltip = { "tooltip_CargoHelipad_DeliveriesTraffic",this.HomeUID,"H",this.TrafficEnabled,"X" }
		end
	elseif this.CargoType == "Exports" then
		this.Tooltip = { "tooltip_CargoHelipad_ExportsTraffic",this.HomeUID,"H",this.TrafficEnabled,"X" }
	elseif this.CargoType == "Garbage" then
		this.Tooltip = { "tooltip_CargoHelipad_GarbageTraffic",this.HomeUID,"H",this.TrafficEnabled,"X" }
	elseif this.CargoType == "Intake" then
		if this.PrisQuantity > 0 then
			this.Tooltip = { "tooltip_CargoHelipad_PrisonersArriving",this.HomeUID,"Y",this.Number,"Z",this.PrisQuantity,"T",this.MinSecQuantity,"A",this.NormalQuantity,"B",this.MaxSecQuantity,"C",this.ProtectedQuantity,"D",this.SuperMaxQuantity,"E",this.DeathRowQuantity,"F",this.InsaneQuantity,"G" }
		else
			this.Tooltip = { "tooltip_CargoHelipad_IntakeTraffic",this.HomeUID,"H",this.TrafficEnabled,"X" }
		end
	elseif this.CargoType == "Emergency" then
		this.Tooltip = { "tooltip_CargoHelipad_EmergencyTraffic",this.HomeUID,"H",this.TrafficEnabled,"X" }
	end
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
