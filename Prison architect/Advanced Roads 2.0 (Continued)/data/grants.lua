
function CreateGrants()
	CreateTrafficTerminal()
	CreateCargoStationDeliveries()
	CreateCargoStationGarbage()
	CreateCargoStationExports()
	CreateCargoStationIntake()
	CreateCargoStationEmergency()
	CreateCargoStationCallout()
end

function CreateTrafficTerminal()
	Objective.CreateGrant			( "Grant_TrafficTerminal", 2000, 25000 )
		
	Objective.CreateGrant			( "Grant_TrafficTerminal_CreateTerminalA1", 0, 0 )
	Objective.SetParent				( "Grant_TrafficTerminal" )
	Objective.RequireObjects		( "TrafficTerminal", 1 )
	
	Objective.CreateGrant			( "Grant_TrafficTerminal_CreateTerminalB", 0, 0 )
	Objective.SetParent				( "Grant_TrafficTerminal" )
    Objective.RequireRoom           ( "Deliveries", true )
	
	Objective.CreateGrant			( "Grant_TrafficTerminal_CreateTerminalC", 0, 0 )
	Objective.SetParent				( "Grant_TrafficTerminal" )
	Objective.RequireObjects		( "PreviewTruckSkinBG", 1 )
end

function CreateCargoStationDeliveries()
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries", 2000, 5000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_TrafficTerminal", 0 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_CreateStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
    Objective.RequireRoom           ( "CargoStorage", true )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleFood", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerFood", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleVending", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerVending", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleBuilding", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerBuilding", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleFloors", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerFloors", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleLaundry", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerLaundry", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleForest", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerForest", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleWorkshop", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerWorkshop", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_ToggleOther", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerOther", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_EnableStation", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerDeliveries", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Deliveries_EnableTerminalD", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Deliveries" )
	Objective.RequireObjects		( "GrantCheckerTerminal", 1 )
end

function CreateCargoStationGarbage()
	Objective.CreateGrant			( "Grant_CargoStation_Garbage", 2000, 5000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_TrafficTerminal", 0 )

	Objective.CreateGrant			( "Grant_CargoStation_Garbage_CreateStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Garbage" )
    Objective.RequireRoom           ( "Garbage", true )
	
	Objective.CreateGrant			( "Grant_CargoStation_Garbage_EnableStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Garbage" )
	Objective.RequireObjects		( "GrantCheckerGarbage", 1 )
end

function CreateCargoStationExports()
	Objective.CreateGrant			( "Grant_CargoStation_Exports", 2000, 5000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_TrafficTerminal", 0 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Exports_CreateStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Exports" )
    Objective.RequireRoom           ( "Exports", true )
	
	Objective.CreateGrant			( "Grant_CargoStation_Exports_EnableStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Exports" )
	Objective.RequireObjects		( "GrantCheckerExports", 1 )
end

function CreateCargoStationIntake()
	Objective.CreateGrant			( "Grant_CargoStation_Intake", 2000, 5000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_TrafficTerminal", 0 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Intake_CreateStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Intake" )
    Objective.RequireRoom           ( "CargoIntake", true )
	
	Objective.CreateGrant			( "Grant_CargoStation_Intake_ToggleMin", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Intake" )
	Objective.RequireObjects		( "GrantCheckerMinSec", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Intake_ToggleMed", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Intake" )
	Objective.RequireObjects		( "GrantCheckerMedSec", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Intake_EnableStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Intake" )
	Objective.RequireObjects		( "GrantCheckerIntake", 1 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Intake_EnableTerminalI", 0, 10 )
	Objective.SetParent				( "Grant_CargoStation_Intake" )
	Objective.RequireObjects		( "GrantCheckerTerminalI", 1 )
end

function CreateCargoStationEmergency()
	Objective.CreateGrant			( "Grant_CargoStation_Emergency", 2000, 5000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_TrafficTerminal", 0 )
	
	Objective.CreateGrant			( "Grant_CargoStation_Emergency_CreateStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Emergency" )
    Objective.RequireRoom           ( "CargoEmergencies", true )
	
	Objective.CreateGrant			( "Grant_CargoStation_Emergency_EnableStation", 0, 0 )
	Objective.SetParent				( "Grant_CargoStation_Emergency" )
	Objective.RequireObjects		( "GrantCheckerEmergency", 1 )
end

function CreateCargoStationCallout()
	Objective.CreateGrant			( "Grant_ChinookCallout", 2000, 5000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_TrafficTerminal", 0 )
	
	Objective.CreateGrant			( "Grant_ChinookCallout_FireStarter", 0, 0 )
	Objective.SetParent				( "Grant_ChinookCallout" )
	Objective.RequireObjects		( "Fire", 20 )
	
	Objective.CreateGrant			( "Grant_ChinookCallout_CalloutHelipad", 0, 0 )
	Objective.SetParent				( "Grant_ChinookCallout" )
	Objective.RequireObjects		( "CalloutHelipad", 1 )
	
	Objective.CreateGrant			( "Grant_ChinookCallout_Callout1", 0, 0 )
	Objective.SetParent				( "Grant_ChinookCallout" )
	Objective.RequireObjects		( "Chinook2", 1 )
	Objective.RequireObjects		( "Fireman", 8 )
end
