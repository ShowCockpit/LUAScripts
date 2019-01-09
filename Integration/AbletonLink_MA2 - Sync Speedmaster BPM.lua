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
        -- Account for phase
    	phase = AbletonLink.GetPhase()
    	intPhase = math.floor(phase)
    	subPhase = phase - intPhase;
        remPhase = 1.0 - subPhase;
        beatTime = (60 / bpm) * 1000;
        waitTimeMS = math.floor(remPhase * beatTime);
        
        sleep(waitTimeMS / 1000)
    
    	GrandMA2.CommandExecute_ButtonClick('SpecialMaster 3.1 At ' .. bpm)
    	print(bpm)
    	lastBpm = bpm
    end
	
    sleep(0.05)
end
