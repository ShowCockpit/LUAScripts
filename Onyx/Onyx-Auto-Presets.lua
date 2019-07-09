-- ShowCockpit LUA Script: DeleteRangeOfCuelist
--   created on ShowCockpit v2.15.2
--   by Spb8 Lighting
--   on 15-11-2018

-------------
-- Purpose --
-------------
-- This script allows to create automatically presets based on a fixture selection

---------------
-- Changelog --
---------------
-- 09-09-2019 - 0.1: Allow to adjust the preset creation position + For Color preset, the Color Palette choice (Basic or Full) is asked back (previous choice kept) to enhance the workflow
-- 05-01-2019 - 0.0.1: Preset Populate is active
-- 04-01-2019 - 0.0.0.1: Preset creation works, not the populate part
-- 06-12-2018 - 0.0.0.0.0.1: Initialisation, not working yet
-- 16-11-2018 - 0.0.0.0.0.0.1: Initialisation, not working yet

-------------------
-- Configuration --
-------------------

Settings = {
  WaitTime = 0.5,
  PresetStartPosition = {}
}

ScriptInfos = {
	version = "0.1",
	name = "AutoPresets"
}

-- ShowCockpit LUA Script: LuaHeader for Spb8 Lighting LUA Script

---------------
-- Changelog --
---------------
-- 04-01-2019 - 1.6: RecordPreset() function has been added
-- 29-12-2018 - 1.5: DeleteGroup() function & ListGroup() has been added
-- 16-11-2018 - 1.4: InputNumber() function now accept MinValue as Infos to SetMinValue (default stays 1)
-- 08-11-2018 - 1.3: New InputText() function
--							+	New replace() function
-- 07-09-2018 - 1.2: Fix input number max issue
--              + add Word.Script.Cancel text value
--              + add Form.Preset list values
--              + update Default Preset Appearance to match Onyx Colors
--              + reword some function parameter name
--              + add ListCuelit()
--              + add the possibility to define default value for InputNumber and InputFloatNumber
-- 06-09-2018 - 1.1: Add Preset Name Framing, Add Generic GetPresetName, Add Generic DeletePreset
-- 05-09-2018 - 1.0: Creation

--------------------
--    Variables   --
--------------------

if Settings.WaitTime == nil or Settings.WaitTime == "" then
	Settings.WaitTime = 0.5
end

PresetName = {
  Intensity = "Intensity",
	PanTilt = "PanTilt",
	Color = "Color",
	Gobo = "Gobo",
	Beam = "Beam",
	BeamFX = "BeamFX",
	Framing = "Framing"
}

ScriptInfos = {
	version = ScriptInfos.version,
	name = ScriptInfos.name,
	author = "Sylvain Guiblain",
	contact = "sylvain.guiblain@gmail.com",
	website = "https://github.com/Spb8Lighting/OnyxLuaScripts"
}

Infos = {
	Sentence = "Scripted by " .. ScriptInfos.author .. "\r\n\r\n" .. ScriptInfos.contact .. "\r\n\r\n" .. ScriptInfos.website,
	Script = ScriptInfos.name .. " v" .. ScriptInfos.version
}

Appearance = {
	White = "#-1551",
	Red = "#-2686966",
	Orange = "#-33280",
	Yellow = "#-2560",
	Lime = "#-3342592",
	Green = "#-16711936",
	Cyan = "#-167714241",
	LightBlue = "#-16746497",
	Blue = "#-16769537",
	Uv = "#-13959025",
	Pink = "#-52996",
	Magenta = "#-65333"
}

DefaultAppearance = {
	Intensity = Appearance.White,
	PanTilt = Appearance.Red,
	Color = Appearance.White,
  Gobo = Appearance.Green,
	Beam = Appearance.Yellow,
	BeamFX = Appearance.Cyan,
	Framing = Appearance.Magenta
}

BPMTiming = {
	Half = "1/2",
	Third = "1/3",
	Quarter = "1/4"
}

Word = {
	Script = {
			Cancel = "Script has been cancelled! Nothing performed."
	},
	Ok = "Ok",
	Cancel = "Cancel",
	Reset = "Reset",
	Yes = "Yes",
	No = "No",
	Vertical = "Vertical",
	Horizontal = "Horizontal"
}

Form = {
	Ok = {
		Word.Ok
	},
	OkCancel = {
		Word.Ok,
		Word.Cancel
	},
	YesNo = {
		Word.Yes,
		Word.No
    },
	Preset = {
		PresetName.Intensity,
		PresetName.PanTilt,
		PresetName.Color,
		PresetName.Gobo,
		PresetName.Beam,
		PresetName.BeamFX,
		PresetName.Framing
	}
}

-- Get Onyx Software object

Onyx = GetElement("Onyx")

--------------------
--General Function--
--------------------

function HeadPrint()
	LogInformation(Infos.Script .. "\r\n\t" .. Infos.Sentence) --Notification
end

function FootPrint(Sentence)
	LogInformation(Sentence .. "\r\n\t" .. Infos.Sentence)
	Infos = {
		Question = Infos.Script,
		Description = Sentence .. "\r\n\r\n" .. Infos.Sentence,
		Buttons = Form.Ok,
		DefaultButton = Word.Ok
	}
	InputYesNo(Infos)
end

function Cancelled(variable)
	if variable == nil or variable == "" then
		FootPrint(Word.Script.Cancel)
		return true
	else
		return false
	end
end

function CheckInput(Infos, Answer)
	if Answer["button"] == Word.Yes then
		Answer["input"] = true
	end
	if Infos.Cancel == true then
		if Answer["button"] == Word.Yes then
			Answer["input"] = true
		elseif Answer["button"] == Word.Cancel or Answer["button"] == Word.No then
			Answer["input"] = nil
		end
	end
	return Answer
end

function Input(Infos, Type)
	-- Create the Prompt
	Prompt = CreatePrompt(Infos.Question, Infos.Description)

	-- Prompt settings
	if Type then
		Prompt.SetType(Type)
	end
	Prompt.SetButtons(Infos.Buttons)
	Prompt.SetDefaultButton(Infos.DefaultButton)

	-- Return the prompt
	return Prompt
end

function InputDropDown(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "DropDown")
	-- Prompt settings
	Prompt.SetDropDownOptions(Infos.DropDown)
	Prompt.SetDefaultValue(Infos.DropDownDefault)

	return ShowInput(Prompt, Infos)
end

function InputYesNo(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos)
	return ShowInput(Prompt, Infos)
end

function InputNumber(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "IntegerInput")
	-- Prompt settings
	if Infos.MinValue then
		Prompt.SetMinValue(Infos.MinValue)
	else
		Prompt.SetMinValue(1)
	end
	Prompt.SetMaxValue(10000)
	if Infos.CurrentValue then
		Prompt.SetDefaultValue(Infos.CurrentValue)
	end

	return ShowInput(Prompt, Infos)
end

function InputFloatNumber(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "FloatInput")
	-- Prompt settings
	Prompt.SetMinValue(0)
	if Infos.CurrentValue then
		Prompt.SetDefaultValue(Infos.CurrentValue)
	end

	return ShowInput(Prompt, Infos)
end

function InputText(Infos)
	-- Get the IntegerInput Prompt with default settings
	Prompt = Input(Infos, "TextInput")
	-- Prompt settings
	if Infos.CurrentValue then
		Prompt.SetDefaultValue(Infos.CurrentValue)
	end

	return ShowInput(Prompt, Infos)
end

function ShowInput(Prompt, Infos)
	-- Display the prompt
	Answer = Prompt.Show()

	return CheckInput(Infos, Answer)["input"]
end

--------------------
--     Logging    --
--------------------

Messages = {}

function LogActivity(text)
	table.insert(Messages, text)
end

function GetActivity()
	local Feedback = ""
	for i, Message in pairs(Messages) do
		Feedback = Feedback .. "\n" .. Message
	end
	return Feedback
end

--------------------
--   Functions    --
--------------------

function replace(str, what, with)
    what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
    with = string.gsub(with, "[%%]", "%%%%")
    return string.gsub(str, what, with)
end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function CopyCue(CuelistIDSource, CueID, CuelistIDTarget)
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CuelistIDSource)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Copy")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Cue")
	Sleep(Settings.WaitTime)
	KeyNumber(CueID)
	Onyx.Key_ButtonClick("At")
	Sleep(Settings.WaitTime)
	Onyx.SelectCuelist(CuelistIDTarget)
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Enter")
	Sleep(Settings.WaitTime)
end

function KeyNumber(Number)
	if string.find(Number, "%d", 1, false) then
		a = string.match(Number, "(.+)")
		for c in a:gmatch "." do
			Onyx.Key_ButtonClick("Num" .. c)
		end
		Sleep(Settings.WaitTime)
	end
end

function DeleteGroup(GroupID)
	Onyx.Key_ButtonClick("Delete")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Group")
	Sleep(Settings.WaitTime)
	KeyNumber(GroupID)
	Onyx.Key_ButtonClick("Enter")
	return true
end

function RecordCuelist(CuelistID)
	Onyx.Key_ButtonClick("Record")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Slash")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Slash")
	KeyNumber(CuelistID)
	Onyx.Key_ButtonClick("Enter")
	Sleep(Settings.WaitTime)
	Onyx.Key_ButtonClick("Enter")
	return true
end

function CheckEmpty(Chain, default)
	if Chain == nil or Chain == "" then
		if default then
			return default
		else
			return "---"
		end
	else
		return Chain
	end
end

function GetPresetName(PresetType, PresetID)
	if PresetType == PresetName.PanTilt then
		return CheckEmpty(Onyx.GetPanTiltPresetName(PresetID))
	elseif PresetType == PresetName.Color then
		return CheckEmpty(Onyx.GetColorPresetName(PresetID))
	elseif PresetType == PresetName.Intensity then
		return CheckEmpty(Onyx.GetIntensityPresetName(PresetID))
	elseif PresetType == PresetName.Gobo then
		return CheckEmpty(Onyx.GetGoboPresetName(PresetID))
	elseif PresetType == PresetName.Beam then
		return CheckEmpty(Onyx.GetBeamPresetName(PresetID))
	elseif PresetType == PresetName.BeamFX then
		return CheckEmpty(Onyx.GetBeamFXPresetName(PresetID))
	elseif PresetType == PresetName.Framing then
		return CheckEmpty(Onyx.GetFramingPresetName(PresetID))
	else
		return false
	end
end

function GetPresetAppearance(PresetType, PresetID)
	if PresetType == PresetName.PanTilt then
		return CheckEmpty(Onyx.GetPanTiltPresetAppearance(PresetID), DefaultAppearance.PanTilt)
	elseif PresetType == PresetName.Color then
		return CheckEmpty(Onyx.GetColorPresetAppearance(PresetID), DefaultAppearance.Color)
	elseif PresetType == PresetName.Intensity then
		return CheckEmpty(Onyx.GetIntensityPresetAppearance(PresetID), DefaultAppearance.Intensity)
	elseif PresetType == PresetName.Gobo then
		return CheckEmpty(Onyx.GetGoboPresetAppearance(PresetID), DefaultAppearance.Gobo)
	elseif PresetType == PresetName.Beam then
		return CheckEmpty(Onyx.GetBeamPresetAppearance(PresetID), DefaultAppearance.Beam)
	elseif PresetType == PresetName.BeamFX then
		return CheckEmpty(Onyx.GetBeamFXPresetAppearance(PresetID), DefaultAppearance.BeamFX)
	elseif PresetType == PresetName.Framing then
		return CheckEmpty(Onyx.GetFramingPresetAppearance(PresetID), DefaultAppearance.Framing)
	else
		return false
	end
end

function DeletePreset(PresetType, PresetID)
	if PresetType == PresetName.PanTilt then
		Onyx.DeletePanTiltPreset(PresetID)
	elseif PresetType == PresetName.Color then
		Onyx.DeleteColorPreset(PresetID)
	elseif PresetType == PresetName.Intensity then
		Onyx.DeleteIntensityPreset(PresetID)
	elseif PresetType == PresetName.Gobo then
		Onyx.DeleteGoboPreset(PresetID)
	elseif PresetType == PresetName.Beam then
		Onyx.DeleteBeamPreset(PresetID)
	elseif PresetType == PresetName.BeamFX then
		Onyx.DeleteBeamFXPreset(PresetID)
	elseif PresetType == PresetName.Framing then
		Onyx.DeleteFramingPreset(PresetID)
	end
	return true
end

function RecordPreset(PresetType, Preset, Merging)
	if PresetType == PresetName.PanTilt then
		Onyx.RecordPanTiltPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Color then
		Onyx.RecordColorPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Intensity then
		Onyx.RecordIntensityPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Gobo then
		Onyx.RecordGoboPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Beam then
		Onyx.RecordBeamPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.BeamFX then
		Onyx.RecordBeamFXPreset(Preset.Position, Preset.Name, Merging)
	elseif PresetType == PresetName.Framing then
		Onyx.RecordFramingPreset(Preset.Position, Preset.Name, Merging)
	end
	return true
end

function ListPreset(PresetType, PresetIDStart, PresetIDEnd)
	Presets = {}
	for i = PresetIDStart, PresetIDEnd, 1 do
		table.insert(
			Presets,
			{
				id = i,
				name = GetPresetName(PresetType, i),
				appearance = GetPresetAppearance(PresetType, i)
			}
		)
	end
	return Presets
end

function ListCuelist(CuelistIDStart, CuelistIDEnd)
	Cuelists = {}
	for i = CuelistIDStart, CuelistIDEnd, 1 do
		table.insert(
			Cuelists,
			{
				id = i,
				name = CheckEmpty(Onyx.GetCuelistName(i))
			}
		)
	end
	return Cuelists
end

function ListGroup(GroupIDStart, GroupIDEnd)
	Groups = {}
	for i = GroupIDStart, GroupIDEnd, 1 do
		table.insert(
			Groups,
			{
				id = i,
				name = CheckEmpty(Onyx.GetGroupName(i))
			}
		)
	end
	return Groups
end
HeadPrint()
-- End of Header --



Settings.PresetStartPosition[PresetName.Intensity] = 1	  -- Adjust the start point from the first line for INTENSITY presets
Settings.PresetStartPosition[PresetName.Color] = 1		    -- Adjust the start point from the first line for COLOR presets
Settings.PresetStartPosition[PresetName.Gobo] = 1		      -- Adjust the start point from the first line for Gobo presets
Settings.PresetStartPosition[PresetName.Beam] = 1		      -- Adjust the start point from the first line for BEAM presets

function GetPresetsConfiguration()
  return {
    Intensity = {
      {Name = "Dimmer 100%", 		    Color = "255, 255, 255",		Value=255, 		          Position = Settings.PresetStartPosition[PresetName.Intensity]},
      {Name = "Dimmer 50%", 		    Color = "160, 160, 160", 		Value=127,		          Position = Settings.PresetStartPosition[PresetName.Intensity]+Settings.PresetGridWidth},
      {Name = "Dimmer 0%", 			    Color = "96, 96, 96", 			Value=0,		            Position = Settings.PresetStartPosition[PresetName.Intensity]+Settings.PresetGridWidth*2},
      
      {Name = "Strobe Fast", 		    Color = "255, 255, 0", 			Value=nil,	          	Position = Settings.PresetStartPosition[PresetName.Intensity]+1},
      {Name = "Strobe Mid", 		    Color = "255, 255, 128", 		Value=nil,	          	Position = Settings.PresetStartPosition[PresetName.Intensity]+Settings.PresetGridWidth+1},
      {Name = "Strobe Low", 		    Color = "255, 255, 204", 		Value=nil,	          	Position = Settings.PresetStartPosition[PresetName.Intensity]+Settings.PresetGridWidth*2+1},
      
      {Name = "Shutter Open", 	    Color = "255, 255, 255", 		Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Intensity]+2},
      {Name = "Shutter Closed",     Color = "0, 0, 0", 				  Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Intensity]+Settings.PresetGridWidth+2}
    },
    Gobo = {
      {Name = "No Gobo",	 			    Color = "0, 0, 0", 			  	Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Gobo]},
      {Name = "Gobo Rot CW Slow", 	Color = "255, 0, 0", 		  	Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Gobo]+Settings.PresetGridWidth},
      {Name = "Gobo Rot CW Fast", 	Color = "255, 255, 0", 			Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Gobo]+Settings.PresetGridWidth*2},
      {Name = "Gobo fixed", 			  Color = "160, 160, 160", 		Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Gobo]+1},
      {Name = "Gobo Rot CCW Slow", 	Color = "0, 0, 255", 		  	Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Gobo]+Settings.PresetGridWidth+1},
      {Name = "Gobo Rot CCW Fast", 	Color = "0, 255, 255", 			Value=nil,		          Position = Settings.PresetStartPosition[PresetName.Gobo]+Settings.PresetGridWidth*2+1}
    },
    Beam = {
      {Name = "No prism", 			    Color = "0, 0, 0", 			  	Value=nil,			        Position = Settings.PresetStartPosition[PresetName.Beam]},
      {Name = "Prism Rot CW Slow", 	Color = "255, 0, 0", 			  Value=nil,			        Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth},
      {Name = "Prism Rot CW Fast", 	Color = "255, 255, 0", 			Value=nil,			        Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth*2},
      {Name = "Prism fixed", 			  Color = "160, 160, 160", 		Value=nil,			        Position = Settings.PresetStartPosition[PresetName.Beam]+1},
      {Name = "Prism Rot CCW Slow", Color = "0, 0, 255", 			  Value=nil,			        Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth+1},
      {Name = "Prism Rot CCW Fast", Color = "0, 255, 255", 			Value=nil,			        Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth*2+1},
      
      {Name = "Focus Near", 			  Color = "0, 0, 0", 				  Value={Focus=0},		  	Position = Settings.PresetStartPosition[PresetName.Beam]+2},
      {Name = "Focus Middle", 		  Color = "160, 160, 160", 		Value={Focus=127},			Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth+2},
      {Name = "Focus Far", 			    Color = "255, 0, 0", 			  Value={Focus=255},			Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth*2+2},
      
      {Name = "Frost 100%", 			  Color = "255, 255, 255",		Value={Frost=255},			Position = Settings.PresetStartPosition[PresetName.Beam]+3},
      {Name = "Frost 50%", 			    Color = "160, 160, 160", 		Value={Frost=127},			Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth+3},
      {Name = "Frost 0%", 			    Color = "96, 96, 96", 			Value={Frost=0},			  Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth*2+3},
      
      {Name = "Zoom 100%", 		    	Color = "255, 255, 255",		Value={Zoom=255},		    Position = Settings.PresetStartPosition[PresetName.Beam]+4},
      {Name = "Zoom 50%", 		    	Color = "160, 160, 160", 		Value={Zoom=127},		    Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth+4},
      {Name = "Zoom 0%", 				    Color = "96, 96, 96", 			Value={Zoom=0},			    Position = Settings.PresetStartPosition[PresetName.Beam]+Settings.PresetGridWidth*2+4}
    },
    ColorFull = {
      {Name = "CTB", 					      Color = "-8071681", 	                              Position = Settings.PresetStartPosition[PresetName.Color],
        Value={Red=215,		Green=243,		Blue=255,	  White=255,	Amber=0,		UV=0,		  Cyan=40,	Magenta=12,	  Yellow=0}},	
      {Name = "White", 				      Color = "-327682", 			                            Position = Settings.PresetStartPosition[PresetName.Color]+1,
        Value={Red=255,		Green=255,		Blue=255,	  White=255,	Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=0}},
      {Name = "CTO", 					      Color = "-6824", 									                  Position = Settings.PresetStartPosition[PresetName.Color]+2,
        Value={Red=255,		Green=216,		Blue=176,	  White=255,	Amber=255,	UV=0,		  Cyan=0,		Magenta=39,		Yellow=79}},
      {Name = "Salmon", 			      Color = "-65536", 									                Position = Settings.PresetStartPosition[PresetName.Color]+3,
        Value={Red=255,		Green=39,		  Blue=28,	  White=25,		Amber=0,		UV=0,		  Cyan=0,		Magenta=216,	Yellow=227}},
      {Name = "Red", 					      Color = "-65536", 									                Position = Settings.PresetStartPosition[PresetName.Color]+4,
        Value={Red=255,		Green=0,		  Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=255}},
      {Name = "Peach", 				      Color = "-65536", 								                	Position = Settings.PresetStartPosition[PresetName.Color]+5,
        Value={Red=252,		Green=85,		  Blue=37,	  White=0,		Amber=0,		UV=0,		  Cyan=3,		Magenta=170,	Yellow=218}},
      {Name = "Orange", 			      Color = "-33280", 									                Position = Settings.PresetStartPosition[PresetName.Color]+6,
        Value={Red=255,		Green=127,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=255}},
      {Name = "Yellow", 			      Color = "-2560", 									                  Position = Settings.PresetStartPosition[PresetName.Color]+7,
        Value={Red=255,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=255}},
      {Name = "Lime", 				      Color = "-2560", 									                  Position = Settings.PresetStartPosition[PresetName.Color]+8,
        Value={Red=191,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=64,	Magenta=0,		Yellow=255}},
      {Name = "Green", 				      Color = "-10879232", 								                Position = Settings.PresetStartPosition[PresetName.Color]+9,
        Value={Red=0,		  Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=255}},
      {Name = "Turquoise", 		      Color = "-16712449", 								                Position = Settings.PresetStartPosition[PresetName.Color]+10,
        Value={Red=0,		  Green=191,		Blue=127,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=64,		Yellow=127}},
      {Name = "Cyan", 			      	Color = "-16712449", 							                	Position = Settings.PresetStartPosition[PresetName.Color]+11,
        Value={Red=0,		  Green=255,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=0}},
      {Name = "Azure", 				      Color = "-16712449", 								                Position = Settings.PresetStartPosition[PresetName.Color]+12,
        Value={Red=0,		  Green=160,		Blue=207,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=96,		Yellow=48}},
      {Name = "Light Blue",       	Color = "-16769537", 								                Position = Settings.PresetStartPosition[PresetName.Color]+13,
        Value={Red=17,		Green=118,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=238,	Magenta=137,	Yellow=0}},
      {Name = "Blue", 				      Color = "-16769537", 								                Position = Settings.PresetStartPosition[PresetName.Color]+14,
        Value={Red=0,		  Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=255,	Yellow=0}},
      {Name = "Dark Blue", 		      Color = "-16769537", 								                Position = Settings.PresetStartPosition[PresetName.Color]+15,
        Value={Red=0,		  Green=16,		  Blue=128,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=239,	Yellow=127}},
      {Name = "Lavender", 		      Color = "-136631233", 								              Position = Settings.PresetStartPosition[PresetName.Color]+16,
        Value={Red=64,		Green=0,		  Blue=128,	  White=0,		Amber=0,		UV=0,		  Cyan=191,	Magenta=255,	Yellow=127}},
      {Name = "Uv", 					      Color = "-136631233", 								              Position = Settings.PresetStartPosition[PresetName.Color]+17,
        Value={Red=13,		Green=4,		  Blue=113,	  White=0,		Amber=0,		UV=255,		Cyan=242,	Magenta=251,	Yellow=142}},
      {Name = "Bright Pink", 	      Color = "-65308", 									                Position = Settings.PresetStartPosition[PresetName.Color]+18,
        Value={Red=221,		Green=2,		  Blue=96,	  White=0,		Amber=0,		UV=0,		  Cyan=34,	Magenta=253,	Yellow=159}},
      {Name = "Pink", 				      Color = "-65308", 									                Position = Settings.PresetStartPosition[PresetName.Color]+19,
        Value={Red=255,		Green=127,		Blue=127,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=127}},
      {Name = "Flash Pink", 	      Color = "-65308", 									                Position = Settings.PresetStartPosition[PresetName.Color]+20,
        Value={Red=223,		Green=32,		  Blue=96,	  White=0,		Amber=0,		UV=0,		  Cyan=32,	Magenta=223,	Yellow=159}},
      {Name = "Sunset Pink", 	      Color = "-65308", 									                Position = Settings.PresetStartPosition[PresetName.Color]+21,
        Value={Red=255,		Green=0,		  Blue=85,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=170}},
      {Name = "Magenta", 			      Color = "-65434", 									                Position = Settings.PresetStartPosition[PresetName.Color]+22,
        Value={Red=255,		Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=0}}
    },
    Color = {
      {Name = "White", 				      Color = "-327682", 									                Position = Settings.PresetStartPosition[PresetName.Color],
        Value={Red=255,		Green=255,		Blue=255,	  White=255,	Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=0}},
      {Name = "Red", 					      Color = "-65536", 									                Position = Settings.PresetStartPosition[PresetName.Color]+1,
        Value={Red=255,		Green=0,		  Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=255}},
      {Name = "Orange", 			      Color = "-33280", 									                Position = Settings.PresetStartPosition[PresetName.Color]+2,
        Value={Red=255,		Green=127,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=255}},
      {Name = "Yellow", 			      Color = "-2560", 									                  Position = Settings.PresetStartPosition[PresetName.Color]+3,
        Value={Red=255,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=0,		Yellow=255}},
      {Name = "Lime", 				      Color = "-2560", 									                  Position = Settings.PresetStartPosition[PresetName.Color]+4,
        Value={Red=191,		Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=64,	Magenta=0,		Yellow=255}},
      {Name = "Green", 				      Color = "-10879232", 								                Position = Settings.PresetStartPosition[PresetName.Color]+5,
        Value={Red=0,		  Green=255,		Blue=0,		  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=255}},
      {Name = "Cyan", 				      Color = "-16712449", 								                Position = Settings.PresetStartPosition[PresetName.Color]+6,
        Value={Red=0,		  Green=255,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=0,		Yellow=0}},
      {Name = "Light Blue", 	      Color = "-16769537", 								                Position = Settings.PresetStartPosition[PresetName.Color]+7,
        Value={Red=17,		Green=118,		Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=238,	Magenta=137,	Yellow=0}},
      {Name = "Blue", 				      Color = "-16769537", 								                Position = Settings.PresetStartPosition[PresetName.Color]+8,
        Value={Red=0,		  Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=255,	Magenta=255,	Yellow=0}},
      {Name = "Uv", 					      Color = "-136631233", 								              Position = Settings.PresetStartPosition[PresetName.Color]+9,
        Value={Red=13,		Green=4,		  Blue=113,	  White=0,		Amber=0,		UV=255,		Cyan=242,	Magenta=251,	Yellow=142}},
      {Name = "Pink", 				      Color = "-65308", 									                Position = Settings.PresetStartPosition[PresetName.Color]+10,
        Value={Red=255,		Green=127,		Blue=127,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=127,	Yellow=127}},
      {Name = "Magenta", 			      Color = "-65434", 									                Position = Settings.PresetStartPosition[PresetName.Color]+11,
        Value={Red=255,		Green=0,		  Blue=255,	  White=0,		Amber=0,		UV=0,		  Cyan=0,		Magenta=255,	Yellow=0}}
    }
  }
end



----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Rep = "%VAR%"
RepID = "%GROUPID%"

AutoPresetTypes = {PresetName.Intensity, PresetName.Color, PresetName.Gobo, PresetName.Beam}

Content = {
  StopMessage = "Stopped!" .. "\r\n\t" .. "The value defined in the script configuration is not supported",
  Action = {
    Question = "What action do you want to perform?",
    Description = "Please select what you want to do:",
    Create = "Create",
    Populate = "Populate"
  },
  Groups = {
    ReuseGroup = "Do you want to keep your previous groups definition?",
    Options = "Groups Options:",
    List = "Group list:",
    Question = "How many fixture groups will be used?",
    Description = "Please indicate the quantity of groups where to populate presets:"
  },
  GroupID = {
    Question = "What is the Group n°".. Rep .." ID?",
    Description = "Please indicate the Group n°".. Rep .." ID:"
  },
  Resolution = {
    Question = "[" .. Rep .. "] What is the " .. Rep .. " resolution for the group ".. RepID .."?",
    Description = "[" .. Rep .. "] Please select the " .. Rep .. " resolution for the group ".. RepID ..":",
    Standard = "8 bits (standard)",
    Fine = "16 bits (fine)"
  },
  PresetPosition = {
    Question = "Where do you want to start recording " .. Rep .. " presets?",
    Description = "This option permit to define where to start recording " .. Rep .. " presets"
  },
  Create = {
    Question = "Which type of preset do you want to " .. Rep .. "?",
    Description = "Please select the preset type to " .. Rep .. ":"
  },
  CreateValidation = {
    Question = "Are you sure to create empty " .. Rep .. " presets?",
    Description = "WARNING, it can't be UNDO! Use it with caution!"
  },
  PopulateValidation = {
    Question = "Are you sure to populate " .. Rep .. " presets?",
    Description = "WARNING, it can't be UNDO! Use it with caution!"
  },
  Grid = {
    Question = "What is your preset grid width?",
    Description = "Indicate the preset grid width (min 4):"
  },
  Color = {
    Question = "What is your color preference?",
    Description = "Select your color palette preference (Extended > 20 colors, Basic = 12 colors):",
    Extended = "Extended",
    Basic = "Basic"
  }
}

--------------------------
--      Functions       --
--------------------------

function SetSettingsType()
  if Settings.Type == PresetName.Color then
    -- Define the color preset type following preferences
    if Settings.Color == Content.Color.Extended then
      Settings.PresetTyping = 'ColorFull'
    else
      Settings.PresetTyping = 'Color'
    end
  else
    -- Define the preset type
    Settings.PresetTyping = Settings.Type
  end
end

function ApplyPresetContent(Group, Preset)
  if Preset.Value ~= nil then
    -- If the preset type is color, record additional value for color macro
    if Settings.Type == PresetName.Color then
      Onyx.SetAttributeVal('Color Macro', 0, true)
    end
    if type(Preset.Value) == 'table' then
      for Key, Value in pairs(Preset.Value) do
        -- Set value on 16 bits if needed of course!
        if Group.Resolution[Settings.Type] == Content.Resolution.Fine then
          Value = Value * 257
        end
        -- Set the attribute and its value
        Onyx.SetAttributeVal(Key, Value, true)
      end
    else
      Onyx.SetAttributeVal(Settings.Type, Preset.Value, true)
    end
    -- Record into Preset
    RecordPreset(Settings.Type, Preset, true)
    Sleep(Settings.WaitTime)
  end
end

--------------------------
-- Collect Informations --
--------------------------

--# REQUEST the Preset Grid Width # --
--------------------------------

InputSettings = {
  Question = Content.Grid.Question,
  Description = Content.Grid.Description,
  CurrentValue = CheckEmpty(GetVar("Settings.PresetGridWidth"), 8),
  MinValue = 4,
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok
}

Settings.PresetGridWidth = InputNumber(InputSettings)

if Cancelled(Settings.PresetGridWidth) then
    goto EXIT
else
  SetVar("Settings.PresetGridWidth", Settings.PresetGridWidth)
  LogActivity("\r\n\t" .. "Preset Grid Width: " .. Settings.PresetGridWidth)
end

-- START POINT, to loop actions
::START::

--# REQUEST the Action type # --
--------------------------------
InputSettings = false
InputSettings = {
  Question = Content.Action.Question,
  Description = Content.Action.Description,
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok,
  DropDown = {Content.Action.Create, Content.Action.Populate},
  DropDownDefault = CheckEmpty(GetVar("Settings.Action"), Content.Action.Create),
  Cancel = true
}

ActionType = InputDropDown(InputSettings)

-- If not ActionType defined, exit
if Cancelled(ActionType) then
  goto EXIT
else
  if Content.Action[ActionType] then
      Settings.Action = ActionType
  else
      LogInformation(Content.StopMessage)
      goto EXIT
  end
  SetVar("Settings.Action", Settings.Action)
  LogActivity("\r\n\t" .."Action: " .. Settings.Action)
end

--# REQUEST the Preset Type # --
--------------------------------
InputSettings = false
InputSettings = {
  Question = replace(Content.Create.Question, Rep, Settings.Action),
  Description = replace(Content.Create.Description, Rep, Settings.Action),
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok,
  DropDown = AutoPresetTypes,
  DropDownDefault = CheckEmpty(GetVar("Settings.Type"), PresetName.Intensity),
  Cancel = true
}

PresetType = InputDropDown(InputSettings)

-- If not PresetType defined, exit
if Cancelled(PresetType) then
  goto EXIT
else
  if PresetName[PresetType] then
      Settings.Type = PresetType
  else
      LogInformation(Content.StopMessage)
      goto EXIT
  end
  SetVar("Settings.Type", Settings.Type)
  LogActivity("\r\n\t" .."Preset Type: " .. Settings.Type)
end

--# REQUEST the Preset Start Position # --
--------------------------------
InputSettings = false
InputSettings = {
  Question = replace(Content.PresetPosition.Question, Rep, Settings.Type),
  Description = replace(Content.PresetPosition.Description, Rep, Settings.Type),
  Buttons = Form.OkCancel,
  DefaultButton = Word.Ok,
  CurrentValue = CheckEmpty(GetVar("Settings.PresetStartPosition" .. Settings.Type), Settings.PresetStartPosition[Settings.Type]),
  Cancel = true
}
Settings.PresetStartPosition[Settings.Type] = InputNumber(InputSettings)

-- If not PresetType defined, exit
if Cancelled(Settings.PresetStartPosition[Settings.Type]) then
  goto EXIT
else
  SetVar("Settings.PresetStartPosition" .. Settings.Type, Settings.PresetStartPosition[Settings.Type])
  LogActivity("\r\n\t" .. Settings.Type .. " Preset Start Position: " .. Settings.PresetStartPosition[Settings.Type])
end

-- If Color preference is not already set, and PresetType is Color, request the color preferences to be applied
if Settings.Type == PresetName.Color then
  InputSettings = false
  InputSettings = {
    Question = Content.Color.Question,
    Description = Content.Color.Description,
    Buttons = Form.OkCancel,
    DropDown = {Content.Color.Extended, Content.Color.Basic},
    DropDownDefault = CheckEmpty(GetVar("Settings.Color"), Content.Color.Basic)
  }
  Settings.Color = InputDropDown(InputSettings)

  -- If not PresetType defined, exit
  if Cancelled(Settings.Color) then
    goto EXIT
  else
    SetVar("Settings.Color", Settings.Color)
    LogActivity("\r\n\t" .."Color Preference: " .. Settings.Color)
  end
end

--# REQUEST the Fixtures Group # --
-----------------------------------
::GROUPS::
-- Request Fixtures Group setting when Populate preset Only
if Settings.Action == Content.Action.Populate then
  if Settings.Groups == nil then
    -- Request EU number of groups to be threated
    InputSettings = false
    InputSettings = {
      Question = Content.Groups.Question,
      Description = Content.Groups.Description,
      Buttons = Form.OkCancel,
      DefaultButton = Word.Ok,
      Cancel = true
    }

    Settings.NbOfGroups = InputNumber(InputSettings)

    if Cancelled(Settings.NbOfGroups) then
      goto EXIT
    end

    -- Indicate the number of Groups to be threated
    Settings.Groups = {}

    -- Request EU details for each group
    for i = 1, Settings.NbOfGroups, 1 do
      -- Request the Group ID
      InputSettings.Question = replace(Content.GroupID.Question, Rep, i)
      InputSettings.Description = replace(Content.GroupID.Description, Rep, i)

      local Group = {}
      Group.Resolution = {}
      Group.ID = InputNumber(InputSettings)

      if Cancelled(Group.ID) then
          goto EXIT
      end

      -- Get the Group Name
      Group.Name = CheckEmpty(Onyx.GetGroupName(Group.ID))

      -- Request EU details for each PRESET TYPE resolution
      InputSettings = false
      InputSettings = {
        Buttons = Form.OkCancel,
        DefaultButton = Word.Ok,
        DropDown = {Content.Resolution.Standard, Content.Resolution.Fine},
        DropDownDefault = Content.Resolution.Standard,
        Cancel = true
      }
      for idPreset, LocalPreset in pairs(AutoPresetTypes) do
        ReplaceRepID = "n°" .. i .. " " .. Group.Name .. "[" .. Group.ID .. "]"
        InputSettings.Question = replace(replace(Content.Resolution.Question, Rep, LocalPreset), RepID, ReplaceRepID)
        InputSettings.Description = replace(replace(Content.Resolution.Description, Rep, LocalPreset), RepID, ReplaceRepID)

        Group.Resolution[LocalPreset] = InputDropDown(InputSettings)

          -- If not PresetType defined, exit
        if Cancelled(Group.Resolution[LocalPreset]) then
          goto EXIT
        end
      end
      -- Inset into the global Groups table
      table.insert(Settings.Groups, Group)
    end
    -- RESUME of GROUPS
    LogActivity("\r\n" .. Content.Groups.Options)
    LogActivity("\r\n\t" .. "- " .. Settings.NbOfGroups .. " group(s)")

    -- DETAIL of GROUPS
    LogActivity("\r\n" .. Content.Groups.List)
    for i, Group in pairs(Settings.Groups) do
        LogActivity("\r\n\t" .. "- n°" .. Group.ID .. " - " .. Group.Name)
        for Key, Value in pairs(Group.Resolution) do
          LogActivity("\r\n\t\t" .. "- " .. Key .. ": " .. Value)
        end
    end
  else
    InputSettings = false
    InputSettings = {
      Question = Content.Groups.ReuseGroup,
      Description = Content.Groups.ReuseGroup,
      Buttons = Form.YesNo,
      DefaultButton = Word.Yes
    }

    if InputYesNo(InputValidationSettings) then
    else
      Settings.Groups = nil
      goto GROUPS
    end
  end
end

----------------------------
-- Execution for Creation --
----------------------------

-- CREATE ACTION
if Settings.Action == Content.Action.Create then
  --# USER Validation # --
  ------------------------
  InputValidationSettings = {
    Question = replace(Content.CreateValidation.Question, Rep, Settings.Type),
    Description = Content.CreateValidation.Description .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
  }

  Settings.Validation = InputYesNo(InputValidationSettings)
  -- RESET Log Messages
  Messages = {}

  if Settings.Validation then
    PresetsConfiguration = GetPresetsConfiguration()
    SetSettingsType()
    -- Create Preset
    for i, InnerPreset in pairs(PresetsConfiguration[Settings.PresetTyping]) do
      RecordPreset(Settings.Type, InnerPreset, true)
      Sleep(Settings.WaitTime)
    end
    -- Don't exit, purpose to continue for a next action!
    Onyx.ClearProgrammer()
    goto START
  end
-- POPULATE ACTION
elseif Settings.Action == Content.Action.Populate then
  --# USER Validation # --
  ------------------------
  InputValidationSettings = {
    Question = replace(Content.PopulateValidation.Question, Rep, Settings.Type),
    Description = Content.PopulateValidation.Description .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
  }

  Settings.Validation = InputYesNo(InputValidationSettings)
  -- RESET Log Messages
  Messages = {}

  if Settings.Validation then
    SetSettingsType()
    for i, Group in pairs(Settings.Groups) do
      Onyx.ClearProgrammer()
      -- Create Preset
      Onyx.SelectGroup(Group.ID)
      Sleep(Settings.WaitTime)
      for i, InnerPreset in pairs(PresetsConfiguration[Settings.PresetTyping]) do
        ApplyPresetContent(Group, InnerPreset)
        Sleep(Settings.WaitTime)
      end
    end
    -- Don't exit, purpose to continue for a next action!
    Onyx.ClearProgrammer()
    goto START
  end
end

::EXIT::
