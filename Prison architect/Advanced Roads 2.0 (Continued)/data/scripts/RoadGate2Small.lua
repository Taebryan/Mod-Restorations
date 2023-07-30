
local timeTot=0
local Get=Object.GetProperty
local Set=Object.SetProperty
local Find=Object.GetNearbyObjects
local group = { "Workman","Janitor","Gardener","Sniper","Cook","CarMechanic2","CraneOperator2","TowTruck2Driver","TowTruck2DriverMilitary",
	"Limo2Driver0","Limo2Driver1","Limo2Driver2","Limo2Driver3","Limo2Driver4","Limo2Driver5","Limo2Driver6","Limo2Driver7","Limo2Driver8","Limo2Driver9","Limo2Driver10","Limo2Driver11","Limo2Driver12","Limo2Driver13","Limo2Driver14","Limo2Driver15","Limo2DriverLeaving" }
local crap = { "Garbage","Rubble","Box","Stack","UnsortedTrash" }

local GateTypes = { [0] = "Default", [1] = "MinSec",[2] = "Normal",[3] = "MaxSec", [4] = "Protected", [5] = "SuperMax", [6] = "DeathRow", [7] = "Insane", [8] = "Shared", [9] = "PoW" }

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
		local cellTL = World.GetCell(math.floor(this.Pos.x-2),math.floor(this.Pos.y-1));	cellTL.Mat = "RoadGate2Wall"
		local cellTR = World.GetCell(math.floor(this.Pos.x+1),math.floor(this.Pos.y-1));	cellTR.Mat = "RoadGate2Wall"
	else
		local cellTL = World.GetCell(math.floor(this.Pos.x-2),math.floor(this.Pos.y-1));	cellTL.Mat = "ConcreteTiles"
		local cellTR = World.GetCell(math.floor(this.Pos.x+1),math.floor(this.Pos.y-1));	cellTR.Mat = "ConcreteTiles"
	end
	local cellBL = World.GetCell(math.floor(this.Pos.x-2),math.floor(this.Pos.y));			cellBL.Mat = "RoadGate2Wall"
	local cellBR = World.GetCell(math.floor(this.Pos.x+1),math.floor(this.Pos.y));			cellBR.Mat = "RoadGate2Wall"
	
	-- local cellGL = World.GetCell(math.floor(this.Pos.x-1),math.floor(this.Pos.y));			cellGL.Mat = "yellowcrosslinesL"
	-- local cellGR = World.GetCell(math.floor(this.Pos.x),math.floor(this.Pos.y));			cellGR.Mat = "yellowcrosslinesR"
end

function CreateGate()
	print("CreateGate")
	local PosLX,PosRX = this.Pos.x-1.5,this.Pos.x+1.5
	local PosY = this.Pos.y-0.5
	
	if this.PostType == "Small" then PosY = this.Pos.y end
	if this.PostType == "Large" then PosLX,PosRX = this.Pos.x-1.25,this.Pos.x+1.25 end
	
	CreateGateWalls()
	CheckForAdjacentGate()
	
	PostLeft = Object.Spawn("RoadGate2PostLeft"..this.PostType,PosLX,PosY)	
	PostRight = Object.Spawn("RoadGate2PostRight"..this.PostType,PosRX,PosY)
	Set(PostLeft,"GateUID",this.GateUID)
	Set(PostRight,"GateUID",this.GateUID)
	if this.HomeUID ~= nil then
		Set(PostLeft,"HomeUID",this.HomeUID)
		Set(PostRight,"HomeUID",this.HomeUID)
	end
		
	if this.TrafficLightEnabled == "yes" then
		local TrafficPost = PostRight
		if this.Direction == "Right" then TrafficPost = PostLeft end
	
		local MyTrafficLight = Object.Spawn("RoadGate2TrafficLightSmall",this.Pos.x,this.Pos.y)
		MyTrafficLight.SubType = 3
		Set(MyTrafficLight,"LightType",3)
		Set(MyTrafficLight,"GateUID",this.GateUID)
		if this.HomeUID ~= nil then
			Set(MyTrafficLight,"HomeUID",this.HomeUID)
		end
		TrafficPost.Slot0.i = MyTrafficLight.Id.i
		TrafficPost.Slot0.u = MyTrafficLight.Id.u
		MyTrafficLight.CarrierId.i = TrafficPost.Id.i
		MyTrafficLight.CarrierId.u = TrafficPost.Id.u
		MyTrafficLight.Loaded = true
		TrafficPost.SubType = 1
	end
	
	if GateToLeftPresent == true then
		PostLeft.SubType = 2
		if this.PostType ~= "Small" then PostLeft.Pos.x = this.Pos.x-1 end
	end
	if GateToRightPresent == true then
		PostRight.SubType = 2
		if this.PostType ~= "Small" then PostRight.Pos.x = this.Pos.x+1 end
	end
	
	if this.LightsEnabled == "yes" then
		MyLightLeft=Object.Spawn("WallLight",this.Pos.x,this.Pos.y)
		Set(MyLightLeft,"GateUID",this.GateUID)
		if this.HomeUID ~= nil then
			Set(MyLightLeft,"HomeUID",this.HomeUID)
		end
		PostLeft.Slot1.i = MyLightLeft.Id.i
		PostLeft.Slot1.u = MyLightLeft.Id.u
		MyLightLeft.CarrierId.i = PostLeft.Id.i
		MyLightLeft.CarrierId.u = PostLeft.Id.u
		MyLightLeft.Loaded = true
		MyLightRight=Object.Spawn("WallLight",this.Pos.x,this.Pos.y)
		Set(MyLightRight,"GateUID",this.GateUID)
		if this.HomeUID ~= nil then
			Set(MyLightRight,"HomeUID",this.HomeUID)
		end
		PostRight.Slot1.i = MyLightRight.Id.i
		PostRight.Slot1.u = MyLightRight.Id.u
		MyLightRight.CarrierId.i = PostRight.Id.i
		MyLightRight.CarrierId.u = PostRight.Id.u
		MyLightRight.Loaded = true
	end
	AddButtons()
end

function FindMyTrafficLight()
	print("FindMyTrafficLight")
	MyTrafficLight = nil
	MySideLaneTrafficLight = nil
	local nearbyObject = Find(this,"RoadGate2TrafficLightSmall",2)
	if next(nearbyObject) then
		for thatLight, distance in pairs(nearbyObject) do
			if this.GateUID ~= nil and thatLight.GateUID==this.GateUID then
				MyTrafficLight=thatLight
				--print("MyTrafficLight.LightType "..MyTrafficLight.LightType)
				if MyTrafficLight.LightType == 2 then MyTrafficLight.LightType,MyTrafficLight.SubType = 3,3 end
				--print("Found TrafficLight with GateUID "..thatLight.GateUID.." at dist "..distance)
			elseif this.HomeUID ~= nil and thatLight.HomeUID==this.HomeUID then
				if thatLight.SideLaneLight == true then
					MySideLaneTrafficLight=thatLight
					--print("Found SideLaneLight with HomeUID "..thatLight.HomeUID.." at dist "..distance)
				end
			end
		end
	end
	nearbyObject = nil
end

function ResetGateClicked()
    local nearbyObject = Find(this,"RoadMarker2",10000)
	if next(nearbyObject) then
		for thatMarker,dist in pairs(nearbyObject) do
			if Get(this,"MarkerUID") == Get(thatMarker,"MarkerUID") then
				--print("marker found")
				MyMarker=thatMarker
				local i = Get(this,"GatePosition")
				--print("reset gate "..i)
				Set(MyMarker,"RequestFrom"..i,"none")
				Set(MyMarker,"Authorized"..i,"no")
				Set(MyMarker,"CloseGate"..i,"no")
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
	local nearbyObject = Find("RoadGate2Small",3)
	if next(nearbyObject) then
		for thatGate,dist in pairs(nearbyObject) do
			if thatGate.Id.i ~= this.Id.i and thatGate.Pos.y == this.Pos.y and not thatGate.Deleted then
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
					this.OpenDir.x = 2
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
					this.OpenDir.x = -2
					Set(this,"Direction","Left")
					print("Found RoadGate2Small to right side at distance "..dist)
				end
			end
		end
	end
	nearbyObject = nil
	
	local nearbyObject = Find("RoadGate2Large",7)
	if next(nearbyObject) then
		for thatGate,dist in pairs(nearbyObject) do
			if thatGate.Pos.y == this.Pos.y and not thatGate.Deleted then
				if thatGate.Pos.x == this.Pos.x-4.5 then
					GateToLeftPresent = true
					AdjacentGate = thatGate
					AdjacentGate.Open = 0
					AdjacentGate.Or.y = 1
					AdjacentGate.OpenDir.x = -5
					Set(AdjacentGate,"Direction","Left")
					if not this.Refresh then
						Set(AdjacentGate,"PostType",this.PostType)
						Set(AdjacentGate,"LightsEnabled",this.LightsEnabled)
						Set(AdjacentGate,"TrafficLightEnabled",this.TrafficLightEnabled)
						Set(AdjacentGate,"Refresh",true)
					end					
					this.Open = 0
					this.Or.y = -1
					this.OpenDir.x = 2
					Set(this,"Direction","Right")
					print("Found RoadGate2Large to left side at distance "..dist)
				end
				if thatGate.Pos.x == this.Pos.x+4.5 then
					GateToRightPresent = true
					AdjacentGate = thatGate
					AdjacentGate.Open = 0
					AdjacentGate.Or.y = -1
					AdjacentGate.OpenDir.x = 5
					Set(AdjacentGate,"Direction","Right")
					if not this.Refresh then
						Set(AdjacentGate,"PostType",this.PostType)
						Set(AdjacentGate,"LightsEnabled",this.LightsEnabled)
						Set(AdjacentGate,"TrafficLightEnabled",this.TrafficLightEnabled)
						Set(AdjacentGate,"Refresh",true)
					end
					this.Open = 0
					this.Or.y = 1
					this.OpenDir.x = -2
					Set(this,"Direction","Left")
					print("Found RoadGate2Large to right side at distance "..dist)
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
								"RoadGate2TrafficLightSmall","WallLight" }
	for _, typ in pairs(GroupOfOldObjects) do
		nearbyObject = Find(typ,3)
		for thatObject, _ in pairs(nearbyObject) do
			if (this.GateUID ~= nil and thatObject.GateUID == this.GateUID) or (this.HomeUID ~= nil and thatObject.HomeUID == this.HomeUID) then
				thatObject.Delete()
			end
		end
		nearbyObject = nil
	end
end

function toggleSubTypeClicked()
	this.SubType = this.SubType + 1
	if this.SubType > 9 then this.SubType = 0 end
	this.SetInterfaceCaption("toggleSubType", "tooltip_RoadGate2_Button_SubType",GateTypes[this.SubType],"X")
end

function toggleDirectionClicked()
	CleanUpGate()
	if Get(this,"Direction") == "Left" then
		this.Open = 0
		this.Or.y = -1
		this.OpenDir.x = 2
		Set(this,"Direction","Right")
	else
		this.Open = 0
		this.Or.y = 1
		this.OpenDir.x = -2
		Set(this,"Direction","Left")
	end
	CreateGate()
	this.SetInterfaceCaption("toggleDirection", "tooltip_RoadGate2_Button_Direction",this.Direction,"X")
end

function togglePostClicked()
	CleanUpGate()
	if Get(this,"PostType") == "Small" then		 Set(this,"PostType","Large")
	elseif Get(this,"PostType") == "Large" then	 Set(this,"PostType","PoW"); this.SubType = 9
	elseif Get(this,"PostType") == "PoW" then	 Set(this,"PostType","Small"); this.SubType = 0
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
	if Get(this,"ScanForStaff") == "yes" then Set(this,"ScanForStaff","no") else Set(this,"ScanForStaff","yes") end
	this.SetInterfaceCaption("toggleStaffAuthorized", "tooltip_RoadGate2_Button_StaffScan",this.ScanForStaff,"X")
end

function ScanForStaff()
	print("ScanForStaff")
	--if (this.Or.x == 0 and this.Or.y == -1) or (this.Or.x == 0 and this.Or.y == 1) then
		for _, typ in pairs(group) do
			local people = Find(this,typ,3)
			for entity, _ in pairs(people) do
				if next(entity) then
					if entity.Pos.y >= this.Pos.y-0.6 and entity.Pos.y <= this.Pos.y+0.6 and entity.Pos.x >= this.Pos.x-1.5 and entity.Pos.x <= this.Pos.x+1.5 then
						print("Found "..entity.Type)
						print("This X: "..this.Pos.x.." Entity X: "..entity.Pos.x.." Dest.x: "..entity.Dest.x)
						print("This Y: "..this.Pos.y.." Entity Y: "..entity.Pos.y.." Dest.y: "..entity.Dest.y)
						print("Gate Mode: "..this.Mode)
						if this.Mode == "LockedShut" then
							if entity.Pos.y <= this.Pos.y then
								Object.ApplyVelocity(entity,math.random(),-5,false) -- push entity away from the gate
								print("Moving stuck "..entity.Type.." to northside")
							elseif entity.Pos.y >= this.Pos.y then
								Object.ApplyVelocity(entity,math.random(),5,false)
								print("Moving stuck "..entity.Type.." to southside")
							end
						else
							print("Open gate for "..entity.Type)
							this.Open=0.1
						end
						break
					end
				end
			end
			people=nil
		end
--	end
end

function ScanForCrapClicked()
	for _, typ in pairs(crap) do
		local thecrap = Find(this,typ,1)
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
	Interface.RemoveComponent(this,"toggleSubType")
	Interface.RemoveComponent(this,"toggleDirection")
	Interface.RemoveComponent(this,"togglePost")
	Interface.RemoveComponent(this,"toggleLights")
	Interface.RemoveComponent(this,"toggleTrafficLight")
	Interface.RemoveComponent(this,"toggleStaffAuthorized")
	Interface.RemoveComponent(this,"ScanForCrap")
end

function AddButtons()
	if not Get(this,"SmallPost") then
		Interface.AddComponent(this,"toggleLinkGate","Button","tooltip_RoadGate2_Button_LinkGate",this.LinkGate,"X")
		Interface.AddComponent(this,"CaptionSeparator1", "Caption", "tooltip_RoadGate2_Separatorline")
		if GateToLeftPresent == false and GateToRightPresent == false then
			Interface.AddComponent(this,"toggleDirection", "Button", "tooltip_RoadGate2_Button_Direction",this.Direction,"X")
		end
		Interface.AddComponent(this,"toggleSubType", "Button", "tooltip_RoadGate2_Button_SubType",GateTypes[this.SubType],"X")
		Interface.AddComponent(this,"togglePost", "Button", "tooltip_RoadGate2_Button_PostType",this.PostType,"X")
		Interface.AddComponent(this,"toggleLights", "Button", "tooltip_RoadGate2_Button_Lights",this.LightsEnabled,"X")
		Interface.AddComponent(this,"toggleTrafficLight", "Button", "tooltip_RoadGate2_Button_TrafficLight",this.TrafficLightEnabled,"X")
		Interface.AddComponent(this,"toggleStaffAuthorized", "Button", "tooltip_RoadGate2_Button_StaffScan",this.ScanForStaff,"X")
		Interface.AddComponent(this,"ScanForCrap", "Button", "tooltip_RoadGate2_Button_RemoveCrap")
	end
end

function Update(timePassed)
	if timePerUpdate == nil then
		Interface.AddComponent(this,"RemoveLeftOvers", "Button", "Remove Gate")
		Interface.AddComponent(this,"ResetGate", "Button", "Reset Gate")
		Interface.AddComponent(this,"CaptionSeparator0", "Caption", "tooltip_RoadGate2_Separatorline")
		if not Get(this,"GateCreated") then	-- no posts spawned yet
			if not Get(this,"SmallPost") then	-- this is not a gate inside the limo garage
				if this.Pos.y < 2.5 then this.Pos.y = 2.5 end
				Set(this,"GateUID",me["id-uniqueId"])
				CreateGate()
				FindMyStreetManager()
				if Exists(MyManager) then
					Set(MyManager,"AddNewGates",true)
				end
			else
				this.SubType = 10
			end
			Set(this,"GateCreated",true)
		else
			AddButtons()
		end
		if not Get(this,"SmallPost") then
			--FindMyTrafficLight()
		else
			FindMyTrafficLight()
			if Exists(MySideLaneTrafficLight) then MySideLaneTrafficLight.Tooltip = "tooltip_RoadGate2_SidelaneLight" end
		end
		ScanForCrapClicked()
		timePerUpdate = 1 / World.TimeWarpFactor
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
	"SmallRoadPole","RoadPoleEnd","RoadPoleStart","RoadGate2TrafficLightSmall","WallLight" }
	for _, typ in pairs(GroupOfOldObjects) do
		nearbyObject = Find(typ,3)
		for thatObject, _ in pairs(nearbyObject) do
			if (this.GateUID ~= nil and thatObject.GateUID == this.GateUID) or (this.HomeUID ~= nil and thatObject.HomeUID == this.HomeUID) then
				thatObject.Delete()
			end
		end
		nearbyObject = nil
	end
	local cellTL = World.GetCell(math.floor(this.Pos.x-2),math.floor(this.Pos.y-1));	cellTL.Mat = "ConcreteTiles"
	local cellTR = World.GetCell(math.floor(this.Pos.x+1),math.floor(this.Pos.y-1));	cellTR.Mat = "ConcreteTiles"
	local cellBL = World.GetCell(math.floor(this.Pos.x-2),math.floor(this.Pos.y));		cellBL.Mat = "ConcreteTiles"
	local cellBR = World.GetCell(math.floor(this.Pos.x+1),math.floor(this.Pos.y));		cellBR.Mat = "ConcreteTiles"
	
	local nearbyObject = Find("RoadGate2Small",3)
	if next(nearbyObject) then
		for thatGate,dist in pairs(nearbyObject) do
			if thatGate.Id.i ~= this.Id.i and thatGate.Pos.y == this.Pos.y and not thatGate.Deleted then
				Set(thatGate,"Refresh",true)
			end
		end
	end
	local nearbyObject = Find("RoadGate2Large",7)
	if next(nearbyObject) then
		for thatGate,dist in pairs(nearbyObject) do
			if thatGate.Pos.y == this.Pos.y and not thatGate.Deleted then
				if thatGate.Pos.x == this.Pos.x-4.5 or thatGate.Pos.x == this.Pos.x+4.5 then
					Set(thatGate,"Refresh",true)
				end
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
