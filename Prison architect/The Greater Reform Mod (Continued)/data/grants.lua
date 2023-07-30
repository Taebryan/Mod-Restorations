
function CreateGrants()

	CreateGroupTherapy();
	CreateCreativeAccounting();
	CreateBasicEducation();
	CreateAdvancedEducation();
	CreateBasicLabour();
	CreateLifeDiscipline();
    
end



function 	CreateGroupTherapy()

	Objective.CreateGrant			( "Grant_GroupTherapy", 1500, 5000 )

	Objective.CreateGrant			( "Grant_GroupTherapy_Reaserch", 0, 0 )
	Objective.SetParent				( "Grant_GroupTherapy" )
	Objective.RequireResearched		( "GroupTherapy" )
	
	Objective.CreateGrant			( "Grant_GroupTherapy_Office", 0, 0 )
	Objective.SetParent				( "Grant_GroupTherapy" )
	Objective.RequireRoomsAvailable	( "Office", 1 )
	
	Objective.CreateGrant			( "Grant_GroupTherapy_TherapyCentre", 0, 0 )	
	Objective.SetParent				( "Grant_GroupTherapy" )
	Objective.RequireRoom			( "TherapyCentre", true )
	
	Objective.CreateGrant			( "Grant_GroupTherapy_OT", 0, 0 )
	Objective.SetParent				( "Grant_GroupTherapy" )
	Objective.RequireObjects		( "OccupationalTherapist", 1 )
	
end

function CreateCreativeAccounting()

	Objective.CreateGrant			( "Grant_CreativeAccounting", 1000, 2500 )
    Objective.SetPreRequisite       ( "Completed", "Grant_bootstraps", 0 )
    Objective.SetPreRequisite       ( "Unlocked", "Finance", 0 )
	
	Objective.CreateGrant			( "Grant_CreativeAccounting_Reaserch", 0, 0 )
	Objective.SetParent				( "Grant_CreativeAccounting" )
	Objective.RequireResearched		( "CreativeAccounting" )
	
	Objective.CreateGrant			( "Grant_CreativeAccounting_AccountingOffice", 0, 0 )	
	Objective.SetParent				( "Grant_CreativeAccounting" )
	Objective.RequireRoom			( "AccountingOffice", true )	
end

function CreateBasicEducation()

	Objective.CreateGrant			( "Grant_BasicEducation", 2000, 5000 )
    Objective.SetPreRequisite       ( "Unlocked", "Education", 0 )
	
	Objective.CreateGrant			( "Grant_BasicEducation_Reaserch", 0, 0 )
	Objective.SetParent				( "Grant_BasicEducation" )
	Objective.RequireResearched		( "BasicEducation" )
	
	Objective.CreateGrant			( "Grant_BasicEducation_Office", 0, 0 )
	Objective.SetParent				( "Grant_BasicEducation" )
	Objective.RequireRoomsAvailable	( "Office", 1 )
	
	Objective.CreateGrant			( "Grant_BasicEducation_Lecturer", 0, 0 )
	Objective.SetParent				( "Grant_BasicEducation" )
	Objective.RequireObjects		( "Lecturer", 1 )
	
end

function CreateAdvancedEducation()

  	Objective.CreateGrant			( "Grant_AdvancedEducation", 3000, 7500 )
	Objective.SetPreRequisite       ( "Completed", "Grant_BasicEducation", 0 )
    Objective.SetPreRequisite       ( "Unlocked", "Education", 0 )
	
	Objective.CreateGrant			( "Grant_AdvancedEducation_Reaserch", 0, 0 )
	Objective.SetParent				( "Grant_AdvancedEducation" )
	Objective.RequireResearched		( "AdvancedEducation" )
	
end

function CreateBasicLabour()
    
	Objective.CreateGrant			( "Grant_BasicLabour", 2000, 5000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_PrisonerWorkforce", 0 )
    Objective.SetPreRequisite       ( "Unlocked", "PrisonLabour", 0 )
	
	Objective.CreateGrant			( "Grant_BasicLabour_Reaserch", 0, 0 )
	Objective.SetParent				( "Grant_BasicLabour" )
	Objective.RequireResearched		( "BasicLabour" )
	
	Objective.CreateGrant			( "Grant_BasicLabour_Office", 0, 0 )
	Objective.SetParent				( "Grant_BasicLabour" )
	Objective.RequireRoomsAvailable	( "Office", 2 )
	
	Objective.CreateGrant			( "Grant_BasicLabour_HairDresser", 0, 0 )
	Objective.SetParent				( "Grant_BasicLabour" )
	Objective.RequireObjects		( "HairDresser", 1 )
	
	Objective.CreateGrant			( "Grant_BasicLabour_Mechanic", 0, 0 )
	Objective.SetParent				( "Grant_BasicLabour" )
	Objective.RequireObjects		( "Mechanic", 1 )
	
	Objective.CreateGrant			( "Grant_BasicLabour_Salon", 0, 0 )	
	Objective.SetParent				( "Grant_BasicLabour" )
	Objective.RequireRoom			( "Salon", true )	
	
	Objective.CreateGrant			( "Grant_BasicLabour_Garage", 0, 0 )	
	Objective.SetParent				( "Grant_BasicLabour" )
	Objective.RequireRoom			( "Garage", true )	
	
end

function CreateLifeDiscipline()

 	Objective.CreateGrant			( "Grant_LifeDiscipline", 1000, 2500 )
    Objective.SetPreRequisite       ( "Completed", "Grant_EnhancedSecurity", 0 )
    Objective.SetPreRequisite       ( "Unlocked", "Security", 0 )
	
	Objective.CreateGrant			( "Grant_LifeDiscipline_Reaserch", 0, 0 )
	Objective.SetParent				( "Grant_LifeDiscipline" )
	Objective.RequireResearched		( "LifeDiscipline" )
	
	Objective.CreateGrant			( "Grant_LifeDiscipline_Office", 0, 0 )
	Objective.SetParent				( "Grant_LifeDiscipline" )
	Objective.RequireRoomsAvailable	( "Office", 1 )
	
	Objective.CreateGrant			( "Grant_LifeDiscipline_StaffSergeant", 0, 0 )
	Objective.SetParent				( "Grant_LifeDiscipline" )
	Objective.RequireObjects		( "StaffSergeant", 1 )

	
	Objective.CreateGrant			( "Grant_LifeDiscipline_ParadeSquare", 0, 0 )	
	Objective.SetParent				( "Grant_LifeDiscipline" )
	Objective.RequireRoom			( "ParadeSquare", true )	

end