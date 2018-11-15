-- ShowCockpit LUA Script: CreatePlaybacksFromPresets
--   created on ShowCockpit v2.4.2
--   by Spb8 Lighting
--   on 05-09-2018

-------------
-- Purpose --
-------------
-- This script allows to create playback(s) cuelist from preset(s)

---------------
-- Changelog --
---------------
-- 30-10-2018 - 1.1: Fix a bug when the grid width is smaller than the number of cuelist to be created
--                  + Fix the historical issue with the first cuelist creation which fails randomly
-- 07-09-2018 - 1.0: Creation

-------------------
-- Configuration --
-------------------

Settings = {
    WaitTime = 0.5,
    HarmonizeCLName = true, -- Default: true > If preset name has the group name, the script will remove take the preset name without the group name to format the cuelist name
    Optimize = true, -- Default: true > Activate optimization to speed up execution (take care, this option can break the result) [-6 x Waitime per playback button]
    RenameCue = false, -- Default: false > Activate the cue Renaming with preset name (increase the performance)
    Step = 1
}

ScriptInfos = {
    version = "1.1",
    name = "CreatePlaybacksFromPresets"
}

-- ShowCockpit LUA Script: LuaHeader for Spb8 Lighting LUA Script

---------------
-- Changelog --
---------------
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
	Prompt.SetMinValue(1)
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

HeadPrint()
-- End of Header --



----------------------------------------------------
-- Main Script - dont change if you don't need to --
----------------------------------------------------

--------------------------
-- Sentence and Wording --
--------------------------

Content = {
    StopMessage = "Stopped!" .. "\r\n\t" .. "The Preset type defined in the script configuration is not supported",
    Done = "Deletion Ended!",
    Options = "Delete Options:",
    Presets = {
        Options = "Presets Options:",
        List = "Preset list:"
    },
    Select = {
        Question = "Which type of preset will be used to create playback?",
        Description = "Please select the preset type to create playback from the list:"
    },
    Groups = {
        Options = "Groups Options:",
        List = "Group list:",
        Question = "How many fixture groups will be used?",
        Description = "Please indicate the quantity of groups where to create playbacks:"
    },
    Cuelist = {
        From = {
            Question = "Create playbacks from Preset n°",
            Description = "Indicate the first Preset ID number:"
        },
        To = {
            Question = "Create playbacks until Preset n°",
            Description = "Indicate the last Preset ID number:"
        },
        Time = {
            Question = "Cuelist Release Time:",
            Description = "Indicate the awaiting Cuelist release time (in seconds)"
        }
    },
    Playback = {
        Options = "Playback Options:",
        Page = {
            Question = "Which playback page n° to create playbacks?",
            Description = "Indicate playback page ID where to create playbacks:"
        },
        Button = {
            Question = "Which playback button n° to start creating playback?",
            Description = "Indicate playback button ID number where to start creating playback:"
        },
        Arrangement = {
            Question = "Which playback arrangement do you want?",
            Description = "Choose the playback button arrangement of your choice:"
        },
        Grid = {
            Question = "What is your playback page width?",
            Description = "Indicate the playback page width (column):"
        }
    },
    Cue = {
        Time = {
            Question = "Cue Fade Time:",
            Description = "Indicate the awaiting Cue fade time (in seconds)"
        }
    },
    Records = {
        Options = "Records Options:"
    },
    Validation = {
        Question = "Do you want to create the playbacks?"
    }
}

--------------------------
--      Functions       --
--------------------------

function SleepOption()
    if Settings.Optimize == false then
        Sleep(Settings.WaitTime)
    end
end

function CuelistName(GroupName, NamePreset, OnlyPresetName)
    function RemoveGroup()
        return trim(string.gsub(NamePreset, GroupName, ""))
    end
    local CLName = GroupName .. " - " .. NamePreset
    if Settings.HarmonizeCLName == true then
        if string.find(NamePreset, GroupName, 1, true) then
            if OnlyPresetName == true then
                return RemoveGroup()
            else
                return GroupName .. " - " .. RemoveGroup()
            end
        else
            if OnlyPresetName == true then
                return NamePreset
            else
                return CLName
            end
        end
    else
        if OnlyPresetName == true then
            return NamePreset
        else
            return CLName
        end
    end
end

--------------------------
-- Collect Informations --
--------------------------

--# REQUEST the Preset Type # --
--------------------------------

InputSettings = {
    Question = Content.Select.Question,
    Description = Content.Select.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    DropDown = Form.Preset,
    DropDownDefault = PresetName.Intensity,
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
    LogInformation("Preset Type: " .. PresetType .. "\r\n\t" .. "Create " .. PresetType .. " Playbacks")
end

--# REQUEST the Fixtures Group # --
-----------------------------------

-- Request EU number of groups to be threated
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
    InputSettings.Question = "Group n°" .. i .. " ID"
    InputSettings.Description = "Please indicate the Group n°" .. i .. " ID:"

    local GroupID = InputNumber(InputSettings)

    if Cancelled(GroupID) then
        goto EXIT
    end

    table.insert(Settings.Groups, {id = GroupID, name = Onyx.GetGroupName(GroupID)})
end


-- Request the Start Preset ID n°
InputSettings = {
    Question = Content.Cuelist.From.Question,
    Description = Content.Cuelist.From.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    Cancel = true
}

Settings.PresetIDStart = InputNumber(InputSettings)

if Cancelled(Settings.PresetIDStart) then
    goto EXIT
end
-- Request the Last Preset ID n°
InputSettings.Question = Content.Cuelist.To.Question
InputSettings.Description = Content.Cuelist.To.Description
InputSettings.CurrentValue = Settings.PresetIDStart + 1

Settings.PresetIDEnd = InputNumber(InputSettings)

if Cancelled(Settings.PresetIDEnd) then
    goto EXIT
end

-- Compute the number of Presets
Settings.NumberOfPreset = Settings.PresetIDEnd - Settings.PresetIDStart + 1

--# REQUEST the Playback Informations # --
------------------------------------------

-- Starting playback button page
InputSettings.Question = Content.Playback.Page.Question
InputSettings.Description = Content.Playback.Page.Description
InputSettings.CurrentValue = 1

Settings.PlaybackButtonPage = InputNumber(InputSettings)

if Cancelled(Settings.PlaybackButtonPage) then
    goto EXIT
end

-- First playback button
InputSettings.Question = Content.Playback.Button.Question
InputSettings.Description = Content.Playback.Button.Description

Settings.PlaybackButtonStart = InputNumber(InputSettings)

if Cancelled(Settings.PlaybackButtonStart) then
    goto EXIT
end

-- Playback arrangement
InputSettings = {
    Question = Content.Playback.Arrangement.Question,
    Description = Content.Playback.Arrangement.Description,
    Buttons = Form.OkCancel,
    DefaultButton = Word.Ok,
    DropDown = {Word.Vertical, Word.Horizontal},
    DropDownDefault = Word.Vertical,
    Cancel = true
}

Settings.TextOrientation = InputDropDown(InputSettings)

-- Playback Grid Width
InputSettings.Question = Content.Playback.Grid.Question
InputSettings.Description = Content.Playback.Grid.Description
InputSettings.CurrentValue = Settings.NumberOfPreset

Settings.PlaybackWidth = InputNumber(InputSettings)

if Cancelled(Settings.PlaybackButtonPage) then
    goto EXIT
end


--# REQUEST the Cue Fading Time # --
------------------------------------

InputSettings.Question = Content.Cue.Time.Question
InputSettings.Description = Content.Cue.Time.Description
InputSettings.CurrentValue = 0

Settings.TimeFade = InputFloatNumber(InputSettings)

if Cancelled(Settings.TimeFade) then
    goto EXIT
end

--# REQUEST the Cuelist Release Time # --
-----------------------------------------

InputSettings.Question = Content.Cuelist.Time.Question
InputSettings.Description = Content.Cuelist.Time.Description
InputSettings.CurrentValue = 0

Settings.TimeRelease = InputFloatNumber(InputSettings)

if Cancelled(Settings.TimeRelease) then
    goto EXIT
end

--# LOG all user choice # --
----------------------------

-- RESUME of GROUPS
LogActivity(Content.Groups.Options)
LogActivity("\r\n\t" .. "- " .. Settings.NbOfGroups .. " group(s)")

-- DETAIL of GROUPS
LogActivity("\r\n" .. Content.Groups.List)
for i, Group in pairs(Settings.Groups) do
    LogActivity("\r\n\t" .. "- n°" .. Group.id .. " - " .. Group.name)
end

-- RESUME of PRESETS
LogActivity("\r\n" .. Content.Presets.Options)
LogActivity("\r\n\t" .. "- " .. PresetType .. " Presets, from n°" .. Settings.PresetIDStart .. " to n°" .. Settings.PresetIDEnd)

-- DETAIL of PRESETS
LogActivity("\r\n" .. Content.Presets.List)

Settings.Presets = ListPreset(PresetType, Settings.PresetIDStart, Settings.PresetIDEnd)

for i, Preset in pairs(Settings.Presets) do
    LogActivity("\r\n\t" .. "- n°" .. Preset.id .. " " .. Preset.name)
end

-- RESUME of PLAYBACK
Settings.GridSize = Settings.NbOfGroups .. " groups of " .. Settings.NumberOfPreset .. " presets"

LogActivity("\r\n" .. Content.Playback.Options)
LogActivity("\r\n\t" .. "- Playback page n°" .. Settings.PlaybackButtonPage)
LogActivity("\r\n\t" .. "- Playback button n°" .. Settings.PlaybackButtonStart)
LogActivity("\r\n\t" .. "- " .. Settings.TextOrientation .. " arrangement for " .. Settings.GridSize .. " on " .. Settings.PlaybackWidth .. " grid width")

-- Get the next Cuelist ID available
Settings.StartingEmptyCueList = Onyx.GetNextCuelistNumber()

-- RESUME of TIMING
LogActivity(Content.Records.Options)
LogActivity("\r\n\t" .. "- Create Cuelist(s) from n°" .. Settings.StartingEmptyCueList)
LogActivity("\r\n\t" .. "- Cue Fade Time: " .. Settings.TimeFade .. "s")
LogActivity("\r\n\t" .. "- Cuelist Release Time: " .. Settings.TimeRelease .. "s")

--# USER Validation # --
------------------------

InputValidationSettings = {
    Question = Content.Validation.Question,
    Description = "Do you agree to generate " .. PresetType .. " Playbacks for " .. Settings.GridSize .. ", on Playback page n°" .. Settings.PlaybackButtonPage .. "?" .. "\n\r\n\r" .. GetActivity(),
    Buttons = Form.YesNo,
    DefaultButton = Word.Yes
}

Settings.Validation = InputYesNo(InputValidationSettings)

--------------------------
--      Execution       --
--------------------------

Counter = {
    Cuelist = Settings.StartingEmptyCueList,
    PlaybackNumber = Settings.PlaybackButtonStart
}

::START::

if Settings.Validation then
    Onyx.ClearProgrammer()
    if Settings.Step == 1 then
        --Workaround the first empty playback
        RecordCuelist(Counter.Cuelist)
            Sleep(Settings.WaitTime)
        Onyx.DeleteCuelist(Counter.Cuelist)
            Sleep(Settings.WaitTime)
    end
    for i, Group in pairs(Settings.Groups) do
        --For each preset
        for i, Preset in pairs(Settings.Presets) do
            Onyx.ClearProgrammer()
            if Settings.Step == 1 then
                Sleep(Settings.WaitTime)
                Onyx.SelectGroup(Group.id)
                SleepOption()
                if PresetType == PresetName.PanTilt then
                    Onyx.SelectPanTiltPreset(Preset.id)
                elseif PresetType == PresetName.Color then
                    Onyx.SelectColorPreset(Preset.id)
                elseif PresetType == PresetName.Intensity then
                    Onyx.SelectIntensityPreset(Preset.id)
                elseif PresetType == PresetName.Gobo then
                    Onyx.SelectGoboPreset(Preset.id)
                elseif PresetType == PresetName.Beam then
                    Onyx.SelectBeamPreset(Preset.id)
                end
                Sleep(Settings.WaitTime)
                RecordCuelist(Counter.Cuelist)
                Sleep(Settings.WaitTime)
                Onyx.CopyCuelistToPlaybackButton(
                    Counter.Cuelist,
                    Settings.PlaybackButtonPage,
                    Counter.PlaybackNumber
                )
                Sleep(Settings.WaitTime)
                Onyx.RenameCuelist(CuelistName(Group.name, Preset.name, false))
                if Settings.RenameCue == true then
                    Sleep(Settings.WaitTime)
                    Onyx.RenameCue(1, CuelistName(Group.name, Preset.name, false))
                end
                SleepOption()
                Onyx.SetCueFadeTime(1, Settings.TimeFade)
                SleepOption()
                Onyx.SetCuelistReleaseTime(Counter.Cuelist, Settings.TimeRelease)
            elseif Settings.Step == 2 then
                Onyx.SelectCuelist(Counter.Cuelist)
                Onyx.SetCuelistAppearance(Counter.Cuelist, Preset.appearance) -- Apply the preset appearance to the cuelist
            end
            Counter.Cuelist = Counter.Cuelist + 1 -- Go to next cuelist
            if Settings.Orientation == true then -- Vertical Orientation
                Counter.PlaybackNumber = Counter.PlaybackNumber + Settings.PlaybackWidth -- Set the next position
            else -- Horizontal Orientation
                Counter.PlaybackNumber = Counter.PlaybackNumber + 1 -- Set the next position
            end
        end
        if Settings.Orientation == true then -- Vertical Orientation
            Counter.PlaybackNumber = Settings.PlaybackButtonStart + i
        else -- Horizontal Orientation
            if i == 1 and Counter.PlaybackNumber > Settings.PlaybackWidth then
                Settings.PlaybackWidth = Settings.PlaybackWidth * math.ceil(Counter.PlaybackNumber / Settings.PlaybackWidth)
            end
            Counter.PlaybackNumber = Settings.PlaybackButtonStart + (Settings.PlaybackWidth * i)
        end
    end
    Sleep(Settings.WaitTime)
    if Settings.Step == 1 then
        Counter.Cuelist = Settings.StartingEmptyCueList
        Counter.PlaybackNumber = Settings.PlaybackButtonStart
        Settings.Step = 2
        goto START
    end

    FootPrint("Creation finished!")
else
    Cancelled()
end

::EXIT::
