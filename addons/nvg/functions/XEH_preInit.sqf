#include "\z\ktweak\addons\nvg\version.hpp"

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
    ["KtweaK - Client", "NVG Effects"],
    [false],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_NVG_opt_intensity",
    "SLIDER",
    ["Effect Intensity", "Intensity of the effect. Setting it to 0 will not disable the effect, but will diminish it considerably.\nSet it higher than default if you want to emulate older generation devices.\n"],
    ["KtweaK - Client", "NVG Effects"],
    [0, 10, 1, 1],
    0,
    {}
] call CBA_fnc_addSetting;
