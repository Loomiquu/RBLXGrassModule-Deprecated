local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local collectionService = game:GetService("CollectionService")

local GrassModule = {}

local playerService = game:GetService("Players")
local player = playerService.LocalPlayer
local humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart")

local self = GrassModule
local running = false

self.BladesToSpawn = 2500
self.TopColor = Color3.fromRGB(0, 255, 0)
self.BottomColor = Color3.fromRGB(0, 54, 0)
self.topWidth = 0.1
self.bottomWidth = 0.4
self.Height = 2.3
self.RaycastY = 10
self.FrontValue = 80
self.SideValue = 80
self.DespawnDistance = 80
self.GrassIDistance = 4
self.SleepDistance = 15
self.EasingStyle = Enum.EasingStyle.Bounce
self.yOffset = 0.2
self.StatusMessagesEnabled = false
self.GrassCurveNumber = 2


local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.IgnoreWater = true
	
local globalCounter = 0
local canCreate = false

function Recycle()
	globalCounter += 1
	
	local topAttachment = Instance.new("Attachment")
	local bottomAttachment = Instance.new("Attachment")
	local objVal = Instance.new("ObjectValue")
	objVal.Name = "Object"
	objVal.Value = bottomAttachment
	objVal.Parent = topAttachment
	local grassBeam = Instance.new("Beam")
	local rng = humanoidRootPart.CFrame * CFrame.new(math.random(-self.SideValue,self.SideValue),0,math.random(-self.FrontValue,self.FrontValue)) 
	
	topAttachment.Parent = collectionService:GetTagged("mainObj")[1]
	bottomAttachment.Parent = collectionService:GetTagged("mainObj")[1]
	topAttachment.Position = rng.Position

	bottomAttachment.Position = rng.Position
	collectionService:AddTag(topAttachment,"Grass")
	local playerArray = {}
	for _, v in playerService:GetPlayers() do
		table.insert(playerArray, v.Character)
	end
	topAttachment.Name = tostring(globalCounter)
	params.FilterDescendantsInstances = playerArray
	local raycastResult = workspace:Raycast(Vector3.new(rng.Position.X,self.RaycastY + humanoidRootPart.Position.Y,rng.Position.Z), Vector3.new(0,-self.RaycastY,0) * 10,params)

	if raycastResult then
		bottomAttachment.Position = Vector3.new(rng.Position.X, raycastResult.Position.Y - self.yOffset,rng.Position.Z)
		topAttachment.Position = Vector3.new(rng.Position.X,raycastResult.Position.Y + self.Height, rng.Position.Z)
	else
		bottomAttachment.Position = Vector3.new(rng.Position.X,0,rng.Position.Z)
		topAttachment.Position = Vector3.new(rng.Position.X,0,rng.Position.Z)
		grassBeam.Enabled = false
	end
	topAttachment:SetAttribute("OriginalPosition", topAttachment.Position)
	grassBeam.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, GrassModule.BottomColor),
		ColorSequenceKeypoint.new(0.5, GrassModule.TopColor),
		ColorSequenceKeypoint.new(1, GrassModule.TopColor)
	}

	grassBeam.Transparency = NumberSequence.new(0)
	grassBeam.FaceCamera = true
	grassBeam.Width1 = self.topWidth
	grassBeam.Width0 = self.bottomWidth
	grassBeam.Attachment0 = bottomAttachment
	grassBeam.Attachment1 = topAttachment
	grassBeam.Parent = topAttachment

end

function main()

	local grass = collectionService:GetTagged("Grass")
	for i = 1, #grass do
		
			local distance = (grass[i].Object.Value.WorldPosition - humanoidRootPart.Position).Magnitude
		
		if distance < self.GrassIDistance then
			local newCF = CFrame.new(grass[i].Object.Value.WorldPosition, humanoidRootPart.CFrame.Position).UpVector
			tweenService:Create(grass[i], TweenInfo.new(0.2), {Position = Vector3.new(newCF.X, newCF.Y - (self.yOffset * 2),newCF.Z) * self.GrassCurveNumber + grass[i]:GetAttribute("OriginalPosition")}):Play()
			elseif grass[i]:GetAttribute("OriginalPosition") and distance > self.GrassIDistance * 1.5 and distance < self.SleepDistance then
			tweenService:Create(grass[i],TweenInfo.new(0.2, self.EasingStyle), {Position = grass[i]:GetAttribute("OriginalPosition")}):Play()
		end
		
		if distance > self.DespawnDistance then
		grass[i].Object.Value:Destroy()
		grass[i]:Destroy()
				
			if canCreate then
			Recycle()	
			end		
		end
	end
end

function self.Initiate()
	if not running then
	running = true
	canCreate = true
	local mainObj = Instance.new("Part")
	collectionService:AddTag(mainObj, "mainObj")
	mainObj.Position = Vector3.zero
	mainObj.Size = Vector3.zero
	mainObj.Transparency = 1
	mainObj.Anchored = true
	mainObj.CanCollide = false
	mainObj.Parent = workspace
	
	for i = 1, self.BladesToSpawn do
		globalCounter += 1
		task.desynchronize()
		local topAttachment = Instance.new("Attachment")
		local bottomAttachment = Instance.new("Attachment")
		
		local grassBeam = Instance.new("Beam")
		local rng = humanoidRootPart.CFrame * CFrame.new(math.random(-self.SideValue,self.SideValue),0,math.random(-self.FrontValue,self.FrontValue)) 
		task.synchronize()
		local objVal = Instance.new("ObjectValue")
		objVal.Name = "Object"
		objVal.Value = bottomAttachment
		objVal.Parent = topAttachment
		topAttachment.Parent = mainObj
		bottomAttachment.Parent = mainObj
		topAttachment.Position = rng.Position
			
		bottomAttachment.Position = rng.Position
		collectionService:AddTag(topAttachment,"Grass")
		local playerArray = {}
		for _, v in playerService:GetPlayers() do
		table.insert(playerArray, v.Character)
		end
		topAttachment.Name = tostring(globalCounter)
		bottomAttachment.Name = tostring(globalCounter).. "Bottom"
		params.FilterDescendantsInstances = playerArray
		local raycastResult = workspace:Raycast(Vector3.new(rng.Position.X,self.RaycastY + humanoidRootPart.Position.Y,rng.Position.Z), Vector3.new(0,-self.RaycastY,0) * 10,params)
		
		if raycastResult then
			bottomAttachment.Position = Vector3.new(rng.Position.X, raycastResult.Position.Y - self.yOffset,rng.Position.Z)
			topAttachment.Position = Vector3.new(rng.Position.X,raycastResult.Position.Y + self.Height, rng.Position.Z)
		else
			bottomAttachment.Position = Vector3.new(rng.Position.X,0,rng.Position.Z)
			topAttachment.Position = Vector3.new(rng.Position.X,0,rng.Position.Z)
			grassBeam.Enabled = false
		end
		topAttachment:SetAttribute("OriginalPosition", topAttachment.Position)
		grassBeam.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, GrassModule.BottomColor),
			ColorSequenceKeypoint.new(0.5, GrassModule.TopColor),
			ColorSequenceKeypoint.new(1, GrassModule.TopColor)
		}
		
		grassBeam.Transparency = NumberSequence.new(0)
		grassBeam.FaceCamera = true
		grassBeam.Width1 = self.topWidth
		grassBeam.Width0 = self.bottomWidth
		grassBeam.Attachment0 = bottomAttachment
		grassBeam.Attachment1 = topAttachment
		grassBeam.Parent = topAttachment
		end
		runService:BindToRenderStep("Main", Enum.RenderPriority.Camera.Value, main)
	else
		warn("::".. script.Name..":: ".. " ::Cannot run more than one routine!::")
	end
end

function self.ForceCleanup()
	if self.StatusMessagesEnabled then
		warn("::".. script.Name.. ":: ".." ::Forced cleanup has begun!::")
	end
	running = false
	canCreate = false
	runService:UnbindFromRenderStep("Main")
	collectionService:GetTagged("mainObj")[1]:Destroy()
	globalCounter = 0
	
	if self.StatusMessagesEnabled then
		warn("::".. script.Name.. ":: ".." ::Forced cleanup has been completed::")
	end
end

function self.Cleanup()
	
	canCreate = false
	
	local canStop = false
	collectionService:GetTagged("mainObj")[1].ChildRemoved:Connect(function()
		canStop = true
		for _, v in collectionService:GetTagged("mainObj")[1]:GetChildren() do
			if v ~= nil then
				canStop = false
			end
		end
		
		if canStop == true then
			running = false
			
			if self.StatusMessagesEnabled then
				warn("::".. script.Name..":: ".. " ::Successfully cleaned up grass::")
			end
			
			runService:UnbindFromRenderStep("Main")
			globalCounter = 0
			collectionService:GetTagged("mainObj")[1]:Destroy()
		end
	end)
end

function onCharacterAdded(character)
	humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
end

player.CharacterAppearanceLoaded:Connect(onCharacterAdded)

return GrassModule
