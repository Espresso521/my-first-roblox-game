-- src/server/init.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 游戏设置
local STARTING_MONEY = 0
local CLICK_VALUE = 1

---------------------------------------------------------
-- 1. 创建通信桥梁 (RemoteEvent)
---------------------------------------------------------
-- 我们检查一下是否已经有这个事件，没有就创建
-- 放在 ReplicatedStorage 里，这样客户端也能访问到
local clickEvent = ReplicatedStorage:FindFirstChild("ClickEvent")
if not clickEvent then
	clickEvent = Instance.new("RemoteEvent")
	clickEvent.Name = "ClickEvent"
	clickEvent.Parent = ReplicatedStorage
end

---------------------------------------------------------
-- 2. 玩家数据逻辑
---------------------------------------------------------
local function onPlayerAdded(player)
	print(player.Name .. " 加入游戏")

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = STARTING_MONEY
	money.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats
end

Players.PlayerAdded:Connect(onPlayerAdded)

---------------------------------------------------------
-- 3. 监听客户端的请求 (后厨接单)
---------------------------------------------------------
-- 当客户端发来信号时，执行这个函数
clickEvent.OnServerEvent:Connect(function(player)
	-- 注意：Roblox 自动帮我们在第一个参数填入“是谁点的”
	-- 这一点非常重要，防止A点击却给B加钱

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local money = stats:FindFirstChild("Money")
		if money then
			money.Value = money.Value + CLICK_VALUE
			-- 这里去掉了print，防止点击太快刷屏
		end
	end
end)
