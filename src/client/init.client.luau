-- src/client/init.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 获取本地玩家（就是你自己）
local player = Players.LocalPlayer
-- 获取玩家的 UI 容器
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- 1. 用代码画一个简单的 UI
-- (通常我们会用 Roblox Studio 的界面编辑器画，
-- 但为了保持纯代码流程，我们先用代码生成)
---------------------------------------------------------

-- 创建屏幕 UI 容器
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameUI"
screenGui.Parent = playerGui

-- 创建一个“点击按钮”
local clickButton = Instance.new("TextButton")
clickButton.Name = "ClickButton"
clickButton.Size = UDim2.new(0, 200, 0, 100) -- 宽200像素，高100像素
clickButton.Position = UDim2.new(0.5, -100, 0.8, 0) -- 屏幕底部居中
clickButton.Text = "点击赚钱!"
clickButton.TextSize = 30
clickButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0) -- 橙色
clickButton.Parent = screenGui

-- 加上圆角让它好看点
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 20)
uiCorner.Parent = clickButton

---------------------------------------------------------
-- 2. 处理点击逻辑 (顾客点单)
---------------------------------------------------------

-- 等待“服务员”到位
local clickEvent = ReplicatedStorage:WaitForChild("ClickEvent")

-- 客户端防抖动 (CoolDown) - 可选，防止点击过快卡顿
local DEBOUNCE = false

clickButton.MouseButton1Click:Connect(function()
	if DEBOUNCE then return end
	DEBOUNCE = true

	-- 播放一个小动画：按钮变小
	clickButton:TweenSize(UDim2.new(0, 180, 0, 90), "Out", "Quad", 0.1, true)

	-- >>> 关键一步：呼叫服务器 <<<
	clickEvent:FireServer()

	-- 动画恢复
	wait(0.1)
	clickButton:TweenSize(UDim2.new(0, 200, 0, 100), "Out", "Bounce", 0.1, true)
	DEBOUNCE = false
end)
