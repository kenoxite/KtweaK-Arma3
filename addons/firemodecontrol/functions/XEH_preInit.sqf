#include "\z\ktweak\addons\firemodecontrol\version.hpp"

[
    "ktweak_firemodecontrol",
    VERSION_STR,
    { /* mismatch handler */ }
] call CBA_fnc_registerVersion;

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

#define MAIN ""

// -----------------------------------------------------------------------------------------------
//  CLIENT
// -----------------------------------------------------------------------------------------------

// FIREMODE CONTROL
[
    "KTWK_FMC_opt_restrictFiremodes",
    "CHECKBOX",
    ["Restrict firemode cycling", "Limits cycling to primary muzzle firemodes only.\nExample: [single >> burst >> full auto] instead of [single >> burst >> full auto >> grenade launcher].\n\nTo access the grenade launcher, or any other alternate firemode, use the new keybind defined in Settings -> Controls, under Mods.\n"],
    ["KtweaK - Firemode Control", MAIN],
    [false],
    0,
    {}
] call CBA_fnc_addSetting;
