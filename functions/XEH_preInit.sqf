// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// * EH *
// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------

["CAManBase", "initPost", {
    params ["_unit"];
    // Stop if being healed
    _unit addEventHandler ["HandleHeal", {
        // Only apply to local units
        if (!KTWK_SFH_opt_enabled || !local _this#0) exitwith {};
        _this spawn {
            // Wait a bit before applying this EH to make sure it's applied, even if all EHs are deleted from the unit (by a mission or other means)
            sleep 3;
            params ["_injured", "_healer"];
            private _damage = damage _injured;
            private _startTime = time;
            if (_healer == p1) then {
                _injured disableAI "MOVE";
                waitUntil {damage _injured != _damage || !alive _injured || !alive _healer || (time - _startTime) > 30};
                _injured enableAI "MOVE";
                if (damage _injured != _damage) then {
                    _healer addRating (round (200 * _damage));
                };
            };
        };
    }];
}] call CBA_fnc_addClassEventHandler;



// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// * CBA *
// -----------------------------------------------------------------------------------------------
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
[
    "KTWK_opt_debug", 
    "CHECKBOX",
    ["Debug", "Debug Mode"],
    ["kTweaks", ""],
    [false],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// STOP FOR HEALING
// -----------------------------------------------------------------------------------------------
[
    "KTWK_SFH_opt_enabled", 
    "CHECKBOX",
    ["Enable Stop for Healing", "If enabled, AI infantry will stop moving when being healed, even when the group leader hasn't issued a heal unit order (which is the only way they stop for heals by default).\n"],
    ["kTweaks", "Stop for Healing"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// HUMIDITY EFFECTS
// -----------------------------------------------------------------------------------------------
[
    "KTWK_HFX_opt_enabled", 
    "CHECKBOX",
    ["Enable Humidity Effects", "If enabled, blurry visuals and muffled sounds will be applied depending on the current fog settings and the location of the player respective to the fog.\nThe effect is increased the deeper the player is into the fog and is lowered when inside a covered vehicle or building.\n"],
    ["kTweaks", "Humidity Effects"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;
[
    "KTWK_HFX_opt_intensity", 
    "LIST",
    ["Effect Intensity", "Strength of the blur effect and the dampening of sounds.\n"],
    ["kTweaks", "Humidity Effects"],
    [[3, 2, 1], ["Low", "Moderate", "Strong"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;
[
    "KTWK_HFX_opt_activeEffects", 
    "LIST",
    ["Active Effects", "Choose which effects should be applied.\n"],
    ["kTweaks", "Humidity Effects"],
    [[0, 1, 2], ["All", "Only visual", "Only auditive"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;


// -----------------------------------------------------------------------------------------------
// FATAL WOUNDS
// -----------------------------------------------------------------------------------------------
[
    "KTWK_FW_opt_enabled", 
    "CHECKBOX",
    ["Enable Fatal Wounds", "If enabled, dead units will play a fatally wounded animation.\nThe animation played is random, but based on the location of the body part that killed the unit.\nUnits have a chance of being instantly dead (no fatally wounded animation will be played) if the head or chest is severely wounded.\nIn both cases, the unit is actually killed and, if not instantly dead, a clone (an agent) will be spawned to play the fatally wounded animation.\n\nFatally wounded units will scream in pain if using mods like 'SSD Death Screams' or 'Project Human'.\n"],
    ["kTweaks", "Fatal Wounds"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_mode", 
    "LIST",
    ["Animation mode", "Delete original corpse: The dead unit is deleted and a clone is created, which will be the one playing the fatally wounded animation.\n\nKeep original corpse: The dead unit is hidden and a clone is created, which will play the fatally wounded animation.\n Once the animation is done,the clone will be deleted and the original dead unit will be repositioned on the last position of the clone.\n Use this option for better compatibility with some missions and mods.\n"],
    ["kTweaks", "Fatal Wounds"],
    [["delete", "keep"], ["Delete original corpse", "Keep original corpse"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_maxRange", 
    "SLIDER",
    ["Animation range", "Max distance from the player at which units will play fatally wounded animations, in meters."],
    ["kTweaks", "Fatal Wounds"],
    [0, 5000, 500, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_deleteTimer", 
    "SLIDER",
    ["Time until corpse deletion", "Time until the cloned corpse is 'buried' (hideBody), in seconds. Set to 0 to not delete.\nIt only applies if 'Delete original corpse' is selected and will only delete the clone, so it won't hide the original corpse if it was instant death and no clone was created.\n"],
    ["kTweaks", "Fatal Wounds"],
    [0, 3600, 0, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;


