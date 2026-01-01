--[[
	OneWayPlatformsScript - This script sets up the collision groups for one way platforms. This is
	necessary to avoid issues with moving platforms and distributed physics simulation.

	For example: If a player is above a platform (i.e. CanCollide = true) and has simulation ownership of it,
	its movement will be affected since the client sees it as collidable. This can lead to cases where the
	platform will run into other characters and glitch out.

	To fix this, we assign the platforms and characters to collision groups which do not collide with each other.
	Each player locally assigns their character back to a collision group which does collide with the platforms.
	This allows the client to simulate collisions with its own character but not with other characters.
--]]

local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Gameplay.Constants)
local safePlayerAdded = require(ReplicatedStorage.Utility.safePlayerAdded)

local function onCharacterAdded(character: Model)
	character.DescendantAdded:Connect(function(descendant: Instance)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = Constants.CHARACTER_GROUP
		end
	end)

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = Constants.CHARACTER_GROUP
		end
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

local function onPlatformAdded(platform: Instance)
	assert(platform:IsA("BasePart"), `{platform} should be a BasePart`)

	platform.CollisionGroup = Constants.ONE_WAY_PLATFORM_GROUP
end

local function initializeCollisionGroups()
	PhysicsService:RegisterCollisionGroup(Constants.CHARACTER_GROUP)
	PhysicsService:RegisterCollisionGroup(Constants.LOCAL_CHARACTER_GROUP)
	PhysicsService:RegisterCollisionGroup(Constants.ONE_WAY_PLATFORM_GROUP)

	PhysicsService:CollisionGroupSetCollidable(Constants.CHARACTER_GROUP, Constants.ONE_WAY_PLATFORM_GROUP, false)
end

local function initialize()
	initializeCollisionGroups()

	CollectionService:GetInstanceAddedSignal(Constants.ONE_WAY_PLATFORM_TAG):Connect(onPlatformAdded)
	safePlayerAdded(onPlayerAdded)

	for _, platform in CollectionService:GetTagged(Constants.ONE_WAY_PLATFORM_TAG) do
		onPlatformAdded(platform)
	end
end

initialize()
