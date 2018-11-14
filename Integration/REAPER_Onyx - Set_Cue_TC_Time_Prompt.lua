-- ShowCockpit LUA Script: Set Cue TC Time Prompt
--   created on ShowCockpit v2.15.2
--   by Ricardo Dias
--   on 13-11-2018

-- Config
FPS = 30

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

print(string.format("%02d:%02d:%02d,%02d", tHours , tMin , tSec , tFrames))

-- Start creating the prompt
test = CreatePrompt('Enter Cue Number', 'Enter the cue number below')
test.SetType('TextInput')
test.SetDefaultValue('1')
res = test.Show()

if res['button'] == 'OK' then
	print(res['input'])
	Onyx.SetCueTCTime(res['input'], string.format("%02d%02d%02d%02d", tHours , tMin , tSec , tFrames))
end