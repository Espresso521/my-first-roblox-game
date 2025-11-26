local GridUtil = {}

local GRID_SIZE = 4 -- 每个格子 4x4 studs

-- 将世界坐标转换为网格坐标 (Round to nearest 4)
function GridUtil.SnapToGrid(position)
	local x = math.floor(position.X / GRID_SIZE + 0.5) * GRID_SIZE
	local z = math.floor(position.Z / GRID_SIZE + 0.5) * GRID_SIZE
	local y = position.Y -- Y轴通常保持不变或固定高度

	return Vector3.new(x, y, z)
end

-- 获取网格中心点的 CFrame
function GridUtil.GetGridCFrame(position, rotationY)
	local snappedPos = GridUtil.SnapToGrid(position)
	-- CFrame.Angles 使用弧度
	local rotation = CFrame.Angles(0, math.rad(rotationY or 0), 0)
	return CFrame.new(snappedPos) * rotation
end

return GridUtil
