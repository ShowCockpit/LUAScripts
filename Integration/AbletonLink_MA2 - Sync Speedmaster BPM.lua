-- ShowCockpit LUA Script: LUA Script
--   created on ShowCockpit v2.18.1
--   by Ricardo Dias
--   on 9-1-2019

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Get 'Ableton Link' element
AbletonLink = GetElement('Ableton Link')

-- Get 'GrandMA2' element
GrandMA2 = GetElement('GrandMA2')

lastBpm = -1
while true do
    bpm = AbletonLink.GetTempo()
    bpm = round(bpm, 2)
    
    if bpm ~= lastBpm then
    	GrandMA2.CommandExecute_ButtonClick('SpecialMaster 3.1 At ' .. bpm)
    	print(bpm)
    	lastBpm = bpm
    end
	
	sleep(0.01)
end
