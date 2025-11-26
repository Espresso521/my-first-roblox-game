-- 引入模块
local PlacementService = require(script.Services.PlacementService)
local TycoonService = require(script.Services.TycoonService) -- <--- 确保引入了它

-- 初始化
PlacementService:Init()
TycoonService:Start()  -- <--- 【关键！】这一行必须有，否则生产循环不会开始
