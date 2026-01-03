local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local simpleParticleBurst = require(Utility.simpleParticleBurst)
local simpleParticleTimed = require(Utility.simpleParticleTimed)

-- 获取你放在地图里的那个 Part
local myPart = workspace:WaitForChild("Part")

-- 定义一个函数来方便显示标题，这样你在 Output 窗口能看到当前在演示哪一个
local function showEffectLabel(name)
	print("--- 正在展示效果: " .. name .. " ---")
end

-- 1. 展示 Dash (冲刺/速度线)
-- 使用 simpleParticleTimed，因为它是一个持续性的效果
showEffectLabel("Dash (持续3秒)")
local dashTemplate = ReplicatedStorage.Platformer.Effects.DashParticles
simpleParticleTimed(dashTemplate, CFrame.new(), 3, myPart) -- 展示3秒
task.wait(4) -- 等待4秒（3秒展示 + 1秒淡出清理）

-- 2. 展示 Jump (起跳烟雾)
-- 使用 simpleParticleBurst，因为它是一个瞬间喷发的效果
showEffectLabel("Jump (起跳喷发)")
local jumpTemplate = ReplicatedStorage.Platformer.Effects.JumpParticles
simpleParticleBurst(jumpTemplate, CFrame.new(), myPart) -- 瞬间喷发
task.wait(2) -- 等待2秒看清楚效果

-- 3. 展示 WallImpact (撞墙火花)
showEffectLabel("WallImpact (撞击墙壁)")
local wallTemplate = ReplicatedStorage.Platformer.Effects.WallImpactParticles
simpleParticleBurst(wallTemplate, CFrame.new(), myPart)
task.wait(2)

-- 4. 展示 FloorImpact (落地冲击)
showEffectLabel("FloorImpact (落地回收)")
local floorTemplate = ReplicatedStorage.Platformer.Effects.FloorImpactParticles
simpleParticleBurst(floorTemplate, CFrame.new(), myPart)

print("--- 所有效果顺序演示完毕 ---")
