--[[
	playSoundFromSource - A utility function to clone and play an audio player, routing it to a specified target,
	and destroying it once it has finished playing.
--]]

local function playSoundFromSource(playerTemplate: AudioPlayer, target: Instance, pitchAdjustment: number?)
	local audioPlayer = playerTemplate:Clone()
	if pitchAdjustment then
		audioPlayer.PlaybackSpeed *= pitchAdjustment
	end

	local wire = Instance.new("Wire")
	wire.SourceInstance = audioPlayer
	wire.TargetInstance = target
	wire.Parent = audioPlayer

	audioPlayer.Parent = target

	audioPlayer:Play()
	audioPlayer.Ended:Once(function()
		audioPlayer:Destroy()
	end)
end

return playSoundFromSource
