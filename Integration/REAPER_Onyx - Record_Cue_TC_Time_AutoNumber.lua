-- ShowCockpit LUA Script: Set Cue TC Time
--   created on ShowCockpit v2.15.2
--   by Ricardo Dias
--   on 14-11-2018

-- Config
FPS = 30
sleepTime = 0.1 -- increase if needed

-- Elements
REAPER = GetElement('REAPER - Web')
Onyx = GetElement('Onyx')

-- Get the last received TC Sync total seconds
v = REAPER.GetLastValue_TCSyncSeconds('Timecode Sync')

total = math.floor(v)
tFrames = math.floor((v - total) * FPS);
tSec = math.floor(total % 60);
total = total / 60;
tMin = math.floor(total % 60);
tHours = math.floor(total / 60);

-- Print the current TC time 
print(string.format("%02d:%02d:%02d,%02d", tHours , tMin , tSec , tFrames))

-- Concatenate hours, minutes, seconds and frames to a string
cueNumber = string.format("%02d%02d%02d%02d", tHours , tMin , tSec , tFrames)

-- Remove leading zeroes
cueNumberNoZeros = cueNumber:match("0*(%d+)")

-- Print the cue number to the console for debug
print('cue number = ' .. cueNumberNoZeros)

-- Record cue with MERGE = true
Onyx.RecordCue(cueNumberNoZeros, true)

sleep(sleepTime)

-- Set the TC time for that cue
Onyx.SetCueTCTime(cueNumberNoZeros, cueNumber)