
local timeTot = 0
local timeLoad = 0
local timePerLoadUpdate = (math.random(10,99) / 100) * math.random(10,15)

local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

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

local MyEntities = {}

function Create()
	Set(this,"TruckType","Cargo")
end

function Update(timePassed)
	if timePerUpdate == nil then
		if this.AllQuantity > 0 then
			this.Tooltip = { "tooltip_CargoStopSign_DeliveriesArriving",this.HomeUID,"X",this.CargoStationID,"Y",this.Number,"Z",this.BuildingQuantity,"A",this.FloorsQuantity,"B",this.FoodQuantity,"C",this.LaundryQuantity,"D",this.ForestQuantity,"E",this.VendingQuantity,"F",this.Workshop1Quantity,"G",this.Workshop2Quantity,"H",this.Workshop3Quantity,"I",this.Workshop4Quantity,"J",this.Workshop5Quantity,"K",this.OtherQuantity,"L" }
		elseif this.PrisQuantity > 0 then
			this.Tooltip = { "tooltip_CargoStopSign_PrisonersArriving",this.HomeUID,"X",this.CargoStationID,"Y",this.Number,"Z",this.PrisQuantity,"T",this.MinSecQuantity,"A",this.NormalQuantity,"B",this.MaxSecQuantity,"C",this.ProtectedQuantity,"D",this.SuperMaxQuantity,"E",this.DeathRowQuantity,"F",this.InsaneQuantity,"G" }
		else
			this.Tooltip = { "tooltip_CargoStopSign",this.HomeUID,"X",this.CargoStationID,"Y",this.Number,"Z" }
		end
		if this.WaitForFiremen == true then
			FindMyCalloutEntities(10000)
		end
		timePerUpdate = 1 / World.TimeWarpFactor
	end
	if this.CargoType ~= "Intake" and this.CargoType ~= "Deliveries" then
		timeTot = timeTot + timePassed
		if timeTot >= timePerUpdate then
			timeTot = 0
			if this.TrafficEnabled == "yes" then 
				timeLoad = timeLoad + 1
				if timeLoad >= timePerLoadUpdate then
					timeLoad = 0
					if this.InUse == "no" then LookForCargo() end
				end
			end
			if this.FindFiremen == true then
				FindMyCalloutEntities(10000)
				this.FindFiremen = false
			end
			if this.WaitForFiremen == true then
				WaitForFiremen()
			end
		end
	end
end

function FindMyLoadChecker()
	print("FindMyLoadChecker")
	local nearbyObject = Find(this,"LoadChecker",6)
	if next(nearbyObject) then
		for thatChecker, distance in pairs(nearbyObject) do
			if thatChecker.CargoStationID == this.CargoStationID then
				MyChecker = thatChecker
				print("MyChecker found at "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyChecker) then
		print(" -- ERROR --- MyChecker not found")
	end
end

function FindMyCargoControl()
	print("FindMyCargoControl")
	local nearbyObject = Find(this,"CargoStationControl",3)
	if next(nearbyObject) then
		for thatControl, distance in pairs(nearbyObject) do
			if thatControl.CargoStationID == this.CargoStationID then
				MyCargoControl = thatControl
				print("CargoStationControl found at "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyCargoControl) then
		print(" -- ERROR --- MyCargoControl not found")
	end
end

function FindMyLoaders()
	if this.SubType == 1 or this.SubType == 2 then
		Set(this,"TruckType","Cargo")			-- exports and garbage are loaded on CargoTruckBay
	elseif this.SubType == 4 then
		Set(this,"TruckType","Emergency")		-- dead entities are loaded on EmergencyTruckBay
	end
	print("FindMyLoaders "..this.TruckType)
	local found = false
	Loaders = {}
	Loaders[3] = {}
	Loaders[4] = {}
	Loaders[5] = {}
	Loaders[6] = {}
	if not Exists(MyChecker) then FindMyLoadChecker() end
	local nearbyObjects = Find(MyChecker,this.TruckType.."TruckBay",5)
	if next(nearbyObjects) then
		for thatLoader, distance in pairs(nearbyObjects) do
			if thatLoader.CargoStationID == this.CargoStationID and thatLoader.TruckBayNr >= 3 then
				thatLoader.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",thatLoader.TruckBayNr,"N",thatLoader.CargoAmount,"A" }
				Loaders[thatLoader.TruckBayNr] = thatLoader
				print("My"..this.TruckType.."Loader"..thatLoader.TruckBayNr.." found at "..distance)
			elseif thatLoader.CargoStationID == this.CargoStationID and thatLoader.TruckBayNr == 1 then
				thatLoader.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",thatLoader.TruckBayNr,"N",thatLoader.CargoAmount,"A" }
				TakeAwayLoader1 = thatLoader
				print("My"..this.TruckType.."Loader"..thatLoader.TruckBayNr.." found at "..distance)
			elseif thatLoader.CargoStationID == this.CargoStationID and thatLoader.TruckBayNr == 2 then
				thatLoader.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",thatLoader.TruckBayNr,"N",thatLoader.CargoAmount,"A" }
				TakeAwayLoader2 = thatLoader
				print("My"..this.TruckType.."Loader"..thatLoader.TruckBayNr.." found at "..distance)
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
	if not Exists(MyCargoControl) then FindMyCargoControl() end
	if Loaders == nil then FindMyLoaders() end
	if this.SubType == 1 or this.SubType == 2 then
		if not this.AllLoadersFilled then
			Set(this,"TruckType","Cargo")
			print("LookForCargo "..this.TruckType)
			if not Exists(MyChecker) then FindMyLoadChecker() end
			for _, typ in pairs(ObjectsToLoad) do
				local nearbyObjects = Find(MyChecker,typ,4)
				for thatObject, _ in pairs(nearbyObjects) do
					if not thatObject.Loaded then
						FillMyLoader(thatObject)
					end
					if this.AllLoadersFilled == true then break end
				end
				nearbyObjects = nil
				if this.AllLoadersFilled == true then break end
			end
		else
			print("AllLoadersFilled")
		end
		CheckMyLoaders()
	elseif this.SubType == 4 then
		Set(this,"TruckType","Emergency")
		print("LookForCargo "..this.TruckType)
		CheckMyLoaders()
	end
end

function CheckMyLoaders()
	print("CheckMyLoaders "..this.TruckType)
	local consolidate = false
	local totalAmount = 0
	local amount = 0
	for L = 3,6 do
		amount = 0
		if not Exists(Loaders[L]) then SpawnLoader(L) end
		for S = 0,7 do
			if Get(Loaders[L],"Slot"..S..".i") > -1 then
				amount = amount + 1
				Set(Loaders[L],"CargoLoad"..S,this.CargoStationID)
			else
				Set(Loaders[L],"CargoLoad"..S,0)
			end
		end
		Set(Loaders[L],"CargoAmount",amount)
		Loaders[L].Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",L,"N",amount,"A" }
		totalAmount = totalAmount + amount
	end
	if totalAmount > 0 then ConsolidateLoaders() else Set(this,"AllLoadersFilled",nil) end
	if this.TruckType == "Emergency" and this.CargoStored > 0 then
		if this.LoadAvailable == false then
			OrderTruck()	-- NOT IDEAL, NEEDS OTHER SOLUTION
			Set(this,"LoadAvailable",true)
		end
	elseif this.CargoStored >= 8 then
		if this.LoadAvailable == false then
			OrderTruck()
			Set(this,"LoadAvailable",true)
		end
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
					Set(Loaders[L],"CargoLoad"..S,this.CargoStationID)
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

function SpawnLoader(BayNr)
	print("SpawnLoader "..this.TruckType.." "..BayNr)
	if not Exists(MyCargoControl) then FindMyCargoControl() end
	Loaders[BayNr] = {}
	local X = 0
	if math.random() > 0.5 then
		X = this.CheckPointX-0.5 + (math.random(1,10) / 10) + 0.25
	else
		X = this.CheckPointX+0.5 - (math.random(1,10) / 10) - 0.25
	end
	local MyLoader
	if this.TruckType == "Emergency" then
		MyLoader = Object.Spawn(this.TruckType.."TruckBay",X,this.CheckPointY-0.05)
	else
		MyLoader = Object.Spawn(this.TruckType.."TruckBay",X,this.CheckPointY-0.55)
	end
	Set(MyLoader,"CargoStationID",this.CargoStationID)
	Set(MyLoader,"HomeUID",this.HomeUID)
	Set(MyLoader,"TruckBayNr",BayNr)
	Set(MyLoader,"CargoAmount",0)
	for i = 0,7 do
		Set(MyLoader,"CargoLoad"..i,0)
	end
	MyLoader.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",BayNr,"N",0,"A" }
	Loaders[BayNr] = MyLoader
	print(" -- MyLoader "..BayNr.." spawned")
end

function ConsolidateLoaders()
	print("ConsolidateLoaders "..this.TruckType.."TruckBay")
	Set(this,"CargoStored",0)
	
	if not Exists(TakeAwayLoader1) then
		local X,Y = 0,0
		if math.random() > 0.5 then
			X = this.CheckPointX-0.5 + (math.random(1,10) / 10) + 0.25
			Y = this.CheckPointY-1.25 + (math.random(1,10) / 10) - 0.25
		else
			X = this.CheckPointX+0.5 - (math.random(1,10) / 10) - 0.25
			Y = this.CheckPointY-0.25 - (math.random(1,10) / 10) - 0.25
		end
		TakeAwayLoader1 = Object.Spawn(this.TruckType.."TruckBay",X,Y)
		Set(TakeAwayLoader1,"CargoStationID",this.CargoStationID)
		Set(TakeAwayLoader1,"HomeUID",this.HomeUID)
		TakeAwayLoader1.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",1,"N",0,"A" }
		Set(TakeAwayLoader1,"TruckBayNr",1)
		for i = 0,7 do
			Set(TakeAwayLoader1,"CargoLoad"..i,0)
		end
	end
	FillTakeAway(TakeAwayLoader1,1)
	Set(this,"CargoStored",TakeAwayLoader1.CargoAmount)
	
	if not Exists(TakeAwayLoader2) then
		local X,Y = 0,0
		if math.random() > 0.5 then
			X = this.CheckPointX-0.5 + (math.random(1,10) / 10) + 0.25
			Y = this.CheckPointY-1.25 + (math.random(1,10) / 10) - 0.25
		else
			X = this.CheckPointX+0.5 - (math.random(1,10) / 10) - 0.25
			Y = this.CheckPointY-0.25 - (math.random(1,10) / 10) - 0.25
		end
		TakeAwayLoader2 = Object.Spawn(this.TruckType.."TruckBay",X,Y)
		Set(TakeAwayLoader2,"CargoStationID",this.CargoStationID)
		Set(TakeAwayLoader2,"HomeUID",this.HomeUID)
		TakeAwayLoader2.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",2,"N",0,"A" }
		Set(TakeAwayLoader2,"TruckBayNr",2)
		for i = 0,7 do
			Set(TakeAwayLoader2,"CargoLoad"..i,0)
		end
	end
	FillTakeAway(TakeAwayLoader2,2)
	Set(this,"CargoStored",this.CargoStored + TakeAwayLoader2.CargoAmount)
end

function FillTakeAway(theTakeAway,theBayNr)
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
						Set(Loaders[L],"CargoLoad"..S,0)
						print("Fill TakeAwayLoader"..theBayNr.." slot "..E.." with loader"..L.." slot "..S)
						Set(theTakeAway,"Slot"..E..".i",Get(Loaders[L],"Slot"..S..".i"))
						Set(theTakeAway,"Slot"..E..".u",Get(Loaders[L],"Slot"..S..".u"))
						Set(Loaders[L],"Slot"..S..".i",-1)
						Set(Loaders[L],"Slot"..S..".u",-1)
						Set(theTakeAway,"CargoLoad"..E,this.CargoStationID)
						loaded = true
						break
					end
					if Get(Loaders[L],"CargoLoad"..S) == this.CargoStationID then
						loaderamount = loaderamount + 1
					end
				end
				Set(Loaders[L],"CargoAmount",loaderamount)
				Loaders[L].Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",L,"N",loaderamount,"A" }
				if loaded then break end
			end
		end
		loaded = nil
		E = E + 1
	end
	for i = 0,7 do
		if Get(theTakeAway,"CargoLoad"..i) == this.CargoStationID then
			amount = amount + 1
		end
	end
	Set(theTakeAway,"CargoAmount",amount)
	theTakeAway.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",theBayNr,"N",amount,"A" }
end

function WaitForFiremen()
	print("WaitForFiremen")
	local FiremenBackOrDead = { [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false, [8] = false }
	for B = 1,8 do
		if MyEntities[B] == nil then
			FiremenBackOrDead[B] = true
		else
			if MyEntities[B].Energy ~= nil and MyEntities[B].Damage < 1 then
				if MyEntities[B].Loaded == true or MyEntities[B].LeavingMap then
					print("Fireman "..B.." is back")
					if not Exists(MyFireEquipment) then FindMyFireEquipment() end
					for U = 0,7 do
						if Get(MyFireEquipment,"Slot"..U..".i") == MyEntities[B].Id.i then
							Set(MyFireEquipment,"Slot"..U..".i",-1)
							Set(MyFireEquipment,"Slot"..U..".u",-1)
						end
					end
					Set(MyEntities[B],"CargoStationID",0)
					Set(MyEntities[B],"CarrierId.i",-1)
					Set(MyEntities[B],"CarrierId.u",-1)
					Set(MyEntities[B],"Loaded",false)
					Set(MyEntities[B],"Equipment",0)
					MyEntities[B].FireEngine.i = -1
					MyEntities[B].FireEngine.u = -1
					MyEntities[B].LeaveMap()
					MyEntities[B] = nil
					FiremenBackOrDead[B] = true
				end
			else
				FiremenBackOrDead[B] = true
			end			
		end
	end
	
	local AllBackOrDead = true
	for D = 1,8 do
		if FiremenBackOrDead[D] == false then
			AllBackOrDead = false
			break
		end
	end
	if AllBackOrDead == true then
		print("FiremenAreBack")
		if not Exists(MyFireEquipment) then FindMyFireEquipment() end
		MyFireEquipment.SubType = MyFireEquipment.SubType - 1
		Set(this,"WaitForFiremen",false)
	end	
end

function FindMyCalloutEntities()
	print("FindMyCalloutEntities")
	local nearbyObjects = Find(this,"Fireman",10000)
	for thatEntity, distance in pairs(nearbyObjects) do
		if thatEntity.CargoStationID == this.CargoStationID then
			if thatEntity.Number == 1	  then MyEntity1 = thatEntity; MyEntities[1] = MyEntity1; print("MyEntity1 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 2 then MyEntity2 = thatEntity; MyEntities[2] = MyEntity2; print("MyEntity2 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 3 then MyEntity3 = thatEntity; MyEntities[3] = MyEntity3; print("MyEntity3 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 4 then MyEntity4 = thatEntity; MyEntities[4] = MyEntity4; print("MyEntity4 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 5 then MyEntity5 = thatEntity; MyEntities[5] = MyEntity5; print("MyEntity5 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 6 then MyEntity6 = thatEntity; MyEntities[6] = MyEntity6; print("MyEntity6 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 7 then MyEntity7 = thatEntity; MyEntities[7] = MyEntity7; print("MyEntity7 "..thatEntity.Type.." found at "..distance)
			elseif thatEntity.Number == 8 then MyEntity8 = thatEntity; MyEntities[8] = MyEntity8; print("MyEntity8 "..thatEntity.Type.." found at "..distance)
			end
		end
	end
	nearbyObjects = nil
	
	if not Exists(MyEntity1) then
		print(" -- ERROR --- MyEntity1 not found")
	end
	if not Exists(MyEntity2) then
		print(" -- ERROR --- MyEntity2 not found")
	end
	if not Exists(MyEntity3) then
		print(" -- ERROR --- MyEntity3 not found")
	end
	if not Exists(MyEntity4) then
		print(" -- ERROR --- MyEntity4 not found")
	end
	if not Exists(MyEntity5) then
		print(" -- ERROR --- MyEntity5 not found")
	end
	if not Exists(MyEntity6) then
		print(" -- ERROR --- MyEntity6 not found")
	end
	if not Exists(MyEntity7) then
		print(" -- ERROR --- MyEntity7 not found")
	end
	if not Exists(MyEntity8) then
		print(" -- ERROR --- MyEntity8 not found")
	end
end

function FindMyFireEquipment()
	print("---")
	print("FindMyFireEquipment")
	local nearbyObject = Find("CargoStationFireEngine",10)
	if next(nearbyObject) then
		for thatEquip, distance in pairs(nearbyObject) do
			if thatEquip.CargoStationID == this.CargoStationID then
				MyFireEquipment = thatEquip
				print("MyFireEquipment found at "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyFireEquipment) then
		print(" -- ERROR --- MyFireEquipment not found")
	end
end

function OrderTruck()
	print("OrderTruck")
	local TruckSub = 0
	if not Exists(MyTrafficTerminal) then
		local nearbyTerminals = Find("TrafficTerminal",10000)
		if next(nearbyTerminals) then
			for thatTerminal, distance in pairs(nearbyTerminals) do
				print("MyTrafficTerminal found at "..distance)
				MyTrafficTerminal = thatTerminal
				TruckSub = Get(MyTrafficTerminal,"SubType_"..this.CargoType.."StationTruck")
				print("TruckSub: "..TruckSub)
				break
			end
		end
		nearbyTerminals = nil
	else
		TruckSub = Get(MyTrafficTerminal,"SubType_"..this.CargoType.."StationTruck")
		print("TruckSub: "..TruckSub)
	end
	if not Exists(MyCargoControl) then FindMyCargoControl() end
	local MyTruck = Object.Spawn("CargoStationTruck",this.RoadX,math.random(1,2) + (math.random(10,99) / 100) + (math.random(10,99) / 100))
	Set(MyTruck,"HomeUID",this.TruckType.."Truck_"..MyTruck.Id.u)
	Set(MyTruck,"TruckID",MyTruck.Id.u)
	Set(MyTruck,"CargoStationID",this.CargoStationID)
	Set(MyTruck,"MyType",this.TruckType)
	Set(MyTruck,"SkinType",this.CargoType)
	if this.TruckType =="Emergency" then
		Set(MyTruck,"Tail",3.75)
		Set(MyTruck,"Head",1.5)
		Set(MyTruck,"TruckY",0.25)
	elseif this.TruckType =="Cargo" then
		Set(MyTruck,"Tail",6.5)
		Set(MyTruck,"Head",1.5)
		Set(MyTruck,"TruckY",2)
	end
	Set(MyTruck,"RoadX",this.RoadX)
	Set(MyTruck,"TotalCargoAmount",0)
	
	
	local newTruckSkin = Object.Spawn(this.CargoType.."TruckSkin",this.RoadX,MyTruck.Pos.y)
	newTruckSkin.SubType = TruckSub
	Set(newTruckSkin,"HomeUID",MyTruck.HomeUID)
	Set(newTruckSkin,"Slot0.i",MyTruck.Id.i)
	Set(newTruckSkin,"Slot0.u",MyTruck.Id.u)
	Set(MyTruck,"CarrierId.i",newTruckSkin.Id.i)
	Set(MyTruck,"CarrierId.u",newTruckSkin.Id.u)
	Set(MyTruck,"Loaded",true)
	newTruckSkin.Tooltip = { "tooltip_CargoStationTruck_TruckSkin",this.HomeUID,"H" }

	if SpawnTruckLightsOK() == true then
		local newHL = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
		Set(newTruckSkin,"Slot1.i",newHL.Id.i)
		Set(newTruckSkin,"Slot1.u",newHL.Id.u)
		Set(newHL,"CarrierId.i",newTruckSkin.Id.i)
		Set(newHL,"CarrierId.u",newTruckSkin.Id.u)
		Set(newHL,"Loaded",true)
		Set(newHL,"HomeUID",MyTruck.HomeUID)
		local newHR = Object.Spawn("WallLight",newTruckSkin.Pos.x,newTruckSkin.Pos.y)
		Set(newTruckSkin,"Slot2.i",newHR.Id.i)
		Set(newTruckSkin,"Slot2.u",newHR.Id.u)
		Set(newHR,"CarrierId.i",newTruckSkin.Id.i)
		Set(newHR,"CarrierId.u",newTruckSkin.Id.u)
		Set(newHR,"Loaded",true)
		Set(newHR,"HomeUID",MyTruck.HomeUID)
	end
	
	Set(this,"CargoStored",0)
	Set(this,"AllLoadersFilled",nil)
	Set(this,"InUse","yes")
	Set(this,"Status","ON ROUTE")
	if this.TruckType == "Emergency" then
		Set(MyCargoControl,"SubType",20)
	else
		Set(MyCargoControl,"SubType",7)
	end
	
	Set(MyTruck,"Number",this.Number)
	
	TakeAwayLoader1 = nil
	TakeAwayLoader2 = nil
	timePerLoadUpdate = math.random() * 10
end

function SpawnTruckLightsOK()
	if Get(MyTrafficTerminal,"TruckLights") == "always" then
		return true
	elseif Get(MyTrafficTerminal,"TruckLights") == "night" then
		local hours = math.floor(math.mod(World.TimeIndex,1440) /60)
		print("SpawnTruckLightsOK -->> current hour is: "..hours)
		if hours > 18 or hours < 8 then
			print("SpawnTruckLightsOK -->> enable vehicle lights")
			return true
		end
	end
	return false
end

function FindMyTrafficTerminal()
	print("FindMyTrafficTerminal")
	local nearbyTerminals = Find(this,"TrafficTerminal",10000)
	for thatTerminal, distance in pairs(nearbyTerminals) do
		MyTrafficTerminal = thatTerminal
		print(" -- MyTrafficTerminal found")
	end
	if not Exists(MyTrafficTerminal) then
		print(" -- ERROR --- MyTrafficTerminal not found")
	end
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
