--[[
	safePlayerAdded - A utility function to run a callback for all players who join the server as
	well as any players currently in the server. The PlayerAdded connection is returned so that
	it can be disconnected if necessary.
--]]

local Players = game:GetService("Players")

local function safePlayerAdded(callback: (Player) -> ())
	for _, player in Players:GetPlayers() do
		task.spawn(callback, player)
	end

	return Players.PlayerAdded:Connect(callback)
end

return safePlayerAdded
