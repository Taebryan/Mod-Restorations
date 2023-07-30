function Create()

	local weaponID=1;
	local prisoners = Object.GetNearbyObjects(this, "Prisoner", 10000);
	if prisoners~=nil then
		for name,dist in pairs( prisoners ) do
			Object.SetProperty(name,"BoilingPoint",100);
			Object.SetProperty(name,"Misbehavior",2);
			
			--set weapon
			if weaponID==1 then Object.SetProperty(name,"Equipment",104);
			elseif weaponID>=2 and weaponID<=5 then Object.SetProperty(name,"Equipment",103);
			elseif weaponID>=6 and weaponID<=8 then Object.SetProperty(name,"Equipment",30);
			elseif weaponID==8 then Object.SetProperty(name,"Equipment",103);
			elseif weaponID==9 then Object.SetProperty(name,"Equipment",46);
			elseif weaponID>=10 and weaponID<=14 then Object.SetProperty(name,"Equipment",7);
			elseif weaponID==15 then Object.SetProperty(name,"Equipment",46);
			elseif weaponID>=16 and weaponID<=18 then Object.SetProperty(name,"Equipment",32);
			elseif weaponID==19 then Object.SetProperty(name,"Equipment",42);
			elseif weaponID==20 then Object.SetProperty(name,"Equipment",45); end
			
			weaponID=weaponID+1;
			if weaponID>20 then
				weaponID = 1;
			end
		end
	end
	this.Sound("__RiotAssault","Breach2");
	this.Sound("_Failure","FinalFailure");
	this.Delete();
end