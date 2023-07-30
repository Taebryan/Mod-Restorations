
local timeTot = 0
local Get = Object.GetProperty
local Set = Object.SetProperty

local SubTypes = {
		Fireman		 = { [1] = 0, [2] = 8, [3] = 1 },
		Paramedic	 = { [1] = 0, [2] = 8, [3] = 2 },
		Orderly		 = { [1] = 0, [2] = 8, [3] = 3 },
		RiotGuard	 = { [1] = 0, [2] = 8, [3] = 4 },
		ArmedGuard	 = { [1] = 0, [2] = 8, [3] = 5 },
		Soldier		 = { [1] = 0, [2] = 8, [3] = 6 },
		EliteOps	 = { [1] = 0, [2] = 8, [3] = 7 }
		}

local EquipmentTypes = {
		Fireman		 = { [1] = "Extinguisher", [2] = "Hose" },
		Paramedic	 = { [1] = "Needle" },
		Orderly		 = { [1] = "SedativeSyringe" },
		ArmedGuard	 = { [1] = "Shotgun", [2] = "AssaultRifle", [3] = "AK47", [4] = "Axe", [5] = "Baton", [6] = "BatteringRam", [7] = "Gun", [8] = "Knife", [9] = "Rifle", [10] = "SubMachineGun", [11] = "Tazer" },
		RiotGuard	 = { [1] = "Baton", [2] = "AssaultRifle", [3] = "AK47", [4] = "Axe", [5] = "BatteringRam", [6] = "Gun", [7] = "Knife", [8] = "Rifle", [9] = "Shotgun", [10] = "SubMachineGun", [11] = "Tazer" },
		Soldier		 = { [1] = "AssaultRifle", [2] = "Baton", [3] = "AK47", [4] = "Axe", [5] = "BatteringRam", [6] = "Gun", [7] = "Knife", [8] = "Rifle", [9] = "Shotgun", [10] = "SubMachineGun", [11] = "Tazer" },
		EliteOps	 = { [1] = "AssaultRifle", [2] = "Baton", [3] = "AK47", [4] = "Axe", [5] = "BatteringRam", [6] = "Gun", [7] = "Knife", [8] = "Rifle", [9] = "Shotgun", [10] = "SubMachineGun", [11] = "Tazer" }
		}

local EquipmentNumbers = {
		Fireman		 = { [1] = 0, [2] = 24 },
		Paramedic	 = { [1] = 9 },
		Orderly		 = { [1] = 0 },
		ArmedGuard	 = { [1] = 32, [2] = 45, [3] = 0, [4] = 43, [5] = 2, [6] = 48, [7] = 7, [8] = 5, [9] = 42, [10] = 46, [11] = 37 },
		RiotGuard	 = { [1] = 2, [2] = 45, [3] = 0, [4] = 43, [5] = 48, [6] = 7, [7] = 5, [8] = 42, [9] = 32, [10] = 46, [11] = 37 },
		Soldier		 = { [1] = 45, [2] = 2, [3] = 0, [4] = 43, [5] = 48, [6] = 7, [7] = 5, [8] = 42, [9] = 32, [10] = 46, [11] = 37 },
		EliteOps	 = { [1] = 45, [2] = 2, [3] = 0, [4] = 43, [5] = 48, [6] = 7, [7] = 5, [8] = 42, [9] = 32, [10] = 46, [11] = 37 }
		}
		
local CalloutEquipment

function Create()
end

function Update(timePassed)
	if timePerUpdate == nil then
		if this.HomeUID == nil then
			Set(this,"HomeUID","CalloutHelipad_"..string.sub(this.Id.u,-2))
			Set(this,"Tooltip","tooltip_CalloutHelipadA")
			Set(this,"Number",0)
			Set(this,"InUse","no")
			Set(this,"TrafficEnabled","yes")
			Set(this,"FiremanMethod","FlyBy")
		end
		timePerUpdate = 0.5
	end
	timeTot = timeTot+timePassed
	if timeTot >=timePerUpdate then
		timeTot = 0
		if this.MyType == nil then
			timePerUpdate = 0.33
			if this.SubType == 0 then this.SubType = 1
			elseif this.SubType == 1 then this.SubType = 2
			elseif this.SubType == 2 then this.SubType = 3
			elseif this.SubType == 3 then this.SubType = 4
			elseif this.SubType == 4 then this.SubType = 5
			elseif this.SubType == 5 then this.SubType = 6
			elseif this.SubType == 6 then this.SubType = 7
			elseif this.SubType == 7 then this.SubType = 8
			elseif this.SubType == 8 then this.SubType = 0
			end
		else
			if not ButtonsMade then
				MakeButtons()
			end
			timePerUpdate = 0.5
			if this.SubType == SubTypes[this.MyType][1] then
				this.SubType = SubTypes[this.MyType][2]
			elseif this.SubType == SubTypes[this.MyType][2] then
				this.SubType = SubTypes[this.MyType][3]
			else
				this.SubType = SubTypes[this.MyType][1]
			end
		end
	end
end

function MakeButtons()
	FindSomeEquipmentNumbers()
	if this.MyType == "Fireman" then
		Interface.AddComponent(this,"Separator"..this.Id.u.."A", "Caption", "tooltip_CalloutHelipad_SeparatorMethod")
		Interface.AddComponent(this,"toggleMethod", "Button", "tooltip_CalloutHelipad_Button_ToggleFiremanMethod","tooltip_CalloutHelipad_FiremanMethod_"..this.FiremanMethod,"X")
	end
	Interface.AddComponent(this,"Separator"..this.Id.u.."B", "Caption", "tooltip_CalloutHelipad_SeparatorEquipment")
	if this.CalloutEquipment == nil then
		Set(this,"Current",1)
		Set(this,"CalloutEquipment",EquipmentNumbers[this.MyType][this.Current])
		CalloutEquipment = EquipmentTypes[this.MyType][this.Current]
	else
		CalloutEquipment = EquipmentTypes[this.MyType][this.Current]
	end
	print(CalloutEquipment.." (number: "..this.CalloutEquipment..")")
	Interface.AddComponent(this,"toggleEquipment", "Button", "tooltip_CalloutHelipad_Button_ToggleCalloutEquipment","tooltip_CalloutHelipad_CalloutEquipment_"..CalloutEquipment,"X")
	SetTooltip()
	ButtonsMade = true
end

function toggleMethodClicked()
	if Get(this,"FiremanMethod") == "FlyBy" then
		Set(this,"FiremanMethod","DropOff")
		this.Current = 2
		Set(this,"CalloutEquipment",EquipmentNumbers[this.MyType][2])
		CalloutEquipment = EquipmentTypes[this.MyType][this.Current]
	else
		Set(this,"FiremanMethod","FlyBy")
		this.Current = 1
		Set(this,"CalloutEquipment",EquipmentNumbers[this.MyType][1])
		CalloutEquipment = EquipmentTypes[this.MyType][this.Current]
	end
	this.SetInterfaceCaption("toggleMethod", "tooltip_CalloutHelipad_Button_ToggleFiremanMethod","tooltip_CalloutHelipad_FiremanMethod_"..this.FiremanMethod,"X")
	this.SetInterfaceCaption("toggleEquipment", "tooltip_CalloutHelipad_Button_ToggleCalloutEquipment","tooltip_CalloutHelipad_CalloutEquipment_"..CalloutEquipment,"X")
	SetTooltip()
end

function toggleEquipmentClicked()
	this.Current = this.Current + 1
	if EquipmentTypes[this.MyType][this.Current] == nil then
		this.Current = 1
	end
	Set(this,"CalloutEquipment",EquipmentNumbers[this.MyType][this.Current])
	CalloutEquipment = EquipmentTypes[this.MyType][this.Current]
	print(CalloutEquipment.." (number: "..this.CalloutEquipment..")")
	this.SetInterfaceCaption("toggleEquipment", "tooltip_CalloutHelipad_Button_ToggleCalloutEquipment","tooltip_CalloutHelipad_CalloutEquipment_"..CalloutEquipment,"X")
	SetTooltip()
end

function SetTooltip()
	if this.MyType ~= "Fireman" then
		this.Tooltip = { "tooltip_CalloutHelipadB",this.MyType,"X",CalloutEquipment,"Y" }
	else
		this.Tooltip = { "tooltip_CalloutHelipadC",CalloutEquipment,"X",this.FiremanMethod,"Y" }
	end
end

function FindSomeEquipmentNumbers()
	local TestEntity = Object.Spawn("IntakeChinookPilot",this.Pos.x,this.Pos.y)
	for e = 0,1000 do
		TestEntity.Equipment = e
		if TestEntity.Equipment == "Extinguisher" then
			EquipmentNumbers["Fireman"][1] = e
			hoseFound = true
		end
		if TestEntity.Equipment == "SedativeSyringe" then
			EquipmentNumbers["Orderly"][1] = e
			syringeFound = true
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
