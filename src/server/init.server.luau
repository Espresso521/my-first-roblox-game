-- src/server/init.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---------------------------------------------------------
-- 1. 初始化远程事件 (RemoteEvents)
---------------------------------------------------------
-- 封装一个函数来创建或获取事件
local function getRemoteEvent(name)
	local event = ReplicatedStorage:FindFirstChild(name)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = ReplicatedStorage
	end
	return event
end

local clickEvent = getRemoteEvent("ClickEvent")
local upgradeEvent = getRemoteEvent("BuyUpgrade") -- 新增：购买升级事件

---------------------------------------------------------
-- 2. 玩家数据初始化
---------------------------------------------------------
local function onPlayerAdded(player)
	-- 创建 leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- 金币 (Money)
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 0
	money.Parent = leaderstats

	-- 点击力量 (ClickPower) - 新增！
	-- 我们把它放在 leaderstats 里，这样你能在右上角看到你的力量等级
	local clickPower = Instance.new("IntValue")
	clickPower.Name = "ClickPower"
	clickPower.Value = 1 -- 初始每次点击赚 1 块
	clickPower.Parent = leaderstats
end

Players.PlayerAdded:Connect(onPlayerAdded)

---------------------------------------------------------
-- 3. 处理交互逻辑
---------------------------------------------------------

-- 处理：点击赚钱
clickEvent.OnServerEvent:Connect(function(player)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local money = stats.Money
		local power = stats.ClickPower

		-- 现在的赚钱公式：当前金币 + 当前点击力量
		money.Value = money.Value + power.Value
	end
end)

-- 处理：购买升级 (新功能)
upgradeEvent.OnServerEvent:Connect(function(player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end

	local money = stats.Money
	local power = stats.ClickPower

	-- === 升级公式 ===
	-- 价格 = 当前力量 * 10 (例如：1级升2级要10块，10级升11级要100块)
	local upgradeCost = power.Value * 10

	if money.Value >= upgradeCost then
		-- 扣钱
		money.Value = money.Value - upgradeCost
		-- 增加力量
		power.Value = power.Value + 1
		print(player.Name .. " 升级成功！当前力量: " .. power.Value)
	else
		print("金币不足！需要: " .. upgradeCost)
	end
end)
