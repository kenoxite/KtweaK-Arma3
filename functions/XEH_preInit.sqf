// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// * EH *
// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------

["CAManBase", "initPost", {
    params ["_unit"];
    // Stop if being healed
    _unit spawn {
        // Wait a bit before applying this EH to make sure it's applied, even if all EHs are deleted from the unit (by a mission or other means)
        sleep 3;
        _this addEventHandler ["HandleHeal", {
            if (!KTWK_SFH_opt_enabled) exitwith {};
            params ["_injured", "_healer"];
            // Only apply when healer is a player or a player controlled unit and also if injured unit is local to the player
            private _players = allPlayers - entities "HeadlessClient_F";
            if (!local _injured || (!(_healer in _players) && !(remoteControlled _healer in _players))) exitwith {};
            _this spawn {
                params ["_injured", "_healer"];
                private _damage = damage _injured;
                private _startTime = time;
                _injured disableAI "MOVE";
                waitUntil {damage _injured != _damage || !alive _injured || !alive _healer || (time - _startTime) > 30};
                _injured enableAI "MOVE";
                // Add some mission rating to the player to reward being an active healer, based on amount healed
                if (damage _injured != _damage) then {
                    _healer addRating (round (200 * _damage));
                };
            };
        }];
        _this addEventHandler ["Fired", {
            if (!KTWK_laser_opt_enabled) exitwith {};
            // Enable IR laser
            (_this#0) enableIRLasers true;
            _this spawn {
                sleep 2;
                // Disable IR laser
                (_this#0) enableIRLasers false;
            };
        }];
    };
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
    ["Enable", "If enabled, AI infantry will stop moving when being healed, even when the group leader hasn't issued a heal order (which is the only way they stop for heals by default).\n"],
    ["kTweaks", "AI Stop for Healing"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// BettIR AUTOENABLE
// -----------------------------------------------------------------------------------------------
[
    "KTWK_BIR_NVG_illum_opt_enabled", 
    "LIST",
    ["Auto enable NVG illuminator", "Automatically enable the NVG illuminator for all AI units, in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["kTweaks", "BettIR Auto Enable for AI"],
    [[0,1,2], ["Never", "Always", "When too dark or in building"], 2],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_BIR_wpn_illum_opt_enabled", 
    "LIST",
    ["Auto enable weapon illuminator", "Automatically enable the weapon illuminator, in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["kTweaks", "BettIR Auto Enable for AI"],
    [[0,1,2,3], ["Never", "Always", "When too dark or in building", "When too dark or in building and in combat"], 3],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_BIR_stealth_opt_enabled", 
    "LIST",
    ["Disable illuminators in stealth mode", "Toggle the use of illuminators by the AI when in stealth mode, in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["kTweaks", "BettIR Auto Enable for AI"],
    [[0,1,2,3], ["Always", "Never", "Disable NVG illuminators", "Disable weapon illuminators"], 2],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// AI AUTO LASER
// -----------------------------------------------------------------------------------------------
[
    "KTWK_laser_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, infantry AI will briefly enable their IR laser when firing.\n"],
    ["kTweaks", "AI Auto IR Laser"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// HEALTH HUD
// -----------------------------------------------------------------------------------------------
[
    "KTWK_HUD_health_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, a HUD displaying the damage suffered by the player will briefly appear in the bottom right corner. It will be displayed whenever the health status changes, or as long as the player inventory is opened.\n"],
    ["kTweaks", "Health HUD"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_showInjured", 
    "CHECKBOX",
    ["Display when health changes", "If enabled, the health HUD will be briefly displayed whenever the health of any body part changes.\n"],
    ["kTweaks", "Health HUD"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_showInv", 
    "CHECKBOX",
    ["Display when inventory is opened", "If enabled, the health HUD will be displayed as long as the player has the inventory opened.\n"],
    ["kTweaks", "Health HUD"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorHealthy", 
    "COLOR",
    ["Healthy color", "Color for healthy body parts.\n"],
    ["kTweaks", "Health HUD"],
    [0.5,0.5,0.5],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorLightWound", 
    "COLOR",
    ["Light Wound color", "Color for lightly wounded body parts.\n"],
    ["kTweaks", "Health HUD"],
    [1,1,0],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorModerateWound", 
    "COLOR",
    ["Moderate Wound color", "Color for moderately wounded body parts.\n"],
    ["kTweaks", "Health HUD"],
    [1,0.5,0],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorSevereWound", 
    "COLOR",
    ["Severe Wound color", "Color for severely wounded body parts.\n"],
    ["kTweaks", "Health HUD"],
    [0.6,0,0],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// HUMIDITY EFFECTS
// -----------------------------------------------------------------------------------------------
[
    "KTWK_HFX_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, blurry visuals and muffled sounds will be applied depending on the current fog settings and the location of the player respective to the fog.\nThe effect is increased the deeper the player is into the fog and is lowered when inside a covered vehicle or building.\n"],
    ["kTweaks", "XPERIMENTAL Humidity Effects"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;
[
    "KTWK_HFX_opt_intensity", 
    "LIST",
    ["Effect Intensity", "Strength of the blur effect and the dampening of sounds.\n"],
    ["kTweaks", "XPERIMENTAL Humidity Effects"],
    [[3, 2, 1], ["Low", "Moderate", "Strong"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;
[
    "KTWK_HFX_opt_activeEffects", 
    "LIST",
    ["Active Effects", "Choose which effects should be applied.\n"],
    ["kTweaks", "XPERIMENTAL Humidity Effects"],
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
    ["Enable", "If enabled, dead units will play a fatally wounded animation.\nThe animation played is random, but based on the location of the body part that killed the unit.\nUnits have a chance of being instantly dead (no fatally wounded animation will be played) if the head or chest is severely wounded.\nIn both cases, the unit is actually killed and, if not instantly dead, a clone (an agent) will be spawned to play the fatally wounded animation.\n\nFatally wounded units will scream in pain if using mods like 'SSD Death Screams' or 'Project Human'.\n"],
    ["kTweaks", "XPERIMENTAL Fatal Wounds"],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_mode", 
    "LIST",
    ["Animation mode", "Delete original corpse: The dead unit is deleted and a clone is created, which will be the one playing the fatally wounded animation.\n\nKeep original corpse: The dead unit is hidden and a clone is created, which will play the fatally wounded animation.\n Once the animation is done,the clone will be deleted and the original dead unit will be repositioned on the last position of the clone.\n Use this option for better compatibility with some missions and mods.\n"],
    ["kTweaks", "XPERIMENTAL Fatal Wounds"],
    [["delete", "keep"], ["Delete original corpse", "Keep original corpse"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_maxRange", 
    "SLIDER",
    ["Animation range", "Max distance from the player at which units will play fatally wounded animations, in meters."],
    ["kTweaks", "XPERIMENTAL Fatal Wounds"],
    [0, 5000, 500, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_deleteTimer", 
    "SLIDER",
    ["Time until corpse deletion", "Time until the cloned corpse is 'buried' (hideBody), in seconds. Set to 0 to not delete.\nIt only applies if 'Delete original corpse' is selected and will only delete the clone, so it won't hide the original corpse if it was instant death and no clone was created.\n"],
    ["kTweaks", "XPERIMENTAL Fatal Wounds"],
    [0, 3600, 0, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;


