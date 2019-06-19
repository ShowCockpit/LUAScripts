-- ShowCockpit LUA Script: Ableton Link to Onyx FX
--   created on ShowCockpit v3.3.0
--   by Ricardo Dias
--   on 19-6-2019

-- Get 'Ableton Link' element
AbletonLink = GetElement('Ableton Link')
-- Get 'Onyx' element
Onyx = GetElement('Onyx')

while true do
	-- Gets the current tempo
	bpm = AbletonLink.GetTempo()
	
	-- Calculate the fader level (assuming speed recorded at 100%)
	faderLevel = math.sqrt(bpm/300)
	
	-- Move the Override fader to set the FX speed
	Onyx.MainPlaybackFader_FaderMove(8, faderLevel)
	
	sleep(0.01)
end