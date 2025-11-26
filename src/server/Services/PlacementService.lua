-- src/server/Services/PlacementService.lua
local CollectionService = game:GetService('CollectionService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Assets = ReplicatedStorage:WaitForChild("Assets") -- <--- 获取资源

local PlaceEvent = ReplicatedStorage:FindFirstChild("PlaceItemEvent")
if not PlaceEvent then
	PlaceEvent = Instance.new("RemoteEvent")
	PlaceEvent.Name = "PlaceItemEvent"
	PlaceEvent.Parent = ReplicatedStorage
end

local PlacementService = {}

function PlacementService:Init()
	PlaceEvent.OnServerEvent:Connect(function(player, itemId, cframe)
		self:PlaceItem(player, itemId, cframe)
	end)
end

function PlacementService:PlaceItem(player, itemId, cframe)
	-- 1. 安全检查：确保玩家请求的是合法的物品
	local template = Assets:FindFirstChild(itemId)
	if not template then
		warn(player.Name .. " 尝试放置不存在的物品: " .. tostring(itemId))
		return
	end

	-- TODO: 在这里加扣钱逻辑 (check if money >= cost)
	-- TODO: 在这里加碰撞检查 (check if grid is empty)

	-- 2. 克隆实体
	local newItem = template:Clone()
	newItem.Name = itemId

  -- >>> 新增：如果是 Dropper，就给它打个标签 <<<
  if itemId == "Dropper" then
      CollectionService:AddTag(newItem, "Dropper")
      -- 在物体里存一下“谁是主人”，方便以后给钱
      newItem:SetAttribute("Owner", player.Name)
      print("已给新物体打上 Dropper 标签")
  end

	-- 3. 设置位置
	if newItem:IsA("Model") then
		newItem:SetPrimaryPartCFrame(cframe)
	else
		newItem.CFrame = cframe
		newItem.Anchored = true -- 确保它是固定的
	end

	-- 4. 放到 Workspace
	-- 建议创建一个文件夹专门放玩家建筑，保持整洁
	local playerFolder = workspace:FindFirstChild(player.Name .. "_Tycoon")
	if not playerFolder then
		playerFolder = Instance.new("Folder")
		playerFolder.Name = player.Name .. "_Tycoon"
		playerFolder.Parent = workspace
	end

	newItem.Parent = playerFolder

	print(player.Name .. " 放置了 " .. itemId)
end

return PlacementService
