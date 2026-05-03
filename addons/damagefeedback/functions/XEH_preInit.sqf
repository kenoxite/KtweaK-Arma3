#include "\z\ktweak\addons\damagefeedback\version.hpp"

[
    "ktweak_damagefeedback",
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

// DAMAGE FEEDBACK
[
    "KTWK_DFB_opt_enabled",
    "CHECKBOX",
    ["Enable", "A visual representation of damaged body areas will briefly appear in the bottom right corner when you take damage.\nYour current overall health status will also appear when the inventory is opened.\n"],
    ["KtweaK - Damage Feedback", ""],
    [true],
    0,
    { call KTWK_DFB_fnc_toggleSystem; }
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_showInjured",
    "CHECKBOX",
    ["Show on damage", "The damage representation will briefly appear whenever any body part takes damage.\n"],
    ["KtweaK - Damage Feedback", ""],
    [true],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_showInv",
    "CHECKBOX",
    ["Show when inventory is opened", "Your current overall health status will appear when the inventory is opened.\n"],
    ["KtweaK - Damage Feedback", ""],
    [true],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_alpha",
    "SLIDER",
    ["Default display transparency", "Default transparency. Set higher than 0 to keep the display always visible.\n"],
    ["KtweaK - Damage Feedback", ""],
    [0, 1, 0, 2],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_xPos",
    "SLIDER",
    ["Horizontal Position", "How close to the left of the screen the display sits, relative to the default bottom right corner position.\n"],
    ["KtweaK - Damage Feedback", ""],
    [0, 117, 0, 2],
    0,
    { call KTWK_DFB_fnc_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_yPos",
    "SLIDER",
    ["Vertical Position", "How close to the top of the screen the display sits, relative to the default bottom right corner position.\n"],
    ["KtweaK - Damage Feedback", ""],
    [0, 60.5, 0, 2],
    0,
    { call KTWK_DFB_fnc_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_ColorHealthy",
    "COLOR",
    ["Healthy color", "Color for undamaged body parts.\n"],
    ["KtweaK - Damage Feedback", ""],
    [0.8, 0.8, 0.8],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_ColorScuffed",
    "COLOR",
    ["Scuffed color", "Color for slightly damaged body parts.\n"],
    ["KtweaK - Damage Feedback", ""],
    [0.75, 0.6, 0.75],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_ColorLightWound",
    "COLOR",
    ["Light Wound color", "Color for lightly wounded body parts.\n"],
    ["KtweaK - Damage Feedback", ""],
    [1, 1, 0],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_ColorModerateWound",
    "COLOR",
    ["Moderate Wound color", "Color for moderately wounded body parts.\n"],
    ["KtweaK - Damage Feedback", ""],
    [1, 0.5, 0],
    0,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_DFB_opt_ColorSevereWound",
    "COLOR",
    ["Severe Wound color", "Color for severely wounded body parts.\n"],
    ["KtweaK - Damage Feedback", ""],
    [0.6, 0, 0],
    0,
    {}
] call CBA_fnc_addSetting;
