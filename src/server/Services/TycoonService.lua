local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TycoonService = {}

-- 定义物品的模板 (以后可以放在 Config 模块里)
local function spawnPart(dropper)
    local outputPos = dropper.CFrame * CFrame.new(0, 2, 0)

    local part = Instance.new("Part")
    part.Name = "Ore"
    part.Size = Vector3.new(1, 1, 1)
    part.Color = Color3.fromRGB(255, 255, 0)
    part.Material = Enum.Material.Neon
    part.CFrame = outputPos

    -- >>> 修改这里：先设置 Parent，再设置网络所有权 <<<

    -- 1. 先把它放进游戏世界
    part.Parent = workspace

    -- 2. 现在它在世界里了，物理引擎才能接管它
    part:SetNetworkOwner(nil)

    -- 加上销毁时间
    game:GetService("Debris"):AddItem(part, 30)
end

function TycoonService:Start()
    print("Tycoon 生产服务已启动！") -- 1. 确认服务启动了

    task.spawn(function()
        while true do
            task.wait(2)

            local allDroppers = CollectionService:GetTagged("Dropper")
            -- 2. 打印一下当前找到了几个 Dropper
            print("正在生产... 找到 Dropper 数量: " .. #allDroppers)

            for _, dropper in pairs(allDroppers) do
                spawnPart(dropper)
            end
        end
    end)
end

return TycoonService
