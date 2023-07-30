
local timeTot = 0
local flashTimer = 0
local timePerFlash = 0.75

local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects

local SubTypes = {
		Cargo		 = { [1] = 0, [2] = 1 },
		Exports		 = { [1] = 2, [2] = 3 },
		Emergency	 = { [1] = 4, [2] = 5 },
		Intake		 = { [1] = 6, [2] = 7, [3] = 8, [4] = 9 },
		Fireman		 = { [1] = 10, [2] = 11, [3] = 12 },
		Paramedic	 = { [1] = 13, [2] = 14 },
		Orderly		 = { [1] = 15, [2] = 16 },
		RiotGuard	 = { [1] = 17, [2] = 18 },
		ArmedGuard	 = { [1] = 17, [2] = 18 },
		Soldier		 = { [1] = 19, [2] = 20 },
		EliteOps	 = { [1] = 19, [2] = 20 }
		}

local CalloutEntitiesToFind = { "Fireman", "Paramedic", "Orderly", "RiotGuard", "ArmedGuard", "Soldier", "EliteOps" }
local MyEntities = {}

local EntitySpots = { [1] = 1.475, [2] = 1.975, [3] = 2.475, [4] = 2.975, [5] = 1.475, [6] = 1.975, [7] = 2.475, [8] = 2.975 }

function Create()
	Set(this,"VehicleState","Arriving")
    Set(this,"PosX",this.Pos.x)
    Set(this,"PosY",this.Pos.y)
end

function Update(timePassed)
	if timePerUpdate == nil then
		if this.MyType == nil then
			if not InitMyCalloutEntities() then
				return
			end
		end
		if this.Number == nil then return end
		print("My HomeUID: "..this.HomeUID)
		FindMyParts()
		if IsCallOut then FindMyCalloutEntities(9) end
		this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
		timePerUpdate = 0.016
	end
	timeTot = timeTot + timePassed

	if IsAnimated then
		if not IsIntake then
			
			if TickTock then
				TickTock = nil
			else
				if this.SubType == SubTypes[SkinType][1] then this.SubType = SubTypes[SkinType][2] else this.SubType = SubTypes[SkinType][1] end
				TickTock = true
			end
			
			flashTimer = flashTimer + timePassed
			if flashTimer >= timePerFlash then
				flashTimer,timePerFlash = 0,math.random()
				if not flashTickTock then
					MyBackLight.Triggered = 2
					flashTickTock = true
				else
					MyFrontLight.Triggered = 2
					flashTickTock = nil
				end
			end
		elseif this.SubType < SubTypes[SkinType][3] then
		
			if TickTock and timeTot >= timePerUpdate then
				TickTock = nil
			elseif timeTot >= timePerUpdate then
				if this.SubType == SubTypes[SkinType][1] then this.SubType = SubTypes[SkinType][2] else this.SubType = SubTypes[SkinType][1] end
				TickTock = true
			end

			flashTimer = flashTimer + timePassed
			if flashTimer >= timePerFlash then
				flashTimer,timePerFlash = 0,math.random()
				if not flashTickTock then
					MyBackLight.Triggered = 2
					flashTickTock = true
				else
					MyFrontLight.Triggered = 2
					flashTickTock = nil
				end
			end
		end
	elseif IsCallOut then
		
		if TickTock then
			TickTock = nil
		else
			if this.SubType == SubTypes[SkinType][1] then this.SubType = SubTypes[SkinType][2] else this.SubType = SubTypes[SkinType][1] end
			TickTock = true
		end
	end
	
	if timeTot >= timePerUpdate then
		timeTot = 0
			
		if this.DeleteMe == true then
			if IsCargo then MoveStackBackToTerminal() elseif IsIntake then MovePrisonersBackToTerminal() end
			return
		end
	-------------------------------------------------------------------------------------------
	-- Fly to my Helipad
	-------------------------------------------------------------------------------------------     
		if VehicleState == "ToHelipad" then
			if not this.HasLanded then
				GoTo(padX,padY+3,5,timePassed)
				if IsCallOut then KeepEntitiesLoaded() end
				if AtDest(padX,padY,2.05) then
					Set(this,"PosX",this.PadX-2)
					Set(this,"PosY",this.PadY+2)
					if IsCargo or IsExports or IsHearse then
						Set(this,"Slot2.i",-1)
						Set(this,"Slot2.u",-1)
						MyHook1.Loaded = nil
						Set(this,"Slot3.i",-1)
						Set(this,"Slot3.u",-1)
						MyHook2.Loaded = nil
					elseif IsIntake then
						Set(this,"PosX",this.PadX-2.25)
					elseif IsCallOut then
						if not Exists(MyHelipad) then FindMyHelipad(9) end
						if Exists(MyHelipad) then
							if MyHelipad.Type == "CalloutHelipad" then
								for I = 1,8 do
									MyEntities[I].Equipment = MyHelipad.CalloutEquipment
								end
								if this.MyType == "Fireman" and MyHelipad.FiremanMethod == "DropOff" and MyHelipad.CalloutEquipment == 24 then WaitAtDropOff = true end
								MyHelipad.Delete()
							else
								Set(MyHelipad,"InUse","no")
								Set(MyHelipad,"VehicleSpawned","no")
								Set(MyHelipad,"Status","Waiting...")
							end
						end
						if FlyBy then
							Set(this,"VehicleState","ToMapEdge")
							VehicleState = "ToMapEdge"
							this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
						end
					end
					Set(this,"HasLanded",true)
				end
			else
				if not this.Cooldown then		-- do last bit of landing corrections
					GoDown(padY,1,timePassed)
					if this.Pos.y >= this.PosY then
						if IsExports or IsHearse then
							MyHook1.Delete()
							MyHook2.Delete()
						end
						if IsIntake then
							print("Unload skin")	-- temporary unload the skin from the inside, so the doors are visible when they open (would otherwise be a renderdepth issue)
							Set(MyInside,"Slot0.i",-1)
							Set(MyInside,"Slot0.u",-1)
							Set(this,"CarrierId.i",-1)
							Set(this,"CarrierId.u",-1)
							Set(this,"Loaded",false)
							this.Pos.x = MyInside.Pos.x
							this.Pos.y = MyInside.Pos.y
							Set(this,"VehicleState","GuardAndPilotOut")
							VehicleState = "GuardAndPilotOut"
							timePerUpdate = 0
						elseif WaitAtDropOff then
							Set(this,"VehicleState","DeployFiremen")
							VehicleState = "DeployFiremen"
							this.Pos.x = this.PosX
							this.Pos.y = this.PosY
						else
							Set(this,"VehicleState","Processing")
							VehicleState = "Processing"
							this.Pos.x = this.PosX
							this.Pos.y = this.PosY
						end
						this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
						Set(this,"Cooldown",true)
					end
				end
			end
	
	-------------------------------------------------------------------------------------------
	-- Fly to MapEdge
	-------------------------------------------------------------------------------------------   
		elseif VehicleState == "ToMapEdge" then
			if not FlyBy then
				GoTo(edgeX,edgeY,7.5,timePassed)	-- leave map with normal speed
			else
				KeepEntitiesLoaded()
				GoTo(edgeX,edgeY,2.5,timePassed)	-- leave map slower for flyby, so firemen actually get some time to do their job
			end
			if AtDest(edgeX,edgeY,2) then
				if IsExports or IsHearse then
					if MyHook1.Type == "EmergencyChinookHook" then
						if not Exists(MyHelipad) then FindMyHelipad(10000) end
						if Exists(MyHelipad) then
							Set(MyHelipad,"LoadAvailable",false)
							Set(MyHelipad,"InUse","no")
							Set(MyHelipad,"VehicleSpawned","no")
							Set(MyHelipad,"Status","Waiting...")
						end
						Set(this,"HeliPadID",0)
					end
					
					local DummyBoxes = Find(MyHook1,"CargoExports",3)
					if next(DummyBoxes) then
						for thatDummy, dist in pairs(DummyBoxes) do
							if thatDummy.HomeUID == this.HomeUID then
								print("DummyBox found at "..dist)
								thatDummy.Delete()
							end
						end
					else
						local SupplyTruck1 = Object.Spawn("SupplyTruck",World.NumCellsX - 2.1,World.NumCellsY - 2)
						Set(SupplyTruck1,"StackTransferred",true)
						Set(SupplyTruck1,"State","Leaving")
						Set(SupplyTruck1,"Hidden",true)	-- spawn an invisible truck to export stuff/bodies
						for i=0,7 do
							Set(SupplyTruck1,"Slot"..i..".i",Get(MyHook1,"Slot"..i..".i"))
							Set(SupplyTruck1,"Slot"..i..".u",Get(MyHook1,"Slot"..i..".u"))
						end
						local SupplyTruck2 = Object.Spawn("SupplyTruck",World.NumCellsX - 2.2,World.NumCellsY - 2)
						Set(SupplyTruck2,"StackTransferred",true)
						Set(SupplyTruck2,"State","Leaving")
						Set(SupplyTruck2,"Hidden",true)
						for i=0,7 do
							Set(SupplyTruck2,"Slot"..i..".i",Get(MyHook2,"Slot"..i..".i"))
							Set(SupplyTruck2,"Slot"..i..".u",Get(MyHook2,"Slot"..i..".u"))
						end
					end
					Set(this,"CargoToTruck",true)
				elseif IsCallOut then
					if this.MyType == "Fireman" and this.FlyBy == true then
						if not Exists(MyEntity1) then FindMyCalloutEntities(9) end
						for D = 1,8 do
							if Exists(MyEntities[D]) then MyEntities[D].Delete() end
						end
					end
				end
				if Exists(MyInside) then MyInside.Delete() end
				if Exists(MyHook1) then MyHook1.Delete() end
				if Exists(MyHook2) then MyHook2.Delete() end
				if Exists(MyBackLight) then MyBackLight.Delete() end
				if Exists(MyFrontLight) then MyFrontLight.Delete() end
				this.Delete()
			end
	-------------------------------------------------------------------------------------------
	-- Stationary
	-------------------------------------------------------------------------------------------
		elseif VehicleState == "Processing" then
	-------------------------------------------------------------------------------------------
			-- Unload cargo
	------------------------------------------------------------------------------------------- 
			if IsCargo then
				if not this.CargoDeployed then
					SwapRealDeliveries(MyHook1)
					MyHook1.SubType = 1
					SwapRealDeliveries(MyHook2)
					MyHook2.SubType = 1
					for D = 0,7 do
						Set(MyHook1,"Slot"..D..".i",-1)
						Set(MyHook1,"Slot"..D..".u",-1)
						Set(MyHook2,"Slot"..D..".i",-1)
						Set(MyHook2,"Slot"..D..".u",-1)
					end
					if not Exists(MyHelipad) then FindMyHelipad(9) end
					if Exists(MyHelipad) then
						Set(MyHelipad,"InUse","no")
						Set(MyHelipad,"VehicleSpawned","no")
						Set(MyHelipad,"Status","Waiting...")
						MyHelipad.Tooltip = { "tooltip_CargoHelipad",MyHelipad.HomeUID,"Y",MyHelipad.Number,"Z" }
					end
					Set(this,"VehicleState","TakeOff")
					VehicleState = "TakeOff"
					this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
					Set(this,"CargoDeployed",true)
				end
	-------------------------------------------------------------------------------------------
			-- Pick up exports or dead bodies
	------------------------------------------------------------------------------------------- 
			elseif IsExports or IsHearse then
				if not this.ExportsPickedUp then
					if not this.HookReleased then
						FindMyExportsHook()
						SpawnSupplyTruck(MyHook1)
						Set(MyHook1,"SubType",0)
						SpawnSupplyTruck(MyHook2)
						Set(MyHook2,"SubType",0)
						if MyHook1.Type == "EmergencyChinookHook" then
							FillUpHook(MyHook1)
							FillUpHook(MyHook2)
						end
						Set(this,"HookReleased",true)
					elseif not this.HookLoaded then
						Set(MyHook1,"HomeUID",this.HomeUID)
						Set(MyHook2,"HomeUID",this.HomeUID)
						Set(MyHook1,"Tooltip","\nVehicle ID: "..this.HomeUID.." Bay 1")
						Set(MyHook2,"Tooltip","\nVehicle ID: "..this.HomeUID.." Bay 2")
						Set(this,"VehicleState","TakeOff")
						VehicleState = "TakeOff"
						this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
						Set(this,"HookLoaded",true)
						Set(this,"ExportsPickedUp",true)
					end
				end
	-------------------------------------------------------------------------------------------
			-- Keep personnel on their spot
	-------------------------------------------------------------------------------------------
			elseif IsIntake then
				timePerUpdate = 1
				
				if Exists(MyPilot) and not this.ChinookLeaving then MyPilot.ClearRouting(); MyPilot.NavigateTo(this.Pos.x+6.5,this.Pos.y+3); MyPilot.Or.x=0; MyPilot.Or.y = 1 end
				if Exists(MyGuard) and not this.ChinookLeaving then MyGuard.ClearRouting(); MyGuard.NavigateTo(this.Pos.x+5.25,this.Pos.y+3); MyGuard.Or.x=0; MyGuard.Or.y = 1 end
	-------------------------------------------------------------------------------------------
				-- Unload prisoners
	------------------------------------------------------------------------------------------- 
				if not this.PrisonerIntakeDone then
					UnloadPrisonersFromChinook()
				end
				
				if this.PrisonerIntakeDone == true then
					if not Exists(MyHook1) then FindMyIntakeHook(1) end
					if Exists(MyHook1) then MyHook1.Delete() end
					if Exists(MyHook2) then MyHook2.Delete() end
					if not Exists(blockLeft) then FindMyBlocks() end
					if Exists(blockLeft) then blockLeft.Delete() end
					if Exists(blockRight) then blockRight.Delete() end
					
					Set(this,"VehicleState","GuardAndPilotIn")
					VehicleState = "GuardAndPilotIn"
					this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
				end
	-------------------------------------------------------------------------------------------
			-- Unload call-out
	-------------------------------------------------------------------------------------------
			elseif IsCallOut then
				timePerUpdate = 1
				if not this.CalloutEntitiesDeployed then		-- release the emergency entities
					if not Exists(MyEntity1) then FindMyCalloutEntities(9) end
					for U = 0,7 do
						Set(this,"Slot"..U..".i",-1)
						Set(this,"Slot"..U..".u",-1)
						if Exists(MyEntities[U+1]) then
							Set(MyEntities[U+1],"CarrierId.i",-1)
							Set(MyEntities[U+1],"CarrierId.u",-1)
							MyEntities[U+1].Loaded = false
							-- start PA 2018 code
							-- MyEntities[U+1].NavigateTo(MyEntities[U+1].Pos.x,MyEntities[U+1].Pos.y+2)
							-- finish PA 2018 code
							
							-- start PA Rock code
							if MyEntities[U+1].Type == "Fireman" then
								MyEntities[U+1].PlayerOrderPos.x = MyEntities[U+1].Pos.x
								MyEntities[U+1].PlayerOrderPos.y = MyEntities[U+1].Pos.y+2
							else
								MyEntities[U+1].NavigateTo(MyEntities[U+1].Pos.x,MyEntities[U+1].Pos.y+2)
							end
							-- finish PA Rock code
						 end
					end
					timePerUpdate = 1
					Set(this,"VehicleState","TakeOff")
					VehicleState = "TakeOff"
					this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
					Set(this,"CalloutEntitiesDeployed",true)
				end
			end
	-------------------------------------------------------------------------------------------
	-- TakeOff
	-------------------------------------------------------------------------------------------
		elseif VehicleState == "TakeOff" then
			if not this.ChinookLeaving then
				if IsCargo then
					if not this.WarmingUpA then		-- get airborn   
						GoUp(padY-3,1,timePassed)
						if this.Pos.y <= this.PosY - 3 then
							Set(this,"Slot2.i",MyHook1.Id.i)
							Set(this,"Slot2.u",MyHook1.Id.u)
							Set(MyHook1,"Loaded",true)
							Set(this,"Slot3.i",MyHook2.Id.i)
							Set(this,"Slot3.u",MyHook2.Id.u)
							Set(MyHook2,"Loaded",true)
							
							-- if not Exists(MyHelipad) then FindMyHelipad(9) end	 -- moved to line 273, since deliveries pad somehow kept being in use
							-- if Exists(MyHelipad) then
								-- Set(MyHelipad,"InUse","no")
								-- Set(MyHelipad,"VehicleSpawned","no")
								-- Set(MyHelipad,"Status","Waiting...")
								-- MyHelipad.Tooltip = { "tooltip_CargoHelipad",MyHelipad.HomeUID,"Y",MyHelipad.Number,"Z" }
							-- end
							Set(this,"ChinookLeaving",true)
							Set(this,"WarmingUpA",true)
						end
					end
				elseif IsExports or IsHearse then
					if not this.WarmingUpA then		-- get airborn   
						GoUp(padY-3,1,timePassed)
						if this.Pos.y <= this.PosY - 3 then
							Set(this,"Slot2.i",MyHook1.Id.i)
							Set(this,"Slot2.u",MyHook1.Id.u)
							Set(MyHook1,"Loaded",true)
							Set(this,"Slot3.i",MyHook2.Id.i)
							Set(this,"Slot3.u",MyHook2.Id.u)
							Set(MyHook2,"Loaded",true)
							
							if MyHook1.Type == "ExportsChinookHook" then
								if not Exists(MyHelipad) then FindMyHelipad(9) end
								if Exists(MyHelipad) then
									Set(MyHelipad,"LoadAvailable",false)
									Set(MyHelipad,"InUse","no")
									Set(MyHelipad,"VehicleSpawned","no")
									Set(MyHelipad,"Status","Waiting...")
									MyHelipad.Tooltip = { "tooltip_CargoHelipad",MyHelipad.HomeUID,"Y",MyHelipad.Number,"Z" }
								end
								Set(this,"HeliPadID",0)
							end
							Set(this,"ChinookLeaving",true)
							Set(this,"WarmingUpA",true)
						end
					end
				elseif IsIntake then
					if not this.WarmingUpA then			-- let the blades spin up
						timePerUpdate = timePerUpdate - 0.01
						if this.SubType == SubTypes[SkinType][1] then this.SubType = SubTypes[SkinType][2] else this.SubType = SubTypes[SkinType][1] end
						TickTock = true
						if timePerUpdate <= 0.016 then
							timePerUpdate = 0.016
							Set(this,"WarmingUpA",true)
						end
					elseif not this.WarmingUpB then		-- get airborn
						timePerUpdate = 0.016
						GoUp(padY-3,1,timePassed)
						if this.Pos.y <= this.PosY - 3 then
							if not Exists(MyHelipad) then FindMyHelipad(9) end
							if Exists(MyHelipad) then
								Set(MyHelipad,"InUse","no")
								Set(MyHelipad,"VehicleSpawned","no")
								Set(MyHelipad,"Status","Waiting...")
								MyHelipad.Tooltip = { "tooltip_CargoHelipad",MyHelipad.HomeUID,"Y",MyHelipad.Number,"Z" }
							end
							timePerUpdate = 0.016
							Set(this,"ChinookLeaving",true)
							Set(this,"WarmingUpB",true)
						end
					end
				elseif IsCallOut then
					timePerUpdate = 0.016
					if not this.WarmingUpA then		-- get airborn   
						GoUp(padY-3,1,timePassed)
						if this.Pos.y <= this.PosY - 3 then
							Set(this,"ChinookLeaving",true)
							Set(this,"WarmingUpA",true)
						end
					end
				end
			else
				Set(this,"VehicleState","ToMapEdge")
				VehicleState = "ToMapEdge"
				this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
			end
	-------------------------------------------------------------------------------------------
	-- Open doors and let guard/pilot out
	------------------------------------------------------------------------------------------- 
		elseif VehicleState == "GuardAndPilotOut" then

			if not this.CooldownB then	-- let the blades spin down
				timePerUpdate = timePerUpdate + 0.01
				if this.SubType == SubTypes[SkinType][1] then this.SubType = SubTypes[SkinType][2] else this.SubType = SubTypes[SkinType][1] end
				TickTock = true
				if timePerUpdate >= 0.35 then
					timePerUpdate = 1.2
					Set(this,"CooldownB",true)
				end
			elseif not this.DoorsSpawnedA then	-- spawn dummy doors
				this.SubType = SubTypes[SkinType][3]
				if not Exists(doorLeft) then 
					doorLeft=Object.Spawn("IntakeChinookDoor",this.Pos.x+1.485,this.Pos.y+0.29)
					Set(doorLeft,"HomeUID",this.HomeUID)
					Set(doorLeft,"Left",true)
					doorRight=Object.Spawn("IntakeChinookDoor",this.Pos.x+2.585,this.Pos.y+0.29)
					Set(doorRight,"HomeUID",this.HomeUID)
					Set(doorRight,"Right",true)
				end
				timePerUpdate = 0
				Set(this,"DoorsSpawnedA",true)
			elseif not this.DoorsOpened then		-- open the dummy doors manually so they cant be blocked like normal doors
				if not Exists(doorLeft) then FindMyDoors() end
				if doorLeft.Pos.x >= this.Pos.x + 0.35 then
					doorLeft.Pos.x = doorLeft.Pos.x - 0.005
					doorRight.Pos.x = doorRight.Pos.x + 0.005
				else
					this.SubType = SubTypes[SkinType][4]
					print("Load skin")	-- load skin back onto the inside, so the renderdepth changes again and pilot/guard appear inside the chinook
					Set(MyInside,"Slot0.i",this.Id.i)
					Set(MyInside,"Slot0.u",this.Id.u)
					Set(this,"CarrierId.i",MyInside.Id.i)
					Set(this,"CarrierId.u",MyInside.Id.u)
					Set(this,"Loaded",true)
					doorLeft.Delete()
					doorRight.Delete()
					Set(this,"DoorsOpened",true)
				end
			elseif not this.PilotToDoorA then
				print("move pilot and guard A")
				MyGuard = Object.Spawn("IntakeChinookGuard",this.Pos.x+1.5,this.Pos.y+0.6)
				MyPilot = Object.Spawn("IntakeChinookPilot",this.Pos.x+3.5,this.Pos.y+0.6)
				Set(MyGuard,"HomeUID",this.HomeUID)
				Set(MyPilot,"HomeUID",this.HomeUID)
				Object.ApplyVelocity(MyGuard,1.5,0,true)
				Object.ApplyVelocity(MyPilot,-1.5,0,true)
				timePerUpdate = 1.2
				Set(this,"PilotToDoorA",true)
			elseif not this.DeployedPilot then
				if not this.PilotOutside then
					print("move pilot and guard b")
					if Exists(MyPilot) then MyPilot.NavigateTo(this.Pos.x+1+(math.random(10,75)/100),this.Pos.y+2) end
					if Exists(MyGuard) then MyGuard.NavigateTo(this.Pos.x+1+(math.random(10,75)/100),this.Pos.y+2) end
					Set(this,"PilotOutside",true)
				else
					print("move pilot and guard c")
					if Exists(MyPilot) then MyPilot.ClearRouting(); MyPilot.NavigateTo(this.Pos.x+6,this.Pos.y+3) end
					if Exists(MyGuard) then MyGuard.ClearRouting(); MyGuard.NavigateTo(this.Pos.x+5.25,this.Pos.y+3) end
					Set(this,"PilotToDoor",false)
					timePerUpdate = 3
					Set(this,"DeployedPilot",true)
					Set(this,"VehicleState","Processing")
					VehicleState = "Processing"
					this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
					Set(this,"HookNr",1)
				end
				return
			end
	-------------------------------------------------------------------------------------------
	-- Put Guard / Pilot back inside and close the doors
	-------------------------------------------------------------------------------------------
		elseif VehicleState == "GuardAndPilotIn" then				
			if not this.PilotToDoorL then
				timePerUpdate = 1
				if Exists(MyPilot) then MyPilot.NavigateTo(this.Pos.x+2+(math.random(10,75)/100),this.Pos.y+3) end
				if Exists(MyGuard) then MyGuard.NavigateTo(this.Pos.x+1+(math.random(20,75)/100),this.Pos.y+3) end
				Set(this,"PilotToDoorL",true)
			elseif not this.PilotToInside then
				if Exists(MyPilot) then MyPilot.NavigateTo(this.Pos.x+2.5,this.Pos.y+0.25) end
				if Exists(MyGuard) then MyGuard.NavigateTo(this.Pos.x+1.5,this.Pos.y+0.25) end
				if not Exists(MyPilot) then 
					Set(this,"PilotToInside",true)
				elseif MyPilot.Pos.y <= this.Pos.y+0.6 then
					Set(this,"PilotToInside",true)
					if Exists(MyPilot) then MyPilot.NavigateTo(this.Pos.x+5.85,this.Pos.y+0.6) end
					if Exists(MyGuard) then MyGuard.NavigateTo(this.Pos.x-1.5,this.Pos.y+0.6) end
					timePerUpdate = 1.5
				end
			elseif not this.DoorsSpawnedL then	-- spawn dummy doors
				if Exists(MyGuard) then MyGuard.Delete() end
				if Exists(MyPilot) then MyPilot.Delete() end
				this.SubType = SubTypes[SkinType][3]
				doorLeft=Object.Spawn("IntakeChinookDoor",this.Pos.x+0.35,this.Pos.y+0.29)
				Set(doorLeft,"HomeUID",this.HomeUID)
				Set(doorLeft,"Left",true)
				doorRight=Object.Spawn("IntakeChinookDoor",this.Pos.x+3.7,this.Pos.y+0.29)
				Set(doorRight,"HomeUID",this.HomeUID)
				Set(doorRight,"Right",true)
				Set(this,"DoorsSpawnedL",true)
				timePerUpdate = 0
			elseif not this.DoorsClosed then
				timePerUpdate = 0
				if not Exists(doorLeft) then FindMyDoors() end
				if doorLeft.Pos.x <= this.Pos.x+1.485 then
					doorLeft.Pos.x = doorLeft.Pos.x+0.005
					doorRight.Pos.x = doorRight.Pos.x-0.005
				else
					doorLeft.Delete()
					doorRight.Delete()
					this.SubType = SubTypes[SkinType][1]
					Set(this,"VehicleState","TakeOff")
					VehicleState = "TakeOff"
					this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
					timePerUpdate = 0.35
					Set(this,"DoorsClosed",true)
				end
			end
	-------------------------------------------------------------------------------------------
	-- Drop off the firemen and wait for them to return to the chinook
	-------------------------------------------------------------------------------------------
		elseif VehicleState == "DeployFiremen" then
			if not Exists(MyEntity1) then FindMyCalloutEntities(9) end
			if not this.HoseDeployed then														-- chinook on the ground, so deploy a hose for each firemen and do funky stuff:
				xyHose = Object.Spawn("HoseXY",this.Pos.x+1,this.Pos.y+2.5)						-- attach them to a temporary object to get some properly aligned hoses attached to the chinook... dafuq?
				Set(xyHose,"HomeUID",this.HomeUID)
				for H = 1,8 do
					MyEntities[H].FireEngine.i = xyHose.Id.i									-- ...because something looks very hardcoded and measured to fit at the normal Firetruck sprite here...
					MyEntities[H].FireEngine.u = xyHose.Id.u									-- ...as the hose will spawn a few tiles above this object, just about half the length of the firetruck perhaps (?)
					MyEntities[H].HoseOffset.HoseOffsetMetaTable.HoseOffsetSetterTable.x = 0	-- anyway it looks neater this way, otherwise the hose would spawn somewhere in the topback of the chinook
					MyEntities[H].HoseOffset.HoseOffsetMetaTable.HoseOffsetSetterTable.y = 0	-- changing these values doesn't seem to do anything, as long as it's set it will deploy a hose (?)
				end

				FindMyFireEngineBlocks()
				
				Set(this,"HoseDeployed",true)
			elseif not this.FiremenOutside then
				if not this.SlotsUnloaded then
					for S=0,7 do
						Set(this,"Slot"..S..".i",-1)
						Set(this,"Slot"..S..".u",-1)
						Set(MyEntities[S+1],"CarrierId.i",-1)
						Set(MyEntities[S+1],"CarrierId.u",-1)
						MyEntities[S+1].Loaded = false
					end
					Set(this,"SlotsUnloaded",true)
				elseif not this.GroupAOutside then
					for A = 1,4 do
						MyEntities[A].ClearRouting()
						MyEntities[A].AiSetTarget = false
						-- start PA 2018 code
						-- MyEntities[A].NavigateTo(MyEntities[A].Pos.x,MyEntities[A].Pos.y+2.5)
						-- finish PA 2018 code
						
						-- start PA Rock code
						MyEntities[A].PlayerOrderPos.x = MyEntities[A].Pos.x
						MyEntities[A].PlayerOrderPos.y = MyEntities[A].Pos.y+2.5
						-- finish PA Rock code
					end
					Set(this,"GroupAOutside",true)
				elseif not this.GroupBOutside then
					for B = 5,8 do
						MyEntities[B].ClearRouting()
						MyEntities[B].AiSetTarget = false
						-- start PA 2018 code
						-- MyEntities[B].NavigateTo(MyEntities[B].Pos.x,MyEntities[B].Pos.y+2.25)
						-- finish PA 2018 code
						
						-- start PA Rock code
						MyEntities[B].PlayerOrderPos.x = MyEntities[B].Pos.x
						MyEntities[B].PlayerOrderPos.y = MyEntities[B].Pos.y+2.25
						-- finish PA Rock code
					end
					Set(this,"GroupBOutside",true)
				else
					Set(this,"VehicleState","SwapFireEngine")
					VehicleState = "SwapFireEngine"
					this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
					Set(this,"FiremenOutside",true)
				end
			end
		elseif VehicleState == "SwapFireEngine" then	-- Attach the firemen back to me, the REAL FireEngine, instead of my dummy FireEngine where the hooks looks much better on when it's attached...
													--   ...so I can check when my firemen are done with their job and want to go home with me instead of my hose spawner.
			if not this.FireEngineSwapped then
				for F = 1,8 do
					MyEntities[F].FireEngine.i = this.Id.i
					MyEntities[F].FireEngine.u = this.Id.u
				end
				if not Exists(xyHose) then FindMyHose() end
				if Exists(xyHose) then xyHose.Delete() end
				Set("FireEngineSwapped",true)
			else
				Set(this,"VehicleState","WaitForFiremen")
				VehicleState = "WaitForFiremen"
				this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
			end
		elseif VehicleState == "WaitForFiremen" then
			if not Exists(MyEntity1) then FindMyCalloutEntities(10000) end
			if not this.FiremenAreBack then
				timePerUpdate = 5
				local FiremenBackOrDead = { [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false, [8] = false }
				for B = 1,8 do
					if MyEntities[B].Energy ~= nil and MyEntities[B].Damage < 1 then
						if MyEntities[B].Loaded or MyEntities[B].LeavingMap then
							FiremenBackOrDead[B] = true
						end
					else
						FiremenBackOrDead[B] = true
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
					if not Exists(blockLeft) then FindMyFireEngineBlocks() end
					blockLeft.Delete()
					timePerUpdate = 0.016
					print("FiremenAreBack")
					Set(this,"FiremenAreBack",true)
				end
			elseif not this.HoseRemoved then 	-- setting the FireEngine.i and .u values to -1 makes the hose disappear. No idea if this is the correct way to handle it, but it works :)
				for H = 1,8 do
					if Exists(MyEntities[H]) then
						MyEntities[H].FireEngine.i = -1
						MyEntities[H].FireEngine.u = -1
					end
				end
				Set(this,"HoseRemoved",true)
			else
				Set(this,"VehicleState","TakeOff")
				VehicleState = "TakeOff"
				this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
			end	
		end
	end
end


	-------------------------------------------------------------------------------------------
	-- Move the chinook
	-------------------------------------------------------------------------------------------
function AtDest(theX,theY,r)
    if -r <= theX-Get(this,"Pos.x") and theX-Get(this,"Pos.x") <= r then
        return true
    end
    return false
end

function GoUp(theY,speed,dT)
	if IsIntake then
		local difY = theY - MyInside.Pos.y
		if difY > 0.3 then
			MyInside.Pos.y = MyInside.Pos.y + speed * dT
		elseif difY < -0.3 then
			MyInside.Pos.y = MyInside.Pos.y - speed * dT
		end
	else
		local difY = theY - this.Pos.y
		if difY > 0.3 then
			this.Pos.y = this.Pos.y + speed * dT
			if Exists(MyHook1) then
				if MyHook1.Pos.y > this.Pos.y-0.22 then MyHook1.Pos.y = MyHook1.Pos.y + speed * (dT+0.005) else MyHook1.Pos.y = this.Pos.y-0.22 end
				MyHook2.Pos.y = MyHook1.Pos.y
			end
		elseif difY < -0.3 then
			this.Pos.y = this.Pos.y - speed * dT
			if Exists(MyHook1) then
				if MyHook1.Pos.y > this.Pos.y-0.22 then MyHook1.Pos.y = MyHook1.Pos.y - speed * (dT+0.005) else MyHook1.Pos.y = this.Pos.y-0.22 end
				MyHook2.Pos.y = MyHook1.Pos.y
			end
		end
	end
end

function GoDown(theY,speed,dT)
	if IsIntake then
		local difY = theY + MyInside.Pos.y
		if difY > 0.3 then
			MyInside.Pos.y = MyInside.Pos.y + speed * dT
		elseif difY < -0.3 then
			MyInside.Pos.y = MyInside.Pos.y - speed * dT
		end
	else
		local difY = theY + this.Pos.y
		if difY > 0.3 then
			this.Pos.y = this.Pos.y + speed * dT
			if Exists(MyHook1) then
				if MyHook1.Pos.y < this.Pos.y+0.42 then MyHook1.Pos.y = MyHook1.Pos.y + speed * (dT+0.008) else MyHook1.Pos.y = this.Pos.y+0.42 end
				MyHook2.Pos.y = MyHook1.Pos.y
			end
		elseif difY < -0.3 then
			this.Pos.y = this.Pos.y - speed * dT
			if Exists(MyHook1) then
				if MyHook1.Pos.y < this.Pos.y+0.42 then MyHook1.Pos.y = MyHook1.Pos.y - speed * (dT+0.008) else MyHook1.Pos.y = this.Pos.y+0.42 end
				MyHook2.Pos.y = MyHook1.Pos.y
			end
		end
	end
end
  
function GoTo(theX,theY,speed,dT)
    --Move left and right
	if IsIntake then
		local difX = theX - MyInside.Pos.x
		local difY = theY - MyInside.Pos.y
		
		--Move left and right
		if difX > 0.3 then
			MyInside.Pos.x = MyInside.Pos.x + speed * dT
		elseif difX < -0.3 then
			MyInside.Pos.x = MyInside.Pos.x - speed * dT
		end
	   
		xMagnitude = math.abs(difX)
		if xMagnitude > 0.5 then
			if xMagnitude > 35 and difY < 4 then
				MyInside.Pos.y = MyInside.Pos.y - 0.4 * dT
			else        
			--this sends it down when approaching helipad
				if difY > 0.3 then
					MyInside.Pos.y = MyInside.Pos.y + difY/xMagnitude * dT;
				elseif difY < -0.3 then
					MyInside.Pos.y = MyInside.Pos.y - difY/xMagnitude *dT;
				end
			end
		end
	else
		local difX = theX - this.Pos.x
		local difY = theY - this.Pos.y
	
		if difX > 0.3 then
			this.Pos.x = this.Pos.x + speed * dT;
		elseif difX < -0.3 then
			this.Pos.x = this.Pos.x - speed * dT;
		end
	   
		xMagnitude = math.abs(difX)
		if xMagnitude > 0.5 then
			if xMagnitude > 35 and difY < 4 then
				this.Pos.y = this.Pos.y - 0.4 * dT;
			else        
			--this sends it down when approaching helipad
				if difY > 0.3 then
					this.Pos.y = this.Pos.y + difY/xMagnitude * dT;
				elseif difY < -0.3 then
					this.Pos.y = this.Pos.y - difY/xMagnitude *dT;
				end
			end
		end
	end
end


	-------------------------------------------------------------------------------------------
	-- Find stuff
	-------------------------------------------------------------------------------------------
	
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

function FindMyHelipad(theDist)
	print("FindMyHelipad")
	local Helipads = { "CalloutHelipad", "CargoHelipad" }
	for T, typ in pairs(Helipads) do
		local nearbyObjects = Find(this,typ,theDist)
		for thatHelipad, distance in pairs(nearbyObjects) do
			if thatHelipad.HomeUID == this.HeliPadID then
				MyHelipad = thatHelipad
				print("MyHelipad found at "..distance)
				break
			end
		end
	end
	nearbyObject = nil
	if not Exists(MyHelipad) then
		print(" -- ERROR --- MyHelipad not found")
	end
end

function FindMyExportsHook()
	print("FindMyExportsHook")
	local nearbyObjects = Find(this,this.MyType.."ChinookHook",9) -- can be Exports or Emergency hook
	if next(nearbyObjects) then
		for thatHook, distance in pairs(nearbyObjects) do 
			if thatHook.HomeUID == this.HeliPadID then
				if thatHook.HookNr == 1 then MyHook1 = thatHook; print("MyExportsHook1 found at "..distance)
				elseif thatHook.HookNr == 2 then MyHook2 = thatHook; print("MyExportsHook2 found at "..distance)
				end
			end
		end
		nearbyObject = nil
	end
	if not Exists(MyHook1) then
		print(" -- ERROR --- MyExportsHook1 not found")
	end
	if not Exists(MyHook2) then
		print(" -- ERROR --- MyExportsHook2 not found")
	end
end

function FindMyIntakeHook(theHookNr)
	TheCargoAmount = 0
	local nearbyObject = Find(this,"IntakeChinookHook",9)
	if next(nearbyObject) then
		for thatHook, distance in pairs(nearbyObject) do
			if thatHook.HomeUID == this.HomeUID then
				if thatHook.HookNr == 1 then MyHook1 = thatHook; print("MyHook1 found at "..distance)
				elseif thatHook.HookNr == 2 then MyHook2 = thatHook; print("MyHook2 found at "..distance)
				end
			end
		end
	end
	nearbyObject = nil
	if theHookNr == 1 and Exists(MyHook1) then
		if MyHook1.Loaded == true then
			MyHook = MyHook1
			MyInside.Slot4.i = -1
			MyInside.Slot4.u = -1
			MyHook.CarrierId.i = -1
			MyHook.CarrierId.u = -1
			MyHook.Loaded = false
			Object.ApplyVelocity(MyHook,4,0,false)
		end
	elseif theHookNr == 2 and Exists(MyHook2) then
		if MyHook2.Loaded == true then
			MyHook = MyHook2
			MyInside.Slot5.i = -1
			MyInside.Slot5.u = -1
			MyHook.CarrierId.i = -1
			MyHook.CarrierId.u = -1
			MyHook.Loaded = false
			Object.ApplyVelocity(MyHook,4,0,false)
		end
	end
	if not Exists(MyHook) then
		print(" -- ERROR --- MyHook"..theHookNr.." not found")
	else
		TheCargoAmount = Get(MyHook,"CargoAmount")
	end
end

function FindMyDoors()
	local nearbyObject = Find(this,"IntakeChinookDoor",9)
	if next(nearbyObject) then
		for thatDoor, distance in pairs(nearbyObject) do
			if thatDoor.HomeUID == this.HomeUID then
				if thatDoor.Left == true then doorLeft = thatDoor; print("Left door found at "..distance)
				elseif thatDoor.Right == true then doorRight = thatDoor; print("Right door found at "..distance)
				end
			end
		end
	end
	nearbyObject = nil
	if not Exists(doorLeft) then
		print(" -- ERROR --- Left door not found")
	end
	if not Exists(doorRight) then
		print(" -- ERROR --- Right door not found")
	end
end

function FindMyBlocks()
	local nearbyObject = Find(this,"IntakeChinookBlock",9)
	if next(nearbyObject) then
		for thatBlock, distance in pairs(nearbyObject) do
			if thatBlock.HomeUID == this.HomeUID then
				if thatBlock.Left == true then blockLeft = thatBlock; print("Left block found at "..distance)
				elseif thatBlock.Right == true then blockRight = thatBlock; print("Right block found at "..distance)
				end
			end
		end
	end
	nearbyObject = nil
	if not Exists(blockLeft) then
		print(" -- Left block spawned")
		-- start PA 2018 code
		-- blockLeft = Object.Spawn("IntakeChinookBlock",this.Pos.x-1,this.Pos.y+0.5)
		-- finish PA 2018 code
		
		-- start PA Rock code
		blockLeft = Object.Spawn("IntakeChinookBlock",this.Pos.x-1,this.Pos.y-0.5)
		-- finish PA Rock code
		Set(blockLeft,"HomeUID",this.HomeUID)
		Set(blockLeft,"Left",true)
		Set(blockLeft,"Tooltip","tooltip_IntakeChinookBlock")
	end
	if not Exists(blockRight) then
		print(" -- Right block spawned")
		-- start PA 2018 code
		-- blockRight = Object.Spawn("IntakeChinookBlock",this.Pos.x+2,this.Pos.y+0.25)
		-- finish PA 2018 code
		
		-- start PA Rock code
		blockRight = Object.Spawn("IntakeChinookBlock",this.Pos.x+2,this.Pos.y-1.25)
		-- finish PA Rock code
		Set(blockRight,"HomeUID",this.HomeUID)
		Set(blockRight,"Right",true)
		Set(blockRight,"Tooltip","tooltip_IntakeChinookBlock")
	end
end

function FindMyParts()
	print("FindMyParts")
	
	if this.AnimateChinook == "yes" then IsAnimated = true end
	if this.MyType == "Cargo"			 then IsCargo = true
	elseif this.MyType == "Intake"		 then IsIntake = true
	elseif this.MyType == "Exports"		 then IsExports = true
	elseif this.MyType == "Emergency"	 then IsHearse = true
	elseif this.IsCallOut == true		 then IsCallOut = true
	end
	if this.FlyBy == true				 then FlyBy = true end
	SkinType = this.MyType
	this.SubType = SubTypes[SkinType][1]
	VehicleState = this.VehicleState
	edgeX = this.EdgeX
	edgeY = this.EdgeY
	padX = this.PadX
	padY = this.PadY

	if not IsCallOut then
	
		if IsIntake then
			local nearbyObject = Find(this,"IntakeChinookInside",4)
			if next(nearbyObject) then
				for thatInside, distance in pairs(nearbyObject) do
					if thatInside.HomeUID == this.HomeUID then
						MyInside = thatInside
						print("MyInside found at "..distance)
						break
					end
				end
			end
			nearbyObject = nil
			if not Exists(MyInside) then
				print(" -- ERROR --- MyInside not found")
			end
			
		else
		
			local nearbyObjects = Find(this,this.MyType.."ChinookHook",9) -- can be Exports or Emergency hook
			if next(nearbyObjects) then
				for thatHook, distance in pairs(nearbyObjects) do
					if thatHook.HomeUID == this.HomeUID then
						if thatHook.HookNr == 1 then MyHook1 = thatHook; print("MyHook1 found at "..distance)
						elseif thatHook.HookNr == 2 then MyHook2 = thatHook; print("MyHook2 found at "..distance)
						end
					end
				end
			end
			nearbyObjects = nil
			if not Exists(MyHook1) then
				print(" -- MyHook1 not found")
			end
			if not Exists(MyHook2) then
				print(" -- MyHook2 not found")
			end
			
		end
		
		if IsAnimated then
		
			local nearbyObject = Find(this,"StatusLight",9)
			if next(nearbyObject) then
				for thatLight, distance in pairs(nearbyObject) do
					if thatLight.HomeUID == this.HomeUID then
						if thatLight.Spot == "Back" then MyBackLight = thatLight; print("MyBackLight found at "..distance)
						elseif thatLight.Spot == "Front" then MyFrontLight = thatLight; print("MyFrontLight found at "..distance)
						end
					end
				end
			end
			nearbyObject = nil
			if not Exists(MyBackLight) then
				print(" -- MyBackLight not found")
			end
			if not Exists(MyFrontLight) then
				print(" -- MyFrontLight not found")
			end
		end
	end
end


	-------------------------------------------------------------------------------------------
	-- Cargo routines
	------------------------------------------------------------------------------------------- 
	
function SwapRealDeliveries(theHook)
	print("---")
	print("SwapRealDeliveries "..theHook.HookNr)
	local RealBayFound = false
	if not Exists(MyTrafficTerminal) then FindMyTrafficTerminal() end
	local RealDeliveries = Find(MyTrafficTerminal,"TmpCargoTruckBay",5)
	for thatBay, dist in pairs(RealDeliveries) do
		if thatBay.HomeUID == this.HomeUID and thatBay.HookNr == theHook.HookNr then
			RealBay = thatBay
			RealBayFound = true
			print("RealBay "..theHook.HookNr.." found at "..dist)
			break
		end
	end
	if RealBayFound == true then
		local DummyBoxes = Find(theHook,"CargoDeliveries",3)
		for thatDummy, dist in pairs(DummyBoxes) do
			if thatDummy.HomeUID == this.HomeUID and thatDummy.HookNr == theHook.HookNr then
				print("DummyBox found at "..dist..", swap with empty packaging")
				local newEmptyPackage = Object.Spawn("CargoDeliveriesEmpty",thatDummy.Pos.x,thatDummy.Pos.y)
				newEmptyPackage.Tooltip = thatDummy.Tooltip.."\n -> Cargo delivered, this box gets dumped."
				thatDummy.Delete()
			end
		end
		tmpChinookHook = Object.Spawn("CargoChinookHook",theHook.Pos.x,theHook.Pos.y)
		Set(tmpChinookHook,"HookNr",theHook.HookNr)
		for D = 0,7 do
			if Get(RealBay,"Slot"..D..".i") > -1 then
				print("RealBox "..D.." found, swap with hook")
				Set(tmpChinookHook,"Slot"..D..".i",Get(RealBay,"Slot"..D..".i"))
				Set(tmpChinookHook,"Slot"..D..".u",Get(RealBay,"Slot"..D..".u"))
				Set(RealBay,"Slot"..D..".i",-1)
				Set(RealBay,"Slot"..D..".u",-1)
			end
		end
		RealBay.Delete()
		UnloadHook(tmpChinookHook)
	end
end
	
function UnloadHook(tmpHook)
	print("---")
	print("UnloadHook "..tmpHook.HookNr)
	local loadedStack=Find(tmpHook,"Stack",3)
	local loadedBox=Find(tmpHook,"Box",3)
	local loadedMail=Find(tmpHook,"MailSatchel",3)
	if next(loadedStack) then
		for thatStack, distance in pairs(loadedStack) do
			for A = 0,7 do
				if thatStack.Id.i == Get(tmpHook,"Slot"..A..".i") then
					print("Unloading stack "..A.." from tmpHook (dist: "..distance..")")
					Set(tmpHook,"Slot"..A..".i",-1)
					Set(tmpHook,"Slot"..A..".u",-1)
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
				if thatBox.Id.i == Get(tmpHook,"Slot"..A..".i") then
					print("Unloading box "..A.." from tmpHook (dist: "..distance..")")
					Set(tmpHook,"Slot"..A..".i",-1)
					Set(tmpHook,"Slot"..A..".u",-1)
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
				if thatMail.Id.i == Get(tmpHook,"Slot"..A..".i") then
					print("Unloading mail "..A.." from tmpHook (dist: "..distance..")")
					Set(tmpHook,"Slot"..A..".i",-1)
					Set(tmpHook,"Slot"..A..".u",-1)
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
	tmpHook.Delete()
end

function MoveStackBackToTerminal()											-- move incoming deliveries back to terminal
	local nearbyTowers = {}
	nearbyTowers = Find("TrafficTerminal",10000)
	if next(nearbyTowers) then
		for thatTower, distance in pairs(nearbyTowers) do
			MyTrafficTerminal = thatTower
			print("Found MyTrafficTerminal at distance "..distance)
			break
		end
		local NewDeliveriesFound = false
		local DummyBoxes = Find(this,"CargoDeliveries",6)
		for thatDummy, dist in pairs(DummyBoxes) do
			if thatDummy.HomeUID == this.HomeUID then
				thatDummy.Delete()
				NewDeliveriesFound = true
			end
		end
		if NewDeliveriesFound == true then	-- new deliveries method with CargoDeliveries boxes
			local RealDeliveries = Find(MyTrafficTerminal,"TmpCargoTruckBay",5)
			for thatBay, dist in pairs(RealDeliveries) do
				if thatBay.HomeUID == this.HomeUID then
					local S = math.random(0,7)
					thatBay.Pos.x,thatBay.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y-3
					thatBay.Delete()
				end
			end
		else						
			local loadedStack=Find(this,"Stack",6)
			local loadedBox=Find(this,"Box",6)
			local loadedMail=Find(this,"MailSatchel",6)
			if next(loadedStack) then
				for thatStack, distance in pairs(loadedStack) do
					local unloaded = false
					local S = 0
					for A = 0,7 do
						if thatStack.Id.i == Get(MyHook1,"Slot"..A..".i") then
							print("Unloading stack "..A.." from MyHook1")
							Set(MyHook1,"Slot"..A..".i",-1)
							Set(MyHook1,"Slot"..A..".u",-1)
							unloaded = true
							S = A
							break
						elseif thatStack.Id.i == Get(MyHook2,"Slot"..A..".i") then
							print("Unloading stack "..A.." from MyHook2")
							Set(MyHook2,"Slot"..A..".i",-1)
							Set(MyHook2,"Slot"..A..".u",-1)
							unloaded = true
							S = A
							break
						end
					end
					if unloaded == true then
						print("Transferring stack to MyTrafficTerminal")
						Set(thatStack,"CarrierId.i",-1)
						Set(thatStack,"CarrierId.u",-1)
						Set(thatStack,"Loaded",false)
						if math.random() > 0.75 then
							thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y-3
						elseif math.random() > 0.5 then
							thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y-1
						elseif math.random() > 0.25 then
							thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y
						else
							thatStack.Pos.x,thatStack.Pos.y = MyTrafficTerminal.Pos.x-3.5+S,MyTrafficTerminal.Pos.y+1
						end
						thatStack = nil
					end
				end
			end
			if next(loadedBox) then
				for thatBox, distance in pairs(loadedBox) do
					local unloaded = false
					local S = 0
					for A = 0,7 do
						if thatBox.Id.i == Get(MyHook1,"Slot"..A..".i") then
							print("Unloading box "..A.." from MyHook1")
							Set(MyHook1,"Slot"..A..".i",-1)
							Set(MyHook1,"Slot"..A..".u",-1)
							unloaded = true
							S = A
							break
						elseif thatBox.Id.i == Get(MyHook2,"Slot"..A..".i") then
							print("Unloading box "..A.." from MyHook2")
							Set(MyHook2,"Slot"..A..".i",-1)
							Set(MyHook2,"Slot"..A..".u",-1)
							unloaded = true
							S = A
							break
						end
					end
					if unloaded == true then
						print("Transferring stack to MyTrafficTerminal")
						Set(thatBox,"CarrierId.i",-1)
						Set(thatBox,"CarrierId.u",-1)
						Set(thatBox,"Loaded",false)
						if math.random() > 0.75 then
							thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y+1
						elseif math.random() > 0.5 then
							thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y
						elseif math.random() > 0.25 then
							thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y-1
						else
							thatBox.Pos.x,thatBox.Pos.y = MyTrafficTerminal.Pos.x+2.5-S,MyTrafficTerminal.Pos.y-3
						end
						thatBox = nil
					end
				end
			end
			if next(loadedMail) then
				for thatMail, distance in pairs(loadedMail) do
					local unloaded = false
					for A = 0,7 do
						if thatMail.Id.i == Get(MyHook1,"Slot"..A..".i") then
							Set(MyHook1,"Slot"..A..".i",-1)
							Set(MyHook1,"Slot"..A..".u",-1)
							unloaded = true
							break
						elseif thatMail.Id.i == Get(MyHook2,"Slot"..A..".i") then
							Set(MyHook2,"Slot"..A..".i",-1)
							Set(MyHook2,"Slot"..A..".u",-1)
							unloaded = true
							break
						end
					end
					if unloaded == true then
						Set(thatMail,"CarrierId.i",-1)
						Set(thatMail,"CarrierId.u",-1)
						Set(thatMail,"Loaded",false)
						thatMail.Pos.x,thatMail.Pos.y = MyTrafficTerminal.Pos.x-4.5+math.random(1,8),MyTrafficTerminal.Pos.y+3
						thatMail = nil
						break
					end
				end
			end
			local loadedCargoGarbage=Find(this,"CargoGarbage",6)
			for thatGarbage, distance in pairs(loadedCargoGarbage) do
				if thatGarbage.CarrierId.i == MyHook1.Id.i or thatGarbage.CarrierId.i == MyHook2.Id.i then
					thatGarbage.Delete()
				end
			end
		end
	end
	if not Exists(MyHelipad) then FindMyHelipad(10000) end
	if Exists(MyHelipad) then
		Set(MyHelipad,"InUse","no")
		Set(MyHelipad,"VehicleSpawned","no")
		Set(MyHelipad,"Status","Waiting...")
		Set(MyHelipad,"BuildingQuantity",0)
		Set(MyHelipad,"FloorsQuantity",0)
		Set(MyHelipad,"LaundryQuantity",0)
		Set(MyHelipad,"FoodQuantity",0)
		Set(MyHelipad,"ForestQuantity",0)
		Set(MyHelipad,"VendingQuantity",0)
		Set(MyHelipad,"Workshop1Quantity",0)
		Set(MyHelipad,"Workshop2Quantity",0)
		Set(MyHelipad,"Workshop3Quantity",0)
		Set(MyHelipad,"Workshop4Quantity",0)
		Set(MyHelipad,"Workshop5Quantity",0)
		Set(MyHelipad,"OtherQuantity",0)
		Set(MyHelipad,"AllQuantity",0)
		MyHelipad.Tooltip = { "tooltip_CargoHelipad",MyHelipad.HomeUID,"Y",MyHelipad.Number,"Z" }
	end

	if Exists(MyInside) then MyInside.Delete() end
	if Exists(MyHook1) then MyHook1.Delete() end
	if Exists(MyHook2) then MyHook2.Delete() end
	if Exists(MyBackLight) then MyBackLight.Delete() end
	if Exists(MyFrontLight) then MyFrontLight.Delete() end
	this.Delete()
end

	-------------------------------------------------------------------------------------------
	-- Exports routines
	------------------------------------------------------------------------------------------- 
function FillUpHook(theHook)
	for F = 0,7 do
		if Get(theHook,"Slot"..F..".i") == -1 then
			local NewStackHolder = Object.Spawn("PrisonerStackHolder",theHook.Pos.x,theHook.Pos.y)
			Set(NewStackHolder,"Tooltip","Contents: dummyload")
			Set(theHook,"Slot"..F..".i",NewStackHolder.Id.i)
			Set(theHook,"Slot"..F..".u",NewStackHolder.Id.u)
			Set(NewStackHolder,"CarrierId.i",theHook.Id.i)
			Set(NewStackHolder,"CarrierId.u",theHook.Id.u)
			Set(NewStackHolder,"Loaded",true)
			NewStackHolder = nil
		end
	end
end

function SpawnSupplyTruck(theHook)
	local NewSupplyTruck = Object.Spawn("SupplyTruck",World.NumCellsX-1,World.NumCellsY-4+math.random()+math.random())
	Set(NewSupplyTruck,"StackTransferred",true)
	Set(NewSupplyTruck,"State","Leaving")
	Set(NewSupplyTruck,"Hidden",true)
	for H = 0,7 do
		if Get(theHook,"Slot"..H..".i") > -1 then
			Set(NewSupplyTruck,"Slot"..H..".i",Get(theHook,"Slot"..H..".i"))
			Set(NewSupplyTruck,"Slot"..H..".u",Get(theHook,"Slot"..H..".u"))
			Set(theHook,"Slot"..H..".i",-1)
			Set(theHook,"Slot"..H..".u",-1)
			local newExports = Object.Spawn("CargoExports",theHook.Pos.x,theHook.Pos.y)	-- spawn dummy boxes for export
			Set(newExports,"HomeUID",this.HomeUID)
			Set(theHook,"Slot"..H..".i",newExports.Id.i)
			Set(theHook,"Slot"..H..".u",newExports.Id.u)
			Set(newExports,"CarrierId.i",theHook.Id.i)
			Set(newExports,"CarrierId.u",theHook.Id.u)
			newExports.Loaded = true
			newExports.Tooltip = "Cargo ready for exports"
		end
	end
	NewSupplyTruck.Speed = 5
end


	-------------------------------------------------------------------------------------------
	-- Intake routines
	------------------------------------------------------------------------------------------- 
function UnloadPrisonersFromChinook()
	print("---")
	print("UnloadPrisonersFromChinook "..this.HookNr)
	if not Exists(blockLeft) then FindMyBlocks() end
	if not Exists(MyHook) then FindMyIntakeHook(this.HookNr) return end
	if not Exists(MyHelipad) then FindMyHelipad(9) end
	if Exists(MyHook) and Exists(MyHelipad) then
		print("MyHook "..this.HookNr.." holds "..MyHook.CargoAmount.." prisoners")
		if TheCargoAmount > 0 then
			for L = 0,7 do
				Object.ApplyVelocity(MyHook,(math.random(25,75) / 100),0,false)
				if Get(MyHook,"CargoLoad"..L) == MyHelipad.Id.u then
					print("Process MyHook slot "..L..": "..Get(MyHook,"CargoLoad"..L))
					local foundH = false
					local MyPrisonerHolders = Find(MyHook,"PrisonerStackHolder",6)
					if next(MyPrisonerHolders) then
						for thatPrisonerHolder, dist in pairs(MyPrisonerHolders) do
							if Get(thatPrisonerHolder,"SlingShotToOutside") == true then
								local Prisoners = Find(thatPrisonerHolder,"Prisoner",1)
								for thatPrisoner, dist in pairs(Prisoners) do
									if thatPrisoner.Id.i == Get(thatPrisonerHolder,"Slot0.i") then
										Set(thatPrisonerHolder,"Slot0.i",-1)
										Set(thatPrisonerHolder,"Slot0.u",-1)
										Set(thatPrisoner,"CarrierId.i",-1)
										Set(thatPrisoner,"CarrierId.u",-1)
										Set(thatPrisoner,"Loaded",false)
										Set(thatPrisoner,"Locked",false)
										if MyHelipad.IsIntake == "yes" then
											Set(thatPrisoner,"IsNewIntake",true)
										end
										print("SlingShotToOutside done Prisoner "..L)
									end
								end
								Prisoners = nil
								thatPrisonerHolder.Delete()
								foundH = true
								Set(MyHook,"CargoLoad"..L,0)
								Set(MyHook,"CargoAmount",MyHook.CargoAmount - 1)
								break
							elseif thatPrisonerHolder.Id.i == Get(MyHook,"Slot"..L..".i") then
								print("Unload Prisoner "..L)
								Set(MyHook,"Slot"..L..".i",-1)
								Set(MyHook,"Slot"..L..".u",-1)
								Set(thatPrisonerHolder,"CarrierId.i",-1)
								Set(thatPrisonerHolder,"CarrierId.u",-1)
								Set(thatPrisonerHolder,"Loaded",false)
								Set(thatPrisonerHolder,"Or.x",0)
								Set(thatPrisonerHolder,"HomeUID",this.HomeUID)
								Set(thatPrisonerHolder,"SlingShotToOutside",true)
								local X = (math.random(10,90) / 100) + (math.random(10,90) / 100) + (math.random(10,90) / 100)
								local Y = math.random(50,75) / 10
								if math.random() <= 0.50 then X = -X end
								Object.ApplyVelocity(thatPrisonerHolder,X,Y,false)
								print("SlingShotToOutside "..L)
								foundH = true
								break
							end
						end
						if foundH == false then	-- to prevent looping in case something went wrong
							Set(MyHook,"CargoAmount",0)
							TheCargoAmount = 0
						end
					else	-- to prevent looping in case something went wrong
						Set(MyHook,"CargoAmount",0)
						TheCargoAmount = 0
					end
					break
				else
					print("Ignore MyHook slot "..L..", is empty")
				end
			end
		end
		if Get(MyHook,"CargoAmount") <= 0 then
			if Get(this,"HookNr") == 1 then
				MyHook = nil
				Set(this,"HookNr",2)
				FindMyIntakeHook(2)
				if TheCargoAmount == 0 then
					Set(this,"HookNr",0)
				end
			else
				Set(this,"HookNr",0)
			end
		end
	else
		if Get(this,"HookNr") == 1 then
			MyHook = nil
			Set(this,"HookNr",2)
			FindMyIntakeHook(2)
			if TheCargoAmount == 0 then
				Set(this,"HookNr",0)
			end
		else
			Set(this,"HookNr",0)
		end
	end
	if Get(this,"HookNr") == 0 then
		Set(this,"PrisonerIntakeDone",true)
	end
end

function MovePrisonersBackToTerminal()							-- move arriving prisoners back to terminal
	local nearbyTowers = {}
	nearbyTowers = Find("TrafficTerminal",10000)
	if next(nearbyTowers) then
		for thatTower, distance in pairs(nearbyTowers) do
			MyTrafficTerminal = thatTower
			break
		end
		if not Exists(MyHook1) then FindMyIntakeHook(1) end
		if not Exists(MyHook2) then FindMyIntakeHook(2) end
		local loadedPrisoners=Find(this,"PrisonerStackHolder",5)
		for thatPrisonerHolder, distance in pairs(loadedPrisoners) do
			if thatPrisonerHolder.CarrierId.i == MyHook1.Id.i or thatPrisonerHolder.CarrierId.i == MyHook2.Id.i then
				print("Loaded "..thatPrisonerHolder.HolderCategory.." prisoner ID "..thatPrisonerHolder.Slot0.i.." back to terminal")
				Set(thatPrisonerHolder,"CarrierId.i",-1)
				Set(thatPrisonerHolder,"CarrierId.u",-1)
				Set(thatPrisonerHolder,"Loaded",false)
				Set(thatPrisonerHolder,"Pos.y",MyTrafficTerminal.Pos.y+2)
				Set(thatPrisonerHolder,"Pos.x",MyTrafficTerminal.Pos.x-3)
			end
		end
		for H = 0,7 do
			Set(MyHook1,"Slot"..H..".i",-1)
			Set(MyHook1,"Slot"..H..".u",-1)
			Set(MyHook2,"Slot"..H..".i",-1)
			Set(MyHook2,"Slot"..H..".u",-1)
		end
	end
	if not Exists(MyHelipad) then FindMyHelipad(10000) end
	if Exists(MyHelipad) then
		Set(MyHelipad,"InUse","no")
		Set(MyHelipad,"VehicleSpawned","no")
		Set(MyHelipad,"Status","Waiting...")
		Set(MyHelipad,"MinSecQuantity",0)
		Set(MyHelipad,"NormalQuantity",0)
		Set(MyHelipad,"MaxSecQuantity",0)
		Set(MyHelipad,"SuperMaxQuantity",0)
		Set(MyHelipad,"ProtectedQuantity",0)
		Set(MyHelipad,"DeathRowQuantity",0)
		Set(MyHelipad,"InsaneQuantity",0)
		Set(MyHelipad,"PrisQuantity",0)
		MyHelipad.Tooltip = { "tooltip_CargoHelipad",MyHelipad.HomeUID,"Y",MyHelipad.Number,"Z" }
	end
	if not Exists(doorLeft) then FindMyDoors() end
	if Exists(doorLeft) then doorLeft.Delete() end
	if Exists(doorRight) then doorRight.Delete() end
	if not Exists(blockLeft) then FindMyBlocks() end
	if Exists(blockLeft) then blockLeft.Delete() end
	if Exists(blockRight) then blockRight.Delete() end
	if Exists(MyInside) then MyInside.Delete() end
	if Exists(MyHook1) then MyHook1.Delete() end
	if Exists(MyHook2) then MyHook2.Delete() end
	if Exists(MyGuard) then MyGuard.Delete() end
	if Exists(MyPilot) then MyPilot.Delete() end
	if Exists(MyBackLight) then MyBackLight.Delete() end
	if Exists(MyFrontLight) then MyFrontLight.Delete() end
	this.Delete()
end


	-------------------------------------------------------------------------------------------
	-- Emergency Call-Out routines
	------------------------------------------------------------------------------------------- 
function KeepEntitiesLoaded()
	if Exists(MyHelipad) and MyHelipad.Type == "CalloutHelipad" then
		if not FlyBy then
			for L = 0,7 do
				Set(this,"Slot"..L..".i",MyEntities[L+1].Id.i)
				Set(this,"Slot"..L..".u",MyEntities[L+1].Id.u)
				MyEntities[L+1].Equipment = MyHelipad.CalloutEquipment
			end
			if this.MyType == "Fireman" and MyHelipad.FiremanMethod == "FlyBy" and not FlyBy then
				for U = 0,7 do
					Set(this,"Slot"..U..".i",-1)
					Set(this,"Slot"..U..".u",-1)
					MyEntities[U+1].Loaded = false
				end
				Set(this,"FlyBy",true)
				FlyBy = true
			end
		else
			for L = 1,8 do
				MyEntities[L].Pos.x = this.Pos.x+EntitySpots[L]
				MyEntities[L].Pos.y = this.Pos.y+0.5
				MyEntities[L].Equipment = MyHelipad.CalloutEquipment
			end
			if this.MyType == "Fireman" and MyHelipad.FiremanMethod == "DropOff" and FlyBy == true then this.FlyBy = nil; FlyBy = nil end
		end
	else
		if not FlyBy then
			for L = 0,7 do
				Set(this,"Slot"..L..".i",MyEntities[L+1].Id.i)
				Set(this,"Slot"..L..".u",MyEntities[L+1].Id.u)
			end
		else
			for L = 1,8 do
				MyEntities[L].Pos.x = this.Pos.x+EntitySpots[L]
				MyEntities[L].Pos.y = this.Pos.y+0.5
			end
		end
	end
end

function FindCalloutHelipad()
	print("FindCalloutHelipad")
	local Helipads = { "CalloutHelipad" } --, "CargoHelipad" }
	for T, typ in pairs(Helipads) do
		print("Looking for "..Helipads[T])
		local nearbyObjects = Find(this,typ,10000)
		for thatHelipad, distance in pairs(nearbyObjects) do
			if thatHelipad.InUse == "no" and thatHelipad.TrafficEnabled == "yes" then
				MyHelipad = thatHelipad
				Set(MyHelipad,"InUse","yes")	-- moved to here
				if Helipads[T] == "CalloutHelipad" then
					Set(MyHelipad,"MyType",this.MyType)
				end
				print("Helipad found at "..distance..", using it for temporary call-out ("..this.MyType..")")
				break
			end
		end
	end
	nearbyObject = nil
	
	if not Exists(MyHelipad) then
		print(" -- No suitable Helipads found, arriving at map centre")
		local CentreX = World.NumCellsX/2
		local CentreY = World.NumCellsY/2
		MyHelipad = Object.Spawn("CalloutHelipad",CentreX,CentreY)
		Set(MyHelipad,"HomeUID","CalloutHelipad_"..string.sub(this.Id.u,-2))
		Set(MyHelipad,"Number",0)
		Set(MyHelipad,"Tooltip","tooltip_CalloutHelipad")
		Set(MyHelipad,"MyType",this.MyType)
		Set(MyHelipad,"TrafficEnabled","yes")
		Set(MyHelipad,"FiremanMethod","FlyBy")
		Set(MyHelipad,"Current",1)
	end
	
	if this.MyType == "Fireman" and MyHelipad.FiremanMethod == "FlyBy" then
		for U = 0,7 do
			Set(this,"Slot"..U..".i",-1)
			Set(this,"Slot"..U..".u",-1)
			MyEntities[U+1].Loaded = false
		end
		Set(this,"FlyBy",true)
		FlyBy = true
	end
	Set(MyHelipad,"VehicleSpawned","yes")
	Set(MyHelipad,"Status","CALL-OUT")
	Set(this,"PadX",MyHelipad.Pos.x-0.5+math.random())
	Set(this,"PadY",MyHelipad.Pos.y-5+math.random())
	this.Pos.x = 4
	this.Pos.y = this.PadY
	Set(this,"HeliPadID",MyHelipad.HomeUID)
	Set(this,"EdgeX",World.NumCellsX - 6)
	Set(this,"EdgeY",this.PadY)
	Set(this,"AnimateChinook","no")
	Set(this,"VehicleState","ToHelipad")
	Set(this,"Number",MyHelipad.Number)
	VehicleState = "ToHelipad"
	print("PadX: "..this.PadX.." PadY: "..this.PadY.." HeliPadID: "..this.HeliPadID.." EdgeX: "..this.EdgeX.." EdgeY: "..this.EdgeY)
	this.Tooltip = { "tooltip_Chinook2_Status",this.HomeUID,"X",VehicleState,"Y" }
end

function InitMyCalloutEntities()
	print("InitMyCalloutEntities")
	local Init = false
	for T, typ in pairs(CalloutEntitiesToFind) do
		print("Looking for call-out "..CalloutEntitiesToFind[T])
		local nearbyObjects = Find(this,typ,9)
		for thatEntity, distance in pairs(nearbyObjects) do
			if this.Slot0.u == thatEntity.Id.u		 then MyEntity1 = thatEntity; MyEntities[1] = MyEntity1; print("MyEntity1 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot1.u == thatEntity.Id.u	 then MyEntity2 = thatEntity; MyEntities[2] = MyEntity2; print("MyEntity2 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot2.u == thatEntity.Id.u	 then MyEntity3 = thatEntity; MyEntities[3] = MyEntity3; print("MyEntity3 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot3.u == thatEntity.Id.u	 then MyEntity4 = thatEntity; MyEntities[4] = MyEntity4; print("MyEntity4 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot4.u == thatEntity.Id.u	 then MyEntity5 = thatEntity; MyEntities[5] = MyEntity5; print("MyEntity5 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot5.u == thatEntity.Id.u	 then MyEntity6 = thatEntity; MyEntities[6] = MyEntity6; print("MyEntity6 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot6.u == thatEntity.Id.u	 then MyEntity7 = thatEntity; MyEntities[7] = MyEntity7; print("MyEntity7 "..thatEntity.Type.." found at "..distance)
			elseif this.Slot7.u == thatEntity.Id.u	 then MyEntity8 = thatEntity; MyEntities[8] = MyEntity8; print("MyEntity8 "..thatEntity.Type.." found at "..distance)
			end
		end
		nearbyObjects = nil
		if Exists(MyEntity1) and Exists(MyEntity2) and Exists(MyEntity3) and Exists(MyEntity4) and Exists(MyEntity5) and Exists(MyEntity6) and Exists(MyEntity7) and Exists(MyEntity8) then
			Set(this,"MyType",CalloutEntitiesToFind[T])
			Set(this,"IsCallOut",true)
			Set(this,"HomeUID",this.MyType.."Chinook_"..string.sub(this.Id.u,-2))
			break
		end
	end
	if Exists(MyEntity1) and Exists(MyEntity2) and Exists(MyEntity3) and Exists(MyEntity4) and Exists(MyEntity5) and Exists(MyEntity6) and Exists(MyEntity7) and Exists(MyEntity8) then
		for I = 1,8 do
			Set(MyEntities[I],"HomeUID",this.HomeUID)
			Set(MyEntities[I],"Number",I)
			if this.MyType == "Fireman" then
				MyEntities[I].FireEngine.i = -1
				MyEntities[I].FireEngine.u = -1
			end
		end
		FindCalloutHelipad()
		Init = true
	else
		print("Waiting for my call-out entities to initialize...")
	end
	return Init
end

function FindMyCalloutEntities(theDist)
	print("FindMyCalloutEntities")
	for C, typ in pairs(CalloutEntitiesToFind) do
		print("Finding "..CalloutEntitiesToFind[C])
		local nearbyObjects = Find(this,typ,theDist)
		for thatEntity, distance in pairs(nearbyObjects) do
			if thatEntity.HomeUID == this.HomeUID then
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
			if thatHose.HomeUID == this.HomeUID then
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

function FindMyFireEngineBlocks()
	local nearbyObject = Find(this,"IntakeChinookBlock",9)
	if next(nearbyObject) then
		for thatBlock, distance in pairs(nearbyObject) do
			if thatBlock.HomeUID == this.HomeUID then
				blockLeft = thatBlock
				print("Block found at "..distance)
			end
		end
	end
	nearbyObject = nil
	if not Exists(blockLeft) then
		print(" -- Block spawned")
		blockLeft = Object.Spawn("IntakeChinookBlock",this.Pos.x-1,this.Pos.y+1.5)		
		Set(blockLeft,"HomeUID",this.HomeUID)
		Set(blockLeft,"Tooltip","Blocks left side of the chinook")
	end
end

function Exists(theObject)
	if theObject ~= nil and theObject.SubType ~= nil then
		return true
	else
		return false
	end
end
