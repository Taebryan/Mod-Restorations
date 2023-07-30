
function CreateGrants()
	-- CreateLimoGarage2()
	-- CreateLimoMechanics2()
end

-- function CreateLimoGarage2()
	-- Objective.CreateGrant			( "Grant_LimoGarage2", 1500, 50000 )
    -- Objective.SetPreRequisite       ( "Unlocked", "PrisonLabour", 0 )
    -- Objective.HiddenWhileLocked     ()
	-- Objective.CreateGrant			( "Grant_LimoGarage2_Research", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.Requires				( "Unlocked", "LimoRepairShop", 0 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_SpawnerNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "GantryCrane2Spawner", 1 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_RepairNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "Limo2Preview", 4 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_LessonNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "Limo2LessonPreview", 2 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_BoothNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "GantryCrane2BoothPreview", 1 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_RackNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "CarPartsRack2Preview", 1 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_DeskNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "Limo2ServiceDeskPreview", 1 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_FilingNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "Limo2FilingCabinetPreview", 1 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_LimoGarageRoom", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireRoom			( "LimoGarage2", true )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_LimoWaitingRoom", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireRoom			( "Limo2WaitingRoom", true )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_CarMechanicNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "CarMechanic2", 1 )
	
	-- Objective.CreateGrant			( "Grant_LimoGarage2_CraneOperatorNumber", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoGarage2" )
	-- Objective.RequireObjects		( "CraneOperator2", 1 )
	
-- end

-- function CreateLimoMechanics2()
	-- Objective.CreateGrant			( "Grant_LimoMechanics2", 1500, 2500 )
    -- Objective.SetPreRequisite       ( "Unlocked", "LimoRepairShop", 0 )
    -- Objective.HiddenWhileLocked     ()
	
	-- Objective.CreateGrant			( "Grant_LimoMechanics2_Research", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoMechanics2" )
	-- Objective.Requires				( "Completed", "Grant_LimoGarage2", 0 )
	
	-- Objective.CreateGrant			( "Grant_LimoMechanics2_ProgramPassed1", 0, 5000 )
	-- Objective.SetParent				( "Grant_LimoMechanics2" )
	-- Objective.Requires				( "ReformPassed", "Limo2RepairTheoretic", 2 )
	
	-- Objective.CreateGrant			( "Grant_LimoMechanics2_ProgramPassed2", 0, 10000 )
	-- Objective.SetParent				( "Grant_LimoMechanics2" )
	-- Objective.Requires				( "ReformPassed", "Limo2RepairPractical", 2 )
	
	-- Objective.CreateGrant			( "Grant_LimoMechanics2_Assigned", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoMechanics2")
	-- Objective.Requires				( "PrisonerJobs", "LimoGarage2", 2 )
	
	-- Objective.CreateGrant			( "Grant_LimoMechanics2_Repaired", 0, 0 )
	-- Objective.SetParent				( "Grant_LimoMechanics2" )
	-- Objective.RequireObjects		( "Limo2Repaired", 1 )
-- end
