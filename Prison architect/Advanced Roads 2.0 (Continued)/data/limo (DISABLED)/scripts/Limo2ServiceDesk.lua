
local timeTot = 0
local timeToBill = 0
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects
local nearbyObject = {}

function FindMyCrane()
	--print("FindMyCrane")
	nearbyObject = Find("GantryCrane2RailLeft",50)
	if next(nearbyObject) then
		for thatRail, distance in pairs(nearbyObject) do
			if thatRail.HomeUID==this.HomeUID then
				--print("MyCraneRailLeft found")
				MyCraneRailLeft=thatRail
			end
		end
	end
	nearbyObject=nil
	local nearbyObject = Find("GantryCrane2",50)
	if next(nearbyObject) then
		for thatCrane, distance in pairs(nearbyObject) do
			if thatCrane.HomeUID==this.HomeUID then
				--print("GantryCrane2 found")
				MyCrane=thatCrane
				break
			end
		end
	end
	nearbyObject=nil
	local nearbyObject = Find("GantryCrane2Hook",50)
	if next(nearbyObject) then
		for thatHook, distance in pairs(nearbyObject) do
			if thatHook.HomeUID==this.HomeUID then
				--print("GantryCrane2Hook found")
				MyHook=thatHook
				break
			end
		end
	end
	nearbyObject=nil
	local nearbyObject = Find("GantryCrane2Booth",50)
	if next(nearbyObject) then
		for thatBooth, distance in pairs(nearbyObject) do
			if thatBooth.HomeUID==this.HomeUID then
				MyCraneBooth=thatBooth
				--print("MyCraneBooth found")
				break
			end
		end
	end
	nearbyObject = nil
	local nearbyObject = Find("CarPartsRack2",50)
	if next(nearbyObject) then
		for thatRack, distance in pairs(nearbyObject) do
			if thatRack.HomeUID==this.HomeUID then
				--print("CarPartsRack2 found")
				MyRack=thatRack
				break
			end
		end
	end
	nearbyObject=nil
end

function FindMyLimoTruck()
	--print("FindMyLimoTruck")
	local nearbyObject = Find("TowTruck2WithLimo",1500)
	if next(nearbyObject) then
		--print("Some trucks found")
		for thatTruck, distance in pairs(nearbyObject) do
			--print(thatTruck.CraneUID)
			--print(thatTruck.VehicleState)
			if Get(thatTruck,"CraneUID") == this.HomeUID then
				--print("TowTruck2WithLimo found")
				newLimoTruck=thatTruck
				break
			end
		end
	end
	nearbyObject = nil
end

function FindMyPartsTruck()
	--print("FindMyPartsTruck")
	local nearbyObject = Find("TowTruck2WithCarParts",1500)
	if next(nearbyObject) then
		--print("Some trucks found")
		for thatTruck, distance in pairs(nearbyObject) do
			--print(thatTruck.CraneUID)
			--print(thatTruck.VehicleState)
			if Get(thatTruck,"CraneUID") == this.HomeUID then
				--print("TowTruck2WithCarParts found")
				newEngineTruck=thatTruck
				break
			end
		end
	end
	nearbyObject = nil
end

function SpawnBill(price,theNr)
	if timePerUpdate == nil then
		Init()
	end
	--print("spawn bill "..theNr.." with price "..price)
	if price == nil then price = math.random(1,10) end
	NewBill = Object.Spawn("Limo2Bill"..price,this.Pos.x,this.Pos.y)
	Set(NewBill,"CraneUID",this.HomeUID)
	local velX = -0.25 + math.random()
	local velY = -0.25 + math.random()
	Object.ApplyVelocity(NewBill, velX, velY)
	
	NewRepairPapersCopy = Object.Spawn("Limo2RepairPapersCopy",this.Pos.x,this.Pos.y)
	Set(NewRepairPapersCopy,"CraneUID",this.HomeUID)
	local velX = -0.25 + math.random()
	local velY = -0.25 + math.random()
	Object.ApplyVelocity(NewRepairPapersCopy, velX, velY)
	
	NewRepairPapers = Object.Spawn("Limo2RepairPapers",this.Pos.x,this.Pos.y)
	Set(NewRepairPapers,"CraneUID",this.HomeUID)
	Set(NewRepairPapers,"CarNr",theNr)
	local velX = -0.25 + math.random()
	local velY = -0.25 + math.random()
	Object.ApplyVelocity(NewRepairPapers, velX, velY)
	
	Object.CancelJob(this,"WriteBill"..theNr)
	Set(this,"WriteBill"..theNr,false)
	
	MyLimoDriver = Object.Spawn("Limo2Driver"..theNr,this.Pos.x,0)
	if MyCraneBooth.IsMilitary == "Yes" then
		MyLimoDriver.SubType = math.random(22,34)
	else
		MyLimoDriver.SubType = math.random(0,21)
	end
	MyLimoDriver.NavigateTo(this.Pos.x,this.Pos.y)
	Set(MyLimoDriver,"HomeUID",this.HomeUID)
	Set(MyLimoDriver,"CarUID",Get(this,"CarUID"..theNr))
	MyLimoDriver.Tooltip = "\nCarUID: "..MyLimoDriver.CarUID.."\nComing to fetch limo "..theNr+1
	
	--print("create job paybill "..theNr)
	Object.CreateJob(this,"PayBill"..theNr)
	Set(this,"PayBill"..theNr,true)
end

function PayBill(theNr)
	if timePerUpdate == nil then
		Init()
	end
	--print("finding driver "..theNr)
    local nearbyObject = Find("Limo2Driver"..theNr,1500)
	if next(nearbyObject) then
		for thatEntity, distance in pairs(nearbyObject) do
			if thatEntity.HomeUID == this.HomeUID then
				--print("Driver found")
				MyLimoDriver=thatEntity
				driverFound = true
				break
			end
		end
	end
	if driverFound == true then
		local nearbyObject = Find("Limo2RepairPapers",3)
		if next(nearbyObject) then
			for thatBill, distance in pairs(nearbyObject) do
				if thatBill.CraneUID == this.HomeUID and thatBill.CarNr == theNr then
					LeavingLimoDriver = Object.Spawn("Limo2DriverLeaving",MyLimoDriver.Pos.x,MyLimoDriver.Pos.y)
					LeavingLimoDriver.SubType = MyLimoDriver.SubType
					LeavingLimoDriver.Or.x = MyLimoDriver.Or.x
					LeavingLimoDriver.Or.y = MyLimoDriver.Or.y
					Set(LeavingLimoDriver,"HomeUID",this.HomeUID)
					Set(LeavingLimoDriver,"CarUID",Get(this,"CarUID"..theNr))
					Set(LeavingLimoDriver,"DeskX",this.Pos.x)
					Set(LeavingLimoDriver,"DeskY",this.Pos.y)
					LeavingLimoDriver.Tooltip = "\nCarUID: "..LeavingLimoDriver.CarUID.."\nPaid for limo "..theNr+1
					Set(this,"CarUID"..theNr,nil)
					MyLimoDriver.Delete()
					thatBill.Delete()
					if LimoReceiptNr == nil then
						local correctItem = "Limo2Receipt"
						for i = 0,1000 do
							LeavingLimoDriver.Equipment = i
							if LeavingLimoDriver.Equipment == correctItem then
								LimoReceiptNr = i
								break
							end
						end
					else
						LeavingLimoDriver.Equipment = LimoReceiptNr
					end
					Set(this,"RepairBill"..theNr,0)
					Set(this,"PayBill"..theNr,false)
					Set(this,"PaymentInProgress",false)
					Set(MyCraneBooth,"ttSlot"..theNr,"Bill paid, waiting for crane...")
					Set(MyCraneBooth,"UnloadSlot"..theNr,true)
					papersFound = true
					break
				end
			end
		end
		if papersFound == nil then
			Set(this,"WriteBill"..theNr,true)
			Set(this,"PayBill"..theNr,false)
			--print("no papers found, create job writebill "..theNr)
			Object.CreateJob(this,"WriteBill"..theNr)
		end
		nearbyObject = nil
	else
		--print("Driver not found, spawn new")
		MyLimoDriver = Object.Spawn("Limo2Driver"..theNr,this.Pos.x,0)
		if MyCraneBooth.IsMilitary == "Yes" then
			MyLimoDriver.SubType = math.random(22,34)
		else
			MyLimoDriver.SubType = math.random(0,21)
		end
		MyLimoDriver.NavigateTo(this.Pos.x,this.Pos.y)
		Set(MyLimoDriver,"HomeUID",this.HomeUID)
		Set(MyLimoDriver,"CarUID",Get(this,"CarUID"..theNr))
		MyLimoDriver.Tooltip = "\nCarUID: "..MyLimoDriver.CarUID.."\nComing to fetch limo "..theNr+1
		Set(this,"PayBill"..theNr,true)
		--print("no driver found, create job paybill "..theNr)
		Object.CreateJob(this,"PayBill"..theNr)
	end
	nearbyObject = nil
end

function Create()

	Set(this,"WriteBill0",false)
	Set(this,"WriteBill1",false)
	Set(this,"WriteBill2",false)
	Set(this,"WriteBill3",false)
	Set(this,"WriteBill4",false)
	Set(this,"WriteBill5",false)
	Set(this,"WriteBill6",false)
	Set(this,"WriteBill7",false)
	Set(this,"WriteBill8",false)
	Set(this,"WriteBill9",false)
	Set(this,"WriteBill10",false)
	Set(this,"WriteBill11",false)
	Set(this,"WriteBill12",false)
	Set(this,"WriteBill13",false)
	Set(this,"WriteBill14",false)
	Set(this,"WriteBill15",false)
	Set(this,"PayBill0",false)
	Set(this,"PayBill1",false)
	Set(this,"PayBill2",false)
	Set(this,"PayBill3",false)
	Set(this,"PayBill4",false)
	Set(this,"PayBill5",false)
	Set(this,"PayBill6",false)
	Set(this,"PayBill7",false)
	Set(this,"PayBill8",false)
	Set(this,"PayBill9",false)
	Set(this,"PayBill10",false)
	Set(this,"PayBill11",false)
	Set(this,"PayBill12",false)
	Set(this,"PayBill13",false)
	Set(this,"PayBill14",false)
	Set(this,"PayBill15",false)
	Set(this,"RepairBill0",0)
	Set(this,"RepairBill1",0)
	Set(this,"RepairBill2",0)
	Set(this,"RepairBill3",0)
	Set(this,"RepairBill4",0)
	Set(this,"RepairBill5",0)
	Set(this,"RepairBill6",0)
	Set(this,"RepairBill7",0)
	Set(this,"RepairBill8",0)
	Set(this,"RepairBill9",0)
	Set(this,"RepairBill10",0)
	Set(this,"RepairBill11",0)
	Set(this,"RepairBill12",0)
	Set(this,"RepairBill13",0)
	Set(this,"RepairBill14",0)
	Set(this,"RepairBill15",0)
end

function Init()
	Set(this,"Tooltip","CraneUID: "..this.HomeUID)
	if this.BuildTooltip == nil then this.BuildTooltip = "Init, please wait..." end
	FindMyCrane()
	timePerUpdate = 0.10 / World.TimeWarpFactor
	timePerBillUpdate = 5 / this.TimeWarp
end

function Update(timePassed)
	if timePerUpdate == nil then
		Init()
	end
	
	timeTot=timeTot+timePassed
	if timeTot>=timePerUpdate then
		timeTot=0
		BuildTooltip()
	end
	
	timeToBill = timeToBill + timePassed
	if timeToBill >= timePerBillUpdate then
		timeToBill = 0
		if this.WriteBill0 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill0") end
		if this.WriteBill1 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill1") end
		if this.WriteBill2 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill2") end
		if this.WriteBill3 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill3") end
		if this.WriteBill4 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill4") end
		if this.WriteBill5 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill5") end
		if this.WriteBill6 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill6") end
		if this.WriteBill7 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill7") end
		if this.WriteBill8 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill8") end
		if this.WriteBill9 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill9") end
		if this.WriteBill0 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill10") end
		if this.WriteBill11 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill11") end
		if this.WriteBill12 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill12") end
		if this.WriteBill13 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill13") end
		if this.WriteBill14 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill14") end
		if this.WriteBill15 == true and not this.PaymentInProgress then Set(this,"PaymentInProgress",true); Object.CreateJob(this,"WriteBill15") end
		
		if this.PayBill0 == true then Object.CreateJob(this,"PayBill0") end
		if this.PayBill1 == true then Object.CreateJob(this,"PayBill1") end
		if this.PayBill2 == true then Object.CreateJob(this,"PayBill2") end
		if this.PayBill3 == true then Object.CreateJob(this,"PayBill3") end
		if this.PayBill4 == true then Object.CreateJob(this,"PayBill4") end
		if this.PayBill5 == true then Object.CreateJob(this,"PayBill5") end
		if this.PayBill6 == true then Object.CreateJob(this,"PayBill6") end
		if this.PayBill7 == true then Object.CreateJob(this,"PayBill7") end
		if this.PayBill8 == true then Object.CreateJob(this,"PayBill8") end
		if this.PayBill9 == true then Object.CreateJob(this,"PayBill9") end
		if this.PayBill10 == true then Object.CreateJob(this,"PayBill10") end
		if this.PayBill11 == true then Object.CreateJob(this,"PayBill11") end
		if this.PayBill12 == true then Object.CreateJob(this,"PayBill12") end
		if this.PayBill13 == true then Object.CreateJob(this,"PayBill13") end
		if this.PayBill14 == true then Object.CreateJob(this,"PayBill14") end
		if this.PayBill15 == true then Object.CreateJob(this,"PayBill15") end
	end
end

function JobComplete_WriteBill0()
	SpawnBill(Get(this,"RepairBill0"),0)
end

function JobComplete_PayBill0()
	PayBill(0)
end

function JobComplete_WriteBill1()
	SpawnBill(Get(this,"RepairBill1"),1)
end

function JobComplete_PayBill1()
	PayBill(1)
end

function JobComplete_WriteBill2()
	SpawnBill(Get(this,"RepairBill2"),2)
end

function JobComplete_PayBill2()
	PayBill(2)
end

function JobComplete_WriteBill3()
	SpawnBill(Get(this,"RepairBill3"),3)
end

function JobComplete_PayBill3()
	PayBill(3)
end

function JobComplete_WriteBill4()
	SpawnBill(Get(this,"RepairBill4"),4)
end

function JobComplete_PayBill4()
	PayBill(4)
end

function JobComplete_WriteBill5()
	SpawnBill(Get(this,"RepairBill5"),5)
end

function JobComplete_PayBill5()
	PayBill(5)
end

function JobComplete_WriteBill6()
	SpawnBill(Get(this,"RepairBill6"),6)
end

function JobComplete_PayBill6()
	PayBill(6)
end

function JobComplete_WriteBill7()
	SpawnBill(Get(this,"RepairBill7"),7)
end

function JobComplete_PayBill7()
	PayBill(7)
end

function JobComplete_WriteBill8()
	SpawnBill(Get(this,"RepairBill8"),8)
end

function JobComplete_PayBill8()
	PayBill(8)
end

function JobComplete_WriteBill9()
	SpawnBill(Get(this,"RepairBill9"),9)
end

function JobComplete_PayBill9()
	PayBill(9)
end

function JobComplete_WriteBill10()
	SpawnBill(Get(this,"RepairBill10"),10)
end

function JobComplete_PayBill10()
	PayBill(10)
end

function JobComplete_WriteBill11()
	SpawnBill(Get(this,"RepairBill11"),11)
end

function JobComplete_PayBill11()
	PayBill(11)
end

function JobComplete_WriteBill12()
	SpawnBill(Get(this,"RepairBill12"),12)
end

function JobComplete_PayBill12()
	PayBill(12)
end

function JobComplete_WriteBill13()
	SpawnBill(Get(this,"RepairBill13"),13)
end

function JobComplete_PayBill13()
	PayBill(13)
end

function JobComplete_WriteBill14()
	SpawnBill(Get(this,"RepairBill14"),14)
end

function JobComplete_PayBill14()
	PayBill(14)
end

function JobComplete_WriteBill15()
	SpawnBill(Get(this,"RepairBill15"),15)
end

function JobComplete_PayBill15()
	PayBill(15)
end



function BuildTooltip()
	--print("BuildTooltip")
	local LimoWaitingOnRoad = "no"
	local LimoTruckArriving = "no"
	local PartsTruckArriving = "no"
	local GarageIsFull = "no"
	local PartsRackIsFull = ""
	local BoothJobQueue = ""
	local BoothErrorLog = ""
	local HookErrorLog = ""
	local CraneErrorLog = ""
	local TooltipSpots = ""
	local TooltipBooth = ""
	local TooltipCrane = ""
	local TooltipHook = ""
	local TooltipRack = ""
	local TooltipLimo = ""
	local TooltipLesson = ""
	local TooltipTruck = ""
	
	local tL1 = "";		if MyCraneBooth.ttLessonSlot1 ~= "(not in use)" then tL1 = "\n\n _________________________ LESSON SPOTS\n |  1 "..MyCraneBooth.ttLessonSlot1 end
	local tL2 = "";		if MyCraneBooth.ttLessonSlot2 ~= "(not in use)" then tL2 = "\n |  2 "..MyCraneBooth.ttLessonSlot2 end
	local tL3 = "";		if MyCraneBooth.ttLessonSlot3 ~= "(not in use)" then tL3 = "\n |  3 "..MyCraneBooth.ttLessonSlot3 end
	local tL4 = "";		if MyCraneBooth.ttLessonSlot4 ~= "(not in use)" then tL4 = "\n |  4 "..MyCraneBooth.ttLessonSlot4 end
	local tL5 = "";		if MyCraneBooth.ttLessonSlot5 ~= "(not in use)" then tL5 = "\n |  5 "..MyCraneBooth.ttLessonSlot5 end
	local tL6 = "";		if MyCraneBooth.ttLessonSlot6 ~= "(not in use)" then tL6 = "\n |  6 "..MyCraneBooth.ttLessonSlot6 end
	local tL7 = "";		if MyCraneBooth.ttLessonSlot7 ~= "(not in use)" then tL7 = "\n |  7 "..MyCraneBooth.ttLessonSlot7 end
	local tL8 = "";		if MyCraneBooth.ttLessonSlot8 ~= "(not in use)" then tL8 = "\n |  8 "..MyCraneBooth.ttLessonSlot8 end
	local tL9 = "";		if MyCraneBooth.ttLessonSlot9 ~= "(not in use)" then tL9 = "\n |  9 "..MyCraneBooth.ttLessonSlot9 end
	local tL10 = "";	if MyCraneBooth.ttLessonSlot10 ~= "(not in use)" then tL10 = "\n |  10 "..MyCraneBooth.ttLessonSlot10 end

	
	if MyCraneBooth.GarageSize == "Tall" or MyCraneBooth.GarageSize == "Wide" then
		local tt0 = "";		if MyCraneBooth.ttSlot0 ~= "(not in use)" then tt0 = "\n |  1 "..MyCraneBooth.ttSlot0 end
		local tt1 = "";		if MyCraneBooth.ttSlot1 ~= "(not in use)" then tt1 = "\n |  2 "..MyCraneBooth.ttSlot1 end
		local tt2 = "";		if MyCraneBooth.ttSlot2 ~= "(not in use)" then tt2 = "\n |  3 "..MyCraneBooth.ttSlot2 end
		local tt3 = "";		if MyCraneBooth.ttSlot3 ~= "(not in use)" then tt3 = "\n |  4 "..MyCraneBooth.ttSlot3 end
		local tt4 = "";		if MyCraneBooth.ttSlot4 ~= "(not in use)" then tt4 = "\n |  5 "..MyCraneBooth.ttSlot4 end
		local tt5 = "";		if MyCraneBooth.ttSlot5 ~= "(not in use)" then tt5 = "\n |  6 "..MyCraneBooth.ttSlot5 end
		local tt6 = "";		if MyCraneBooth.ttSlot6 ~= "(not in use)" then tt6 = "\n |  7 "..MyCraneBooth.ttSlot6 end
		local tt7 = "";		if MyCraneBooth.ttSlot7 ~= "(not in use)" then tt7 = "\n |  8 "..MyCraneBooth.ttSlot7 end
		local tt8 = "";		if MyCraneBooth.ttSlot8 ~= "(not in use)" then tt8 = "\n |  9 "..MyCraneBooth.ttSlot8 end
		local tt9 = "";		if MyCraneBooth.ttSlot9 ~= "(not in use)" then tt9 = "\n |  10 "..MyCraneBooth.ttSlot9 end
		local tt10 = "";	if MyCraneBooth.ttSlot10 ~= "(not in use)" then tt10 = "\n |  11 "..MyCraneBooth.ttSlot10 end
		local tt11 = "";	if MyCraneBooth.ttSlot11 ~= "(not in use)" then tt11 = "\n |  12 "..MyCraneBooth.ttSlot11 end
		local tt12 = "";	if MyCraneBooth.ttSlot12 ~= "(not in use)" then tt12 = "\n |  13 "..MyCraneBooth.ttSlot12 end
		local tt13 = "";	if MyCraneBooth.ttSlot13 ~= "(not in use)" then tt13 = "\n |  14 "..MyCraneBooth.ttSlot13 end
		local tt14 = "";	if MyCraneBooth.ttSlot14 ~= "(not in use)" then tt14 = "\n |  15 "..MyCraneBooth.ttSlot14 end
		local tt15 = "";	if MyCraneBooth.ttSlot15 ~= "(not in use)" then tt15 = "\n |  16 "..MyCraneBooth.ttSlot15 end
		
		TooltipSpots = "\n\n _________________ REPAIR / PAINT SPOTS"..tt0..""..tt1..""..tt2..""..tt3..""..tt4..""..tt5..""..tt6..""..tt7..""..tt8..""..tt9..""..tt10..""..tt11..""..tt12..""..tt13..""..tt14..""..tt15..""..tL1..""..tL2..""..tL3..""..tL4..""..tL5..""..tL6..""..tL7..""..tL8..""..tL9..""..tL10
		
	else
		local tt0 = "";		if MyCraneBooth.ttSlot0 ~= "(not in use)" then tt0 = "\n |  1 "..MyCraneBooth.ttSlot0 end
		local tt1 = "";		if MyCraneBooth.ttSlot1 ~= "(not in use)" then tt1 = "\n |  2 "..MyCraneBooth.ttSlot1 end
		local tt2 = "";		if MyCraneBooth.ttSlot2 ~= "(not in use)" then tt2 = "\n |  3 "..MyCraneBooth.ttSlot2 end
		local tt3 = "";		if MyCraneBooth.ttSlot3 ~= "(not in use)" then tt3 = "\n |  4 "..MyCraneBooth.ttSlot3 end
		local tt4 = "";		if MyCraneBooth.ttSlot4 ~= "(not in use)" then tt4 = "\n |  5 "..MyCraneBooth.ttSlot4 end
		local tt5 = "";		if MyCraneBooth.ttSlot5 ~= "(not in use)" then tt5 = "\n |  6 "..MyCraneBooth.ttSlot5 end
		local tt6 = "";		if MyCraneBooth.ttSlot6 ~= "(not in use)" then tt6 = "\n |  7 "..MyCraneBooth.ttSlot6 end
		local tt7 = "";		if MyCraneBooth.ttSlot7 ~= "(not in use)" then tt7 = "\n |  8 "..MyCraneBooth.ttSlot7 end
		
		TooltipSpots = "\n\n _________________ REPAIR / PAINT SPOTS"..tt0..""..tt1..""..tt2..""..tt3..""..tt4..""..tt5..""..tt6..""..tt7..""..tL1..""..tL2..""..tL3..""..tL4..""..tL5..""..tL6..""..tL7..""..tL8..""..tL9..""..tL10

	end
	
	LimoTruckArriving = Get(MyCraneBooth,"LimoTruckArriving")
	PartsTruckArriving = Get(MyCraneBooth,"PartsTruckArriving")
	LimoWaitingOnRoad = Get(MyCraneBooth,"LimoWaitingOnRoad")
	GarageIsFull = Get(MyCraneBooth,"GarageIsFull")
	if Exists(MyRack) then
		PartsRackIsFull = "\n |  PartsRack full: "..Get(MyCraneBooth,"PartsRackIsFull")
	end	
	if MyCraneBooth.ShowLimo2BoothInfo == "Yes" then
		for i=0,15 do
			if Get(MyCraneBooth,"UnloadSlot"..i) == true then
				BoothJobQueue = BoothJobQueue.."\n |  Place repaired limo "..(i+1).." on road"
			end
		end
		if Get(MyCraneBooth,"UnloadTruckSlot0") == true then
			BoothJobQueue = BoothJobQueue.."\n |  Fetch Limo from TowTruck spot 1"
		end
		if Get(MyCraneBooth,"UnloadTruckSlot1") == true then
			BoothJobQueue = BoothJobQueue.."\n |  Fetch Limo from TowTruck spot 2"
		end
		if Get(MyCraneBooth,"UnloadEngineSlot0") == true then
			BoothJobQueue = BoothJobQueue.."\n |  Fetch Engine from TowTruck spot 1"
		end
		if Get(MyCraneBooth,"UnloadEngineSlot1") == true then
			BoothJobQueue = BoothJobQueue.."\n |  Fetch Engine from TowTruck spot 2"
		end
		for i=0,15 do
			if Get(MyCraneBooth,"PutEngineInLessonCar"..i) == true then
				BoothJobQueue = BoothJobQueue.."\n |  Place limo "..(i+1).." engine in lesson car"
			end
		end
		for i=1,10 do
			if Get(MyCraneBooth,"BringToRack"..i) == true then
				BoothJobQueue = BoothJobQueue.."\n |  Place lesson car "..i.." engine in rack"
			end
		end
		for i=0,15 do
			if Get(MyCraneBooth,"BringEngine"..i) == true then
				BoothJobQueue = BoothJobQueue.."\n |  Fetch engine for limo "..(i+1)
			end
		end
		if BoothJobQueue == "" then BoothJobQueue = "\n |  None" end
		
		if Get(MyCraneBooth,"ErrorLog") ~= " " then
			BoothErrorLog = "\n |\n |  ERROR LOG"..MyCraneBooth.ErrorLog
		end
		
		TooltipBooth = "\n\n ____________________________ TASK QUEUE"..BoothJobQueue.."\n\n ______________________ GANTRY CONTROL\n |  Limo on road: "..LimoWaitingOnRoad.."\n |  LimoTruck on road: "..LimoTruckArriving.."\n |  PartsTruck on road: "..PartsTruckArriving.."\n |  Garage full: "..GarageIsFull..PartsRackIsFull..BoothErrorLog
	end
	
	if MyCraneBooth.ShowLimo2CraneInfo == "Yes" then
		local CraneX = string.sub(MyCrane.Pos.x,0,6)
		local CraneY = string.sub(MyCrane.Pos.y,0,6)
		local CraneToX = string.sub(MyCrane.Pos.x,0,6)
		local CraneToY = string.sub(MyCrane.Pos.y,0,6)
		local InPosition = "No"
		local CraneJob = "None"
		if MyCrane.MoveToX ~= nil then CraneToX = string.sub(MyCrane.MoveToX,0,6) end
		if MyCrane.MoveToY ~= nil then CraneToY = string.sub(MyCrane.MoveToY,0,6) end
		if MyCrane.CraneInPosition == true then InPosition = "Yes" end
		if MyCrane.GiveJob ~= nil then CraneJob = MyCrane.GiveJob end
		
		if Get(MyCrane,"ErrorLog") ~= " " then
			CraneErrorLog = "\n |\n |  ERROR LOG"..MyCrane.ErrorLog
		end
		
		TooltipCrane = "\n\n _________________________ GANTRY CRANE\n |  GoTo Y: "..CraneToY.."  Current Y: "..CraneY.."\n |  Crane In Position: "..InPosition.."\n |  Job: "..CraneJob..CraneErrorLog
	end
	
	if MyCraneBooth.ShowLimo2HookInfo == "Yes" then
	
		local HookX = string.sub(MyHook.Pos.x,0,6)
		local HookY = string.sub(MyHook.Pos.y,0,6)
		local HookToX = string.sub(MyCrane.Pos.x,0,6)
		local HookToY = string.sub(MyCrane.Pos.y,0,6)
		if MyCrane.MoveToY ~= nil then HookToY = string.sub(MyCrane.MoveToY,0,6) end
		if MyCrane.MoveToX ~= nil then HookToX = string.sub(MyCrane.MoveToX,0,6)
			elseif MyHook.Pos.x == MyHook.ParkX and MyHook.Pos.y == MyHook.ParkY then HookToX = MyHook.ParkX; HookY = HookY.."\n |  Gantry crane is parked"
		end
		local HookJob = "None"
		if MyHook.GrabLimoFromTruck == true then HookJob = "GrabLimoFromTruck"
			elseif MyHook.SpawnLimoOnFloor == true then HookJob = "SpawnLimoOnFloor"
			elseif MyHook.GrabLimoFromFloor == true then HookJob = "GrabLimoFromFloor"
			elseif MyHook.UnloadCar == true then HookJob = "UnloadCar"
			elseif MyHook.GrabEngineFromTruck == true then HookJob = "GrabEngineFromTruck"
			elseif MyHook.SpawnEngineInRack == true then HookJob = "SpawnEngineInRack"
			elseif MyHook.GrabEngineFromRack == true then HookJob = "GrabEngineFromRack"
			elseif MyHook.GrabEngineFromCar == true then HookJob = "GrabEngineFromCar"
			elseif MyHook.BringEngineToRack == true then HookJob = "BringEngineToRack"
			elseif MyHook.BringEngineToLimo == true then HookJob = "BringEngineToLimo"
			elseif MyHook.UnloadEngine == true then HookJob = "UnloadEngine"
			elseif MyHook.ParkHook == true then HookJob = "ParkHook"
		end
		if Get(MyHook,"ErrorLog") ~= " " then
			HookErrorLog = "\n |\n |  ERROR LOG"..MyHook.ErrorLog
		end
		
		TooltipHook = "\n\n __________________________ GANTRY HOOK\n |  GoTo X: "..HookToX.."  Current X: "..HookX.."\n |  GoTo Y: "..HookToY.."  Current Y: "..HookY.."\n |  Job: "..HookJob..HookErrorLog
	end
	
	if MyCraneBooth.ShowLimo2RackInfo == "Yes" and MyRack ~= nil then
		local S0 = "empty"
		local S1 = "empty"
		local S2 = "empty"
		local S3 = "empty"
		local S4 = "empty"
		local S5 = "empty"
		local S6 = "empty"
		local S7 = "empty"
		local R0 = "no"
		local R1 = "no"
		local R2 = "no"
		local R3 = "no"
		local R4 = "no"
		local R5 = "no"
		local R6 = "no"
		local R7 = "no"
		if MyRack.Slot0Reserved ~= nil then R0 = MyRack.Slot0Reserved else R0 = "no" end
		if MyRack.Slot1Reserved ~= nil then R1 = MyRack.Slot1Reserved else R1 = "no" end
		if MyRack.Slot2Reserved ~= nil then R2 = MyRack.Slot2Reserved else R2 = "no" end
		if MyRack.Slot3Reserved ~= nil then R3 = MyRack.Slot3Reserved else R3 = "no" end
		if MyRack.Slot4Reserved ~= nil then R4 = MyRack.Slot4Reserved else R4 = "no" end
		if MyRack.Slot5Reserved ~= nil then R5 = MyRack.Slot5Reserved else R5 = "no" end
		if MyRack.Slot6Reserved ~= nil then R6 = MyRack.Slot6Reserved else R6 = "no" end
		if MyRack.Slot7Reserved ~= nil then R7 = MyRack.Slot7Reserved else R7 = "no" end
		if tonumber(MyRack.Slot0.i) ~= -1 then S0 = "available -" else S0 = " - empty  -" end
		if tonumber(MyRack.Slot1.i) ~= -1 then S1 = "available -" else S1 = " - empty  -" end
		if tonumber(MyRack.Slot2.i) ~= -1 then S2 = "available -" else S2 = " - empty  -" end
		if tonumber(MyRack.Slot3.i) ~= -1 then S3 = "available -" else S3 = " - empty  -" end
		if tonumber(MyRack.Slot4.i) ~= -1 then S4 = "available -" else S4 = " - empty  -" end
		if tonumber(MyRack.Slot5.i) ~= -1 then S5 = "available -" else S5 = " - empty  -" end
		if tonumber(MyRack.Slot6.i) ~= -1 then S6 = "available -" else S6 = " - empty  -" end
		if tonumber(MyRack.Slot7.i) ~= -1 then S7 = "available -" else S7 = " - empty  -" end

		TooltipRack = "\n\n ____________________________ PARTS RACK\n |        Engine Stock    - Reserved\n |  Engine 1: "..S0.."  "..R0.."\n |  Engine 2: "..S1.."  "..R1.."\n |  Engine 3: "..S2.."  "..R2.."\n |  Engine 4: "..S3.."  "..R3.."\n |  Engine 5: "..S4.."  "..R4.."\n |  Engine 6: "..S5.."  "..R5.."\n |  Engine 7: "..S6.."  "..R6.."\n |  Engine 8: "..S7.."  "..R7

		
	end
	if MyCraneBooth.ShowLimo2TruckInfo == "Yes" then
		local truckID = ""
		local truckPos = ""
		local truckSpeed = ""
		local truckState = ""
		local readyToLeave = ""
		local truckError = ""
		local truckSlot0 = ""
		local truckSlot1 = ""
		if LimoTruckArriving == "yes" then
			if newLimoTruck == nil then FindMyLimoTruck() end
			if Exists(newLimoTruck) then
				if newLimoTruck.VehicleState ~= "Leaving" then
					truckID = "\n |  ID: "..newLimoTruck.HomeUID
					truckPos = "\n |  Current Y: "..string.sub(newLimoTruck.Pos.y,0,6)
					truckSpeed = "\n |  Speed: "..string.sub(newLimoTruck.Vel.y,0,6)
					truckState = "\n |  State: "..newLimoTruck.VehicleState
					truckSlot0 = "\n |"
					truckSlot1 = "\n |"
					if newLimoTruck.VehicleState == "Processing" then
						if newLimoTruck.Slot0IsAtX ~= nil and MyCraneBooth.UnloadTruckSlot0 == true then truckSlot0 = "\n |  Limo1 X: "..newLimoTruck.Slot0IsAtX.."  Y : "..newLimoTruck.Slot0IsAtY end
						if newLimoTruck.Slot1IsAtX ~= nil and MyCraneBooth.UnloadTruckSlot1 == true then truckSlot1 = "\n |  Limo2 X: "..newLimoTruck.Slot1IsAtX.."  Y : "..newLimoTruck.Slot1IsAtY end
					end
					if newLimoTruck.ReadyToLeave == true then readyToLeave = "\n |  Ready to leave: Yes" else readyToLeave = "\n |  Ready to leave: No" end
					if newLimoTruck.ErrorLog ~= nil and newLimoTruck.ErrorLog ~= " " then
						truckError = "\n |\n |  ERROR LOG"..newLimoTruck.ErrorLog
					end
				end
				if newLimoTruck.VehicleState == "Leaving" then newLimoTruck = nil end
			else
				newLimoTruck = nil
			end
		elseif PartsTruckArriving == "yes" then
			if newEngineTruck == nil then FindMyPartsTruck() end
			if Exists(newEngineTruck) then
				truckID = "\n |  ID: "..newEngineTruck.HomeUID
				truckPos = "\n |  Current Y: "..string.sub(newEngineTruck.Pos.y,0,6)
				truckSpeed = "\n |  Speed: "..string.sub(newEngineTruck.Vel.y,0,6)
				truckState = "\n |  State: "..newEngineTruck.VehicleState
				truckSlot0 = "\n |"
				truckSlot1 = "\n |"
				if newEngineTruck.ReadyToLeave == true then readyToLeave = "\n |  Ready to leave: Yes" else readyToLeave = "\n |  Ready to leave: No" end
				if newEngineTruck.VehicleState == "Processing" then
					if newEngineTruck.Slot0IsAtX ~= nil then truckSlot0 = "\n |  Engine1 X: "..newEngineTruck.Slot0IsAtX.."  Y : "..newEngineTruck.Slot0IsAtY end
					if newEngineTruck.Slot1IsAtX ~= nil then truckSlot1 = "\n |  Engine2 X: "..newEngineTruck.Slot1IsAtX.."  Y : "..newEngineTruck.Slot1IsAtY end
				end
				if newEngineTruck.ErrorLog ~= nil and newEngineTruck.ErrorLog ~= " " then
					truckError = "\n |\n |  ERROR LOG"..newEngineTruck.ErrorLog
				end
			else
				newEngineTruck = nil
			end
		else
			newLimoTruck = nil
			newEngineTruck = nil
		end
		
		TooltipTruck = "\n\n _____________________________ TOW TRUCK"..truckID..truckState..truckPos..truckSpeed..readyToLeave..truckSlot0..truckSlot1..truckError
	end
	
	FinalTooltip = TooltipBooth..TooltipSpots..TooltipCrane..TooltipHook..TooltipRack..TooltipTruck.."\n"
	
	MyCraneBooth.Tooltip = { "tooltip_GantryCraneBoothOverview",MyCraneBooth.HomeUID,"A",this.BuildTooltip,"B",FinalTooltip,"C" }
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
