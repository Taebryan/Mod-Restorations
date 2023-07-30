
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

function Create()
end

function Update(timePassed)
	-- print("this.Pos.x: "..this.Pos.x.." this.Pos.y: "..this.Pos.y)
	if this.StackTransferred == nil then
		this.Pos.y = 2
		TransferStack()
		this.StackTransferred = true
	end
end

function TransferStack()
	for thatTransferrer in next, Find(this,"StackTransferrer",1) do
		MyStackTransferrer = thatTransferrer
		for C = 0,7 do
			Set(this,"Slot"..C..".i",-1)
			Set(this,"Slot"..C..".u",-1)
		end
		Set(MyStackTransferrer,"NewLoadAvailable",true)
		this.Delete()
		-- print("Found nearby MyStackTransferrer.Pos.x: "..MyStackTransferrer.Pos.x.." MyStackTransferrer.Pos.y: "..MyStackTransferrer.Pos.y)
	end
	if MyStackTransferrer == nil then
		for thatTransferrer in next, Find(this,"StackTransferrer",10000) do
			MyStackTransferrer = thatTransferrer
			MyStackTransferrer.Pos.x = this.Pos.x
			MyStackTransferrer.Pos.y = 2
			for C = 0,7 do
				Set(this,"Slot"..C..".i",-1)
				Set(this,"Slot"..C..".u",-1)
			end
			Set(MyStackTransferrer,"NewLoadAvailable",true)
			this.Delete()
			-- print("Found far MyStackTransferrer.Pos.x: "..MyStackTransferrer.Pos.x.." MyStackTransferrer.Pos.y: "..MyStackTransferrer.Pos.y)
		end
	end
	if this.SubType == 0 then
		Set(this,"Tooltip","tooltip_SupplyTruck")
	end
end
