function Create()

	local prisoners = Object.GetNearbyObjects(this, "Prisoner", 10000);
	if prisoners~=nil then
		for name,dist in pairs( prisoners ) do
			Object.SetProperty(name,"BoilingPoint",100);
			Object.SetProperty(name,"Misbehavior",2);
		end
	end
	
	this.Delete();
end