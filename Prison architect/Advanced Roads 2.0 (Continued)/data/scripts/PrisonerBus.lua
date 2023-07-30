
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

function Create()
	local nearbyTransferrers = Find(this,"StackTransferrer",5)
	if next(nearbyTransferrers) then
		print("Found nearbyTransferrers")
		return true
	else
		local farTransferrers = Find(this,"StackTransferrer",10000)
		if next(farTransferrers) then
			print("Found farTransferrers")
			for thatTransferrer, distance in pairs(farTransferrers) do
				thatTransferrer.Pos.x = this.Pos.x
				thatTransferrer.Pos.y = 2
			end
		end
	end
end

function Update(timePassed)
	if this.PrisonersTransferred == nil then
		TransferPrisoners(5)
		this.PrisonersTransferred = true
	end
	if this.State == "Processing" then
		if not this.TriedTransfer then
			TransferPrisoners(10000)
			this.TriedTransfer = true
		end
	end
end

function TransferPrisoners(theDist)
	for MyStackTransferrer in next, Find(this,"StackTransferrer",theDist) do
		local loadedPrisoners=Find(this,"Prisoner",5)
		for A = 0,7 do
			P = Get(this,"Slot"..A..".i")
			if next(loadedPrisoners) then
				for thatPrisoner, distance in pairs(loadedPrisoners) do
					if thatPrisoner.Id.i == P then
						Set(this,"Slot"..A..".i",-1)
						Set(this,"Slot"..A..".u",-1)
						Set(thatPrisoner,"CarrierId.i",-1)
						Set(thatPrisoner,"CarrierId.u",-1)
						Set(thatPrisoner,"Loaded",false)
						local NewPrisonerHolder = Object.Spawn("PrisonerStackHolder",MyStackTransferrer.Pos.x,MyStackTransferrer.Pos.y)
						Set(NewPrisonerHolder,"HolderCategory",thatPrisoner.Category)
						Set(NewPrisonerHolder,"Tooltip",thatPrisoner.Category.." Prisoner")
						Set(NewPrisonerHolder,"Slot0.i",thatPrisoner.Id.i)
						Set(NewPrisonerHolder,"Slot0.u",thatPrisoner.Id.u)
						Set(thatPrisoner,"CarrierId.i",NewPrisonerHolder.Id.i)
						Set(thatPrisoner,"CarrierId.u",NewPrisonerHolder.Id.u)
						Set(thatPrisoner,"Loaded",true)
						Set(thatPrisoner,"Locked",true)
						NewPrisonerHolder = nil
					end
				end
			end
		end
		loadedPrisoners = nil
		Set(MyStackTransferrer,"NewIntakeAvailable",true)
		this.Delete()
	end
end
