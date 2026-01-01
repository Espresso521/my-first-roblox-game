--[[
	DoubleJump - Jump a second time in the air by setting the character's vertical velocity.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Platformer.Constants)
local calculateVelocityForHeight = require(ReplicatedStorage.Utility.calculateVelocityForHeight)
local setVerticalVelocity = require(ReplicatedStorage.Utility.setVerticalVelocity)

local Action = {
	clearOnGrounded = true,
	animation = "DoubleJump",
	effect = "Jump",
	sound = "DoubleJump",
}

-- Double jump!
function Action.perform(characterController)
	-- Make sure the character is currently allowed to double jump
	local canDoubleJump = characterController.character:GetAttribute(Constants.CAN_DOUBLE_JUMP_ATTRIBUTE)
	if not canDoubleJump then
		return
	end

	-- Don't let the character double jump during an air dash, since that will cut it short
	local timeSinceLastDash = characterController:getTimeSinceAction("Dash")
	if timeSinceLastDash < Constants.DASH_TIME then
		return
	end

	characterController.character:SetAttribute(Constants.CAN_DOUBLE_JUMP_ATTRIBUTE, false)
	characterController:setAction("DoubleJump")

	-- Set the character's vertical velocity to make them double jump
	local jumpVelocity = calculateVelocityForHeight(Constants.DOUBLE_JUMP_HEIGHT)
	setVerticalVelocity(characterController.root, jumpVelocity)
end

return Action
