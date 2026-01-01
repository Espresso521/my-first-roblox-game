--[[
	SmoothCameraScript - Smooths the camera's motion following the character, allowing different
	speeds for vertical and horizontal motion.

	Rather than directly smoothing the camera motion, an offset is applied based on the character's velocity.
	This avoids jitter issues caused by desync between the render framerate and physics step rate.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Platformer.Constants)
local clampMagnitude = require(ReplicatedStorage.Utility.clampMagnitude)

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

local root = nil

local offsetXZ = Vector3.zero
local offsetY = Vector3.zero

local function onCharacterAdded(character: Model)
	root = character:WaitForChild("HumanoidRootPart")
end

local function onRenderStep(deltaTime: number)
	if not root then
		return
	end

	-- Offset the camera in the opposite direction of the character's velocity so it lags behind
	offsetXZ -= Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z) * deltaTime
	offsetY -= Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) * deltaTime

	-- Clamp the offset so we don't lose sight of the character when it's moving fast
	offsetXZ = clampMagnitude(offsetXZ, Constants.CAMERA_MAX_DISTANCE)
	offsetY = clampMagnitude(offsetY, Constants.CAMERA_MAX_DISTANCE)

	-- Lerp the offset back to zero so the camera doesn't get left behind
	offsetXZ = offsetXZ:Lerp(Vector3.zero, math.min(deltaTime * Constants.CAMERA_SMOOTH_HORIZONTAL_SPEED, 1))
	offsetY = offsetY:Lerp(Vector3.zero, math.min(deltaTime * Constants.CAMERA_SMOOTH_VERTICAL_SPEED, 1))

	-- Apply the offset to the camera
	local offset = offsetXZ + offsetY
	camera.CFrame += offset
end

local function initialize()
	player.CharacterAdded:Connect(onCharacterAdded)
	RunService:BindToRenderStep("CameraSmoothing", Enum.RenderPriority.Camera.Value + 1, onRenderStep)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

initialize()
