#include "\z\ktweak\addons\nvg\version.hpp"

#define MAIN ""
#define MANUAL "1. Manual"
#define ADVANCED "2. Advanced"
#define COLOR_PRESETS "3. Color Presets"
#define CUSTOM_GEAR "4. Custom Gear"
#define CUSTOM_COLORS "5. Custom Gear Colors"
#define EXCLUSIONS "6. Exclusions"
#define MANUAL_DESC "\nNV Mode must be set to manual if you want to use these settings!\n"
#define MAGICWORDS_DESC "\nMagic words automatically convert to the corresponding class names:\n- nvg = currently equipped NVG\n- helmet = currently worn helmet with built-in NV\n- binoc = currently held rangefinder or laser designator with NV\n- scope = currently attached weapon optic with NV\n- vehicle = current vehicle with NV capabilities\n\nExample: nvg, vehicle, <classNameOfThatCoolMod>\n\nMagic Words become permanent class names after accepting the changes.\n"

[
    "ktweak_nvg",
    VERSION_STR,
    { /* mismatch handler */ }
] call CBA_fnc_registerVersion;

// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// * CBA *
// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// KEYBINDS
// -----------------------------------------------------------------------------------------------
#include "\a3\ui_f\hpp\definedikcodes.inc"

/*
Function: CBA_fnc_addKeybind

Description:
 Adds or updates the keybind handler for a specified mod action, and associates
 a function with that keybind being pressed.

Parameters:
 _modName           Name of the registering mod [String]
 _actionId          Id of the key action. [String]
 _displayName       Pretty name, or an array of strings for the pretty name and a tool tip [String]
 _downCode          Code for down event, empty string for no code. [Code]
 _upCode            Code for up event, empty string for no code. [Code]

 Optional:
 _defaultKeybind    The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
 _holdKey           Will the key fire every frame while down [Bool]
 _holdDelay         How long after keydown will the key event fire, in seconds. [Float]
 _overwrite         Overwrite any previously stored default keybind [Bool]

Returns:
 Returns the current keybind for the action [Array]
*/

[
    ["KtweaK - NVG", ""],
    "KTWK_NVG_key_irLight",
    ["Toggle NVG IR Light", "Toggles an IR illuminator attached to the player when using NVGs"],
    { [!KTWK_NVG_irLightToggle] call KTWK_NVG_fnc_toggleIRLight },
    {},
    [ DIK_I, [false, false, true] ], // [DIK, [shift, ctrl, alt]
    false
] call CBA_fnc_addKeybind;

// -----------------------------------------------------------------------------------------------
// SETTINGS
// -----------------------------------------------------------------------------------------------
/*
Parameters:
    _setting     - Unique setting name. Matches resulting variable name <STRING>
    _settingType - Type of setting. Can be "CHECKBOX", "EDITBOX", "LIST", "SLIDER" or "COLOR" <STRING>
    _title       - Display name or display name + tooltip (optional, default: same as setting name) <STRING, ARRAY>
    _category    - Category for the settings menu + optional sub-category <STRING, ARRAY>
    _valueInfo   - Extra properties of the setting depending of _settingType. See examples below <ANY>
    _isGlobal    - 1: all clients share the same setting, 2: setting can't be overwritten (optional, default: 0) <NUMBER>
    _script      - Script to execute when setting is changed. (optional) <CODE>
    _needRestart - Setting will be marked as needing mission restart after being changed. (optional, default false) <BOOL>
*/

// -----------------------------------------------------------------------------------------------
//  CLIENT
// -----------------------------------------------------------------------------------------------

// NVG EFFECTS
[
    "KTWK_NVG_opt_enabled",
    "CHECKBOX",
    ["Enable", "If enabled, some blur and noise will be applied when night vision of any type is active.\nThe strength of the effect is calculated based on the device generation and lighting conditions.\n\nDisabled if ACE Nightvision is detected, regardless of this setting.\n"],
    ["KtweaK - NVG", MAIN],
    [true],
    0,
    {[!KTWK_NVG_isActive] call KTWK_NVG_fnc_toggleSystem}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_blurADS",
    "CHECKBOX",
    ["Blur when ADS", "Apply a heavy blur effect when aiming down sights.\n"],
    ["KtweaK - NVG", MAIN],
    [false],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_nvMode",
    "LIST",
    ["NV Mode", "Select night vision behavior.\n\n- Full: Full optical simulation with dynamic ambient darkening and film grain. Image will be significantly darker in low light.\n  Recommended to use with an IR illumination mod (ITN, BettIR, etc).\n- Basic: Generation based blur, color, and range limits. No dynamic darkening or film grain. Standard Arma lighting works normally.\n- Manual: Use manual settings only. Auto-detection disabled.\n"],
    ["KtweaK - NVG", MAIN],
    [[0,1,2], ["Full", "Basic", "Manual"], 0],
    0,
    {}
] call CBA_fnc_addSetting;


// ------------------
// MANUAL EFFECTS
[
    "KTWK_NVG_opt_intensity",
    "SLIDER",
    ["Effect Intensity", format ["Intensity of the effect. Setting it to 0 will not disable the effect, but will diminish it considerably.\nSet it higher than default if you want to emulate older generation devices.\n%1", MANUAL_DESC]],
    ["KtweaK - NVG", MANUAL],
    [0, 1, 0.4, 1],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color",
    "LIST",
    ["Phosphor Color", format ["Choose the night vision color.\n%1", MANUAL_DESC]],
    ["KtweaK - NVG", MANUAL],
    [[0, 1, 2, 3, 4, 5, 6], ["None", "Military Green", "White Phosphor", "Amber", "Black and White", "Crimson", "Custom"], 0],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_brightness",
    "SLIDER",
    ["Ambient Brightness", format ["Darkens and brightens the night vision effect based on current lighting at the player position.\n0 = no effect, higher = stronger effect.\n%1", MANUAL_DESC]],
    ["KtweaK - NVG", MANUAL],
    [0, 1.5, 1.2, 1],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_noise",
    "SLIDER",
    ["Darkness Noise", format ["Noise and blur increases in darker areas.\n0 = no effect, higher = more noise.\n%1", MANUAL_DESC]],
    ["KtweaK - NVG", MANUAL],
    [0, 1, 0.5, 1],
    0,
    {}
] call CBA_fnc_addSetting;

// ------------------
// ADVANCED EFFECTS

[
    "KTWK_NVG_opt_baseBlur",
    "SLIDER",
    ["Base Blur", "Base amount of blur applied to the night vision effect.\nHigher values increase overall blur.\n"],
    ["KtweaK - NVG", ADVANCED],
    [0, 0.5, 0.20, 2],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_outOfRangeBlur",
    "SLIDER",
    ["Out of Range Blur", "Additional blur multiplier when looking at distant objects beyond the device effective range.\n0 = no extra blur, 1 = maximum extra blur.\n"],
    ["KtweaK - NVG", ADVANCED],
    [0, 1, 1, 2],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_filmGrainEnabled",
    "CHECKBOX",
    ["Film Grain", "Applies film grain to the night vision effect.\nNote that disabling this will SEVERELY hinder the emulation of NV device generations.\n"],
    ["KtweaK - NVG", ADVANCED],
    [true],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_pfhInterval",
    "SLIDER",
    ["Update Interval", "Time in seconds between effect updates.\nLower values = smoother transitions but more CPU usage.\nHigher values = slower updates to the effects but better performance.\n"],
    ["KtweaK - NVG", ADVANCED],
    [0, 0.5, 0.15, 2],
    0,
    {}
] call CBA_fnc_addSetting;

// ------------------
// CUSTOM GEAR
[
    "KTWK_NVG_opt_gen1",
    "EDITBOX",
    ["Gen 1 Devices", format ["List of Generation 1 device class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_gen2",
    "EDITBOX",
    ["Gen 2 Devices", format ["List of Generation 2 device class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_gen3",
    "EDITBOX",
    ["Gen 3 Devices", format ["List of Generation 3 device class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_gen4",
    "EDITBOX",
    ["Gen 4 Devices", format ["List of Generation 4 device class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

// ------------------
// CUSTOM GEAR COLORS
[
    "KTWK_NVG_opt_color_wp",
    "EDITBOX",
    ["White Phosphor Devices", format ["List of devices you want to use White Phosphor.\nIt can be class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_amber",
    "EDITBOX",
    ["Amber Devices", format ["List of devices you want to use Amber filter.\nIt can be class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_bw",
    "EDITBOX",
    ["Black and White Devices", format ["List of devices you want to use Black and White filter.\nIt can be class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_crimson",
    "EDITBOX",
    ["Crimson Devices", format ["List of devices you want to use Crimson filter.\nIt can be class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;
[
    "KTWK_NVG_opt_color_green",
    "EDITBOX",
    ["Military Green Devices", format ["List of devices you want to use Military Green.\nIt can be class names or Magic Words, without quotes and separated by commas.\n\nNote that auto-detected devices will default to this color, so adding something here is only needed if it defaults to another one (white phosphor, amber, etc) and want it green.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

// ------------------
// EXCLUSION LISTS

[
    "KTWK_NVG_opt_excludeGlobal",
    "EDITBOX",
    ["Global Exclusion", format ["List of devices to exclude from ALL night vision effects.\nIt can be class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", EXCLUSIONS],
    "",
    0,
    { call KTWK_NVG_fnc_updateExclusions }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_excludeAutoGen",
    "EDITBOX",
    ["Auto-Detect Generation Exclusion", format ["List of devices to exclude ONLY from Auto-Detect Generation, so you can apply manual intensity, color, etc.\nIt can be class names or Magic Words, without quotes and separated by commas.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG", EXCLUSIONS],
    "",
    0,
    { call KTWK_NVG_fnc_updateExclusions }
] call CBA_fnc_addSetting;


// ------------------
// COLOR PRESETS

[
    "KTWK_NVG_opt_color_1",
    "COLOR",
    ["Military Green", "Color for 'Military Green' preset."],
    ["KtweaK - NVG", COLOR_PRESETS],
    [0.35, 0.65, 0.15],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_2",
    "COLOR",
    ["White Phosphor", "Color for 'White Phosphor' preset."],
    ["KtweaK - NVG", COLOR_PRESETS],
    [0.7, 0.92, 0.95],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_3",
    "COLOR",
    ["Amber", "Color for 'Amber' preset."],
    ["KtweaK - NVG", COLOR_PRESETS],
    [0.96, 0.98, 0.45],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_4",
    "COLOR",
    ["Black and White", "Color for 'Black and White' preset."],
    ["KtweaK - NVG", COLOR_PRESETS],
    [1, 1, 1],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_5",
    "COLOR",
    ["Crimson", "Color for 'Crimson' preset."],
    ["KtweaK - NVG", COLOR_PRESETS],
    [1.0, 0.6, 0.6],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_6",
    "COLOR",
    ["Custom", "Color for 'Custom' preset.\nUse this if you want to keep the default colors as is and want a new one for particular devices."],
    ["KtweaK - NVG", COLOR_PRESETS],
    [0.1, 0.9, 0.8],
    0,
    {}
] call CBA_fnc_addSetting;
