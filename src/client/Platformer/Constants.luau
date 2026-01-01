local StarterPlayer = game:GetService("StarterPlayer")

local Constants = {
	-- Input management
	KEYBOARD_SPECIAL_KEY_CODE = Enum.KeyCode.LeftShift,
	GAMEPAD_SPECIAL_KEY_CODE = Enum.KeyCode.ButtonX,
	CONTROLLER_RENDER_STEP_BIND = "PlatformerControl",
	SPECIAL_ACTION_BIND = "Dash/Roll",
	-- Distance check for walls during long jump
	WALL_CHECK_RADIUS = 1,
	-- Attributes
	ACTION_ATTRIBUTE = "action",
	REPLICATED_ACTION_ATTRIBUTE = "replicatedAction",
	LAST_GROUNDED_ATTRIBUTE = "lastGrounded",
	LAST_TIME_FORMAT_STRING = "last%s",
	-- Jump
	JUMP_COOLDOWN = 0.15,
	-- "Coyote time" refers to a small amount of time after stepping off an edge where the
	-- character is still allowed to jump. This allows for better game feel when jumping
	-- off the edges of platforms.
	JUMP_COYOTE_TIME = 0.15,
	-- Climbing
	LADDER_EJECT_SPEED = 15,
	-- Acceleration
	GROUND_ACCELERATION = 20,
	AIR_ACCELERATION = 15,
	WATER_ACCELERATION = 10,
	LADDER_ACCELERATION = 20,
	-- Double jump
	CAN_DOUBLE_JUMP_ATTRIBUTE = "canDoubleJump",
	DOUBLE_JUMP_HEIGHT = StarterPlayer.CharacterJumpHeight,
	-- Roll
	ROLL_SPEED = 60,
	ROLL_FORCE_FACTOR = 1500,
	ROLL_TIME = 0.35,
	ROLL_COOLDOWN = 0.2,
	-- Dash
	CAN_DASH_ATTRIBUTE = "canDash",
	DASH_SPEED = 60,
	DASH_FORCE_FACTOR = 1500,
	DASH_TIME = 0.2,
	--  Long jump
	LONG_JUMP_SPEED = 60,
	LONG_JUMP_HEIGHT = 7,
	LONG_JUMP_FORCE_FACTOR = 1500,
	-- The long jump window is the time period after rolling where a player can trigger a long jump
	LONG_JUMP_WINDOW = 0.3,
	-- Stun
	STUN_FORCE_FACTOR = 1500,
	STUN_BOUNCE_SPEED = 25,
	STUN_BOUNCE_HEIGHT = 3,
	-- Recover
	RECOVER_TIME = 0.5,
	-- Camera smoothing
	CAMERA_SMOOTH_HORIZONTAL_SPEED = 20,
	CAMERA_SMOOTH_VERTICAL_SPEED = 5,
	CAMERA_MAX_DISTANCE = 8,
	-- Effects
	EFFECTS_MAX_DISTANCE = 250,
	-- Animations
	ACTION_ANIMATION_FADE_TIME = 0.1,
}

return Constants
