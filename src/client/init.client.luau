-- src/client/init.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- 等待数据加载
local leaderstats = player:WaitForChild("leaderstats")
local money = leaderstats:WaitForChild("Money")
local clickPower = leaderstats:WaitForChild("ClickPower")

-- 获取远程事件
local clickEvent = ReplicatedStorage:WaitForChild("ClickEvent")
local upgradeEvent = ReplicatedStorage:WaitForChild("BuyUpgrade")

---------------------------------------------------------
-- 1. UI 搭建 (使用代码构建)
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TycoonUI"
screenGui.ResetOnSpawn = false -- 玩家死后UI不消失
screenGui.Parent = playerGui

-- === A. 顶部金币显示 ===
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Name = "MoneyDisplay"
moneyLabel.Size = UDim2.new(0, 300, 0, 50)
moneyLabel.Position = UDim2.new(0.5, -150, 0.05, 0) -- 屏幕顶部居中
moneyLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
moneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- 金色
moneyLabel.TextSize = 24
moneyLabel.Font = Enum.Font.FredokaOne -- 卡通字体
moneyLabel.Text = "金币: $0"
moneyLabel.Parent = screenGui
-- 加个圆角
local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 10)
startCorner.Parent = moneyLabel

-- === B. 中间点击按钮 ===
local mainButton = Instance.new("TextButton")
mainButton.Name = "ClickButton"
mainButton.Size = UDim2.new(0, 50, 0, 50)
mainButton.Position = UDim2.new(0.5, -100, 0.5, -100) -- 正中心
mainButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
mainButton.Text = "点我!"
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.TextSize = 40
mainButton.Font = Enum.Font.FredokaOne
mainButton.Parent = screenGui
Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0) -- 变成圆形

-- === C. 右侧升级按钮 ===
local upgradeButton = Instance.new("TextButton")
upgradeButton.Name = "UpgradeButton"
upgradeButton.Size = UDim2.new(0, 150, 0, 80)
upgradeButton.Position = UDim2.new(1, -170, 0.5, -40) -- 靠右
upgradeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
upgradeButton.Text = "升级\n($10)"
upgradeButton.TextSize = 20
upgradeButton.Font = Enum.Font.SourceSansBold
upgradeButton.Parent = screenGui
Instance.new("UICorner", upgradeButton).CornerRadius = UDim.new(0, 8)

---------------------------------------------------------
-- 2. 逻辑绑定 (让 UI 动起来)
---------------------------------------------------------

-- 辅助函数：计算当前升级价格 (必须和服务器公式一致)
local function getUpgradeCost()
	return clickPower.Value * 10
end

-- A. 更新 UI 的函数
local function updateUI()
	moneyLabel.Text = "金币: $" .. money.Value
	upgradeButton.Text = "升级力量\n(花费: $" .. getUpgradeCost() .. ")"
end

-- B. 监听数据变化 (Reactive UI)
-- 只要 money 或 clickPower 的值一变，立刻刷新界面
money.Changed:Connect(updateUI)
clickPower.Changed:Connect(updateUI)

-- 初始化显示一次
updateUI()

-- C. 按钮点击事件
local debounce = false

-- 点击赚钱
mainButton.MouseButton1Click:Connect(function()
	if debounce then return end
	debounce = true

	-- 简单的缩放动画
	mainButton:TweenSize(UDim2.new(0, 180, 0, 180), "Out", "Quad", 0.05, true)
	clickEvent:FireServer() -- 呼叫服务器
	wait(0.05)
	mainButton:TweenSize(UDim2.new(0, 200, 0, 200), "Out", "Bounce", 0.1, true)

	debounce = false
end)

-- 购买升级
upgradeButton.MouseButton1Click:Connect(function()
	-- 可以在这里先做一个本地判断，如果钱不够就让按钮变红提示一下
	if money.Value >= getUpgradeCost() then
		upgradeEvent:FireServer() -- 呼叫服务器购买
	else
		-- 钱不够的视觉反馈
		upgradeButton.Text = "钱不够!"
		upgradeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		wait(1)
		updateUI() -- 恢复文字
		upgradeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	end
end)
