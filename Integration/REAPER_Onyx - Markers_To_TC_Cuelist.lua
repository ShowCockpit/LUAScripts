-- ShowCockpit LUA Script: Populate TC Cuelist
--   created on ShowCockpit v2.15.2
--   by Ricardo Dias
--   on 14-11-2018

-- Config
FPS = 30
sleepTime = 0.2 -- increase if needed

-- Get element with TC source
REAPER = GetElement('REAPER - Web')
Onyx = GetElement('Onyx')

Onyx.ClearProgrammer()

markers = REAPER.GetMarkers()

-- Iterate through markers list
for k,v in pairs(markers) do
	print('Marker "'.. k ..'": ID = ' .. v["id"] .. ' @ ' .. v["position"])
	
	-- Get marker data into variables
	name = k
	id = v["id"]
	v = v["position"]
	
	total = math.floor(v)
	tFrames = math.floor((v - total) * FPS);
	tSec = math.floor(total % 60);
	total = total / 60;
	tMin = math.floor(total % 60);
	tHours = math.floor(total / 60);
	
	print(string.format("%02d:%02d:%02d,%02d", tHours , tMin , tSec , tFrames))
	
	-- Record cue with MERGE = true
	Onyx.RecordCue(id, true)
	
	sleep(sleepTime)
	
	-- Rename cue
	Onyx.RenameCue(id, name)
	
	sleep(sleepTime)
	
	-- Set the TC time for that cue
	tcTime = string.format("%02d%02d%02d%02d", tHours , tMin , tSec , tFrames)
	Onyx.SetCueTCTime(id, tcTime)

end

