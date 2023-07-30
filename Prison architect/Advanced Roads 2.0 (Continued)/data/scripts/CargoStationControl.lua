
local timeTot = 0
local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

local CargoLoaderSlots	= { [0] = 0, [1] = 0, [2] = 0, [3] = 0,  [4] = 0, [5] = 0, [6] = 0, [7] = 0 }
local TruckBaySlots		= { [0] = 0, [1] = 0, [2] = 0, [3] = 0,  [4] = 0, [5] = 0, [6] = 0, [7] = 0 }
local TheCargoAmount = 0

local CargoX = "Left"
local CargoY = "Up"

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

local CalloutEntitiesToFind = { "Fireman", "Paramedic", "ArmedGuard", "RiotGuard", "Soldier", "EliteOps" }
local MyEntities = {}

function Create()
end

function Update(timePassed)
	if timePerUpdate == nil then
		FindMyCrane()
		FindMyHook()
		FindMyCargoStopSign()
		FindMyLoadChecker()
		timePerUpdate = 1
		if this.GrabBayOnTruck == true then FindBays(this.BayNr) end
	end
	timeTot = timeTot+timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		
		if not this.GrabBayOnTruck then
			
			-- SubTypes 1 & 2 are for handling Deliveries
			if this.SubType == 1 then				-- move crane from truck to cargo area
				timePerUpdate = 0.01
				 if FromTruckToArea(this.RandomSpotX,this.RandomSpotY,3,timePassed) == true then
					StopAtSide("Deliveries")
					Set(this,"SubType",2)
				end
			elseif this.SubType == 2 then			-- move crane from cargo area back to truck
				timePerUpdate = 0.01
				if FromAreaToTruck(this.TruckX,this.TruckY,3,timePassed) == true then
					StopInCentre("Deliveries")
				end
				
				
			-- SubTypes 3 & 4 are for handling exports
			elseif this.SubType == 3 then			-- move crane from truck to exports area
				timePerUpdate = 0.01
				if FromTruckToArea(this.RandomSpotX,this.RandomSpotY,3,timePassed) == true then
					StopAtSide("Exports")
					Set(this,"SubType",4)
				end
			elseif this.SubType == 4 then			-- move crane from exports area back to truck
				timePerUpdate = 0.01
				if FromAreaToTruck(this.TruckX,this.TruckY,3,timePassed) == true then
					StopInCentre("Exports")
				end
				
				
			-- SubTypes 5 & 6 are for handling garbage
			elseif this.SubType == 5 then			-- move crane from truck to garbage area
				timePerUpdate = 0.01
				if FromTruckToArea(this.RandomSpotX,this.RandomSpotY,3,timePassed) == true then
					StopAtSide("Garbage")
					Set(this,"SubType",6)
				end
			elseif this.SubType == 6 then			-- move crane from garbage area back to truck
				timePerUpdate = 0.01
				if FromAreaToTruck(this.TruckX,this.TruckY,3,timePassed) == true then
					StopInCentre("Garbage")
				end
				
			-- prisoner intake
			elseif this.SubType == 18 then
				timePerUpdate = 1
				if this.RoadX < this.TruckX then	-- cargo area is on left side of the road
					UnloadPrisonersFromTruck(this.TruckX-2,math.random(-5,-1),math.random(-5,-1))
				else
					UnloadPrisonersFromTruck(this.TruckX+2,math.random(1,5),math.random(-5,-1))
				end
				
			-- SubTypes 21 & 22 are for handling emergency
			elseif this.SubType == 21 then			-- move crane from truck to emergency area
				timePerUpdate = 0.01
				if FromTruckToArea(this.RandomSpotX,this.RandomSpotY,3,timePassed) == true then
					StopAtSide("Emergency")
					Set(this,"SubType",22)
				end
			elseif this.SubType == 22 then			-- move crane from emergency area back to truck
				timePerUpdate = 0.01
				if FromAreaToTruck(this.TruckX,this.TruckY,3,timePassed) == true then
					StopInCentre("Emergency")
				end
			elseif this.SubType == 23 then
				timePerUpdate = 0.5
				HandleCallout()
			else
				CheckForActivation()
			end
		else
			timePerUpdate = 0.01
			if FromAreaToTruck(BayOnTruck.Pos.x,BayOnTruck.Pos.y,3,timePassed) == true then
				Set(this,"GrabBayOnTruck",nil)
				LoadDeliveriesBayOnHook()
				timePerUpdate = 1
				Set(this,"SubType",1)
			end
		end
		if this.ActivateJob then
			Object.CreateJob(this,this.ActivateJob)
		end
	end
end

function FromTruckToArea(theX,theY,speed,dT)
	if CargoX == "Left" then
		if not reachedX then
			MyCrane.Pos.x = MyCrane.Pos.x - speed * dT
			MyHook.Pos.x = MyHook.Pos.x - speed * dT
			if MyCrane.Pos.x <= theX then
				if MyHook.Pos.y < this.RandomSpotY then CargoY = "Down" else CargoY = "Up" end
				MyCrane.Pos.x = theX
				MyHook.Pos.x = theX
				reachedX = true
			end
		elseif not reachedY then
			if CargoY == "Up" then
				MyHook.Pos.y = MyHook.Pos.y - speed * dT
				if MyHook.Pos.y <= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			elseif CargoY == "Down" then
				MyHook.Pos.y = MyHook.Pos.y + speed * dT
				if MyHook.Pos.y >= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			end
		end
		if reachedX == true and reachedY == true then
			reachedX,reachedY = nil,nil
			return true
		end
	elseif CargoX == "Right" then
		if not reachedX then
			MyCrane.Pos.x = MyCrane.Pos.x + speed * dT
			MyHook.Pos.x = MyHook.Pos.x + speed * dT
			if MyCrane.Pos.x >= theX then
				if MyHook.Pos.y < this.RandomSpotY then CargoY = "Down" else CargoY = "Up" end
				MyCrane.Pos.x = theX
				MyHook.Pos.x = theX
				reachedX = true
			end
		elseif not reachedY then
			if CargoY == "Up" then
				MyHook.Pos.y = MyHook.Pos.y - speed * dT
				if MyHook.Pos.y <= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			elseif CargoY == "Down" then
				MyHook.Pos.y = MyHook.Pos.y + speed * dT
				if MyHook.Pos.y >= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			end
		end
		if reachedX == true and reachedY == true then
			reachedX,reachedY = nil,nil
			return true
		end
	end
end

function FromAreaToTruck(theX,theY,speed,dT)
	if CargoX == "Left" then
		if not reachedX then
			MyCrane.Pos.x = MyCrane.Pos.x + speed * dT
			MyHook.Pos.x = MyHook.Pos.x + speed * dT
			if MyCrane.Pos.x >= theX then
				if MyHook.Pos.y < this.TruckY then CargoY = "Down" else CargoY = "Up" end
				MyCrane.Pos.x = theX
				MyHook.Pos.x = theX
				reachedX = true
			end
		elseif not reachedY then
			if CargoY == "Up" then
				MyHook.Pos.y = MyHook.Pos.y - speed * dT
				if MyHook.Pos.y <= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			elseif CargoY == "Down" then
				MyHook.Pos.y = MyHook.Pos.y + speed * dT
				if MyHook.Pos.y >= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			end
		end
		if reachedX == true and reachedY == true then
			reachedX,reachedY = nil,nil
			return true
		end
	elseif CargoX == "Right" then
		if not reachedX then
			MyCrane.Pos.x = MyCrane.Pos.x - speed * dT
			MyHook.Pos.x = MyHook.Pos.x - speed * dT
			if MyCrane.Pos.x <= theX then
				if MyHook.Pos.y < this.TruckY then CargoY = "Down" else CargoY = "Up" end
				MyCrane.Pos.x = theX
				MyHook.Pos.x = theX
				reachedX = true
			end
		elseif not reachedY then
			if CargoY == "Up" then
				MyHook.Pos.y = MyHook.Pos.y - speed * dT
				if MyHook.Pos.y <= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			elseif CargoY == "Down" then
				MyHook.Pos.y = MyHook.Pos.y + speed * dT
				if MyHook.Pos.y >= theY then
					MyHook.Pos.y = theY
					reachedY = true
				end
			end
		end
		if reachedX == true and reachedY == true then
			reachedX,reachedY = nil,nil
			return true
		end
	end
end

function FindMyTrafficTerminal()
	print("---")
	print("--- HOMEUID "..this.HomeUID.." --- FindMyTrafficTerminal")
	local nearbyTerminals = Find("TrafficTerminal",10000)
	if next(nearbyTerminals) then
		for thatTerminal, distance in pairs(nearbyTerminals) do
			print("MyTrafficTerminal found at "..distance)
			MyTrafficTerminal = thatTerminal
			break
		end
	end
	nearbyTerminals = nil
end

function FindMyCrane()
	print("---")
	print("--- HOMEUID "..this.HomeUID.." --- FindMyCrane")
	local nearbyObject = Find("CargoStationGantryCrane",10)
	if next(nearbyObject) then
		for thatCrane, distance in pairs(nearbyObject) do
			if thatCrane.CargoStationID == this.CargoStationID then
				MyCrane = thatCrane
				print("MyCrane found at "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyCrane) then
		print(" -- ERROR --- MyCrane not found")
	end
end

function FindMyHook()
	print("---")
	print("FindMyHook")
	local nearbyObject = Find("CargoStationGantryHook",10)
	if next(nearbyObject) then
		for thatHook, distance in pairs(nearbyObject) do
			if thatHook.CargoStationID == this.CargoStationID then
				MyHook = thatHook
				print("MyHook found at "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyHook) then
		print(" -- ERROR --- MyHook not found")
	end
end

function FindMyFireEquipment()
	print("---")
	print("FindMyFireEquipment")
	local nearbyObject = Find("CargoStationFireEngine",8)
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

function FindMyCargoStopSign()
	print("---")
	print("FindMyCargoStopSign")
	local nearbyObject = Find("CargoStopSign",3)
	if next(nearbyObject) then
		for thatSign, distance in pairs(nearbyObject) do
			if thatSign.CargoStationID == this.CargoStationID then
				MyCargoStopSign = thatSign
				print("MyCargoStopSign found at "..distance)
				if MyCargoStopSign.Pos.x < this.Pos.x then CargoX = "Right" end
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyCargoStopSign) then
		print(" -- ERROR --- MyCargoStopSign not found")
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

function FindMyLoaders(cargoType)
	print("---")
	print("FindMyLoaders "..cargoType)
	local found = false
	Loaders = {}
	Loaders[3] = {}
	Loaders[4] = {}
	Loaders[5] = {}
	Loaders[6] = {}
	if not Exists(MyChecker) then FindMyLoadChecker() end
	local nearbyObjects = Find(MyChecker,cargoType.."TruckBay",5)
	if next(nearbyObjects) then
		for thatLoader, distance in pairs(nearbyObjects) do
			if thatLoader.CargoStationID == this.CargoStationID and thatLoader.TruckBayNr >= 3 then
				Loaders[thatLoader.TruckBayNr] = thatLoader
				print(cargoType.."Loader"..thatLoader.TruckBayNr.." found at "..distance)
			end
		end
	end
	nearbyObjects = nil
end

function FindMyTruck()
	print("---")
	print("FindMyTruck")
	local Trucks = {"CargoStationTruck" } --,"IntakeStationTruck","EmergencyStationTruck" }
	if not Exists(MyChecker) then FindMyLoadChecker() end
	for _, typ in pairs(Trucks) do
		local nearbyObjects = Find(MyCargoStopSign,typ,3)
		for thatTruck, distance in pairs(nearbyObjects) do
			if thatTruck.Id.u == Get(this,"TruckID") then
				MyTruck = thatTruck
				Set(this,"TruckY",thatTruck.Pos.y-thatTruck.Tail+thatTruck.TruckY)
				print("MyTruck found at "..distance)
				break
			end
		end
		nearbyObjects = nil
	end
	if not Exists(MyTruck) then
		print(" -- ERROR --- MyTruck not found")
	end
end

function FindMyTruckSkin()
	print("---")
	print("FindMyTruckSkin")
	local Skins = {"DeliveriesTruckSkin","ExportsTruckSkin","GarbageTruckSkin","IntakeTruckSkin","EmergencyTruckSkin","FireEngineTruckSkin" }
	if not Exists(MyChecker) then FindMyLoadChecker() end
	for _, typ in pairs(Skins) do
		local nearbyObjects = Find(MyTruck,typ,8)
		for thatSkin, distance in pairs(nearbyObjects) do
			if thatSkin.HomeUID == MyTruck.HomeUID then
				MyTruckSkin = thatSkin
				print("MyTruckSkin found at "..distance)
				break
			end
		end
		nearbyObjects = nil
	end
	if not Exists(MyTruckSkin) then
		print(" -- ERROR --- MyTruckSkin not found")
	end
end

function FindBays(theBayNr)
	print("---")
	print("FindBay "..this.BayNr)
	if not Exists(MyTruck) then FindMyTruck() end
	TakeAwayBay = nil
	BayOnTruck = nil
	TheCargoAmount = 0
	if Exists(MyTruck) then
		local Bays = {"CargoTruckBay","IntakeTruckBay","EmergencyTruckBay","CalloutTruckBay" }
		if not Exists(MyChecker) then FindMyLoadChecker() end
		for _, typ in pairs(Bays) do
			local nearbyObjects = Find(MyChecker,typ,6)
			for thatBay, distance in pairs(nearbyObjects) do
				if thatBay.HomeUID == MyTruck.HomeUID and thatBay.TruckBayNr == theBayNr then
					BayOnTruck = thatBay
					TheCargoAmount = Get(BayOnTruck,"CargoAmount")
					print("BayOnTruck "..this.BayNr.." found at "..distance)
				elseif thatBay.CargoStationID == this.CargoStationID and thatBay.TruckBayNr == theBayNr then
					TakeAwayBay = thatBay
					TheCargoAmount = Get(TakeAwayBay,"CargoAmount")
					Set(this,"RandomSpotX",TakeAwayBay.Pos.x)
					Set(this,"RandomSpotY",TakeAwayBay.Pos.y)
					print("TakeAwayBay "..this.BayNr.." found at "..distance.." RandomX: "..this.RandomSpotX.." RandomY: "..this.RandomSpotY)
				end
			end
		end
		nearbyObject = nil
	end
end

function LoadDeliveriesBayOnHook()
	print("---")
	print("LoadDeliveriesBayOnHook "..this.BayNr)
	if not Exists(MyTruck) then FindMyTruck() end
	if not Exists(BayOnTruck) then FindBays(this.BayNr) end
	FindMyTruckSkin()
	Set(MyTruckSkin,"Slot"..(this.BayNr+2)..".i",-1)
	Set(MyTruckSkin,"Slot"..(this.BayNr+2)..".u",-1)
	Set(BayOnTruck,"CarrierId.i",-1)
	Set(BayOnTruck,"CarrierId.u",-1)
	Set(MyHook,"Slot0.i",BayOnTruck.Id.i)
	Set(MyHook,"Slot0.u",BayOnTruck.Id.u)
	Set(BayOnTruck,"CarrierId.i",MyHook.Id.i)
	Set(BayOnTruck,"CarrierId.u",MyHook.Id.u)
	Set(BayOnTruck,"Loaded",true)
	if math.random() > 0.5 then
		Set(this,"RandomSpotX",this.CheckPointX-0.5 + (math.random(1,10) / 10) + 0.25)
		Set(this,"RandomSpotY",this.CheckPointY-1.25 + (math.random(1,10) / 10) - 0.25)
	else
		Set(this,"RandomSpotX",this.CheckPointX+0.5 - (math.random(1,10) / 10) - 0.25)
		Set(this,"RandomSpotY",this.CheckPointY+0.25 - (math.random(1,10) / 10) - 0.25)
	end
end

function PutDeliveriesOnFloor()
	print("---")
	print("PutDeliveriesOnFloor "..this.BayNr)
	if not Exists(MyTruck) then FindMyTruck() end
	if not Exists(BayOnTruck) then FindBays(this.BayNr) end
	Set(MyHook,"Slot0.i",-1)
	Set(MyHook,"Slot0.u",-1)
	Set(BayOnTruck,"CarrierId.i",-1)
	Set(BayOnTruck,"CarrierId.u",-1)
	Set(BayOnTruck,"Loaded",false)
	
	SwapRealDeliveries()	-- teleports the real deliveries below the dummy cargo boxes and replaces those with empty cargo packaging boxes which get dumped
	
	local loadedStack=Find(BayOnTruck,"Stack",3)
	local loadedBox=Find(BayOnTruck,"Box",3)
	local loadedMail=Find(BayOnTruck,"MailSatchel",3)
	if next(loadedStack) then
		for thatStack, distance in pairs(loadedStack) do
			for A = 0,7 do
				if thatStack.Id.i == Get(BayOnTruck,"Slot"..A..".i") then
					print("Unloading stack "..A.." from BayOnTruck (dist: "..distance..")")
					Set(BayOnTruck,"Slot"..A..".i",-1)
					Set(BayOnTruck,"Slot"..A..".u",-1)
					Set(thatStack,"CarrierId.i",-1)
					Set(thatStack,"CarrierId.u",-1)
					Set(thatStack,"Loaded",false)
					thatStack = nil
					break
				end
			end
		end
	end
	if next(loadedBox) then
		for thatBox, distance in pairs(loadedBox) do
			for A = 0,7 do
				if thatBox.Id.i == Get(BayOnTruck,"Slot"..A..".i") then
					print("Unloading box "..A.." from BayOnTruck (dist: "..distance..")")
					Set(BayOnTruck,"Slot"..A..".i",-1)
					Set(BayOnTruck,"Slot"..A..".u",-1)
					Set(thatBox,"CarrierId.i",-1)
					Set(thatBox,"CarrierId.u",-1)
					Set(thatBox,"Loaded",false)
					thatBox = nil
					break
				end
			end
		end
	end
	if next(loadedMail) then
		for thatMail, distance in pairs(loadedMail) do
			for A = 0,7 do
				if thatMail.Id.i == Get(BayOnTruck,"Slot"..A..".i") then
					print("Unloading mail "..A.." from BayOnTruck (dist: "..distance..")")
					Set(BayOnTruck,"Slot"..A..".i",-1)
					Set(BayOnTruck,"Slot"..A..".u",-1)
					Set(thatMail,"CarrierId.i",-1)
					Set(thatMail,"CarrierId.u",-1)
					Set(thatMail,"Loaded",false)
					break
				end
			end
		end
	end
	loadedStack = nil
	loadedBox = nil
	loadedMail = nil
	
	BayOnTruck.Delete()
	TakeAwayBay = nil
end

function SwapRealDeliveries()
	print("---")
	print("SwapRealDeliveries "..this.BayNr)
	local RealBayFound = false
	if not Exists(MyTrafficTerminal) then FindMyTrafficTerminal() end
	local RealDeliveries = Find(MyTrafficTerminal,"TmpCargoTruckBay",5)
	for thatBay, dist in pairs(RealDeliveries) do
		if thatBay.HomeUID == MyTruck.HomeUID and thatBay.TruckBayNr == this.BayNr then
			RealBay = thatBay
			RealBayFound = true
			print("RealBay "..this.BayNr.." found at "..dist)
			break
		end
	end
	if RealBayFound == true then
		local DummyBoxes = Find(BayOnTruck,"CargoDeliveries",3)
		for thatDummy, dist in pairs(DummyBoxes) do
			if thatDummy.HomeUID == MyTruck.HomeUID and thatDummy.TruckBayNr == this.BayNr then
				print("DummyBox found at "..dist..", swap with empty packaging")
				local newEmptyPackage = Object.Spawn("CargoDeliveriesEmpty",thatDummy.Pos.x,thatDummy.Pos.y)
				newEmptyPackage.Tooltip = thatDummy.Tooltip.."\n -> Cargo delivered, this box gets dumped."
				thatDummy.Delete()
			end
		end
		for D = 0,7 do
			if Get(RealBay,"Slot"..D..".i") > -1 then
				Set(BayOnTruck,"Slot"..D..".i",Get(RealBay,"Slot"..D..".i"))
				Set(BayOnTruck,"Slot"..D..".u",Get(RealBay,"Slot"..D..".u"))
				Set(RealBay,"Slot"..D..".i",-1)
				Set(RealBay,"Slot"..D..".u",-1)
			end
		end
		RealBay.Delete()
	end
end

function LoadTakeAwayBayOnHook(cargoType)
	print("---")
	print("LoadTakeAwayBayOnHook "..this.BayNr)
	if not Exists(MyTruck) then FindMyTruck() end
	if not Exists(TakeAwayBay) then FindBays(this.BayNr) end
	Set(MyHook,"Slot0.i",TakeAwayBay.Id.i)
	Set(MyHook,"Slot0.u",TakeAwayBay.Id.u)
	Set(TakeAwayBay,"CarrierId.i",MyHook.Id.i)
	Set(TakeAwayBay,"CarrierId.u",MyHook.Id.u)
	Set(TakeAwayBay,"Loaded",true)
	if Get(TakeAwayBay,"CargoAmount") < 8 then
		ConsolidateTakeAwayBay(cargoType)	-- loads more stuff from the various cargo loaders if available, since the stopsign suspends checking for stuff when an ordered truck is arriving
	end
	SpawnSupplyTruck(TakeAwayBay) -- get rid of the exports by spawning a default supplytruck now, this prevents exported stuff from being grabbed by workmen after it got placed on exportstruck.
end

function SpawnSupplyTruck(theBay)
	local NewSupplyTruck = Object.Spawn("SupplyTruck",World.NumCellsX-1,World.NumCellsY-4+math.random()+math.random())
	Set(NewSupplyTruck,"StackTransferred",true)
	Set(NewSupplyTruck,"State","Leaving")
	Set(NewSupplyTruck,"Hidden",true)
	for H = 0,7 do
		if Get(theBay,"Slot"..H..".i") > -1 then
			Set(NewSupplyTruck,"Slot"..H..".i",Get(theBay,"Slot"..H..".i"))
			Set(NewSupplyTruck,"Slot"..H..".u",Get(theBay,"Slot"..H..".u"))
			Set(theBay,"Slot"..H..".i",-1)
			Set(theBay,"Slot"..H..".u",-1)
			local newExports = Object.Spawn("CargoExports",theBay.Pos.x,theBay.Pos.y)	-- spawn dummy boxes for export
			Set(theBay,"Slot"..H..".i",newExports.Id.i)
			Set(theBay,"Slot"..H..".u",newExports.Id.u)
			Set(newExports,"CarrierId.i",theBay.Id.i)
			Set(newExports,"CarrierId.u",theBay.Id.u)
			newExports.Loaded = true
			newExports.Tooltip = "Cargo ready for exports"
		end
	end
	NewSupplyTruck.Speed = 5
end

function ConsolidateTakeAwayBay(cargoType)
	print("ConsolidateTakeAwayBay")
	FindMyLoaders(cargoType)
	local amount = 0
	local L = 3
	local E = 0
	while E <= 7 do
		if Get(TakeAwayBay,"Slot"..E..".i") == -1 then
			for L = 3,6 do
				if Exists(Loaders[L]) then
					local loaderamount = 0
					for S = 0,7 do
						if Get(Loaders[L],"Slot"..S..".i") > -1 then
							Set(Loaders[L],"CargoLoad"..S,0)
							print("Fill TakeAwayBay"..this.BayNr.." slot "..E.." with loader"..L.." slot "..S)
							Set(TakeAwayBay,"Slot"..E..".i",Get(Loaders[L],"Slot"..S..".i"))
							Set(TakeAwayBay,"Slot"..E..".u",Get(Loaders[L],"Slot"..S..".u"))
							Set(Loaders[L],"Slot"..S..".i",-1)
							Set(Loaders[L],"Slot"..S..".u",-1)
							Set(TakeAwayBay,"CargoLoad"..E,this.CargoStationID)
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
		end
		loaded = nil
		E = E + 1
	end
	for C = 0,7 do
		if Get(TakeAwayBay,"CargoLoad"..C) == this.CargoStationID then
			amount = amount + 1
		end
	end
	Set(TakeAwayBay,"CargoAmount",amount)
	if amount < 8 and cargoType ~= "Emergency" then
		print("Adding any new cargo")
		if not Exists(MyChecker) then FindMyLoadChecker() end
		for _, typ in pairs(ObjectsToLoad) do
			local nearbyObjects = Find(MyChecker,typ,4)
			for thatObject, _ in pairs(nearbyObjects) do
				if not thatObject.Loaded then
					for S = 7,0,-1 do
						if Get(TakeAwayBay,"Slot"..S..".i") == -1 then
							amount = amount + 1
							if thatObject.Type == "Garbage" then
								local newGarbage = Object.Spawn("CargoGarbage",thatObject.Pos.x,thatObject.Pos.y)
								newGarbage.SubType = thatObject.SubType
								thatObject.Delete()
								thatObject = newGarbage
							end
							print("Loading "..thatObject.Type.." in "..TakeAwayBay.Type.." "..L.." Slot "..S)
							Set(TakeAwayBay,"Slot"..S..".i",thatObject.Id.i)
							Set(TakeAwayBay,"Slot"..S..".u",thatObject.Id.u)
							Set(thatObject,"CarrierId.i",TakeAwayBay.Id.i)
							Set(thatObject,"CarrierId.u",TakeAwayBay.Id.u)
							Set(thatObject,"Loaded",true)
							Set(TakeAwayBay,"CargoLoad"..S,this.CargoStationID)
							Set(TakeAwayBay,"CargoAmount",TakeAwayBay.CargoAmount + 1)
							break
						end
						if amount >= 8 then break end
					end
				end
			end
			nearbyObjects = nil
			if amount >= 8 then break end
		end
	end
	Loaders = nil
	TakeAwayBay.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",TakeAwayBay.TruckBayNr,"N",TakeAwayBay.CargoAmount,"A" }
end

function AnyNewCargoAvailable(cargoType)
	print("AnyNewCargoAvailable "..cargoType)
	
	local somethingAvailable = false
	if not Exists(MyChecker) then FindMyLoadChecker() end
	for _, typ in pairs(ObjectsToLoad) do
		local nearbyObjects = Find(MyChecker,typ,4)
		for thatObject, _ in pairs(nearbyObjects) do
			if not thatObject.Loaded then
				somethingAvailable = true
				break
			end
		end
		nearbyObject = nil
		if somethingAvailable == true then break end
	end
	
	if somethingAvailable == true then
	
		if not Exists(TakeAwayBay) then
			local X,Y = 0,0
			if math.random() > 0.5 then
				X = this.CheckPointX-0.5 + (math.random(1,10) / 10) + 0.25
				Y = this.CheckPointY-1.25 + (math.random(1,10) / 10) - 0.25
			else
				X = this.CheckPointX+0.5 - (math.random(1,10) / 10) - 0.25
				Y = this.CheckPointY-0.25 - (math.random(1,10) / 10) - 0.25
			end
			TakeAwayBay = Object.Spawn("CargoTruckBay",X,Y)
			Set(TakeAwayBay,"CargoStationID",this.CargoStationID)
			Set(TakeAwayBay,"HomeUID",this.HomeUID)
			Set(TakeAwayBay,"TruckBayNr",this.BayNr)
			for i = 0,7 do
				Set(TakeAwayBay,"CargoLoad"..i,0)
			end
			Set(TakeAwayBay,"CargoAmount",0)
			TheCargoAmount = 0
			Set(this,"RandomSpotX",TakeAwayBay.Pos.x)
			Set(this,"RandomSpotY",TakeAwayBay.Pos.y)
			print("TakeAwayBay "..this.BayNr.." spawned at RandomX: "..this.RandomSpotX.." RandomY: "..this.RandomSpotY)
			TakeAwayBay.Tooltip = { "tooltip_Bay",this.HomeUID,"H",this.CargoStationID,"I",TakeAwayBay.TruckBayNr,"N",TakeAwayBay.CargoAmount,"A" }
		end
		ConsolidateTakeAwayBay(cargoType)
	end
	return somethingAvailable
end

function LoadTakeAwayBayOnTruck()
	print("---")
	print("LoadTakeAwayBayOnTruck "..this.BayNr)
	if not Exists(MyHook) then FindMyHook() end
	if not Exists(MyTruck) then FindMyTruck() end
	if not Exists(TakeAwayBay) then FindBays(this.BayNr) end
	Set(MyHook,"Slot0.i",-1)
	Set(MyHook,"Slot0.u",-1)
	Set(TakeAwayBay,"CarrierId.i",-1)
	Set(TakeAwayBay,"CarrierId.u",-1)
	Set(TakeAwayBay,"Pos.x",MyTruck.Pos.x)
	Set(TakeAwayBay,"Loaded",false)
	Set(TakeAwayBay,"HomeUID",MyTruck.HomeUID)
	Set(TakeAwayBay,"CargoStationID",0)
	TakeAwayBay.Tooltip = { "tooltip_Bay",MyTruck.HomeUID,"H",this.CargoStationID,"I",TakeAwayBay.TruckBayNr,"N",TakeAwayBay.CargoAmount,"A" }
	Set(MyTruck,"TotalCargoAmount",MyTruck.TotalCargoAmount+TakeAwayBay.CargoAmount)
	TakeAwayBay = nil
end

function StopInCentre(cargoType)
	print("---")
	print("StopInCentre")
	if not Exists(MyCrane) then FindMyCrane() end
	if not Exists(MyHook) then FindMyHook() end
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	if not Exists(MyTruck) then FindMyTruck() end
	MyHook.Pos.x = this.TruckX
	MyCrane.Pos.x = this.TruckX
	if cargoType == "Emergency" then
		Set(MyHook,"SubType",3)
	else
		Set(MyHook,"SubType",0)
	end
	
	if cargoType == "Deliveries" then
		if Get(this,"BayNr") == 1 then
			Set(this,"BayNr",2)
			FindBays(2)
			if Exists(BayOnTruck) and TheCargoAmount > 0 then
				Set(this,"GrabBayOnTruck",true)
			else
				Set(this,"BayNr",0)
				ResetStopSignQuantity()
				Set(MyTruck,"TotalCargoAmount",0)
			end
		else
			Set(this,"BayNr",0)
			ResetStopSignQuantity()
			Set(MyTruck,"TotalCargoAmount",0)
		end
		
	elseif cargoType == "Garbage" or cargoType == "Exports" or cargoType == "Emergency" then
		LoadTakeAwayBayOnTruck()
		if Get(this,"BayNr") == 1 then
			Set(this,"BayNr",2)
			FindBays(2)
			if not Exists(BayOnTruck) then
				if cargoType == "Emergency" then
					Set(this,"SubType",21)
					timePerUpdate = 1
				elseif AnyNewCargoAvailable(cargoType) == true then
					if cargoType == "Exports" then
						Set(this,"SubType",3)
					elseif cargoType == "Garbage" then
						Set(this,"SubType",5)
					end
					timePerUpdate = 1
				else
					Set(this,"BayNr",0)
				end
			else
				Set(this,"BayNr",0)
			end
		else
			Set(this,"BayNr",0)
		end
	end
	if Get(this,"BayNr") == 0 then
		StationFinished(cargoType)
	end
end

function StopAtSide(cargoType)
	print("---")
	print("StopAtSide ("..cargoType..")")
	if cargoType == "Emergency" then
		Set(MyHook,"SubType",3)
	else
		Set(MyHook,"SubType",0)
	end
	if cargoType == "Deliveries" then
		PutDeliveriesOnFloor()
	elseif cargoType == "Garbage" or cargoType == "Exports" or cargoType == "Emergency" then
		LoadTakeAwayBayOnHook(cargoType)
	end
	timePerUpdate = 1
end

function StationFinished(cargoType)
	print("---")
	print("StationFinished ("..cargoType..")")
	if cargoType == "Emergency" then
		Set(this,"SubType",19)
	else
		Set(this,"SubType",0)
	end
	Set(MyCargoStopSign,"CargoStored",0)
	Set(MyCargoStopSign,"LoadAvailable",false)
	Set(MyCargoStopSign,"InUse","no")
	Set(MyCargoStopSign,"VehicleSpawned","no")
	Set(MyCargoStopSign,"Status","Waiting...")
	MyCargoStopSign.Tooltip = { "tooltip_CargoStopSign",MyCargoStopSign.HomeUID,"X",MyCargoStopSign.CargoStationID,"Y",MyCargoStopSign.Number,"Z" }
	
	Object.CancelJob(this,"Operate"..cargoType.."Station")
	
	timePerUpdate = 1
	TakeAwayBay = nil
	BayOnTruck = nil
	RemoveLoaders()
	Set(this,"TruckID",nil)
	Set(MyTruck,"StationDone",true)
	MyTruck = nil
	print("--- SEQUENCE END ---")
end

function PrepareHook(cargoType)
	print("---")
	print("--- SEQUENCE STARTING --- PrepareHook ("..cargoType..")")
	if not Exists(MyCrane) then FindMyCrane() end
	if not Exists(MyHook) then FindMyHook() end
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	Set(MyCargoStopSign,"InUse","yes")
	Set(MyCargoStopSign,"VehicleSpawned","yes")
	Set(MyCargoStopSign,"Status","ON ROUTE")
	FindMyTruck()
	Set(this,"BayNr",1)
	FindBays(1)
	
	if cargoType == "Deliveries" then
		if Exists(BayOnTruck) then
			Object.CreateJob(this,"Operate"..cargoType.."Station")
			Set(this,"GrabBayOnTruck",true)
		else
			Set(this,"BayNr",2)
			FindBays(2)
			if Exists(BayOnTruck) and TheCargoAmount > 0 then
				Set(this,"GrabBayOnTruck",true)
			else
				Set(this,"BayNr",0)
				ResetStopSignQuantity()
				Set(MyTruck,"TotalCargoAmount",0)
			end
		end
		
	elseif cargoType == "Garbage" or cargoType == "Exports" or cargoType == "Emergency" then
		local IsOK = false
		if not Exists(BayOnTruck) and Exists(TakeAwayBay) then
			IsOK = true
		else
			Set(this,"BayNr",2)
			FindBays(2)
			if not Exists(BayOnTruck) then
				if cargoType == "Emergency" then
					IsOK = true
				elseif AnyNewCargoAvailable(cargoType) == true then
					IsOK = true
				end
			end
		end
		if IsOK == true then
			Object.CreateJob(this,"Operate"..cargoType.."Station")
			if cargoType == "Exports" then
				Set(this,"SubType",3)
			elseif cargoType == "Garbage" then
				Set(this,"SubType",5)
			elseif cargoType == "Emergency" then
				Set(this,"SubType",21)
			end
		else
			Set(this,"BayNr",0)
		end
	end
	
	if Get(this,"BayNr") == 0 then
		StationFinished(cargoType)
	end
end

function CheckForActivation()
	if this.PrepareDeliveries == true then
		this.PrepareDeliveries = nil
		PrepareHook("Deliveries")
	elseif this.PrepareExports == true then
		this.PrepareExports = nil
		PrepareHook("Exports")
	elseif this.PrepareGarbage == true then
		this.PrepareGarbage = nil
		PrepareHook("Garbage")
	elseif this.PrepareEmergency == true then
		this.PrepareEmergency = nil
		PrepareHook("Emergency")
	elseif this.PrepareIntake == true then
		this.PrepareIntake = nil
		ActivateIntake()
	elseif this.PrepareCallout == true then
		this.PrepareCallout = nil
		ActivateCallout()
	end
end

function JobComplete_ActivateDeliveriesStation()
	Set(this,"ActivateJob",nil)
	Object.CancelJob(this,"ActivateDeliveriesStation")
	PrepareHook("Deliveries")
end

function JobComplete_ActivateExportsStation()
	Set(this,"ActivateJob",nil)
	Object.CancelJob(this,"ActivateExportsStation")
	PrepareHook("Exports")
end

function JobComplete_ActivateGarbageStation()
	Set(this,"ActivateJob",nil)
	Object.CancelJob(this,"ActivateGarbageStation")
	PrepareHook("Garbage")
end

function JobComplete_ActivateEmergencyStation()
	Set(this,"ActivateJob",nil)
	Object.CancelJob(this,"ActivateEmergencyStation")
	PrepareHook("Emergency")
end

function JobComplete_ActivateIntakeStation()
	Set(this,"ActivateJob",nil)
	Object.CancelJob(this,"ActivateIntakeStation")
	ActivateIntake()
end

function ActivateIntake()
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	Set(this,"BayNr",1)
	FindMyTruck()
	FindBays(1)
	if TheCargoAmount == 0 then
		Set(this,"BayNr",2)
		FindBays(2)
		if TheCargoAmount == 0 then
			Set(this,"BayNr",0)
		end
	end
	if Get(this,"BayNr") > 0 then
		Set(this,"SubType",18)
		MyPrisonerHolders = Find(BayOnTruck,"PrisonerStackHolder",10)
		if next(MyPrisonerHolders) then
			for L = 0,7 do
				for thatPrisonerHolder, dist in pairs(MyPrisonerHolders) do
					if thatPrisonerHolder.Id.i == Get(BayOnTruck,"Slot"..L..".i") then
						Set(BayOnTruck,"Slot"..L..".i",-1)
						Set(BayOnTruck,"Slot"..L..".u",-1)
						Set(thatPrisonerHolder,"CarrierId.i",-1)
						Set(thatPrisonerHolder,"CarrierId.u",-1)
						Set(thatPrisonerHolder,"Loaded",false)
						Set(thatPrisonerHolder,"Unloaded",true)
						Set(thatPrisonerHolder,"HomeUID",this.CargoStationID)
						print("Unloaded prisonerholder "..L.." at dist "..dist.." from bay "..this.BayNr)
					end
				end
			end
		end
		Object.CreateJob(this,"OperateIntakeStation")
	else
		IntakeFinished()
	end
end

function UnloadPrisonersFromTruck(theSidePos,theX,theY)
	print("---")
	print("UnloadPrisonersFromTruck bay "..this.BayNr)
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	if not Exists(MyTruck) then FindMyTruck() end
	if not Exists(BayOnTruck) then FindBays(this.BayNr) end
	print("BayOnTruck "..this.BayNr.." holds "..BayOnTruck.CargoAmount.." prisoners")
	if TheCargoAmount > 0 then
		if MyPrisonerHolders == nil then MyPrisonerHolders = Find(BayOnTruck,"PrisonerStackHolder",10) end
		if next(MyPrisonerHolders) then
			local foundH = false
			for thatPrisonerHolder, dist in pairs(MyPrisonerHolders) do
				if Get(thatPrisonerHolder,"Unloaded") == true and thatPrisonerHolder.HomeUID == this.CargoStationID then
					if Get(thatPrisonerHolder,"SlingShot") == true then
						print("Slingshot done for prisoner "..TheCargoAmount)
						local Prisoners = Find(thatPrisonerHolder,"Prisoner",1)
						for thatPrisoner, dist in pairs(Prisoners) do
							if thatPrisoner.Id.i == Get(thatPrisonerHolder,"Slot0.i") then
								Set(thatPrisoner,"CarrierId.i",-1)
								Set(thatPrisoner,"CarrierId.u",-1)
								Set(thatPrisoner,"Loaded",false)
								Set(thatPrisoner,"Locked",false)
								Set(thatPrisoner,"Shackled",true)
								if MyCargoStopSign.IsIntake == "yes" then
									Set(thatPrisoner,"IsNewIntake",true)
								end
							end
						end
						Prisoners = nil
						thatPrisonerHolder.Delete()
						foundH = true
						Set(BayOnTruck,"CargoAmount",BayOnTruck.CargoAmount - 1)
						TheCargoAmount = TheCargoAmount - 1
						break
					else
						print("Slingshot active for prisoner "..TheCargoAmount)
						Set(thatPrisonerHolder,"Pos.x",theSidePos)
						Set(thatPrisonerHolder,"Pos.y",this.Pos.y-2.75)
						Set(thatPrisonerHolder,"SlingShot",true)
						Object.ApplyVelocity(thatPrisonerHolder,theX,theY,true)
						foundH = true
						break
					end
				end
			end
			if foundH == false then	-- to prevent looping in case something went wrong
				Set(BayOnTruck,"CargoAmount",0)
				TheCargoAmount = 0
			end
		else	-- to prevent looping in case something went wrong
			Set(BayOnTruck,"CargoAmount",0)
			TheCargoAmount = 0
		end
	end
	if Get(BayOnTruck,"CargoAmount") <= 0 then
		if Get(this,"BayNr") == 1 then
			BayOnTruck.Delete()
			BayOnTruck = nil
			Set(this,"BayNr",2)
			FindBays(2)
			if TheCargoAmount == 0 then
				BayOnTruck.Delete()
				Set(this,"BayNr",0)
			else
				MyPrisonerHolders = Find(BayOnTruck,"PrisonerStackHolder",10)
				if next(MyPrisonerHolders) then
					for L = 0,7 do
						for thatPrisonerHolder, dist in pairs(MyPrisonerHolders) do
							if thatPrisonerHolder.Id.i == Get(BayOnTruck,"Slot"..L..".i") then
								Set(BayOnTruck,"Slot"..L..".i",-1)
								Set(BayOnTruck,"Slot"..L..".u",-1)
								Set(thatPrisonerHolder,"CarrierId.i",-1)
								Set(thatPrisonerHolder,"CarrierId.u",-1)
								Set(thatPrisonerHolder,"Loaded",false)
								Set(thatPrisonerHolder,"Unloaded",true)
								Set(thatPrisonerHolder,"HomeUID",this.CargoStationID)
								print("Unloaded prisonerholder "..L.." at dist "..dist.." from bay "..this.BayNr)
							end
						end
					end
				end
			end
		else
			BayOnTruck.Delete()
			BayOnTruck = nil
			Set(this,"BayNr",0)
		end
	end
	if Get(this,"BayNr") == 0 then
		IntakeFinished()
	end
end

function IntakeFinished()
	print("---")
	print("IntakeFinished")
	Set(this,"SubType",8)
	Set(MyCargoStopSign,"PrisQuantity",0)
	Set(MyCargoStopSign,"InUse","no")
	Set(MyCargoStopSign,"VehicleSpawned","no")
	Set(MyCargoStopSign,"Status","Waiting...")
	MyCargoStopSign.Tooltip = { "tooltip_CargoStopSign",MyCargoStopSign.HomeUID,"X",MyCargoStopSign.CargoStationID,"Y",MyCargoStopSign.Number,"Z" }
	
	Object.CancelJob(this,"OperateIntakeStation")
	
	timePerUpdate = 1
	Set(this,"TruckID",nil)	
	BayOnTruck = nil
	Set(MyTruck,"StationDone",true)
	MyTruck = nil
	print("--- SEQUENCE END ---")
end

function JobComplete_ActivateCalloutStation()
	Set(this,"ActivateJob",nil)
	Object.CancelJob(this,"ActivateCalloutStation")
	ActivateCallout()
end

function ActivateCallout()
	Set(this,"BayNr",1)
	FindMyTruck()
	FindBays(1)
	FindMyCalloutEntities(9)
	Set(MyTruck,"CalloutUnloaded",true)
	this.SubType = 23
	if this.RoadX < this.TruckX then	-- cargo area is on left side of the road
		local cell1 = World.GetCell(this.Pos.x+2,this.Pos.y-5)
		local cell2 = World.GetCell(this.Pos.x+2,this.Pos.y-4)
		local cell3 = World.GetCell(this.Pos.x+2,this.Pos.y-3)
		cell1.Mat = "RailwayStationRS1"	-- create temporary platform passage
		cell2.Mat = "RailwayStationRS1"
		cell3.Mat = "RailwayStationRS1"
	else
		local cell1 = World.GetCell(this.Pos.x-2,this.Pos.y-5)
		local cell2 = World.GetCell(this.Pos.x-2,this.Pos.y-4)
		local cell3 = World.GetCell(this.Pos.x-2,this.Pos.y-3)
		cell1.Mat = "RailwayStationLS1"
		cell2.Mat = "RailwayStationLS1"
		cell3.Mat = "RailwayStationLS1"
	end
	Object.CreateJob(this,"OperateCalloutStation")
end

function HandleCallout()
	local GoX = { [1] = -1.125, [2] = -0.375, [3] = 0.375, [4] = 1.125, [5] = -1.125, [6] = -0.375, [7] = 0.375, [8] = 1.125 }
	local GoY = { [1] = 0.75, [2] = 0.75, [3] = 0.75, [4] = 0.75, [5] = 1.5, [6] = 1.5, [7] = 1.5, [8] = 1.5 }
	
	if not Exists(MyCargoStopSign) then FindMyCargoStopSign() end
	if not Exists(MyTruck) then FindMyTruck() end
	if not Exists(BayOnTruck) then FindBays(this.BayNr) end
	if TheCargoAmount > 0 then
		print("BayOnTruck "..this.BayNr.." holds "..BayOnTruck.CargoAmount.." people")
		if not Exists(MyEntities[1]) then FindMyCalloutEntities(9) end
		if Get(MyCargoStopSign,"Equipment"..MyEntities[1].Type) ~= 24 then -- not a Hose for firemen
			for U = 1,8 do
				MyEntities[U].Equipment = Get(MyCargoStopSign,"Equipment"..MyEntities[U].Type)
				MyEntities[U].ClearRouting()
				MyEntities[U].AiSetTarget = false
				Set(BayOnTruck,"Slot"..(U-1)..".i",-1)
				Set(BayOnTruck,"Slot"..(U-1)..".u",-1)
				Set(MyEntities[U],"CarrierId.i",-1)
				Set(MyEntities[U],"CarrierId.u",-1)
				Set(MyEntities[U],"Loaded",false)
				if MyTruck.CalloutX ~= nil then
					MyEntities[U].NavigateTo(MyTruck.CalloutX+GoX[U],MyTruck.CalloutY+GoY[U])
				else
					MyEntities[U].NavigateTo(this.CheckPointX+GoX[U],this.CheckPointY-0.75+GoY[U])
				end
			end
			Set(this,"BayNr",0)
			timePerUpdate = 2
		else
			this.FiremanState = "DeployFiremen"
		end
		Set(BayOnTruck,"CargoAmount",0)
		TheCargoAmount = 0
	elseif Get(this,"BayNr") == 1 then
		if not Exists(MyEntity1) then FindMyCalloutEntities(10000) end
	-------------------------------------------------------------------------------------------
	-- Drop off the firemen and wait for them to return to the FireEngine
	-------------------------------------------------------------------------------------------
		if this.FiremanState == "DeployFiremen" then
			if not Exists(MyEntities[1]) then FindMyCalloutEntities(9) end
			if not this.FiremenOutside then
				if not Exists(MyFireEquipment) then FindMyFireEquipment() end
				if not this.GroupOutside then
					for A = 1,8 do
						MyEntities[A].ClearRouting()
						MyEntities[A].AiSetTarget = false
						Set(BayOnTruck,"Slot"..(A-1)..".i",-1)
						Set(BayOnTruck,"Slot"..(A-1)..".u",-1)
						Set(MyEntities[A],"CarrierId.i",-1)
						Set(MyEntities[A],"CarrierId.u",-1)
						Set(MyEntities[A],"Loaded",false)
						-- start PA 2018 code
						-- MyEntities[A].NavigateTo(this.CheckPointX+GoX[A],this.CheckPointY-0.75+GoY[A])
						-- finish PA 2018 code
						
						-- start PA Rock code
						MyEntities[A].PlayerOrderPos.x = this.CheckPointX+GoX[A]
						MyEntities[A].PlayerOrderPos.y = this.CheckPointY-0.75+GoY[A]
						-- finish PA Rock code
						MyEntities[A].AISetTarget = false
					end
					Set(this,"GroupOutside",true)
				elseif not this.ToFireEquipment then
					for B = 1,8 do
						-- start PA 2018 code
						-- MyEntities[B].NavigateTo(this.CheckPointX+GoX[B],MyFireEquipment.Pos.y+GoY[B])
						-- finish PA 2018 code
						
						-- start PA Rock code
						MyEntities[B].PlayerOrderPos.x = this.CheckPointX+GoX[B]
						MyEntities[B].PlayerOrderPos.y = MyFireEquipment.Pos.y+GoY[B]
						-- finish PA Rock code
						MyEntities[B].AISetTarget = false
					end
					Set(this,"ToFireEquipment",true)
				else
					Set(this,"FiremenOutside",true)
				end
			elseif not this.HoseDeployed then															-- deploy a hose for each firemen and do funky stuff: 
				xyHose = Object.Spawn("HoseXY",MyFireEquipment.Pos.x+1.25,MyFireEquipment.Pos.y+3.5)	-- attach them to a temporary object to get some properly aligned hoses attached to the chinook... dafuq?
				Set(xyHose,"CargoStationID",this.CargoStationID)
				for H = 1,8 do
					MyEntities[H].Equipment = 24
					MyEntities[H].ClearRouting()
					MyEntities[H].AiSetTarget = false
					MyEntities[H].FireEngine.i = xyHose.Id.i									-- ...because something looks very hardcoded and measured to fit at the normal Firetruck sprite here...
					MyEntities[H].FireEngine.u = xyHose.Id.u									-- ...as the hose will spawn a few tiles above this object, just about half the length of the firetruck perhaps (?)
					MyEntities[H].HoseOffset.HoseOffsetMetaTable.HoseOffsetSetterTable.x = 0	-- anyway it looks neater this way, otherwise the hose would spawn somewhere in the topback of the chinook
					MyEntities[H].HoseOffset.HoseOffsetMetaTable.HoseOffsetSetterTable.y = 0	-- changing these values doesn't seem to do anything, as long as it's set it will deploy a hose (?)
					MyEntities[H].AISetTarget = false
				end
				MyFireEquipment.SubType = MyFireEquipment.SubType + 1
				Set(this,"HoseDeployed",true)
				Set(this,"FiremanState","SwapFireEngine")
			end
		elseif this.FiremanState == "SwapFireEngine" then	-- Attach the firemen back to me, the REAL FireEngine, instead of my dummy FireEngine where the hooks looks much better on when it's attached...
													--   ...so I can check when my firemen are done with their job and want to go home with me instead of my hose spawner.
			if not Exists(MyEntities[1]) then FindMyCalloutEntities(9) end
			if not Exists(MyFireEquipment) then FindMyFireEquipment() end
			if not this.FireEngineSwapped then
				for F = 8,1,-1 do
					Set(MyEntities[F],"CargoStationID",MyCargoStopSign.CargoStationID)
					MyEntities[F].ClearRouting()
					MyEntities[F].AiSetTarget = false
					MyEntities[F].FireEngine.i = MyFireEquipment.Id.i
					MyEntities[F].FireEngine.u = MyFireEquipment.Id.u
					if MyTruck.CalloutX ~= nil then
						-- start PA 2018 code
						-- MyEntities[F].NavigateTo(MyTruck.CalloutX+GoX[F],MyTruck.CalloutY+GoY[F])
						-- finish PA 2018 code
						
						-- start PA Rock code
						MyEntities[F].PlayerOrderPos.x = MyTruck.CalloutX+GoX[F]
						MyEntities[F].PlayerOrderPos.y = MyTruck.CalloutY+GoY[F]
						-- finish PA Rock code
					else
						-- start PA 2018 code
						-- MyEntities[F].NavigateTo(this.CheckPointX+GoX[F],this.CheckPointY-0.75+GoY[F])
						-- finish PA 2018 code
						
						-- start PA Rock code
						MyEntities[F].PlayerOrderPos.x = this.CheckPointX+GoX[F]
						MyEntities[F].PlayerOrderPos.y = this.CheckPointY-0.75+GoY[F]
						-- finish PA Rock code
						-- 
					end
					MyEntities[F].AISetTarget = false
				end
				if not Exists(xyHose) then FindMyHose() end
				if Exists(xyHose) then xyHose.Delete() end
				Set(MyCargoStopSign,"FindFiremen",true)
				Set("FireEngineSwapped",true)
			else
				Set(this,"BayNr",0)
			end
		end
	else
		CalloutFinished()
	end
end

function CalloutFinished()
	print("---")
	print("CalloutFinished")
	if this.RoadX < this.TruckX then	-- cargo area is on left side of the road
		local cell1 = World.GetCell(this.Pos.x+2,this.Pos.y-5)
		local cell2 = World.GetCell(this.Pos.x+2,this.Pos.y-4)
		local cell3 = World.GetCell(this.Pos.x+2,this.Pos.y-3)
		cell1.Mat = "RailwayStationCR"	-- close the temporary platform passage
		cell2.Mat = "RailwayStationCR"
		cell3.Mat = "RailwayStationCR"
	else
		local cell1 = World.GetCell(this.Pos.x-2,this.Pos.y-5)
		local cell2 = World.GetCell(this.Pos.x-2,this.Pos.y-4)
		local cell3 = World.GetCell(this.Pos.x-2,this.Pos.y-3)
		cell1.Mat = "RailwayStationCL"
		cell2.Mat = "RailwayStationCL"
		cell3.Mat = "RailwayStationCL"
	end
	this.HoseDeployed = nil
	this.FiremanState = nil
	this.FiremenOutside = nil
	this.GroupOutside = nil
	this.ToFireEquipment = nil
	this.FireEngineSwapped = nil
	Set(this,"SubType",19)
	Set(MyCargoStopSign,"InUse","no")
	Set(MyCargoStopSign,"VehicleSpawned","no")
	Set(MyCargoStopSign,"Status","Waiting...")
	if Get(MyCargoStopSign,"Equipment"..MyEntities[1].Type) == 24 then	-- if callout is firemen with equipment Hose
		Set(MyCargoStopSign,"WaitForFiremen",true)
	end
	timePerUpdate = 1
	
	Object.CancelJob(this,"OperateCalloutStation")
	
	MyEntity1 = nil
	MyEntity2 = nil
	MyEntity3 = nil
	MyEntity4 = nil
	MyEntity5 = nil
	MyEntity6 = nil
	MyEntity7 = nil
	MyEntity8 = nil
	for I = 1,8 do
		MyEntities[I] = nil
	end
	Set(this,"TruckID",nil)	
	BayOnTruck = nil
	Set(MyTruck,"StationDone",true)
	MyTruck = nil
	print("--- SEQUENCE END ---")
end

function FindMyCalloutEntities(theDist)
	print("FindMyCalloutEntities")
	for C, typ in pairs(CalloutEntitiesToFind) do
		print("Finding "..CalloutEntitiesToFind[C])
		local nearbyObjects = Find(this,typ,theDist)
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
		if Exists(MyEntity1) and Exists(MyEntity2) and Exists(MyEntity3) and Exists(MyEntity4) and Exists(MyEntity5) and Exists(MyEntity6) and Exists(MyEntity7) and Exists(MyEntity8) then break end
	end
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

function FindMyHose()
	local nearbyObject = Find(this,"HoseXY",9)
	if next(nearbyObject) then
		for thatHose, distance in pairs(nearbyObject) do
			if thatHose.CargoStationID == this.CargoStationID then
				thatHose = xyHose
				print("Hose found at "..distance)
			end
		end
	end
	nearbyObject = nil
	if not Exists(xyHose) then
		print(" -- ERROR --- Hose not found")
	end
end

function ResetStopSignQuantity()
	Set(MyCargoStopSign,"FoodQuantity",0)
	Set(MyCargoStopSign,"VendingQuantity",0)
	Set(MyCargoStopSign,"BuildingQuantity",0)
	Set(MyCargoStopSign,"FloorsQuantity",0)
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
	MyCargoStopSign.Tooltip = { "tooltip_CargoStopSign",MyCargoStopSign.HomeUID,"X",MyCargoStopSign.CargoStationID,"Y",MyCargoStopSign.Number,"Z" }
end

function RemoveLoaders()
	print("RemoveLoaders")
	local TruckBayObjects = { "CargoTruckBay","IntakeTruckBay","EmergencyTruckBay" }
	local removeChecker = Object.Spawn("LoadChecker",this.CheckPointX,this.CheckPointY)
	for j = 1, #TruckBayObjects do
		for thatBay in next, Find(removeChecker,TruckBayObjects[j],5) do
			if thatBay.CargoStationID == this.CargoStationID then
			print("Removing "..thatBay.Type.." BayNr "..thatBay.TruckBayNr)
				thatBay.Delete()
			end
		end
	end
	removeChecker.Delete()
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
