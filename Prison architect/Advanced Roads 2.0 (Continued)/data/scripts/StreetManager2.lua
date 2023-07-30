
local timeTot = 0

local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

local AllGates={}
local SortedGates={}
local SortedStopSigns={}

function CacheMyGates()
--	print("CacheMyGates starting")
	local GatesToSort={}
	SortedGates={}
	for thatMarker,d in pairs(myMarkers) do
		SortedGates[thatMarker]={}
--		print("searching for AllSmallGates at "..thatMarker.Pos.x.."")
		local GateCounter=0
		for thatGate, distance in pairs(AllSmallGates) do
			if thatGate.Pos.x==thatMarker.Pos.x then
				GateCounter=GateCounter+1
--				print("found small gate "..GateCounter.." is at "..thatGate.Pos.x.." "..thatGate.Pos.y.."  ID: "..thatGate.Id.u.."")
				GatesToSort[GateCounter]=thatGate.Pos.y
			end	
		end
--		print("searching for AllBigGates at "..thatMarker.Pos.x.."")
		for thatGate, distance in pairs(AllBigGates) do
			if thatGate.Pos.x==thatMarker.Pos.x-1.5 or thatGate.Pos.x==thatMarker.Pos.x+1.5 then
				GateCounter=GateCounter+1
--				print("found big gate "..GateCounter.." is at "..thatGate.Pos.x.." "..thatGate.Pos.y.."  ID: "..thatGate.Id.u.."")
				GatesToSort[GateCounter]=thatGate.Pos.y
			end	
		end
		table.sort(GatesToSort)	-- sort all found gates so we know which marker owns which gates
		local j=0
		for i,n in ipairs(GatesToSort) do
			for thatGate,distance in pairs(AllSmallGates) do
				if thatGate.Pos.y==GatesToSort[i] and thatGate.Pos.y~=GatesToSort[i-1] and thatGate.Pos.x==thatMarker.Pos.x then -- needs thatGate.Pos.y~=GatesToSort[i-1] to prevent rare case double entries (?!?)
					j=j+1
--					print("sorted small gate "..j.." is at: "..thatGate.Pos.x.." "..thatGate.Pos.y.." ID: "..thatGate.Id.u.."")
					SortedGates[thatMarker][j]=thatGate
				end
			end
			for thatGate,distance in pairs(AllBigGates) do
				if thatGate.Pos.y==GatesToSort[i] and thatGate.Pos.y~=GatesToSort[i-1] and (thatGate.Pos.x==thatMarker.Pos.x-1.5 or thatGate.Pos.x==thatMarker.Pos.x+1.5) then
					j=j+1
--					print("sorted big gate "..j.." is at: "..thatGate.Pos.x.." "..thatGate.Pos.y.." ID: "..thatGate.Id.u.."")
					SortedGates[thatMarker][j]=thatGate
				end
			end
		end
	end
	for thatMarker, d in pairs(SortedGates) do
		ResetRoadMarker(thatMarker)
--		print("list for that marker")
		local GatesHash = "Gates: "
		for i, theGate in pairs(SortedGates[thatMarker]) do
			Set(thatMarker,"WriteLock"..i,true)
			Set(thatMarker,"LinkGate"..i,theGate.LinkGate)
			theGate.IsProcessed = nil
			Set(thatMarker,"GatePosX"..i,theGate.Pos.x)
			Set(thatMarker,"GatePosY"..i,theGate.Pos.y)
			Set(thatMarker,"GateOpen"..i,theGate.Open)
			GatesHash = GatesHash.."Y:"..math.floor(theGate.Pos.y).."-L:"..theGate.LinkGate.."-"
			if theGate.Pos.x==thatMarker.Pos.x+1.5 or theGate.Pos.x==thatMarker.Pos.x-1.5 then Set(thatMarker,"LargeGate"..i,"yes") else Set(thatMarker,"LargeGate"..i,"no") end
			if Get(thatMarker,"LargeGate"..i) == "yes" then
				if theGate.Pos.x==thatMarker.Pos.x+1.5 then	-- the RoadMarker is on left lane of double road --
					if not AdjacentMarkerFound(thatMarker,"right") then return end
					Set(theGate,"GatePositionL",i)
					Set(theGate,"MarkerUIDL",thatMarker.Id.u)
					if Get(thatMarker,"RequestFromL"..i) == nil or this.AddNewGates == true then Set(thatMarker,"RequestFromL"..i,"none") end
					if Get(thatMarker,"AuthorizedL"..i) == nil or this.AddNewGates == true then Set(thatMarker,"AuthorizedL"..i,"no") end
					if Get(thatMarker,"CloseGateL"..i) == nil or this.AddNewGates == true then Set(thatMarker,"CloseGateL"..i,"no") end
				elseif theGate.Pos.x==thatMarker.Pos.x-1.5 then	-- the RoadMarker is on right lane of double road --
					if not AdjacentMarkerFound(thatMarker,"left") then return end
					Set(theGate,"GatePositionR",i)
					Set(theGate,"MarkerUIDR",thatMarker.Id.u)
					if Get(thatMarker,"RequestFromR"..i) == nil or this.AddNewGates == true then Set(thatMarker,"RequestFromR"..i,"none") end
					if Get(thatMarker,"AuthorizedR"..i) == nil or this.AddNewGates == true then Set(thatMarker,"AuthorizedR"..i,"no") end
					if Get(thatMarker,"CloseGateR"..i) == nil or this.AddNewGates == true then Set(thatMarker,"CloseGateR"..i,"no") end
				end
			elseif Get(thatMarker,"LargeGate"..i) == "no" then
				Set(theGate,"GatePosition",i)
				Set(theGate,"MarkerUID",thatMarker.Id.u)
				if Get(thatMarker,"Authorized"..i)==nil or this.AddNewGates == true then Set(thatMarker,"Authorized"..i,"no") end
				if Get(thatMarker,"RequestFrom"..i)==nil or this.AddNewGates == true then Set(thatMarker,"RequestFrom"..i,"none") end
				if Get(thatMarker,"CloseGate"..i)==nil or this.AddNewGates == true then Set(thatMarker,"CloseGate"..i,"no") end
			end
			Set(thatMarker,"TotalGates",i)
			Set(thatMarker,"WriteLock"..i,nil)
--			print("Marker ID "..thatMarker.Id.u.." -- X "..thatMarker.Pos.x.." - Gate: "..i.."   X "..theGate.Pos.x.."  Y "..theGate.Pos.y.."   large "..Get(thatMarker,"LargeGate"..i).."   linked "..Get(thatMarker,"LinkGate"..i))
		end
		GatesHash = GatesHash.."-TG:"..thatMarker.TotalGates
		Set(thatMarker,"GatesHash",GatesHash)
--		print("Marker ID "..thatMarker.Id.u.." -- GatesHash: "..thatMarker.GatesHash.."  TotalGates for this marker: "..thatMarker.TotalGates)
	end
end

function CacheMyStopSigns()
--	print("CacheMyStopSigns starting")
	local StopSignsToSort={}
	SortedStopSigns={}
	for thatMarker,d in pairs(myMarkers) do
		SortedStopSigns[thatMarker]={}
--		print("searching for StopSigns at "..thatMarker.Pos.x.."")
		local StopSignCounter=0
		for thatStopSign, distance in pairs(AllStopSigns) do
			if thatStopSign.Pos.x==thatMarker.Pos.x-1.5000 or thatStopSign.Pos.x==thatMarker.Pos.x+1.5000 then
				StopSignCounter=StopSignCounter + 1
--				print("Found Cargo stop "..StopSignCounter.." is at "..thatStopSign.Pos.x.." "..thatStopSign.Pos.y.."  ID: "..thatStopSign.Id.u.."")
				StopSignsToSort[StopSignCounter]=thatStopSign.Pos.y
			end	
		end
		table.sort(StopSignsToSort)
		for i,n in ipairs(StopSignsToSort) do 
			for thatStopSign,distance in pairs(AllStopSigns) do
				if thatStopSign.Pos.y==StopSignsToSort[i] and (thatStopSign.Pos.x==thatMarker.Pos.x-1.5000 or thatStopSign.Pos.x==thatMarker.Pos.x+1.5000) then
--					print("Sorted Cargo stop "..StopSignCounter.." is at: "..thatStopSign.Pos.x.." "..thatStopSign.Pos.y.." ID: "..thatStopSign.Id.u.."")
					SortedStopSigns[thatMarker][StopSignCounter]=thatStopSign
					StopSignCounter = StopSignCounter - 1
				end
			end
		end
	end
	local Number = 1	-- Total Cargo Stations of all lanes combined, gives stations/helipads their Number property
	for thatMarker, d in pairs(SortedStopSigns) do
		local StationsHash = "Stations:"
		local CS = #SortedStopSigns[thatMarker]	-- sort stations from bottom to top of the map:
										-- when 3 trucks are ordered for 3 stations on the same lane, 
										-- the first truck spawned will be heading to the lowest station,
										-- so the following trucks don't need to wait for it to unload
		Set(thatMarker,"TotalCargoStops",CS)
		for S, theStop in pairs(SortedStopSigns[thatMarker]) do
			StationsHash = StationsHash.."Y:"..math.floor(theStop.Pos.y).."-S:"..string.sub(theStop.CargoType,1,3).."-"
--			print("CS: "..CS.."   position "..theStop.Pos.x.."  "..theStop.Pos.y.."   CargoType "..theStop.CargoType.." CargoStationID"..theStop.CargoStationID)
			Set(theStop,"Number",Number)
			Set(thatMarker,"CargoPosX"..CS,theStop.Pos.x)
			Set(thatMarker,"CargoPosY"..CS,theStop.Pos.y)
			Set(thatMarker,"CargoStationID"..CS,theStop.CargoStationID)
			Set(thatMarker,"CargoType"..CS,theStop.CargoType)
			Set(thatMarker,"SecLevel"..CS,theStop.SecLevel)
			Set(thatMarker,"IsIntake"..CS,theStop.IsIntake)
			CS = CS - 1
			Number = Number + 1
		end
		StationsHash = StationsHash.."-TCS:"..thatMarker.TotalCargoStops
		Set(thatMarker,"StationsHash",StationsHash)
--		print("Marker ID "..thatMarker.Id.u.." --- TotalCargoStops for this marker: "..thatMarker.TotalCargoStops)
	end
end

function CacheMyGarages()
--	print("CacheMyGarages starting")
	local GaragesToSort={}
	SortedGarages={}
	for thatMarker,d in pairs(myMarkers) do
		SortedGarages[thatMarker]={}
--		print("searching for AllGates at "..thatIntakeMarker.Pos.x.."")
		local GarageCounter=0
		for thatGarage, distance in pairs(AllGarages) do
			if thatGarage.ParkX==thatMarker.Pos.x then
				GarageCounter=GarageCounter+1
--				print("found Garage "..GarageCounter.." is at "..thatGarage.Pos.x.." "..thatGarage.Pos.y.."  ID: "..thatGarage.Id.u.."")
				GaragesToSort[GarageCounter]=thatGarage.ParkY
			end	
		end
		table.sort(GaragesToSort)
		local j=0
		for i,n in ipairs(GaragesToSort) do 
			for thatGarage,distance in pairs(AllGarages) do
				if thatGarage.ParkY==GaragesToSort[i] and thatGarage.ParkX==thatMarker.Pos.x then
					j=j+1
--					print("sorted Garage "..j.." is at: "..thatGarage.Pos.x.." "..thatGarage.Pos.y.." ID: "..thatGarage.Id.u.."")
					SortedGarages[thatMarker][j]=thatGarage
				end
			end
		end
	end
	for thatMarker, d in pairs(SortedGarages) do
		for i, theGarage in pairs(SortedGarages[thatMarker]) do
--			print("i: "..i.."   position "..theGarage.Pos.x.."  "..theGarage.Pos.y.."   mode "..theGarage.Mode.."")
			Set(thatMarker,"GaragePosX"..i,theGarage.ParkX)
			Set(thatMarker,"GaragePosY"..i,theGarage.ParkY)
			Set(theGarage,"MarkerUID",thatMarker.Id.u)
		end
	end
end

function UpdateLinkGates()
	for thatMarker, d in pairs(SortedGates) do
		local GatesHash = "Gates:"
		for i, theGate in pairs(SortedGates[thatMarker]) do
			Set(thatMarker,"LinkGate"..i,Get(theGate,"LinkGate"))
			GatesHash = GatesHash.."Y:"..math.floor(theGate.Pos.y).."-L:"..theGate.LinkGate.."-"
--			print("Marker ID "..thatMarker.Id.u.." -- X "..thatMarker.Pos.x.." - Gate: "..i.."   X "..theGate.Pos.x.."  Y "..theGate.Pos.y.."   large "..Get(thatMarker,"LargeGate"..i).."   linked "..Get(thatMarker,"LinkGate"..i))
		end
		GatesHash = GatesHash.."-TG:"..thatMarker.TotalGates
		Set(thatMarker,"GatesHash",GatesHash)
--		print("Marker ID "..thatMarker.Id.u.." -- GatesHash: "..thatMarker.GatesHash.."  TotalGates for this marker: "..thatMarker.TotalGates)
	end	
end

function ReadMarkerData(theGateX,theGateY)
	for theMarker, s in pairs(SortedGates) do
		if Exists(theMarker) then
			for j, thatGate in pairs(SortedGates[theMarker]) do
				if Exists(thatGate) then
					if thatGate.Pos.x == theGateX and thatGate.Pos.y == theGateY then
						Set(theMarker,"WriteLock"..j,true)
						if thatGate.Pos.x == theMarker.Pos.x+1.5 then				-- LargeGate, left lane
							Set(thatGate,"RequestFromL",Get(theMarker,"RequestFromL"..j))
							Set(thatGate,"AuthorizedL",Get(theMarker,"AuthorizedL"..j))
							Set(thatGate,"CloseGateL",Get(theMarker,"CloseGateL"..j))
							Set(theMarker,"PeopleCrossingStreet"..j,Get(thatGate,"PeopleCrossingStreet"))
							--print("ReadMarkerData - Marker ID "..theMarker.Id.u.." - LargeGate "..j..":  x "..thatGate.Pos.x.."  y "..thatGate.Pos.y.." - Linked: "..thatGate.LinkGate.." - RequestL: "..thatGate.RequestFromL.." - AuthorizedL: "..thatGate.AuthorizedL.." - CloseGateL: "..thatGate.CloseGateL)
						elseif thatGate.Pos.x == theMarker.Pos.x-1.5 then				-- LargeGate, right lane
							Set(thatGate,"RequestFromR",Get(theMarker,"RequestFromR"..j))
							Set(thatGate,"AuthorizedR",Get(theMarker,"AuthorizedR"..j))
							Set(thatGate,"CloseGateR",Get(theMarker,"CloseGateR"..j))
							Set(theMarker,"PeopleCrossingStreet"..j,Get(thatGate,"PeopleCrossingStreet"))
							--print("ReadMarkerData - Marker ID "..theMarker.Id.u.." - LargeGate "..j..":  x "..thatGate.Pos.x.."  y "..thatGate.Pos.y.." - Linked: "..thatGate.LinkGate.." - RequestR: "..thatGate.RequestFromR.." - AuthorizedR: "..thatGate.AuthorizedR.." - CloseGateR: "..thatGate.CloseGateR)
						end
					end
				end
			end
		end
	end
end

function WriteCombinedData(theGateX,theGateY)
	for thisMarker, u in pairs(SortedGates) do
		if Exists(thisMarker) then
			for h, thisGate in pairs(SortedGates[thisMarker]) do
				if Exists(thisGate) then
					if thisGate.Pos.x == theGateX and thisGate.Pos.y == theGateY then
						if thisGate.Pos.x == thisMarker.Pos.x+1.5 then
							Set(thisMarker,"RequestFromL"..h,Get(thisGate,"RequestFromL"))
							Set(thisMarker,"AuthorizedL"..h,Get(thisGate,"AuthorizedL"))
							Set(thisMarker,"CloseGateL"..h,Get(thisGate,"CloseGateL"))
							Set(thisMarker,"PeopleCrossingStreet"..h,Get(thisGate,"PeopleCrossingStreet"))
							--print("WriteCombinedData - Marker ID "..thisMarker.Id.u.." - LargeGate "..h..":  x "..thisGate.Pos.x.."  y "..thisGate.Pos.y.." - Linked: "..thisGate.LinkGate.." - RequestL: "..thisGate.RequestFromL.." - AuthorizedL: "..thisGate.AuthorizedL.." - CloseGateL: "..thisGate.CloseGateL)
						elseif thisGate.Pos.x == thisMarker.Pos.x-1.5 then
							Set(thisMarker,"RequestFromR"..h,Get(thisGate,"RequestFromR"))
							Set(thisMarker,"AuthorizedR"..h,Get(thisGate,"AuthorizedR"))
							Set(thisMarker,"CloseGateR"..h,Get(thisGate,"CloseGateR"))
							Set(thisMarker,"PeopleCrossingStreet"..h,Get(thisGate,"PeopleCrossingStreet"))
							--print("WriteCombinedData - Marker ID "..thisMarker.Id.u.." - LargeGate "..h..":  x "..thisGate.Pos.x.."  y "..thisGate.Pos.y.." - Linked: "..thisGate.LinkGate.." - RequestR: "..thisGate.RequestFromR.." - AuthorizedR: "..thisGate.AuthorizedR.." - CloseGateR: "..thisGate.CloseGateR)
						end
						Set(thisMarker,"WriteLock"..h,nil)
					end
				end
			end
		end
	end
end

function UpdateGateModes()
	for thatMarker, d in pairs(SortedGates) do
		if Exists(thatMarker) then
			thatMarker.Pos.y = 1
			local tmpTooltip = ""
			tmpTooltip = "RoadMarker ID: "..thatMarker.Id.u.." at position X: "..thatMarker.Pos.x.."\nRequests and Authorizations of "..thatMarker.TotalGates.." gates:\n"
			for i, theGate in pairs(SortedGates[thatMarker]) do
				if Exists(theGate) then
					Object.CancelJob(theGate,"OpenDoor")
					
					if Get(thatMarker,"LargeGate"..i) == "no" then		-- SmallGate --
					
						Set(thatMarker,"WriteLock"..i,true)
					
						local gateReq		 = Get(thatMarker,"RequestFrom"..i)
						local gateAuth		 = Get(thatMarker,"Authorized"..i)
						local gateClose		 = Get(thatMarker,"CloseGate"..i)
						local gateTraffic	 = Get(theGate,"Traffic")
						local gateMode		 = Get(theGate,"Mode")
						local gateChanging   = Get(theGate,"Changing")
						if gateMode == "LockedShut" then gateMode = 1 elseif gateMode == "LockedOpen" then gateMode = 2 else gateMode = 0 end
						local gateOpen		 = Get(theGate,"Open")
						local gateCloseTimer = Get(theGate,"CloseTimer")
						local gateCrossing	 = Get(theGate,"PeopleCrossingStreet") 
						
						if (gateMode == 2 and gateOpen == 1 and gateChanging == 0)
						or (gateMode == 1 and gateOpen == 0 and gateChanging == 0) then
							if gateReq == "none" and gateAuth == "no" then
								gateTraffic = nil
								gateMode = 0					-- Mode 2 = LockedOpen, Mode 1 = LockedShut, Mode 0 = Close gate
								gateCloseTimer = 0.1			-- almost immediately close gate without timeout (because CloseTimer counts down from 1.000000 to 0.000000)
						--		print("[A1] -- Marker ID "..thatMarker.Id.u.." -- Small Gate "..i.." -- No traffic, close gate --")
							end
						end
						
						if gateClose == "yes" then
							gateMode = 1
							gateCloseTimer = 0.1
							gateClose = "no"
							gateTraffic = nil
						--	print("[A2] -- Marker ID "..thatMarker.Id.u.." -- Small Gate "..i.." -- Set gate behind "..gateAuth.." to LockedShut")
						end
						
						-- The gate is LockedShut and closed --												
						if not gateCrossing and gateMode <= 1 then -- and gateOpen == 0 then
							if gateReq ~= "none" and gateAuth == "no" then
								gateAuth = gateReq
								gateMode = 2
								gateTraffic = true
								gateReq = "none"
							--		Set(theGate,"Open",0.1)					-- this would open the gate normally instead of setting it to LockedOpen
						--		print("[A3] -- Marker ID "..thatMarker.Id.u.." -- Small Gate "..i.." -- Request for "..gateAuth.." authorized, set to LockedOpen")
							end
						end
						
						Set(thatMarker,"PeopleCrossingStreet"..i,gateCrossing)
						Set(thatMarker,"RequestFrom"..i,gateReq)
						Set(thatMarker,"Authorized"..i,gateAuth)
						Set(thatMarker,"CloseGate"..i,gateClose)
						Set(theGate,"Traffic",gateTraffic)
						Set(theGate,"Open",gateOpen)
						Set(theGate,"Mode",gateMode)
						Set(theGate,"CloseTimer",gateCloseTimer)
						
						Set(thatMarker,"WriteLock"..i,nil)
						
						local tmpGTC = ""
						local tmpMTC = "\n\n"
						if gateCrossing == true then
							tmpGTC = "\n\n  -- People crossing the road --"
							tmpMTC = "\n  -- People crossing the road --\n"
						end
						tmpTooltip=tmpTooltip.."\nGate "..i..":  X "..theGate.Pos.x.."  Y "..theGate.Pos.y.."  Linked: "..theGate.LinkGate.."\n  Req: "..Get(thatMarker,"RequestFrom"..i).." -- Auth: "..Get(thatMarker,"Authorized"..i)..tmpMTC
						theGate.Tooltip = "\nGate "..i..":  X "..theGate.Pos.x.."  Y "..theGate.Pos.y.."\n  Linked: "..theGate.LinkGate.."\n  Request: "..Get(thatMarker,"RequestFrom"..i).."\n  Authorized: "..Get(thatMarker,"Authorized"..i)..tmpGTC

					elseif Get(thatMarker,"LargeGate"..i) == "yes" then	-- LargeGate --

						if not theGate.IsProcessed then	-- one marker on double road processes requests, and the other marker writes this data back
							
							ReadMarkerData(theGate.Pos.x,theGate.Pos.y) -- gather data from both markers and temp store it at gate
							
							-- local gateOrX		 = Get(theGate,"Or.x")
							local gateOrY		 = Get(theGate,"Or.y")
							local gateChanging   = Get(theGate,"Changing")
							local gateOpenDir	 = Get(theGate,"OpenDir.x")
							local gateMode		 = Get(theGate,"Mode")
							if gateMode == "LockedShut" then gateMode = 1 elseif gateMode == "LockedOpen" then gateMode = 2 else gateMode = 0 end
							local gateOpen		 = Get(theGate,"Open")
							local gateTrafficL	 = Get(theGate,"TrafficL")
							local gateTrafficR	 = Get(theGate,"TrafficR")
							local gateCloseTimer = Get(theGate,"CloseTimer")
							local gateReqL		 = Get(theGate,"RequestFromL")
							local gateReqR		 = Get(theGate,"RequestFromR")
							local gateAuthL		 = Get(theGate,"AuthorizedL")
							local gateAuthR		 = Get(theGate,"AuthorizedR")
							local gateCloseL	 = Get(theGate,"CloseGateL")
							local gateCloseR	 = Get(theGate,"CloseGateR")
							local gateCrossing	 = Get(theGate,"PeopleCrossingStreet")
							
							-- The gate is LockedOpen and open, or LockedShut and closed --
							if (gateMode == 2 and gateOpen == 1 and gateChanging == 0)
							or (gateMode == 1 and gateOpen == 0 and gateChanging == 0) then
								if gateReqL == "none" and gateAuthL == "no" and gateReqR == "none" and gateAuthR == "no" then
									gateMode = 0
									gateCloseTimer = 0.1
									gateTrafficL = nil				-- tell its left traffic light to switch to red
									gateTrafficR = nil				-- tell its right traffic light to switch to red
									print("[B1] -- Marker ID "..thatMarker.Id.u.." -- LargeGate "..i.." -- No traffic, close gate --")
								end
							end
							if gateCloseL == "yes" then
								if gateOpen == 1 and not gateTrafficR then
									gateMode = 1
									gateCloseTimer = 0.1
								end
								gateTrafficL = nil
								gateCloseL = "no"
								print("[B2] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Set gate behind "..gateAuthL.." to LockedShut")
							end
							if gateCloseR == "yes" then
								if gateOpen == 1 and not gateTrafficL then
									gateMode = 1
									gateCloseTimer = 0.1
								end
								gateTrafficR = nil
								gateCloseR = "no"
								print("[B3] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Set gate behind "..gateAuthR.." to LockedShut")
							end
							
							-- The gate is LockedOpen and open --
							if not gateCrossing and gateMode == 2 and gateOpen == 1 then
								if (gateReqL ~= "none" and gateAuthL == "no" and gateAuthR ~= "no")		-- vehicle on left lane, right lane is empty, or
								or (gateReqR ~= "none" and gateAuthR == "no" and gateAuthL ~= "no") then	-- vehicle on right lane, left lane is empty
									
									if gateReqL ~= "none" and gateAuthL == "no" then
										gateAuthL = gateReqL
										--gateOrY = 1					-- turn the gate so it opens to the right
										gateTrafficL = true
										gateReqL = "none"
										print("[D1] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Request for "..gateAuthL.." authorized, was LockedOpen")
									elseif gateReqR ~= "none" and gateAuthR == "no" then
										gateAuthR = gateReqR
										--gateOrY = -1				-- turn the gate so it opens to the left
										gateTrafficR = true
										gateReqR = "none"
										print("[D2] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Request for "..gateAuthR.." authorized, was LockedOpen")
									end
									gateOpen = 0.6
									gateOpenDir = -gateOrY * 5
									if gateAuthL == "no" then
										print("[D4] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Set gate for "..gateAuthR.." OpenDirX to "..gateOpenDir)
									else
										print("[D4] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Set gate for "..gateAuthL.." OpenDirX to "..gateOpenDir)
									end
									gateMode = 2

								elseif gateReqL ~= "none" and gateAuthL == "no" and gateReqR ~= "none" and gateAuthR == "no" then	-- vehicles on both lanes

									gateAuthL = gateReqL
									gateTrafficL = true
									gateReqL = "none"
									print("[D5] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Request for "..gateAuthL.." authorized, was LockedOpen")
									gateAuthR = gateReqR
									gateTrafficR = true
									gateReqR = "none"
									print("[D6] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Request for "..gateAuthR.." authorized, was LockedOpen")
									
									gateOpenDir = gateOrY * 5	-- open the gate completely in whatever direction it opened before
									print("[D8] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Set gate for "..gateAuthL.." OpenDirX to "..gateOpenDir)
									print("[D8] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Set gate for "..gateAuthR.." OpenDirX to "..gateOpenDir)
									gateMode = 2
									
								end
								
							-- The gate is LockedShut and closed --
							elseif not gateCrossing and gateMode <= 1 then --  and gateOpen == 0 then
								if (gateReqL ~= "none" and gateAuthL == "no" and gateReqR == "none" and gateAuthR == "no")		-- vehicle on left lane, right lane is empty, or
								or (gateReqR ~= "none" and gateAuthR == "no" and gateReqL == "none" and gateAuthL == "no") then	-- vehicle on right lane, left lane is empty
									
									if gateReqL ~= "none" and gateAuthL == "no" then
										gateAuthL = gateReqL
										gateOrY = -1					-- turn the gate so it opens to the right
										gateTrafficL = true
										gateReqL = "none"
										print("[C1] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Request for "..gateAuthL.." authorized, was Closed, set to LockedOpen")
									elseif gateReqR ~= "none" and gateAuthR == "no" then
										gateAuthR = gateReqR
										gateOrY = 1				-- turn the gate so it opens to the left
										gateTrafficR = true
										gateReqR = "none"
										print("[C2] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Request for "..gateAuthR.." authorized, was Closed, set to LockedOpen")
									end
									gateOpenDir = -gateOrY * 3	-- open the gate halfway
									if gateAuthL == "no" then
										print("[C4] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Set gate for "..gateAuthR.." OpenDirX to "..gateOpenDir)
									else
										print("[C4] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Set gate for "..gateAuthL.." OpenDirX to "..gateOpenDir)
									end
									gateMode = 2

								elseif gateReqL ~= "none" and gateAuthL == "no" and gateReqR ~= "none" and gateAuthR == "no" then	-- vehicles on both lanes

									gateAuthL = gateReqL
									gateTrafficL = true
									gateReqL = "none"
									print("[C5] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Request for "..gateAuthL.." authorized, was Closed, set to LockedOpen")
									gateAuthR = gateReqR
									gateTrafficR = true
									gateReqR = "none"
									print("[C6] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Request for "..gateAuthR.." authorized, was Closed, set to LockedOpen")

									gateOpenDir = -gateOrY * 5	-- open the gate completely in whatever direction it opened before
									print("[C8] -- Marker ID "..thatMarker.Id.u.." -- LargeGate L"..i.." -- Set gate for "..gateAuthL.." OpenDirX to "..gateOpenDir)
									print("[C8] -- Marker ID "..thatMarker.Id.u.." -- LargeGate R"..i.." -- Set gate for "..gateAuthR.." OpenDirX to "..gateOpenDir)
									gateMode = 2
									
								end
								
							end
							
							Set(theGate,"RequestFromL",gateReqL)
							Set(theGate,"AuthorizedL",gateAuthL)
							Set(theGate,"CloseGateL",gateCloseL)
							Set(theGate,"RequestFromR",gateReqR)
							Set(theGate,"AuthorizedR",gateAuthR)
							Set(theGate,"CloseGateR",gateCloseR)
							
							-- Set(theGate,"Or.x",gateOrX)
							Set(theGate,"Or.y",gateOrY)
							Set(theGate,"OpenDir.x",gateOpenDir)
							Set(theGate,"Open",gateOpen)
							Set(theGate,"Mode",gateMode)
							Set(theGate,"CloseTimer",gateCloseTimer)
							Set(theGate,"TrafficL",gateTrafficL)
							Set(theGate,"TrafficR",gateTrafficR)
							theGate.IsProcessed = true
						 else
							WriteCombinedData(theGate.Pos.x,theGate.Pos.y)	-- write temp data from gate back to both markers
							theGate.IsProcessed = nil
						end
						
						local tmpGTC = ""
						local tmpMTC = "\n\n"
						if Get(theGate,"PeopleCrossingStreet") == true then
							tmpMTC = "\n  -- People crossing the road --\n"
							tmpGTC = "\n\n  -- People crossing the road --"
						end
						tmpTooltip=tmpTooltip.."\nGate "..i..":  X "..theGate.Pos.x.."  Y "..theGate.Pos.y.."  Linked: "..theGate.LinkGate.."\n  Req L: "..theGate.RequestFromL.." -- Auth L: "..theGate.AuthorizedL.."\n  Req R: "..theGate.RequestFromR.." -- Auth R: "..theGate.AuthorizedR..tmpMTC
						theGate.Tooltip = "\nGate "..i.." is at:  X "..theGate.Pos.x.."  Y "..theGate.Pos.y.."\n  Linked: "..theGate.LinkGate.."\n  L: Request "..theGate.RequestFromL.."\n  Authorized "..theGate.AuthorizedL.."\n  R: Request "..theGate.RequestFromR.."\n  Authorized "..theGate.AuthorizedR..tmpGTC
					end
						
					Set(thatMarker,"GateOpen"..i,theGate.Open)
					
				else
					FindMyMarkersClicked()		-- gate got removed, reset
					return
				end
			end
			Set(thatMarker,"Tooltip",tmpTooltip)
		else
			FindMyMarkersClicked()				-- marker got removed or replaced, reset
			return
		end
	end
end

function UpdateStopSigns()
	for thatMarker, d in pairs(SortedStopSigns) do
		local StationsHash = "Stations:"
		if next(SortedStopSigns[thatMarker]) then
			local tmpTooltip=thatMarker.Tooltip.."\n\nY positions of "..thatMarker.TotalCargoStops.." Stop Signs:\n"
			for i, theStop in pairs(SortedStopSigns[thatMarker]) do
				if Exists(theStop) then
					StationsHash = StationsHash.."Y:"..math.floor(theStop.Pos.y).."-S:"..string.sub(theStop.CargoType,1,3).."-"
					--thatMarker.SubType = 9
					if theStop.Pos.x == thatMarker.Pos.x-1.5000 then
						tmpTooltip = tmpTooltip.."\n "..i.." is at "..(theStop.Pos.y+2.5).."  "..theStop.CargoType.." (Left)"
					elseif theStop.Pos.x == thatMarker.Pos.x+1.5000 then
						tmpTooltip = tmpTooltip.."\n "..i.." is at "..(theStop.Pos.y+2.5).."  "..theStop.CargoType.." (Right)"
					end
					for T = 1,#SortedStopSigns[thatMarker] do
						if Get(thatMarker,"CargoPosY"..T) == theStop.Pos.y then
							Set(thatMarker,"CargoType"..T,theStop.CargoType)
						end
					end
				else
				--	tmpTooltip=tmpTooltip.."\n  StopSign "..i.." has been removed, please press the Cache RoadMap button."
					FindMyMarkersClicked()
					return
				end
			end
			Set(thatMarker,"Tooltip",tmpTooltip)
		end
		StationsHash = StationsHash.."-TCS:"..thatMarker.TotalCargoStops
		Set(thatMarker,"StationsHash",StationsHash)
	end
end

function UpdateGarages()
	for thatMarker, d in pairs(SortedGarages) do
		if next(SortedGarages[thatMarker]) then
			local tmpTooltip=thatMarker.Tooltip.."\n\nY positions of the Garages on this lane:\n"
			for i, theGarage in pairs(SortedGarages[thatMarker]) do
				if Exists(theGarage) then
					Set(thatMarker,"TotalGarages",i)		-- it doesn't matter when bus stops are placed and then removed. The Totals counter will make sure the bus will stop at valid points only and not obsolete ones (which are not removed from the savegame)
					tmpTooltip=tmpTooltip.."\n "..i.." is at "..theGarage.ParkY..""
				else
				--	tmpTooltip=tmpTooltip.."\n  Garage "..i.." has been removed, please press the Cache RoadMap button."
					FindMyMarkersClicked()
					return
				end
			end
			Set(thatMarker,"Tooltip",tmpTooltip)
		end
	end
end

function BuildGatesMap()
	AllSmallGates={}
	AllBigGates={}
	AllStopSigns={}
	AllGarages={}
	AllSmallGates = Find(this,"RoadGate2Small",10000)
	AllBigGates = Find(this,"RoadGate",1500)		-- how about the road barrier?
	for g,dist in pairs(AllBigGates) do
		newLargeGate = Object.Spawn("RoadGate2Large",g.Pos.x,g.Pos.y)
		g.Delete()
	end
	AllLargeGates = Find(this,"RoadGate2Large",10000)
	if AllLargeGates ~= nil then
		for k,v in pairs(AllLargeGates) do AllBigGates[k] = v end	-- append the table with LargeRoadGates to the table with the default RoadGates
	end
	AllStopSigns = Find(this,"CargoStopSign",10000)
	
	-- AllRailwaySigns = Find(this,"RailwayStopSign",10000)
	-- if AllRailwaySigns ~= nil then
		-- for k,v in pairs(AllRailwaySigns) do AllStopSigns[k] = v end	-- append the table with RailwayStopSigns to the table with the CargoStopSigns
	-- end
	
	AllGarages = Find(this,"GantryCrane2Hook",10000)
	CacheMyGates()
	CacheMyStopSigns()
	CacheMyGarages()
end

function UpdateAllGateModes()
	UpdateGateModes()
	UpdateStopSigns()
	UpdateGarages()
end

function Create()
end

function FindMyTrafficTerminal()
--	print("FindMyTrafficTerminal")
	local nearbyTerminals = Find(this,"TrafficTerminal",4)
	for thatTerminal, distance in pairs(nearbyTerminals) do
		MyTrafficTerminal = thatTerminal
--		print(" -- MyTrafficTerminal found")
	end
	if not Exists(MyTrafficTerminal) then
--		print(" -- ERROR --- MyTrafficTerminal not found")
	end
end

function FindMyMarkersClicked()
--	print(" -- Updating markers and gates -- ")
	myMarkers = nil
	local MyChecker = Object.Spawn("LoadChecker",0,0)
	myMarkers=Find(MyChecker,"RoadMarker2",10000)
	for thatMarker,d in pairs(myMarkers) do
		Set(thatMarker,"MarkerUID",thatMarker.Id.u)
	end
	MyChecker.Delete()
	
	BuildGatesMap()
	UpdateAllGateModes()
	
	if not Exists(MyTrafficTerminal) then FindMyTrafficTerminal() end
	if Exists(MyTrafficTerminal) then Set(MyTrafficTerminal,"UpdateTraffic",true) end
end

function AdjacentMarkerFound(otherMarker,theSide)
	local adjacentOK
	for adjacentMarker, a in pairs(myMarkers) do
		if (theSide == "left" and adjacentMarker.Pos.x == otherMarker.Pos.x-3) or (theSide == "right" and adjacentMarker.Pos.x == otherMarker.Pos.x+3) then
			adjacentOK = true
			break
		end
	end
	if adjacentOK == true then
		return true
	else
		if theSide == "left" then
			newMarker = Object.Spawn("RoadMarker2",otherMarker.Pos.x-3,0.5)
		else
			newMarker = Object.Spawn("RoadMarker2",otherMarker.Pos.x+3,0.5)
		end
		Set(this,"AddNewGates",true)
		return false
	end
end

function ResetRoadMarker(MarkerToReset)
--	print(" -- ResetRoadMarker -- ")
	local done = false
	local i = 1
	while not done do
		if Get(MarkerToReset,"GatePosY"..i) ~= nil then
			Set(MarkerToReset,"GatePosY"..i,nil)
			i = i + 1
		else
			done = true
		end
	end
	Set(MarkerToReset,"TotalEmergencyStops",0)
	Set(MarkerToReset,"TotalBusStops",0)
	Set(MarkerToReset,"TotalCargoStops",0)
	i = 1
	done = false
	while not done do
		if Get(MarkerToReset,"CargoPosY"..i) ~= nil then
			Set(MarkerToReset,"CargoPosX"..i,nil)
			Set(MarkerToReset,"CargoPosY"..i,nil)
			Set(MarkerToReset,"CargoStationID"..i,nil)
			Set(thatMarker,"CargoType"..i,nil)
			Set(thatMarker,"SecLevel"..i,nil)
			Set(thatMarker,"IsIntake"..i,nil)
			i = i + 1
		else
			done = true
		end
	end
	--	Set(MarkerToReset,"GateOpen"..i,0)					-- enabling all these might give unforeseen problems for user when vehicles are on the map, 
	--	Set(MarkerToReset,"CloseGate"..i,"no")				-- so if he needs a REAL reset, then just press Reset button on the marker itself
	--	Set(MarkerToReset,"LinkGate"..i,"no")
	--	Set(MarkerToReset,"RequestFrom"..i,"none")
	--	Set(MarkerToReset,"Authorized"..i,"no")
	Set(MarkerToReset,"TotalGates",0)
end

function ResetAllGatesClicked()
	for myMarker, s in pairs(SortedGates) do
		if Exists(myMarker) then
			for r, myGate in pairs(SortedGates[myMarker]) do
				if Exists(myGate) then
					if Get(myMarker,"LargeGate"..r) == "yes" then
						Set(myMarker,"WriteLock"..r,true)
						if myGate.Pos.x == myMarker.Pos.x+1.5 then
							Set(myGate,"RequestFromL","none")
							Set(myGate,"AuthorizedL","no")
							Set(myGate,"CloseGateL","no")
							Set(myMarker,"RequestFromL"..r,"none")
							Set(myMarker,"AuthorizedL"..r,"no")
							Set(myMarker,"CloseGateL"..r,"no")
						elseif myGate.Pos.x == myMarker.Pos.x-1.5 then
							Set(myGate,"RequestFromR","none")
							Set(myGate,"AuthorizedR","no")
							Set(myGate,"CloseGateR","no")
							Set(myMarker,"RequestFromR"..r,"none")
							Set(myMarker,"AuthorizedR"..r,"no")
							Set(myMarker,"CloseGateR"..r,"no")
						end
						Set(myMarker,"WriteLock"..r,nil)
					else
						Set(myMarker,"WriteLock"..r,true)
						Set(myGate,"RequestFrom","none")
						Set(myGate,"Authorized","no")
						Set(myGate,"CloseGate","no")
						Set(myMarker,"RequestFrom"..r,"none")
						Set(myMarker,"Authorized"..r,"no")
						Set(myMarker,"CloseGate"..r,"no")
						Set(myMarker,"WriteLock"..r,nil)
					end
				end
			end
		end
	end
end

function Update(TimePassed)
	if timePerUpdate == nil then
		FindMyTrafficTerminal()
		this.Tooltip = { "tooltip_StreetManager2",this.HomeUID,"H" }
		Interface.AddComponent(this,"FindMyMarkers", "Button", "Update road map")
		Interface.AddComponent(this,"ResetAllGates", "Button", "Clear gate requests")
		Interface.AddComponent(this,"CaptionSeparatorSubTypes", "Caption", "tooltip_StreetManager2_SeparatorSubTypes")
		Interface.AddComponent(this,"ShowSkins", "Button", "Show truck skins")
		Interface.AddComponent(this,"ChangeSubTypeDeliveries", "Button", "tooltip_StreetManager2_ChangeSubTypeDeliveries",MyTrafficTerminal.SubType_DeliveriesStationTruck+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeExports", "Button", "tooltip_StreetManager2_ChangeSubTypeExports",MyTrafficTerminal.SubType_ExportsStationTruck+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeGarbage", "Button", "tooltip_StreetManager2_ChangeSubTypeGarbage",MyTrafficTerminal.SubType_GarbageStationTruck+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeIntake", "Button", "tooltip_StreetManager2_ChangeSubTypeIntake",MyTrafficTerminal.SubType_IntakeStationTruck+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeEmergency", "Button", "tooltip_StreetManager2_ChangeSubTypeEmergency",MyTrafficTerminal.SubType_EmergencyStationTruck+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeFireEngine", "Button", "tooltip_StreetManager2_ChangeSubTypeFireEngine",MyTrafficTerminal.SubType_FireEngine+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeAmbulance", "Button", "tooltip_StreetManager2_ChangeSubTypeAmbulance",MyTrafficTerminal.SubType_Ambulance+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeRiotVan", "Button", "tooltip_StreetManager2_ChangeSubTypeRiotVan",MyTrafficTerminal.SubType_RiotVan+1,"X")
		Interface.AddComponent(this,"ChangeSubTypeTroopTruck", "Button", "tooltip_StreetManager2_ChangeSubTypeTroopTruck",MyTrafficTerminal.SubType_Troop+1,"X")
		FindMyMarkersClicked()
		timePerUpdate = 0.5
	end
    timeTot = timeTot + TimePassed
    if timeTot > timePerUpdate then
        timeTot=0
		if this.UpdateCargoStations == true then
			print("--UpdateCargoStations--")
			FindMyMarkersClicked()
			Set(this,"UpdateCargoStations",false)
		end
		if this.AddNewGates == true then
			print("--AddNewGates--")
			FindMyMarkersClicked()
			Set(this,"AddNewGates",false)
		end
		if this.UpdateLinkedGates == true then
			print("--UpdateLinkedGates--")
			UpdateLinkGates()
			Set(this,"UpdateLinkedGates",false)
		end
		UpdateAllGateModes()
	end
end

function ShowPreviewSkins()
	if not Exists(PreviewBG)then
		PreviewBG = Object.Spawn("PreviewTruckSkinBG",MyTrafficTerminal.Pos.x+0.5,MyTrafficTerminal.Pos.y)
	else
		PreviewBG.TimeTot = 0
	end
	if not Exists(PreviewDeliveries)then
		PreviewDeliveries = Object.Spawn("PreviewDeliveriesTruckSkin",MyTrafficTerminal.Pos.x-9.5,MyTrafficTerminal.Pos.y-3.5)
	end
	PreviewDeliveries.TimeTot = 0
	PreviewDeliveries.SubType = MyTrafficTerminal.SubType_DeliveriesStationTruck
		
	if not Exists(PreviewExports)then
		PreviewExports = Object.Spawn("PreviewExportsTruckSkin",MyTrafficTerminal.Pos.x-7,MyTrafficTerminal.Pos.y-3.5)
	end
	PreviewExports.TimeTot = 0
	PreviewExports.SubType = MyTrafficTerminal.SubType_ExportsStationTruck
		
	if not Exists(PreviewGarbage)then
		PreviewGarbage = Object.Spawn("PreviewGarbageTruckSkin",MyTrafficTerminal.Pos.x-4.5,MyTrafficTerminal.Pos.y-3.5)
	end
	PreviewGarbage.TimeTot = 0
	PreviewGarbage.SubType = MyTrafficTerminal.SubType_GarbageStationTruck
		
	if not Exists(PreviewIntake)then
		PreviewIntake = Object.Spawn("PreviewIntakeTruckSkin",MyTrafficTerminal.Pos.x-2,MyTrafficTerminal.Pos.y-2)
	end
	PreviewIntake.TimeTot = 0
	PreviewIntake.SubType = MyTrafficTerminal.SubType_IntakeStationTruck
		
	if not Exists(PreviewEmergency)then
		PreviewEmergency = Object.Spawn("PreviewEmergencyTruckSkin",MyTrafficTerminal.Pos.x+0.5,MyTrafficTerminal.Pos.y-2)
	end
	PreviewEmergency.TimeTot = 0
	PreviewEmergency.SubType = MyTrafficTerminal.SubType_EmergencyStationTruck
		
	if not Exists(PreviewFireEngine)then
		PreviewFireEngine = Object.Spawn("PreviewFireEngineTruckSkin",MyTrafficTerminal.Pos.x+3,MyTrafficTerminal.Pos.y+0.25)
	end
	PreviewFireEngine.TimeTot = 0
	PreviewFireEngine.SubType = MyTrafficTerminal.SubType_FireEngine
		
	if not Exists(PreviewAmbulance)then
		PreviewAmbulance = Object.Spawn("PreviewAmbulanceTruckSkin",MyTrafficTerminal.Pos.x+5.5,MyTrafficTerminal.Pos.y-2)
	end
	PreviewAmbulance.TimeTot = 0
	PreviewAmbulance.SubType = MyTrafficTerminal.SubType_Ambulance
		
	if not Exists(PreviewRiotVan)then
		PreviewRiotVan = Object.Spawn("PreviewRiotVanTruckSkin",MyTrafficTerminal.Pos.x+8,MyTrafficTerminal.Pos.y)
	end
	PreviewRiotVan.TimeTot = 0
	PreviewRiotVan.SubType = MyTrafficTerminal.SubType_RiotVan
		
	if not Exists(PreviewTroopTruck)then
		PreviewTroopTruck = Object.Spawn("PreviewTroopTruckSkin",MyTrafficTerminal.Pos.x+10.5,MyTrafficTerminal.Pos.y)
	end
	PreviewTroopTruck.TimeTot = 0
	PreviewTroopTruck.SubType = MyTrafficTerminal.SubType_Troop
end

function ShowSkinsClicked()
	ShowPreviewSkins()
end

function ChangeSubTypeDeliveriesClicked()
	local S = MyTrafficTerminal.SubType_DeliveriesStationTruck
	S = S + 1
	if S >= 9 then S = 0 end
	Set(MyTrafficTerminal,"SubType_DeliveriesStationTruck",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeDeliveries", "tooltip_StreetManager2_ChangeSubTypeDeliveries",(S+1),"X")
end

function ChangeSubTypeExportsClicked()
	local S = MyTrafficTerminal.SubType_ExportsStationTruck
	S = S + 1
	if S >= 9 then S = 0 end
	Set(MyTrafficTerminal,"SubType_ExportsStationTruck",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeExports", "tooltip_StreetManager2_ChangeSubTypeExports",(S+1),"X")
end

function ChangeSubTypeGarbageClicked()
	local S = MyTrafficTerminal.SubType_GarbageStationTruck
	S = S + 1
	if S >= 9 then S = 0 end
	Set(MyTrafficTerminal,"SubType_GarbageStationTruck",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeGarbage", "tooltip_StreetManager2_ChangeSubTypeGarbage",(S+1),"X")
end

function ChangeSubTypeIntakeClicked()
	local S = MyTrafficTerminal.SubType_IntakeStationTruck
	S = S + 1
	if S >= 14 then S = 0 end
	Set(MyTrafficTerminal,"SubType_IntakeStationTruck",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeIntake", "tooltip_StreetManager2_ChangeSubTypeIntake",(S+1),"X")
end

function ChangeSubTypeEmergencyClicked()
	local S = MyTrafficTerminal.SubType_EmergencyStationTruck
	S = S + 1
	if S >= 14 then S = 0 end
	Set(MyTrafficTerminal,"SubType_EmergencyStationTruck",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeEmergency", "tooltip_StreetManager2_ChangeSubTypeEmergency",(S+1),"X")
end

function ChangeSubTypeFireEngineClicked()
	local S = MyTrafficTerminal.SubType_FireEngine
	S = S + 1
	if S >= 13 then S = 0 end
	Set(MyTrafficTerminal,"SubType_FireEngine",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeFireEngine", "tooltip_StreetManager2_ChangeSubTypeFireEngine",(S+1),"X")
end

function ChangeSubTypeAmbulanceClicked()
	local S = MyTrafficTerminal.SubType_Ambulance
	S = S + 1
	if S >= 14 then S = 0 end
	Set(MyTrafficTerminal,"SubType_Ambulance",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeAmbulance", "tooltip_StreetManager2_ChangeSubTypeAmbulance",(S+1),"X")
end

function ChangeSubTypeRiotVanClicked()
	local S = MyTrafficTerminal.SubType_RiotVan
	S = S + 1
	if S >= 15 then S = 0 end
	Set(MyTrafficTerminal,"SubType_RiotVan",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeRiotVan", "tooltip_StreetManager2_ChangeSubTypeRiotVan",(S+1),"X")
end

function ChangeSubTypeTroopTruckClicked()
	local S = MyTrafficTerminal.SubType_Troop
	S = S + 1
	if S >= 11 then S = 0 end
	Set(MyTrafficTerminal,"SubType_Troop",S)
	ShowPreviewSkins()
	this.SetInterfaceCaption("ChangeSubTypeTroopTruck", "tooltip_StreetManager2_ChangeSubTypeTroopTruck",(S+1),"X")
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
