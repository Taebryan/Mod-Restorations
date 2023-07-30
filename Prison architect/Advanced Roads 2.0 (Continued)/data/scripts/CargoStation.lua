
local timeTot = 0
local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

local TreeTypes = { "Tree", "SpookyTree", "SnowyConiferTree", "CactusTree", "SakuraTree", "PalmTree", "Bush" }

local CargoStationObjects	= { "CargoStationTruck","CargoTruckBay","IntakeStationTruck","IntakeTruckBay","EmergencyStationTruck","EmergencyTruckBay","LoadChecker",
								"CargoStopSign","CargoStationControl","CargoStationGantryCrane","CargoStationGantryHook","CargoStationFireEngine","WallLight","JailDoorLarge"  }
						
local TruckBayObjects = { "CargoTruckBay","IntakeTruckBay","EmergencyTruckBay" }

local TruckDrivers = { "DeliveriesTruckDriver", "ExportsTruckDriver", "GarbageTruckDriver", "IntakeTruckDriver", "EmergencyTruckDriver", "CalloutTruckDriver" }

local ObjectsToLoad = { "Garbage", "Stack", "Box", "RecyclingBag", "CargoGarbage", "CargoDeliveriesEmpty",			-- Default stuff

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

local StopSignTypes = { ["Deliveries"] = 0, ["Exports"] = 1, ["Garbage"] = 2, ["Intake"] = 3, ["Emergency"] = 4 }

local CargoStationsLarge = { ["Deliveries"] = 0, ["Exports"] = 1, ["Garbage"] = 2, ["Intake"] = 3, ["Emergency"] = 4 }
local CargoStationsSmallLeft = { ["Deliveries"] = 5, ["Exports"] = 6, ["Garbage"] = 7, ["Intake"] = 8, ["Emergency"] = 9 }
local CargoStationsSmallRight = { ["Deliveries"] = 10, ["Exports"] = 11, ["Garbage"] = 12, ["Intake"] = 13, ["Emergency"] = 14 }
local CargoStationColour = { [0] = "Orange", [1] = "Blue", [2] = "Beige", [3] = "Green", [4] = "White", [5] = "Orange", [6] = "Blue", [7] = "Beige", [8] = "Green", [9] = "White", [10] = "Orange", [11] = "Blue", [12] = "Beige", [13] = "Green", [14] = "White", }

local EquipmentTypes = {
		Fireman		 = { [1] = "Extinguisher", [2] = "Hose" },
		Paramedic	 = { [1] = "Needle" },
		ArmedGuard	 = { [1] = "Shotgun", [2] = "AssaultRifle", [3] = "AK47", [4] = "Axe", [5] = "Baton", [6] = "BatteringRam", [7] = "Gun", [8] = "Knife", [9] = "Rifle", [10] = "SubMachineGun", [11] = "Tazer" },
		RiotGuard	 = { [1] = "Baton", [2] = "AssaultRifle", [3] = "AK47", [4] = "Axe", [5] = "BatteringRam", [6] = "Gun", [7] = "Knife", [8] = "Rifle", [9] = "Shotgun", [10] = "SubMachineGun", [11] = "Tazer" },
		Soldier		 = { [1] = "AssaultRifle", [2] = "Baton", [3] = "AK47", [4] = "Axe", [5] = "BatteringRam", [6] = "Gun", [7] = "Knife", [8] = "Rifle", [9] = "Shotgun", [10] = "SubMachineGun", [11] = "Tazer" },
		EliteOps	 = { [1] = "AssaultRifle", [2] = "Baton", [3] = "AK47", [4] = "Axe", [5] = "BatteringRam", [6] = "Gun", [7] = "Knife", [8] = "Rifle", [9] = "Shotgun", [10] = "SubMachineGun", [11] = "Tazer" }
		}

local EquipmentNumbers = {
		Fireman		 = { [1] = 0, [2] = 24 },
		Paramedic	 = { [1] = 9 },
		ArmedGuard	 = { [1] = 32, [2] = 45, [3] = 0, [4] = 43, [5] = 2, [6] = 48, [7] = 7, [8] = 5, [9] = 42, [10] = 46, [11] = 37 },
		RiotGuard	 = { [1] = 2, [2] = 45, [3] = 0, [4] = 43, [5] = 48, [6] = 7, [7] = 5, [8] = 42, [9] = 32, [10] = 46, [11] = 37 },
		Soldier		 = { [1] = 45, [2] = 2, [3] = 0, [4] = 43, [5] = 48, [6] = 7, [7] = 5, [8] = 42, [9] = 32, [10] = 46, [11] = 37 },
		EliteOps	 = { [1] = 45, [2] = 2, [3] = 0, [4] = 43, [5] = 48, [6] = 7, [7] = 5, [8] = 42, [9] = 32, [10] = 46, [11] = 37 }
		}

local CalloutEquipment

function Create()
	Set(this,"HomeUID","CargoStation_"..string.sub(me["id-uniqueId"],-2))
	this.Tooltip = "tooltip_CargoStation_Placement"
end

function BuildRoadClicked()
	FindMyRoadMarker()
	Set(this,"StationHeight","COMPACT")
	Set(this,"RecyclingArea","no")
	Set(this,"FoundationType","Platform")
	if this.CargoFloor == "LARGE" then
		for thatLight in next, Find(this,"Light",10) do
			if thatLight.Pos.x > this.Pos.x-9 and thatLight.Pos.x < this.Pos.x+9 and thatLight.Pos.y > this.Pos.y-6 and thatLight.Pos.y < this.Pos.y+7 then
				thatLight.Delete()
			end
		end
		Set(this,"StationHeightLeft","COMPACT")
		Set(this,"StationHeightRight","COMPACT")
		Set(this,"RecyclingAreaLeft","no")
		Set(this,"RecyclingAreaRight","no")
		BuildMyRoad("CENTRE","DOUBLE")
		CreateLargeDeliveryFloor()
	else
		for thatLight in next, Find(this,"Light",10) do
			if thatLight.Pos.x > this.Pos.x-6 and thatLight.Pos.x < this.Pos.x+6 and thatLight.Pos.y > this.Pos.y-6 and thatLight.Pos.y < this.Pos.y+7 then
				thatLight.Delete()
			end
		end
		if this.CargoSide == "RIGHT" then
			BuildMyRoad("LEFT","SINGLE")
		else
			BuildMyRoad("RIGHT","SINGLE")
		end
		CreateSmallDeliveryFloor()
	end
	Interface.RemoveComponent(this,"BuildRoad")
	Interface.RemoveComponent(this,"SeparatorOr")
	Interface.RemoveComponent(this,"DeleteStation")
	Interface.AddComponent(this,"RemoveStation", "Button", "tooltip_CargoStation_Button_Delete")
	Interface.AddComponent(this,"SeparatorPad0", "Caption", "tooltip_CargoStation_Separatorline")
	Interface.AddComponent(this,"rebuildBuildRoad", "Button", "tooltip_CargoStation_Button_ReBuildRoad")
	Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_CargoStation_Button_FloorType")
	Interface.AddComponent(this,"toggleStationSubType", "Button", "tooltip_CargoStation_Button_SubType","tooltip_CargoStation_Button_"..CargoStationColour[this.SubType],"X")
	Interface.AddComponent(this,"toggleStationHeight", "Button", "tooltip_CargoStation_Button_StationHeight","tooltip_CargoStation_Button_"..this.StationHeight,"X")
	Interface.AddComponent(this,"toggleLights", "Button", "tooltip_CargoStation_Button_ToggleLights")
	Interface.AddComponent(this,"RemoveStack", "Button", "tooltip_CargoStation_Button_DeleteStack")
	Interface.AddComponent(this,"SeparatorPad1", "Caption", "tooltip_CargoStation_Separatorline")
	Interface.AddComponent(this,"toggleCargoSide", "Button", "tooltip_CargoStation_Button_CargoSide","tooltip_CargoStation_Button_"..this.CargoSide,"X")
	Interface.AddComponent(this,"toggleCargoType", "Button", "tooltip_CargoStation_Button_CargoType","tooltip_CargoStation_Button_"..MyCargoStopSign.CargoType,"X")
	Interface.AddComponent(this,"toggleTraffic", "Button", "tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..MyCargoStopSign.TrafficEnabled,"X")
	Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoStation_SeparatorlineCARGO")
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

	
	UpdateTooltip()
	Set(this,"RoadMade",true)
end

function CreateSmallDeliveryFloor()
	MyCargoStopSign = Object.Spawn("CargoStopSign",this.Pos.x,math.floor(this.Pos.y)+4)
	MyCargoStopSign.HomeUID = this.HomeUID
		
	MyCargoControl = Object.Spawn("CargoStationControl",this.Pos.x,this.Pos.y+3.75)
	MyCargoControl.HomeUID = this.HomeUID
			
	MyCrane = Object.Spawn("CargoStationGantryCrane",this.Pos.x,this.Pos.y-4)	
	MyCrane.HomeUID = this.HomeUID
	
	MyHook = Object.Spawn("CargoStationGantryHook",this.Pos.x,this.Pos.y-2)
	MyHook.HomeUID = this.HomeUID
	
	MyLoadChecker = Object.Spawn("LoadChecker",this.Pos.x-2,this.Pos.y-1)
	MyLoadChecker.HomeUID = this.HomeUID
	MyLoadChecker.Hidden = true
	
	RemoveTrees(MyHook,9)
	
	Set(MyCargoStopSign,"CargoStationID",MyCargoStopSign.Id.u)
    Set(MyCargoStopSign,"InUse","no")
    Set(MyCargoStopSign,"Number",0)
	Set(MyCargoStopSign,"TrafficEnabled","no")
	Set(MyCargoStopSign,"FoodDelivery","no")
	Set(MyCargoStopSign,"FoodQuantity",0)
	Set(MyCargoStopSign,"VendingDelivery","no")
	Set(MyCargoStopSign,"VendingQuantity",0)
	Set(MyCargoStopSign,"BuildingDelivery","no")
	Set(MyCargoStopSign,"BuildingQuantity",0)
	Set(MyCargoStopSign,"FloorDelivery","no")
	Set(MyCargoStopSign,"FloorQuantity",0)
	Set(MyCargoStopSign,"ForestDelivery","no")
	Set(MyCargoStopSign,"ForestQuantity",0)
	Set(MyCargoStopSign,"LaundryDelivery","no")
	Set(MyCargoStopSign,"LaundryQuantity",0)
	Set(MyCargoStopSign,"Workshop1Delivery","no")
	Set(MyCargoStopSign,"WorkshopQuantity",0)
	Set(MyCargoStopSign,"Workshop2Delivery","no")
	Set(MyCargoStopSign,"Workshop2Quantity",0)
	Set(MyCargoStopSign,"Workshop3Delivery","no")
	Set(MyCargoStopSign,"Workshop3Quantity",0)
	Set(MyCargoStopSign,"Workshop4Delivery","no")
	Set(MyCargoStopSign,"Workshop4uantity",0)
	Set(MyCargoStopSign,"Workshop5Delivery","no")
	Set(MyCargoStopSign,"Workshop5Quantity",0)
	Set(MyCargoStopSign,"OtherDelivery","no")
	Set(MyCargoStopSign,"OtherQuantity",0)
	Set(MyCargoStopSign,"AllQuantity",0)
	Set(MyCargoStopSign,"Status","DISABLED")
	Set(MyCargoStopSign,"SubType",5)
	Set(MyCargoStopSign,"Tooltip","tooltip_CargoStopSign_TrafficTerminalRequired")
	Set(MyCargoStopSign,"CargoType","Deliveries")
	Set(MyCargoStopSign,"VehicleSpawned","no")
	Set(MyCargoStopSign,"LoadAvailable",false)
	Set(MyCargoStopSign,"CargoStored",0)
	
	Set(MyCargoStopSign,"IDtoRemove","None")
	Set(MyCargoStopSign,"IntakeCancelled",false)
	Set(MyCargoStopSign,"SecLevel","ALL")
	Set(MyCargoStopSign,"IntakeMinSec","no")
	Set(MyCargoStopSign,"IntakeNormal","no")
	Set(MyCargoStopSign,"IntakeMaxSec","no")
	Set(MyCargoStopSign,"IntakeSuperMax","no")
	Set(MyCargoStopSign,"IntakeProtected","no")
	Set(MyCargoStopSign,"IntakeDeathRow","no")
	Set(MyCargoStopSign,"IntakeInsane","no")
	Set(MyCargoStopSign,"IsIntake","no")
	Set(MyCargoStopSign,"PrisQuantity",0)
	
	Set(MyCargoStopSign,"WaitForFiremen",false)
	
	Set(MyCargoStopSign,"EquipmentFiremanNr",2)
	Set(MyCargoStopSign,"EquipmentParamedicNr",1)
	Set(MyCargoStopSign,"EquipmentRiotGuardNr",1)
	Set(MyCargoStopSign,"EquipmentArmedGuardNr",1)
	Set(MyCargoStopSign,"EquipmentSoldierNr",1)
	Set(MyCargoStopSign,"EquipmentFireman",24)
	Set(MyCargoStopSign,"EquipmentParamedic",9)
	Set(MyCargoStopSign,"EquipmentRiotGuard",2)
	Set(MyCargoStopSign,"EquipmentArmedGuard",32)
	Set(MyCargoStopSign,"EquipmentSoldier",45)
	
	Set(MyCrane,"CargoStationID",MyCargoStopSign.Id.u)
	Set(MyHook,"CargoStationID",MyCargoStopSign.Id.u)
	Set(MyLoadChecker,"CargoStationID",MyCargoStopSign.Id.u)
	Set(MyCargoControl,"CargoStationID",MyCargoStopSign.Id.u)
	Set(MyCargoControl,"BayNr",0)
	
	MyCargoStopSign.MarkerUID = this.MarkerUID
	MyCargoControl.MarkerUID = this.MarkerUID
	MyCrane.MarkerUID = this.MarkerUID
	MyHook.MarkerUID = this.MarkerUID
	MyLoadChecker.MarkerUID = this.MarkerUID
	
	CreateStationFoundation(this.CargoSide)
	ToggleCargoFloor("Deliveries",this.CargoSide)
	UpdateInventoryPositions()
end

function UpdateInventoryPositions()
	print("UpdateInventoryPositions")
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	if not Exists(MyCargoControl) then FindMyCargoControl() end
	if not Exists(MyCrane) then FindMyCrane() end
	if not Exists(MyHook) then FindMyHook() end
	if not Exists(MyLoadChecker) then FindMyLoadChecker() end
	if not Exists(MyIntakeDoor) then FindMyIntakeDoor() end
	if not Exists(MyFireEquipment) then FindMyFireEquipment() end
	if this.CargoFloor == "COMPACT" then
		if this.CargoSide == "RIGHT" then
			if Exists(MyLoadChecker) then MyLoadChecker.Pos.x = this.Pos.x+2 end
			MyCargoStopSign.Pos.x = this.Pos.x
			MyCargoStopSign.CheckPointX = this.Pos.x+2
			MyCargoStopSign.CheckPointY = this.Pos.y-1
			MyCargoStopSign.RoadX = this.Pos.x-1.5
			MyCargoControl.Pos.x = this.Pos.x+2
			MyCargoControl.TruckX = this.Pos.x-1.5
			MyCargoControl.RoadX = this.Pos.x+2
			MyCargoControl.CheckPointX = this.Pos.x+2
			MyCargoControl.CheckPointY = this.Pos.y-1
			if Exists(MyCrane) then MyCrane.Pos.x = this.Pos.x-1.5 end
			if Exists(MyHook) then MyHook.Pos.x = this.Pos.x-1.5 end
			if Exists(MyIntakeDoor) then MyIntakeDoor.Pos.x = this.Pos.x+4 end
			if Exists(MyFireEquipment) then MyFireEquipment.Pos.x = this.Pos.x+2 end
		else
			if Exists(MyLoadChecker) then MyLoadChecker.Pos.x = this.Pos.x-2 end
			MyCargoStopSign.Pos.x = this.Pos.x
			MyCargoStopSign.CheckPointX = this.Pos.x-2
			MyCargoStopSign.CheckPointY = this.Pos.y-1
			MyCargoStopSign.RoadX = this.Pos.x+1.5
			MyCargoControl.Pos.x = this.Pos.x-2
			MyCargoControl.TruckX = this.Pos.x+1.5
			MyCargoControl.RoadX = this.Pos.x-2
			MyCargoControl.CheckPointX = this.Pos.x-2
			MyCargoControl.CheckPointY = this.Pos.y-1
			if Exists(MyCrane) then MyCrane.Pos.x = this.Pos.x+1.5 end
			if Exists(MyHook) then MyHook.Pos.x = this.Pos.x+1.5 end
			if Exists(MyIntakeDoor) then MyIntakeDoor.Pos.x = this.Pos.x-4 end
			if Exists(MyFireEquipment) then MyFireEquipment.Pos.x = this.Pos.x-2 end
		end
	else
		if Exists(MyLoadCheckerLeft) then MyLoadCheckerLeft.Pos.x = this.Pos.x-5 end
		if Exists(MyLoadCheckerRight) then MyLoadCheckerRight.Pos.x = this.Pos.x+5 end
		MyCargoSignLeft.RoadX = this.Pos.x-1.5
		MyCargoSignLeft.CheckPointX = this.Pos.x-5
		MyCargoSignLeft.CheckPointY = this.Pos.y-1
		MyCargoSignRight.RoadX = this.Pos.x+1.5
		MyCargoSignRight.CheckPointX = this.Pos.x+5
		MyCargoSignRight.CheckPointY = this.Pos.y-1
		MyCargoControlLeft.TruckX = this.Pos.x-1.5
		MyCargoControlLeft.RoadX = this.Pos.x-5
		MyCargoControlLeft.CheckPointX = this.Pos.x-5
		MyCargoControlLeft.CheckPointY = this.Pos.y-1
		MyCargoControlRight.TruckX = this.Pos.x+1.5
		MyCargoControlRight.RoadX = this.Pos.x+5
		MyCargoControlRight.CheckPointX = this.Pos.x+5
		MyCargoControlRight.CheckPointY = this.Pos.y-1
		if Exists(MyIntakeDoorLeft) then MyIntakeDoorLeft.Pos.x = this.Pos.x-7 end
		if Exists(MyIntakeDoorRight) then MyIntakeDoorRight.Pos.x = this.Pos.x+7 end
	end
	Set(this,"NumCellsX",World.NumCellsX)
	Set(this,"NumCellsY",World.NumCellsY)
	for MyStreetManager in next, Find(this,"StreetManager2",10000) do
		Set(MyStreetManager,"UpdateCargoStations",true)
	end
end

function CreateLargeDeliveryFloor()
	print("CreateLargeDeliveryFloor")
	MyCargoSignLeft = Object.Spawn("CargoStopSign",this.Pos.x-3,math.floor(this.Pos.y)+4)
	MyCargoSignLeft.HomeUID = this.HomeUID
	
	MyCargoSignRight = Object.Spawn("CargoStopSign",this.Pos.x+3,math.floor(this.Pos.y)+4)
	MyCargoSignRight.HomeUID = this.HomeUID
	
	MyCargoControlLeft = Object.Spawn("CargoStationControl",this.Pos.x-5,this.Pos.y+3.75)
	MyCargoControlLeft.HomeUID = this.HomeUID
	
	MyCargoControlRight = Object.Spawn("CargoStationControl",this.Pos.x+5,this.Pos.y+3.75)
	MyCargoControlRight.HomeUID = this.HomeUID
		
	MyCraneLeft = Object.Spawn("CargoStationGantryCrane",this.Pos.x-1.5,this.Pos.y-4)
	MyCraneLeft.HomeUID = this.HomeUID
	
	MyCraneRight = Object.Spawn("CargoStationGantryCrane",this.Pos.x+1.5,this.Pos.y-4)
	MyCraneRight.HomeUID = this.HomeUID
	
	MyHookLeft = Object.Spawn("CargoStationGantryHook",this.Pos.x-1.5,this.Pos.y-2)
	MyHookLeft.HomeUID = this.HomeUID
	
	MyHookRight = Object.Spawn("CargoStationGantryHook",this.Pos.x+1.5,this.Pos.y-2)
	MyHookRight.HomeUID = this.HomeUID
	
	MyLoadCheckerLeft = Object.Spawn("LoadChecker",this.Pos.x-5,this.Pos.y-1)
	MyLoadCheckerLeft.HomeUID = this.HomeUID
	MyLoadCheckerLeft.Hidden = true
	
	MyLoadCheckerRight = Object.Spawn("LoadChecker",this.Pos.x-5,this.Pos.y-1)
	MyLoadCheckerRight.HomeUID = this.HomeUID
	MyLoadCheckerRight.Hidden = true
	
	RemoveTrees(MyHookLeft,9)
	RemoveTrees(MyHookRight,9)
		
	Set(MyCargoSignLeft,"CargoStationID",MyCargoSignLeft.Id.u)
    Set(MyCargoSignLeft,"InUse","no")
    Set(MyCargoSignLeft,"Number",0)
	Set(MyCargoSignLeft,"TrafficEnabled","no")
	Set(MyCargoSignLeft,"FoodDelivery","no")
	Set(MyCargoSignLeft,"FoodQuantity",0)
	Set(MyCargoSignLeft,"VendingDelivery","no")
	Set(MyCargoSignLeft,"VendingQuantity",0)
	Set(MyCargoSignLeft,"BuildingDelivery","no")
	Set(MyCargoSignLeft,"BuildingQuantity",0)
	Set(MyCargoSignLeft,"FloorDelivery","no")
	Set(MyCargoSignLeft,"FloorQuantity",0)
	Set(MyCargoSignLeft,"ForestDelivery","no")
	Set(MyCargoSignLeft,"ForestQuantity",0)
	Set(MyCargoSignLeft,"LaundryDelivery","no")
	Set(MyCargoSignLeft,"LaundryQuantity",0)
	Set(MyCargoSignLeft,"Workshop1Delivery","no")
	Set(MyCargoSignLeft,"Workshop1Quantity",0)
	Set(MyCargoSignLeft,"Workshop2Delivery","no")
	Set(MyCargoSignLeft,"Workshop2Quantity",0)
	Set(MyCargoSignLeft,"Workshop3Delivery","no")
	Set(MyCargoSignLeft,"Workshop3Quantity",0)
	Set(MyCargoSignLeft,"Workshop4Delivery","no")
	Set(MyCargoSignLeft,"Workshop4Quantity",0)
	Set(MyCargoSignLeft,"Workshop5Delivery","no")
	Set(MyCargoSignLeft,"Workshop5Quantity",0)
	Set(MyCargoSignLeft,"OtherDelivery","no")
	Set(MyCargoSignLeft,"OtherQuantity",0)
	Set(MyCargoSignLeft,"AllQuantity",0)
	Set(MyCargoSignLeft,"Status","DISABLED")
	Set(MyCargoSignLeft,"SubType",5)
	Set(MyCargoSignLeft,"Tooltip","tooltip_CargoStopSign_TrafficTerminalRequired")
	Set(MyCargoSignLeft,"CargoType","Deliveries")
	Set(MyCargoSignLeft,"VehicleSpawned","no")
	Set(MyCargoSignLeft,"LoadAvailable",false)
	Set(MyCargoSignLeft,"CargoStored",0)
	
	Set(MyCargoSignLeft,"IDtoRemove","None")
	Set(MyCargoSignLeft,"IntakeCancelled",false)
	Set(MyCargoSignLeft,"SecLevel","ALL")
	Set(MyCargoSignLeft,"IntakeMinSec","no")
	Set(MyCargoSignLeft,"IntakeNormal","no")
	Set(MyCargoSignLeft,"IntakeMaxSec","no")
	Set(MyCargoSignLeft,"IntakeSuperMax","no")
	Set(MyCargoSignLeft,"IntakeProtected","no")
	Set(MyCargoSignLeft,"IntakeDeathRow","no")
	Set(MyCargoSignLeft,"IntakeInsane","no")
	Set(MyCargoSignLeft,"IsIntake","no")
	Set(MyCargoSignLeft,"PrisQuantity",0)
	
	Set(MyCargoSignLeft,"WaitForFiremen",false)
	Set(MyCargoSignLeft,"EquipmentFiremanNr",2)
	Set(MyCargoSignLeft,"EquipmentParamedicNr",1)
	Set(MyCargoSignLeft,"EquipmentRiotGuardNr",1)
	Set(MyCargoSignLeft,"EquipmentArmedGuardNr",1)
	Set(MyCargoSignLeft,"EquipmentSoldierNr",1)
	Set(MyCargoSignLeft,"EquipmentFireman",24)
	Set(MyCargoSignLeft,"EquipmentParamedic",9)
	Set(MyCargoSignLeft,"EquipmentRiotGuard",2)
	Set(MyCargoSignLeft,"EquipmentArmedGuard",32)
	Set(MyCargoSignLeft,"EquipmentSoldier",45)
	
	Set(MyCargoSignRight,"CargoStationID",MyCargoSignRight.Id.u)
    Set(MyCargoSignRight,"InUse","no")
    Set(MyCargoSignRight,"Number",0)
	Set(MyCargoSignRight,"TrafficEnabled","no")
	Set(MyCargoSignRight,"FoodDelivery","no")
	Set(MyCargoSignRight,"FoodQuantity",0)
	Set(MyCargoSignRight,"VendingDelivery","no")
	Set(MyCargoSignRight,"VendingQuantity",0)
	Set(MyCargoSignRight,"BuildingDelivery","no")
	Set(MyCargoSignRight,"BuildingQuantity",0)
	Set(MyCargoSignRight,"FloorDelivery","no")
	Set(MyCargoSignRight,"FloorQuantity",0)
	Set(MyCargoSignRight,"ForestDelivery","no")
	Set(MyCargoSignRight,"ForestQuantity",0)
	Set(MyCargoSignRight,"LaundryDelivery","no")
	Set(MyCargoSignRight,"LaundryQuantity",0)
	Set(MyCargoSignRight,"Workshop1Delivery","no")
	Set(MyCargoSignRight,"Workshop1Quantity",0)
	Set(MyCargoSignRight,"Workshop2Delivery","no")
	Set(MyCargoSignRight,"Workshop2Quantity",0)
	Set(MyCargoSignRight,"Workshop3Delivery","no")
	Set(MyCargoSignRight,"Workshop3Quantity",0)
	Set(MyCargoSignRight,"Workshop4Delivery","no")
	Set(MyCargoSignRight,"Workshop4Quantity",0)
	Set(MyCargoSignRight,"Workshop5Delivery","no")
	Set(MyCargoSignRight,"Workshop5Quantity",0)
	Set(MyCargoSignRight,"OtherDelivery","no")
	Set(MyCargoSignRight,"OtherQuantity",0)
	Set(MyCargoSignRight,"AllQuantity",0)
	Set(MyCargoSignRight,"Status","DISABLED")
	Set(MyCargoSignRight,"SubType",5)
	Set(MyCargoSignRight,"Tooltip","tooltip_CargoStopSign_TrafficTerminalRequired")
	Set(MyCargoSignRight,"CargoType","Garbage")
	Set(MyCargoSignRight,"VehicleSpawned","no")
	Set(MyCargoSignRight,"LoadAvailable",false)
	Set(MyCargoSignRight,"CargoStored",0)
	
	Set(MyCargoSignRight,"IDtoRemove","None")
	Set(MyCargoSignRight,"IntakeCancelled",false)
	Set(MyCargoSignRight,"SecLevel","ALL")
	Set(MyCargoSignRight,"IntakeMinSec","no")
	Set(MyCargoSignRight,"IntakeNormal","no")
	Set(MyCargoSignRight,"IntakeMaxSec","no")
	Set(MyCargoSignRight,"IntakeSuperMax","no")
	Set(MyCargoSignRight,"IntakeProtected","no")
	Set(MyCargoSignRight,"IntakeDeathRow","no")
	Set(MyCargoSignRight,"IntakeInsane","no")
	Set(MyCargoSignRight,"IsIntake","no")
	Set(MyCargoSignRight,"PrisQuantity",0)
	
	Set(MyCargoSignRight,"WaitForFiremen",false)
	Set(MyCargoSignRight,"EquipmentFiremanNr",2)
	Set(MyCargoSignRight,"EquipmentParamedicNr",1)
	Set(MyCargoSignRight,"EquipmentRiotGuardNr",1)
	Set(MyCargoSignRight,"EquipmentArmedGuardNr",1)
	Set(MyCargoSignRight,"EquipmentSoldierNr",1)
	Set(MyCargoSignRight,"EquipmentFireman",24)
	Set(MyCargoSignRight,"EquipmentParamedic",9)
	Set(MyCargoSignRight,"EquipmentRiotGuard",2)
	Set(MyCargoSignRight,"EquipmentArmedGuard",32)
	Set(MyCargoSignRight,"EquipmentSoldier",45)
	
	Set(MyCraneLeft,"CargoStationID",MyCargoSignLeft.Id.u)
	Set(MyCraneRight,"CargoStationID",MyCargoSignRight.Id.u)
	Set(MyHookLeft,"CargoStationID",MyCargoSignLeft.Id.u)
	Set(MyHookRight,"CargoStationID",MyCargoSignRight.Id.u)
	Set(MyLoadCheckerLeft,"CargoStationID",MyCargoSignLeft.Id.u)
	Set(MyLoadCheckerRight,"CargoStationID",MyCargoSignRight.Id.u)
	Set(MyCargoControlLeft,"CargoStationID",MyCargoSignLeft.Id.u)
	Set(MyCargoControlRight,"CargoStationID",MyCargoSignRight.Id.u)
	Set(MyCargoControlLeft,"BayNr",0)
	Set(MyCargoControlRight,"BayNr",0)
	
	MyCargoSignLeft.MarkerUID = this.LeftMarkerUID
	MyCargoSignRight.MarkerUID = this.RightMarkerUID
	MyCargoControlLeft.MarkerUID = this.LeftMarkerUID
	MyCargoControlRight.MarkerUID = this.RightMarkerUID
	MyCraneLeft.MarkerUID = this.LeftMarkerUID
	MyCraneRight.MarkerUID = this.RightMarkerUID
	MyHookLeft.MarkerUID = this.LeftMarkerUID
	MyHookRight.MarkerUID = this.RightMarkerUID
	MyLoadCheckerLeft.MarkerUID = this.LeftMarkerUID
	MyLoadCheckerRight.MarkerUID = this.RightMarkerUID
	
	MyCargoControl = MyCargoControlLeft
	MyCargoStopSign = MyCargoSignLeft
	MyHook = MyHookLeft
	MyCrane = MyCraneLeft
	MyLoadChecker = MyLoadCheckerLeft
	this.CargoSide = "LEFT"
	CreateStationFoundation("LEFT")
	ToggleCargoFloor("Deliveries","LEFT")
	ToggleCargoFloor("Garbage","RIGHT")
	UpdateInventoryPositions()
end

function toggleFloorTypeClicked()
	if this.FoundationType == "Road" then
		Set(this,"FoundationType","Platform")
	else
		Set(this,"FoundationType","Road")
	end
	CreateStationFoundation(this.CargoSide)
	if this.CargoFloor == "COMPACT" then
		if this.StationHeight == "TALL" then
			ToggleStorageFoundation(this.CargoSide,MyCargoStopSign.CargoType)
		end
		ToggleCargoFloor(MyCargoStopSign.CargoType,this.CargoSide)
	else
		if this.StationHeightLeft == "TALL" then
			ToggleStorageFoundation("LEFT",MyCargoStopSign.CargoType)
		end
		if this.StationHeightRight == "TALL" then
			ToggleStorageFoundation("RIGHT",MyCargoStopSign.CargoType)
		end
		ToggleCargoFloor(MyCargoStopSign.CargoType,"LEFT")
		ToggleCargoFloor(MyCargoStopSign.CargoType,"RIGHT")
	end
	this.Sound("_Deployment","SetNone")
	this.SetInterfaceCaption("toggleFloorType", "tooltip_CargoStation_Button_FloorType"..this.FoundationType)
end

function CreateStationFoundation(theSide)		-- build the foundation
	print("CreateStationFoundation "..theSide)

	local CargoLeft = {}
	local CargoRight = {}
	local LargeCargo = {}
	local Tiles = {}
	
	if this.FoundationType == "Platform" then
		CargoLeft = {
			{ 2, 20, 21, 22, 23, 4, 0, 0, 2, 3, 4 },
			{ 5, 1, 25, 26, 27, 6, 0, 0, 5, 1, 6 },
			{ 5, 1, 0, 0, 0, 6, 0, 0, 5, 1, 6 },
			{ 28, 17, 0, 0, 0, 6, 0, 0, 5, 1, 6 },
			{ 11, 10, 0, 0, 0, 6, 0, 0, 5, 1, 6 },
			{ 11, 10, 0, 0, 0, 6, 0, 0, 5, 1, 6 },
			{ 29, 16, 0, 0, 0, 6, 0, 0, 5, 1, 6 },
			{ 5, 1, 8, 8, 8, 9, 0, 0, 5, 1, 6 },
			{ 5, 1, 3, 3, 3, 4, 0, 0, 5, 1, 6 },
			{ 5, 1, 1, 1, 15, 9, 0, 0, 5, 1, 6 },
			{ 5, 1, 1, 1, 34, 33, 0, 0, 30, 1, 6 },
			{ 7, 8, 8, 8, 8, 9, 0, 0, 7, 8, 9 }
			}

		CargoRight = {
			{ 2, 3, 4, 0, 0, 2, 21, 22, 23, 20, 4 },
			{ 5, 1, 6, 0, 0, 5, 25, 26, 27, 1, 6 },			
			{ 5, 1, 6, 0, 0, 5, 0, 0, 0, 1, 6 },
			{ 5, 1, 6, 0, 0, 5, 0, 0, 0, 15, 18 },
			{ 5, 1, 6, 0, 0, 5, 0, 0, 0, 12, 13 },
			{ 5, 1, 6, 0, 0, 5, 0, 0, 0, 12, 13 },
			{ 5, 1, 6, 0, 0, 5, 0, 0, 0, 14, 19 },
			{ 5, 1, 6, 0, 0, 7, 8, 8, 8, 1, 6 },
			{ 5, 1, 6, 0, 0, 2, 3, 3, 3, 1, 6 },
			{ 5, 1, 6, 0, 0, 7, 17, 1, 1, 1, 6 },
			{ 5, 1, 31, 0, 0, 35, 36, 1, 1, 1, 6 },
			{ 7, 8, 9, 0, 0, 7, 8, 8, 8, 8, 9 }
			}
				
		LargeCargo = {
			{ 2, 20, 21, 22, 23, 4, 0, 0, 0, 0, 0, 2, 21, 22, 23, 20, 4 },
			{ 5, 1, 25, 26, 27, 6, 0, 0, 0, 0, 0, 5, 25, 26, 27, 1, 6 },
			{ 5, 1, 0, 0, 0, 6, 0, 0, 0, 0, 0, 5, 0, 0, 0, 1, 6 },
			{ 28, 17, 0, 0, 0, 6, 0, 0, 0, 0, 0, 5, 0, 0, 0, 15, 18 },
			{ 11, 10, 0, 0, 0, 6, 0, 0, 0, 0, 0, 5, 0, 0, 0, 12, 13 },
			{ 11, 10, 0, 0, 0, 6, 0, 0, 0, 0, 0, 5, 0, 0, 0, 12, 13 },
			{ 29, 16, 0, 0, 0, 6, 0, 0, 0, 0, 0, 5, 0, 0, 0, 14, 19 },
			{ 5, 1, 8, 8, 8, 9, 0, 0, 0, 0, 0, 7, 8, 8, 8, 1, 6 },
			{ 5, 1, 3, 3, 3, 4, 0, 0, 0, 0, 0 , 2, 3, 3, 3, 1, 6 },
			{ 5, 1, 1, 1, 15, 9, 0, 0, 0, 0, 0, 7, 17, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 34, 33, 0, 0, 0, 0, 0, 35, 36, 1, 1, 1, 6 },
			{ 7, 8, 8, 8, 8, 9, 0, 0, 0, 0, 0, 7, 8, 8, 8, 8, 9 }
			}
			
		Tiles = {
			[0] = "Excluded", -- 0 = excluded from changing
			[1] = "RailwayStationCT",
			[2] = "RailwayStationTL",
			[3] = "RailwayStationTC",
			[4] = "RailwayStationTR",
			[5] = "RailwayStationCL",
			[6] = "RailwayStationCR",
			[7] = "RailwayStationBL",
			[8] = "RailwayStationBC",
			[9] = "RailwayStationBR",
			[10] = "RailwayStationLS1",
			[11] = "RailwayStationLS2",
			[12] = "RailwayStationRS1",
			[13] = "RailwayStationRS2",
			[14] = "RailwayStationCTL",
			[15] = "RailwayStationCBL",
			[16] = "RailwayStationCTR",
			[17] = "RailwayStationCBR",
			[18] = "RailwayStationBR",
			[19] = "RailwayStationTR",			
			[20] = "RailwayStationTC",
			[21] = "RailwayStationTR",
			[22] = "RailwayStationTS2",
			[23] = "RailwayStationTL",
			[24] = "RailwayStationTL",
			[25] = "RailwayStationCTL",
			[26] = "RailwayStationTS1",
			[27] = "RailwayStationCTR",			
			[28] = "RailwayStationBL",
			[29] = "RailwayStationTL",
			[30] = "RailwayStationLS1",
			[31] = "RailwayStationRS1",
			[32] = "ConcreteTiles",
			[33] = "RailwayStationRS2",
			[34] = "RailwayStationRS1",
			[35] = "RailwayStationLS2",
			[36] = "RailwayStationLS1",
			}
		
		if math.floor(this.Pos.x)-8 == 0 or math.floor(this.Pos.x)-5 == 0 then	-- left map edge detected, remove stairs
			Tiles[10],Tiles[11],Tiles[28],Tiles[29] = "RailwayStationCT","RailwayStationCL","RailwayStationCL","RailwayStationCL"
		elseif math.floor(this.Pos.x)+9 == World.NumCellsX or math.floor(this.Pos.x)+6 == World.NumCellsX then	-- right map edge detected, remove stairs
			Tiles[12],Tiles[13],Tiles[18],Tiles[19] = "RailwayStationCT","RailwayStationCR","RailwayStationCR","RailwayStationCR"
		end
		
	else
		CargoLeft = {
			{ 2, 11, 11, 12, 11, 3, 0, 0, 2, 11, 3 },
			{ 6, 1, 1, 1, 1, 7, 0, 0, 6, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 9, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 9, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 9, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 9, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 9, 1, 7 },
			{ 6, 1, 1, 1, 1, 8, 0, 0, 9, 1, 7 },
			{ 6, 17, 11, 11, 11, 3, 0, 0, 2, 18, 7 },
			{ 6, 1, 1, 1, 1, 7, 0, 0, 6, 1, 7 },
			{ 6, 1, 1, 1, 1, 7, 0, 0, 6, 1, 7 },
			{ 5, 10, 10, 10, 10, 4, 0, 0, 5, 10, 4 }
			}

		CargoRight = {
			{ 2, 11, 3, 0, 0, 2, 11, 12, 11, 11, 3 },
			{ 6, 1, 6, 0, 0, 6, 1, 1, 1, 1, 7 },			
			{ 6, 1, 8, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 8, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 8, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 8, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 8, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 8, 0, 0, 9, 1, 1, 1, 1, 7 },
			{ 6, 17, 3, 0, 0, 2, 11, 11, 11, 18, 7 },
			{ 6, 1, 7, 0, 0, 6, 1, 1, 1, 1, 7 },
			{ 6, 1, 7, 0, 0, 6, 1, 1, 1, 1, 7 },
			{ 5, 10, 4, 0, 0, 5, 10, 10, 10, 10, 4 }
			}
				
		LargeCargo = {
			{ 2, 11, 11, 12, 11, 3, 0, 0, 0, 0, 0, 2, 11, 12, 11, 11, 3 },
			{ 6, 1, 1, 1, 1, 7, 0, 0, 0, 0, 0, 6, 1, 1, 1, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 0, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 0, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 0, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 0, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 0, 0, 0, 8, 0, 0, 0, 0, 0, 9, 0, 0, 0, 1, 7 },
			{ 6, 1, 1, 1, 1, 8, 0, 0, 0, 0, 0, 9, 1, 1, 1, 1, 7 },
			{ 6, 17, 11, 11, 11, 3, 0, 0, 0, 0, 0 , 2, 11, 11, 11, 18, 7 },
			{ 6, 1, 1, 1, 1, 7, 0, 0, 0, 0, 0, 6, 1, 1, 1, 1, 7 },
			{ 6, 1, 1, 1, 1, 7, 0, 0, 0, 0, 0, 6, 1, 1, 1, 1, 7 },
			{ 5, 10, 10, 10, 10, 4, 0, 0, 0, 0, 0, 5, 10, 10, 10, 10, 4 }
			}
			
		Tiles = {
			[0] = "Excluded", -- 0 = excluded from changing
			[1] = "Road",
			[2] = "curbcornerTL",
			[3] = "curbcornerTR",
			[4] = "curbcornerBR",
			[5] = "curbcornerBL",
			[6] = "outercurbL",
			[7] = "outercurbR",
			[8] = "whitecrosslinesTL",
			[9] = "whitecrosslinesTR",
			[10] = "outercurbB",
			[11] = "outercurbT",
			[12] = "curbgutter",
			[13] = "whitecenterturnTL",
			[14] = "whitecenterturnTR",
			[15] = "whitecenterturnBR",
			[16] = "whitecenterturnBL",
			[17] = "innercurbB",
			[18] = "innercurbR"
			}
	end
	
	local MyFloor = {}
	MyFloor = LargeCargo
	local x = math.floor(this.Pos.x)-9
	local y = math.floor(this.Pos.y)-6
	local maxX = 17
	
	if this.CargoFloor == "COMPACT" then
		if theSide == "RIGHT" then
			x = this.Pos.x-6
			maxX = 11
			MyFloor = CargoRight
		else
			x = this.Pos.x-6
			maxX = 11
			MyFloor = CargoLeft
		end
	end
	
	for X = 1,maxX do
		for Y = 1,12 do
			local cell = World.GetCell(x+X,y+Y)
			if Tiles[MyFloor[Y][X]] ~= "Excluded" then
				cell.Mat = Tiles[MyFloor[Y][X]]
				if this.FoundationType == "Platform" then
					cell.Ind = true
				else
					cell.Ind = false
				end
			end
		end
	end
	
end

function ToggleCargoFloor(theType,theSide)		-- adjust the 3x5 tiles of the cargo area
	print("ToggleCargoFloor "..theType.."  "..theSide)
	
	local CargoFloor = {}
	local Tiles = {}
	
	if this.FoundationType == "Platform" then
		CargoFloor = {
				{ 1, 1, 1 },
				{ 1, 1, 1 },
				{ 1, 2, 1 },
				{ 1, 1, 1 },
				{ 1, 1, 1 }
				}
				
		Tiles = {
				[0] = "Excluded",
				[1] = "NewCargoFloor",
				[2] = "NewCargoFloor"
				}
		
		if theType == "Deliveries"		 then Tiles[1],Tiles[2] = "NewCargoFloor", "NewCargoFloor"
		elseif theType == "Exports"		 then Tiles[1],Tiles[2] = "MetallTiles", "MetallTiles"
		elseif theType == "Garbage"		 then Tiles[1],Tiles[2] = "NewIronFloor", "NewIronFloor"
		elseif theType == "Intake"		 then Tiles[1],Tiles[2] = "BlackTiles", "BlackTiles"
		elseif theType == "Emergency"	 then Tiles[1],Tiles[2] = "T0_WhiteTile", "C_MaximumTile"
		end
	else
		CargoFloor = {
				{ 3, 1, 4 },
				{ 1, 1, 1 },
				{ 1, 2, 1 },
				{ 1, 1, 1 },
				{ 6, 1, 5 }
				}
				
		Tiles = {
				[0] = "Excluded",
				[1] = "Road",
				[2] = "Road",
				[3] = "whitecenterturnTL",
				[4] = "whitecenterturnTR",
				[5] = "whitecenterturnBR",
				[6] = "whitecenterturnBL"
				}
	end
	
	local x = math.floor(this.Pos.x)-7
	local y = math.floor(this.Pos.y)-4
	if this.CargoFloor == "COMPACT" then
		if theSide == "RIGHT" then
			x = this.Pos.x
		else
			x = this.Pos.x-4
		end
	elseif this.CargoFloor == "LARGE" then
		if theSide == "RIGHT" then
			x = this.Pos.x+3
		end
	end
	
	for X = 1,3 do
		for Y = 1,5 do
			local cell = World.GetCell(x+X,y+Y)
			if Tiles[CargoFloor[Y][X]] ~= "Excluded" then
				cell.Mat = Tiles[CargoFloor[Y][X]]
				if this.FoundationType == "Platform" then
					cell.Ind = true
				else
					cell.Ind = false
				end
			end
		end
	end
	ToggleStationPassage(theSide,theType)
end

function ToggleStationPassage(theSide,theType)		-- when the height is 21 tiles, create a passage between station and storage floor
	print("ToggleStationPassage "..theSide.." "..theType)
	
	local StationFloorLeft = {}
	local StationFloorLeftIntake = {}
	local PassageLeft = {}
	local PassageLeftIntake = {}
	local StationFloorRight = {}
	local StationFloorRightIntake = {}
	local PassageRight = {}
	local PassageRightIntake = {}
	local Tiles = {}
	
	if this.FoundationType == "Platform" then
	
		StationFloorLeft =  {			-- default, no storage area above the station
			{ 2, 3, 4, 7, 2, 4 },		-- creates top 2 rows of the cargo station foundation with stairs
			{ 5, 1, 1, 8, 1, 6 }
			}
			
		StationFloorLeftIntake =  {	-- intake station only has a large jaildoor to the side, no stairs at the top
			{ 2, 3, 3, 3, 3, 4 },		-- creates top 2 rows of cargo station foundation with walls
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageLeft = {				-- storage area above station, create a passage
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageLeftIntake = {			-- storage area above station is separated from intake area
			{ 2, 3, 3, 3, 3, 4 },		-- could be changed into a passage as well if desired
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		StationFloorRight = {
			{ 2, 4, 7, 2, 3, 4 },
			{ 5, 1, 8, 1, 1, 6 }
			}
			
		StationFloorRightIntake = {
			{ 2, 3, 3, 3, 3, 4 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageRight = {
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageRightIntake = {
			{ 2, 3, 3, 3, 3, 4 },
			{ 5, 1, 1, 1, 1, 6 }
			}

		Tiles = {
			[0] = "Excluded", -- 0 = excluded from changing
			[1] = "RailwayStationCT",
			[2] = "RailwayStationTL",
			[3] = "RailwayStationTC",
			[4] = "RailwayStationTR",
			[5] = "RailwayStationCL",
			[6] = "RailwayStationCR",
			[7] = "RailwayStationTS2",
			[8] = "RailwayStationTS1",
			[9] = "RailwayStationCTL",
			[10] = "RailwayStationCTR"
			}
	else
			
		StationFloorLeft =  {			-- default, no storage area above the station
			{ 2, 3, 3, 7, 3, 4 },		-- creates top 2 rows of the cargo station foundation with stairs
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		StationFloorLeftIntake =  {	-- intake station only has a large jaildoor to the side, no stairs at the top
			{ 2, 3, 3, 7, 3, 4 },		-- creates top 2 rows of cargo station foundation with walls
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageLeft = {				-- storage area above station, create a passage
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageLeftIntake = {			-- storage area above station is separated from intake area
			{ 5, 1, 1, 1, 1, 6 },		-- could be changed into a passage as well if desired
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		StationFloorRight = {
			{ 2, 3, 7, 3, 3, 4 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		StationFloorRightIntake = {
			{ 2, 3, 7, 3, 3, 4 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageRight = {
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		PassageRightIntake = {
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}

		Tiles = {
				[0] = "Excluded",
				[1] = "Road",
				[2] = "curbcornerTL",
				[3] = "outercurbT",
				[4] = "curbcornerTR",
				[5] = "outercurbL",
				[6] = "outercurbR",
				[7] = "curbgutter"
				}
	end
	local x = math.floor(this.Pos.x)-9
	local y = math.floor(this.Pos.y)-6
	if this.CargoFloor == "COMPACT" then
		RemoveWallLights(theSide)
		x = this.Pos.x-6
	elseif this.CargoFloor == "LARGE" then
		RemoveWallLights("LEFT")
		RemoveWallLights("RIGHT")	
	end
	if theSide == "RIGHT" then
		if this.CargoFloor == "COMPACT" then
			x = this.Pos.x-1
		else
			x = this.Pos.x+2
		end
	end
	
	local MyFloor = {}
	local Height = "COMPACT"
	if this.CargoFloor == "COMPACT" then
		Height = Get(this,"StationHeight")
	else
		if theSide == "RIGHT" then
			Height = Get(this,"StationHeightRight")
		else
			Height = Get(this,"StationHeightLeft")
		end
	end
	if Height == "TALL" then
		if theSide == "RIGHT" then
			if theType ~= "Intake" then
				MyFloor = PassageRight
			else
				MyFloor = PassageRightIntake
			end
		elseif theSide == "LEFT" then
			if theType ~= "Intake" then
				MyFloor = PassageLeft
			else
				MyFloor = PassageLeftIntake
			end
		end
	else
		if theSide == "RIGHT" then
			if theType ~= "Intake" then
				MyFloor = StationFloorRight
			else
				MyFloor = StationFloorRightIntake
			end
		elseif theSide == "LEFT" then
			if theType ~= "Intake" then
				MyFloor = StationFloorLeft
			else
				MyFloor = StationFloorLeftIntake
			end
		end
	end
	
	for X = 1,6 do
		for Y = 1,2 do
			local cell = World.GetCell(x+X,y+Y)
			if Tiles[MyFloor[Y][X]] ~= "Excluded" then
				cell.Mat = Tiles[MyFloor[Y][X]]
				if this.FoundationType == "Platform" then
					cell.Ind = true
				else
					cell.Ind = false
				end
			end
		end
	end
	
	if this.CargoFloor == "COMPACT" then
		if Get(this,"LightsOn"..theSide) == true then
			MakeWallLights(theSide)
		end
	elseif this.CargoFloor == "LARGE" then
		if Get(this,"LightsOnLEFT") == true then
			MakeWallLights("LEFT")
		end
		if Get(this,"LightsOnRIGHT") == true then
			MakeWallLights("RIGHT")
		end
	end
end

function ToggleStorageFoundation(theSide,theType)
	print("ToggleStorageFoundation "..theType.."  "..theSide)
	
	local StorageFloorLeft = {}
	local StorageFloorRight = {}
	local Tiles = {}
	
	if this.FoundationType == "Platform" then
		StorageFloorLeft = {
			{ 2, 3, 4, 8, 2, 4 },
			{ 5, 1, 19, 9, 18, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 7, 17, 1, 1, 1, 6 },
			{ 11, 10, 1, 1, 1, 6 },
			{ 11, 10, 1, 1, 1, 6 },
			{ 22, 16, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		StorageFloorRight = {
			{ 2, 4, 8, 2, 3, 4 },
			{ 5, 19, 9, 18, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 15, 20 },
			{ 5, 1, 1, 1, 12, 13 },
			{ 5, 1, 1, 1, 12, 13 },
			{ 5, 1, 1, 1, 14, 21 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		Tiles = {
			[0] = "Excluded", -- 0 = excluded from changing
			[1] = "RailwayStationCT",
			[2] = "RailwayStationTL",
			[3] = "RailwayStationTC",
			[4] = "RailwayStationTR",
			[5] = "RailwayStationCL",
			[6] = "RailwayStationCR",
			[7] = "RailwayStationBL",
			[8] = "RailwayStationTS2",
			[9] = "RailwayStationTS1",
			[10] = "RailwayStationLS1",
			[11] = "RailwayStationLS2",
			[12] = "RailwayStationRS1",
			[13] = "RailwayStationRS2",
			[14] = "RailwayStationCTL",
			[15] = "RailwayStationCBL",
			[16] = "RailwayStationCTR",
			[17] = "RailwayStationCBR",
			[18] = "RailwayStationCTR",
			[19] = "RailwayStationCTL",
			[20] = "RailwayStationBR",
			[21] = "RailwayStationTR",
			[22] = "RailwayStationTL"
			}
			
		if math.floor(this.Pos.x)-8 == 0 or math.floor(this.Pos.x)-5 == 0 then	-- left map edge detected, remove stairs
			Tiles[7],Tiles[10],Tiles[11],Tiles[16],Tiles[17],Tiles[22] = "RailwayStationCL","RailwayStationCT","RailwayStationCL","RailwayStationCT","RailwayStationCT","RailwayStationCL"
		elseif math.floor(this.Pos.x)+9 == World.NumCellsX or math.floor(this.Pos.x)+6 == World.NumCellsX then	-- right map edge detected, remove stairs
			Tiles[12],Tiles[13],Tiles[14],Tiles[15],Tiles[20],Tiles[21] = "RailwayStationCT","RailwayStationCR","RailwayStationCT","RailwayStationCT","RailwayStationCR","RailwayStationCR"
		end
	else
		StorageFloorLeft = {
			{ 2, 3, 3, 7, 3, 4 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}
			
		StorageFloorRight = {
			{ 2, 3, 7, 3, 3, 4 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6},
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 },
			{ 5, 1, 1, 1, 1, 6 }
			}
		Tiles = {
				[0] = "Excluded",
				[1] = "Road",
				[2] = "curbcornerTL",
				[3] = "outercurbT",
				[4] = "curbcornerTR",
				[5] = "outercurbL",
				[6] = "outercurbR",
				[7] = "curbgutter"
				}
	end
	
	local x = math.floor(this.Pos.x)-9
	local y = math.floor(this.Pos.y)-15
	if this.CargoFloor == "COMPACT" then
		x = this.Pos.x-6
	end
	if theSide == "RIGHT" then
		if this.CargoFloor == "COMPACT" then
			x = this.Pos.x-1
		else
			x = this.Pos.x+2
		end
	end
	
	if theSide == "RIGHT" and not UndoRightPossible then
		print("Creating BackupFloorRight")
		BackupFloorRight = {
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" },
			{ "ConcreteTiles", "Dirt", "Dirt", "Dirt", "Dirt", "Dirt" }
			}
		BackupIndRight = {
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false }
			}
		for X = 1,6 do
			for Y = 1,9 do
				local cell = World.GetCell(x+X,y+Y)
				if string.sub(cell.Mat,0,14) ~= "RailwayStation" then
					BackupFloorRight[Y][X] = cell.Mat
					BackupIndRight[Y][X] = cell.Ind
				end
			end
		end
		UndoRightPossible = true
	elseif theSide == "LEFT" and not UndoLeftPossible then
		print("Creating BackupFloorLeft")
		BackupFloorLeft = {
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" },
			{ "Dirt", "Dirt", "Dirt", "Dirt", "Dirt", "ConcreteTiles" }
			}
		BackupIndLeft = {
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false },
			{ false, false, false, false, false, false }
			}
		for X = 1,6 do
			for Y = 1,9 do
				local cell = World.GetCell(x+X,y+Y)
				if string.sub(cell.Mat,0,14) ~= "RailwayStation" then
					BackupFloorLeft[Y][X] = cell.Mat
					BackupIndLeft[Y][X] = cell.Ind
				end
			end
		end
		UndoLeftPossible = true
	end
	
	if Get(this,"StationHeight") == "TALL" then			
		print("Creating StorageFloor")
		local MyFloor = {}
		if theSide == "RIGHT" then
			MyFloor = StorageFloorRight
		elseif theSide == "LEFT" then
			MyFloor = StorageFloorLeft
		end
		for X = 1,6 do
			for Y = 1,9 do
				local cell = World.GetCell(x+X,y+Y)
				if Tiles[MyFloor[Y][X]] ~= "Excluded" then
					cell.Mat = Tiles[MyFloor[Y][X]]
					if this.FoundationType == "Platform" then
						cell.Ind = true
					else
						cell.Ind = false
					end
				end
			end
		end
		
	else
		if theSide == "LEFT" and UndoLeftPossible then
			print("Restoring BackupFloor")
			for X = 1,6 do
				for Y = 1,9 do
					local cell = World.GetCell(x+X,y+Y)
					cell.Mat = BackupFloorLeft[Y][X]
					cell.Ind = BackupIndLeft[Y][X]
				end
			end
			UndoLeftPossible = nil
		end
		if theSide == "RIGHT" and UndoRightPossible then
			print("Restoring BackupFloor")
			for X = 1,6 do
				for Y = 1,9 do
					local cell = World.GetCell(x+X,y+Y)
					cell.Mat = BackupFloorRight[Y][X]
					cell.Ind = BackupIndRight[Y][X]
				end
			end
			UndoRightPossible = nil
		end
	end
	ToggleStationPassage(theSide,theType)
end

function RemoveWallLights(theSide)
	for thatLight in next, Find(this,"WallLight",7) do
		if thatLight.HomeUID == this.HomeUID and thatLight.CargoSide == theSide then
			thatLight.Delete()
		end
	end
end

function MakeWallLights(theSide)
	local LightPosX = this.Pos.x-2
	if theSide == "RIGHT" then
		if this.CargoFloor == "LARGE" then
			LightPosX = this.Pos.x+5
		else
			LightPosX = this.Pos.x+2
		end
	else
		if this.CargoFloor == "LARGE" then
			LightPosX = this.Pos.x-5
		end
	end
	local MyWallLight1 = Object.Spawn("WallLight",LightPosX,this.Pos.y-4)
	MyWallLight1.HomeUID = this.HomeUID
	MyWallLight1.CargoSide = theSide
	
	local MyWallLight2 = Object.Spawn("WallLight",LightPosX,this.Pos.y+2.25)
	MyWallLight2.Or.y = -1
	MyWallLight2.HomeUID = this.HomeUID
	MyWallLight2.CargoSide = theSide
	
	local MyWallLight3 = Object.Spawn("WallLight",LightPosX,this.Pos.y+2.25)
	MyWallLight3.HomeUID = this.HomeUID
	MyWallLight3.CargoSide = theSide
	
	if this.CargoFloor == "LARGE" then
		if theSide == "RIGHT" and Get(this,"StationHeightRight") == "TALL" then
			local MyWallLight4 = Object.Spawn("WallLight",LightPosX,this.Pos.y-4)
			MyWallLight4.Or.y = -1
			MyWallLight4.HomeUID = this.HomeUID
			MyWallLight4.CargoSide = theSide
		elseif theSide == "LEFT" and Get(this,"StationHeightLeft") == "TALL" then
			local MyWallLight4 = Object.Spawn("WallLight",LightPosX,this.Pos.y-4)
			MyWallLight4.Or.y = -1
			MyWallLight4.HomeUID = this.HomeUID
			MyWallLight4.CargoSide = theSide
		end
	else
		if Get(this,"StationHeight") == "TALL" then
			local MyWallLight4 = Object.Spawn("WallLight",LightPosX,this.Pos.y-4)
			MyWallLight4.Or.y = -1
			MyWallLight4.HomeUID = this.HomeUID
			MyWallLight4.CargoSide = theSide
		end
	end
end

function BuildMyRoad(theSide, theSize,Forced)
	if markerFound == false or Forced then	-- if no roadmarker was on this lane yet, then build a road. otherwise a roadmarker was already placed by a cargo station
		print("BuildMyRoad")
		local endY=-1
		local PosX = 0
		if theSide == "LEFT" then
			PosX = this.Pos.x-1.5
		elseif theSide == "CENTRE" then
			PosX = this.Pos.x
		elseif theSide == "RIGHT" then
			PosX = this.Pos.x+1.5
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
			elseif theSize == "SINGLE" then
				MyTreeRemover.Pos.y = endY
				if MyTreeRemover.Pos.y >= TreeRemoverPriorPosY+3 then
					TreeRemoverPriorPosY = MyTreeRemover.Pos.y
					RemoveTrees(MyTreeRemover,4)
				end
				local myCTL = World.GetCell(PosX-2,endY)
				local myRML = World.GetCell(PosX-1,endY)
				local myRMR = World.GetCell(PosX,endY)
				local myCTR = World.GetCell(PosX+1,endY)
				if not IsStationPlatform(endY,this.StationHeight,"COMPACT","LEFT") then
					myCTL.Mat="ConcreteTiles"
				end
				if not IsStationPlatform(endY,this.StationHeight,"COMPACT","RIGHT") then
					myCTR.Mat="ConcreteTiles"
				end
				myRML.Mat="RoadMarkingsLeft"; myRMR.Mat="RoadMarkingsRight"
			elseif theSize == "DOUBLE" then
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
					if not IsStationPlatform(endY,this.StationHeightLeft,"LARGE") then
						myCTL.Mat="ConcreteTiles"
					end
					if not IsStationPlatform(endY,this.StationHeightRight,"LARGE") then
						myCTR.Mat="ConcreteTiles"
					end
					myRML.Mat="RoadMarkingsLeft"; myRL.Mat="Road"; myRC.Mat="RoadMarkings"; myRR.Mat="Road"; myRMR.Mat="RoadMarkingsRight"
					TickTock=true
				else
					if not IsStationPlatform(endY,this.StationHeightLeft,"LARGE") then
						myCTL.Mat="ConcreteTiles"
					end
					if not IsStationPlatform(endY,this.StationHeightRight,"LARGE") then
						myCTR.Mat="ConcreteTiles"
					end
					myRML.Mat="RoadMarkingsLeft"; myRL.Mat="Road"; myRC.Mat="Road"; myRR.Mat="Road"; myRMR.Mat="RoadMarkingsRight"
					TickTock=false
				end
			end
		end
	end
end

function IsStationPlatform(PosY,Height,Floor,Side)
	if Height == "TALL" then
		if Floor == "LARGE" then
			if PosY > this.Pos.y-15 and PosY < this.Pos.y+6 then
				return true
			else
				return false
			end
		elseif Floor == "COMPACT" then
			if this.CargoSide == Side then
				if PosY > this.Pos.y-15 and PosY < this.Pos.y+6 then
					return true
				else
					return false
				end
			else
				if PosY > this.Pos.y-6 and PosY < this.Pos.y+6 then
					return true
				else
					return false
				end
			end
		end
			
	else
		if PosY > this.Pos.y-6 and PosY < this.Pos.y+6 then
			return true
		else
			return false
		end
	end
end

function RemoveMyRoad(theSide, theSize)
	print("RemoveMyRoad")
	local endY=-1
	local PosX = 0
	if theSide == "LEFT" then
		PosX = this.Pos.x-1.5
	elseif theSide == "CENTRE" then
		PosX = this.Pos.x
	elseif theSide == "RIGHT" then
		PosX = this.Pos.x+1.5
	end
	local foundEndY=false
	while foundEndY==false do
		endY=endY+1
		local myCell = World.GetCell(PosX,endY)
		if myCell.Mat==nil then
			foundEndY=true
			endY=endY-1
		elseif theSize == "SINGLE" then
			local myCTL = World.GetCell(PosX-2,endY)
			local myRML = World.GetCell(PosX-1,endY)
			local myRMR = World.GetCell(PosX,endY)
			local myCTR = World.GetCell(PosX+1,endY)
			myCTL.Mat="Dirt"; myRML.Mat="Dirt"; myRMR.Mat="Dirt"; myCTR.Mat="Dirt"
		elseif theSize == "DOUBLE" then
			local myCTL = World.GetCell(PosX-3,endY)
			local myRML = World.GetCell(PosX-2,endY)
			local myRL = World.GetCell(PosX-1,endY)
			local myRC = World.GetCell(PosX,endY)
			local myRR = World.GetCell(PosX+1,endY)
			local myRMR = World.GetCell(PosX+2,endY)
			local myCTR = World.GetCell(PosX+3,endY)
			myCTL.Mat="Dirt"; myRML.Mat="Dirt"; myRL.Mat="Dirt"; myRC.Mat="Dirt"; myRR.Mat="Dirt"; myRMR.Mat="Dirt"; myCTR.Mat="Dirt"
		end
	end
end

function FindMyRoadMarker()
	markerFound = false
	markerFoundLeft = false
	markerFoundRight = false
    local roadMarkers = Find(this,"RoadMarker2",10000)
	if this.CargoFloor == "LARGE" then
		if next(roadMarkers) then
			for thatMarker,dist in pairs(roadMarkers) do
				if thatMarker.Pos.x == this.Pos.x+1.5 then
					MyRoadMarkerRight = thatMarker
					Set(this,"RightMarkerUID",thatMarker.Id.u)
					markerFoundRight = true
					markerFound = true
					break
				end
			end
			for thatMarker,dist in pairs(roadMarkers) do
				if thatMarker.Pos.x == this.Pos.x-1.5 then
					MyRoadMarkerLeft = thatMarker
					Set(this,"LeftMarkerUID",thatMarker.Id.u)
					markerFoundLeft = true
					markerFound = true
					break
				end
			end
		end
		roadMarkers = nil
		
		if markerFoundLeft == false then
			MyRoadMarkerLeft = Object.Spawn("RoadMarker2",this.Pos.x-1.5,0.5000000)
			Set(this,"LeftMarkerUID",MyRoadMarkerLeft.Id.u)
			local cell = World.GetCell(math.floor(MyRoadMarkerLeft.Pos.x)-1,0)
			cell.Mat = "RoadMarkerTile"
		end
			
		if markerFoundRight == false then
			MyRoadMarkerRight = Object.Spawn("RoadMarker2",this.Pos.x+1.5,0.5000000)
			Set(this,"RightMarkerUID",MyRoadMarkerRight.Id.u)
		end
	else
		local MarkerPosX = this.Pos.x + 1.5
		if this.CargoSide == "RIGHT" then MarkerPosX = this.Pos.x - 1.5 end
		if next(roadMarkers) then
			for thatMarker,distance in pairs(roadMarkers) do
				if thatMarker.Pos.x == MarkerPosX then
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
			MyRoadMarker = Object.Spawn("RoadMarker2",MarkerPosX,0.5000000)
			Set(this,"MarkerUID",MyRoadMarker.Id.u)
			local cell = World.GetCell(math.floor(MyRoadMarker.Pos.x)-1,0)
			cell.Mat = "RoadMarkerTile"
		end
	end
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyRoadMarker = MyRoadMarkerLeft
		else
			MyRoadMarker = MyRoadMarkerRight
		end
	end
	if not Exists(MyRoadMarker) then
		print(" -- ERROR --- MyRoadMarker not found")
	end
end

function FindMyCrane()
	print("---")
	print("--- HOMEUID "..this.HomeUID.." --- FindMyCrane")
	local craneFound = false
	local craneFoundLeft = false
	local craneFoundRight = false
	local nearbyObject = Find("CargoStationGantryCrane",8)
	if next(nearbyObject) then
		for thatCrane, distance in pairs(nearbyObject) do
			if thatCrane.MarkerUID == this.MarkerUID and thatCrane.HomeUID == this.HomeUID then
				MyCrane = thatCrane
				craneFound = true
				print("MyCrane found at dist "..distance)
				break
			end
			if thatCrane.MarkerUID == this.LeftMarkerUID and thatCrane.HomeUID == this.HomeUID then
				MyCraneLeft = thatCrane
				craneFoundLeft = true
				print("MyCraneLeft found at dist "..distance)
			end
			if thatCrane.MarkerUID == this.RightMarkerUID and thatCrane.HomeUID == this.HomeUID then
				MyCraneRight = thatCrane
				craneFoundRight = true
				print("MyCraneRight found at dist "..distance)
			end
		end
	end
	nearbyObject = nil
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyCrane = MyCraneLeft
		else
			MyCrane = MyCraneRight
		end
	end
	if not Exists(MyCrane) then
		print(" -- ERROR --- MyCrane not found")
	end
end

function FindMyHook()
	print("FindMyHook")
	local hookFound = false
	local hookFoundLeft = false
	local hookFoundRight = false
	local nearbyObject = Find("CargoStationGantryHook",8)
	if next(nearbyObject) then
		for thatHook, distance in pairs(nearbyObject) do
			if thatHook.MarkerUID == this.MarkerUID and thatHook.HomeUID == this.HomeUID then
				MyHook = thatHook
				print("MyHook found at "..distance)
				break
			end
			if thatHook.MarkerUID == this.LeftMarkerUID and thatHook.HomeUID == this.HomeUID then
				MyHookLeft = thatHook
				hookFoundLeft = true
				print("MyHookLeft found at dist "..distance)
			end
			if thatHook.MarkerUID == this.RightMarkerUID and thatHook.HomeUID == this.HomeUID then
				MyHookRight = thatHook
				hookFoundRight = true
				print("MyHookRight found at dist "..distance)
			end
		end
	end
	nearbyObject = nil
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyHook = MyHookLeft
		else
			MyHook = MyHookRight
		end
	end
	if not Exists(MyHook) then
		print(" -- ERROR --- MyHook not found")
	end
end

function FindMyLoadChecker()
	print("FindMyLoadChecker")
	local checkerFound = false
	local checkerFoundLeft = false
	local checkerFoundRight = false
	local nearbyObject = Find("LoadChecker",8)
	if next(nearbyObject) then
		for thatChecker, distance in pairs(nearbyObject) do
			if thatChecker.MarkerUID == this.MarkerUID and thatChecker.HomeUID == this.HomeUID then
				MyLoadChecker = thatChecker
				print("MyLoadChecker found at "..distance)
				break
			end
			if thatChecker.MarkerUID == this.LeftMarkerUID and thatChecker.HomeUID == this.HomeUID then
				MyLoadCheckerLeft = thatChecker
				checkerFoundLeft = true
				print("MyLoadCheckerLeft found at dist "..distance)
			end
			if thatChecker.MarkerUID == this.RightMarkerUID and thatChecker.HomeUID == this.HomeUID then
				MyLoadCheckerRight = thatChecker
				checkerFoundRight = true
				print("MyLoadCheckerRight found at dist "..distance)
			end
		end
	end
	nearbyObject = nil
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyLoadChecker = MyLoadCheckerLeft
		else
			MyLoadChecker = MyLoadCheckerRight
		end
	end
	if not Exists(MyLoadChecker) then
		print(" -- ERROR --- MyLoadChecker not found")
	end
end

function FindMyIntakeDoor()
	print("FindMyIntakeDoor")
	local doorFound = false
	local doorFoundLeft = false
	local doorFoundRight = false
	local nearbyObject = Find("JailDoorLarge",8)
	if next(nearbyObject) then
		for thatDoor, distance in pairs(nearbyObject) do
			if thatDoor.MarkerUID == this.MarkerUID and thatDoor.HomeUID == this.HomeUID then
				MyIntakeDoor = thatDoor
				doorFound = true
				print("MyIntakeDoor found at "..distance)
				break
			end
			if thatDoor.MarkerUID == this.LeftMarkerUID and thatDoor.HomeUID == this.HomeUID then
				MyIntakeDoorLeft = thatDoor
				doorFoundLeft = true
				print("MyIntakeDoorLeft found at dist "..distance)
			end
			if thatDoor.MarkerUID == this.RightMarkerUID and thatDoor.HomeUID == this.HomeUID then
				MyIntakeDoorRight = thatDoor
				doorFoundRight = true
				print("MyIntakeDoorRight found at dist "..distance)
			end
		end
	end
	nearbyObject = nil
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyIntakeDoor = MyIntakeDoorLeft
		else
			MyIntakeDoor = MyIntakeDoorRight
		end
	end
	if not Exists(MyIntakeDoor) then
		print(" -- ERROR --- MyIntakeDoor not found")
	end
end

function FindMyFireEquipment()
	print("FindMyFireEquipment")
	local equipFound = false
	local equipFoundLeft = false
	local equipFoundRight = false
	local nearbyObject = Find("CargoStationFireEngine",8)
	if next(nearbyObject) then
		for thatEquip, distance in pairs(nearbyObject) do
			if thatEquip.MarkerUID == this.MarkerUID and thatEquip.HomeUID == this.HomeUID then
				MyFireEquipment = thatEquip
				print("MyFireEquipment found at "..distance)
				break
			end
			if thatEquip.MarkerUID == this.LeftMarkerUID and thatEquip.HomeUID == this.HomeUID then
				MyFireEquipmentLeft = thatEquip
				equipFoundLeft = true
				print("MyFireEquipmentLeft found at dist "..distance)
			end
			if thatEquip.MarkerUID == this.RightMarkerUID and thatEquip.HomeUID == this.HomeUID then
				MyFireEquipmentRight = thatEquip
				equipFoundRight = true
				print("MyFireEquipmentRight found at dist "..distance)
			end
		end
	end
	nearbyObject = nil
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyFireEquipment = MyFireEquipmentLeft
		else
			MyFireEquipment = MyFireEquipmentRight
		end
	end
	if not Exists(MyFireEquipment) then
		print(" -- ERROR --- MyFireEquipment not found")
	end
end

function FindMyCargoControl()
	print("FindMyCargoControl")
	local controlFound = false
	local controlFoundLeft = false
	local controlFoundRight = false
	local nearbyObject = Find("CargoStationControl",7)
	if next(nearbyObject) then
		print("Found some CargoControls")
		for thatControl, distance in pairs(nearbyObject) do
			if thatControl.MarkerUID == this.MarkerUID and thatControl.HomeUID == this.HomeUID then
				MyCargoControl = thatControl
				controlFound = true
				print("CargoStationControl found at "..distance)
				break
			end
			if thatControl.MarkerUID == this.LeftMarkerUID and thatControl.HomeUID == this.HomeUID then
				MyCargoControlLeft = thatControl
				controlFoundLeft = true
				print("MyCargoControlLeft found at dist "..distance)
			end
			if thatControl.MarkerUID == this.RightMarkerUID and thatControl.HomeUID == this.HomeUID then
				MyCargoControlRight = thatControl
				controlFoundRight = true
				print("MyCargoControlRight found at dist "..distance)
			end
		end
	end
	nearbyObject = nil
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyCargoControl = MyCargoControlLeft
		else
			MyCargoControl = MyCargoControlRight
		end
	end
	if not Exists(MyCargoControl) then
		print(" -- ERROR --- MyCargoControl not found")
	end
end

function FindMyCargoStopSign()
	print("FindMyCargoStopSign")
	local signFound = false
	local signFoundLeft = false
	local signFoundRight = false
	local nearbyObject = Find("CargoStopSign",5)
	if next(nearbyObject) then
		for thatSign, distance in pairs(nearbyObject) do
			if thatSign.MarkerUID == this.MarkerUID and thatSign.HomeUID == this.HomeUID then
				MyCargoStopSign = thatSign
				signFound = true
				print("Sign found at dist "..distance)
				if MyCargoStopSign.IntakeMinSec == nil then	-- upgrade values for compatibility
					if MyCargoStopSign.SecLevel == "ALL" or MyCargoStopSign.SecLevel == "MinSec" then Set(MyCargoStopSign,"IntakeMinSec","yes") else Set(MyCargoStopSign,"IntakeMinSec","no") end
					if MyCargoStopSign.SecLevel == "ALL" or MyCargoStopSign.SecLevel == "Normal" then Set(MyCargoStopSign,"IntakeNormal","yes") else Set(MyCargoStopSign,"IntakeNormal","no") end
					if MyCargoStopSign.SecLevel == "ALL" or MyCargoStopSign.SecLevel == "MaxSec" then Set(MyCargoStopSign,"IntakeMaxSec","yes") else Set(MyCargoStopSign,"IntakeMaxSec","no") end
					if MyCargoStopSign.SecLevel == "ALL" or MyCargoStopSign.SecLevel == "SuperMax" then Set(MyCargoStopSign,"IntakeSuperMax","yes") else Set(MyCargoStopSign,"IntakeSuperMax","no") end
					if MyCargoStopSign.SecLevel == "ALL" or MyCargoStopSign.SecLevel == "Protected" then Set(MyCargoStopSign,"IntakeProtected","yes") else Set(MyCargoStopSign,"IntakeProtected","no") end
					if MyCargoStopSign.SecLevel == "ALL" or MyCargoStopSign.SecLevel == "DeathRow" then Set(MyCargoStopSign,"IntakeDeathRow","yes") else Set(MyCargoStopSign,"IntakeDeathRow","no") end
					if MyCargoStopSign.SecLevel == "ALL" or MyCargoStopSign.SecLevel == "Insane" then Set(MyCargoStopSign,"IntakeInsane","yes") else Set(MyCargoStopSign,"IntakeInsane","no") end
					Set(MyCargoStopSign,"SecLevel","ALL")	-- updates display icon for compatibility
				end
				break
			end
			if thatSign.MarkerUID == this.LeftMarkerUID and thatSign.HomeUID == this.HomeUID then
				MyCargoSignLeft = thatSign
				signFoundLeft = true
				print("MyCargoSignLeft found at dist "..distance)
				if MyCargoSignLeft.IntakeMinSec == nil then	-- upgrade values for compatibility
					if MyCargoSignLeft.SecLevel == "ALL" or MyCargoSignLeft.SecLevel == "MinSec" then Set(MyCargoSignLeft,"IntakeMinSec","yes") else Set(MyCargoSignLeft,"IntakeMinSec","no") end
					if MyCargoSignLeft.SecLevel == "ALL" or MyCargoSignLeft.SecLevel == "Normal" then Set(MyCargoSignLeft,"IntakeNormal","yes") else Set(MyCargoSignLeft,"IntakeNormal","no") end
					if MyCargoSignLeft.SecLevel == "ALL" or MyCargoSignLeft.SecLevel == "MaxSec" then Set(MyCargoSignLeft,"IntakeMaxSec","yes") else Set(MyCargoSignLeft,"IntakeMaxSec","no") end
					if MyCargoSignLeft.SecLevel == "ALL" or MyCargoSignLeft.SecLevel == "SuperMax" then Set(MyCargoSignLeft,"IntakeSuperMax","yes") else Set(MyCargoSignLeft,"IntakeSuperMax","no") end
					if MyCargoSignLeft.SecLevel == "ALL" or MyCargoSignLeft.SecLevel == "Protected" then Set(MyCargoSignLeft,"IntakeProtected","yes") else Set(MyCargoSignLeft,"IntakeProtected","no") end
					if MyCargoSignLeft.SecLevel == "ALL" or MyCargoSignLeft.SecLevel == "DeathRow" then Set(MyCargoSignLeft,"IntakeDeathRow","yes") else Set(MyCargoSignLeft,"IntakeDeathRow","no") end
					if MyCargoSignLeft.SecLevel == "ALL" or MyCargoSignLeft.SecLevel == "Insane" then Set(MyCargoSignLeft,"IntakeInsane","yes") else Set(MyCargoSignLeft,"IntakeInsane","no") end
					Set(MyCargoStopSignLeft,"SecLevel","ALL")	-- updates display icon for compatibility
				end
			end
			if thatSign.MarkerUID == this.RightMarkerUID and thatSign.HomeUID == this.HomeUID then
				MyCargoSignRight = thatSign
				signFoundRight = true
				print("MyCargoSignRight found at dist "..distance)
				if MyCargoSignRight.IntakeMinSec == nil then	-- upgrade values for compatibility
					if MyCargoSignRight.SecLevel == "ALL" or MyCargoSignRight.SecLevel == "MinSec" then Set(MyCargoSignRight,"IntakeMinSec","yes") else Set(MyCargoSignRight,"IntakeMinSec","no") end
					if MyCargoSignRight.SecLevel == "ALL" or MyCargoSignRight.SecLevel == "Normal" then Set(MyCargoSignRight,"IntakeNormal","yes") else Set(MyCargoSignRight,"IntakeNormal","no") end
					if MyCargoSignRight.SecLevel == "ALL" or MyCargoSignRight.SecLevel == "MaxSec" then Set(MyCargoSignRight,"IntakeMaxSec","yes") else Set(MyCargoSignRight,"IntakeMaxSec","no") end
					if MyCargoSignRight.SecLevel == "ALL" or MyCargoSignRight.SecLevel == "SuperMax" then Set(MyCargoSignRight,"IntakeSuperMax","yes") else Set(MyCargoSignRight,"IntakeSuperMax","no") end
					if MyCargoSignRight.SecLevel == "ALL" or MyCargoSignRight.SecLevel == "Protected" then Set(MyCargoSignRight,"IntakeProtected","yes") else Set(MyCargoSignRight,"IntakeProtected","no") end
					if MyCargoSignRight.SecLevel == "ALL" or MyCargoSignRight.SecLevel == "DeathRow" then Set(MyCargoSignRight,"IntakeDeathRow","yes") else Set(MyCargoSignRight,"IntakeDeathRow","no") end
					if MyCargoSignRight.SecLevel == "ALL" or MyCargoSignRight.SecLevel == "Insane" then Set(MyCargoSignRight,"IntakeInsane","yes") else Set(MyCargoSignRight,"IntakeInsane","no") end
					Set(MyCargoStopSignRight,"SecLevel","ALL")	-- updates display icon for compatibility
				end
			end
		end
	end
	nearbyObject = nil
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			MyCargoStopSign = MyCargoSignLeft
		else
			MyCargoStopSign = MyCargoSignRight
		end
	end
	if not Exists(MyCargoStopSign) then
		print(" -- ERROR --- MyCargoStopSign not found")
	end
end

function Update(timePassed)
	if timePerUpdate == nil then
		if this.RoadMade == true then
			FindMyRoadMarker()
			FindMyCargoStopSign()
			UpdateTooltip()
			if this.StationHeight == nil then
				Set(this,"StationHeight","COMPACT")
				if this.CargoFloor == "LARGE" then
					Set(this,"StationHeightLeft","COMPACT")
					Set(this,"StationHeightRight","COMPACT")
				end
			end
			if this.RecyclingArea == nil then
				Set(this,"RecyclingArea","no")
				if this.CargoFloor == "LARGE" then
					Set(this,"RecyclingAreaLeft","no")
					Set(this,"RecyclingAreaRight","no")
				end
			end
			Interface.AddComponent(this,"RemoveStation", "Button", "tooltip_CargoStation_Button_Delete")
			Interface.AddComponent(this,"SeparatorPad0", "Caption", "tooltip_CargoStation_Separatorline")
			Interface.AddComponent(this,"rebuildBuildRoad", "Button", "tooltip_CargoStation_Button_ReBuildRoad")
			Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_CargoStation_Button_FloorType")
			Interface.AddComponent(this,"toggleStationSubType", "Button", "tooltip_CargoStation_Button_SubType","tooltip_CargoStation_Button_"..CargoStationColour[this.SubType],"X")
			Interface.AddComponent(this,"toggleStationHeight", "Button", "tooltip_CargoStation_Button_StationHeight","tooltip_CargoStation_Button_"..this.StationHeight,"X")
			Interface.AddComponent(this,"toggleLights", "Button", "tooltip_CargoStation_Button_ToggleLights")
			Interface.AddComponent(this,"RemoveStack", "Button", "tooltip_CargoStation_Button_DeleteStack")
			Interface.AddComponent(this,"SeparatorPad1", "Caption", "tooltip_CargoStation_Separatorline")
			Interface.AddComponent(this,"toggleCargoSide", "Button", "tooltip_CargoStation_Button_CargoSide","tooltip_CargoStation_Button_"..this.CargoSide,"X")
			Interface.AddComponent(this,"toggleCargoType", "Button", "tooltip_CargoStation_Button_CargoType","tooltip_CargoStation_Button_"..MyCargoStopSign.CargoType,"X")
			Interface.AddComponent(this,"toggleTraffic", "Button", "tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..MyCargoStopSign.TrafficEnabled,"X")
			if MyCargoStopSign.CargoType == "Deliveries" then
				Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoStation_SeparatorlineCARGO")
				Interface.AddComponent(this,"toggleFoodDelivery", "Button", "tooltip_CargoStation_Button_FoodDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.FoodDelivery,"X")
				Interface.AddComponent(this,"toggleVendingDelivery", "Button", "tooltip_CargoStation_Button_VendingDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.VendingDelivery,"X")
				Interface.AddComponent(this,"toggleBuildingDelivery", "Button", "tooltip_CargoStation_Button_BuildingDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.BuildingDelivery,"X")
				Interface.AddComponent(this,"toggleFloorsDelivery", "Button", "tooltip_CargoStation_Button_FloorsDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.FloorDelivery,"X")
				Interface.AddComponent(this,"toggleLaundryDelivery", "Button", "tooltip_CargoStation_Button_LaundryDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.LaundryDelivery,"X")
				Interface.AddComponent(this,"toggleForestDelivery", "Button", "tooltip_CargoStation_Button_ForestDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.ForestDelivery,"X")
				Interface.AddComponent(this,"toggleWorkshop1Delivery", "Button", "tooltip_CargoStation_Button_Workshop1Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop1Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop2Delivery", "Button", "tooltip_CargoStation_Button_Workshop2Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop2Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop3Delivery", "Button", "tooltip_CargoStation_Button_Workshop3Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop3Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop4Delivery", "Button", "tooltip_CargoStation_Button_Workshop4Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop4Delivery,"X")
				Interface.AddComponent(this,"toggleWorkshop5Delivery", "Button", "tooltip_CargoStation_Button_Workshop5Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop5Delivery,"X")
				Interface.AddComponent(this,"toggleOtherDelivery", "Button", "tooltip_CargoStation_Button_OtherDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.OtherDelivery,"X")
			elseif MyCargoStopSign.CargoType == "Exports" then
				Interface.AddComponent(this,"toggleRecycling", "Button", "tooltip_CargoStation_Button_RecyclingArea", "tooltip_CargoStation_Button_"..this.RecyclingArea,"X")
			elseif MyCargoStopSign.CargoType == "Intake" then
				Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoStation_Separatorline")
				Interface.AddComponent(this,"toggleSecLevel1", "Button", "tooltip_CargoStation_Button_SecLevel1","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeMinSec,"X")
				Interface.AddComponent(this,"toggleSecLevel2", "Button", "tooltip_CargoStation_Button_SecLevel2","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeNormal,"X")
				Interface.AddComponent(this,"toggleSecLevel3", "Button", "tooltip_CargoStation_Button_SecLevel3","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeMaxSec,"X")
				Interface.AddComponent(this,"toggleSecLevel4", "Button", "tooltip_CargoStation_Button_SecLevel4","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeProtected,"X")
				Interface.AddComponent(this,"toggleSecLevel5", "Button", "tooltip_CargoStation_Button_SecLevel5","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeSuperMax,"X")
				Interface.AddComponent(this,"toggleSecLevel6", "Button", "tooltip_CargoStation_Button_SecLevel6","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeDeathRow,"X")
				Interface.AddComponent(this,"toggleSecLevel7", "Button", "tooltip_CargoStation_Button_SecLevel7","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeInsane,"X")
				Interface.AddComponent(this,"toggleIsIntake", "Button", "tooltip_CargoStation_Button_IsIntake","tooltip_CargoStation_Button_"..MyCargoStopSign.IsIntake,"X")
			elseif MyCargoStopSign.CargoType == "Emergency" then
				FindSomeEquipmentNumbers()
				Interface.AddComponent(this,"SeparatorEquipment", "Caption", "tooltip_CargoStation_SeparatorEquipment")
				Interface.AddComponent(this,"toggleEquipmentArmedGuard", "Button", "tooltip_CargoStation_Button_CalloutEquipmentArmedGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["ArmedGuard"][MyCargoStopSign.EquipmentArmedGuardNr],"X")
				Interface.AddComponent(this,"toggleEquipmentFireman", "Button", "tooltip_CargoStation_Button_CalloutEquipmentFireman","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Fireman"][MyCargoStopSign.EquipmentFiremanNr],"X")
				Interface.AddComponent(this,"toggleEquipmentRiotGuard", "Button", "tooltip_CargoStation_Button_CalloutEquipmentRiotGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["RiotGuard"][MyCargoStopSign.EquipmentRiotGuardNr],"X")
				Interface.AddComponent(this,"toggleEquipmentSoldier", "Button", "tooltip_CargoStation_Button_CalloutEquipmentSoldier","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Soldier"][MyCargoStopSign.EquipmentSoldierNr],"X")
			end
		else
			Interface.AddComponent(this,"DeleteStation", "Button", "tooltip_CargoStation_Button_Delete")
			Interface.AddComponent(this,"SeparatorOr", "Caption", "tooltip_CargoStation_Or")
			Interface.AddComponent(this,"BuildRoad", "Button", "tooltip_CargoStation_Button_BuildRoad")
		end
		timePerUpdate = 0.25
	end
	
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		if this.RoadMade == true and this.CargoFloor == "LARGE" then
			if not Exists(MyRoadMarkerRight) or not Exists(MyRoadMarkerLeft) then
				local OldLeftMarkerUID = this.LeftMarkerUID
				local OldRightMarkerUID = this.RightMarkerUID
				print("Old Left MarkerUID: "..OldLeftMarkerUID.."  OldRightMarkerUID: "..OldRightMarkerUID)
				FindMyRoadMarker()
				if OldLeftMarkerUID ~= this.LeftMarkerUID or OldRightMarkerUID ~= this.RightMarkerUID then
					print("Updating my Cargo Station objects with new MarkerUID...")
					for _, typ in pairs(CargoStationObjects) do
						local nearbyObjects = Find(this,typ,10000)
						for thatObject, _ in pairs(nearbyObjects) do
							if OldLeftMarkerUID ~= this.LeftMarkerUID and Get(thatObject,"MarkerUID") == OldLeftMarkerUID then
								print("Found "..thatObject.Type.." with old left MarkerUID "..OldLeftMarkerUID..", updating to MarkerUID "..this.LeftMarkerUID)
								Set(thatObject,"MarkerUID",this.LeftMarkerUID)
							elseif OldRightMarkerUID ~= this.RightMarkerUID and Get(thatObject,"MarkerUID") == OldRightMarkerUID then
								print("Found "..thatObject.Type.." with old right MarkerUID "..OldRightMarkerUID..", updating to MarkerUID "..this.RightMarkerUID)
								Set(thatObject,"MarkerUID",this.RightMarkerUID)
							end
						end
					end
				end
			end
			if World.NumCellsX ~= this.NumCellsX or World.NumCellsY ~= this.NumCellsY then
				print("map change detected")
				BuildMyRoad("CENTRE","DOUBLE",true)
				CreateStationFoundation("LEFT")
				UpdateInventoryPositions()
			end
			if MyCargoStopSign.Status == "TerminalRemoved" then DisableTraffic() end
		elseif this.RoadMade == true and this.CargoFloor == "COMPACT" then
			if not Exists(MyRoadMarker) then
				local OldMarkerUID = this.MarkerUID
				print("Old MarkerUID: "..OldMarkerUID)
				FindMyRoadMarker()
				if OldMarkerUID ~= this.MarkerUID then
					print("Updating my Cargo Station objects with new MarkerUID...")
					for _, typ in pairs(CargoStationObjects) do
						local nearbyObjects = Find(this,typ,10000)
						for thatObject, _ in pairs(nearbyObjects) do
							if Get(thatObject,"MarkerUID") == OldMarkerUID then
								print("Found "..thatObject.Type.." with old MarkerUID "..OldMarkerUID..", updating to MarkerUID "..this.MarkerUID)
								Set(thatObject,"MarkerUID",this.MarkerUID)
							end
						end
					end
				end
			end
			if World.NumCellsX ~= this.NumCellsX or World.NumCellsY ~= this.NumCellsY then
				print("map change detected")
				if this.CargoSide == "RIGHT" then
					BuildMyRoad("LEFT","SINGLE",true)
				else
					BuildMyRoad("RIGHT","SINGLE",true)
				end
				CreateStationFoundation(this.CargoSide)
				UpdateInventoryPositions()
			end
			if MyCargoStopSign.Status == "TerminalRemoved" then DisableTraffic() end
		end
	end
end

function rebuildBuildRoadClicked()
	if this.CargoFloor == "COMPACT" then
		if this.CargoSide == "RIGHT" then
			BuildMyRoad("LEFT","SINGLE",true)
		else
			BuildMyRoad("RIGHT","SINGLE",true)
		end
	else
		BuildMyRoad("CENTRE","DOUBLE",true)
	end
end

function toggleCargoSideClicked()
	if (Get(MyCargoStopSign,"InUse") == "no" and this.CargoFloor == "COMPACT") or this.CargoFloor == "LARGE" then
		if not Exists(MyCrane) then FindMyCrane(); FindMyHook(); FindMyLoadChecker(); FindMyIntakeDoor(); FindMyCargoControl() end
		if MyCargoStopSign.CargoType == "Deliveries" then
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
		elseif MyCargoStopSign.CargoType == "Exports" then
			Interface.RemoveComponent(this,"toggleRecycling")
		elseif MyCargoStopSign.CargoType == "Intake" then
			Interface.RemoveComponent(this,"SeparatorPad2")
			Interface.RemoveComponent(this,"toggleSecLevel1")
			Interface.RemoveComponent(this,"toggleSecLevel2")
			Interface.RemoveComponent(this,"toggleSecLevel3")
			Interface.RemoveComponent(this,"toggleSecLevel4")
			Interface.RemoveComponent(this,"toggleSecLevel5")
			Interface.RemoveComponent(this,"toggleSecLevel6")
			Interface.RemoveComponent(this,"toggleSecLevel7")
			Interface.RemoveComponent(this,"toggleIsIntake")
		elseif MyCargoStopSign.CargoType == "Emergency" then
			Interface.RemoveComponent(this,"SeparatorEquipment")
			Interface.RemoveComponent(this,"toggleEquipmentArmedGuard")
			Interface.RemoveComponent(this,"toggleEquipmentFireman")
			Interface.RemoveComponent(this,"toggleEquipmentRiotGuard")
			Interface.RemoveComponent(this,"toggleEquipmentSoldier")
		end
		if this.CargoFloor == "LARGE" then
			if this.CargoSide == "LEFT" then
				MyCargoStopSign = MyCargoSignRight
				if Exists(MyCrane) then MyCrane = MyCraneRight end
				if Exists(MyHook) then MyHook = MyHookRight end
				if Exists(MyIntakeDoor) then MyIntakeDoor = MyIntakeDoorRight end
				if Exists(MyFireEquipment) then MyFireEquipment = MyFireEquipmentRight end
				if Exists(MyCargoControl) then MyCargoControl = MyCargoControlRight end
				if Exists(MyLoadChecker) then MyLoadChecker = MyLoadCheckerRight end
				Set(this,"CargoSide","RIGHT")
				Set(this,"StationHeight",this.StationHeightRight)
				Set(this,"RecyclingArea",this.RecyclingAreaRight)
			else
				MyCargoStopSign = MyCargoSignLeft
				if Exists(MyCrane) then MyCrane = MyCraneLeft end
				if Exists(MyHook) then MyHook = MyHookLeft end
				if Exists(MyIntakeDoor) then MyIntakeDoor = MyIntakeDoorLeft end
				if Exists(MyFireEquipment) then MyFireEquipment = MyFireEquipmentLeft end
				if Exists(MyCargoControl) then MyCargoControl = MyCargoControlLeft end
				if Exists(MyLoadChecker) then MyLoadChecker = MyLoadCheckerLeft end
				Set(this,"CargoSide","LEFT")
				Set(this,"StationHeight",this.StationHeightLeft)
				Set(this,"RecyclingArea",this.RecyclingAreaLeft)
			end
		else
			RemoveStackClicked()
			-- RemoveLoaders()
			RemoveFloor()
			if this.RecyclingArea == "yes" then
				toggleRecyclingClicked()
			end
			if this.CargoSide == "LEFT" then
				this.Pos.x = this.Pos.x+3
				Set(this,"CargoSide","RIGHT")
				Set(this,"LightsOnRIGHT",this.LightsOnLEFT)
				this.SubType = CargoStationsSmallRight[MyCargoStopSign.CargoType]
				if this.CargoFloor == "COMPACT" then UndoLeftPossible = nil; Set(this,"StationHeight","COMPACT"); CreateStationFoundation(this.CargoSide) end
			else
				this.Pos.x = this.Pos.x-3
				Set(this,"CargoSide","LEFT")
				Set(this,"LightsOnLEFT",this.LightsOnRIGHT)
				this.SubType = CargoStationsSmallLeft[MyCargoStopSign.CargoType]
				if this.CargoFloor == "COMPACT" then UndoRightPossible = nil; Set(this,"StationHeight","COMPACT"); CreateStationFoundation(this.CargoSide) end
			end
			this.SetInterfaceCaption("toggleStationSubType","tooltip_CargoStation_Button_SubType","tooltip_CargoStation_Button_"..CargoStationColour[this.SubType],"X")
			ToggleCargoFloor(MyCargoStopSign.CargoType,this.CargoSide)
			UpdateInventoryPositions()
		end
		this.SetInterfaceCaption("toggleStationHeight","tooltip_CargoStation_Button_StationHeight","tooltip_CargoStation_Button_"..this.StationHeight,"X")
		this.SetInterfaceCaption("toggleCargoSide", "tooltip_CargoStation_Button_CargoSide","tooltip_CargoStation_Button_"..this.CargoSide,"X")
		this.SetInterfaceCaption("toggleCargoType", "tooltip_CargoStation_Button_CargoType","tooltip_CargoStation_Button_"..MyCargoStopSign.CargoType,"X")
		this.SetInterfaceCaption("toggleTraffic", "tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..MyCargoStopSign.TrafficEnabled,"X")
		if MyCargoStopSign.CargoType == "Deliveries" then
			Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoStation_SeparatorlineCARGO")
			Interface.AddComponent(this,"toggleFoodDelivery", "Button", "tooltip_CargoStation_Button_FoodDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.FoodDelivery,"X")
			Interface.AddComponent(this,"toggleVendingDelivery", "Button", "tooltip_CargoStation_Button_VendingDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.VendingDelivery,"X")
			Interface.AddComponent(this,"toggleBuildingDelivery", "Button", "tooltip_CargoStation_Button_BuildingDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.BuildingDelivery,"X")
			Interface.AddComponent(this,"toggleFloorsDelivery", "Button", "tooltip_CargoStation_Button_FloorsDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.FloorDelivery,"X")
			Interface.AddComponent(this,"toggleLaundryDelivery", "Button", "tooltip_CargoStation_Button_LaundryDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.LaundryDelivery,"X")
			Interface.AddComponent(this,"toggleForestDelivery", "Button", "tooltip_CargoStation_Button_ForestDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.ForestDelivery,"X")
			Interface.AddComponent(this,"toggleWorkshop1Delivery", "Button", "tooltip_CargoStation_Button_Workshop1Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop1Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop2Delivery", "Button", "tooltip_CargoStation_Button_Workshop2Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop2Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop3Delivery", "Button", "tooltip_CargoStation_Button_Workshop3Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop3Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop4Delivery", "Button", "tooltip_CargoStation_Button_Workshop4Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop4Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop5Delivery", "Button", "tooltip_CargoStation_Button_Workshop5Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop5Delivery,"X")
			Interface.AddComponent(this,"toggleOtherDelivery", "Button", "tooltip_CargoStation_Button_OtherDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.OtherDelivery,"X")
		elseif MyCargoStopSign.CargoType == "Exports" then
			Interface.AddComponent(this,"toggleRecycling", "Button", "tooltip_CargoStation_Button_RecyclingArea", "tooltip_CargoStation_Button_"..this.RecyclingArea,"X")
		elseif MyCargoStopSign.CargoType == "Intake" then
			Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoStation_Separatorline")
			Interface.AddComponent(this,"toggleSecLevel1", "Button", "tooltip_CargoStation_Button_SecLevel1","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeMinSec,"X")
			Interface.AddComponent(this,"toggleSecLevel2", "Button", "tooltip_CargoStation_Button_SecLevel2","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeNormal,"X")
			Interface.AddComponent(this,"toggleSecLevel3", "Button", "tooltip_CargoStation_Button_SecLevel3","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeMaxSec,"X")
			Interface.AddComponent(this,"toggleSecLevel4", "Button", "tooltip_CargoStation_Button_SecLevel4","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeProtected,"X")
			Interface.AddComponent(this,"toggleSecLevel5", "Button", "tooltip_CargoStation_Button_SecLevel5","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeSuperMax,"X")
			Interface.AddComponent(this,"toggleSecLevel6", "Button", "tooltip_CargoStation_Button_SecLevel6","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeDeathRow,"X")
			Interface.AddComponent(this,"toggleSecLevel7", "Button", "tooltip_CargoStation_Button_SecLevel7","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeInsane,"X")
			Interface.AddComponent(this,"toggleIsIntake", "Button", "tooltip_CargoStation_Button_IsIntake","tooltip_CargoStation_Button_"..MyCargoStopSign.IsIntake,"X")
		elseif MyCargoStopSign.CargoType == "Emergency" then
			if EquipmentNumbers["Fireman"][1] == 0 then FindSomeEquipmentNumbers() end
			Interface.AddComponent(this,"SeparatorEquipment", "Caption", "tooltip_CargoStation_SeparatorEquipment")
			Interface.AddComponent(this,"toggleEquipmentArmedGuard", "Button", "tooltip_CargoStation_Button_CalloutEquipmentArmedGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["ArmedGuard"][MyCargoStopSign.EquipmentArmedGuardNr],"X")
			Interface.AddComponent(this,"toggleEquipmentFireman", "Button", "tooltip_CargoStation_Button_CalloutEquipmentFireman","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Fireman"][MyCargoStopSign.EquipmentFiremanNr],"X")
			Interface.AddComponent(this,"toggleEquipmentRiotGuard", "Button", "tooltip_CargoStation_Button_CalloutEquipmentRiotGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["RiotGuard"][MyCargoStopSign.EquipmentRiotGuardNr],"X")
			Interface.AddComponent(this,"toggleEquipmentSoldier", "Button", "tooltip_CargoStation_Button_CalloutEquipmentSoldier","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Soldier"][MyCargoStopSign.EquipmentSoldierNr],"X")
		end
		UpdateTooltip()
		this.Sound("_Deployment","SetNone")
	end
end

function toggleCargoTypeClicked()
	RemoveStackClicked()
	-- RemoveLoaders()
	if Get(MyCargoStopSign,"InUse") == "no" then
		if Get(MyCargoStopSign,"CargoType") == "Deliveries" then
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
			Interface.AddComponent(this,"toggleRecycling", "Button", "tooltip_CargoStation_Button_RecyclingArea", "tooltip_CargoStation_Button_"..this.RecyclingArea,"X")
			Set(MyCargoStopSign,"CargoType","Exports")
			Set(MyCargoStopSign,"LoadAvailable",false)
		elseif Get(MyCargoStopSign,"CargoType") == "Exports" then
			if Get(this,"Recycling"..this.CargoSide) == true then
				RemoveRecycling(this.CargoSide)
			end
			Interface.RemoveComponent(this,"toggleRecycling")
			Set(MyCargoStopSign,"CargoType","Garbage")
			Set(MyCargoStopSign,"LoadAvailable",false)
		elseif Get(MyCargoStopSign,"CargoType") == "Garbage" then
			if not Exists(MyCrane) then FindMyCrane(); FindMyHook(); FindMyCargoControl() end
			MyCrane.Delete()
			MyHook.Delete()
			MyCargoControl.SubType = 8
			if this.CargoFloor == "LARGE" then
				if this.CargoSide == "LEFT" then
					MyIntakeDoorLeft = Object.Spawn("JailDoorLarge",this.Pos.x-7,this.Pos.y-0.5)
					MyIntakeDoorLeft.Or.x = 1
					MyIntakeDoorLeft.Or.y = 0
					MyIntakeDoorLeft.OpenDir.x = 0
					MyIntakeDoorLeft.OpenDir.y = 2
					MyIntakeDoorLeft.MarkerUID = this.LeftMarkerUID
					MyIntakeDoorLeft.HomeUID = this.HomeUID
					
					MyIntakeDoor = MyIntakeDoorLeft
				else
					MyIntakeDoorRight = Object.Spawn("JailDoorLarge",this.Pos.x+7,this.Pos.y-0.5)
					MyIntakeDoorRight.Or.x = 1
					MyIntakeDoorRight.Or.y = 0
					MyIntakeDoorRight.OpenDir.x = 0
					MyIntakeDoorRight.OpenDir.y = 2
					MyIntakeDoorRight.MarkerUID = this.RightMarkerUID
					MyIntakeDoorRight.HomeUID = this.HomeUID
					
					MyIntakeDoor = MyIntakeDoorRight
				end
			else
				local DoorPosX = this.Pos.x-4
				if this.CargoSide == "RIGHT" then DoorPosX = this.Pos.x+4 end
				MyIntakeDoor = Object.Spawn("JailDoorLarge",DoorPosX,this.Pos.y-0.5)
				MyIntakeDoor.Or.x = 1
				MyIntakeDoor.Or.y = 0
				MyIntakeDoor.OpenDir.x = 0
				MyIntakeDoor.OpenDir.y = 2
				MyIntakeDoor.MarkerUID = this.MarkerUID
				MyIntakeDoor.HomeUID = this.HomeUID
			end	
			Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoStation_Separatorline")
			Interface.AddComponent(this,"toggleSecLevel1", "Button", "tooltip_CargoStation_Button_SecLevel1","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeMinSec,"X")
			Interface.AddComponent(this,"toggleSecLevel2", "Button", "tooltip_CargoStation_Button_SecLevel2","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeNormal,"X")
			Interface.AddComponent(this,"toggleSecLevel3", "Button", "tooltip_CargoStation_Button_SecLevel3","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeMaxSec,"X")
			Interface.AddComponent(this,"toggleSecLevel4", "Button", "tooltip_CargoStation_Button_SecLevel4","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeProtected,"X")
			Interface.AddComponent(this,"toggleSecLevel5", "Button", "tooltip_CargoStation_Button_SecLevel5","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeSuperMax,"X")
			Interface.AddComponent(this,"toggleSecLevel6", "Button", "tooltip_CargoStation_Button_SecLevel6","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeDeathRow,"X")
			Interface.AddComponent(this,"toggleSecLevel7", "Button", "tooltip_CargoStation_Button_SecLevel7","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.IntakeInsane,"X")
			Interface.AddComponent(this,"toggleIsIntake", "Button", "tooltip_CargoStation_Button_IsIntake","tooltip_CargoStation_Button_"..MyCargoStopSign.IsIntake,"X")
			Set(MyCargoStopSign,"CargoType","Intake")
		elseif Get(MyCargoStopSign,"CargoType") == "Intake" then
			if not Exists(MyIntakeDoor) then FindMyIntakeDoor() end
			if Exists(MyIntakeDoor) then MyIntakeDoor.Delete() end
			if not Exists(MyCargoControl) then FindMyCargoControl() end
			MyCargoControl.SubType = 19
			
			if this.CargoFloor == "LARGE" then
				if this.CargoSide == "LEFT" then
					MyCraneLeft = Object.Spawn("CargoStationGantryCrane",this.Pos.x-1.5,this.Pos.y-4)
					MyCraneLeft.MarkerUID = this.LeftMarkerUID
					MyCraneLeft.HomeUID = this.HomeUID
					MyCraneLeft.CargoStationID = MyCargoControl.CargoStationID
		
					MyHookLeft = Object.Spawn("CargoStationGantryHook",this.Pos.x-1.5,this.Pos.y-2)
					MyHookLeft.MarkerUID = this.LeftMarkerUID
					MyHookLeft.HomeUID = this.HomeUID
					MyHookLeft.CargoStationID = MyCargoControl.CargoStationID
					MyHookLeft.SubType = 3
									
					MyFireEquipmentLeft = Object.Spawn("CargoStationFireEngine",this.Pos.x-5,this.Pos.y-3.5)
					MyFireEquipmentLeft.MarkerUID = this.LeftMarkerUID
					MyFireEquipmentLeft.HomeUID = this.HomeUID
					MyFireEquipmentLeft.CargoStationID = MyCargoControl.CargoStationID
					
					MyCrane = MyCraneLeft
					MyHook = MyHookLeft
					MyFireEquipment = MyFireEquipmentLeft
				else
					MyCraneRight = Object.Spawn("CargoStationGantryCrane",this.Pos.x+1.5,this.Pos.y-4)
					MyCraneRight.MarkerUID = this.RightMarkerUID
					MyCraneRight.HomeUID = this.HomeUID
					MyCraneRight.CargoStationID = MyCargoControl.CargoStationID
					
					MyHookRight = Object.Spawn("CargoStationGantryHook",this.Pos.x+1.5,this.Pos.y-2)
					MyHookRight.MarkerUID = this.RightMarkerUID
					MyHookRight.HomeUID = this.HomeUID
					MyHookRight.CargoStationID = MyCargoControl.CargoStationID
					MyHookRight.SubType = 3
										
					MyFireEquipmentRight = Object.Spawn("CargoStationFireEngine",this.Pos.x+5,this.Pos.y-3.5)
					MyFireEquipmentRight.SubType = 2
					MyFireEquipmentRight.MarkerUID = this.RightMarkerUID
					MyFireEquipmentRight.HomeUID = this.HomeUID
					MyFireEquipmentRight.CargoStationID = MyCargoControl.CargoStationID
					
					MyCrane = MyCraneRight
					MyHook = MyHookRight
					MyFireEquipment = MyFireEquipmentRight					
				end
			else
				local CranePosX,FireX,LoadX = this.Pos.x+1.5,this.Pos.x-2,this.Pos.x-2
				if this.CargoSide == "RIGHT" then CranePosX,FireX,LoadX = this.Pos.x-1.5,this.Pos.x+2,this.Pos.x+2 end
				MyCrane = Object.Spawn("CargoStationGantryCrane",CranePosX,this.Pos.y-4)
				MyCrane.MarkerUID = this.MarkerUID
				MyCrane.HomeUID = this.HomeUID
				MyCrane.CargoStationID = MyCargoControl.CargoStationID
				
				MyHook = Object.Spawn("CargoStationGantryHook",CranePosX,this.Pos.y-2)
				MyHook.MarkerUID = this.MarkerUID
				MyHook.HomeUID = this.HomeUID
				MyHook.CargoStationID = MyCargoControl.CargoStationID
				MyHook.SubType = 3
								
				MyFireEquipment = Object.Spawn("CargoStationFireEngine",FireX,this.Pos.y-3.5)
				if this.CargoSide == "RIGHT" then
					MyFireEquipment.SubType = 2
				end
				MyFireEquipment.MarkerUID = this.MarkerUID
				MyFireEquipment.HomeUID = this.HomeUID
				MyFireEquipment.CargoStationID = MyCargoControl.CargoStationID
			end
			Interface.RemoveComponent(this,"SeparatorPad2")
			-- Interface.RemoveComponent(this,"toggleSecLevel")
			Interface.RemoveComponent(this,"toggleSecLevel1")
			Interface.RemoveComponent(this,"toggleSecLevel2")
			Interface.RemoveComponent(this,"toggleSecLevel3")
			Interface.RemoveComponent(this,"toggleSecLevel4")
			Interface.RemoveComponent(this,"toggleSecLevel5")
			Interface.RemoveComponent(this,"toggleSecLevel6")
			Interface.RemoveComponent(this,"toggleSecLevel7")
			Interface.RemoveComponent(this,"toggleIsIntake")
			if EquipmentNumbers["Fireman"][1] == 0 then FindSomeEquipmentNumbers() end
			Interface.AddComponent(this,"SeparatorEquipment", "Caption", "tooltip_CargoStation_SeparatorEquipment")
			Interface.AddComponent(this,"toggleEquipmentArmedGuard", "Button", "tooltip_CargoStation_Button_CalloutEquipmentArmedGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["ArmedGuard"][MyCargoStopSign.EquipmentArmedGuardNr],"X")
			Interface.AddComponent(this,"toggleEquipmentFireman", "Button", "tooltip_CargoStation_Button_CalloutEquipmentFireman","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Fireman"][MyCargoStopSign.EquipmentFiremanNr],"X")
			Interface.AddComponent(this,"toggleEquipmentRiotGuard", "Button", "tooltip_CargoStation_Button_CalloutEquipmentRiotGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["RiotGuard"][MyCargoStopSign.EquipmentRiotGuardNr],"X")
			Interface.AddComponent(this,"toggleEquipmentSoldier", "Button", "tooltip_CargoStation_Button_CalloutEquipmentSoldier","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Soldier"][MyCargoStopSign.EquipmentSoldierNr],"X")
			Set(MyCargoStopSign,"CargoType","Emergency")
			Set(MyCargoStopSign,"LoadAvailable",false)
		elseif Get(MyCargoStopSign,"CargoType") == "Emergency" then
			Interface.RemoveComponent(this,"SeparatorEquipment")
			Interface.RemoveComponent(this,"toggleEquipmentArmedGuard")
			Interface.RemoveComponent(this,"toggleEquipmentFireman")
			Interface.RemoveComponent(this,"toggleEquipmentRiotGuard")
			Interface.RemoveComponent(this,"toggleEquipmentSoldier")
			if not Exists(MyCargoControl) then FindMyCargoControl() end
			if not Exists(MyHook) then FindMyHook() end
			if not Exists(MyFireEquipment) then FindMyFireEquipment() end
			MyFireEquipment.Delete()
			Set(MyCargoStopSign,"WaitForFiremen",false)
			MyCargoControl.SubType = 0
			MyHook.SubType = 0
			Set(MyCargoStopSign,"FoodQuantity",0)
			Set(MyCargoStopSign,"VendingQuantity",0)
			Set(MyCargoStopSign,"BuildingQuantity",0)
			Set(MyCargoStopSign,"FloorQuantity",0)
			Set(MyCargoStopSign,"ForestQuantity",0)
			Set(MyCargoStopSign,"LaundryQuantity",0)
			Set(MyCargoStopSign,"Workshop1Quantity",0)
			Set(MyCargoStopSign,"Workshop2Quantity",0)
			Set(MyCargoStopSign,"Workshop3Quantity",0)
			Set(MyCargoStopSign,"Workshop4Quantity",0)
			Set(MyCargoStopSign,"Workshop5Quantity",0)
			Set(MyCargoStopSign,"OtherQuantity",0)
			Set(MyCargoStopSign,"AllQuantity",0)
			Set(MyCargoStopSign,"InUse","no")
			Set(MyCargoStopSign,"VehicleSpawned","no")
			Set(MyCargoStopSign,"Status","Waiting...")
			
			Interface.AddComponent(this,"SeparatorPad2", "Caption", "tooltip_CargoStation_SeparatorlineCARGO")
			Interface.AddComponent(this,"toggleFoodDelivery", "Button", "tooltip_CargoStation_Button_FoodDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.FoodDelivery,"X")
			Interface.AddComponent(this,"toggleVendingDelivery", "Button", "tooltip_CargoStation_Button_VendingDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.VendingDelivery,"X")
			Interface.AddComponent(this,"toggleBuildingDelivery", "Button", "tooltip_CargoStation_Button_BuildingDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.BuildingDelivery,"X")
			Interface.AddComponent(this,"toggleFloorsDelivery", "Button", "tooltip_CargoStation_Button_FloorsDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.FloorDelivery,"X")
			Interface.AddComponent(this,"toggleLaundryDelivery", "Button", "tooltip_CargoStation_Button_LaundryDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.LaundryDelivery,"X")
			Interface.AddComponent(this,"toggleForestDelivery", "Button", "tooltip_CargoStation_Button_ForestDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.ForestDelivery,"X")
			Interface.AddComponent(this,"toggleWorkshop1Delivery", "Button", "tooltip_CargoStation_Button_Workshop1Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop1Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop2Delivery", "Button", "tooltip_CargoStation_Button_Workshop2Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop2Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop3Delivery", "Button", "tooltip_CargoStation_Button_Workshop3Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop3Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop4Delivery", "Button", "tooltip_CargoStation_Button_Workshop4Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop4Delivery,"X")
			Interface.AddComponent(this,"toggleWorkshop5Delivery", "Button", "tooltip_CargoStation_Button_Workshop5Delivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.Workshop5Delivery,"X")
			Interface.AddComponent(this,"toggleOtherDelivery", "Button", "tooltip_CargoStation_Button_OtherDelivery","tooltip_CargoStation_Button_Delivery_"..MyCargoStopSign.OtherDelivery,"X")
			Set(MyCargoStopSign,"CargoType","Deliveries")
		end
		if Get(MyCargoStopSign,"TrafficEnabled") == "yes" then
			MyCargoStopSign.SubType = StopSignTypes[MyCargoStopSign.CargoType]
		end
		ToggleCargoFloor(MyCargoStopSign.CargoType,this.CargoSide)
		if this.CargoFloor == "LARGE" then
			this.SubType = CargoStationsLarge[MyCargoStopSign.CargoType]
		else
			if this.CargoSide == "RIGHT" then
				this.SubType = CargoStationsSmallRight[MyCargoStopSign.CargoType]
			else
				this.SubType = CargoStationsSmallLeft[MyCargoStopSign.CargoType]
			end
		end
		this.SetInterfaceCaption("toggleStationSubType","tooltip_CargoStation_Button_SubType","tooltip_CargoStation_Button_"..CargoStationColour[this.SubType],"X")
		this.SetInterfaceCaption("toggleCargoType","tooltip_CargoStation_Button_CargoType","tooltip_CargoStation_Button_"..MyCargoStopSign.CargoType,"X")
		
		UpdateTooltip()
		this.Sound("_Deployment","SetNone")
	end
end

function toggleTrafficClicked()
	if Get(MyCargoStopSign,"InUse") == "no" and Get(MyCargoStopSign,"Number") > 0 then
		if Get(MyCargoStopSign,"TrafficEnabled") == "no" then
			RemoveWallLights(this.CargoSide)
			MakeWallLights(this.CargoSide)
			Set(this,"LightsOn"..this.CargoSide,true)
			Set(MyCargoStopSign,"TrafficEnabled","yes")
			Set(MyCargoStopSign,"Status","Waiting...")
			MyCargoStopSign.SubType = StopSignTypes[MyCargoStopSign.CargoType]
			if this.CargoFloor == "COMPACT" then
				if not this.GrantCheckerSpawned then
					local GrantChecker = Object.Spawn("GrantChecker"..MyCargoStopSign.CargoType,this.Pos.x-0.5,this.Pos.y+2)
				end
			else
				if this.CargoSide == "LEFT" and not this.GrantCheckerLeftSpawned then
					local GrantChecker = Object.Spawn("GrantChecker"..MyCargoStopSign.CargoType,this.Pos.x-0.5,this.Pos.y+2)
				elseif this.CargoSide == "RIGHT" and not this.GrantCheckerRightSpawned then
					local GrantChecker = Object.Spawn("GrantChecker"..MyCargoStopSign.CargoType,this.Pos.x-0.5,this.Pos.y+2)
				end
			end
		else
			RemoveStackClicked()
			-- RemoveLoaders()
			RemoveWallLights(this.CargoSide)
			Set(this,"LightsOn"..this.CargoSide,nil)
			Set(MyCargoStopSign,"TrafficEnabled","no")
			Set(MyCargoStopSign,"Status","DISABLED")
			MyCargoStopSign.SubType = 5
		end
		UpdateTooltip()
		this.Sound("_Deployment","SetNone")
		this.SetInterfaceCaption("toggleTraffic","tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..MyCargoStopSign.TrafficEnabled,"X")
	end
end

function DisableTraffic()
	RemoveStackClicked()
	-- RemoveLoaders()
	RemoveWallLights(this.CargoSide)
	Set(this,"LightsOn"..this.CargoSide,nil)
	Set(MyCargoStopSign,"TrafficEnabled","no")
	Set(MyCargoStopSign,"Status","DISABLED")
	MyCargoStopSign.SubType = 5
	UpdateTooltip()
	this.SetInterfaceCaption("toggleTraffic","tooltip_CargoStation_Button_TrafficEnabled","tooltip_CargoStation_Button_"..MyCargoStopSign.TrafficEnabled,"X")
end

function ToggleYesNo(property,var)
	local Property = Get(MyCargoStopSign,property)
	if Property == "yes" then Property = "no" else Property = "yes" end
	Set(MyCargoStopSign,property,Property)
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

function toggleEquipmentFiremanClicked()
	MyCargoStopSign.EquipmentFiremanNr = MyCargoStopSign.EquipmentFiremanNr + 1
	if EquipmentTypes["Fireman"][MyCargoStopSign.EquipmentFiremanNr] == nil then
		MyCargoStopSign.EquipmentFiremanNr = 1
	end
	Set(MyCargoStopSign,"EquipmentFireman",EquipmentNumbers["Fireman"][MyCargoStopSign.EquipmentFiremanNr])
	CalloutEquipment = EquipmentTypes["Fireman"][MyCargoStopSign.EquipmentFiremanNr]
	print(CalloutEquipment.." (number: "..MyCargoStopSign.EquipmentFireman..")")
	this.SetInterfaceCaption("toggleEquipmentFireman", "tooltip_CargoStation_Button_CalloutEquipmentFireman","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Fireman"][MyCargoStopSign.EquipmentFiremanNr],"X")
end

function toggleEquipmentArmedGuardClicked()
	MyCargoStopSign.EquipmentArmedGuardNr = MyCargoStopSign.EquipmentArmedGuardNr + 1
	if EquipmentTypes["ArmedGuard"][MyCargoStopSign.EquipmentArmedGuardNr] == nil then
		MyCargoStopSign.EquipmentArmedGuardNr = 1
	end
	Set(MyCargoStopSign,"EquipmentArmedGuard",EquipmentNumbers["ArmedGuard"][MyCargoStopSign.EquipmentArmedGuardNr])
	CalloutEquipment = EquipmentTypes["ArmedGuard"][MyCargoStopSign.EquipmentArmedGuardNr]
	print(CalloutEquipment.." (number: "..MyCargoStopSign.EquipmentArmedGuard..")")
	this.SetInterfaceCaption("toggleEquipmentArmedGuard", "tooltip_CargoStation_Button_CalloutEquipmentArmedGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["ArmedGuard"][MyCargoStopSign.EquipmentArmedGuardNr],"X")
end

function toggleEquipmentRiotGuardClicked()
	MyCargoStopSign.EquipmentRiotGuardNr = MyCargoStopSign.EquipmentRiotGuardNr + 1
	if EquipmentTypes["RiotGuard"][MyCargoStopSign.EquipmentRiotGuardNr] == nil then
		MyCargoStopSign.EquipmentRiotGuardNr = 1
	end
	Set(MyCargoStopSign,"EquipmentRiotGuard",EquipmentNumbers["RiotGuard"][MyCargoStopSign.EquipmentRiotGuardNr])
	CalloutEquipment = EquipmentTypes["RiotGuard"][MyCargoStopSign.EquipmentRiotGuardNr]
	print(CalloutEquipment.." (number: "..MyCargoStopSign.EquipmentRiotGuard..")")
	this.SetInterfaceCaption("toggleEquipmentRiotGuard", "tooltip_CargoStation_Button_CalloutEquipmentRiotGuard","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["RiotGuard"][MyCargoStopSign.EquipmentRiotGuardNr],"X")
end

function toggleEquipmentSoldierClicked()
	MyCargoStopSign.EquipmentSoldierNr = MyCargoStopSign.EquipmentSoldierNr + 1
	if EquipmentTypes["Soldier"][MyCargoStopSign.EquipmentSoldierNr] == nil then
		MyCargoStopSign.EquipmentSoldierNr = 1
	end
	Set(MyCargoStopSign,"EquipmentSoldier",EquipmentNumbers["Soldier"][MyCargoStopSign.EquipmentSoldierNr])
	CalloutEquipment = EquipmentTypes["Soldier"][MyCargoStopSign.EquipmentSoldierNr]
	print(CalloutEquipment.." (number: "..MyCargoStopSign.EquipmentSoldier..")")
	this.SetInterfaceCaption("toggleEquipmentSoldier", "tooltip_CargoStation_Button_CalloutEquipmentSoldier","tooltip_CargoStation_CalloutEquipment_"..EquipmentTypes["Soldier"][MyCargoStopSign.EquipmentSoldierNr],"X")
end


function FindSomeEquipmentNumbers()
	local TestEntity = Object.Spawn("IntakeChinookPilot",this.Pos.x,this.Pos.y)
	for e = 0,1000 do
		TestEntity.Equipment = e
		if TestEntity.Equipment == "Extinguisher" then
			EquipmentNumbers["Fireman"][1] = e
			hoseFound = true
		end
		if TestEntity.Equipment == "AK47" then
			EquipmentNumbers["ArmedGuard"][3] = e
			EquipmentNumbers["RiotGuard"][3] = e
			EquipmentNumbers["Soldier"][3] = e
			EquipmentNumbers["EliteOps"][3] = e
			akFound = true
		end
		if hoseFound and syringeFound and akFound then break end
	end
	TestEntity.Delete()
end

function toggleLightsClicked()
	if Get(this,"LightsOn"..this.CargoSide) == true then
		RemoveWallLights(this.CargoSide)
		Set(this,"LightsOn"..this.CargoSide,nil)
	else
		RemoveWallLights(this.CargoSide)
		MakeWallLights(this.CargoSide)
		Set(this,"LightsOn"..this.CargoSide,true)
	end
	this.Sound("_Deployment","SetNone")
end

function toggleStationSubTypeClicked()
	if this.CargoFloor == "LARGE" then
		if this.SubType == 0 then
			this.SubType = 1
		elseif this.SubType == 1 then
			this.SubType = 2
		elseif this.SubType == 2 then
			this.SubType = 3
		elseif this.SubType == 3 then
			this.SubType = 4
		elseif this.SubType == 4 then
			this.SubType = 0
		end
	else
		if this.CargoSide == "RIGHT" then
			if this.SubType == 10 then
				this.SubType = 11
			elseif this.SubType == 11 then
				this.SubType = 12
			elseif this.SubType == 12 then
				this.SubType = 13
			elseif this.SubType == 13 then
				this.SubType = 14
			else
				this.SubType = 10
			end
		else
			if this.SubType == 5 then
				this.SubType = 6
			elseif this.SubType == 6 then
				this.SubType = 7
			elseif this.SubType == 7 then
				this.SubType = 8
			elseif this.SubType == 8 then
				this.SubType = 9
			else
				this.SubType = 5
			end
		end
	end
	this.SetInterfaceCaption("toggleStationSubType","tooltip_CargoStation_Button_SubType","tooltip_CargoStation_Button_"..CargoStationColour[this.SubType],"X")
	this.Sound("_Deployment","SetNone")
end

function toggleStationHeightClicked()
	if this.StationHeight == "COMPACT" then
		Set(this,"StationHeight","TALL")
	else
		Set(this,"StationHeight","COMPACT")
		if this.RecyclingArea == "yes" then
			toggleRecyclingClicked()
		end
		this.SetInterfaceCaption("toggleRecycling","tooltip_CargoStation_Button_RecyclingArea","tooltip_CargoStation_Button_"..this.RecyclingArea,"X")
	end
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "RIGHT" then
			Set(this,"StationHeightRight",this.StationHeight)
		else
			Set(this,"StationHeightLeft",this.StationHeight)
		end
	end
	ToggleStorageFoundation(this.CargoSide,MyCargoStopSign.CargoType)
	this.SetInterfaceCaption("toggleStationHeight","tooltip_CargoStation_Button_StationHeight","tooltip_CargoStation_Button_"..this.StationHeight,"X")
end

function toggleRecyclingClicked()
	if this.RecyclingArea == "no" then
		Set(this,"RecyclingArea","yes")
		MakeRecycling(this.CargoSide)
	else
		Set(this,"RecyclingArea","no")
		RemoveRecycling(this.CargoSide)
	end
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "RIGHT" then
			Set(this,"RecyclingAreaRight",this.RecyclingArea)
		else
			Set(this,"RecyclingAreaLeft",this.RecyclingArea)
		end
	end
	this.Sound("_Deployment","SetNone")
	this.SetInterfaceCaption("toggleRecycling","tooltip_CargoStation_Button_RecyclingArea","tooltip_CargoStation_Button_"..this.RecyclingArea,"X")
end

function MakeRecycling(theSide)
	if this.StationHeight == "COMPACT" then
		toggleStationHeightClicked()
	end
	-- for legacy Recycling and Recycling 3.0 mods
	local RecycleDeskX,RecycleDeskY = this.Pos.x-2,this.Pos.y-9
	local TableX,TableY = this.Pos.x-1,this.Pos.y-11.5
	local TrashBinX,TrashBinY = this.Pos.x-4,this.Pos.y-13
	local CompactorX,CompactorY = this.Pos.x-2,this.Pos.y-6
	local TableOrX,TableOrY = -1,0
	if this.CargoFloor == "LARGE" then
		if theSide == "RIGHT" then
			RecycleDeskX,RecycleDeskY = this.Pos.x+5,this.Pos.y-9
			TableX,TableY = this.Pos.x+4,this.Pos.y-11.5
			TrashBinX,TrashBinY = this.Pos.x+7,this.Pos.y-13
			CompactorX,CompactorY = this.Pos.x+5,this.Pos.y-6
			TableOrX,TableOrY = 1,0
		else
			RecycleDeskX,RecycleDeskY = this.Pos.x-5,this.Pos.y-9
			TableX,TableY = this.Pos.x-4,this.Pos.y-11.5
			TrashBinX,TrashBinY = this.Pos.x-7,this.Pos.y-13
			CompactorX,CompactorY = this.Pos.x-5,this.Pos.y-6
		end
	else
		if theSide == "RIGHT" then
			RecycleDeskX,RecycleDeskY = this.Pos.x+2,this.Pos.y-9
			TableX,TableY = this.Pos.x+1,this.Pos.y-11.5
			TrashBinX,TrashBinY = this.Pos.x+4,this.Pos.y-13
			CompactorX,CompactorY = this.Pos.x+2,this.Pos.y-6
			TableOrX,TableOrY = 1,0
		end
	end
	local newDesk = Object.Spawn("RecycleDesk",RecycleDeskX,RecycleDeskY)
	if Exists(newDesk) then
		Set(newDesk,"HomeUID",this.HomeUID)
		Set(newDesk,"SpawnTimer",0)
		Set(newDesk,"CargoStationID",this.Id.u)
		Set(newDesk,"CargoSide",this.CargoSide)
		local newFront = Object.Spawn("RecycleDeskFront",RecycleDeskX,RecycleDeskY+1)
		Set(newFront,"HomeUID",this.HomeUID)
		Set(newFront,"CargoStationID",this.Id.u)
		Set(newFront,"CargoSide",this.CargoSide)
		local newLogo = Object.Spawn("RecycleAnimation",RecycleDeskX,RecycleDeskY)
		Set(newLogo,"HomeUID",this.HomeUID)
		Set(newLogo,"CargoStationID",this.Id.u)
		Set(newLogo,"CargoSide",this.CargoSide)		
		local newTable = Object.Spawn("SmallGardenTable",TableX,TableY)
		newTable.Or.x,newTable.Or.y = TableOrX,TableOrY
		Set(newTable,"CargoStationID",this.Id.u)
		Set(newTable,"CargoSide",this.CargoSide)
		local newTrashBin = Object.Spawn("TrashBin10",TrashBinX,TrashBinY)
		Set(newTrashBin,"CargoStationID",this.Id.u)
		Set(newTrashBin,"CargoSide",this.CargoSide)
		local newTrashCompactor = Object.Spawn("TrashCompactor",CompactorX,CompactorY)
		Set(newTrashCompactor,"CargoStationID",this.Id.u)
		Set(newTrashCompactor,"CargoSide",this.CargoSide)
	else
		-- for Recycling 4.0 mod
		local RecycleDeskX,RecycleDeskY = this.Pos.x-1.5,this.Pos.y-9
		local TableX,TableY = this.Pos.x-4,this.Pos.y-11.5
		local TrashBinX,TrashBinY = this.Pos.x-1,this.Pos.y-12
		local CompactorX,CompactorY = this.Pos.x-1.5,this.Pos.y-6
		local RecycleDeskOrX,RecycleDeskOrY = 1,0
		local TableOrX,TableOrY =  1,0
		local BinOrX,BinOrY = -1,0
		if this.CargoFloor == "LARGE" then
			if theSide == "RIGHT" then
				RecycleDeskX,RecycleDeskY = this.Pos.x+4.5,this.Pos.y-9
				TableX,TableY = this.Pos.x+7,this.Pos.y-11.5
				TrashBinX,TrashBinY = this.Pos.x+4,this.Pos.y-12
				CompactorX,CompactorY =  this.Pos.x+4.5,this.Pos.y-6
				RecycleDeskOrX,RecycleDeskOrY = -1,0
				TableOrX,TableOrY = -1,0
				BinOrX,BinOrY = 1,0
			else
				RecycleDeskX,RecycleDeskY = this.Pos.x-4.5,this.Pos.y-9
				TableX,TableY = this.Pos.x-7,this.Pos.y-12.5
				TrashBinX,TrashBinY = this.Pos.x-4,this.Pos.y-12
				CompactorX,CompactorY = this.Pos.x-4.5,this.Pos.y-6
			end
		else
			if theSide == "RIGHT" then
				RecycleDeskX,RecycleDeskY = this.Pos.x+1.5,this.Pos.y-9
				TableX,TableY = this.Pos.x+4,this.Pos.y-11.5
				TrashBinX,TrashBinY = this.Pos.x+1,this.Pos.y-12
				CompactorX,CompactorY =  this.Pos.x+1.5,this.Pos.y-6
				RecycleDeskOrX,RecycleDeskOrY = -1,0
				TableOrX,TableOrY = -1,0
				BinOrX,BinOrY = 1,0
			end
		end
		local newDesk = Object.Spawn("R4_RecycleDeskVisible",RecycleDeskX,RecycleDeskY)
		if Exists(newDesk) then
			newDesk.Or.x,newDesk.Or.y = RecycleDeskOrX,RecycleDeskOrY
			Set(newDesk,"CargoStationID",this.Id.u)
			Set(newDesk,"CargoSide",this.CargoSide)
			local newTable = Object.Spawn("R4_RecycleTable",TableX,TableY)
			newTable.Or.x,newTable.Or.y = TableOrX,TableOrY
			Set(newTable,"CargoStationID",this.Id.u)
			Set(newTable,"CargoSide",this.CargoSide)
			local newTrashBin = Object.Spawn("R4_TrashBin",TrashBinX,TrashBinY)
			newTrashBin.Or.x,newTrashBin.Or.y = BinOrX,BinOrY
			Set(newTrashBin,"CargoStationID",this.Id.u)
			Set(newTrashBin,"CargoSide",this.CargoSide)
			local newTrashCompactor = Object.Spawn("R4_TrashCompactor",CompactorX,CompactorY)
			Set(newTrashCompactor,"CargoStationID",this.Id.u)
			Set(newTrashCompactor,"CargoSide",this.CargoSide)
		end
	end
end

function RemoveRecycling(theSide)
	local DeskUID = 0
	local RecyclingObjects = { "RecycleDesk", "RecycleDeskFront", "RecycleAnimation", "SmallGardenTable", "RecycleBin", "TrashBin10", "TrashBin20", "TrashBin30", "TrashCompactor",
							"R4_RecycleDeskVisible", "R4_RecycleTable", "R4_TrashBin", "R4_TrashCompactor"	}
	local found = false
	for _, typ in pairs(RecyclingObjects) do
		local nearbyObjects = Find(this,typ,15)
		for thatObject, _ in pairs(nearbyObjects) do
			if thatObject.Type == "RecycleDeskFront" and Get(thatObject,"HomeUID") == DeskUID then
				thatObject.Delete()
			elseif thatObject.Type == "R4_RecycleDeskVisible" and Get(thatObject,"DeskUID") == DeskUID then
				thatObject.Delete()
			elseif Get(thatObject,"CargoStationID") == this.Id.u and Get(thatObject,"CargoSide") == theSide then
				if thatObject.Type == "RecycleDesk" then
					DeskUID = Get(thatObject,"HomeUID")
				elseif thatObject.Type == "R4_RecycleDeskVisible" then
					DeskUID = Get(thatObject,"DeskUID")
				end
				thatObject.Delete()
			end
		end
	end
end

function UpdateTooltip()
	if this.CargoFloor == "COMPACT" then
		this.Tooltip = { "tooltip_CargoStation_Compact",this.HomeUID,"H",MyCargoStopSign.TrafficEnabled,"X","tooltip_CargoStation_"..MyCargoStopSign.CargoType,"Y" }
	else
		this.Tooltip = { "tooltip_CargoStation_Large",this.HomeUID,"H",MyCargoSignLeft.TrafficEnabled,"A","tooltip_CargoStation_"..MyCargoSignLeft.CargoType,"B",MyCargoSignRight.TrafficEnabled,"C","tooltip_CargoStation_"..MyCargoSignRight.CargoType,"D" }
	end
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end

function RemoveTrees(from,dist)
	for j = 1, #TreeTypes do
		for thatTree in next, Find(from,TreeTypes[j],dist) do
			thatTree.Delete()
		end
	end
end

function RemoveStackClicked()
	if Get(MyCargoStopSign,"InUse") == "no" then
		print("RemoveStackClicked")
		if this.CargoFloor == "LARGE" then
			if this.CargoSide == "LEFT" then
				local removeChecker = Object.Spawn("LoadChecker",MyCargoSignLeft.CheckPointX,MyCargoSignLeft.CheckPointY)
				for j = 1, #ObjectsToLoad do
					for thatObject in next, Find(removeChecker,ObjectsToLoad[j],4) do
						thatObject.Delete()
					end
				end
				Set(MyCargoSignLeft,"CargoStored",0)
				Set(MyCargoSignLeft,"AllLoadersFilled",nil)
				removeChecker.Delete()
			else
				local removeChecker = Object.Spawn("LoadChecker",MyCargoSignRight.CheckPointX,MyCargoSignRight.CheckPointY)
				for j = 1, #ObjectsToLoad do
					for thatObject in next, Find(removeChecker,ObjectsToLoad[j],4) do
						thatObject.Delete()
					end
				end
				Set(MyCargoSignRight,"CargoStored",0)
				Set(MyCargoSignRight,"AllLoadersFilled",nil)
				removeChecker.Delete()
			end
		else
			local removeChecker = Object.Spawn("LoadChecker",MyCargoStopSign.CheckPointX,MyCargoStopSign.CheckPointY)
			for j = 1, #ObjectsToLoad do
				for thatObject in next, Find(removeChecker,ObjectsToLoad[j],4) do
					thatObject.Delete()
				end
			end
			Set(MyCargoStopSign,"CargoStored",0)
			Set(MyCargoStopSign,"AllLoadersFilled",nil)
			removeChecker.Delete()
		end
		RemoveLoaders()
	end
end

function RemoveLoaders()
	print("RemoveLoaders")
	if this.CargoFloor == "LARGE" then
		if this.CargoSide == "LEFT" then
			local removeChecker = Object.Spawn("LoadChecker",MyCargoSignLeft.CheckPointX,MyCargoSignLeft.CheckPointY)
			for j = 1, #TruckBayObjects do
				for thatLoader in next, Find(removeChecker,TruckBayObjects[j],5) do
					if thatLoader.CargoStationID == MyCargoSignLeft.CargoStationID then
						print("Removed left loader")
						thatLoader.Delete()
					end
				end
			end
			removeChecker.Delete()
		else
			local removeChecker = Object.Spawn("LoadChecker",MyCargoSignRight.CheckPointX,MyCargoSignRight.CheckPointY)
			for j = 1, #TruckBayObjects do
				for thatLoader in next, Find(removeChecker,TruckBayObjects[j],5) do
					if thatLoader.CargoStationID == MyCargoSignRight.CargoStationID then
						print("Removed right loader")
						thatLoader.Delete()
					end
				end
			end
			removeChecker.Delete()
		end
	else
		local removeChecker = Object.Spawn("LoadChecker",MyCargoStopSign.CheckPointX,MyCargoStopSign.CheckPointY)
		for j = 1, #TruckBayObjects do
			for thatObject in next, Find(removeChecker,TruckBayObjects[j],5) do
				if thatObject.CargoStationID == MyCargoStopSign.CargoStationID then
					print("Removed loader")
					thatObject.Delete()
				end
			end
		end
		removeChecker.Delete()
	end
end

function DeleteStationClicked()
	this.Delete()
end

function RemoveFloor()
	local CompactFloorLeft = {
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 2, 1, 1 }
			}

	local CompactFloorRight = {
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1 }
			}

	local LargeFloor = {
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 },
			{ 1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 1 }
			}
			
	local Tiles = {
			[0] = "Excluded", -- 0 = excluded from changing, since this is the road
			[1] = "LooseStone",
			[2] = "Gravel"
			}

	if this.CargoFloor == "COMPACT" then
		local CompactFloor = {}
		if this.CargoSide == "RIGHT" then CompactFloor = CompactFloorRight else CompactFloor = CompactFloorLeft end
		local x = this.Pos.x-6
		local y = this.Pos.y-6
		
		for X = 1,11 do
			for Y = 1,12 do
				local cell = World.GetCell(x+X,y+Y)
				if Tiles[CompactFloor[Y][X]] ~= "Excluded" then
					cell.Mat = Tiles[CompactFloor[Y][X]]
				end
				cell.Ind = false
			end
		end
		if Get(this,"StationHeight") == "TALL" then
			if this.CargoSide == "LEFT" then
				x = this.Pos.x-6
				y = this.Pos.y-15
				for X = 1,6 do
					for Y = 1,11 do
						local cell = World.GetCell(x+X,y+Y)
						if Tiles[CompactFloor[Y][X]] ~= "Excluded" then
							cell.Mat = Tiles[CompactFloor[Y][X]]
						end
						cell.Ind = false
					end
				end
			else
				x = this.Pos.x-6
				y = this.Pos.y-15
				for X = 5,11 do
					for Y = 1,11 do
						local cell = World.GetCell(x+X,y+Y)
						if Tiles[CompactFloor[Y][X]] ~= "Excluded" then
							cell.Mat = Tiles[CompactFloor[Y][X]]
						end
						cell.Ind = false
					end
				end
			end
		end
	else
		local x = math.floor(this.Pos.x)-9
		local y = math.floor(this.Pos.y)-6
		for X = 1,17 do
			for Y = 1,12 do
				local cell = World.GetCell(x+X,y+Y)
				if Tiles[LargeFloor[Y][X]] ~= "Excluded" then
					cell.Mat = Tiles[LargeFloor[Y][X]]
				end
				cell.Ind = false
			end
		end
		if Get(this,"StationHeightLeft") == "TALL" then		
			x = this.Pos.x-9
			y = this.Pos.y-15
			for X = 1,6 do
				for Y = 1,11 do
					local cell = World.GetCell(x+X,y+Y)
					if Tiles[LargeFloor[Y][X]] ~= "Excluded" then
						cell.Mat = Tiles[LargeFloor[Y][X]]
					end
					cell.Ind = false
				end
			end
		end
		if Get(this,"StationHeightRight") == "TALL" then		
			x = this.Pos.x-9
			y = this.Pos.y-15
			for X = 11,17 do
				for Y = 1,11 do
					local cell = World.GetCell(x+X,y+Y)
					if Tiles[LargeFloor[Y][X]] ~= "Excluded" then
						cell.Mat = Tiles[LargeFloor[Y][X]]
					end
					cell.Ind = false
				end
			end
		end
	end
end

function RemoveStationClicked()
	RemoveFloor()
	RemoveRecycling("LEFT")
	RemoveRecycling("RIGHT")
	
	if this.CargoFloor == "LARGE" and Exists(MyRoadMarker) and FoundOtherCargoStation(MyRoadMarker) == false then
		MyRoadMarker.Delete()
		if Exists(MyRoadMarkerLeft) then
			MyRoadMarkerLeft.Delete()
		end
		if Exists(MyRoadMarkerRight) then
			MyRoadMarkerRight.Delete()
		end
		RemoveMyRoad("CENTRE","DOUBLE")
	elseif this.CargoFloor == "COMPACT" and Exists(MyRoadMarker) and FoundOtherCargoStation(MyRoadMarker) == false then
		MyRoadMarker.Delete()
		if this.CargoSide == "RIGHT" then
			RemoveMyRoad("LEFT","SINGLE")
		else
			RemoveMyRoad("RIGHT","SINGLE")
		end
	end
	
	for _, typ in pairs(CargoStationObjects) do
		local nearbyObjects = Find(this,typ,10000)
		for thatObject, _ in pairs(nearbyObjects) do
			if thatObject.Id.u ~= this.Id.u then
				if thatObject.Type == "CargoStationTruck" then
					if this.CargoFloor == "LARGE" then
						if (Get(thatObject,"CargoStationID") == MyCargoSignLeft.CargoStationID or Get(thatObject,"CargoStationID") == MyCargoSignRight.CargoStationID or Get(thatObject,"CargoStationID") == 0) then
							for __, driver in pairs(TruckDrivers) do
								local truckDrivers = Find(thatObject,driver,10)
								for thatTruckDriver, dist in pairs(truckDrivers) do
									if thatTruckDriver.TruckID == thatObject.Id.u then
										thatTruckDriver.Delete()
									end
								end
							end
							Set(thatObject,"DeleteMe",true)
						end
					else
						if (Get(thatObject,"CargoStationID") == MyCargoStopSign.CargoStationID or Get(thatObject,"CargoStationID") == 0) then
							for __, driver in pairs(TruckDrivers) do
								local truckDrivers = Find(thatObject,driver,10)
								for thatTruckDriver, dist in pairs(truckDrivers) do
									if thatTruckDriver.TruckID == thatObject.Id.u then
										thatTruckDriver.Delete()
									end
								end
							end
							Set(thatObject,"DeleteMe",true)
						end
					end
				elseif Get(thatObject,"MarkerUID") == this.MarkerUID and thatObject.HomeUID == this.HomeUID then
					thatObject.Delete()
				elseif Get(thatObject,"MarkerUID") == this.LeftMarkerUID and thatObject.HomeUID == this.HomeUID then
					thatObject.Delete()
				elseif Get(thatObject,"MarkerUID") == this.RightMarkerUID and thatObject.HomeUID == this.HomeUID then
					thatObject.Delete()
				end
			end
		end
	end
	
	for j = 1, #ObjectsToLoad do
		for thatObject in next, Find(this,ObjectsToLoad[j],8) do
			thatObject.Delete()
		end
	end
	
	this.Delete()
end

function FoundOtherCargoStation(myMarker)
	local sameLane = false
	for OtherStopSign in next, Find(this,"CargoStopSign",10000) do
		if OtherStopSign.Id.i ~= MyCargoStopSign.Id.i and OtherStopSign.RoadX == myMarker.Pos.x then
			sameLane = true
			break
		end
	end
	return sameLane
end
