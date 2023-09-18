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
    ["KtweaK", ""],
    [false],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// DISABLE VOICES FOR NON HUMANS
// -----------------------------------------------------------------------------------------------
[
    "KTWK_disableVoices_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, voice mods will be disabled for non humanoid AI units, such as zombies or horses.\nSupported creatures: Ravage, Webknight's Zombies, Drongo's Spooks, Zombies and Demons, Max Zombies, DBO Horse.\nSupported voice mods: Unit Voice-overs, SSD Death Screams, Project SFX.\n"],
    ["KtweaK - Disable voice mods for non-humans", ""],
    [true],
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
    ["KtweaK - AI Stop for Healing", ""],
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
    ["Auto enable NVG illuminator", "Automatically enable the NVG and/or weapon illuminator for all AI units, in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["KtweaK - BettIR Auto Enable for AI", ""],
    [[0,1,2], ["Never", "Always", "When too dark or in building"], 2],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_BIR_wpn_illum_opt_enabled", 
    "LIST",
    ["Auto enable weapon illuminator", "Automatically enable the weapon illuminator, in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["KtweaK - BettIR Auto Enable for AI", ""],
    [[0,1,2,3], ["Never", "Always", "When too dark or in building", "When too dark or in building and in combat"], 3],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_BIR_stealth_opt_enabled", 
    "LIST",
    ["Disable illuminators in stealth mode", "Toggle the use of illuminators by the AI when in stealth mode, in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["KtweaK - BettIR Auto Enable for AI", ""],
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
    ["Enable", "If enabled, infantry AI will briefly enable their IR laser when firing, emulating Passive Aiming to some degree.\n"],
    ["KtweaK - AI Auto IR Laser", ""],
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
    ["KtweaK - Health HUD", ""],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_showInjured", 
    "CHECKBOX",
    ["Display when health changes", "If enabled, the health HUD will be briefly displayed whenever the health of any body part changes.\n"],
    ["KtweaK - Health HUD", ""],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_showInv", 
    "CHECKBOX",
    ["Display when inventory is opened", "If enabled, the health HUD will be displayed as long as the player has the inventory opened.\n"],
    ["KtweaK - Health HUD", ""],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_alpha", 
    "SLIDER",
    ["Default HUD transparency", "Default transparency. If bigger than 0, the HUD will always be visible.\n"],
    ["KtweaK - Health HUD", ""],
    [0, 1, 0, 2], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;


[
    "KTWK_HUD_health_opt_xPos", 
    "SLIDER",
    ["Horizontal Position", "How close to the left of the screen you want the HUD to be, relative to the default position in the bottom right corner.\n"],
    ["KtweaK - Health HUD", ""],
    [0, 117, 0, 2], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;


[
    "KTWK_HUD_health_opt_yPos", 
    "SLIDER",
    ["Vertical Position", "How close to the top of the screen you want the HUD to be, relative to the default position in the bottom right corner.\n"],
    ["KtweaK - Health HUD", ""],
    [0, 60.5, 0, 2], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;


[
    "KTWK_HUD_health_opt_ColorHealthy", 
    "COLOR",
    ["Healthy color", "Color for healthy body parts.\n"],
    ["KtweaK - Health HUD", ""],
    [0.5,0.5,0.5],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorLightWound", 
    "COLOR",
    ["Light Wound color", "Color for lightly wounded body parts.\n"],
    ["KtweaK - Health HUD", ""],
    [1,1,0],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorModerateWound", 
    "COLOR",
    ["Moderate Wound color", "Color for moderately wounded body parts.\n"],
    ["KtweaK - Health HUD", ""],
    [1,0.5,0],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorSevereWound", 
    "COLOR",
    ["Severe Wound color", "Color for severely wounded body parts.\n"],
    ["KtweaK - Health HUD", ""],
    [0.6,0,0],
    nil,
    {} 
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// GR DRONE
// -----------------------------------------------------------------------------------------------
[
    "KTWK_GRdrone_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, an action will be added to the player unit that will allow to automatically launch and control an AR-2 drone for a brief time.\n"],
    ["KtweaK - GR Drone", ""],
    [false],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_maxTime", 
    "SLIDER",
    ["Max Time", "Maximum allowed time to fly the drone, in seconds.\n"],
    ["KtweaK - GR Drone", ""],
    [10, 3600, 120, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_maxDist", 
    "SLIDER",
    ["Max Distance", "Maximum allowed horizontal distance from the player to the drone, in meters.\n"],
    ["KtweaK - GR Drone", ""],
    [10, 9999, 200, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_reuseTime", 
    "SLIDER",
    ["Re-use Time", "Seconds to wait until the drone can be deployed again.\n"],
    ["KtweaK - GR Drone", ""],
    [0, 3600, 60, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

// -----------------------------------------------------------------------------------------------
// ACE Map Flashlights
// -----------------------------------------------------------------------------------------------
[
    "KTWK_ACEfl_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, ACE map flashlights will be added to all infantry units which don't have one already. No flashlight will be added if there's no room in the unit's inventory.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Auto-add ACE Map Flashlights", ""],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_BLUFOR", 
    "LIST",
    ["Flashlight for BLUFOR", "Map flashlight to be added to BLUFOR units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Auto-add ACE Map Flashlights", ""],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 2],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_OPFOR", 
    "LIST",
    ["Flashlight for OPFOR", "Map flashlight to be added to OPFOR units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Auto-add ACE Map Flashlights", ""],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 3],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_INDEP", 
    "LIST",
    ["Flashlight for INDEP", "Map flashlight to be added to INDEP units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Auto-add ACE Map Flashlights", ""],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_CIV", 
    "LIST",
    ["Flashlight for CIV", "Map flashlight to be added to CIV units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Auto-add ACE Map Flashlights", ""],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 4],
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
    ["KtweaK - Humidity Effects", ""],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;
[
    "KTWK_HFX_opt_intensity", 
    "LIST",
    ["Effect Intensity", "Strength of the blur effect and the dampening of sounds.\n"],
    ["KtweaK - Humidity Effects", ""],
    [[3, 2, 1], ["Low", "Moderate", "Strong"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;
[
    "KTWK_HFX_opt_activeEffects", 
    "LIST",
    ["Active Effects", "Choose which effects should be applied.\n"],
    ["KtweaK - Humidity Effects", ""],
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
    ["KtweaK - Fatal Wounds", ""],
    [true],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_instantDeath_head", 
    "SLIDER",
    ["Chance of instant death - Head", "Chance that no death animation will be played if the head was hit, in percent.\n"],
    ["KtweaK - Fatal Wounds", ""],
    [0, 100, 75, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_instantDeath_chest", 
    "SLIDER",
    ["Chance of instant death - Chest", "Chance that no death animation will be played if the chest was hit, in percent.\n"],
    ["KtweaK - Fatal Wounds", ""],
    [0, 100, 50, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_mode", 
    "LIST",
    ["Animation mode", "Delete original corpse: The dead unit is deleted and a clone is created, which will be the one playing the fatally wounded animation.\n\nKeep original corpse: The dead unit is hidden and a clone is created, which will play the fatally wounded animation.\n Once the animation is done,the clone will be deleted and the original dead unit will be repositioned on the last position of the clone.\n Use this option for better compatibility with some missions and mods.\n"],
    ["KtweaK - Fatal Wounds", ""],
    [["delete", "keep"], ["Delete original corpse", "Keep original corpse"], 1],
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_maxRange", 
    "SLIDER",
    ["Animation range", "Max distance from the player at which units will play fatally wounded animations, in meters."],
    ["KtweaK - Fatal Wounds", ""],
    [0, 5000, 500, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_deleteTimer", 
    "SLIDER",
    ["Time until corpse deletion", "Time until the cloned corpse is 'buried' (hideBody), in seconds. Set to 0 to not delete.\nIt only applies if 'Delete original corpse' is selected and will only delete the clone, so it won't hide the original corpse if it was instant death and no clone was created.\n"],
    ["KtweaK - Fatal Wounds", ""],
    [0, 3600, 0, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    nil,
    {} 
] call CBA_fnc_addSetting;


