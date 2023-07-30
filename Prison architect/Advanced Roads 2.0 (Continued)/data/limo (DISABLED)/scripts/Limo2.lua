
--    Name                 Limo
--    Height               5  
--    SpriteScale          1.4

local timePos = 0
local timeTot=0
local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects
local MarkerFound=false

function FindMyRoadMarker()
    local roadMarkers = Find(this,"RoadMarker2",1500)
	MarkerFound = false
    if next(roadMarkers) then
		if Get(this,"MarkerUID") ~= nil then
			for name,dist in pairs(roadMarkers) do
				if Get(name,"MarkerUID") == this.MarkerUID then
					print("[A1] -- "..this.HomeUID.." Marker found")
					MyMarker = name
					MarkerFound = true
					this.Pos.x = name.Pos.x
					-- newH.Pos.x = this.Pos.x
					-- newT.Pos.x = this.Pos.x
					break
				end
			end
		end
	end
	roadMarkers = nil
	if MarkerFound == false then Set(this,"ErrorLog",this.ErrorLog.."\n |  RoadMarker not found.") end
end

function SetRequestForGate(theGateNr)
	if GateList[theGateNr].LargeGate == "no" then
	
		if Get(MyMarker,"RequestFrom"..theGateNr) == "none" and Get(MyMarker,"Authorized"..theGateNr) ~= this.HomeUID then
			if not Get(MyMarker,"WriteLock"..theGateNr) then
				Set(MyMarker,"RequestFrom"..theGateNr,this.HomeUID)
				print("[B1] -- "..this.HomeUID.." stopped. Request for SmallGate "..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate)
			else
				print("[B2] -- "..this.HomeUID.." stopped. Request for SmallGate"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
			end
		end
		
	elseif GateList[theGateNr].LargeGate == "yes" then
	
		if GateList[theGateNr].GatePosX == this.Pos.x+1.5 then
		
			if Get(MyMarker,"RequestFromL"..theGateNr) == "none" and Get(MyMarker,"AuthorizedL"..theGateNr) ~= this.HomeUID then
				if not Get(MyMarker,"WriteLock"..theGateNr) then
					Set(MyMarker,"RequestFromL"..theGateNr,this.HomeUID)
					print("[B3] -- "..this.HomeUID.." stopped. Request for LargeGate L"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate)
				else
					print("[B4] -- "..this.HomeUID.." stopped. Request for LargeGate L"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
				end
			end
			
		elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 then
		
			if Get(MyMarker,"RequestFromR"..theGateNr) == "none" and Get(MyMarker,"AuthorizedR"..theGateNr) ~= this.HomeUID then
				if not Get(MyMarker,"WriteLock"..theGateNr) then
					Set(MyMarker,"RequestFromR"..theGateNr,this.HomeUID)
					print("[B5] -- "..this.HomeUID.." stopped. Request for LargeGate R"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate)
				else
					print("[B6] -- "..this.HomeUID.." stopped. Request for LargeGate R"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
				end
			end
		end
	end
end

function SetRequestForLinkedGates(theGateNr)
	local LinkID = GateList[theGateNr].LinkGate
	for j=theGateNr,TotalGates do
		if GateList[j].LinkGate == LinkID then
			SetRequestForGate(j)
		end
	end
end

function AuthorizedForGate(theGateNr)
	local isAuthorized = false
	if GateList[theGateNr].LargeGate == "no" then
		if Get(MyMarker,"Authorized"..theGateNr) == this.HomeUID then
			print("[C1] -- "..this.HomeUID.." Authorized for SmallGate "..theGateNr..", update gate counter to "..(theGateNr+1).."  Linked: "..GateList[theGateNr].LinkGate)
			isAuthorized = true
		end
	elseif GateList[theGateNr].LargeGate == "yes" then
		if GateList[theGateNr].GatePosX == this.Pos.x+1.5 and Get(MyMarker,"AuthorizedL"..theGateNr) == this.HomeUID then
			print("[C2] -- "..this.HomeUID.." Authorized for LargeGate L"..theGateNr..", update gate counter to "..(theGateNr+1).."  Linked: "..GateList[theGateNr].LinkGate)
			isAuthorized = true
		elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 and Get(MyMarker,"AuthorizedR"..theGateNr) == this.HomeUID then
			print("[C3] -- "..this.HomeUID.." Authorized for LargeGate R"..theGateNr..", update gate counter to "..(theGateNr+1).."  Linked: "..GateList[theGateNr].LinkGate)
			isAuthorized = true
		end
	end
	if isAuthorized == true then
		Set(this,"GateCount",this.GateCount+1)
		if this.GateCount <= TotalGates then
			NextGateY = GateList[this.GateCount].GatePosY
		else
			NextGateY = MapEdge
		end
	end
	return isAuthorized
end

function AuthorizedForLinkedGates(theGateNr)
	local LinkID = GateList[theGateNr].LinkGate
	local linkedgatescounter = 0
	local gatesopencounter = 0
	for j=theGateNr,TotalGates do
		if GateList[j].LinkGate == LinkID then
			linkedgatescounter = linkedgatescounter + 1
		
			if GateList[j].LargeGate == "no" then -- linked SmallGate, check if authorized --
			
				if Get(MyMarker,"Authorized"..j) == this.HomeUID then -- and Get(MyMarker,"GateOpen"..j) == 1 then
					gatesopencounter = gatesopencounter+1
					print("[D1] -- "..this.HomeUID.." Authorized for linked SmallGate "..j.."  Linked: "..GateList[j].LinkGate)
				end
				
			elseif GateList[j].LargeGate == "yes" then -- linked LargeGate, check if authorized --
			
				if GateList[j].GatePosX == this.Pos.x+1.5 and Get(MyMarker,"AuthorizedL"..j) == this.HomeUID then
					gatesopencounter = gatesopencounter+1
					print("[D2] -- "..this.HomeUID.." Authorized for linked LargeGate L"..j.."  Linked: "..GateList[j].LinkGate)
					
				elseif GateList[j].GatePosX == this.Pos.x-1.5 and Get(MyMarker,"AuthorizedR"..j) == this.HomeUID then
					gatesopencounter = gatesopencounter+1
					print("[D3] -- "..this.HomeUID.." Authorized for linked LargeGate R"..j.."  Linked: "..GateList[j].LinkGate)
				end
			end
		end
	end
	print("[D4] -- "..this.HomeUID.." linkedgatescounter: "..linkedgatescounter.."  gatesopencounter: "..gatesopencounter)
	if linkedgatescounter == gatesopencounter then
		Set(this,"GateCount",this.GateCount+linkedgatescounter)
		if this.GateCount <= TotalGates then
			NextGateY = GateList[this.GateCount].GatePosY
			print("NextGateY: "..NextGateY)
		else
			NextGateY = MapEdge
		end
		print("[D5] -- "..this.HomeUID.." Authorized for all linked gates, update gate counter to "..this.GateCount)
		return true
	else
		return false
	end
end

function WaitForGateToOpen()
	if this.GateCount <= TotalGates then
		if not Get(MyMarker,"PeopleCrossingStreet"..this.GateCount) then
		
	print("WaitForGateToOpen")
			if GateList[this.GateCount].LinkGate == "no" then
		
				if not AuthorizedForGate(this.GateCount) then
					SetRequestForGate(this.GateCount)
				else
					StopTheVehicle = nil
				end
				
			else
				
				if not AuthorizedForLinkedGates(this.GateCount) then
					SetRequestForLinkedGates(this.GateCount)
				else
					StopTheVehicle = nil
				end
			end
			
		else
		
			this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nWaiting for people crossing the road..."
			print("[B0] -- "..this.HomeUID.." stopped. Waiting for people crossing the road...")
			
		end
	else
		StopOpeningGates = true
	end
end

function CloseGateBehindMe(Forced)
	if not ForcedCloseGateDone then
	
		local GateCounter = this.GateCount-1
		if Forced == true then
			GateCounter = TotalGates
			print("[F0] -- "..this.HomeUID.." Forced close, TotalGates = "..TotalGates)
		end
		if GateCounter ~= nil and GateCounter > 0 then
			for theGateNr=1,GateCounter do
			
				if GateList[theGateNr].GatePosY <= MyTailLights+1 or Forced == true then
				
					if not Get(this,"ClosedGate"..theGateNr) then -- don't force this one...
					
			print("CloseGateBehindMe "..theGateNr)
						if GateList[theGateNr].LargeGate == "no" then
						
							Set(MyMarker,"CloseGate"..theGateNr,"yes")
							Set(this,"ClosedGate"..theGateNr,true)
							print("[E1] -- "..this.HomeUID.." ClosedGate "..theGateNr)
							
						elseif GateList[theGateNr].GatePosX == this.Pos.x+1.5 then
						
							Set(MyMarker,"CloseGateL"..theGateNr,"yes")
							Set(this,"ClosedGate"..theGateNr,true)
							print("[E2] -- "..this.HomeUID.." ClosedGate L"..theGateNr)
							
						elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 then
						
							Set(MyMarker,"CloseGateR"..theGateNr,"yes")
							Set(this,"ClosedGate"..theGateNr,true)
							print("[E3] -- "..this.HomeUID.." ClosedGate R"..theGateNr)
						end
					end
				end
			end
		end
		if Forced == true and not ForcedCloseGateDone then ForcedCloseGateDone = true end
	end
end

function ClearAuthGateBehindMe(Forced)
	if not ForcedClearAuthDone then
	
		local GateCounter = this.GateCount-1
		local AllAuthCleared = true
		
		if Forced == true then
			GateCounter = TotalGates
			print("[F0] -- "..this.HomeUID.." Forced ClearAuth, TotalGates = "..TotalGates)
		end
		
		if GateCounter ~= nil and GateCounter > 0 then
	
			for theGateNr=1,GateCounter do
			
				if GateList[theGateNr].GatePosY <= MyTailLights-5 or Forced == true then
				
					if not Get(this,"ClearedAuth"..theGateNr) or Forced == true then
					
			print("ClearAuthGateBehindMe "..theGateNr)
						if GateList[theGateNr].LargeGate == "no" then
							if Get(MyMarker,"Authorized"..theGateNr) == this.HomeUID then
								if not Get(MyMarker,"WriteLock"..theGateNr) then
									Set(MyMarker,"Authorized"..theGateNr,"no")
									Set(this,"ClearedAuth"..theGateNr,true)
									print("[F1] -- "..this.HomeUID.." ClearedAuth "..theGateNr)
								else
									AllAuthCleared = false
									print("[F2] -- "..this.HomeUID.." stopped. ClearedAuth for SmallGate"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
								end
							else
								Set(this,"ClearedAuth"..theGateNr,true)
							end
							
						elseif GateList[theGateNr].GatePosX == this.Pos.x+1.5 then
						
							if Get(MyMarker,"AuthorizedL"..theGateNr) == this.HomeUID then
								if not Get(MyMarker,"WriteLock"..theGateNr) then
									Set(MyMarker,"AuthorizedL"..theGateNr,"no")
									Set(this,"ClearedAuth"..theGateNr,true)
									print("[F3] -- "..this.HomeUID.." ClearedAuth L"..theGateNr)
								else
									AllAuthCleared = false
									print("[F4] -- "..this.HomeUID.." stopped. ClearedAuth for LargeGate L"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
								end
							else
								Set(this,"ClearedAuth"..theGateNr,true)
							end

						elseif GateList[theGateNr].GatePosX == this.Pos.x-1.5 then
						
							if Get(MyMarker,"AuthorizedR"..theGateNr) == this.HomeUID then
								if not Get(MyMarker,"WriteLock"..theGateNr) then
									Set(MyMarker,"AuthorizedR"..theGateNr,"no")
									Set(this,"ClearedAuth"..theGateNr,true)
									print("[F5] -- "..this.HomeUID.." ClearedAuth R"..theGateNr)
								else
									AllAuthCleared = false
									print("[F6] -- "..this.HomeUID.." stopped. ClearedAuth for LargeGate R"..theGateNr.."  Linked: "..GateList[theGateNr].LinkGate.." -- denied by WriteLock")
								end
							else
								Set(this,"ClearedAuth"..theGateNr,true)
							end
						end
					end
				end
			end
		end
		
		if Forced == true and not ForcedClearAuthDone then
			if AllAuthCleared == true then
				ForcedClearAuthDone = true
				NextGateY = MapEdge+10
				PriorGateY = MapEdge+10
				StopTheVehicle = nil
				Set(this,"LeavingMap",true)
				local loadedHeadlights=Find(this,"WallLight",6)
				for thatLight, distance in pairs(loadedHeadlights) do
					if Get(thatLight,"HomeUID") == this.HomeUID or thatLight.Id.i == this.Slot1.i or thatLight.Id.i == this.Slot2.i then
						thatLight.Delete()
					end
				end
				print("Forced ClearAuth Done")
				this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nLeaving Map"
			else
				print("Forced ClearAuth Failed")
				this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nAllAuthCleared = false"
			end
		elseif not Forced and not ForcedClearAuthDone then
			for i = 1,TotalGates do
				if not Get(this,"ClearedAuth"..i) then
					PriorGateY = GateList[i].GatePosY
					print("[F7] -- "..this.HomeUID.." PriorGateY: "..PriorGateY)
					break
				end
			end
		end
	end
end

function Create()
	Set(this,"Tail",2)
	Set(this,"Head",2)
	Set(this,"HomeUID","Limo_"..me["id-uniqueId"])
	Set(this,"GateCount",1)
	Set(this,"VelX",0)
	Set(this,"VelY",0)
	Set(this,"FollowingID",-1)
	Set(this,"FollowUpID",-1)
	Set(this,"VehicleState","LeavingGarage")
	Set(this,"UpdateVehicleBehind",false)
	Set(this,"DistanceBehind",0)
	Set(this,"VehicleTypeBehind","None")
	Set(this,"UpdateVehicleInFront",false)
	Set(this,"DistanceInFront",0)
	Set(this,"VehicleTypeInFront","None")
end

function DeleteVehicleClicked()
	if Exists(MyMarker) and TotalGates ~= nil and TotalGates > 0 then
		Set(this,"GateCount",TotalGates)
		CloseGateBehindMe(true)
		ClearAuthGateBehindMe(true)
	end
	local loadedHeadlights=Find(this,"WallLight",6)
	for thatLight, distance in pairs(loadedHeadlights) do
		if Get(thatLight,"HomeUID") == this.HomeUID or thatLight.Id.i == this.Slot1.i or thatLight.Id.i == this.Slot2.i then
			thatLight.Delete()
		end
	end
	this.Delete() 
end

function GetGates()
	print("[G1] -- "..this.HomeUID.." Update gates list")
	GateList = {}
	PriorGateY = 0
	local i = 1
	local listComplete = false
	while not listComplete do
		if Get(MyMarker,"GatePosY"..i) ~= nil then
			GateList[i] = {}
			GateList[i]["GatePosY"] = Get(MyMarker,"GatePosY"..i)
			GateList[i]["GatePosX"] = Get(MyMarker,"GatePosX"..i)
			GateList[i]["LinkGate"] = Get(MyMarker,"LinkGate"..i)
			GateList[i]["LargeGate"] = Get(MyMarker,"LargeGate"..i)
			if i == 1 then
				PriorGateY = GateList[1].GatePosY
			elseif GateList[i].GatePosY <= MyTailLights then
				PriorGateY = GateList[i].GatePosY
			end
			print("[G2] -- "..this.HomeUID.." Marker X "..MyMarker.Pos.x.." - Gate: "..i.."   X "..GateList[i].GatePosX.."   Y "..GateList[i].GatePosY.."   large "..GateList[i].LargeGate.."   linked "..GateList[i].LinkGate)
			i = i + 1
		else
			listComplete = true
		end
	end
	
	TotalGates = Get(MyMarker,"TotalGates")
	GatesHash = Get(MyMarker,"GatesHash")
	if GatesHash ~= nil and TotalGates ~= nil then
		if this.GateCount <= TotalGates and TotalGates > 0 then
			if Get(this,"GateCount") == 1 then
				for i = 1,TotalGates do
					if GateList[i].GatePosY <= MyHeadLights then
						Set(this,"ClosedGate"..i,true)
						Set(this,"ClearedAuth"..i,true)
						Set(this,"GateCount",this.GateCount+1)
						if i == TotalGates then
							if i > 1 then PriorGateY = GateList[this.GateCount-1].GatePosY end
							NextGateY = MapEdge
							StopOpeningGates = true
							break
						else
							PriorGateY = GateList[this.GateCount].GatePosY
						end
					else
						NextGateY = GateList[i].GatePosY
						break
					end
				end
			else
				NextGateY = GateList[this.GateCount].GatePosY
			end
		else
			NextGateY = MapEdge
			StopOpeningGates = true
		end
		print("[G4] -- "..this.HomeUID.." GatesHash: "..GatesHash)
		print("[G4] -- Prior Gate: "..PriorGateY.."  Next Gate: "..NextGateY.."  TotalGates for my marker: "..TotalGates)
	else
		TotalGates = 0
		PriorGateY = 0
		NextGateY = MapEdge
		StopOpeningGates = true
		print("[G6] -- "..this.HomeUID.." Missing GatesHash or no gates on this lane")
	end
end

function SpawnHeadLights()
	 newHL = Object.Spawn("WallLight",this.Pos.x,this.Pos.y+4.5)
	 Set(this,"Slot1.i",Get(newHL,"Id.i"))
	 Set(this,"Slot1.u",Get(newHL,"Id.u"))
	 Set(newHL,"CarrierId.i",Get(this,"Id.i"))
	 Set(newHL,"CarrierId.u",Get(this,"Id.u"))
	 Set(newHL,"Loaded",true)
	 Set(newHL,"HomeUID",this.HomeUID)
	 newHR = Object.Spawn("WallLight",this.Pos.x,this.Pos.y+4.5)
	 Set(this,"Slot2.i",Get(newHR,"Id.i"))
	 Set(this,"Slot2.u",Get(newHR,"Id.u"))
	 Set(newHR,"CarrierId.i",Get(this,"Id.i"))
	 Set(newHR,"CarrierId.u",Get(this,"Id.u"))
	 Set(newHR,"Loaded",true)
	 Set(newHR,"HomeUID",this.HomeUID)
	 Set(this,"HeadLightsSpawned",true)
end

function Update(timePassed)
	if timePerGateUpdate == nil then
		Interface.AddComponent( this,"DeleteVehicle", "Button", "Delete")
		if Get(this,"VelY")==nil then
			Set(this,"VelX",0)
			Set(this,"VelY",0)
		end
		if not this.HeadLightsSpawned then
			SpawnHeadLights()
		end
		if Get(this,"ParkX") == nil then
			Set(this,"ParkX",this.Pos.x)
		end
		FindMyRoadMarker()
		if Get(this,"FollowingID") == -1 then
			FindVehicleInFront()
		else
			LoadVehicleInFront()
		end
		if Get(this,"FollowUpID") == -1 then
			FindVehicleBehindMe()
		else
			LoadVehicleBehindMe()
		end	
		MapEdge = World.NumCellsY+10
		NextGateY = World.NumCellsY+10
		PriorGateY = 0
		MyTailLights = this.Pos.y - this.Tail
		MyHeadLights = this.Pos.y + this.Head
		-- newT = Object.Spawn("FoundationChecker",this.Pos.x,MyTailLights)
		-- newH = Object.Spawn("FoundationChecker",this.Pos.x,MyHeadLights)
		--FindMyRoadMarker()
		if Exists(MyMarker) then
			GetGates()
		end

		if Get(this,"HomeUID")==nil then this.Delete() end
		timePerPositionUpdate = 0.1 / World.TimeWarpFactor
		timePerGateUpdate = 1 / World.TimeWarpFactor
		print("[00] -- "..this.HomeUID.." Init done")
	end
		
	timeTot = timeTot+timePassed
	timePos = timePos+timePassed

	if timePos >= timePerPositionUpdate then
		timePos = 0

		MyTailLights = this.Pos.y - this.Tail
		MyHeadLights = this.Pos.y + this.Head
		-- newT.Pos.y = MyTailLights
		-- newH.Pos.y = MyHeadLights
		
		if Get(this,"UpdateVehicleBehind") == true then
			LoadVehicleBehindMe()
		end
		if Get(this,"UpdateVehicleInFront") == true then
			LoadVehicleInFront()
		end
		if Exists(MyVehicleBehind) then
			VehicleHeadLights = MyVehicleBehind.Pos.y + MyVehicleBehind.Head
		end
		if Exists(MyVehicleInFront) then
			VehicleTailLights = MyVehicleInFront.Pos.y - MyVehicleInFront.Tail
		end
		
		if not ForcedClearAuthDone then
			if MyHeadLights >= MapEdge-11 and not Get(this,"LeavingMap") and TotalGates ~= nil and TotalGates > 0 then
				StopTheVehicle = true
				this.VelY = 0
				Set(this,"GateCount",TotalGates)
				print("Forced close gates")
				CloseGateBehindMe(true)
				ClearAuthGateBehindMe(true)
				if this.IsMilitary == "Yes" then
					RemoveDriver()
				end
				timeTot = 0
				return
			else
				if StopTheVehicle then 
					this.VelY = 0
					timePos=timePerPositionUpdate
				elseif NextGateY - MyHeadLights <= 1 then		-- stop vehicle and request to open gate --
					StopTheVehicle = true
				elseif NextGateY - MyHeadLights <= 3 then		-- slow down when arriving at gate --
					this.VelY = (NextGateY - MyHeadLights) - 0.25
					this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nSlowing down...".."  Speed: "..this.VelY
				elseif Exists(MyVehicleInFront) and VehicleTailLights - MyHeadLights <= 3 then
					this.VelY = VehicleTailLights - MyHeadLights - 0.5			-- - 1.8
					this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nSlowing down for "..MyVehicleInFront.HomeUID.."  Speed: "..this.VelY
					if this.VelY < 0.01 then
						this.VelY = 0
						this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nStopped and waiting for "..MyVehicleInFront.HomeUID
					end
				elseif not Get(this,"LeavingMap") then
					if this.VelY < 3 then
						this.VelY = this.VelY+0.1
					end
					if this.VelY > 3 then this.VelY = 3 end		-- speed limiter for all vehicles
					--this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nDistance to next gate ("..this.GateCount..") is: "..math.floor(NextGateY-MyHeadLights).."  Speed: "..this.Speed

					local tmpGC = this.GateCount
					local tmpDistG = 0
					if TotalGates >= this.GateCount then tmpDistG = GateList[this.GateCount].GatePosY - MyHeadLights end
					local tmpBehind = "none"
					local tmpDistB = 0
					if MyVehicleBehind ~= nil and MyVehicleBehind.SubType ~= nil then tmpBehind = MyVehicleBehind.HomeUID; tmpDistB = MyTailLights - VehicleHeadLights end
					local tmpFront = "none"
					local tmpDistF = 0
					if MyVehicleInFront ~= nil and MyVehicleInFront.SubType ~= nil then tmpFront = MyVehicleInFront.HomeUID; tmpDistF = VehicleTailLights - MyHeadLights end
					
					if TotalGates ~= nil and TotalGates >= this.GateCount then
						this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nCrane ID: "..this.CraneUID.."\n\nDistance to gate ("..tmpGC..") is: "..tmpDistG.."\n\nVehicle Speed: "..this.VelY.."\n\nVehicle behind me: "..tmpBehind.."\nDistance: "..tmpDistB.."\n\nVehicle in front: "..tmpFront.."\nDistance: "..tmpDistF
					else
						this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nCrane ID: "..this.CraneUID.."\n\nVehicle Speed: "..this.VelY.."\n\nVehicle behind me: "..tmpBehind.."\nDistance: "..tmpDistB.."\n\nVehicle in front: "..tmpFront.."\nDistance: "..tmpDistF
					end
				end
				
				if PriorGateY > 0 and not Get(this,"LeavingMap") then
					if PriorGateY <= MyTailLights+1 then
						--this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nDistance to prior stop ("..(this.GateCount-1)..") is: "..(MyTailLights - PriorGateY).." Distance to next stop ("..this.GateCount..") is: "..(NextGateY-MyHeadLights).."  Speed: "..this.Speed
						if MyTailLights - PriorGateY >= 5 then
							ClearAuthGateBehindMe()
						elseif MyTailLights - PriorGateY >= -1 then
							CloseGateBehindMe()
						end
					end
				end
			end
		else
			this.Delete()
		end
	end
	
	Object.ApplyVelocity(this,this.VelX,this.VelY,false)
	
	if timeTot >= timePerGateUpdate then
		timeTot = 0
		
		if this.VehicleState=="LeavingGarage" or this.VehicleState=="Leaving" then
			if Exists(MyMarker) and MarkerHash == MyMarker.MarkerHash then
				if not Get(this,"LeavingMap") then
					if not StopOpeningGates and StopTheVehicle == true then
						this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nStopped and waiting..."
						WaitForGateToOpen()
					end
				end
			else
				if MarkerFound==true then	-- marker got removed or replaced by a new one, reset vehicle
					if this.IsMilitary == "Yes" then
						RemoveDriver()
					end
					local loadedHeadlights=Find(this,"WallLight",6)
					for thatLight, distance in pairs(loadedHeadlights) do
						if Get(thatLight,"HomeUID") == this.HomeUID or thatLight.Id.i == this.Slot1.i or thatLight.Id.i == this.Slot2.i then
							thatLight.Delete()
						end
					end
					this.Delete()
					return
				else
					this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nNo Roadmarker found, ignoring all gates except default Road Gate and Road Barrier"
				end							-- else there were no markers at all, so do nothing
			end
		end
		
	end
end

function FindVehicleBehindMe()
	--print("FindVehicleBehindMe")
	local CurrDist = 9999
	local tmpMyVehicleBehind = nil
	local group = { "CargoStationTruck","Limo2" }
	for _, typ in pairs(group) do
		local nearbyObject = Find(typ,500)
		for V, distance in pairs(nearbyObject) do
			--if V.Id.i ~= this.Id.i and V.VehicleState ~= "Processing" and V.VehicleState ~= "EnteringGarage" and V.Pos.x >= this.Pos.x-3 and V.Pos.x <= this.Pos.x+3 and V.Pos.y < this.Pos.y-4 and this.Pos.y-V.Pos.y < CurrDist then
			if V.Id.i ~= this.Id.i and V.VehicleState ~= "Processing" and V.VehicleState ~= "EnteringGarage" and V.Pos.x == this.ParkX and V.Pos.y < this.Pos.y-4 and this.Pos.y-V.Pos.y < CurrDist then
				CurrDist = distance
				tmpMyVehicleBehind=V
				--print("My x: "..this.Pos.x.."  My y: "..this.Pos.y.."   "..V.HomeUID.." found behind me at x: "..V.Pos.x.." y: "..V.Pos.y.." Dist: "..CurrDist)
			end
		end
	end
	nearbyObject=nil
	if tmpMyVehicleBehind ~= nil and tmpMyVehicleBehind.SubType ~= nil then
		MyVehicleBehind = tmpMyVehicleBehind
		Set(MyVehicleBehind,"VehicleTypeInFront",this.Type)
		Set(MyVehicleBehind,"DistanceInFront",CurrDist+5)
		Set(MyVehicleBehind,"FollowingID",this.Id.i)
		Set(this,"FollowUpID",MyVehicleBehind.Id.i)
		Set(MyVehicleBehind,"UpdateVehicleInFront",true)
		VehicleHeadLights = MyVehicleBehind.Pos.y + MyVehicleBehind.Head
		--print("MyVehicleBehind is "..MyVehicleBehind.HomeUID)
	else
		MyVehicleBehind = nil
	end
end

function FindVehicleInFront()
	--print("FindVehicleInFront")
	local CurrDist = 9999
	local tmpMyVehicleInFront = nil
	local group = { "CargoStationTruck","Limo2" }
	for _, typ in pairs(group) do
		local nearbyObject = Find(typ,500)
		for V, distance in pairs(nearbyObject) do
			--if V.Pos.x ~= nil and V.Id.i ~= this.Id.i and V.VehicleState ~= "Processing" and V.VehicleState ~= "EnteringGarage" and V.Pos.x >= this.Pos.x-3 and V.Pos.x <= this.Pos.x+3 and V.Pos.y >= this.Pos.y-4 and V.Pos.y-this.Pos.y < CurrDist then
			if V.Pos.x ~= nil and V.Id.i ~= this.Id.i and V.VehicleState ~= "Processing" and V.VehicleState ~= "EnteringGarage" and V.Pos.x == this.ParkX and V.Pos.y >= this.Pos.y-4 and V.Pos.y-this.Pos.y < CurrDist then
				if this.VehicleState == "LeavingGarage" then
					CurrDist = distance
					tmpMyVehicleInFront=V
					--print("My x: "..this.Pos.x.."  My y: "..this.Pos.y.."   "..V.HomeUID.." found in front at x: "..V.Pos.x.." y: "..V.Pos.y.." Dist: "..CurrDist)
				elseif V.FollowUpID == -1 then
					CurrDist = distance
					tmpMyVehicleInFront=V
					--print("My x: "..this.Pos.x.."  My y: "..this.Pos.y.."   "..V.HomeUID.." found in front at x: "..V.Pos.x.." y: "..V.Pos.y.." Dist: "..CurrDist)
				end
			end
		end
	end
	nearbyObject=nil
	if tmpMyVehicleInFront ~= nil and tmpMyVehicleInFront.SubType ~= nil then
		MyVehicleInFront = tmpMyVehicleInFront
		Set(MyVehicleInFront,"VehicleTypeBehind",this.Type)
		Set(MyVehicleInFront,"DistanceBehind",CurrDist+5)
		Set(MyVehicleInFront,"FollowUpID",this.Id.i)
		Set(this,"FollowingID",MyVehicleInFront.Id.i)
		Set(MyVehicleInFront,"UpdateVehicleBehind",true)
		VehicleTailLights = MyVehicleInFront.Pos.y - MyVehicleInFront.Tail
		--print("MyVehicleInFront is "..MyVehicleInFront.HomeUID)
	else
		MyVehicleInFront = nil
	end
end

function LoadVehicleBehindMe()
	--print("LoadVehicleBehind")
	local vFound = false
	if this.VehicleTypeBehind ~= "None" then
		--print("trying to find"..this.VehicleTypeBehind.." at distance "..this.DistanceBehind)
		local vehicles = Find(this.VehicleTypeBehind,this.DistanceBehind)
		for V, _ in pairs(vehicles) do
			if Get(V,"FollowingID") == this.Id.i and this.FollowUpID == V.Id.i then --and V.VehicleState ~= "Processing" and V.VehicleState ~= "EnteringGarage" then
				tmpMyVehicleBehind=V
				vFound = true
				break
			end
		end
		vehicles=nil
	end
	if vFound == true then
		MyVehicleBehind = tmpMyVehicleBehind
		VehicleHeadLights = MyVehicleBehind.Pos.y + MyVehicleBehind.Head
		--print("MyVehicleBehind is "..MyVehicleBehind.HomeUID)
	else
		MyVehicleBehind = nil
		--print("MyVehicleBehind not found")
		FindVehicleBehindMe()
	end
end

function LoadVehicleInFront()
	--print("LoadVehicleInFront")
	local vFound = false
	if this.VehicleTypeInFront ~= "None" then
		--print("trying to find"..this.VehicleTypeInFront.." at distance "..this.DistanceInFront)
		local vehicles = Find(this.VehicleTypeInFront,this.DistanceInFront)
		for V, _ in pairs(vehicles) do
			if Get(V,"FollowUpID") == this.Id.i and this.FollowingID == V.Id.i then --and V.VehicleState ~= "Processing" and V.VehicleState ~= "EnteringGarage" then
				tmpMyVehicleInFront=V
				vFound = true
				break
			end
		end
		vehicles=nil
	end
	if vFound == true then
		MyVehicleInFront = tmpMyVehicleInFront
		VehicleTailLights = MyVehicleInFront.Pos.y - MyVehicleInFront.Tail
		--print("MyVehicleInFront is "..MyVehicleInFront.HomeUID)
	else
		MyVehicleInFront = nil
		--print("MyVehicleInFront not found")
		FindVehicleInFront()
	end
end

function RemoveDriver()
    local nearbyObject = Find(this,"Limo2DriverLeaving",4)
	if next(nearbyObject) then
		for thatDriver, dist in pairs(nearbyObject) do
			if thatDriver.CarUID == this.CarUID then
				thatDriver.Delete()
				break
			end
		end
	end
    local nearbyObject = Find(this,"Limo2Window",4)
	if next(nearbyObject) then
		for thatWindow, dist in pairs(nearbyObject) do
			if thatWindow.CarUID == this.CarUID then
				thatWindow.Delete()
				break
			end
		end
	end
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
