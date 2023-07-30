
local timeInit = 0
local initTimer = 0.1 + math.random()	-- only used when object is placed down.
								-- this will prevent a dozen objects being placed down at the same time from starting to calculate
								-- the TimeWarp all at the same moment, give your potato a break and spread the cpu load a bit :)
local Now = 0
local StartingMinute = 0
local EndingMinute = 0

local myMapSize = "UNKNOWN"
local mySlowTime = "UNKNOWN"

local myTimeWarpFactor = 0
local timeWarpFound = false

local timeTot = 0

local Get = Object.GetProperty
local Set = Object.SetProperty
local subToTreeType = { Chestnut = 0, Fir = 1, Palm = 2, Oak = 3, Conifer = 4 }
local treeTypeToSub = { [0] = "Chestnut", [1] = "Fir", [2] = "Palm", [3] = "Oak", [4] = "Conifer" }
local setTreeType=""
local treeType = math.random(0,4)
local LogNr = 1

function Create()
	this.Tooltip = "tooltip_Init_TimeWarpA"
end

function toggleTypeClicked()
	treeType=treeType+1
	if treeType>4 then
		treeType=0
	end
	setTreeType = treeTypeToSub[treeType]
	Set(this,"TreeType",setTreeType)
	this.SetInterfaceCaption("toggleType", "Type: "..this.TreeType.."")
	this.SubType = subToTreeType[Get("TreeType")]
end

function toggleMaxAgePlusClicked()
	if maxAge < 24 then
		maxAge = maxAge+1
		Set(this,"MaxAge",maxAge)
		this.SetInterfaceCaption("CaptionMaxAge", "tooltip_Caption_MaxAge",this.MaxAge,"X")
		this.Tooltip = { "tooltip_TreeAge",age+maxAge+maxAge,"X",this.MaxAge,"Y",maxAge*3,"Z" }
	else
		maxAge = 1
		Set(this,"MaxAge",maxAge)
		this.SetInterfaceCaption("CaptionMaxAge", "tooltip_Caption_MaxAge",this.MaxAge,"X")
		this.Tooltip = { "tooltip_TreeAge",age+maxAge+maxAge,"X",this.MaxAge,"Y",maxAge*3,"Z" }
	end
end

function toggleMaxAgeMinusClicked()
	if maxAge > 1 then
		maxAge = maxAge-1
		Set(this,"MaxAge",maxAge)
		this.SetInterfaceCaption("CaptionMaxAge", "tooltip_Caption_MaxAge",this.MaxAge,"X")
		this.Tooltip = { "tooltip_TreeAge",age+maxAge+maxAge,"X",this.MaxAge,"Y",maxAge*3,"Z" }
	else
		maxAge = 24
		Set(this,"MaxAge",maxAge)
		this.SetInterfaceCaption("CaptionMaxAge", "tooltip_Caption_MaxAge",this.MaxAge,"X")
		this.Tooltip = { "tooltip_TreeAge",age+maxAge+maxAge,"X",this.MaxAge,"Y",maxAge*3,"Z" }
	end
end

function Update(timePassed)
	if this.TimeWarp == nil then
		if World.TimeWarpFactor ~= nil then
			Set(this,"TimeWarp",World.TimeWarpFactor)
		else
			CalculateTimeWarpFactor(timePassed)
		end
		return
	elseif timePerUpdate == nil then
		timePerUpdate = 0.1
		this.Tooltip = ""
		treeType = subToTreeType[Get("TreeType")] or 0
		setTreeType = treeTypeToSub[treeType]
		Set(this,"TreeType",setTreeType)
		this.SubType = subToTreeType[Get("TreeType")]
		maxAge = Get(this,"MaxAge") or 1
		Set(this,"MaxAge",maxAge)
		age = Get("Age") or -0.25
		Set(this,"Age",age)
		this.Tooltip = { "tooltip_TreeAge",age+maxAge+maxAge,"X",this.MaxAge,"Y",maxAge*3,"Z" }
		Interface.AddComponent(this,"CaptionDivider1", "Caption", "tooltip_Divider")
		Interface.AddComponent(this,"toggleType", "Button", "Type: "..this.TreeType.."")
		Interface.AddComponent(this,"CaptionDivider2", "Caption", "tooltip_Divider")
		Interface.AddComponent(this,"toggleMaxAgePlus", "Button", "tooltip_button_MaxAgePlus")
		Interface.AddComponent(this,"CaptionMaxAge", "Caption", "tooltip_Caption_MaxAge",this.MaxAge,"X")
		Interface.AddComponent(this,"toggleMaxAgeMinus", "Button", "tooltip_button_MaxAgeMinus")
	end
	timeTot = timeTot + timePassed
	if timeTot >= timePerUpdate then
		timeTot = 0
		age = Get("Age")
		age = age + 0.25   						-- updates are 4x per hour so age will be 1 after an hour
		Set(this,"Age",age)
		this.Tooltip = { "tooltip_TreeAge",age+maxAge+maxAge,"X",this.MaxAge,"Y",maxAge*3,"Z" }
		if age >= maxAge then
			Object.CreateJob(this,"ChopForestryTree")
		end
		timePerUpdate = 15 / this.TimeWarp	-- update every 15 minutes
	end
end


function CalculateTimeWarpFactor(timePassed)
	if timeInit > initTimer then
	
		if timePerUpdate == nil then
			Now = math.floor(math.mod(World.TimeIndex,60))
			if not StartCountdown then
				if Now ~= StartingMinute then
				--	this.SubType = 5
					StartingMinute = Now
					if Now < 59 then
						EndingMinute = Now + 1				-- calculate TimeWarp within the next minute
						StartCountdown = true
					else
						return				-- wait another minute if object is placed 1 minute before next whole hour
					end
				end
			else
				timeTot=timeTot+timePassed
				this.Tooltip = {"tooltip_Init_TimeWarpB",StartingMinute,"A",EndingMinute,"B",Now,"C",timeTot,"D" }	-- show stopwatch
				if Now >= StartingMinute+1 then
					if timeTot >= 5.4 then			-- the result should be around 8 (1/8) for large map with slow time enabled, compare with 5.4 to compensate for lag
						myTimeWarpFactor = 0.125
					--	this.SubType = 6
						myMapSize = "LARGE"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 4.1 then		-- the result should be around 5.33 (3/16) for medium map with slow time enabled
						myTimeWarpFactor = 0.1875
					--	this.SubType = 7
						myMapSize = "MEDIUM"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 2.1 then		-- the result should be around 4 (1/4) for small map with slow time enabled
						myTimeWarpFactor = 0.25
					--	this.SubType = 8
						myMapSize = "SMALL"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 1.4 then		-- the result should be around 2 (1/2) for large map
						myTimeWarpFactor = 0.5
					--	this.SubType = 9
						myMapSize = "LARGE"
						mySlowTime = "NO"
						timeWarpFound = true
					elseif timeTot >= 1.1 then		-- the result should be around 1.33 (3/4) for medium map
						myTimeWarpFactor = 0.75
					--	this.SubType = 10
						myMapSize = "MEDIUM"
						mySlowTime = "NO"
						timeWarpFound = true
					else							-- the result should be around 1 (1) for small map
						myTimeWarpFactor = 1
					--	this.SubType = 11
						myMapSize = "SMALL"
						mySlowTime = "NO"
						timeWarpFound = true
					end
					
					-- Instead of using the hard coded TimeWarp values (found in de saved game and mentioned above),
					-- you could also calculate your own by dividing 1 minute by the time it took to get to that minute.
					-- The result will be approximately the hard coded TimeWarp value, but can be different for each object you place,
					-- depending on how busy the game is, this is should not be used by default:
					
					--timeWarpFound = false					-- enable to see this calculation result in action
					--if timeWarpFound == false then myTimeWarpFactor = 1 / timeTot end
					
					this.Tooltip = {"tooltip_Init_TimeWarpC",StartingMinute,"A",EndingMinute,"B",Now,"C",timeTot,"D",myMapSize,"E",myTimeWarpFactor,"F",mySlowTime,"G" }	-- show results
					
					-- set the timePerUpdate here so we get out of this function
					timePerUpdate = 1 / myTimeWarpFactor	-- will show the results for 3 game minutes
				end
			end
		else		-- calculation completed, so save the results
			timeTot = timeTot+timePassed
			if timeTot > timePerUpdate then
			--	this.SubType = 0						-- change sprite back to normal
				Set(this,"TimeWarp",myTimeWarpFactor)	-- this tells function Update() to proceed
				this.Tooltip = "tooltip_ReadyForAction"
				timePerUpdate = nil				-- reset to nil so function Update() can proceed with normal activity
			end
		end
	else
		Object.CancelJob(this,"ChopForestryTree")
		timeInit = timeInit+timePassed
		StartingMinute = math.floor(math.mod(World.TimeIndex,60))
	end
end

function JobComplete_ChopForestryTree()
	-- spawn a stack with the material, instead of just the material, so modded staff will carry it to a processor
	FindStackNumbers()
	newStack = Object.Spawn("Stack",this.Pos.x+1,this.Pos.y+1)
	Set(newStack,"Contents",LogNr)
	Set(newStack,"Quantity",3)
	local velX = -1.0 + math.random() + math.random()
	local velY = -1.0 + math.random() + math.random()
	Object.ApplyVelocity(newStack, velX, velY)
	
--	for i=1,3 do
--		newLog = Object.Spawn("Log",this.Pos.x,this.Pos.y)
--		local velX = -1.0 + math.random() + math.random()
--		local velY = -1.0 + math.random() + math.random()
--		Object.ApplyVelocity(newLog, velX, velY)
--	end

	newStump = Object.Spawn("ForestryTreeStump",this.Pos.x,this.Pos.y)
	Set(newStump,"TimeWarp",this.TimeWarp)
	Set(newStump,"MaxAge",this.MaxAge)
	Set(newStump,"TreeType",this.TreeType)
	this.Delete()
end

function FindStackNumbers()
	local newStack = Object.Spawn("Stack", this.Pos.x-1, this.Pos.y)
	for i = 1,2000 do
		Set(newStack,"Quantity",2)
		Set(newStack,"Contents",i)
		if newStack.Contents == "Log" then
			LogNr = i
		end
		if LogNr > 1 then
			newStack.Delete()
			print("Stack Log: "..LogNr)
			break
		end
	end
end
