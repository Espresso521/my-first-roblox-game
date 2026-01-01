--[[
	CoinsScript - This script implements the coin pickup system. Leaderstats are used to keep track of
	the amount of coins each player has. Clients detect pickups locally for minimal latency, so this script
	does validation to ensure they are only able to pick up nearby coins.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage.Gameplay.Constants)
local validateInstance = require(ServerScriptService.Utility.TypeValidation.validateInstance)

local remotes = ReplicatedStorage.Gameplay.Remotes
local pickupCoinRemote = remotes.PickupCoin

local MAX_PICKUP_DISTANCE = 50

local playerCoins = {}

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats
end

local function onPlayerRemoving(player: Player)
	-- Clean up references so we don't leak memory
	if playerCoins[player] then
		playerCoins[player] = nil
	end
end

local function onPickupCoinFunction(player: Player, coin: BasePart): boolean
	-- Validate the argument being passed
	if not validateInstance(coin, "BasePart") then
		return false
	end

	-- Make sure the player is actually trying to pick up a coin
	if not coin:HasTag(Constants.COIN_TAG) then
		return false
	end

	-- Make sure the player hasn't already picked up this coin
	if not playerCoins[player] then
		playerCoins[player] = {}
	end
	if playerCoins[player][coin] then
		return false
	end

	-- Make sure the character is within a reasonable distance from the coin
	local character = player.Character
	if not character then
		return false
	end
	local distance = (character:GetPivot().Position - coin.Position).Magnitude
	if distance > MAX_PICKUP_DISTANCE then
		return false
	end

	-- Increment the player's Coins leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false
	end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then
		return false
	end
	coins.Value += 1

	-- Save this coin as picked up so the player can't pick it up multiple times
	-- This is stored per player since we want multiple players to be able to pick up each coin
	playerCoins[player][coin] = true

	-- Return true so the client knows it successfully picked up the coin
	return true
end

local function initialize()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	pickupCoinRemote.OnServerInvoke = onPickupCoinFunction
end

initialize()
