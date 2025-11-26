-- src/server/init.server.lua
local Players = game:GetService("Players")

-- 游戏设置
local STARTING_MONEY = 0
local CLICK_VALUE = 1 -- 每次点击获得的钱

-- 当玩家加入游戏时
local function onPlayerAdded(player)
	print(player.Name .. " 加入了游戏！")

	-- 1. 创建 leaderstats (Roblox 默认的排行榜系统)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- 2. 创建金币 (Money)
	local money = Instance.new("IntValue")
	money.Name = "Money" -- 这里的名字会显示在右上角
	money.Value = STARTING_MONEY
	money.Parent = leaderstats

	-- 3. 创建重生次数 (Rebirths - 放置游戏常见机制)
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats
end

-- 当玩家离开时 (这里以后我们要加数据保存 DataStore)
local function onPlayerRemoving(player)
	print(player.Name .. " 离开了。")
end

-- 注册事件
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

---------------------------------------------------------
-- 创建一个临时的点击部分 (Part) 用于测试
-- 注意：实际开发中我们通常用 UI 按钮，但为了快速测试 Rojo 是否同步，我们先用 Part
---------------------------------------------------------

local function createClickerPart()
	local part = Instance.new("Part")
	part.Name = "ClickerPart"
	part.Size = Vector3.new(4, 1, 4)
	part.Position = Vector3.new(0, 5, 0)
	part.Color = Color3.fromRGB(0, 255, 128)
	part.Anchored = true
	part.Parent = workspace

	-- 创建点击探测器
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Parent = part

	-- 点击事件
	clickDetector.MouseClick:Connect(function(player)
		local stats = player:FindFirstChild("leaderstats")
		if stats then
			local money = stats:FindFirstChild("Money")
			if money then
				money.Value = money.Value + CLICK_VALUE
				print(player.Name .. " 赚了 $" .. CLICK_VALUE)
			end
		end
	end)
end

-- 生成测试方块
createClickerPart()
