-- src/client/Controllers/PlacementController.lua
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local GridUtil = require(ReplicatedStorage.Shared.GridUtil)
local PlaceEvent = ReplicatedStorage:WaitForChild("PlaceItemEvent")
local Assets = ReplicatedStorage:WaitForChild("Assets") -- <--- 新增：获取资源文件夹

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local PlacementController = {}
PlacementController.CurrentItem = "Conveyor" -- 确保这个名字和 Assets 里的名字一样
PlacementController.Rotation = 0
PlacementController.GhostPart = nil

function PlacementController:Start()
	RunService.RenderStepped:Connect(function()
		self:UpdateGhost()
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		-- 按 R 旋转
		if input.KeyCode == Enum.KeyCode.R then
			self:Rotate()
		-- 鼠标左键放置
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:RequestPlace()
		-- 按数字键切换物品 (临时功能，方便测试)
		elseif input.KeyCode == Enum.KeyCode.One then
			self:SetItem("Conveyor")
		elseif input.KeyCode == Enum.KeyCode.Two then
			self:SetItem("Dropper")
		elseif input.KeyCode == Enum.KeyCode.Three then
			self:SetItem("Furnace")
		end
	end)
end

-- 新增：切换物品清理旧虚影
function PlacementController:SetItem(itemName)
	if self.GhostPart then
		self.GhostPart:Destroy()
		self.GhostPart = nil
	end
	self.CurrentItem = itemName
end

function PlacementController:UpdateGhost()
	local ray = workspace.CurrentCamera:ScreenPointToRay(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character, self.GhostPart} -- 忽略玩家和虚影自己
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(ray.Origin, ray.Direction * 100, raycastParams)

	if result then
		local cframe = GridUtil.GetGridCFrame(result.Position + Vector3.new(0, 0, 0), self.Rotation) -- Y轴可能需要根据模型高度微调

		-- 如果还没有虚影，就克隆一个新的
		if not self.GhostPart then
			local template = Assets:FindFirstChild(self.CurrentItem)
			if template then
				self.GhostPart = template:Clone()
				self.GhostPart.Name = "Ghost"
				self.GhostPart.CanCollide = false
				self.GhostPart.Anchored = true

				-- 把模型变透明、变绿 (Ghost 效果)
				if self.GhostPart:IsA("BasePart") then
					self.GhostPart.Transparency = 0.5
					self.GhostPart.Color = Color3.fromRGB(0, 255, 0) -- 绿色虚影
				else
					-- 如果是 Model，需要遍历里面所有零件
					for _, child in pairs(self.GhostPart:GetDescendants()) do
						if child:IsA("BasePart") then
							child.Transparency = 0.5
							child.Color = Color3.fromRGB(0, 255, 0)
							child.CanCollide = false
						end
					end
				end

				self.GhostPart.Parent = workspace
			end
		end

		-- 更新位置
		if self.GhostPart then
			if self.GhostPart:IsA("Model") then
				self.GhostPart:SetPrimaryPartCFrame(cframe)
			else
				self.GhostPart.CFrame = cframe
			end
		end
	else
		-- 鼠标指着天空时，隐藏虚影
		if self.GhostPart then
			self.GhostPart:Destroy()
			self.GhostPart = nil
		end
	end
end

function PlacementController:Rotate()
	self.Rotation = self.Rotation + 90
end

function PlacementController:RequestPlace()
	if self.GhostPart then
		-- 发送 CFrame 给服务器
		local cf = self.GhostPart:IsA("Model") and self.GhostPart:GetPrimaryPartCFrame() or self.GhostPart.CFrame
		PlaceEvent:FireServer(self.CurrentItem, cf)
	end
end

return PlacementController
