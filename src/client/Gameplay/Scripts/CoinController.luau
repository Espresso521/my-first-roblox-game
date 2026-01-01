--[[
	CoinController - This module script implements the class for a coin pickup. Touch events are
	connected to on the client in order to minimize visual latency when picking up coins.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Gameplay.Constants)
local disconnectAndClear = require(ReplicatedStorage.Utility.disconnectAndClear)
local playSoundFromSource = require(ReplicatedStorage.Utility.playSoundFromSource)
local simpleParticleBurst = require(ReplicatedStorage.Utility.simpleParticleBurst)

local player = Players.LocalPlayer
local visualTemplate = ReplicatedStorage.Gameplay.Objects.Coin
local pickupSoundTemplate = ReplicatedStorage.Gameplay.Sounds.PickupCoin
local pickupParticlesTemplate = ReplicatedStorage.Gameplay.Effects.PickupParticles
local remotes = ReplicatedStorage.Gameplay.Remotes
local pickupCoinRemote = remotes.PickupCoin

local coinHapticTemplate = script.CoinHaptic
local audioEmitterTemplate = script.CoinAudioEmitter

local pickupSoundPitch = 1
local lastPickup = 0
-- We'll use a table to store which coins have been picked up, since locally set attributes will not persist if a coin is streamed out and back in
local pickedUpCoins = {}

local CoinController = {}
CoinController.__index = CoinController

function CoinController.new(coin: BasePart)
	local visual = visualTemplate:Clone()
	visual:PivotTo(coin.CFrame)
	visual.Parent = Workspace

	-- Add an audio emitter
	local audioEmitter = audioEmitterTemplate:Clone()
	audioEmitter.Parent = coin

	local hapticEffect = coinHapticTemplate:Clone()
	hapticEffect.Parent = coin

	local self = {
		coin = coin,
		visual = visual,
		audioEmitter = audioEmitter,
		hapticEffect = hapticEffect,
		connections = {},
	}
	setmetatable(self, CoinController)

	self:initialize()

	return self
end

function CoinController:initialize()
	-- When the coin is touched by our character we'll try to pick it up.
	-- Touches are being detected locally so that picking up feels super responsive.
	table.insert(
		self.connections,
		self.coin.Touched:Connect(function(hit: BasePart)
			if hit.Parent == player.Character then
				self:tryPickup()
			end
		end)
	)

	self:updateVisibility()
end

function CoinController:tryPickup()
	-- Make sure we haven't already picked up this coin
	local isPickedUp = pickedUpCoins[self.coin]
	if isPickedUp then
		return
	end

	-- Pitch up the pickup sound as we pick up coins, reseting it back to 1 if it's been too long between pickups
	local timeSinceLastPickup = os.clock() - lastPickup
	lastPickup = os.clock()

	if timeSinceLastPickup > Constants.COIN_PICKUP_SOUND_PITCH_RESET_TIME then
		pickupSoundPitch = 1
	else
		pickupSoundPitch += Constants.COIN_PICKUP_SOUND_PITCH_INCREASE
	end

	-- Play the pickup sound and a particle effect
	playSoundFromSource(pickupSoundTemplate, self.audioEmitter, pickupSoundPitch)
	simpleParticleBurst(pickupParticlesTemplate, self.coin.CFrame)
	self.hapticEffect:Play()

	-- Immediately mark the coin as picked up so we don't try to pick it up multiple times
	pickedUpCoins[self.coin] = true
	self:updateVisibility()
	-- Tell the server that we're trying to pick up a coin
	local success = pickupCoinRemote:InvokeServer(self.coin)

	-- If the server rejects our request, mark the coin as no longer picked up
	if not success then
		pickedUpCoins[self.coin] = false
		self:updateVisibility()
	end
end

function CoinController:updateVisibility()
	local isPickedUp = pickedUpCoins[self.coin]

	-- If the coin has been picked up, make it transparent
	for _, descendant in self.visual:GetDescendants() do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			descendant.LocalTransparencyModifier = if isPickedUp then Constants.COIN_PICKUP_TRANSPARENCY else 0
		elseif descendant:IsA("Light") then
			descendant.Enabled = not isPickedUp
		end
	end
end

function CoinController:destroy()
	disconnectAndClear(self.connections)
	self.visual:Destroy()
	self.audioEmitter:Destroy()
	self.hapticEffect:Destroy()
end

return CoinController
