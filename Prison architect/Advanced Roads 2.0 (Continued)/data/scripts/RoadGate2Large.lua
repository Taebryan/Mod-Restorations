
local timeTot=0
local Get=Object.GetProperty
local Set=Object.SetProperty
local Find=Object.GetNearbyObjects
local group = { "Workman","Janitor","Gardener","Sniper","Cook","CarMechanic2","CraneOperator2","TowTruck2Driver","TowTruck2DriverMilitary",
	"Limo2Driver0","Limo2Driver1","Limo2Driver2","Limo2Driver3","Limo2Driver4","Limo2Driver5","Limo2Driver6","Limo2Driver7","Limo2Driver8","Limo2Driver9","Limo2Driver10","Limo2Driver11","Limo2Driver12","Limo2Driver13","Limo2Driver14","Limo2Driver15","Limo2DriverLeaving" }
local crap = { "Garbage","Rubble","Box","Stack","UnsortedTrash" }

local GateToLeftPresent = false
local GateToRightPresent = false

function Create()
	Set(this,"PostType","Small")
	Set(this,"Direction","Left")
	Set(this,"LinkGate","no")
	Set(this,"LightsEnabled","yes")
	Set(this,"TrafficLightEnabled","yes")
	Set(this,"ScanForStaff","no")
end

function FindMyStreetManager()
    local managers = Find(this,"StreetManager2",10000)
	local managerFound = false
	if next(managers) then
		for thatManager, distance in pairs(managers) do
			MyManager=thatManager
			managerFound = true
		end
	end
	managers=nil
end

function CreateGateWalls()
	print("CreateGateWalls")
	if this.PostType ~= "Small" then
		local cellTL = World.GetCell(math.floor(this.Pos.x-3),math.floor(this.Pos.y-1));	cellTL.Mat = "RoadGate2Wall"
		local cellTR = World.GetCell(math.floor(this.Pos.x+3),math.floor(this.Pos.y-1));	cellTR.Mat = "RoadGate2Wall"
	else
		local cellTL = World.GetCell(math.floor(this.Pos.x-3),math.floor(this.Pos.y-1));	cellTL.Mat = "ConcreteTiles"
		local cellTR = World.GetCell(math.floor(this.Pos.x+3),math.floor(this.Pos.y-1));	cellTR.Mat = "ConcreteTiles"
	end
	local cellBL = World.GetCell(math.floor(this.Pos.x-3),math.floor(this.Pos.y));			cellBL.Mat = "RoadGate2Wall"
	local cellBR = World.GetCell(math.floor(this.Pos.x+3),math.floor(this.Pos.y));			cellBR.Mat = "RoadGate2Wall"
end

function CreateGate()
	print("CreateGate")
	local PosLX,PosRX = this.Pos.x-3,this.Pos.x+3
	local PosY = this.Pos.y-0.5
	
	if this.PostType == "Small" then PosY = this.Pos.y end
	if this.PostType == "Large" then PosLX,PosRX = this.Pos.x-2.75,this.Pos.x+2.75 end
	
	CreateGateWalls()
	CheckForAdjacentGate()
	
	PostLeft = Object.Spawn("RoadGate2PostLeft"..this.PostType,PosLX,PosY)	
	PostRight = Object.Spawn("RoadGate2PostRight"..this.PostType,PosRX,PosY)
	Set(PostLeft,"GateUID",this.GateUID)
	Set(PostRight,"GateUID",this.GateUID)
	PostLeft.SubType,PostRight.SubType = 1,1
	
	
	if this.TrafficLightEnabled =="yes" then	
		local MyTrafficLightL = Object.Spawn("RoadGate2TrafficLightLarge",this.Pos.x,this.Pos.y)
		MyTrafficLightL.SubType = 3
		Set(MyTrafficLightL,"LeftSide",true)
		Set(MyTrafficLightL,"LightType",3)
		Set(MyTrafficLightL,"GateUID",this.GateUID)
		PostLeft.Slot0.i = MyTrafficLightL.Id.i
		PostLeft.Slot0.u = MyTrafficLightL.Id.u
		MyTrafficLightL.CarrierId.i = PostLeft.Id.i
		MyTrafficLightL.CarrierId.u = PostLeft.Id.u
		MyTrafficLightL.Loaded = true
		
		local MyTrafficLightR = Object.Spawn("RoadGate2TrafficLightLarge",this.Pos.x,this.Pos.y)
		MyTrafficLightR.SubType = 3
		Set(MyTrafficLightR,"RightSide",true)
		Set(MyTrafficLightR,"LightType",3)
		Set(MyTrafficLightR,"GateUID",this.GateUID)
		PostRight.Slot0.i = MyTrafficLightR.Id.i
		PostRight.Slot0.u = MyTrafficLightR.Id.u
		MyTrafficLightR.CarrierId.i = PostRight.Id.i
		MyTrafficLightR.CarrierId.u = PostRight.Id.u
		MyTrafficLightR.Loaded = true
	end
	
	if GateToLeftPresent == true then
		PostLeft.SubType = 2
		if this.PostType ~= "Small" then PostLeft.Pos.x = this.Pos.x-2.5 end
	end
	if GateToRightPresent == true then
		PostRight.SubType = 2
		if this.PostType ~= "Small" then PostRight.Pos.x = this.Pos.x+2.5 end
	end
	
	if this.LightsEnabled == "yes" then
		MyLightLeft=Object.Spawn("WallLight",this.Pos.x,this.Pos.y)
		Set(MyLightLeft,"GateUID",this.GateUID)
		PostLeft.Slot1.i = MyLightLeft.Id.i
		PostLeft.Slot1.u = MyLightLeft.Id.u
		MyLightLeft.CarrierId.i = PostLeft.Id.i
		MyLightLeft.CarrierId.u = PostLeft.Id.u
		MyLightLeft.Loaded = true
		MyLightRight=Object.Spawn("WallLight",this.Pos.x,this.Pos.y)
		Set(MyLightRight,"GateUID",this.GateUID)
		PostRight.Slot1.i = MyLightRight.Id.i
		PostRight.Slot1.u = MyLightRight.Id.u
		MyLightRight.CarrierId.i = PostRight.Id.i
		MyLightRight.CarrierId.u = PostRight.Id.u
		MyLightRight.Loaded = true
	end
	AddButtons()
end

function ResetGateClicked()
    local nearbyObject = Find(this,"RoadMarker2",10000)
	if next(nearbyObject) then
		for name,dist in pairs(nearbyObject) do
			if Get(this,"MarkerUIDL") == Get(name,"MarkerUID") then
				print("marker L found")
				MyMarkerLeft=name
				local i = Get(this,"GatePositionL")
				print("reset gate L"..i)
				Set(MyMarkerLeft,"RequestFromL"..i,"none")
				Set(MyMarkerLeft,"AuthorizedL"..i,"no")
				Set(MyMarkerLeft,"CloseGateL"..i,"no")
				Set(this,"RequestFromL","none")
				Set(this,"AuthorizedL","no")
				Set(this,"CloseGateL","no")
				Set(this,"Mode",0)
			end
			if Get(this,"MarkerUIDR") == Get(name,"MarkerUID") then
				print("marker R found")
				MyMarkerRight=name
				local i = Get(this,"GatePositionR")
				print("reset gate R"..i)
				Set(MyMarkerRight,"RequestFromR"..i,"none")
				Set(MyMarkerRight,"AuthorizedR"..i,"no")
				Set(MyMarkerRight,"CloseGateR"..i,"no")
				Set(this,"RequestFromR","none")
				Set(this,"AuthorizedR","no")
				Set(this,"CloseGateR","no")
				Set(this,"Mode",0)
			end
		end
	end
	nearbyObject = nil
end

function CheckForAdjacentGate()
	print("CheckForAdjacentGate")
	AdjacentGate = nil
	GateToLeftPresent = false
	GateToRightPresent = false
	local nearbyObject = Find("RoadGate2Small",7)
	if next(nearbyObject) then
		for thatGate,dist in pairs(nearbyObject) do
			if thatGate.Pos.y == this.Pos.y and not thatGate.Deleted then
				if thatGate.Pos.x < this.Pos.x then
					GateToLeftPresent = true
					AdjacentGate = thatGate
					AdjacentGate.Open = 0
					AdjacentGate.Or.y = 1
					AdjacentGate.OpenDir.x = -2
					Set(AdjacentGate,"Direction","Left")
					if not this.Refresh then
						Set(AdjacentGate,"PostType",this.PostType)
						Set(AdjacentGate,"LightsEnabled",this.LightsEnabled)
						Set(AdjacentGate,"TrafficLightEnabled",this.TrafficLightEnabled)
						Set(AdjacentGate,"Refresh",true)
					end
					this.Open = 0
					this.Or.y = -1
					this.OpenDir.x = 5
					Set(this,"Direction","Right")
					print("Found RoadGate2Small to left side at distance "..dist)
				end
				
				if thatGate.Pos.x > this.Pos.x then
					GateToRightPresent = true
					AdjacentGate = thatGate
					AdjacentGate.Open = 0
					AdjacentGate.Or.y = -1
					AdjacentGate.OpenDir.x = 2
					Set(AdjacentGate,"Direction","Right")
					if not this.Refresh then
						Set(AdjacentGate,"PostType",this.PostType)
						Set(AdjacentGate,"LightsEnabled",this.LightsEnabled)
						Set(AdjacentGate,"TrafficLightEnabled",this.TrafficLightEnabled)
						Set(AdjacentGate,"Refresh",true)
					end
					this.Open = 0
					this.Or.y = 1
					this.OpenDir.x = -5
					Set(this,"Direction","Left")
					print("Found RoadGate2Small to right side at distance "..dist)
				end
			end
		end
	end
	nearbyObject = nil
end

function CleanUpGate()
	print("CleanUpGate")
	RemoveButtons()
	local GroupOfOldObjects = { "RoadGate2PostLeftSmall","RoadGate2PostRightSmall",
								"RoadGate2PostLeftLarge","RoadGate2PostRightLarge",
								"RoadGate2PostLeftPoW","RoadGate2PostRightPoW",
								"RoadGate2TrafficLightLarge","WallLight" }
	for _, typ in pairs(GroupOfOldObjects) do
		nearbyObject = Find(typ,6)
		for thatObject, _ in pairs(nearbyObject) do
			if thatObject.GateUID == this.GateUID then
			print("Deleting "..thatObject.Type)
				thatObject.Delete()
			end
		end
		nearbyObject = nil
	end
end

function togglePostClicked()
	CleanUpGate()
	if Get(this,"PostType") == "Small" then		 Set(this,"PostType","Large")
	elseif Get(this,"PostType") == "Large" then	 Set(this,"PostType","PoW")
	elseif Get(this,"PostType") == "PoW" then	 Set(this,"PostType","Small")
	end
	CreateGate()
	this.SetInterfaceCaption("togglePost", "tooltip_RoadGate2_Button_PostType",this.PostType,"X")
end

function toggleLightsClicked()
	CleanUpGate()
	if Get(this,"LightsEnabled") == "yes" then Set(this,"LightsEnabled","no") else Set(this,"LightsEnabled","yes") end
	CreateGate()
	this.SetInterfaceCaption("toggleLights", "tooltip_RoadGate2_Button_Lights",this.LightsEnabled,"X")
end

function toggleTrafficLightClicked()
	CleanUpGate()
	if Get(this,"TrafficLightEnabled") == "yes" then Set(this,"TrafficLightEnabled","no") else Set(this,"TrafficLightEnabled","yes") end
	CreateGate()
	this.SetInterfaceCaption("toggleTrafficLight", "tooltip_RoadGate2_Button_TrafficLight",this.TrafficLightEnabled,"X")
end

function toggleStaffAuthorizedClicked()
	if Get(this,"ScanForStaff") == "yes" then
		Set(this,"ScanForStaff","no")
	else
		Set(this,"ScanForStaff","yes")
	end
	this.SetInterfaceCaption("toggleStaffAuthorized", "tooltip_RoadGate2_Button_StaffScan",this.ScanForStaff,"X")
end

function ScanForStaff()
	print("ScanForStaff")
	-- if (this.Or.x == 0 and this.Or.y == -1) or (this.Or.x == 0 and this.Or.y == 1) then
		for _, typ in pairs(group) do
			local people = Find(this,typ,4)
			for entity, _ in pairs(people) do
				if next(entity) then
					if entity.Pos.y >= this.Pos.y-0.6 and entity.Pos.y <= this.Pos.y+0.6 and entity.Pos.x >= this.Pos.x-2.5 and entity.Pos.x <= this.Pos.x+2.5 then
						print("Found "..entity.Type)
						print("This X: "..this.Pos.x.." Entity X: "..entity.Pos.x.." Dest.x: "..entity.Dest.x)
						print("This Y: "..this.Pos.y.." Entity Y: "..entity.Pos.y.." Dest.y: "..entity.Dest.y)
						print("Gate Mode: "..this.Mode)
						if this.Mode == "LockedShut" then
							if entity.Pos.y <= this.Pos.y then
								Object.ApplyVelocity(entity,math.random(),-5,false) 	-- Push entity away from the gate with a random X position,
								print("Moving stuck "..entity.Type.." to northside")	-- so it goes 'somewhere' to the north instead of straight north
							elseif entity.Pos.y >= this.Pos.y then						-- which might push him against a truck and still not move.
								Object.ApplyVelocity(entity,math.random(),5,false)		-- Might need a couple of retry, but eventually the angle
								print("Moving stuck "..entity.Type.." to southside")	-- in which the entity is pushed will be fine
							end
						else
							if entity.Pos.x < this.Pos.x then
								this.Or.y = 1
								this.Open = 0
								this.OpenDir.x = 3	-- open gate 3 tiles to the right
							else
								this.Or.y = -1
								this.Open = 0
								this.OpenDir.x = -3	-- open gate 3 tiles to the left
							end
							print("Open gate for "..entity.Type)
							this.Open=0.1
						end
						break
					end
				end
			end
			people=nil
		end
	-- end
end

function ScanForCrapClicked()
	for _, typ in pairs(crap) do
		local thecrap = Find(this,typ,4)
		for thatcrap, _ in pairs(thecrap) do
			if next(thatcrap) then
				if thatcrap.CarrierId.i == nil or thatcrap.Loaded == false then
					thatcrap.Delete()
				end
			end
		end
	end
	ScanForStaff()
	thecrap=nil
end

function toggleLinkGateClicked()
	if Get(this,"LinkGate")=="no" then Set(this,"LinkGate","AA")
	elseif Get(this,"LinkGate")=="AA" then Set(this,"LinkGate","BB")
	elseif Get(this,"LinkGate")=="BB" then Set(this,"LinkGate","CC")
	elseif Get(this,"LinkGate")=="CC" then Set(this,"LinkGate","DD")
	elseif Get(this,"LinkGate")=="DD" then Set(this,"LinkGate","EE")
	elseif Get(this,"LinkGate")=="EE" then Set(this,"LinkGate","FF")
	elseif Get(this,"LinkGate")=="FF" then Set(this,"LinkGate","GG")
	elseif Get(this,"LinkGate")=="GG" then Set(this,"LinkGate","HH")
	elseif Get(this,"LinkGate")=="HH" then Set(this,"LinkGate","II")
	elseif Get(this,"LinkGate")=="II" then Set(this,"LinkGate","JJ")
	else Set(this,"LinkGate","no") end
	this.SetInterfaceCaption("toggleLinkGate","tooltip_RoadGate2_Button_LinkGate",this.LinkGate,"X")
	if Exists(MyManager) then
		Set(MyManager,"UpdateLinkedGates",true)
	else
		FindMyStreetManager()
		if Exists(MyManager) then
			Set(MyManager,"UpdateLinkedGates",true)
		end
	end
end

function RemoveButtons()
	Interface.RemoveComponent(this,"toggleLinkGate")
	Interface.RemoveComponent(this,"CaptionSeparator1")
	Interface.RemoveComponent(this,"togglePost")
	Interface.RemoveComponent(this,"toggleLights")
	Interface.RemoveComponent(this,"toggleTrafficLight")
	Interface.RemoveComponent(this,"toggleStaffAuthorized")
	Interface.RemoveComponent(this,"ScanForCrap")
end

function AddButtons()
	-- if not Get(this,"SmallPost") then
		Interface.AddComponent(this,"toggleLinkGate","Button","tooltip_RoadGate2_Button_LinkGate",this.LinkGate,"X")
		Interface.AddComponent(this,"CaptionSeparator1", "Caption", "tooltip_RoadGate2_Separatorline")
		Interface.AddComponent(this,"togglePost", "Button", "tooltip_RoadGate2_Button_PostType",this.PostType,"X")
		Interface.AddComponent(this,"toggleLights", "Button", "tooltip_RoadGate2_Button_Lights",this.LightsEnabled,"X")
		Interface.AddComponent(this,"toggleTrafficLight", "Button", "tooltip_RoadGate2_Button_TrafficLight",this.TrafficLightEnabled,"X")
		Interface.AddComponent(this,"toggleStaffAuthorized", "Button", "tooltip_RoadGate2_Button_StaffScan",this.ScanForStaff,"X")
		Interface.AddComponent(this,"ScanForCrap", "Button", "tooltip_RoadGate2_Button_RemoveCrap")
	-- end
end

function Update(timePassed)
	if timePerUpdate == nil then
		Interface.AddComponent(this,"RemoveLeftOvers", "Button", "Remove Gate")
		Interface.AddComponent(this,"ResetGate", "Button", "Reset Gate")
		Interface.AddComponent(this,"CaptionSeparator0", "Caption", "tooltip_RoadGate2_Separatorline")
		if not Get(this,"GateCreated") then	-- no posts spawned yet
			if this.Pos.y < 2.5 then this.Pos.y = 2.5 end
			Set(this,"GateUID",me["id-uniqueId"])
			CreateGate()
			FindMyStreetManager()
			if Exists(MyManager) then
				Set(MyManager,"AddNewGates",true)
			end
			Set(this,"GateCreated",true)
		else
			AddButtons()
		end
		ScanForCrapClicked()
		timePerUpdate = 3 / World.TimeWarpFactor
	end
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		if this.ScanForStaff == "yes" and (this.Mode == "LockedShut" or this.Mode == "Normal") then
			--if not this.PeopleCrossingStreet then
				ScanForStaff()
			--end
		end
	end
	if this.Refresh == true then
		CleanUpGate()
		CreateGate()
		this.Refresh = nil
	end
end

function RemoveLeftOversClicked()
	Set(this,"Deleted",true)
	local GroupOfOldObjects = { "RoadGate2PostLeftSmall","RoadGate2PostRightSmall",
								"RoadGate2PostLeftLarge","RoadGate2PostRightLarge",
								"RoadGate2PostLeftPoW","RoadGate2PostRightPoW",
	"SmallRoadPole","RoadPoleEnd","RoadPoleStart","RoadGate2TrafficLightLarge","WallLight" }
	for _, typ in pairs(GroupOfOldObjects) do
		nearbyObject = Find(typ,6)
		for thatObject, _ in pairs(nearbyObject) do
			if (this.GateUID ~= nil and thatObject.GateUID == this.GateUID) then
				thatObject.Delete()
			end
		end
		nearbyObject = nil
	end
	local cellTL = World.GetCell(math.floor(this.Pos.x-3),math.floor(this.Pos.y-1));	cellTL.Mat = "ConcreteTiles"
	local cellTR = World.GetCell(math.floor(this.Pos.x+3),math.floor(this.Pos.y-1));	cellTR.Mat = "ConcreteTiles"
	local cellBL = World.GetCell(math.floor(this.Pos.x-3),math.floor(this.Pos.y));		cellBL.Mat = "ConcreteTiles"
	local cellBR = World.GetCell(math.floor(this.Pos.x+3),math.floor(this.Pos.y));		cellBR.Mat = "ConcreteTiles"
	
	
	local nearbyObject = Find("RoadGate2Small",7)
	local foundGate = false
	if next(nearbyObject) then
		for thatGate,dist in pairs(nearbyObject) do
			if thatGate.Pos.y == this.Pos.y and not thatGate.Deleted then
				Set(thatGate,"Refresh",true)
			end
		end
	end
	
	local nearbyObject = Find("StreetManager2",10000)
	if next(nearbyObject) then
		for thatManager,dist in pairs(nearbyObject) do
			Set(thatManager,"AddNewGates",true)
			--print("Update StreetManager")
		end
	end
	this.Delete()
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
