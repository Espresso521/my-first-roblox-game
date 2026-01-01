--[[
	OneWayPlatformsScript - This script implements one way platforms (i.e. platforms that the player can
	jump up through but not fall down through). Each Step, any nearby parts tagged with Constants.ONE_WAY_PLATFORM_TAG
	have their CanCollide property changed based on whether they are above or below the local player's character.
	Since CanCollide is being changed locally, this will only affect the local character's interaction with the platform.

	Character collision with platforms is disabled by default to avoid moving platforms running into other characters
	when the player is controlling its simulation while also standing on top of it (i.e. CanCollide = true). To re-enable
	collisions locally, the character's CollisionGroup is changed to a group that allows collision.
--]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(ReplicatedStorage.Gameplay.Constants)

local player = Players.LocalPlayer
local root = nil
local humanoid = nil

local platforms = {}
local lastUpdate = 0

local function onCharacterAdded(character: Model)
	character.DescendantAdded:Connect(function(descendant: Instance)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = Constants.LOCAL_CHARACTER_GROUP
		end
	end)

	root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = Constants.LOCAL_CHARACTER_GROUP
		end
	end
end

-- Keep track of platforms as they're added/removed so we don't need to constantly call CollectionService:GetTagged()
local function onPlatformAdded(platform: Instance)
	assert(platform:IsA("BasePart"), `{platform} should be a BasePart`)

	platforms[platform] = true
end

local function onPlatformRemoved(platform: Instance)
	assert(platform:IsA("BasePart"), `{platform} should be a BasePart`)

	if platforms[platform] then
		platforms[platform] = nil
	end
end

local function onStepped()
	-- If the character isn't spawned in, no need to update the platforms
	if not (root and humanoid) then
		return
	end

	-- We don't need to update the platforms every single frame, especially at higher framerates,
	-- so we've capped the update rate to 30hz.
	local elapsed = os.clock() - lastUpdate
	if elapsed < 1 / Constants.ONE_WAY_PLATFORM_UPDATE_RATE then
		return
	end
	lastUpdate = os.clock()

	-- Calculate the position of the character's feet based on their hip height
	local footPosition = root.Position.Y - humanoid.HipHeight
	for platform in platforms do
		-- No need to update platforms that are far away from the character
		local offset = platform.Position - root.Position
		local maxOffset = math.max(math.abs(offset.X), math.abs(offset.Y), math.abs(offset.Z))
		if maxOffset > Constants.ONE_WAY_PLATFORM_UPDATE_DISTANCE then
			continue
		end

		-- Any platforms below the feet should be collidable
		platform.CanCollide = footPosition > platform.Position.Y
	end
end

local function initialize()
	CollectionService:GetInstanceAddedSignal(Constants.ONE_WAY_PLATFORM_TAG):Connect(onPlatformAdded)
	CollectionService:GetInstanceRemovedSignal(Constants.ONE_WAY_PLATFORM_TAG):Connect(onPlatformRemoved)
	RunService.Stepped:Connect(onStepped)
	player.CharacterAdded:Connect(onCharacterAdded)

	for _, platform in CollectionService:GetTagged(Constants.ONE_WAY_PLATFORM_TAG) do
		onPlatformAdded(platform)
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

initialize()
