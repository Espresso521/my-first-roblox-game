--[[
	MovingPlatformsScript - This script creates and destroys MovingPlatformController classes as necessary for any
	instances tagged with Constants.MOVING_PLATFORM_TAG.
--]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Gameplay.Constants)
local MovingPlatformController = require(script.Parent.MovingPlatformController)

local movingPlatformControllers = {}

local function onMovingPlatformAdded(platform: Instance)
	if movingPlatformControllers[platform] then
		return
	end

	local controller = MovingPlatformController.new(platform)
	movingPlatformControllers[platform] = controller

	controller:move()
end

local function onMovingPlatformRemoved(platform: Instance)
	if movingPlatformControllers[platform] then
		movingPlatformControllers[platform]:destroy()
		movingPlatformControllers[platform] = nil
	end
end

local function initialize()
	CollectionService:GetInstanceAddedSignal(Constants.MOVING_PLATFORM_TAG):Connect(onMovingPlatformAdded)
	CollectionService:GetInstanceRemovedSignal(Constants.MOVING_PLATFORM_TAG):Connect(onMovingPlatformRemoved)

	for _, platform in CollectionService:GetTagged(Constants.MOVING_PLATFORM_TAG) do
		onMovingPlatformAdded(platform)
	end
end

initialize()
