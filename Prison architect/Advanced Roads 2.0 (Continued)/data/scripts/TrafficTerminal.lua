
local timeTot = 0
local timeVal = 0

local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

local TreeTypes = { "Tree", "SpookyTree", "SnowyConiferTree", "CactusTree", "SakuraTree", "PalmTree", "Bush" }

local FoodStack		= { "Ingredients", "FoodTray", "StaffFoodBoxed", "Cooker", "Fridge", "Sink", "ServingTable", "Sprinkler"
					}
					
local LaundryStack	= { "PrisonerUniform", "VendingStackPrisonerUniform",
						"LaundryMachine", "IroningBoard", "LaundryBasket", "IroningBoardShort"
					}
					
local VendingStack	= { "ShopGoods", "LibraryBookUnsorted",
						"PaperCup", "WaterBottle", "VendingCoffee", "VendingFruit", "VendingWater", "VendingSnack", "VendingSandwich",
						"VendingStackFruit", "VendingStackSandwich", "VendingStackBurger", "VendingStackWater",
						"VendingStackSnack", "VendingStackCoffee", "VendingStackSoup", "VendingStackShop",
						"VendingStackNews", "VendingStackMedicine", "VendingStackOrangeJuice", "VendingStackWaterCooler",
						"VendingLotteryTicket", "VendingStackLottery"
					}
					
local ForestStack	= { "StackTrees", "ForestryTreeSapling" }
					
local Workshop1Stack = { "SheetMetal", "Wood", "WorkshopSaw", "WorkshopPress", "CarpenterTable"
					}

local Workshop2Stack = { "CottonSeeds", "CottonSeed", "Compost", "ClothSpool", "CottonCompost", "CottonDDT",
						 "GardenSeed", "GardenCompost", "GardenDDT", "GardenFertilizer", "R4_GardenSeed",
						 "R4_GardenCompost", "R4_GardenFertilizer", "R4_GardenDDT", "R4_GreenhouseSeed",
						 "R4_GreenhouseCompost", "R4_GreenhouseFertilizer", "R4_GreenhouseDDT"
					}

local Workshop3Stack = { "DirtyMoney"
					}
					
local Workshop4Stack = { "SheetAluminium"
					}

local Workshop5Stack = { "ServerParts", "PrinterPaperSmall", "PrinterPaperLarge", "PrinterTonerSmall",
						"PrinterTonerLarge", "PrinterDrumkitSmall", "PrinterDrumkitLarge"
					}

local BuildingStack = { "Brick", "Concrete", "Metal", "Steel",
						"ElectricalCable", "PipeLarge", "PipeSmall", "PipeHotWater",
						"PowerStation", "Capacitor", "WaterPumpStation", "WaterBoiler"
					}

local FloorStack	= { "FloorMaterial", "GrassTurf" }

-- A table holding all the tables above
local StackTypes = { FoodStack, LaundryStack, VendingStack, ForestStack, Workshop1Stack, Workshop2Stack, Workshop3Stack, Workshop4Stack, Workshop5Stack, BuildingStack, FloorStack }

-- StackDest is also the priority order to deliver
local StackDest   = { [1] = "Food",[2] = "Laundry",[3] = "Vending", [4] = "Forest", [5] = "Workshop1", [6] = "Workshop2", [7] = "Workshop3", [8] = "Workshop4", [9] = "Workshop5",[10] = "Building", [11] = "Floor",  [12] = "Other" }
local TooltipDest = { [1] = "Food Distribution",[2] = "Laundry Distribution",[3] = "Vending Distribution", [4] = "Forestry Materials", [5] = "Workshop Materials", [6] = "Plantation/Garden/Greenhouse", [7] = "Money Laundry", [8] = "Phone Factory", [9] = "Computer Parts",[10] = "Construction Site", [11] = "Floors",  [12] = "Other" }

-- Will become a table with all sorted items incoming at the Traffic Terminal room and waiting to be delivered
local StackInQueue = {  Food = {},
						Laundry = {},
						Vending = {},
						Forest = {},
						Workshop1 = {},
						Workshop2 = {},
						Workshop3 = {},
						Workshop4 = {},
						Workshop5 = {},
						Building = {},
						Floor = {},
						Other = {}
					}

local TotalQueuedStack = 0
local CleanUpCounter = 0

-- coordinates used to store items placed in an X-shape on a certain floor tile (instead of putting everything just on top of each other)
local StackSpotsCounter = 0
local StackSpots = { [1] = { X = -0.05, Y = -0.05 },
					 [2] = { X = -0.10, Y = -0.10 },
					 [3] = { X = -0.15, Y = -0.15 },
					 [4] = { X = -0.20, Y = -0.20 },
					 [5] = { X = 0.05, Y = 0.05 },
					 [6] = { X = 0.10, Y = 0.10 },
					 [7] = { X = 0.15, Y = 0.15 },
					 [8] = { X = 0.20, Y = 0.20 },
					 [9] = { X = 0.05, Y = -0.05 },
					 [10] = { X = 0.10, Y = -0.10 },
					 [11] = { X = 0.15, Y = -0.15 },
					 [12] = { X = 0.20, Y = -0.20 },
					 [13] = { X = -0.05, Y = 0.05 },
					 [14] = { X = -0.10, Y = 0.10 },
					 [15] = { X = -0.15, Y = 0.15 },
					 [16] = { X = -0.20, Y = 0.20 },
					}

local PrisonerDest  = { [1] = "MinSec",[2] = "Normal",[3] = "MaxSec", [4] = "Protected", [5] = "SuperMax", [6] = "DeathRow", [7] = "Insane" }

-- A table holding all prisoners at the TrafficTerminal
local PrisonersInQueue = {	MinSec = {},
							Normal = {},
							MaxSec = {},
							Protected = {},
							SuperMax = {},
							DeathRow = {},
							Insane = {}
						}
						
local TotalQueuedPrisoners = 0

local HolderXY = { [1] = { X = 2,Y = 2 }, [2] = { X = 3,Y = 2 }, [3] = { X = 4,Y = 2 }, [4] = { X = 5,Y = 2 }, [5] = { X = 6,Y = 2 }, [6] = { X = 7,Y = 2 }, 
				   [7] = { X = 2,Y = 6 }, [8] = { X = 3,Y = 6 }, [9] = { X = 4,Y = 6 },[10] = { X = 5,Y = 6 },[11] = { X = 6,Y = 6 },[12] = { X = 7,Y = 6 }
				}	-- X/Y spots of the QueuedStackAreaTop and QueuedStackAreaBottom rows where sorted stack is kept until it gets delivered

local CurX = 1
local CurY = 1
local AllQuantity = 0

-- Will become a table with all cargo stations / helipads on the map
local Traffic = {}

function Create()
	World.CheatsEnabled=true
	World.ImmediateMaterials = true	-- no supply trucks should spawn, everything goes directly to the traffic terminal
end

function Update(timePassed)
	if timePerUpdate == nil then
		if not this.InitDone then
			DoOnce()
		end
		if this.TruckLights == nil then Set(this,"TruckLights","always") end
	-------------------------------------------------------------------------------------------
		Interface.AddComponent(this,"DeleteTerminal", "Button", "tooltip_TrafficTerminal_Button_DeleteTerminal")
		Interface.AddComponent(this,"TT_CaptionAnimate", "Caption", "tooltip_TrafficTerminal_AnimateChinook")
		Interface.AddComponent(this,"toggleAnimateChinook", "Button", "tooltip_TrafficTerminal_Button_AnimateChinook",this.AnimateChinook,"X")
		Interface.AddComponent(this,"toggleTruckLights", "Button", "tooltip_TrafficTerminal_Button_TruckLights",this.TruckLights,"X")
		Interface.AddComponent(this,"TT_CaptionSeparatorLine", "Caption", "tooltip_TrafficTerminal_separatorline")
		Interface.AddComponent(this,"toggleDeliveryMethod", "Button", "tooltip_TrafficTerminal_DeliveryMethod",this.DeliveryMethod,"X")
		Interface.AddComponent(this,"toggleIntakeMethod", "Button", "tooltip_TrafficTerminal_IntakeMethod",this.IntakeMethod,"X")
		Interface.AddComponent(this,"RemoveStack", "Button", "tooltip_TrafficTerminal_Button_DeleteStack")
		Interface.AddComponent(this,"RemovePrisoners", "Button", "tooltip_TrafficTerminal_Button_DeletePrisoners")
		AddSnitchButtons()
		FindMyStackTransferrer()			-- the thing at the top of the default road where supplytrucks spawn
		FindMyDisplays()					-- my display panels
		FindQueuedStackAreas()				-- the areas above and below the terminal where sorted stack is stored for delivery
		FindCargoStations()					-- all stations and helipads on the map
		FindKnownPrisoners()				-- rebuild the PrisonersInQueue tables with prisoners hidden below the terminal
		if not OtherTerminalDeleted then	-- rebuild the StackInQueue tables with what was sorted already after loading a game
			CurX,CurY,Forced = 2,2,true		-- orders CollectStack to put MyChecker at the Food tile of QueuedStackAreaTop
		end
		timePerUpdate = 0.15
	else
	
		if this.UpdateTraffic == true then
			FindCargoStations()
			timeTot = timePerUpdate
			return
		end
		
		timeTot = timeTot + timePassed
		if timeTot >= timePerUpdate then
			timeTot = 0
			
			if CurX == 0 and CurY == 0 then
				if TotalQueuedPrisoners > 0 then
					ResetPrisonerNeeds()
				end
				CurX,CurY = 1,1
				CleanTerminalFloor()
			else
				if Tick then
					if AutoSpawnCargoActive == true then
						if CurX == 5 then
							AutoSpawn("Cargo")
						end
					end
					CollectStack(this.Pos.x,this.Pos.y)
					Tick = nil
				else
					if AutoSpawnIntakeActive == true then
						if CurX == 1 then
							AutoSpawn("Intake")
						end
					end
					TransferStack()
					Tick = true
				end
			end
		end
	end
end

function ValidateExistingStations()			-- check if existing cargo stations / helipads are still on the map
	local AllOK = true
	for E = 1, #Traffic do
		if Traffic[E] == nil or not Exists(Traffic[E].CargoStation) then
			AllOK = false					-- something got removed by the player
			break
		end
	end
	if AllOK == false then
		FindCargoStations()					-- build a new table of existing stations
	end
end




	-------------------------------------------------------------------------------------------
	-- Cargo related
	-------------------------------------------------------------------------------------------


function InStackGroup(theContent,theGroup)	-- compares an item agains the given group to see if the content matches
	for _, typ in pairs(theGroup) do
		if theContent == typ then
			return true
		end
	end
	return false
end


	-------------------------------------------------------------------------------------------
	-- Transfers stack from the default road spot where supply trucks spawn and leave it behind
	-------------------------------------------------------------------------------------------
function TransferStack()
	if not Exists(MyStackTransferrer) then FindMyStackTransferrer() end
	MyStackTransferrer.Pos.x = World.OriginW+World.OriginX-10
	MyStackTransferrer.Pos.y = 2
	if MyStackTransferrer.NewLoadAvailable == true then	-- set by supply trucks before they delete themselves
		local IncomingStuffToFind = { "Stack", "Box", "MailSatchel" }
		for S, typ in pairs(IncomingStuffToFind) do
			local incomingObjects = Find(MyStackTransferrer,typ,5)
			if next(incomingObjects) then
				local A = 0
				for thatItem, distance in pairs(incomingObjects) do
					Set(thatItem,"CarrierId.i",-1)
					Set(thatItem,"CarrierId.u",-1)
					Set(thatItem,"Loaded",false)
					Set(thatItem,"Hidden",false)
					local X = this.Pos.x-3+A	-- put the stuff on a random floor row at the terminal room
					local Y = this.Pos.y
					if math.random() > 0.90 then X = this.Pos.x-3+A; Y = this.Pos.y-3
					elseif math.random() > 0.70 then X = this.Pos.x-3+A; Y = this.Pos.y-1
					elseif math.random() > 0.50 then X = this.Pos.x-3+A; Y = this.Pos.y
					elseif math.random() > 0.30 then X = this.Pos.x+4-A; Y = this.Pos.y+1
					elseif math.random() > 0.20 then X = this.Pos.x+4-A; Y = this.Pos.y
					else X = this.Pos.x+4-A; Y = this.Pos.y-1
					end
					Set(thatItem,"Pos.x",X)
					Set(thatItem,"Pos.y",Y)
					Object.ApplyVelocity(thatItem,-0.5+math.random(),-0.5+math.random(),false)
					Set(thatItem,"Tooltip","Transferred by Traffic Terminal\nID: "..thatItem.Id.i)
					print(thatItem.Type.." ID: "..thatItem.Id.i.." Transferred by Traffic Terminal")
					A = A + 1
					if A > 7 then A = 0 end
				end
			end
			incomingObjects = nil
		end
		MyStackTransferrer.NewLoadAvailable = nil
	end
	if MyStackTransferrer.NewIntakeAvailable == true then	-- set by prisoner buses before they delete themselves
		AddNewPrisoners()
		MyStackTransferrer.NewIntakeAvailable = nil
	end
end


	-------------------------------------------------------------------------------------------
	-- Walks from top left to bottom right of the terminal floor to consolidate stack onto several stack holders; checks 1 spot per Update() cycle
	-------------------------------------------------------------------------------------------
function CollectStack(PosX,PosY)
	local X = PosX-4
	local Y = PosY-4
	local foundSomething = false
	
	if not Exists(MyChecker) then
		FindMyChecker(PosX,PosY)
	end
	
	MyChecker.Pos.x, MyChecker.Pos.y = X+CurX,Y+CurY
	local StuffToFind = { "Stack", "Box", "MailSatchel" }
	for S, typ in pairs(StuffToFind) do
		local nearbyObjects = Find(MyChecker,typ,0.79)
		for thatItem, distance in pairs(nearbyObjects) do
			local itemOK = false
			local SortedTo = 12
			if not Forced and Get(thatItem,"Sorted") == nil then
				if thatItem.Type ~= "MailSatchel" then
					Set(thatItem,"Contains",thatItem.Contents)
				else
					Set(thatItem,"Contains","MailSatchel")
				end
				print("CollectStack X:"..CurX.." Y:"..CurY.." -->> Processing new item: "..thatItem.Contains.." ID: "..thatItem.Id.i.." @ distance "..distance)
				local done = false
				for T = 1,11 do
					if InStackGroup(thatItem.Contains,StackTypes[T]) == true then	-- item belongs to one of the predefined stack types
						SortedTo = T
						done = true
						break
					end
				end
				if done == false then												-- item goes to Other stackholder
					SortedTo = 12
				end
				Set(thatItem,"Sorted",SortedTo)
				itemOK = true
			elseif Forced and Get(thatItem,"Sorted") ~= nil then
				print("CollectStack X:"..CurX.." Y:"..CurY.." -->> Processing known item: "..thatItem.Contains.." ID: "..thatItem.Id.i.." @ distance "..distance)
				SortedTo = Get(thatItem,"Sorted")
				itemOK = true
			end
			
			if itemOK == true then
				local ForDestination = StackDest[SortedTo]
				table.insert( StackInQueue[ForDestination], thatItem )		-- add the item at the end of the specific StackInQueue table
				local num = #StackInQueue[ForDestination]					-- find out the total number of records of this table so whe know where the item is
				
				local Sort,Cont = 12,"Unknown" -- needed for a prior bug which has been fixed now
				if Get(thatItem,"Sorted") ~= nil then Sort = Get(thatItem,"Sorted") end
				if Get(thatItem,"Contains") ~= nil then Cont = Get(thatItem,"Contains") end
				
				Set(StackInQueue[ForDestination][ num ],"Tooltip","\n===== PACKING SLIP =====\nSorted by Traffic Terminal\n -> ID: "..thatItem.Id.i.."\n -> Sorted to "..TooltipDest[Sort].."\n -> Contains "..Cont.."\n=====================\n\n -> Status: waiting...\n\n=====================\nPACKAGE DELIVERY NOTES\n -> Toggle =D= button on Traffic Terminal to AUTO\n -> Set 'Type: DELIVERIES' on Cargo Station/Helipad\n -> Set 'CARGO: buttons' on Cargo Station/Helipad\n -> Set 'ENABLED: YES' on Cargo Station/Helipad")
				print("CollectStack X:"..CurX.." Y:"..CurY.." -->> Sorted "..Cont.." to "..TooltipDest[Sort])
				print("StackInQueue "..ForDestination.." has "..num.." records")
				StackSpotsCounter = StackSpotsCounter + 1	-- puts stuff on the specific tiles at QueuedStackAreas, laying items on top of each other in an X shape
				Set(StackInQueue[ForDestination][ num ],"Pos.x",X+HolderXY[Sort].X + StackSpots[StackSpotsCounter].X)
				Set(StackInQueue[ForDestination][ num ],"Pos.y",Y+HolderXY[Sort].Y + StackSpots[StackSpotsCounter].Y)
				if StackSpotsCounter >= 16 then StackSpotsCounter = 0 end	-- there are 16 spots for drawing an X on the floor tile
				foundSomething = true
			end
		end
		nearbyObjects = nil
	end
	
	TotalQueuedStack = 0
	for T = 1,12 do
		TotalQueuedStack = TotalQueuedStack + #StackInQueue[StackDest[T]]
	end
	
	this.Tooltip = { "tooltip_TrafficTerminal",this.DeliveryMethod,"X",this.IntakeMethod,"Y",TotalQueuedStack,"A",TotalQueuedPrisoners,"B",
	#PrisonersInQueue[PrisonerDest[1]],"C",
	#PrisonersInQueue[PrisonerDest[2]],"D",
	#PrisonersInQueue[PrisonerDest[3]],"E",
	#PrisonersInQueue[PrisonerDest[4]],"F",
	#PrisonersInQueue[PrisonerDest[5]],"G",
	#PrisonersInQueue[PrisonerDest[6]],"H",
	#PrisonersInQueue[PrisonerDest[7]],"I" }
	
	QueuedStackAreaTop.Tooltip = { "tooltip_StackInQueueTop_Totals",
	#StackInQueue[StackDest[1]],"A",
	#StackInQueue[StackDest[2]],"B",
	#StackInQueue[StackDest[3]],"C",
	#StackInQueue[StackDest[4]],"D",
	#StackInQueue[StackDest[5]],"E",
	#StackInQueue[StackDest[6]],"F" }
	
	QueuedStackAreaBottom.Tooltip = { "tooltip_StackInQueueBottom_Totals",
	#StackInQueue[StackDest[7]],"A",
	#StackInQueue[StackDest[8]],"B",
	#StackInQueue[StackDest[9]],"C",
	#StackInQueue[StackDest[10]],"D",
	#StackInQueue[StackDest[11]],"E",
	#StackInQueue[StackDest[12]],"F" }

	
	if this.DeliveryMethod == "SUSPEND" then
		if TotalQueuedStack > 0 then
			DisplayCargoL.SubType = 4
		else
			DisplayCargoL.SubType = 0
		end
		DisplayCargoR.SubType = 0
	else
		if TotalQueuedStack > 0 then
			DisplayCargoL.SubType = 3
		else
			DisplayCargoL.SubType = 2
		end
		if CurX == 4 and CurY == 4 then DisplayCargoR.SubType = CheckOnRoute("Deliveries") end
	end
	
	CurX = CurX + 1							-- prepare for the next Update() cycle
	if CurX > 8 then						-- if MyChecker reaches the right wall then check if existing stations are still on the map
		ValidateExistingStations()
		
		CurY = CurY + 1						-- set the checker on the next row
		CurX = 1							-- at the left wall side
	end
	
	if not Forced then
		if foundSomething == true and CleanUpCounter == 0 then
			CleanUpCounter,CurX,CurY = 1,1,1	-- move MyChecker back to top left when stuff has been found
		elseif CurY == 2 then		-- second and sixth row are for sorted stuff waiting to be delivered, these are walls where no other stack spawns
			if CurX == 2 then CurX = 8 end	-- jump over these walls
		elseif CurY == 6 then
			if CurX == 2 then CurX,CurY = 1,7 end
		end
	else
		if CurY == 2 and CurX > 7 then CurX,CurY = 2,6	-- CollectStack was executed by DeleteOtherTerminals() or below, or the game was loaded so we need to rebuild the StackInQueue
		elseif CurY == 6 and CurX > 7 then CurX,CurY,Forced = 0,0,nil end	-- in order to find previously sorted stuff on the walls
	end
	
	if CurY > 7 then						-- stacker reached the bottom row of the terminal area
		CurX = 0							-- place the checker at top left corner
		CurY = 0							-- CurX/Y 0 will trigger ResetPrisonerNeeds()
		CycleDone = true					-- the room cycle has completed, Forced is no longer needed, start collecting new items as usual
		Forced = nil		
		CleanUpCounter = CleanUpCounter + 1	-- sometimes items stay on the floor after being loaded on a truck. No idea why, so this timer triggers a Forced scan

		if this.IntakeMethod == "AUTO" and TotalQueuedPrisoners == 0 and CleanUpCounter >= 1 then FindKnownPrisoners() end	-- doublecheck for prisoners below the terminal if the terminal thinks there are none
		if this.DeliveryMethod == "AUTO" then
			if TotalQueuedStack > 0 and CleanUpCounter >= 1 and StationOrPadFound == true then
				CleanUpCounter = 0
				if not AutoSpawnCargoActive then AutoSpawn("Cargo") end			-- spawns trucks or chinooks
			elseif TotalQueuedStack == 0 and CleanUpCounter >= 1 then	-- if the terminal thinks there is no more stuff in queue, do a Forced scan to find leftovers
				CleanUpCounter,CurX,CurY,Forced = 0,2,2,true
			end
		end
	end
end


	-------------------------------------------------------------------------------------------
	-- Used when the delivery mode is set to AUTO
	-------------------------------------------------------------------------------------------
function AutoSpawn(theType)
	print("AutoSpawn")
	if theType == "Intake" then
		if not AutoSpawnIntakeActive then
			AutoSpawnIntakeActive = true
			CurIntake = 1			
		end
		for A = CurIntake, #Traffic do	 -- first find dedicated intake places for seclevels
			-- print("AutoSpawnIntakeActive = A "..A.. "of "..#Traffic)
			if TotalQueuedPrisoners > 0 and Exists(Traffic[A].CargoStation) and Traffic[A].CargoStation.CargoType == "Intake" and CompareIntake(Traffic[A].CargoStation) == true then
				Traffic[A].CargoStation.VehicleSpawned = "yes"
				if Traffic[A].CargoStation.Type == "CargoStopSign" then
					PrepareIntakeTruck(Traffic[A].CargoStation)
				elseif Traffic[A].CargoStation.Type == "CargoHelipad" then
					PrepareIntakeChinook(Traffic[A].CargoStation)
				-- elseif Traffic[A].CargoStation.Type == "RailwayStopSign" then
					-- PrepareIntakeTrain(Traffic[A].CargoStation)
				end
				DisplayIntake.SubType = 2
				CurIntake = CurIntake + 1
				break
			else
				CurIntake = CurIntake + 1
				break	-- remove this break to speed up vehicle spawning
			end
		end
		if CurIntake > #Traffic then
			AutoSpawnIntakeActive = nil
			NextIntakeTick = nil
		end
	elseif theType == "Cargo" then
		if not AutoSpawnCargoActive then
			AutoSpawnCargoActive = true
			CurTraffic = 1
		end
		for A = CurTraffic, #Traffic do
			-- print("AutoSpawnCargoActive = A "..A.. "of "..#Traffic)
			if TotalQueuedStack > 0 and Exists(Traffic[A].CargoStation) and Traffic[A].CargoStation.CargoType == "Deliveries" and CompareCargo(Traffic[A].CargoStation) == true then
				Traffic[A].CargoStation.VehicleSpawned = "yes"
				if Traffic[A].CargoStation.Type == "CargoStopSign" then
					PrepareCargoTruck(Traffic[A].CargoStation)
				elseif Traffic[A].CargoStation.Type == "CargoHelipad" then
					PrepareCargoChinook(Traffic[A].CargoStation)
				-- elseif Traffic[A].CargoStation.Type == "RailwayStopSign" then
					-- PrepareCargoTrain(Traffic[A].CargoStation)
				end
				DisplayCargoR.SubType = 2
				CurTraffic = CurTraffic + 1
				break
			else
				CurTraffic = CurTraffic + 1
				break	-- remove this break to speed up vehicle spawning
			end
		end
		if CurTraffic > #Traffic then
			AutoSpawnCargoActive = nil 
			NextCargoTick = nil
		end
	end
end


	-------------------------------------------------------------------------------------------
	-- Check if the available cargo matches the cargo which the specified station/helipad accepts
	-------------------------------------------------------------------------------------------
function CompareCargo(theStation)
	local outcome = false
	print("AutoSpawn -->> Check Station: "..theStation.Number.." InUse: "..theStation.InUse.."  TrafficEnabled: "..theStation.TrafficEnabled.."  CargoType: "..theStation.CargoType.."  VehicleSpawned: "..theStation.VehicleSpawned)
	if theStation.CargoType == "Deliveries" and theStation.InUse == "no" and theStation.TrafficEnabled == "yes" and theStation.VehicleSpawned == "no" then
		for C = 1,12 do
			if #StackInQueue[StackDest[C]] > 0 then
				if Get(theStation,StackDest[C].."Delivery") == "yes" then
					print("AutoSpawn -->> Station "..theStation.Number.." accepts "..StackDest[C].." delivery: "..Get(theStation,StackDest[C].."Delivery"))
					print("AutoSpawn -->> Available boxes/stack for "..StackDest[C].." is "..#StackInQueue[StackDest[C]])
					outcome = true
				end
			end
		end
	end
	return outcome
end

	-------------------------------------------------------------------------------------------
	-- Check if the stuff is still on route or not
	-------------------------------------------------------------------------------------------
function CheckOnRoute(theType)
	local DisplaySubType = 1
	for A = 1, #Traffic do
		if Traffic[A] ~= nil and Exists(Traffic[A].CargoStation) and  Traffic[A].CargoStation.CargoType == theType and Traffic[A].CargoStation.InUse == "yes" then
			print("CheckOnRoute -->> Check Station: "..Traffic[A].CargoStation.Number.." InUse: "..Traffic[A].CargoStation.InUse)
			DisplaySubType = 2
		end
	end
	return DisplaySubType
end


function PrepareCargoTruck(theStation)
	print("--- PrepareCargoTruck for Station "..theStation.Number)
	Set(theStation,"BuildingQuantity",0)
	Set(theStation,"FloorsQuantity",0)
	Set(theStation,"LaundryQuantity",0)
	Set(theStation,"FoodQuantity",0)
	Set(theStation,"ForestQuantity",0)
	Set(theStation,"VendingQuantity",0)
	Set(theStation,"Workshop1Quantity",0)
	Set(theStation,"Workshop2Quantity",0)
	Set(theStation,"Workshop3Quantity",0)
	Set(theStation,"Workshop4Quantity",0)
	Set(theStation,"Workshop5Quantity",0)
	Set(theStation,"OtherQuantity",0)
	Set(theStation,"AllQuantity",0)
	AllQuantity = 0
	local newCargoTruck = Object.Spawn("CargoStationTruck",theStation.RoadX,1)
	Set(newCargoTruck,"HomeUID","CargoTruck_"..newCargoTruck.Id.u)
	Set(newCargoTruck,"TruckID",newCargoTruck.Id.u)
	Set(newCargoTruck,"Tail",6.5)
	Set(newCargoTruck,"Head",1.5)
	Set(newCargoTruck,"RoadX",theStation.RoadX)
	Set(newCargoTruck,"MyType","Cargo")
	Set(newCargoTruck,"SkinType","Deliveries")
	Set(newCargoTruck,"CargoStationID",theStation.CargoStationID)
	Set(newCargoTruck,"TruckY",2)
	
	local newTruckSkin = Object.Spawn("DeliveriesTruckSkin",theStation.RoadX,1)
	newTruckSkin.SubType = this.SubType_DeliveriesStationTruck	-- a skin with a higher renderdepth than the prisoners to cover the contents of the CargoStationTruck
	Set(newTruckSkin,"HomeUID",newCargoTruck.HomeUID)
	Set(newTruckSkin,"Slot0.i",newCargoTruck.Id.i)
	Set(newTruckSkin,"Slot0.u",newCargoTruck.Id.u)
	Set(newCargoTruck,"CarrierId.i",newTruckSkin.Id.i)
	Set(newCargoTruck,"CarrierId.u",newTruckSkin.Id.u)
	Set(newCargoTruck,"Loaded",true)
	newTruckSkin.Tooltip = { "tooltip_CargoStationTruck_TruckSkin",this.HomeUID,"H" }

	if SpawnTruckLightsOK() == true then
		local newHL = Object.Spawn("WallLight",newTruckSkin.Pos.x,1)
		Set(newHL,"HomeUID",newCargoTruck.HomeUID)
		Set(newTruckSkin,"Slot1.i",newHL.Id.i)
		Set(newTruckSkin,"Slot1.u",newHL.Id.u)
		Set(newHL,"CarrierId.i",newTruckSkin.Id.i)
		Set(newHL,"CarrierId.u",newTruckSkin.Id.u)
		Set(newHL,"Loaded",true)
		local newHR = Object.Spawn("WallLight",newTruckSkin.Pos.x,1)
		Set(newHR,"HomeUID",newCargoTruck.HomeUID)
		Set(newTruckSkin,"Slot2.i",newHR.Id.i)
		Set(newTruckSkin,"Slot2.u",newHR.Id.u)
		Set(newHR,"CarrierId.i",newTruckSkin.Id.i)
		Set(newHR,"CarrierId.u",newTruckSkin.Id.u)
		Set(newHR,"Loaded",true)
	end
	
	local TotCargo = 0
	for B = 1,2 do
		newTruckBay = Object.Spawn("TmpCargoTruckBay",this.Pos.x+4,this.Pos.y+2)-- fill a temporary truck bay with real deliveries inside the traffic terminal room
		Set(newTruckBay,"HomeUID",newCargoTruck.HomeUID)
		Set(newTruckBay,"CargoStationID",theStation.CargoStationID)
		Set(newTruckBay,"TruckBayNr",B)
		Set(newTruckBay,"CargoAmount",0)
		for i = 0,7 do
			Set(newTruckBay,"CargoLoad"..i,0)
		end
		
		dummyTruckBay = Object.Spawn("CargoTruckBay",theStation.RoadX,1)	-- spawn a truck bay with dummy box deliveries on the deliveries truck
		Set(dummyTruckBay,"HomeUID",newCargoTruck.HomeUID)	-- the dummy bay gets swapped with the real one when the gantry crane grabs the goods from the truck
		Set(dummyTruckBay,"CargoStationID",theStation.CargoStationID)
		Set(dummyTruckBay,"TruckBayNr",B)
		Set(dummyTruckBay,"CargoAmount",0)
		for i = 0,7 do
			Set(dummyTruckBay,"CargoLoad"..i,0)
		end
		Set(newTruckSkin,"Slot"..(B+2)..".i",dummyTruckBay.Id.i)
		Set(newTruckSkin,"Slot"..(B+2)..".u",dummyTruckBay.Id.u)
		Set(dummyTruckBay,"CarrierId.i",newTruckSkin.Id.i)
		Set(dummyTruckBay,"CarrierId.u",newTruckSkin.Id.u)
		Set(dummyTruckBay,"Loaded",true)
		
		LoadCargoByType(theStation,newTruckBay,dummyTruckBay,B)
		
		newTruckBay.Tooltip = { "tooltip_Bay",newTruckBay.HomeUID,"H",newTruckBay.CargoStationID,"I",newTruckBay.TruckBayNr,"N",newTruckBay.CargoAmount,"A" }
		dummyTruckBay.Tooltip = { "tooltip_Bay",newTruckBay.HomeUID,"H",newTruckBay.CargoStationID,"I",newTruckBay.TruckBayNr,"N",newTruckBay.CargoAmount,"A" }
		TotCargo = TotCargo + newTruckBay.CargoAmount
	end
	
	if Get(newTruckBay,"CargoAmount") == 0 then	-- if the second bay is empty, get rid of it
		Set(newTruckSkin,"Slot4.i",-1)
		Set(newTruckSkin,"Slot4.u",-1)
		newTruckBay.Delete()
		dummyTruckBay.Delete()
	end
		
	Set(theStation,"AllQuantity",AllQuantity)
	Set(theStation,"InUse","yes")
	Set(theStation,"Status","ON ROUTE")
	theStation.Tooltip = { "tooltip_CargoStopSign_DeliveriesArriving",theStation.HomeUID,"X",theStation.CargoStationID,"Y",theStation.Number,"Z",theStation.AllQuantity,"T",theStation.FoodQuantity,"A",theStation.LaundryQuantity,"B",theStation.VendingQuantity,"C",theStation.ForestQuantity,"D",theStation.Workshop1Quantity,"E",theStation.Workshop2Quantity,"F",theStation.Workshop3Quantity,"G",theStation.Workshop4Quantity,"H",theStation.Workshop5Quantity,"I",theStation.BuildingQuantity,"J",theStation.FloorsQuantity,"K",theStation.OtherQuantity,"L" }

	local nearbyObject = Find(theStation,"CargoStationControl",8)
	if next(nearbyObject) then
		for thatControl, distance in pairs(nearbyObject) do
			if thatControl.MarkerUID == theStation.MarkerUID and thatControl.HomeUID == theStation.HomeUID then
				Set(thatControl,"SubType",7)
				break
			end
		end
	end
	
	Set(newCargoTruck,"TotalCargoAmount",TotCargo)
	Set(newCargoTruck,"Number",theStation.Number)
	
	nearbyObject = nil
	newCargoTruck = nil
	newTruckBay = nil
	dummyTruckBay = nil
	print("--- PrepareCargoTruck --> ITEMS ON ROUTE TO CARGO STATION "..theStation.Number.." ---")
end

function PrepareCargoChinook(thePad)
	print("--- PrepareCargoChinook for Helipad "..thePad.Number)
	Set(thePad,"BuildingQuantity",0)
	Set(thePad,"FloorsQuantity",0)
	Set(thePad,"LaundryQuantity",0)
	Set(thePad,"FoodQuantity",0)
	Set(thePad,"ForestQuantity",0)
	Set(thePad,"VendingQuantity",0)
	Set(thePad,"Workshop1Quantity",0)
	Set(thePad,"Workshop2Quantity",0)
	Set(thePad,"Workshop3Quantity",0)
	Set(thePad,"Workshop4Quantity",0)
	Set(thePad,"Workshop5Quantity",0)
	Set(thePad,"OtherQuantity",0)
	Set(thePad,"AllQuantity",0)
	AllQuantity = 0
	local rndPosY = thePad.Pos.y-8+math.random()
	local newChinook = Object.Spawn("Chinook2",4,rndPosY)
	Set(newChinook,"HomeUID","CargoChinook_"..string.sub(newChinook.Id.u,-2))
	Set(newChinook,"MyType","Cargo")
	if Get(this,"AnimateChinook") == "yes" then
		local ChinookLightBack = Object.Spawn("StatusLight",newChinook.Pos.x-2.9,newChinook.Pos.y-1)
		Set(ChinookLightBack,"HomeUID",newChinook.HomeUID)
		Set(ChinookLightBack,"Spot","Back")
		Set(ChinookLightBack,"Or.x",0)
		Set(ChinookLightBack,"Or.y",-1)
		Set(newChinook,"Slot0.i",ChinookLightBack.Id.i)
		Set(newChinook,"Slot0.u",ChinookLightBack.Id.u)
		Set(ChinookLightBack,"Loaded",true)
		
		local ChinookLightFront = Object.Spawn("StatusLight",newChinook.Pos.x+5.85,newChinook.Pos.y-1)
		Set(ChinookLightFront,"HomeUID",newChinook.HomeUID)
		Set(ChinookLightFront,"Spot","Front")
		Set(ChinookLightFront,"Or.x",0)
		Set(ChinookLightFront,"Or.y",-1)
		Set(newChinook,"Slot1.i",ChinookLightFront.Id.i)
		Set(newChinook,"Slot1.u",ChinookLightFront.Id.u)
		Set(ChinookLightFront,"Loaded",true)
		
	end
	
	local TotCargo = 0
	for B = 1,2 do
		newChinookHook = Object.Spawn("TmpCargoTruckBay",this.Pos.x+4,this.Pos.y+2)	-- fill a temporary truck bay with real deliveries inside the traffic terminal room
		Set(newChinookHook,"HomeUID",newChinook.HomeUID)
		Set(newChinookHook,"HeliPadID",thePad.HomeUID)
		Set(newChinookHook,"HookNr",B)
		Set(newChinookHook,"CargoAmount",0)
		for i = 0,7 do
			Set(newChinookHook,"CargoLoad"..i,0)
		end
		
		dummyChinookHook = Object.Spawn("CargoChinookHook",newChinook.Pos.x+2.1,newChinook.Pos.y-2.7)
		Set(dummyChinookHook,"HomeUID",newChinook.HomeUID)	-- the dummy bay gets swapped with the real one when the gantry crane grabs the goods from the truck
		Set(dummyChinookHook,"HeliPadID",thePad.HomeUID)
		Set(dummyChinookHook,"HookNr",B)
		Set(dummyChinookHook,"CargoAmount",0)
		for i = 0,7 do
			Set(dummyChinookHook,"CargoLoad"..i,0)
		end
		
		LoadCargoByType(thePad,newChinookHook,dummyChinookHook,B)

		Set(newChinook,"Slot"..(B+1)..".i",dummyChinookHook.Id.i)
		Set(newChinook,"Slot"..(B+1)..".u",dummyChinookHook.Id.u)
		Set(dummyChinookHook,"Loaded",true)
		
		newChinookHook.Tooltip = { "tooltip_ChinookHook",newChinookHook.HomeUID,"H",newChinookHook.HeliPadID,"I",newChinookHook.HookNr,"N",newChinookHook.CargoAmount,"A" }
		dummyChinookHook.Tooltip = { "tooltip_ChinookHook",newChinookHook.HomeUID,"H",newChinookHook.HeliPadID,"I",newChinookHook.HookNr,"N",newChinookHook.CargoAmount,"A" }
		TotCargo = TotCargo + newChinookHook.CargoAmount
	end
	
	Set(newChinook,"TotalCargoAmount",TotCargo)
	
	Set(thePad,"AllQuantity",AllQuantity)
	
	Set(newChinook,"PadX",thePad.Pos.x-0.5+math.random())
	Set(newChinook,"PadY",rndPosY)
	Set(newChinook,"HeliPadID",thePad.HomeUID)
	Set(newChinook,"EdgeX",World.NumCellsX - 6)
	Set(newChinook,"EdgeY",newChinook.PadY)
	Set(newChinook,"AnimateChinook",Get(this,"AnimateChinook"))
	Set(newChinook,"VehicleState","ToHelipad")
	Set(newChinook,"Number",thePad.Number)
	newChinook.Tooltip = { "tooltip_Chinook2_Status",newChinook.HomeUID,"X",newChinook.VehicleState,"Y" }
   
	Set(thePad,"InUse","yes")
	Set(thePad,"Status","ON ROUTE")
	thePad.Tooltip = { "tooltip_CargoHelipad_DeliveriesArriving",thePad.HomeUID,"Y",thePad.Number,"Z",thePad.AllQuantity,"T",thePad.FoodQuantity,"A",thePad.LaundryQuantity,"B",thePad.VendingQuantity,"C",thePad.ForestQuantity,"D",thePad.Workshop1Quantity,"E",thePad.Workshop2Quantity,"F",thePad.Workshop3Quantity,"G",thePad.Workshop4Quantity,"H",thePad.Workshop5Quantity,"I",thePad.BuildingQuantity,"J",thePad.FloorsQuantity,"K",thePad.OtherQuantity,"L" }
	newChinookHook = nil
	print("--- PrepareCargoChinook --> ITEMS ON ROUTE TO HELIPAD "..thePad.Number.." ---")
end

function PrepareCargoTrain(theRailway)
	-- not implemented
end


	-------------------------------------------------------------------------------------------
	-- Load stack onto the CargoTruck/Chinook according to what the CargoStation/Helipad will accept
	-------------------------------------------------------------------------------------------
function LoadCargoByType(theStation,theBay,theDummy,theNumber)
	print("--- LoadCargoByType -->> Fill "..theBay.Type.." number "..theNumber)
	
	local theAmount = 0
	for C = 1,12 do
		local DeliverTo = StackDest[C]
		if #StackInQueue[DeliverTo] > 0 then	-- if the total number of records from the specific StackInQueue table holds items
			-- print("Available: "..#StackInQueue[DeliverTo])
			if Get(theStation,DeliverTo.."Delivery") == "yes" then
				for D = theAmount,7 do
					local foundQ = false
					local LQ = 0
					for Q = 1,#StackInQueue[DeliverTo] do
						if Exists(StackInQueue[DeliverTo][Q]) then
							foundQ = true
							LQ = Q
							break
						else
							table.remove(StackInQueue[DeliverTo],Q)	-- item got teleported already, remove this record item from the StackInQueue table
						end
					end
					if foundQ == true and Exists(StackInQueue[DeliverTo][LQ]) then	-- first in/first out, so the first item from specific StackInQueue table C is delivered
						-- needed for a prior bug which has been fixed now
						local Sort,Cont = 12,"Unknown"
						if StackInQueue[DeliverTo][LQ].Sorted ~= nil then Sort = StackInQueue[DeliverTo][LQ].Sorted end
						if StackInQueue[DeliverTo][LQ].Contains ~= nil then Cont = StackInQueue[DeliverTo][LQ].Contains end
						--
						
						print("Loading item ID "..StackInQueue[DeliverTo][LQ].Id.i.." in "..theBay.Type.." Slot "..D)
						Set(theBay,"Slot"..D..".i",StackInQueue[DeliverTo][LQ].Id.i)
						Set(theBay,"Slot"..D..".u",StackInQueue[DeliverTo][LQ].Id.u)
						Set(StackInQueue[DeliverTo][LQ],"CarrierId.i",theBay.Id.i)
						Set(StackInQueue[DeliverTo][LQ],"CarrierId.u",theBay.Id.u)
						Set(StackInQueue[DeliverTo][LQ],"Loaded",true)
						Set(theBay,"CargoLoad"..D,theStation.CargoStationID)
						Set(theBay,"CargoContains"..D,Cont)
						Set(StackInQueue[DeliverTo][LQ],"Tooltip","\n===== PACKING SLIP =====\nSorted by Traffic Terminal\n -> ID: "..StackInQueue[DeliverTo][LQ].Id.i.."\n -> Sorted to "..TooltipDest[Sort].."\n -> Contains "..Cont.."\n======================\n\n -> Recepient: "..theStation.HomeUID)

						local newDeliveries = Object.Spawn("CargoDeliveries",theDummy.Pos.x,theDummy.Pos.y)	-- spawn dummy boxes for deliveries
						Set(theDummy,"Slot"..D..".i",newDeliveries.Id.i)
						Set(theDummy,"Slot"..D..".u",newDeliveries.Id.u)
						Set(newDeliveries,"CarrierId.i",theDummy.Id.i)
						Set(newDeliveries,"CarrierId.u",theDummy.Id.u)
						Set(newDeliveries,"Loaded",true)
						Set(theDummy,"CargoLoad"..D,theStation.CargoStationID)
						Set(theDummy,"CargoContains"..D,StackInQueue[DeliverTo][LQ].Cont)
						Set(newDeliveries,"Contains",StackInQueue[DeliverTo][LQ].Cont)

						Set(newDeliveries,"HomeUID",theDummy.HomeUID)
						if theDummy.Type == "CargoTruckBay" then
							Set(newDeliveries,"TruckBayNr",theNumber)
						else
							Set(newDeliveries,"HookNr",theNumber)
						end
						Set(newDeliveries,"Tooltip","\n===== PACKING SLIP =====\nSorted by Traffic Terminal\n -> ID: "..StackInQueue[DeliverTo][LQ].Id.i.."\n -> Sorted to "..TooltipDest[Sort].."\n -> Contains "..Cont.."\n======================\n\n -> Recepient: "..theStation.HomeUID)
						
						Set(StackInQueue[DeliverTo][LQ],"Sorted",nil)	-- reset these values in case the truck/chinook gets deleted on route and the stack is transferred back to the terminal
						Set(StackInQueue[DeliverTo][LQ],"Contains",nil)
							
						Set(theStation,StackDest[C].."Quantity",Get(theStation,StackDest[C].."Quantity") + 1)
						
						table.remove(StackInQueue[DeliverTo],LQ)	-- remove this record item from the StackInQueue table
						
						theAmount = theAmount + 1
						AllQuantity = AllQuantity + 1
					end
				end
			end
		end
	end
	Set(theBay,"CargoAmount",theAmount)
	Set(theDummy,"CargoAmount",theAmount)
	print("CargoAmount on bay: "..theBay.CargoAmount)
	
	
	TotalQueuedStack = 0
	for T = 1,12 do
		TotalQueuedStack = TotalQueuedStack + #StackInQueue[StackDest[T]]
	end
	
	this.Tooltip = { "tooltip_TrafficTerminal",this.DeliveryMethod,"X",this.IntakeMethod,"Y",TotalQueuedStack,"A",TotalQueuedPrisoners,"B",
	#PrisonersInQueue[PrisonerDest[1]],"C",
	#PrisonersInQueue[PrisonerDest[2]],"D",
	#PrisonersInQueue[PrisonerDest[3]],"E",
	#PrisonersInQueue[PrisonerDest[4]],"F",
	#PrisonersInQueue[PrisonerDest[5]],"G",
	#PrisonersInQueue[PrisonerDest[6]],"H",
	#PrisonersInQueue[PrisonerDest[7]],"I" }
	
	QueuedStackAreaTop.Tooltip = { "tooltip_StackInQueueTop_Totals",
	#StackInQueue[StackDest[1]],"A",
	#StackInQueue[StackDest[2]],"B",
	#StackInQueue[StackDest[3]],"C",
	#StackInQueue[StackDest[4]],"D",
	#StackInQueue[StackDest[5]],"E",
	#StackInQueue[StackDest[6]],"F" }
	
	QueuedStackAreaBottom.Tooltip = { "tooltip_StackInQueueBottom_Totals",
	#StackInQueue[StackDest[7]],"A",
	#StackInQueue[StackDest[8]],"B",
	#StackInQueue[StackDest[9]],"C",
	#StackInQueue[StackDest[10]],"D",
	#StackInQueue[StackDest[11]],"E",
	#StackInQueue[StackDest[12]],"F" }
	
	DisplayCargoR.SubType = 2
end



	-------------------------------------------------------------------------------------------
	-- Intake related
	-------------------------------------------------------------------------------------------
	
	
function PrepareIntakeTruck(theStation)
	print("--- PrepareIntakeTruck for Station "..theStation.Number)
	Set(theStation,"MinSecQuantity",0)
	Set(theStation,"NormalQuantity",0)
	Set(theStation,"MaxSecQuantity",0)
	Set(theStation,"SuperMaxQuantity",0)
	Set(theStation,"ProtectedQuantity",0)
	Set(theStation,"DeathRowQuantity",0)
	Set(theStation,"InsaneQuantity",0)
	Set(theStation,"PrisQuantity",0)
	PrisQuantity = 0
	local newIntakeTruck = Object.Spawn("CargoStationTruck",theStation.RoadX,1)
	Set(newIntakeTruck,"HomeUID","IntakeTruck_"..newIntakeTruck.Id.u)
	Set(newIntakeTruck,"TruckID",newIntakeTruck.Id.u)
	Set(newIntakeTruck,"Tail",4)
	Set(newIntakeTruck,"Head",1.25)
	Set(newIntakeTruck,"RoadX",theStation.RoadX)
	Set(newIntakeTruck,"MyType","Intake")
	Set(newIntakeTruck,"SkinType","Intake")
	Set(newIntakeTruck,"TruckY",0.25)
	Set(newIntakeTruck,"CargoStationID",theStation.CargoStationID)
	
	local newTruckSkin = Object.Spawn("IntakeTruckSkin",theStation.RoadX,1)
	newTruckSkin.SubType = this.SubType_IntakeStationTruck
	Set(newTruckSkin,"HomeUID",newIntakeTruck.HomeUID)
	Set(newTruckSkin,"Slot0.i",newIntakeTruck.Id.i)
	Set(newTruckSkin,"Slot0.u",newIntakeTruck.Id.u)
	Set(newIntakeTruck,"CarrierId.i",newTruckSkin.Id.i)
	Set(newIntakeTruck,"CarrierId.u",newTruckSkin.Id.u)
	Set(newIntakeTruck,"Loaded",true)
	newIntakeTruck.Tooltip = { "tooltip_CargoStationTruck_TruckSkin",this.HomeUID,"H" }
	
	if SpawnTruckLightsOK() == true then
		local newHL = Object.Spawn("WallLight",newTruckSkin.Pos.x,1)
		Set(newTruckSkin,"Slot1.i",newHL.Id.i)
		Set(newTruckSkin,"Slot1.u",newHL.Id.u)
		Set(newHL,"CarrierId.i",newTruckSkin.Id.i)
		Set(newHL,"CarrierId.u",newTruckSkin.Id.u)
		Set(newHL,"Loaded",true)
		Set(newHL,"HomeUID",newIntakeTruck.HomeUID)
		local newHR = Object.Spawn("WallLight",newTruckSkin.Pos.x,1)
		Set(newTruckSkin,"Slot2.i",newHR.Id.i)
		Set(newTruckSkin,"Slot2.u",newHR.Id.u)
		Set(newHR,"CarrierId.i",newTruckSkin.Id.i)
		Set(newHR,"CarrierId.u",newTruckSkin.Id.u)
		Set(newHR,"Loaded",true)
		Set(newHR,"HomeUID",newIntakeTruck.HomeUID)
	end
	
	local TotCargo = 0
	for B = 1,2 do
		newTruckBay = Object.Spawn("IntakeTruckBay",theStation.RoadX,1)
		newTruckBay.SubType = this.SubType_IntakeStationTruck
		Set(newTruckBay,"HomeUID",newIntakeTruck.HomeUID)
		Set(newTruckBay,"CargoStationID",theStation.CargoStationID)
		Set(newTruckBay,"TruckBayNr",B)
		Set(newTruckBay,"CargoAmount",0)
		for i = 0,7 do
			Set(newTruckBay,"CargoLoad"..i,0)
		end
		
		LoadIntakeBySecLevel(theStation,newTruckBay,B)
		newTruckBay.Tooltip = { "tooltip_BayIntake",newTruckBay.HomeUID,"H",newTruckBay.CargoStationID,"I",newTruckBay.TruckBayNr,"N",newTruckBay.CargoAmount,"A" }
		TotCargo = TotCargo + newTruckBay.CargoAmount
		
		Set(newTruckSkin,"Slot"..(B+2)..".i",newTruckBay.Id.i)
		Set(newTruckSkin,"Slot"..(B+2)..".u",newTruckBay.Id.u)
		Set(newTruckBay,"CarrierId.i",newTruckSkin.Id.i)
		Set(newTruckBay,"CarrierId.u",newTruckSkin.Id.u)
		Set(newTruckBay,"Loaded",true)
	end
	
	Set(theStation,"PrisQuantity",PrisQuantity)
	Set(theStation,"InUse","yes")
	Set(theStation,"Status","ON ROUTE")
	theStation.Tooltip = { "tooltip_CargoStopSign_PrisonersArriving",theStation.HomeUID,"X",theStation.CargoStationID,"Y",theStation.Number,"Z",theStation.PrisQuantity,"T",theStation.MinSecQuantity,"A",theStation.NormalQuantity,"B",theStation.MaxSecQuantity,"C",theStation.ProtectedQuantity,"D",theStation.SuperMaxQuantity,"E",theStation.DeathRowQuantity,"F",theStation.InsaneQuantity,"G" }

	local nearbyObject = Find(theStation,"CargoStationControl",8)
	if next(nearbyObject) then
		for thatControl, distance in pairs(nearbyObject) do
			if thatControl.MarkerUID == theStation.MarkerUID and thatControl.HomeUID == theStation.HomeUID then
				Set(thatControl,"SubType",17)
				break
			end
		end
	end
	
	Set(newIntakeTruck,"TotalCargoAmount",TotCargo)
	Set(newIntakeTruck,"Number",theStation.Number)
	
	nearbyObject = nil
	newIntakeTruck = nil
	newTruckBay = nil
end

function PrepareIntakeChinook(thePad)
	print("--- PrepareIntakeChinook for Helipad "..thePad.Number)
	Set(thePad,"MinSecQuantity",0)
	Set(thePad,"NormalQuantity",0)
	Set(thePad,"MaxSecQuantity",0)
	Set(thePad,"SuperMaxQuantity",0)
	Set(thePad,"ProtectedQuantity",0)
	Set(thePad,"DeathRowQuantity",0)
	Set(thePad,"InsaneQuantity",0)
	Set(thePad,"PrisQuantity",0)
	PrisQuantity = 0
	local newChinook = Object.Spawn("Chinook2",4,thePad.Pos.y-5)
	local insideChinook = Object.Spawn("IntakeChinookInside",4,thePad.Pos.y-5)
	Set(newChinook,"HomeUID","IntakeChinook_"..string.sub(newChinook.Id.u,-2))
	Set(newChinook,"MyType","Intake")
	Set(insideChinook,"HomeUID",newChinook.HomeUID)
	Set(insideChinook,"Slot0.i",newChinook.Id.i)
	Set(insideChinook,"Slot0.u",newChinook.Id.u)
	Set(newChinook,"Loaded",true)
	if Get(this,"AnimateChinook") == "yes" then
		local ChinookLightBack = Object.Spawn("StatusLight",newChinook.Pos.x-2.9,newChinook.Pos.y-1)
		Set(ChinookLightBack,"HomeUID",newChinook.HomeUID)
		Set(ChinookLightBack,"Spot","Back")
		Set(ChinookLightBack,"Or.x",0)
		Set(ChinookLightBack,"Or.y",-1)
		Set(insideChinook,"Slot1.i",ChinookLightBack.Id.i)
		Set(insideChinook,"Slot1.u",ChinookLightBack.Id.u)
		Set(ChinookLightBack,"Loaded",true)
		
		local ChinookLightFront = Object.Spawn("StatusLight",newChinook.Pos.x+5.85,newChinook.Pos.y-1)
		Set(ChinookLightFront,"HomeUID",newChinook.HomeUID)
		Set(ChinookLightFront,"Spot","Front")
		Set(ChinookLightFront,"Or.x",0)
		Set(ChinookLightFront,"Or.y",-1)
		Set(insideChinook,"Slot2.i",ChinookLightFront.Id.i)
		Set(insideChinook,"Slot2.u",ChinookLightFront.Id.u)
		Set(ChinookLightFront,"Loaded",true)
	end
	
	local TotCargo = 0
	for B = 1,2 do
		ChinookHook = Object.Spawn("IntakeChinookHook",newChinook.Pos.x+2.1,newChinook.Pos.y-2.7)
		Set(ChinookHook,"HomeUID",newChinook.HomeUID)
		Set(ChinookHook,"Tooltip","\nVehicle ID: "..ChinookHook.HomeUID.." Bay "..B)
		Set(ChinookHook,"HookNr",B)
		Set(ChinookHook,"CargoAmount",0)
		for i = 0,7 do
			Set(ChinookHook,"CargoLoad"..i,0)
		end
		
		LoadIntakeBySecLevel(thePad,ChinookHook,B)
		
		Set(insideChinook,"Slot"..(B+3)..".i",ChinookHook.Id.i)
		Set(insideChinook,"Slot"..(B+3)..".u",ChinookHook.Id.u)
		Set(ChinookHook,"Loaded",true)
		TotCargo = TotCargo + ChinookHook.CargoAmount
	end
	
	Set(newChinook,"TotalCargoAmount",TotCargo)
	
	Set(thePad,"PrisQuantity",PrisQuantity)
	
	Set(newChinook,"PadX",thePad.Pos.x-0.5+math.random())
	Set(newChinook,"PadY",thePad.Pos.y-6.66+math.random())
	Set(newChinook,"HeliPadID",thePad.HomeUID)
	Set(newChinook,"FuelLevel",0)
	Set(newChinook,"EdgeX",World.NumCellsX - 6)
	Set(newChinook,"EdgeY",newChinook.PadY)
	Set(newChinook,"AnimateChinook",Get(this,"AnimateChinook"))
	Set(newChinook,"VehicleState","ToHelipad")
	Set(newChinook,"Number",thePad.Number)
	newChinook.Tooltip = { "tooltip_Chinook2_Status",newChinook.HomeUID,"X",newChinook.VehicleState,"Y" }
   
	Set(thePad,"InUse","yes")
	Set(thePad,"Status","ON ROUTE")
	thePad.Tooltip = { "tooltip_CargoHelipad_PrisonersArriving",thePad.HomeUID,"Y",thePad.Number,"Z",thePad.PrisQuantity,"T",thePad.MinSecQuantity,"A",thePad.NormalQuantity,"B",thePad.MaxSecQuantity,"C",thePad.ProtectedQuantity,"D",thePad.SuperMaxQuantity,"E",thePad.DeathRowQuantity,"F",thePad.InsaneQuantity,"G" }
	ChinookHook = nil
	print("--- PrepareIntakeChinook --> PRISONERS ON ROUTE TO HELIPAD "..thePad.Number.." ---")
end


	-------------------------------------------------------------------------------------------
	-- Check if available prisoners match the seclevel which the specified helipad accepts
	-------------------------------------------------------------------------------------------
function CompareIntake(theStation)
	local outcome = false
	print("AutoSpawn -->> Check Station: "..theStation.Number.." InUse: "..theStation.InUse.."  TrafficEnabled: "..theStation.TrafficEnabled.."  CargoType: "..theStation.CargoType.."  VehicleSpawned: "..theStation.VehicleSpawned)
	if theStation.CargoType == "Intake" and theStation.InUse == "no" and theStation.TrafficEnabled == "yes" and theStation.VehicleSpawned == "no" then
		for C = 1,7 do
			if #PrisonersInQueue[PrisonerDest[C]] > 0 then
				if Get(theStation,"Intake"..PrisonerDest[C]) == "yes" then
					print("AutoSpawn -->> Station "..theStation.Number.." accepts: "..PrisonerDest[C].." prisoners: "..Get(theStation,"Intake"..PrisonerDest[C]))
					print("AutoSpawn -->> Available prisoners for "..PrisonerDest[C].." is "..#PrisonersInQueue[PrisonerDest[C]])
					outcome = true
				end
			end
		end
	end
	return outcome
end

	-------------------------------------------------------------------------------------------
	-- Load prisoners onto the IntakeTruck/chinook according to what the IntakeStation will accept
	-------------------------------------------------------------------------------------------
function LoadIntakeBySecLevel(theStation,theBay,theNumber)
	print("LoadIntakeBySecLevel -->> Fill "..theBay.Type.." number "..theNumber)
	
	local theAmount = 0
	for C = 1,7 do
		local Category = PrisonerDest[C]
		if #PrisonersInQueue[Category] > 0 then	-- if the total number of records from the specific PrisonersInQueue table holds items
			print("LoadIntakeBySecLevel -->> Available: "..#PrisonersInQueue[Category].." "..Category.." Prisoners")
			if Get(theStation,"Intake"..Category) == "yes" then
				for D = theAmount,7 do
					local foundP = false
					local LP = 0
					for P = 1,#PrisonersInQueue[Category] do
						if Exists(PrisonersInQueue[Category][P]) then
							foundP = true
							LP = P
							break
						else
							table.remove(PrisonersInQueue[Category],P)	-- prisoner vanished, remove this record item from the PrisonersInQueue table
						end
					end
					if foundP == true and Exists(PrisonersInQueue[Category][1]) then	-- first in/first out
						print("LoadIntakeBySecLevel -->> Loading prisoner ID "..PrisonersInQueue[Category][1].Id.i.." in "..theBay.Type.." Slot "..D)
						Set(theBay,"Slot"..D..".i",PrisonersInQueue[Category][1].CarrierId.i) -- the id of the prisonerholder in which this prisoner is locked
						Set(theBay,"Slot"..D..".u",PrisonersInQueue[Category][1].CarrierId.u) -- should load the holder onto the bay without needing to search for it
						if theStation.Type == "CargoHelipad" then
							Set(PrisonersInQueue[Category][1],"HelipadID",theStation.Id.u)
							Set(theBay,"CargoLoad"..D,theStation.Id.u)
						else
							Set(PrisonersInQueue[Category][1],"CargoStationID",theStation.CargoStationID)
							Set(theBay,"CargoLoad"..D,theStation.CargoStationID)
						end
						Set(theStation,Category.."Quantity",Get(theStation,Category.."Quantity") + 1)
						table.remove(PrisonersInQueue[Category],1)	-- remove this record item from the PrisonersInQueue table
						theAmount = theAmount + 1
						PrisQuantity = PrisQuantity + 1
					end
				end
				Set(theBay,"CargoAmount",theAmount)
			end
		end
	end
	UpdatePrisonerDisplays()
end

	-------------------------------------------------------------------------------------------
	-- Find stuff
	-------------------------------------------------------------------------------------------
function FindMyStackTransferrer()
	print("FindMyStackTransferrer")
    local Transferrers = Find(this,"StackTransferrer",10000)
	local transferFound = false
	if next(Transferrers) then
		for thatTransferrer, distance in pairs(Transferrers) do
			MyStackTransferrer=thatTransferrer
			Set(MyStackTransferrer,"HomeUID",this.HomeUID)
			MyStackTransferrer.Pos.x = World.OriginW+World.OriginX-10
			MyStackTransferrer.Pos.y = 2
			print("StackTransferrer found at "..distance)
			transferFound = true
		end
	end
	Transferrers=nil
	if transferFound == false then
		MyStackTransferrer = Object.Spawn("StackTransferrer",World.OriginW+World.OriginX-10,2)
		Set(MyStackTransferrer,"HomeUID",this.HomeUID)
		Set(MyStackTransferrer,"Tooltip","tooltip_StackTransferrer")
		print("StackTransferrer spawned")
	end
end

function FindMyDisplays()
	print("FindMyDisplays")
	local LeftIntakeDisplays = Find(this,"TrafficTerminalIntakeDisplayLeft",4)
	local RightIntakeDisplays = Find(this,"TrafficTerminalIntakeDisplayRight",4)
	local LeftCargoDisplays = Find(this,"TrafficTerminalCargoDisplayLeft",4)
	local RightCargoDisplays = Find(this,"TrafficTerminalCargoDisplayRight",4)
	local IntakeDisplays = Find(this,"TrafficTerminalIntakeDisplay",4)
	
	for L, dist in pairs(LeftIntakeDisplays) do
		if		 L.Display == "MinSec"	 then DisplayMinSec = L	print("Found MinSec display")
		elseif	 L.Display == "MaxSec"	 then DisplayMaxSec = L	print("Found MaxSec display")
		elseif	 L.Display == "Insane"	 then DisplayInsane = L	print("Found Insane display")
		end
	end
	
	for R, dist in pairs(RightIntakeDisplays) do
		if		 R.Display == "Normal"	 then DisplayNormal = R		print("Found Normal display")
		elseif	 R.Display == "SuperMax" then DisplaySuperMax = R	print("Found SuperMax display")
		elseif	 R.Display == "DeathRow" then DisplayDeathRow = R	print("Found DeathRow display")
		end
	end
	
	for I, dist in pairs(IntakeDisplays) do
		if I.HomeUID == this.HomeUID then DisplayIntake = I end	print("Found Intake display")
	end
	if not DisplayIntake.Loaded then
		Set(this,"Slot0.i",DisplayIntake.Id.i)
		Set(this,"Slot0.u",DisplayIntake.Id.u)
		Set(DisplayIntake,"CarrierId.i",this.Id.i)
		Set(DisplayIntake,"CarrierId.u",this.Id.u)
		Set(DisplayIntake,"Loaded",true)
	end
	
	for CL, dist in pairs(LeftCargoDisplays) do
		if CL.HomeUID == this.HomeUID then DisplayCargoL = CL end	print("Found CargoL display")
	end
	if not DisplayCargoL.Loaded then
		Set(this,"Slot1.i",DisplayCargoL.Id.i)
		Set(this,"Slot1.u",DisplayCargoL.Id.u)
		Set(DisplayCargoL,"CarrierId.i",this.Id.i)
		Set(DisplayCargoL,"CarrierId.u",this.Id.u)
		Set(DisplayCargoL,"Loaded",true)
	end
	
	for CR, dist in pairs(RightCargoDisplays) do
		if CR.HomeUID == this.HomeUID then DisplayCargoR = CR end	print("Found CargoR display")
	end
	if not DisplayCargoR.Loaded then
		Set(this,"Slot2.i",DisplayCargoR.Id.i)
		Set(this,"Slot2.u",DisplayCargoR.Id.u)
		Set(DisplayCargoR,"CarrierId.i",this.Id.i)
		Set(DisplayCargoR,"CarrierId.u",this.Id.u)
		Set(DisplayCargoR,"Loaded",true)
	end
end

function FindQueuedStackAreas()
    for thatTopArea in next, Find(this,"StackInQueueTop",5) do
		QueuedStackAreaTop = thatTopArea
	end
    for thatBottomArea in next, Find(this,"StackInQueueBottom",5) do
		QueuedStackAreaBottom = thatBottomArea
	end
end

function FindMyChecker(PosX,PosY)
	local qFound = false
	local nearbyCheckers = Find(this,"QueuedStackChecker",6)
	for thatChecker, dist in pairs(nearbyCheckers) do
		MyChecker = thatChecker
		qFound = true
	end
	nearbyCheckers = nil
	if qFound == false then
		MyChecker = Object.Spawn("QueuedStackChecker",PosX,PosY)
		Set(MyChecker,"HomeUID",this.HomeUID)
	end
end




	-------------------------------------------------------------------------------------------
	-- Prisoners related
	-------------------------------------------------------------------------------------------
function ResetPrisonerNeeds()
	print("ResetPrisonerNeeds")
	if TotalQueuedPrisoners > 0 then
		for T = 1,7 do
			for N = 1,#PrisonersInQueue[PrisonerDest[T]] do
				PrisonersInQueue[PrisonerDest[T]][N].FailedToFindCell = 0
				for thatNeed, distance in pairs(PrisonersInQueue[PrisonerDest[T]][N].Needs.NeedsMetaTable.GetterTable) do -- walk through a list of the prisoners available needs
					if thatNeed == "Warmth" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Warmth = 0 end
					if thatNeed == "Literacy" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Literacy = 0 end
					if thatNeed == "Spirituality" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Spirituality = 0 end
					if thatNeed == "Clothing" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Clothing = 0 end
					if thatNeed == "Freedom" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Freedom = 0 end
					if thatNeed == "Privacy" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Privacy = 0 end
					if thatNeed == "Environment" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Environment = 0 end
					if thatNeed == "Comfort" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Comfort = 0 end
					if thatNeed == "Recreation" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Recreation = 0 end
					if thatNeed == "Family" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Family = 0 end
					if thatNeed == "Exercise" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Exercise = 0 end
					if thatNeed == "Hygiene" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Hygiene = 0 end
					if thatNeed == "Safety" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Safety = 0 end
					if thatNeed == "Bowels" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Bowels = 0 end
					if thatNeed == "Bladder" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Bladder = 0 end
					if thatNeed == "Sleep" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Sleep = 0 end
					if thatNeed == "Food" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Food = 0 end
					if thatNeed == "Alcohol" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Alcohol = 0 end
					if thatNeed == "Drugs" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Drugs = 0 end
					if thatNeed == "BabyPlay" then PrisonersInQueue[PrisonerDest[T]][N].Needs.BabyPlay = 0 end
					if thatNeed == "BabySleep" then PrisonersInQueue[PrisonerDest[T]][N].Needs.BabySleep = 0 end
					if thatNeed == "Barbery" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Barbery = 0 end
					if thatNeed == "Evacuation" then PrisonersInQueue[PrisonerDest[T]][N].Needs.Evauation = 0 end
				end
			end
		end
		if this.IntakeMethod == "AUTO" then
			if StationOrPadFound == true then
				if not AutoSpawnIntakeActive then AutoSpawn("Intake") end			-- spawns prisoner bus or chinooks
			end
		end
	end
	if DisplayIntake.SubType == 2 then
		if Get(this,"IntakeMethod") == "AUTO" then
			DisplayIntake.SubType = CheckOnRoute("Intake")
		end
	end
end

function FindKnownPrisoners()
	print("FindKnownPrisoners")
	
	PrisonersInQueue = {	MinSec = {},
							Normal = {},
							MaxSec = {},
							Protected = {},
							SuperMax = {},
							DeathRow = {},
							Insane = {}
						}
						
	TotalQueuedPrisoners = 0
	local KnownPrisonersToFind = Find(this,"Prisoner",6)
	if next(KnownPrisonersToFind) then
		for thatPrisoner, dist in pairs(KnownPrisonersToFind) do
			if thatPrisoner.Loaded == true then
				local ForDestination = thatPrisoner.Category
				table.insert( PrisonersInQueue[ForDestination], thatPrisoner )		-- add the prisoner at the end of the specific PrisonersInQueue table
				local numP = #PrisonersInQueue[ForDestination]
				print("FindKnownPrisoners -->> Known Prisoner found for SecLevel "..PrisonersInQueue[ForDestination][ numP ].Category)
				print("FindKnownPrisoners -->> PrisonersInQueue "..ForDestination.." has "..numP.." records")
			else
				local NewPrisonerHolder = Object.Spawn("PrisonerStackHolder",thatPrisoner.Pos.x,thatPrisoner.Pos.y)
				Set(NewPrisonerHolder,"HolderCategory",thatPrisoner.Category)
				Set(NewPrisonerHolder,"Tooltip",thatPrisoner.Category.." Prisoner")
				Set(NewPrisonerHolder,"Slot0.i",thatPrisoner.Id.i)
				Set(NewPrisonerHolder,"Slot0.u",thatPrisoner.Id.u)
				Set(thatPrisoner,"CarrierId.i",NewPrisonerHolder.Id.i)
				Set(thatPrisoner,"CarrierId.u",NewPrisonerHolder.Id.u)
				Set(thatPrisoner,"Loaded",true)
				Set(thatPrisoner,"Locked",true)
				
				SortPrisoner(thatPrisoner, NewPrisonerHolder)
				
				Set(NewPrisonerHolder,"TrafficTerminalID",this.Id.i)
				Set(NewPrisonerHolder,"Pos.y",this.Pos.y+2)
				Set(NewPrisonerHolder,"Pos.x",this.Pos.x-3)
					
				local ForDestination = thatPrisoner.Category
				table.insert( PrisonersInQueue[ForDestination], thatPrisoner )		-- add the prisoner at the end of the specific PrisonersInQueue table
				local numP = #PrisonersInQueue[ForDestination]
				print("FindKnownPrisoners -->> Sorted new Prisoner ID: "..thatPrisoner.Id.i.." to "..PrisonersInQueue[ForDestination][ numP ].Category)
				print("FindKnownPrisoners -->> PrisonersInQueue "..ForDestination.." has "..numP.." records")
			end
		end
	end
	UpdatePrisonerDisplays()
end

function AddNewPrisoners()
	print("AddNewPrisoners")
	local IncomingPrisonersToFind = Find(MyStackTransferrer,"Prisoner",5)
	local IncomingHoldersToFind = Find(MyStackTransferrer,"PrisonerStackHolder",5)
	if next(IncomingHoldersToFind) then
		for thatHolder, distance in pairs(IncomingHoldersToFind) do
			local found = false
			for thatPrisoner, dist in pairs(IncomingPrisonersToFind) do
				if Get(thatPrisoner,"CarrierId.i") == thatHolder.Id.i then
					if thatPrisoner.Gang.Rank == 3 then	-- broken? gang info is now in Bio?
						SpawnIntakeCash("Legendary")
					else
						SpawnIntakeCash(thatPrisoner.Category)
					end
					SortPrisoner(thatPrisoner, thatHolder)
					
					Set(thatHolder,"TrafficTerminalID",this.Id.i)
					
					Set(thatHolder,"Pos.y",this.Pos.y+2)
					Set(thatHolder,"Pos.x",this.Pos.x-3)
					
					local ForDestination = thatPrisoner.Category
					
					table.insert( PrisonersInQueue[ForDestination], thatPrisoner )		-- add the prisoner at the end of the specific PrisonersInQueue table
					local numP = #PrisonersInQueue[ForDestination]
					Set(PrisonersInQueue[ForDestination][ N ],"MapBottom",World.NumCellsY)
					print("AddNewPrisoners -->> Sorted new Prisoner ID: "..thatPrisoner.Id.i.." to "..PrisonersInQueue[ForDestination][ numP ].Category)
					print("AddNewPrisoners -->> PrisonersInQueue "..ForDestination.." has "..numP.." records")
					
					found = true
					thatPrisoner = nil
					break
				end
			end
			if found == false then thatHolder.Delete() end
		end
	end
	UpdatePrisonerDisplays()
end

function SpawnIntakeCash(Category)
	print("SpawnIntakeCash -> "..Category)
	if CashMinSecNr == nil then FindStackNumbers() end
	if Category == "MinSec" then
		if not Exists(MyIntakeCashMinSec) then
			MyIntakeCashMinSec = Object.Spawn("Stack", this.Pos.x-2.5, this.Pos.y+3)
			Set(MyIntakeCashMinSec,"Quantity",1)
			Set(MyIntakeCashMinSec,"Contents",CashMinSecNr)
			Set(MyIntakeCashMinSec,"Tooltip","tooltip_PrisonerIntakeCash")
		else
			MyIntakeCashMinSec.Quantity = MyIntakeCashMinSec.Quantity + 1
		end
	elseif Category == "Normal" then
		if not Exists(MyIntakeCashMedSec) then
			MyIntakeCashMedSec = Object.Spawn("Stack", this.Pos.x-1.5, this.Pos.y+3)
			Set(MyIntakeCashMedSec,"Quantity",1)
			Set(MyIntakeCashMedSec,"Contents",CashNormalNr)
			Set(MyIntakeCashMedSec,"Tooltip","tooltip_PrisonerIntakeCash")
		else
			MyIntakeCashMedSec.Quantity = MyIntakeCashMedSec.Quantity + 1
		end
	elseif Category == "MaxSec" then
		if not Exists(MyIntakeCashMaxSec) then
			MyIntakeCashMaxSec = Object.Spawn("Stack", this.Pos.x-0.5, this.Pos.y+3)
			Set(MyIntakeCashMaxSec,"Quantity",1)
			Set(MyIntakeCashMaxSec,"Contents",CashMaxSecNr)
			Set(MyIntakeCashMaxSec,"Tooltip","tooltip_PrisonerIntakeCash")
		else
			MyIntakeCashMaxSec.Quantity = MyIntakeCashMaxSec.Quantity + 1
		end
	elseif Category == "SuperMax" then
		if not Exists(MyIntakeCashSuperMaxSec) then
			MyIntakeCashSuperMaxSec = Object.Spawn("Stack", this.Pos.x+0.5, this.Pos.y+3)
			Set(MyIntakeCashSuperMaxSec,"Quantity",1)
			Set(MyIntakeCashSuperMaxSec,"Contents",CashSuperMaxNr)
			Set(MyIntakeCashSuperMaxSec,"Tooltip","tooltip_PrisonerIntakeCash")
		else
			MyIntakeCashSuperMaxSec.Quantity = MyIntakeCashSuperMaxSec.Quantity + 1
		end
	elseif Category == "DeathRow" then
		if not Exists(MyIntakeCashDeathRow) then
			MyIntakeCashDeathRow = Object.Spawn("Stack", this.Pos.x+1.5, this.Pos.y+3)
			Set(MyIntakeCashDeathRow,"Quantity",1)
			Set(MyIntakeCashDeathRow,"Contents",CashDeathRowNr)
			Set(MyIntakeCashDeathRow,"Tooltip","tooltip_PrisonerIntakeCash")
		else
			MyIntakeCashDeathRow.Quantity = MyIntakeCashDeathRow.Quantity + 1
		end
	elseif Category == "Insane" then
		if not Exists(MyIntakeCashInsane) then
			MyIntakeCashInsane = Object.Spawn("Stack", this.Pos.x+2.5, this.Pos.y+3)
			Set(MyIntakeCashInsane,"Quantity",1)
			Set(MyIntakeCashInsane,"Contents",CashInsaneNr)
			Set(MyIntakeCashInsane,"Tooltip","tooltip_PrisonerIntakeCash")
		else
			MyIntakeCashInsane.Quantity = MyIntakeCashInsane.Quantity + 1
		end
	elseif Category == "Legendary" then
		if not Exists(MyIntakeCashLegendary) then
			MyIntakeCashLegendary = Object.Spawn("Stack", this.Pos.x+3.5, this.Pos.y+3)
			Set(MyIntakeCashLegendary,"Quantity",1)
			Set(MyIntakeCashLegendary,"Contents",CashLegendaryNr)
			Set(MyIntakeCashLegendary,"Tooltip","tooltip_PrisonerIntakeCash")
		else
			MyIntakeCashLegendary.Quantity = MyIntakeCashLegendary.Quantity + 1
		end
	end
end

function FindStackNumbers()
	local totalFound = 0
	local newStack = Object.Spawn("Stack", this.Pos.x-1, this.Pos.y)
	for i = 1,2000 do
		Set(newStack,"Quantity",2)
		Set(newStack,"Contents",i)
		if newStack.Contents == "PrisonerIntakeCashMinSec" then
			CashMinSecNr = i
			totalFound = totalFound + 1
		elseif newStack.Contents == "PrisonerIntakeCashNormal" then
			CashNormalNr = i
			totalFound = totalFound + 1
		elseif newStack.Contents == "PrisonerIntakeCashMaxSec" then
			CashMaxSecNr = i
			totalFound = totalFound + 1
		elseif newStack.Contents == "PrisonerIntakeCashSuperMax" then
			CashSuperMaxNr = i
			totalFound = totalFound + 1
		elseif newStack.Contents == "PrisonerIntakeCashDeathRow" then
			CashDeathRowNr = i
			totalFound = totalFound + 1
		elseif newStack.Contents == "PrisonerIntakeCashInsane" then
			CashInsaneNr = i
			totalFound = totalFound + 1
		elseif newStack.Contents == "PrisonerIntakeCashLegendary" then
			CashLegendaryNr = i
			totalFound = totalFound + 1
		end
		if totalFound == 7 then
			newStack.Delete()
			break
		end
	end
end

function UpdatePrisonerDisplays()
	print("UpdatePrisonerDisplays")

	DisplayMinSec.SubType = 0
	DisplayNormal.SubType = 0
	DisplayMaxSec.SubType = 0
	DisplaySuperMax.SubType = 0
	DisplayInsane.SubType = 0
	DisplayDeathRow.SubType = 0
	
	TotalQueuedPrisoners = 0
	for T = 1,7 do
		TotalQueuedPrisoners = TotalQueuedPrisoners + #PrisonersInQueue[PrisonerDest[T]]
	end
	
	local Min = #PrisonersInQueue[PrisonerDest[1]]
	local Med = #PrisonersInQueue[PrisonerDest[2]]
	local Max = #PrisonersInQueue[PrisonerDest[3]]
	local Prot = #PrisonersInQueue[PrisonerDest[4]]
	local Sup = #PrisonersInQueue[PrisonerDest[5]]
	local DR = #PrisonersInQueue[PrisonerDest[6]]
	local Ins = #PrisonersInQueue[PrisonerDest[7]]
	
	this.Tooltip = { "tooltip_TrafficTerminal",this.DeliveryMethod,"X",this.IntakeMethod,"Y",TotalQueuedStack,"A",TotalQueuedPrisoners,"B",
		#PrisonersInQueue[PrisonerDest[1]],"C",
		#PrisonersInQueue[PrisonerDest[2]],"D",
		#PrisonersInQueue[PrisonerDest[3]],"E",
		#PrisonersInQueue[PrisonerDest[4]],"F",
		#PrisonersInQueue[PrisonerDest[5]],"G",
		#PrisonersInQueue[PrisonerDest[6]],"H",
		#PrisonersInQueue[PrisonerDest[7]],"I" }

	if Min > 0 then DisplayMinSec.SubType = 1 end
	if Med > 0 then DisplayNormal.SubType = 1 end
	if Max > 0 then DisplayMaxSec.SubType = 2 end
	if Sup > 0 then DisplaySuperMax.SubType = 2 end
	if Prot > 0 or Ins > 0 then DisplayInsane.SubType = 3 end
	if DR > 0 then DisplayDeathRow.SubType = 3 end
	
	if Get(this,"IntakeMethod") == "SUSPEND" then
		if TotalQueuedPrisoners > 0 then
			DisplayIntake.SubType = 4
			DisplayMinSec.SubType = 4
			DisplayNormal.SubType = 4
			DisplayMaxSec.SubType = 4
			DisplaySuperMax.SubType = 4
			DisplayInsane.SubType = 4
			DisplayDeathRow.SubType = 4
		else
			DisplayIntake.SubType = 0
		end
	else
		if TotalQueuedPrisoners > 0 then
			DisplayIntake.SubType = 3
		else
			DisplayIntake.SubType = CheckOnRoute("Intake")
		end
	end
end

function SortPrisoner(NewPrisoner,NewHolder)
	print("SortPrisoner ID: "..NewPrisoner.Id.i)
	local NewCategory = { ["MinSec"] = 1, ["Normal"] = 2, ["MaxSec"] = 3, ["Protected"] = 4, ["SuperMax"] = 5, ["DeathRow"] = 6, ["Insane"] = 7 }
	
	if NewPrisoner.SnitchTimer~=0 then
		if NewPrisoner.Category=="MinSec" and SortMin=="YES" then
			Set(NewPrisoner,"Category",4)
			print("SortMinSec")
			Object.Sound("TrafficTerminal","SnitchFound")
		elseif NewPrisoner.Category=="Normal" and SortMed=="YES" then
			Set(NewPrisoner,"Category",4)
			print("SortNormal")
			Object.Sound("TrafficTerminal","SnitchFound")
		elseif NewPrisoner.Category=="MaxSec" and SortMax=="YES" then
			Set(NewPrisoner,"Category",4)
			print("SortMaxSec")
			Object.Sound("TrafficTerminal","SnitchFound")
		elseif NewPrisoner.Category=="SuperMax" and SortSuper=="YES" then
			Set(NewPrisoner,"Category",4)
			print("SortSuperMax")
			Object.Sound("TrafficTerminal","SnitchFound")
		elseif NewPrisoner.Category=="Protected" then
			print("SortProtected")
			Object.Sound("TrafficTerminal","SnitchFound")
		end
	end
	if SortLegendary ~= "NO" and NewPrisoner.Gang.Rank==3 then
		if NewPrisoner.Category~="DeathRow" then
			Set(NewPrisoner,"Category",NewCategory[this.SortLegendary])
			print("SortLegendary")
			Object.Sound("TrafficTerminal","SnitchFound")
		end
	end
	if SortLieutenant ~= "NO" and NewPrisoner.Gang.Rank==2 then
		if NewPrisoner.Category~="DeathRow" then
			Set(NewPrisoner,"Category",NewCategory[this.SortLieutenant])
			print("SortLieutenant")
			Object.Sound("TrafficTerminal","SnitchFound")
		end
	end
	if SortRedGang ~= "NO" and NewPrisoner.Gang.Id==2 then
		if NewPrisoner.Category~="DeathRow" then
			Set(NewPrisoner,"Category",NewCategory[this.SortRedGang])
			print("SortRedGang")
			Object.Sound("TrafficTerminal","SnitchFound")
		end
	end
	if SortGreenGang ~= "NO" and NewPrisoner.Gang.Id==3 then
		if NewPrisoner.Category~="DeathRow" then
			Set(NewPrisoner,"Category",NewCategory[this.SortGreenGang])
			print("SortGreenGang")
			Object.Sound("TrafficTerminal","SnitchFound")
		end
	end
	if SortBlueGang ~= "NO" and NewPrisoner.Gang.Id==4 then
		if NewPrisoner.Category~="DeathRow" then
			Set(NewPrisoner,"Category",NewCategory[this.SortBlueGang])
			print("SortBlueGang")
			Object.Sound("TrafficTerminal","SnitchFound")
		end
	end
	if SortAddicted ~= "NO" then
		if NewPrisoner.Category~="DeathRow" then
			for thatNeed, distance in pairs(NewPrisoner.Needs.NeedsMetaTable.GetterTable) do -- walk through a list of the prisoners available needs
				if thatNeed == "Alcohol" or thatNeed == "Drugs" then
					Set(NewPrisoner,"Category",NewCategory[this.SortAddicted])
					print("SortAddicted")
					Object.Sound("TrafficTerminal","SnitchFound")
				end
			end
		end
	end
	if SortMothers ~= "NO" then
		if NewPrisoner.Category~="DeathRow" then
			for thatNeed, distance in pairs(NewPrisoner.Needs.NeedsMetaTable.GetterTable) do -- walk through a list of the prisoners available needs
				if thatNeed == "BabyPlay" or thatNeed == "BabySleep" then
					Set(NewPrisoner,"Category",NewCategory[this.SortMothers])
					Set(NewPrisoner,"AvailableMoney",100)	-- grant some cash so mothers who don't work can still settle Luxuries needs via vending machines or shop
					print("SortMothers")
					Object.Sound("TrafficTerminal","SnitchFound")
				end
			end
		end
	end
	if SortInsane ~= "NO" and NewPrisoner.Category ~= "Insane" and NewPrisoner.RequiredCellType == "PaddedCell" then
		print("SortInsane")
		Object.Sound("TrafficTerminal","SnitchFound")
		if this.SortInsane ~= "Insane" then
			local PrisSub = NewPrisoner.SubType
			NewPrisoner.Delete()
			local SpawnedPrisoner = Object.Spawn("Prisoner",NewHolder.Pos.x,NewHolder.Pos.y)
			SpawnedPrisoner.SubType = PrisSub
			SpawnedPrisoner.Shackled = true
			SpawnedPrisoner.IsNewIntake = true
			Set(SpawnedPrisoner,"Category",NewCategory[this.SortInsane])
			Set(NewHolder,"Tooltip",SpawnedPrisoner.Category.." Prisoner")
			Set(NewHolder,"HolderCategory",SpawnedPrisoner.Category)
			Set(NewHolder,"Slot0.i",SpawnedPrisoner.Id.i)
			Set(NewHolder,"Slot0.u",SpawnedPrisoner.Id.u)
			Set(SpawnedPrisoner,"CarrierId.i",NewHolder.Id.i)
			Set(SpawnedPrisoner,"CarrierId.u",NewHolder.Id.u)
			Set(SpawnedPrisoner,"Loaded",true)
			Set(SpawnedPrisoner,"Locked",true)
			return SpawnedPrisoner
		else
			Set(NewPrisoner,"Category",NewCategory[this.SortInsane])
		end
	end
end



	-------------------------------------------------------------------------------------------
	-- Find CargoStations
	-------------------------------------------------------------------------------------------
function FindCargoStations()
	print("FindCargoStations")
	StationOrPadFound = false
	Traffic = {}
	local StationsToSort={}
    local MyCargoStations = Find(this,"CargoStopSign",10000)
	local StationCounter=0
	for theStation,dist in pairs(MyCargoStations) do
		StationCounter=StationCounter + 1
		print("Found Cargo stop "..StationCounter.." is at "..theStation.Pos.x.." "..theStation.Pos.y.."  ID: "..theStation.Id.u.." Number: "..theStation.Number)
		StationsToSort[StationCounter]=theStation.Number
	end
	table.sort(StationsToSort)
	StationCounter=0
	for i,n in ipairs(StationsToSort) do 
		for theStation,distance in pairs(MyCargoStations) do
			if theStation.Number==StationsToSort[i] then
				StationCounter=StationCounter + 1
				print("Sorted Cargo stop "..StationCounter.." is at: "..theStation.Pos.x.." "..theStation.Pos.y.." ID: "..theStation.Id.u.." Number: "..theStation.Number)
				Traffic[StationCounter] = {}
				Traffic[StationCounter].CargoStation=theStation
				Traffic[StationCounter].CargoStation.Tooltip = { "tooltip_CargoStopSign",theStation.HomeUID,"X",theStation.CargoStationID,"Y",theStation.Number,"Z" }
				StationOrPadFound = true
			end
		end
	end
	
	StationCounter=StationCounter + 1
	
	MyCargoStations = nil
	
	
	-------------------------------------------------------------------------------------------
	-- Find helipads
	-------------------------------------------------------------------------------------------
    local MyHeliPads = Find(this,"CargoHelipad",10000)
    if next(MyHeliPads) then
		for thatHeliPad,dist in pairs(MyHeliPads) do
			if thatHeliPad.HelipadMade == true then
				print("Found HeliPad "..StationCounter)
				Traffic[StationCounter] = {}
				Traffic[StationCounter].CargoStation = thatHeliPad
				Traffic[StationCounter].CargoStation.Number = StationCounter
				Traffic[StationCounter].CargoStation.Tooltip = { "tooltip_CargoHelipad",thatHeliPad.HomeUID,"Y",StationCounter,"Z" }
				StationOrPadFound = true
				StationCounter=StationCounter + 1
			end
		end
	end
	MyHeliPads = nil
	
	
	-------------------------------------------------------------------------------------------
	-- Find railway stations
	-------------------------------------------------------------------------------------------
    -- local MyRailways = Find(this,"RailwayStopSign",10000)
    -- if next(MyRailways) then
		-- for thatRailway,dist in pairs(MyRailways) do
			-- if thatRailway.RailsMade == true then
				-- print("Found Railway Station "..StationCounter)
				-- Traffic[StationCounter] = {}
				-- Traffic[StationCounter].CargoStation = thatRailway
				-- Traffic[StationCounter].CargoStation.Number = StationCounter
				-- Traffic[StationCounter].CargoStation.Tooltip = { "tooltip_CargoStopSign",thatRailway.HomeUID,"X",thatRailway.CargoStationID,"Y",thatRailway.Number,"Z" }
				-- StationOrPadFound = true
				-- StationCounter=StationCounter + 1
			-- end
		-- end
	-- end
	-- MyRailways = nil
	
	Set(this,"UpdateTraffic",false)
	return StationOrPadFound
end

	
	-------------------------------------------------------------------------------------------
	--Buttons
	-------------------------------------------------------------------------------------------
	
function toggleAnimateChinookClicked()
	if Get(this,"AnimateChinook") == "no" then
		Set(this,"AnimateChinook","yes")
	else
		Set(this,"AnimateChinook","no")
	end
	this.SetInterfaceCaption("toggleAnimateChinook","tooltip_TrafficTerminal_Button_AnimateChinook",this.AnimateChinook,"X")
end

function toggleTruckLightsClicked()
	if Get(this,"TruckLights") == "always" then
		Set(this,"TruckLights","night")
	elseif Get(this,"TruckLights") == "night" then
		Set(this,"TruckLights","off")
	else
		Set(this,"TruckLights","always")
	end
	this.SetInterfaceCaption("toggleTruckLights","tooltip_TrafficTerminal_Button_TruckLights",this.TruckLights,"X")
end

function SpawnTruckLightsOK()
	if Get(this,"TruckLights") == "always" then
		return true
	elseif Get(this,"TruckLights") == "night" then
		local hours = math.floor(math.mod(World.TimeIndex,1440) /60)
		print("SpawnTruckLightsOK -->> current hour is: "..hours)
		if hours > 18 or hours < 8 then
			print("SpawnTruckLightsOK -->> enable vehicle lights")
			return true
		end
	end
	return false
end

function toggleIntakeMethodClicked()
	if Get(this,"IntakeMethod") == "SUSPEND" then
		Set(this,"IntakeMethod","AUTO")
		FindKnownPrisoners()
	else
		Set(this,"IntakeMethod","SUSPEND")
		AutoSpawnIntakeActive = nil
		NextIntakeTick = nil
	end
	if not Exists(GrantCheckerTerminalI) then
		GrantCheckerTerminalI = Object.Spawn("GrantCheckerTerminalI",this.Pos.x+4,this.Pos.y+4)
	else
		GrantCheckerTerminalI.Delete()
	end
	UpdatePrisonerDisplays()
	this.Tooltip = { "tooltip_TrafficTerminal",this.DeliveryMethod,"X",this.IntakeMethod,"Y",TotalQueuedStack,"A",TotalQueuedPrisoners,"B",
		#PrisonersInQueue[PrisonerDest[1]],"C",
		#PrisonersInQueue[PrisonerDest[2]],"D",
		#PrisonersInQueue[PrisonerDest[3]],"E",
		#PrisonersInQueue[PrisonerDest[4]],"F",
		#PrisonersInQueue[PrisonerDest[5]],"G",
		#PrisonersInQueue[PrisonerDest[6]],"H",
		#PrisonersInQueue[PrisonerDest[7]],"I" }

	this.SetInterfaceCaption("toggleIntakeMethod","tooltip_TrafficTerminal_IntakeMethod",this.IntakeMethod,"X")
	if Get(this,"IntakeMethod") == "SUSPEND" then		-- put prisoners back beneath the terminal
		tmpTrucks = Find("CargoStationTruck",10000)
		for thatTruck, dist in pairs(tmpTrucks) do
			if thatTruck.SkinType == "Intake" then
				Set(thatTruck,"DeleteMe",true)
			end
		end
		tmpTrucks = nil
		tmpChinooks = Find("Chinook2",10000)
		for thatChinook, dist in pairs(tmpChinooks) do
			if thatChinook.MyType == "Intake" then
				Set(thatChinook,"DeleteMe",true)
			end
		end
		tmpChinooks = nil
	end
	this.Sound("_Deployment","SetNone")
end

function toggleDeliveryMethodClicked()
	if Get(this,"DeliveryMethod") == "SUSPEND" then
		Set(this,"DeliveryMethod","AUTO")
	else
		Set(this,"DeliveryMethod","SUSPEND")
		AutoSpawnCargoActive = nil
		NextCargoTick = nil
	end
	if this.DeliveryMethod == "SUSPEND" then
		if TotalQueuedStack > 0 then
			DisplayCargoL.SubType = 4
		else
			DisplayCargoL.SubType = 0
		end
		DisplayCargoR.SubType = 0
	else
		if TotalQueuedStack > 0 then
			DisplayCargoL.SubType = 3
		else
			DisplayCargoL.SubType = 2
		end
		DisplayCargoR.SubType = 1
	end
	if not Exists(GrantCheckerTerminal) then
		GrantCheckerTerminal = Object.Spawn("GrantCheckerTerminal",this.Pos.x+4,this.Pos.y+4)
	else
		GrantCheckerTerminal.Delete()
	end
	this.Tooltip = { "tooltip_TrafficTerminal",this.DeliveryMethod,"X",this.IntakeMethod,"Y",TotalQueuedStack,"A",TotalQueuedPrisoners,"B",
		#PrisonersInQueue[PrisonerDest[1]],"C",
		#PrisonersInQueue[PrisonerDest[2]],"D",
		#PrisonersInQueue[PrisonerDest[3]],"E",
		#PrisonersInQueue[PrisonerDest[4]],"F",
		#PrisonersInQueue[PrisonerDest[5]],"G",
		#PrisonersInQueue[PrisonerDest[6]],"H",
		#PrisonersInQueue[PrisonerDest[7]],"I" }
	this.SetInterfaceCaption("toggleDeliveryMethod","tooltip_TrafficTerminal_DeliveryMethod",this.DeliveryMethod,"X")
	if Get(this,"DeliveryMethod") == "SUSPEND" then		-- put deliveries from CargoStationTrucks back beneath the terminal
		tmpTrucks = Find("CargoStationTruck",10000)
		for thatTruck, dist in pairs(tmpTrucks) do
			if thatTruck.SkinType == "Deliveries" then
				Set(thatTruck,"DeleteMe",true)
			end
		end
		tmpTrucks = nil
		tmpChinooks = Find("Chinook2",10000)
		for thatChinook, dist in pairs(tmpChinooks) do
			if thatChinook.MyType == "Cargo" then
				Set(thatChinook,"DeleteMe",true)
			end
		end
		tmpChinooks = nil
		
	end
	this.Sound("_Deployment","SetNone")
end

function AddSnitchButtons()
	Interface.AddComponent(this,"TT_CaptionSnitchOptions", "Caption", "tooltip_TrafficTerminal_TerminalSnitchConfig")
	Interface.AddComponent(this,"toggleSortMin", "Button", "tooltip_TrafficTerminal_Button_minsec","tooltip_TrafficTerminal_"..this.SortMin,"X")
	Interface.AddComponent(this,"toggleSortMed", "Button", "tooltip_TrafficTerminal_Button_medsec","tooltip_TrafficTerminal_"..this.SortMed,"X")
	Interface.AddComponent(this,"toggleSortMax", "Button", "tooltip_TrafficTerminal_Button_maxsec","tooltip_TrafficTerminal_"..this.SortMax,"X")
	Interface.AddComponent(this,"toggleSortSuper", "Button", "tooltip_TrafficTerminal_Button_supmax","tooltip_TrafficTerminal_"..this.SortSuper,"X")
	Interface.AddComponent(this,"TT_PrisonerSorter", "Caption", "tooltip_TrafficTerminal_TerminalPrisonerSort")
	Interface.AddComponent(this,"toggleSortLegendary", "Button", "tooltip_TrafficTerminal_Button_legendary","tooltip_TrafficTerminal_"..this.SortLegendary,"X")
	Interface.AddComponent(this,"toggleSortLieutenant", "Button", "tooltip_TrafficTerminal_Button_lieutenant","tooltip_TrafficTerminal_"..this.SortLieutenant,"X")
	Interface.AddComponent(this,"toggleSortRedGang", "Button", "tooltip_TrafficTerminal_Button_red","tooltip_TrafficTerminal_"..this.SortRedGang,"X")
	Interface.AddComponent(this,"toggleSortGreenGang", "Button", "tooltip_TrafficTerminal_Button_green","tooltip_TrafficTerminal_"..this.SortGreenGang,"X")
	Interface.AddComponent(this,"toggleSortBlueGang", "Button", "tooltip_TrafficTerminal_Button_blue","tooltip_TrafficTerminal_"..this.SortBlueGang,"X")
	Interface.AddComponent(this,"toggleSortAddicted", "Button", "tooltip_TrafficTerminal_Button_addicted","tooltip_TrafficTerminal_"..this.SortAddicted,"X")
	Interface.AddComponent(this,"toggleSortMothers", "Button", "tooltip_TrafficTerminal_Button_mother","tooltip_TrafficTerminal_"..this.SortMothers,"X")
	Interface.AddComponent(this,"toggleSortInsane", "Button", "tooltip_TrafficTerminal_Button_insane","tooltip_TrafficTerminal_"..this.SortInsane,"X")

	SnitchRange = this.SnitchRange
	SortMin = this.SortMin
	SortMed = this.SortMed
	SortMax = this.SortMax
	SortSuper = this.SortSuper
	SortLegendary = this.SortLegendary
	SortLieutenant = this.SortLieutenant
	SortRedGang = this.SortRedGang
	SortGreenGang = this.SortGreenGang
	SortBlueGang = this.SortBlueGang
	SortAddicted = this.SortAddicted
	SortMothers = this.SortMothers
end

function ToggleYesNo(property)
	local Property = Get(this,property)
	if Property == "YES" then Property = "NO" else Property = "YES" end
	Set(this,property,Property)
	return Property
end

function ToggleSecLevel(property)
	local Property = Get(this,property)
	if Property == "NO" then Property = "MinSec"
	elseif Property == "MinSec" then Property = "Normal"
	elseif Property == "Normal" then Property = "MaxSec"
	elseif Property == "MaxSec" then Property = "SuperMax"
	elseif Property == "SuperMax" then Property = "Protected"
	elseif Property == "Protected" then Property = "DeathRow"
	elseif Property == "DeathRow" then Property = "NO" end
	Set(this,property,Property)
	return Property
end

function toggleSortMinClicked()
	SortMin = ToggleYesNo("SortMin")
	this.SetInterfaceCaption("toggleSortMin", "tooltip_TrafficTerminal_Button_minsec","tooltip_TrafficTerminal_"..SortMin,"X")
end

function toggleSortMedClicked()
	SortMed = ToggleYesNo("SortMed")
	this.SetInterfaceCaption("toggleSortMed", "tooltip_TrafficTerminal_Button_medsec","tooltip_TrafficTerminal_"..SortMed,"X")
end

function toggleSortMaxClicked()
	SortMax = ToggleYesNo("SortMax")
	this.SetInterfaceCaption("toggleSortMax", "tooltip_TrafficTerminal_Button_maxsec","tooltip_TrafficTerminal_"..SortMax,"X")
end

function toggleSortSuperClicked()
	SortSuper = ToggleYesNo("SortSuper")
	this.SetInterfaceCaption("toggleSortSuper", "tooltip_TrafficTerminal_Button_supmax","tooltip_TrafficTerminal_"..SortSuper,"X")
end

function toggleSortLegendaryClicked()
	SortLegendary = ToggleSecLevel("SortLegendary")
	this.SetInterfaceCaption("toggleSortLegendary", "tooltip_TrafficTerminal_Button_legendary","tooltip_TrafficTerminal_"..SortLegendary,"X")
end

function toggleSortLieutenantClicked()
	SortLieutenant = ToggleSecLevel("SortLieutenant")
	this.SetInterfaceCaption("toggleSortLieutenant", "tooltip_TrafficTerminal_Button_lieutenant","tooltip_TrafficTerminal_"..SortLieutenant,"X")
end

function toggleSortRedGangClicked()
	SortRedGang = ToggleSecLevel("SortRedGang")
	this.SetInterfaceCaption("toggleSortRedGang", "tooltip_TrafficTerminal_Button_red","tooltip_TrafficTerminal_"..SortRedGang,"X")
end

function toggleSortGreenGangClicked()
	SortGreenGang = ToggleSecLevel("SortGreenGang")
	this.SetInterfaceCaption("toggleSortGreenGang", "tooltip_TrafficTerminal_Button_green","tooltip_TrafficTerminal_"..SortGreenGang,"X")
end

function toggleSortBlueGangClicked()
	SortBlueGang = ToggleSecLevel("SortBlueGang")
	this.SetInterfaceCaption("toggleSortBlueGang", "tooltip_TrafficTerminal_Button_blue","tooltip_TrafficTerminal_"..SortBlueGang,"X")
end

function toggleSortAddictedClicked()
	SortAddicted = ToggleSecLevel("SortAddicted")
	this.SetInterfaceCaption("toggleSortAddicted", "tooltip_TrafficTerminal_Button_addicted","tooltip_TrafficTerminal_"..SortAddicted,"X")
end

function toggleSortMothersClicked()
	SortMothers = ToggleSecLevel("SortMothers")
	this.SetInterfaceCaption("toggleSortMothers", "tooltip_TrafficTerminal_Button_mother","tooltip_TrafficTerminal_"..SortMothers,"X")
end

function toggleSortInsaneClicked()
	SortInsane = ToggleSecLevel("SortInsane")
	this.SetInterfaceCaption("toggleSortInsane", "tooltip_TrafficTerminal_Button_insane","tooltip_TrafficTerminal_"..SortInsane,"X")
end


function RemoveStackClicked()
	local myStack = Find(this,"Stack",4)
	for thatStack, dist in pairs(myStack) do
		thatStack.Delete()
	end
	local myBox = Find(this,"Box",4)
	for thatBox, dist in pairs(myBox) do
		thatBox.Delete()
	end
	local myMails = Find(this,"MailSatchel",4)
	for thatMail, dist in pairs(myMails) do
		thatMail.Delete()
	end
	
	StackInQueue = {  Food = {},
						Laundry = {},
						Vending = {},
						Forest = {},
						Workshop1 = {},
						Workshop2 = {},
						Workshop3 = {},
						Workshop4 = {},
						Workshop5 = {},
						Building = {},
						Floor = {},
						Other = {}
					}
	TotalQueuedStack = 0
	for T = 1,12 do
		TotalQueuedStack = TotalQueuedStack + #StackInQueue[StackDest[T]]
	end
	
	this.Tooltip = { "tooltip_TrafficTerminal",this.DeliveryMethod,"X",this.IntakeMethod,"Y",TotalQueuedStack,"A",TotalQueuedPrisoners,"B",
	#PrisonersInQueue[PrisonerDest[1]],"C",
	#PrisonersInQueue[PrisonerDest[2]],"D",
	#PrisonersInQueue[PrisonerDest[3]],"E",
	#PrisonersInQueue[PrisonerDest[4]],"F",
	#PrisonersInQueue[PrisonerDest[5]],"G",
	#PrisonersInQueue[PrisonerDest[6]],"H",
	#PrisonersInQueue[PrisonerDest[7]],"I" }
	
	QueuedStackAreaTop.Tooltip = { "tooltip_StackInQueueTop_Totals",
	#StackInQueue[StackDest[1]],"A",
	#StackInQueue[StackDest[2]],"B",
	#StackInQueue[StackDest[3]],"C",
	#StackInQueue[StackDest[4]],"D",
	#StackInQueue[StackDest[5]],"E",
	#StackInQueue[StackDest[6]],"F" }
	
	QueuedStackAreaBottom.Tooltip = { "tooltip_StackInQueueBottom_Totals",
	#StackInQueue[StackDest[7]],"A",
	#StackInQueue[StackDest[8]],"B",
	#StackInQueue[StackDest[9]],"C",
	#StackInQueue[StackDest[10]],"D",
	#StackInQueue[StackDest[11]],"E",
	#StackInQueue[StackDest[12]],"F" }
end

function RemovePrisonersClicked()
	local myHolders = Find(this,"PrisonerStackHolder",6)
	for thatHolder, dist in pairs(myHolders) do
		thatHolder.Delete()
	end
	local myPrisoners = Find(this,"Prisoner",6)
	for thatPrisoner, dist in pairs(myPrisoners) do
		thatPrisoner.Delete()
	end
	TotalQueuedPrisoners = 0
	PrisonersInQueue = {	MinSec = {},
							Normal = {},
							MaxSec = {},
							Protected = {},
							SuperMax = {},
							DeathRow = {},
							Insane = {}
						}
	
	this.Tooltip = { "tooltip_TrafficTerminal",this.DeliveryMethod,"X",this.IntakeMethod,"Y",TotalQueuedStack,"A",TotalQueuedPrisoners,"B",
	#PrisonersInQueue[PrisonerDest[1]],"C",
	#PrisonersInQueue[PrisonerDest[2]],"D",
	#PrisonersInQueue[PrisonerDest[3]],"E",
	#PrisonersInQueue[PrisonerDest[4]],"F",
	#PrisonersInQueue[PrisonerDest[5]],"G",
	#PrisonersInQueue[PrisonerDest[6]],"H",
	#PrisonersInQueue[PrisonerDest[7]],"I" }
						
	UpdatePrisonerDisplays()
end

function DeleteTerminalClicked()
	local OldStuff = {"TrafficTerminalIntakeDisplayLeft","TrafficTerminalIntakeDisplayRight", "StackInQueueTop",
						"TrafficTerminalCargoDisplayLeft","TrafficTerminalCargoDisplayRight", "StackInQueueBottom",
						"TrafficTerminalIntakeDisplay", "WallLight","StreetManager2","QueuedStackChecker" }
	for _, typ in pairs(OldStuff) do
		local nearbyObjects = Find(this,typ,6)
		for thatObject, _ in pairs(nearbyObjects) do
			if thatObject.HomeUID == this.HomeUID then
				thatObject.Delete()
			end
		end
	end
	
	local nearbyObjects = Find(this,"TmpCargoTruckBay",6)
	for thatTmpCargo, _ in pairs(nearbyObjects) do
		thatTmpCargo.Pos.x = this.Pos.x
		thatTmpCargo.Pos.y = this.Pos.y
		thatTmpCargo.Delete()
	end
	
	RemoveStackClicked()
	
	for C = 1, #Traffic do
		Traffic[C].CargoStation.Number = 0
		Traffic[C].CargoStation.Status = "TerminalRemoved"
		Traffic[C].CargoStation.Tooltip = "tooltip_CargoStopSign_TrafficTerminalRequired"
	end
	
	local x = math.floor(this.Pos.x)+1
	local y = math.floor(this.Pos.y)
	local Ymin = 0
	local Ymax = 0
	local Xmin = 0
	local Xmax = 0
	for i=Ymin-4,Ymax+4 do	for j=Xmin-5,Xmax+4 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "LooseStone"; cell.Ind = false end	end

	World.ImmediateMaterials = nil
	this.Delete()
end

	-------------------------------------------------------------------------------------------
	-- Only one terminal may exist on the map
	-------------------------------------------------------------------------------------------
	
function DeleteOtherTerminals()
	print("DeleteOtherTerminals")
	OtherTerminals = Find("TrafficTerminal",10000)
	for thatTerminal, dist in pairs(OtherTerminals) do
		if thatTerminal.Id.i ~= this.Id.i then
		
			local nearbyTopQAreas = Find(thatTerminal,"StackInQueueTop",5)
			if next(nearbyTopQAreas) then
				for thatQArea, dist in pairs(nearbyTopQAreas) do
					QueuedStackAreaTop = thatQArea
					Set(QueuedStackAreaTop,"HomeUID",this.HomeUID)
					Set(QueuedStackAreaTop,"Pos.x",this.Pos.x+0.5)
					Set(QueuedStackAreaTop,"Pos.y",this.Pos.y-2)
				end
			end
			nearbyTopQAreas = nil
			
			local nearbyBottomQAreas = Find(thatTerminal,"StackInQueueBottom",5)
			if next(nearbyBottomQAreas) then
				for thatQArea, dist in pairs(nearbyBottomQAreas) do
					QueuedStackAreaBottom = thatQArea
					Set(QueuedStackAreaBottom,"HomeUID",this.HomeUID)
					Set(QueuedStackAreaBottom,"Pos.x",this.Pos.x+0.5)
					Set(QueuedStackAreaBottom,"Pos.y",this.Pos.y+2)
				end
			end
			nearbyBottomQAreas = nil
			
			local nearbyObjects = Find(thatTerminal,"TmpCargoTruckBay",6)
			for thatTmpCargo, _ in pairs(nearbyObjects) do
				thatTmpCargo.Pos.x = this.Pos.x+4
				thatTmpCargo.Pos.y = this.Pos.y+2
			end
	
			local X = this.Pos.x-4
			local Y = this.Pos.y-4
			local IncomingStuffToFind = { "Stack", "Box", "MailSatchel" }
			for S, typ in pairs(IncomingStuffToFind) do
				local incomingObjects = Find(thatTerminal,typ,6)
				if next(incomingObjects) then
					local A = 0
					for thatItem, distance in pairs(incomingObjects) do
						Set(thatItem,"Contains",nil)
						Set(thatItem,"Sorted",nil)
						print("DeleteOtherTerminals -->> Transferring item: "..thatItem.Type.." ID: "..thatItem.Id.i)
						Set(thatItem,"CarrierId.i",-1)
						Set(thatItem,"CarrierId.u",-1)
						Set(thatItem,"Loaded",false)
						Set(thatItem,"Hidden",false)
						local X = this.Pos.x-3+A	-- put the stuff on a random floor row at the terminal room
						local Y = this.Pos.y
						if math.random() > 0.90 then X = this.Pos.x-3+A; Y = this.Pos.y-3
						elseif math.random() > 0.70 then X = this.Pos.x-3+A; Y = this.Pos.y-1
						elseif math.random() > 0.50 then X = this.Pos.x-3+A; Y = this.Pos.y
						elseif math.random() > 0.30 then X = this.Pos.x+4-A; Y = this.Pos.y+1
						elseif math.random() > 0.20 then X = this.Pos.x+4-A; Y = this.Pos.y
						else X = this.Pos.x+4-A; Y = this.Pos.y-1
						end
						Set(thatItem,"Pos.x",X)
						Set(thatItem,"Pos.y",Y)
						Object.ApplyVelocity(thatItem,-0.5+math.random(),-0.5+math.random(),false)
						Set(thatItem,"Tooltip","Transferred by Traffic Terminal\nID: "..thatItem.Id.i)
						A = A + 1
						if A > 7 then A = 0 end
					end
				end
				incomingObjects = nil
			end

			local OtherPrisonersToFind = Find(thatTerminal,"Prisoner",5)
			local OtherPrisonerHolders = Find(thatTerminal,"PrisonerStackHolder",5)
			if next(OtherPrisonerHolders) then
				for thatHolder, distance in pairs(OtherPrisonerHolders) do
					for thatPrisoner, dist in pairs(OtherPrisonersToFind) do
						if Get(thatPrisoner,"CarrierId.i") == thatHolder.Id.i then
							SortPrisoner(thatPrisoner, thatHolder)
							
							Set(thatHolder,"TrafficTerminalID",this.Id.i)
							Set(thatHolder,"Pos.y",this.Pos.y+2)
							Set(thatHolder,"Pos.x",this.Pos.x-3)
							
							local ForDestination = thatPrisoner.Category
							
							table.insert( PrisonersInQueue[ForDestination], thatPrisoner )		-- add the prisoner at the end of the specific PrisonersInQueue table
							local numP = #PrisonersInQueue[ForDestination]
							Set(PrisonersInQueue[ForDestination][ N ],"MapBottom",World.NumCellsY)
							print("AddNewPrisoners -->> Sorted new Prisoner ID: "..thatPrisoner.Id.i.." to "..PrisonersInQueue[ForDestination][ numP ].Category)
							print("AddNewPrisoners -->> PrisonersInQueue "..ForDestination.." has "..numP.." records")
							
							thatPrisoner = nil
							break
						end
					end
				end
			end
			OtherPrisonersToFind = nil
			OtherPrisonerHolders = nil
			UpdatePrisonerDisplays()
			
			local OldStuff = {"TrafficTerminalIntakeDisplayLeft","TrafficTerminalIntakeDisplayRight",
								"TrafficTerminalCargoDisplayLeft","TrafficTerminalCargoDisplayRight",
								"TrafficTerminalIntakeDisplay","WallLight","StreetManager2","QueuedStackChecker" }
			for _, typ in pairs(OldStuff) do
				local nearbyObjects = Find(thatTerminal,typ,6)
				for thatObject, _ in pairs(nearbyObjects) do
					if thatObject.Type == "QueuedStackChecker" then
						MyChecker = thatObject
						Set(MyChecker,"HomeUID",this.HomeUID)
					elseif thatObject.HomeUID == thatTerminal.HomeUID then
						thatObject.Delete()
					end
				end
				nearbyObjects = nil
			end
			
			local x = math.floor(thatTerminal.Pos.x)+1
			local y = math.floor(thatTerminal.Pos.y)
			local Ymin = 0
			local Ymax = 0
			local Xmin = 0
			local Xmax = 0
			for i=Ymin-4,Ymax+4 do	for j=Xmin-5,Xmax+4 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "LooseStone"; cell.Ind = false end	end

			Set(this,"SubType_Ambulance",thatTerminal.SubType_Ambulance)
			Set(this,"SubType_FireEngine",thatTerminal.SubType_FireEngine)
			Set(this,"SubType_EmergencyStationTruck",thatTerminal.SubType_EmergencyStationTruck)
			Set(this,"SubType_IntakeStationTruck",thatTerminal.SubType_IntakeStationTruck)
			Set(this,"SubType_RiotVan",thatTerminal.SubType_RiotVan)
			Set(this,"SubType_DeliveriesStationTruck",thatTerminal.SubType_DeliveriesStationTruck)
			Set(this,"SubType_ExportsStationTruck",thatTerminal.SubType_ExportsStationTruck)
			Set(this,"SubType_GarbageStationTruck",thatTerminal.SubType_GarbageStationTruck)
			Set(this,"SubType_Troop",thatTerminal.SubType_Troop)
			
			Set(this,"SortMin",thatTerminal.SortMin)
			Set(this,"SortMed",thatTerminal.SortMed)
			Set(this,"SortMax",thatTerminal.SortMax)
			Set(this,"SortSuper",thatTerminal.SortSuper)
			Set(this,"SortLegendary",thatTerminal.SortLegendary)
			Set(this,"SortLieutenant",thatTerminal.SortLieutenant)
			Set(this,"SortRedGang",thatTerminal.SortRedGang)
			Set(this,"SortGreenGang",thatTerminal.SortGreenGang)
			Set(this,"SortBlueGang",thatTerminal.SortBlueGang)
			Set(this,"SortAddicted",thatTerminal.SortAddicted)
			Set(this,"SortMothers",thatTerminal.SortMothers)
			Set(this,"SortInsane",thatTerminal.SortInsane)
			
			thatTerminal.Delete()
			if Exists(MyChecker) then
				MyChecker.Pos.x,MyChecker.Pos.y = this.Pos.x-3,this.Pos.y-3
			end
			OtherTerminalDeleted = true
		end
	end
	OtherTerminals = nil
end

function RemoveTrees(from,dist)
	for j = 1, #TreeTypes do
		for thatTree in next, Find(from,TreeTypes[j],dist) do
			thatTree.Delete()
		end
	end
end

function CleanTerminalFloor()
	local x = math.floor(this.Pos.x)+1
	local y = math.floor(this.Pos.y)
	local Ymin = 0
	local Ymax = 0
	local Xmin = 0
	local Xmax = 0
	for i=Ymin-4,Ymax+4 do	for j=Xmin-5,Xmax+4 do	local cell = World.GetCell(x+j,y+i);	cell.Con = 100 end	end
end

function DoOnce()
	print("DoOnce")
	Set(this,"HomeUID","TrafficTerminal"..me["id-uniqueId"])
	
	RemoveTrees(this,8)
	
	DisplayMinSec = Object.Spawn("TrafficTerminalIntakeDisplayLeft",this.Pos.x-2.5,this.Pos.y-0.5)
	DisplayNormal = Object.Spawn("TrafficTerminalIntakeDisplayRight",this.Pos.x-2.5,this.Pos.y-0.5)
	DisplayMaxSec = Object.Spawn("TrafficTerminalIntakeDisplayLeft",this.Pos.x-1.5,this.Pos.y-0.5)
	DisplaySuperMax = Object.Spawn("TrafficTerminalIntakeDisplayRight",this.Pos.x-1.5,this.Pos.y-0.5)
	DisplayInsane = Object.Spawn("TrafficTerminalIntakeDisplayLeft",this.Pos.x-0.5,this.Pos.y-0.5)
	DisplayDeathRow = Object.Spawn("TrafficTerminalIntakeDisplayRight",this.Pos.x-0.5,this.Pos.y-0.5)
	DisplayIntake = Object.Spawn("TrafficTerminalIntakeDisplay",this.Pos.x+0.5,this.Pos.y-0.5)
	DisplayCargoL = Object.Spawn("TrafficTerminalCargoDisplayLeft",this.Pos.x+1.5,this.Pos.y-0.5)
	DisplayCargoR = Object.Spawn("TrafficTerminalCargoDisplayRight",this.Pos.x+2.5,this.Pos.y-0.5)
		
	Set(DisplayMinSec,"HomeUID",this.HomeUID)
	Set(DisplayMinSec,"Display","MinSec")
	Set(DisplayNormal,"HomeUID",this.HomeUID)
	Set(DisplayNormal,"Display","Normal")
	Set(DisplayMaxSec,"HomeUID",this.HomeUID)
	Set(DisplayMaxSec,"Display","MaxSec")
	Set(DisplaySuperMax,"HomeUID",this.HomeUID)
	Set(DisplaySuperMax,"Display","SuperMax")
	Set(DisplayInsane,"HomeUID",this.HomeUID)
	Set(DisplayInsane,"Display","Insane")
	Set(DisplayDeathRow,"HomeUID",this.HomeUID)
	Set(DisplayDeathRow,"Display","DeathRow")
	
	Set(DisplayIntake,"HomeUID",this.HomeUID)
	Set(this,"Slot0.i",DisplayIntake.Id.i)
	Set(this,"Slot0.u",DisplayIntake.Id.u)
	Set(DisplayIntake,"CarrierId.i",this.Id.i)
	Set(DisplayIntake,"CarrierId.u",this.Id.u)
	Set(DisplayIntake,"Loaded",true)
	
	Set(DisplayCargoL,"HomeUID",this.HomeUID)
	Set(this,"Slot1.i",DisplayCargoL.Id.i)
	Set(this,"Slot1.u",DisplayCargoL.Id.u)
	Set(DisplayCargoL,"CarrierId.i",this.Id.i)
	Set(DisplayCargoL,"CarrierId.u",this.Id.u)
	Set(DisplayCargoL,"Loaded",true)
	
	Set(DisplayCargoR,"HomeUID",this.HomeUID)
	Set(this,"Slot2.i",DisplayCargoR.Id.i)
	Set(this,"Slot2.u",DisplayCargoR.Id.u)
	Set(DisplayCargoR,"CarrierId.i",this.Id.i)
	Set(DisplayCargoR,"CarrierId.u",this.Id.u)
	Set(DisplayCargoR,"Loaded",true)
	
	DisplayCargoL.SubType = 1
	DisplayCargoR.SubType = 1
	DisplayIntake.SubType = 0

	Set(this,"AnimateChinook","no")
	
	Set(this,"SnitchRange",2)
	Set(this,"SortMin","NO")
	Set(this,"SortMed","NO")
	Set(this,"SortMax","NO")
	Set(this,"SortSuper","NO")
	Set(this,"SortLegendary","NO")
	Set(this,"SortLieutenant","NO")
	Set(this,"SortRedGang","NO")
	Set(this,"SortGreenGang","NO")
	Set(this,"SortBlueGang","NO")
	Set(this,"SortAddicted","NO")
	Set(this,"SortMothers","NO")
	Set(this,"SortInsane","NO")
	
	Set(this,"DeliveryMethod","SUSPEND")
	Set(this,"IntakeMethod","SUSPEND")
	
	Set(this,"OrderCat",1)
	Set(this,"OrderCategory","MinSec")
	Set(this,"OrderPris",4)
	Set(this,"OrderPlaced","NO")
	Set(this,"NumOfnoPrisoners",0)
	Set(this,"NumOfALLPrisoners",0)
	Set(this,"NumOfMinSecPrisoners",0)
	Set(this,"NumOfNormalPrisoners",0)
	Set(this,"NumOfMaxSecPrisoners",0)
	Set(this,"NumOfSuperMaxPrisoners",0)
	Set(this,"NumOfProtectedPrisoners",0)
	Set(this,"NumOfInsanePrisoners",0)
	Set(this,"NumOfDeathRowPrisoners",0)
	
	for thatTruck in next, Find(this,"SupplyTruck",10000) do
		for thatWorkman in next, Find(thatTruck,"Workman",6) do
			if thatWorkman.CarrierId.i == thatTruck.Id.i then
				for A = 0,7 do
					Set(thatTruck,"Slot"..A..".i",-1)
					Set(thatTruck,"Slot"..A..".u",-1)
				end
				thatWorkman.CarrierId.i = -1
				thatWorkman.CarrierId.u = -1
				thatWorkman.Loaded = false
			end
		end
		thatTruck.Pos.x,thatTruck.Pos.y = this.Pos.x-0.2,this.Pos.y
		thatTruck.Delete()
	end
	
	DeleteOtherTerminals()
	
	SnitchRange = this.SnitchRange
	SortMin = this.SortMin
	SortMed = this.SortMed
	SortMax = this.SortMax
	SortSuper = this.SortSuper
	SortLegendary = this.SortLegendary
	SortLieutenant = this.SortLieutenant
	SortRedGang = this.SortRedGang
	SortGreenGang = this.SortGreenGang
	SortBlueGang = this.SortBlueGang
	SortAddicted = this.SortAddicted
	SortMothers = this.SortMothers
	
	if not OtherTerminalDeleted then
		QueuedStackAreaTop = Object.Spawn("StackInQueueTop",this.Pos.x+0.5,this.Pos.y-2)
		QueuedStackAreaBottom = Object.Spawn("StackInQueueBottom",this.Pos.x+0.5,this.Pos.y+2)
		
		Set(QueuedStackAreaTop,"HomeUID",this.HomeUID)
		Set(QueuedStackAreaBottom,"HomeUID",this.HomeUID)
		
		Set(this,"SubType_Ambulance",0)
		Set(this,"SubType_FireEngine",0)
		Set(this,"SubType_EmergencyStationTruck",0)
		Set(this,"SubType_IntakeStationTruck",0)
		Set(this,"SubType_RiotVan",0)
		Set(this,"SubType_DeliveriesStationTruck",0)
		Set(this,"SubType_ExportsStationTruck",0)
		Set(this,"SubType_GarbageStationTruck",0)
		Set(this,"SubType_Troop",0)
	end
	
	StreetManager = Object.Spawn("StreetManager2",this.Pos.x+3.5,this.Pos.y)
	Set(StreetManager,"HomeUID",this.HomeUID)
	
	local x = math.floor(this.Pos.x)+1
	local y = math.floor(this.Pos.y)
	local Ymin = 0
	local Ymax = 0
	local Xmin = 0
	local Xmax = 0
	for i=Ymin-4,Ymax+4 do	for j=Xmin-5,Xmax+4 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "YutaniWall"; cell.Ind = true end	end
	for i=Ymin-3,Ymax+3 do	for j=Xmin-4,Xmax+3 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "TTFloorA"; cell.Ind = true end	end
	for i=Ymin-2,Ymax-2 do	for j=Xmin-3,Xmax+2 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "TTFloorB"; cell.Ind = true end	end
	for i=Ymin+2,Ymax+2 do	for j=Xmin-3,Xmax+2 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "TTFloorB"; cell.Ind = true end	end
	for i=Ymin+2,Ymax+2 do	for j=Xmin-4,Xmax-4 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "TTFloorC"; cell.Ind = true end	end
	for i=Ymin+2,Ymax+2 do	for j=Xmin+3,Xmax+3 do	local cell = World.GetCell(x+j,y+i);	cell.Mat = "TTFloorC"; cell.Ind = true end	end
	
	DisplayLightLeft = Object.Spawn("WallLight",this.Pos.x-4,this.Pos.y)
	DisplayLightLeft.Or.x = 1
	DisplayLightLeft.Or.y = 0
	DisplayLightRight = Object.Spawn("WallLight",this.Pos.x+5,this.Pos.y)
	DisplayLightRight.Or.x = -1
	DisplayLightRight.Or.y = 0
	Set(DisplayLightLeft,"HomeUID",this.HomeUID)
	Set(DisplayLightRight,"HomeUID",this.HomeUID)
	
	Set(this,"UpdateTraffic",false)
	Set(this,"InitDone",true)
end


function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
