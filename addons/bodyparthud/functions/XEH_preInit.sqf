#include "\z\ktweak\addons\bodyparthud\version.hpp"

[
    "ktweak_bodyparthud",
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

// BODYPART HUD
[
    "KTWK_BPH_opt_enabled",
    "CHECKBOX",
    ["Enable", "If enabled, a HUD displaying the damage suffered by the player will briefly appear in the bottom right corner.\nIt will be displayed whenever the health status changes. The current overall health status will be displayed when the inventory is opened.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [true],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_showInjured",
    "CHECKBOX",
    ["Display when health changes", "If enabled, the bodypart HUD will be briefly displayed whenever the health of any body part changes.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [true],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_showInv",
    "CHECKBOX",
    ["Display when inventory is opened", "If enabled, the current overall health status will be displayed when the inventory is opened.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [true],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_alpha",
    "SLIDER",
    ["Default HUD transparency", "Default transparency. If bigger than 0, the HUD will always be visible.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [0, 1, 0, 2],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_xPos",
    "SLIDER",
    ["Horizontal Position", "How close to the left of the screen you want the HUD to be, relative to the default position in the bottom right corner.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [0, 117, 0, 2],
    0,
    { call KTWK_BPH_fnc_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_yPos",
    "SLIDER",
    ["Vertical Position", "How close to the top of the screen you want the HUD to be, relative to the default position in the bottom right corner.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [0, 60.5, 0, 2],
    0,
    { call KTWK_BPH_fnc_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_ColorHealthy",
    "COLOR",
    ["Healthy color", "Color for undamaged body parts.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [0.8, 0.8, 0.8],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_ColorScuffed",
    "COLOR",
    ["Scuffed color", "Color for slightly damaged body parts.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [0.75, 0.6, 0.75],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_ColorLightWound",
    "COLOR",
    ["Light Wound color", "Color for lightly wounded body parts.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [1, 1, 0],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_ColorModerateWound",
    "COLOR",
    ["Moderate Wound color", "Color for moderately wounded body parts.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [1, 0.5, 0],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BPH_opt_ColorSevereWound",
    "COLOR",
    ["Severe Wound color", "Color for severely wounded body parts.\n"],
    ["KtweaK - Bodypart HUD", ""],
    [0.6, 0, 0],
    0,
    {}
] call CBA_fnc_addSetting;
