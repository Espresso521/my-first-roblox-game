local RunService = game:GetService("RunService")
-- 删掉原来的 StarterPlayer 检测逻辑，因为 Legacy 模式下不需要它

local character = script.Parent
print("LeanScript 启动！当前父级是: " .. character.Name) -- 调试日志

-- 确保这是 R15 角色
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local lowerTorso = character:WaitForChild("LowerTorso")
local rootJoint = lowerTorso:WaitForChild("Root")

local ROLL_ANGLE = math.rad(5)
local PITCH_ANGLE = math.rad(15)
local LEAN_SPEED = 15

local leanCFrame = CFrame.new()
local camera = workspace.CurrentCamera

local function onStepped(_: number, deltaTime: number)
	local moveVelocity = humanoid:GetMoveVelocity()
	local relativeVelocity = root.CFrame:VectorToObjectSpace(moveVelocity)

	local pitch = 0
	local roll = 0

	if humanoid.WalkSpeed ~= 0 then
        -- 计算前倾 (Z轴)
		pitch = math.clamp(relativeVelocity.Z / humanoid.WalkSpeed, -1, 1) * PITCH_ANGLE
        -- 计算侧倾 (X轴)
		roll = -math.clamp(relativeVelocity.X / humanoid.WalkSpeed, -1, 1) * ROLL_ANGLE
	end

	leanCFrame = leanCFrame:Lerp(CFrame.Angles(pitch, 0, roll), math.min(deltaTime * LEAN_SPEED, 1))
	rootJoint.Transform = leanCFrame * rootJoint.Transform

	--local velocity = character.HumanoidRootPart.Velocity
	--local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

	--local targetFov = math.clamp(
	--	70 + horizontalSpeed * 0.5,
	--	70,
	--	90
	--)

	--camera.FieldOfView = math.lerp(
	--	camera.FieldOfView,
	--	targetFov,
	--	0.1
	--)


end

RunService.Stepped:Connect(onStepped)
print("LeanScript 加载完成！")
