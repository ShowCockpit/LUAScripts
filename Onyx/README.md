# Onyx Lua Scripts for ShowCockpit

This repository contains some LUA script which can be run from ShowCockpit to interact with Onyx.

## Script List

<!---* [Onyx-Delete-Groups.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Onyx-Delete-Groups.lua) - This script allows to delete a range of group (batch mode) -->
* [Onyx-Auto-Presets.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Onyx-Auto-Presets.lua) - This script allows to create a bunch of presets in a second. It can also populate some of them based on a group of selection
* [Onyx-Delete-Cuelists.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Onyx-Delete-Cuelists.lua) - This script allows to delete a range of cuelist (batch mode)
* [Onyx-Delete-Presets.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Onyx-Delete-Presets.lua) - This script allows to delete a range of presets (batch mode)
* [Onyx-Update-CueFade-CuelistRelease.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Onyx-Update-CueFade-CuelistRelease.lua) - This script allows to update the cues fade times in the meantime of the cuelist release time
* [Onyx-Create-Playbacks-from-Presets.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Onyx-Create-Playbacks-from-Presets.lua) - This script allows to create playback(s) cuelist from preset(s)
* [Onyx-Rename-Cuelists.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/dist/Onyx-Rename-Cuelists.lua) - This script allows to rename cuelist(s) massively (replace a searched value by another value)

## Lua Fonctions

Inside the [header.lua](https://github.com/Spb8Lighting/OnyxLuaScripts/blob/master/assets/header.lua) script which is include in all scripts, you have access to some functions. Theses last are detailed below if you want to create your own script based on it.

### Logging function

<details>
    <summary>HeadPrint()</summary>
    <p>This function will log the in ShowCockpit the Script Name and the Script Version</p>
</details>
<details>
    <summary>FootPrint(sentence)</summary>
    <p>Arguments: string sentence</p>
    <p>This function will log the in ShowCockpit sentence argument and display the author informations and display a pop-up to user (for script ends)</p>
</details>
<details>
    <summary>LogActivity(text)</summary>
    <p>Arguments: string text</p>
    <p>This function will register all the text argument. It can be restitute later by calling the GetActivity() function</p>
</details>
<details>
    <summary>GetActivity()</summary>
    <p>This function will compile all text sent through the LogActivity(text) function. Each text will have a chariot return as suffix.</p>
</details>

### Interface function

#### Main function

<details>
    <summary>InputDropDown(Infos)</summary>
    <p>Arguments: JSON Infos {Question: string, Description: string, Buttons: JSON {string Button1, string Button2, string Button3}, DefaultButton : string, DropDown : JSON {string Value 1, string Value 2, ...}, DropDownDefault: string}</p>
    <p>Dependency: Input(), ShowInput()</p>
    <p>This function will display the CreatePrompt of type "DropDown" to the user and will return the user choice value</p>
</details>
<details>
    <summary>InputYesNo(Infos)</summary>
    <p>Arguments: JSON Infos {Question: string, Description: string, Buttons: JSON {string Button1, string Button2, string Button3}, DefaultButton : string, DropDown : JSON {string Value 1, string Value 2, ...}, DropDownDefault: string}</p>
    <p>Dependency: Input(), ShowInput()</p>
    <p>This function will display the CreatePrompt of with only buttons to the user and will return the user button click value</p>
</details>
<details>
    <summary>InputText(Infos)</summary>
    <p>Arguments: JSON Infos {Question: string, Description: string, Buttons: JSON {string Button1, string Button2, string Button3}, DefaultButton : string, DropDown : JSON {string Value 1, string Value 2, ...}, DropDownDefault: string}</p>
    <p>Dependency: Input(), ShowInput()</p>
    <p>This function will display the CreatePrompt of type "TextInput" to the user and will return the user value</p>
</details>
<details>
    <summary>InputNumber(Infos)</summary>
    <p>Arguments: JSON Infos {Question: string, Description: string, Buttons: JSON {string Button1, string Button2, string Button3}, DefaultButton : string, DropDown : JSON {string Value 1, string Value 2, ...}, DropDownDefault: string}</p>
    <p>Dependency: Input(), ShowInput()</p>
    <p>This function will display the CreatePrompt of type "IntegerInput" to the user and will return the user value</p>
</details>
<details>
    <summary>InputFloatNumber(Infos)</summary>
    <p>Arguments: JSON Infos {Question: string, Description: string, Buttons: JSON {string Button1, string Button2, string Button3}, DefaultButton : string, DropDown : JSON {string Value 1, string Value 2, ...}, DropDownDefault: string}</p>
    <p>Dependency: Input(), ShowInput()</p>
    <p>This function will display the CreatePrompt of type "FloatInput" to the user and will return the user value</p>
</details>

#### Sub function

<details>
    <summary>Input(Infos, Type=false)</summary>
    <p>Arguments: JSON Infos {Question: string, Description: string, Buttons: JSON {string Button1, string Button2, string Button3}, DefaultButton : string}, string Type [IntegerInput|FloatInput|TextInput|DropDown]</p>
    <p>This function will return the ShowCockpit CreatePrompt() object</p>
</details>
<details>
    <summary>ShowInput(Prompt, Infos)</summary>
    <p>Arguments: object CreatePrompt, JSON Infos {Cancel: boolean}</p>
    <p>Dependency: CheckInput()</p>
    <p>This function will display the CreatePrompt to the user and will return the user answer (CheckInput() function output)</p>
</details>
<details>
    <summary>CheckInput(Infos, Answer)</summary>
    <p>Arguments: JSON Infos {Cancel: boolean}, array Answer</p>
    <p>This function will return, following the Infos.Cancel value, the user answer. If Infos.Cancel is true, and the user answer is empty or button cancel, the return will be a NIL value. Else, the answer will be the button content or the input value</p>
</details>

### Onyx Function

<details>
    <summary>ListPreset(PresetType, PresetIDStart, PresetIDEnd)</summary>
    <p>Arguments: string PresetType [Intensity|PanTilt|Color|Gobo|Beam|BeamFX|Framing], int PresetIDStart, int PresetIDEnd</p>
    <p>Dependency: GetPresetName()</p>
    <p>This function will return an array of JSON object {id,name} with all Presets name of PresetType from ID PresetIDStart to ID PresetIDEnd</p>
</details>
<details>
    <summary>ListCuelist(CuelistIDStart, CuelistIDEnd)</summary>
    <p>Arguments: int CuelistIDStart, int CuelistIDEnd</p>
    <p>This function will return an array of JSON object {id,name} with all Cuelist name from ID CuelistIDStart to ID CuelistIDEnd</p>
</details>
<details>
    <summary>ListGroup(GroupIDStart, GroupIDEnd)</summary>
    <p>Arguments: int GroupIDStart, int GroupIDEnd</p>
    <p>This function will return an array of JSON object {id,name} with all Group name from ID GroupIDStart to ID GroupIDEnd</p>
</details>
<details>
    <summary>DeletePreset(PresetType, PresetID)</summary>
    <p>Arguments: string PresetType [Intensity|PanTilt|Color|Gobo|Beam|BeamFX|Framing], int PresetID</p>
    <p>This function will delete the Preset of PresetType with ID PresetID</p>
</details>
<details>
    <summary>GetPresetName(PresetType, PresetID)</summary>
    <p>Arguments: string PresetType [Intensity|PanTilt|Color|Gobo|Beam|BeamFX|Framing], int PresetID</p>
    <p>Dependency: CheckEmpty()</p>
    <p>This function will return the Preset name of PresetType with ID PresetID. If there is no Preset, it will return "--"</p>
</details>
<details>
    <summary>GetPresetAppearance(PresetType, PresetID)</summary>
    <p>Arguments: string PresetType [Intensity|PanTilt|Color|Gobo|Beam|BeamFX|Framing], int PresetID</p>
    <p>Dependency: CheckEmpty()</p>
    <p>This function will return the Preset apperance of PresetType with ID PresetID. If there is no Preset apperance, it will return the DefaultPresetAppearance of PresetType</p>
</details>
<details>
    <summary>RecordCuelist(CuelistID)</summary>
    <p>Arguments: int CuelistID</p>
    <p>Dependency: KeyNumber()</p>
    <p>This function will record a new cuelist (of the latest recorded cuelist type) with ID CuelistID</p>
</details>
<details>
    <summary>RecordPreset(PresetType, Preset, Merging)</summary>
    <p>Arguments: string PresetType [Intensity|PanTilt|Color|Gobo|Beam|BeamFX|Framing], JSON Preset {Position: int, Name: string}, boolean Merging</p>
    <p>This function will create a preset of the provided PresetType at Preset.Position named Preset.Name. You can merge the preset creation by setting Merging to true, false will overwrite</p>
</details>
<!---<details>
    <summary>DeleteGroup(GroupID)</summary>
    <p>Arguments: int GroupID</p>
    <p>Dependency: KeyNumber()</p>
    <p>This function will delete a group with ID GroupID</p>
</details>-->
<details>
    <summary>KeyNumber(Number)</summary>
    <p>Arguments: int number</p>
    <p>This function will type with the Onyx Keyboard the Number pass as argument</p>
</details>
<details>
    <summary>CopyCue(CuelistIDSource, CueID, CuelistIDTarget)</summary>
    <p>Arguments: int CuelistIDSource, int CueID, int CuelistIDTarget</p>
    <p>Dependency: KeyNumber()</p>
    <p>This function will copy an existing Cue CueID from an existing Cuelist CuelistIDSource to another existing Cuelist CuelistIDTarget</p>
</details>
