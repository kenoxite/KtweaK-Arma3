#include "\z\ktweak\addons\brightermoonlight\version.hpp"

[
    "ktweak_brightermoonlight",
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
//  SERVER
// -----------------------------------------------------------------------------------------------
[
    "KTWK_BM_opt_enabled",
    "LIST",
    ["Brighter Moonlight", "If enabled, lighting in full moon nights will be brighter.\nIt automatically works on any terrain and also in the Eden editor."],
    ["KtweaK - Server", ""],
    [[0,1,2], ["Disable", "Bright", "Brighter"], 1],
    1,
    {}
] call CBA_fnc_addSetting;
