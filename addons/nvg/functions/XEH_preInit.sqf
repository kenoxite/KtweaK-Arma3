#include "\z\ktweak\addons\nvg\version.hpp"

#define MAIN ""
#define CUSTOM_GEAR "Custom Gear"
#define CUSTOM_COLORS "Custom Colors"
#define EXCLUSIONS "Exclusions"
#define MAGICWORDS_DESC "\nMagic words automatically convert to the class name of the item you are currently using when you save the settings:\n- nvg = currently equipped NVG goggles\n- helmet = currently worn helmet with built-in NVG\n- binoc = currently held binocular/rangefinder/designator\n- scope = currently attached weapon optic\n\nExample: nvg, helmet, myCustomGoggles\nAfter saving, magic words become permanent class names.\n"

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
    ["Enable", "If enabled, some blur and noise will be applied when night vision of any type is active, the strength of which will depend on the device used (portable NVG, vehicle NVG, NVG optics, etc).\nThe same effect will be applied to all NVGs, independently of its generation and real-life equivalent visual quality.\n\nDisabled if ACE Nightvision is detected, regardless of this setting.\n"],
    ["KtweaK - NVG Effects", MAIN],
    [true],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_autoGen",
    "CHECKBOX",
    ["Auto-detect NVG Generation", "If enabled, effect intensity is automatically set based on NVG quality (Gen 1-4) of known NVG systems, based on ACE Nightvision definitions.\nOverrides the manual Intensity slider.\n"],
    ["KtweaK - NVG Effects", MAIN],
    [false],
    0,
    { KTWK_NVG_cachedItemClass = ""; }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_intensity",
    "SLIDER",
    ["Effect Intensity", "Intensity of the effect. Setting it to 0 will not disable the effect, but will diminish it considerably.\nSet it higher than default if you want to emulate older generation devices.\n"],
    ["KtweaK - NVG Effects", MAIN],
    [0, 10, 1, 1],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color",
    "LIST",
    ["Phosphor Color", "Choose the NVG color tint.\nNone: No change\nGreen: Standard military\nWhite Phosphor: Blue-white modern\nAmber: Orange-yellow filter\nWhite: Black and white filter\nCrimson: Red filter\n"],
    ["KtweaK - NVG Effects", MAIN],
    [[0, 1, 2, 3, 4, 5], ["None", "Military Green", "White Phosphor", "Amber", "Bland and White", "Crimson"], 0],
    0,
    { KTWK_NVG_cachedColor = []; KTWK_NVG_cachedColorPreset = -1; }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_brightness",
    "SLIDER",
    ["Ambient Brightness", "Darkens and brightens the NVG effect based on current lighting at the player position.\n0 = no effect, higher = stronger effect.\n"],
    ["KtweaK - NVG Effects", MAIN],
    [0, 1, 1, 1],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_noise",
    "SLIDER",
    ["Darkness Noise", "Noise and blur increases in dark areas.\n0 = no effect, higher = more noise.\n"],
    ["KtweaK - NVG Effects", MAIN],
    [0, 1, 0, 1],
    0,
    {}
] call CBA_fnc_addSetting;

// ------------------
// CUSTOM GEAR
[
    "KTWK_NVG_opt_gen1",
    "EDITBOX",
    ["Gen 1 Devices", format ["Comma-separated list of Gen 1 device class names, without quotes.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_gen2",
    "EDITBOX",
    ["Gen 2 Devices", format ["Comma-separated list of Gen 2 device class names, without quotes.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_gen3",
    "EDITBOX",
    ["Gen 3 Devices", format ["Comma-separated list of Gen 3 device class names, without quotes.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_gen4",
    "EDITBOX",
    ["Gen 4 Devices", format ["Comma-separated list of Gen 4 device class names, without quotes.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_GEAR],
    "",
    0,
    { call KTWK_NVG_fnc_updateGenArrays }
] call CBA_fnc_addSetting;

// ------------------
// CUSTOM COLORS
[
    "KTWK_NVG_opt_color_wp",
    "EDITBOX",
    ["White Phosphor Devices", format ["Comma-separated list of device class names that use White Phosphor.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_amber",
    "EDITBOX",
    ["Amber Devices", format ["Comma-separated list of device class names that use Amber filter.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_bw",
    "EDITBOX",
    ["Black and White Devices", format ["Comma-separated list of device class names that use Black and White filter.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_color_crimson",
    "EDITBOX",
    ["Crimson Devices", format ["Comma-separated list of device class names that use Crimson filter.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", CUSTOM_COLORS],
    "",
    0,
    { call KTWK_NVG_fnc_updateColorArrays }
] call CBA_fnc_addSetting;

// ------------------
// EXCLUSION LISTS

[
    "KTWK_NVG_opt_excludeGlobal",
    "EDITBOX",
    ["Global Exclusion", format ["Comma-separated list of items to exclude from ALL NVG effects.\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", EXCLUSIONS],
    "",
    0,
    { call KTWK_NVG_fnc_updateExclusions }
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_excludeAutoGen",
    "EDITBOX",
    ["AutoGen Exclusion", format ["Comma-separated list of items to exclude from AutoGen only (manual intensity/color settings still apply).\n%1", MAGICWORDS_DESC]],
    ["KtweaK - NVG Effects", EXCLUSIONS],
    "",
    0,
    { call KTWK_NVG_fnc_updateExclusions }
] call CBA_fnc_addSetting;
