
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = Object.GetNearbyObjects

function Create()
	local nearbyTransferrers = Find(this,"StackTransferrer",5)
	if next(nearbyTransferrers) then
		print("Found nearbyTransferrer")
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
	if this.ModsChecked == nil then
		CheckMods()
		this.ModsChecked = true
	end
end

function CheckMods()
	for MyStackTransferrer in next, Find(this,"StackTransferrer",5) do
		DeleteMe = true
		this.Delete()
	end
	if not DeleteMe then
		for HearseRemover in next, Find(this,"HearseRemover",10000) do
			this.Delete()
		end
	end
end
