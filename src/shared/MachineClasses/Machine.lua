local Machine = {}
Machine.__index = Machine

-- 构造函数
function Machine.new(model, owner)
	local self = setmetatable({}, Machine)
	self.Model = model
	self.Owner = owner
	self.IsActive = true

	-- 可以在这里初始化通用的逻辑，比如耐久度、通电状态
	return self
end

-- 虚方法：每帧更新 (就像 Unity 的 Update)
function Machine:Update(dt)
	-- 基类不做事，子类重写
end

function Machine:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
	self.IsActive = false
end

return Machine
