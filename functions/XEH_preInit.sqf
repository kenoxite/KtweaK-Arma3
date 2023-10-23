// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// * CBA *
// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// KEYBINDS
// -----------------------------------------------------------------------------------------------
#include "\a3\ui_f\hpp\definedikcodes.inc";

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
    ["KtweaK", ""],
    "KTWK_key_primaryEquipNext",
    ["Equip Next Primary", "Changes the currently equipped primary weapon to other primary weapons in the player's inventory"],
    { [KTWK_player, 1] call KTWK_fnc_equipNextWeapon },
    {},
    [ DIK_1, [false, true, false] ], // [DIK, [shift, ctrl, alt]
    false
] call CBA_fnc_addKeybind;

[
    ["KtweaK", ""],
    "KTWK_key_handgunEquipNext",
    ["Equip Next Handgun", "Changes the currently equipped handgun to other handguns in the player's inventory"],
    { [KTWK_player, 2] call KTWK_fnc_equipNextWeapon },
    {},
    [ DIK_2, [false, true, false] ], // [DIK, [shift, ctrl, alt]
    false
] call CBA_fnc_addKeybind;

[
    ["KtweaK", ""],
    "KTWK_key_secondaryEquipNext",
    ["Equip Next Secondary", "Changes the currently equipped secondary weapon to other secondary weapons in the player's inventory"],
    { [KTWK_player, 3] call KTWK_fnc_equipNextWeapon },
    {},
    [ DIK_3, [false, true, false] ], // [DIK, [shift, ctrl, alt]
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
//  SERVER
// -----------------------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------
// MISC
// -----------------------------------------------------------------------------------------------
[
    "KTWK_opt_debug", 
    "CHECKBOX",
    ["Debug", "Debug Mode"],
    ["KtweaK - Server", ""],
    [false],
    1,
    {} 
] call CBA_fnc_addSetting;

// RAIN PONCHO SWAP
[
    "KTWK_ponchoSwap_opt_enabled", 
    "CHECKBOX",
    ["Rain Poncho Reacts to Water", "If enabled, equipped rain ponchos by any unit will change to the wet or dry version whenever the poncho gets wet or dry.\nOnly compatible with MGSR ponchos.\n"],
    ["KtweaK - Server", ""],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

// STOP FOR HEALING
[
    "KTWK_SFH_opt_enabled", 
    "CHECKBOX",
    ["AI Stop for Healing", "If enabled, AI infantry will stop moving when being healed, even when the group leader hasn't issued a heal order (which is the only way they stop for heals by default).\n"],
    ["KtweaK - Server", ""],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

// AI AUTO LASER
[
    "KTWK_laser_opt_enabled", 
    "CHECKBOX",
    ["AI Auto IR Laser", "If enabled, infantry AI will briefly enable their IR laser when firing, emulating Passive Aiming to some degree.\n"],
    ["KtweaK - Server", ""],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

// AI PREDATOR DEFENSE
[
    "KTWK_opt_AIPredDefense_enable", 
    "CHECKBOX",
    ["Enable", "AI units will attack dangerous predators when they get too close. So far it only works with Edaly's crocodile.\n"],
    ["KtweaK - Server", "AI Predator Defense"],
    [false],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_opt_AIPredDefense_dist", 
    "SLIDER",
    ["Aggression Distance", "Distance below which a predator will be considered as dangerous by the AI.\n"],
    ["KtweaK - Server", "AI Predator Defense"],
    [1, 500, 50, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    {} 
] call CBA_fnc_addSetting;


// DISABLE VOICES - CREATURES
[
    "KTWK_disableVoices_opt_creatures", 
    "CHECKBOX",
    ["Disable Voice Mods for Creatures", "If enabled, voice mods will be disabled for non humanoid AI units, such as zombies or horses.\nSupported creatures: Ravage, Webknight's Zombies, Drongo's Spooks, Zombies and Demons, Max Zombies, DBO Horse and all Edaly creatures (dog, tiger, cattle, crab, crocodile, boar, horse).\nSupported voice mods: Unit Voice-overs, Stalker Voices, SSD Death Screams, Project SFX.\n"],
    ["KtweaK - Server", "Disable Voices"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

// BETTIR AUTOENABLE
[
    "KTWK_BIR_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, AI will automatically toggle the activation of their illuminators basec on the chosen conditions.\n"],
    ["KtweaK - Server", "BettIR Auto Enable for AI"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;
[
    "KTWK_BIR_NVG_illum_opt_enabled", 
    "LIST",
    ["Auto enable NVG illuminator", "Automatically enable the NVG illuminator for all AI units in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["KtweaK - Server", "BettIR Auto Enable for AI"],
    [[0,1,2], ["Never", "Always", "When too dark or in building"], 2],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_BIR_wpn_illum_opt_enabled", 
    "LIST",
    ["Auto enable weapon illuminator", "Automatically enable the weapon illuminator in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["KtweaK - Server", "BettIR Auto Enable for AI"],
    [[0,1,2,3], ["Never", "Always", "When too dark or in building", "When too dark or in building and in combat"], 3],
    1,
    {}
] call CBA_fnc_addSetting;

[
    "KTWK_BIR_stealth_opt_enabled", 
    "LIST",
    ["Disable illuminators in stealth mode", "Toggle the use of illuminators by the AI when in stealth mode, in the specified conditions. It has no effect if BettIR isn't installed.\n"],
    ["KtweaK - Server", "BettIR Auto Enable for AI"],
    [[0,1,2,3], ["Always", "Never", "Disable NVG illuminators", "Disable weapon illuminators"], 2],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_BIR_opt_dist", 
    "SLIDER",
    ["Maximum Distance", "AI units will only toggle illuminators if below this distance from any player. Units in a player's group are exented from this restriction.\n"],
    ["KtweaK - Server", "BettIR Auto Enable for AI"],
    [1, 500, 50, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    {} 
] call CBA_fnc_addSetting;



// ACE MAP FLASHLIGHTS
[
    "KTWK_ACEfl_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, ACE map flashlights will be added to all infantry units which don't have one already. No flashlight will be added if there's no room in the unit's inventory.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Server", "Auto-add ACE Map Flashlights"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_BLUFOR", 
    "LIST",
    ["Flashlight for BLUFOR", "Map flashlight to be added to BLUFOR units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Server", "Auto-add ACE Map Flashlights"],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 2],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_OPFOR", 
    "LIST",
    ["Flashlight for OPFOR", "Map flashlight to be added to OPFOR units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Server", "Auto-add ACE Map Flashlights"],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 3],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_INDEP", 
    "LIST",
    ["Flashlight for INDEP", "Map flashlight to be added to INDEP units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Server", "Auto-add ACE Map Flashlights"],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 1],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ACEfl_opt_CIV", 
    "LIST",
    ["Flashlight for CIV", "Map flashlight to be added to CIV units.\nThis option has no effect if ACE flashlights addon isn't active.\n"],
    ["KtweaK - Server", "Auto-add ACE Map Flashlights"],
    [[0,1,2,3,4], ["None", "Fulton MX-991", "Maglite XL50", "KSF-1", "Random"], 4],
    1,
    {} 
] call CBA_fnc_addSetting;

// FATAL WOUNDS
[
    "KTWK_FW_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, dead units will play a fatally wounded animation.\nThe animation played is random, but based on the location of the body part that killed the unit.\nUnits have a chance of being instantly dead (no fatally wounded animation will be played) if the head or chest is severely wounded.\nIn both cases, the unit is actually killed and, if not instantly dead, a clone (an agent) will be spawned to play the fatally wounded animation.\n\nFatally wounded units will scream in pain if using mods like 'SSD Death Screams' or 'Project Human'.\n"],
    ["KtweaK - Server", "Fatal Wounds"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_instantDeath_head", 
    "SLIDER",
    ["Chance of instant death - Head", "Chance that no death animation will be played if the head was hit, in percent.\n"],
    ["KtweaK - Server", "Fatal Wounds"],
    [0, 100, 75, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_instantDeath_chest", 
    "SLIDER",
    ["Chance of instant death - Chest", "Chance that no death animation will be played if the chest was hit, in percent.\n"],
    ["KtweaK - Server", "Fatal Wounds"],
    [0, 100, 50, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_mode", 
    "LIST",
    ["Animation mode", "Delete original corpse: The dead unit is deleted and a clone is created, which will be the one playing the fatally wounded animation.\n\nKeep original corpse: The dead unit is hidden and a clone is created, which will play the fatally wounded animation.\n Once the animation is done,the clone will be deleted and the original dead unit will be repositioned on the last position of the clone.\n Use this option for better compatibility with some missions and mods.\n"],
    ["KtweaK - Server", "Fatal Wounds"],
    [["delete", "keep"], ["Delete original corpse", "Keep original corpse"], 1],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_maxRange", 
    "SLIDER",
    ["Animation range", "Max distance from the player at which units will play fatally wounded animations, in meters."],
    ["KtweaK - Server", "Fatal Wounds"],
    [0, 5000, 100, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_FW_opt_deleteTimer", 
    "SLIDER",
    ["Time until corpse deletion", "Time until the cloned corpse is 'buried' (hideBody), in seconds. Set to 0 to not delete.\nIt only applies if 'Delete original corpse' is selected and will only delete the clone, so it won't hide the original corpse if it was instant death and no clone was created.\n"],
    ["KtweaK - Server", "Fatal Wounds"],
    [0, 3600, 0, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    {} 
] call CBA_fnc_addSetting;


// RECON DRONE
[
    "KTWK_GRdrone_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, an action will be added to the player unit that will allow to automatically launch and control an AR-2 drone for a brief time.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_maxTime", 
    "SLIDER",
    ["Max Time", "Maximum allowed time to fly the drone, in seconds.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [10, 3600, 120, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_maxDist", 
    "SLIDER",
    ["Max Distance", "Maximum allowed horizontal distance from the player to the drone, in meters.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [10, 9999, 200, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_reuseTime", 
    "SLIDER",
    ["Re-use Time", "Seconds to wait until the drone can be deployed again.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [0, 3600, 60, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_itemRequired", 
    "CHECKBOX",
    ["Require Dispenser in Inventory", "If enabled, the 'Recon Drone Dispenser' item must be in the player controlled unit's inventory in order to launch the drone.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_enableLaser", 
    "CHECKBOX",
    ["Enable Laser", "If enabled, the default laser will be available in the recon drone.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [false],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_enableRadar", 
    "CHECKBOX",
    ["Enable Radar", "If enabled, the default radar display to the left or right will be available in the recon drone.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [false],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_enableNV", 
    "CHECKBOX",
    ["Enable Night Vision", "If enabled, night vision mode will be enabled for the recon drone.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_enableTI", 
    "CHECKBOX",
    ["Enable Thermal Vision", "If enabled, thermal vision mode will be enabled for the recon drone.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_GRdrone_opt_invisibleHeight", 
    "SLIDER",
    ["Enemy Attack Altitude Limit", "AI won't attack if the altitude of the drone is the specified one or above.\nSet to -1 for enemies to always attack, regardless of altitude.\n"],
    ["KtweaK - Server", "Recon Drone"],
    [-1, 999, -1, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
    1,
    {}
] call CBA_fnc_addSetting;


// MAP ICONS ONLY WITH GPS
[
    "KTWK_opt_GPSHideIcons_enable", 
    "CHECKBOX",
    ["Enable", "Hide all map icons (not markers) unless the player unit has a GPS or is in a vehicle with one.\n"],
    ["KtweaK - Server", "Map Icons only with GPS"],
    [false],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_opt_GPSHideIcons_enemies", 
    "CHECKBOX",
    ["Enable Enemy Icons", "Display enemy icons when having a GPS.\n"],
    ["KtweaK - Server", "Map Icons only with GPS"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_opt_GPSHideIcons_mines", 
    "CHECKBOX",
    ["Enable Mine Icons", "Display mine icons when having a GPS.\n"],
    ["KtweaK - Server", "Map Icons only with GPS"],
    [true],
    1,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_opt_GPSHideIcons_autoCenter", 
    "CHECKBOX",
    ["Allow Map Auto-centering", "If disabled, the map won't center on the player anymore and the button to center map on player is disabled."],
    ["KtweaK - Server", "Map Icons only with GPS"],
    [true],
    1,
    {},
    true
] call CBA_fnc_addSetting;

[
    "KTWK_opt_GPSHideIcons_customWP", 
    "CHECKBOX",
    ["Allow Custom Waypoint Creation", "If disabled, the player won't be able to create their own waypoints with Shift+Left Click.\nWARNING: Disabling this WILL break some mods and missions!.\nIt requires to restart the mission for changes to take effect."],
    ["KtweaK - Server", "Map Icons only with GPS"],
    [true],
    1,
    {},
    true
] call CBA_fnc_addSetting;

// SLIDE IN SLOPES
[
    "KTWK_slideInSlopes_opt_enabled", 
    "CHECKBOX",
    ["Slide in Slopes", "If enabled, player infantry units have a chance of slipping when going up and down slopes.\n"],
    ["KtweaK - Server", ""],
    [false],
    1,
    {} 
] call CBA_fnc_addSetting;

// BRIGHTER FULL MOON NIGHTS
[
    "KTWK_BN_opt_enabled", 
    "LIST",
    ["Brighter Full Moon Nights", "If enabled, lighting in full moon nights will be brigther.\n"],
    ["KtweaK - Server", ""],
    [[0,1,2], ["Disable", "Bright", "Brighter"], 1],
    1,
    {} 
] call CBA_fnc_addSetting;


// -----------------------------------------------------------------------------------------------
//  CLIENT
// -----------------------------------------------------------------------------------------------

// EQUIP NEXT WEAPON
[
    "KTWK_ENW_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, it swaps the currently equipped primary/secondary/handgun weapon with other similar weapons in the player's inventory.\nDefault keys are Ctrl+1, Ctrl+2 and Ctrl+3.\n"],
    ["KtweaK - Client", "Equip Next Weapon"],
    [true],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ENW_opt_displayRifle", 
    "CHECKBOX",
    ["Display Next Rifle", "If enabled, the rifle it will be swapped to will be displayed in the unit's body.\n"],
    ["KtweaK - Client", "Equip Next Weapon"],
    [true],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ENW_opt_riflePos",
    "LIST",
    ["Next Rifle Display Position", "Choose the position where the rifle will be displayed.\n"],
    ["KtweaK - Client", "Equip Next Weapon"],
    [[0,1,2,3,4], ["Back right", "Back left", "Front downwards", "Front horizontal", "Front upwards"], 0],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ENW_opt_displayLauncher", 
    "CHECKBOX",
    ["Display Next Launcher", "If enabled, the launcher it will be swapped to will be displayed in the unit's body.\n"],
    ["KtweaK - Client", "Equip Next Weapon"],
    [true],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_ENW_opt_launcherPos",
    "LIST",
    ["Next Launcher Display Position", "Choose the position where the launcher will be displayed.\n"],
    ["KtweaK - Client", "Equip Next Weapon"],
    [[0,1,2], ["Waist back", "Back left", "Back right"], 1],
    0,
    {} 
] call CBA_fnc_addSetting;

// DISABLE SOG VOICES
[
    "KTWK_toggleVoices_opt_SOG_US",
    "LIST",
    ["Ambient Voices for US units", "The default ambient voices for American troops in S.O.G. Prairie Fire will be enabled or disabled according to this setting. This option has no effect if that CDLC isn't active.\n"],
    ["KtweaK - Client", "Toggle S.O.G. Prairie Fire Voices"],
    [[0,1,2], ["Enable all", "Disable all but death screams", "Disable all"], 0],
    0,
    { if (time > 0.1) then { call KTWK_fnc_toggleSOGvoices; } } 
] call CBA_fnc_addSetting;

[
    "KTWK_toggleVoices_opt_SOG_AU",
    "LIST",
    ["Ambient Voices for AU units", "The default ambient voices for Australian troops in S.O.G. Prairie Fire will be enabled or disabled according to this setting. This option has no effect if that CDLC isn't active.\n"],
    ["KtweaK - Client", "Toggle S.O.G. Prairie Fire Voices"],
    [[0,1,2], ["Enable all", "Disable all but death screams", "Disable all"], 0],
    0,
    { if (time > 0.1) then { call KTWK_fnc_toggleSOGvoices; } } 
] call CBA_fnc_addSetting;

[
    "KTWK_toggleVoices_opt_SOG_NZ",
    "LIST",
    ["Ambient Voices for NZ units", "The default ambient voices for New Zealander troops in S.O.G. Prairie Fire will be enabled or disabled according to this setting. This option has no effect if that CDLC isn't active.\n"],
    ["KtweaK - Client", "Toggle S.O.G. Prairie Fire Voices"],
    [[0,1,2], ["Enable all", "Disable all but death screams", "Disable all"], 0],
    0,
    { if (time > 0.1) then { call KTWK_fnc_toggleSOGvoices; } } 
] call CBA_fnc_addSetting;


// HEALTH HUD
[
    "KTWK_HUD_health_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, a HUD displaying the damage suffered by the player will briefly appear in the bottom right corner.\nIt will be displayed whenever the health status changes. The current overall health status will be displayed when the inventory is opened.\n"],
    ["KtweaK - Client", "Health HUD"],
    [true],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_showInjured", 
    "CHECKBOX",
    ["Display when health changes", "If enabled, the health HUD will be briefly displayed whenever the health of any body part changes.\n"],
    ["KtweaK - Client", "Health HUD"],
    [true],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_showInv", 
    "CHECKBOX",
    ["Display when inventory is opened", "If enabled, the current overall health status will be displayed when the inventory is opened.\n"],
    ["KtweaK - Client", "Health HUD"],
    [true],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_alpha", 
    "SLIDER",
    ["Default HUD transparency", "Default transparency. If bigger than 0, the HUD will always be visible.\n"],
    ["KtweaK - Client", "Health HUD"],
    [0, 1, 0, 2], // data for this setting: [min, max, default, number of shown trailing decimals]
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_xPos", 
    "SLIDER",
    ["Horizontal Position", "How close to the left of the screen you want the HUD to be, relative to the default position in the bottom right corner.\n"],
    ["KtweaK - Client", "Health HUD"],
    [0, 117, 0, 2], // data for this setting: [min, max, default, number of shown trailing decimals]
    0,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_yPos", 
    "SLIDER",
    ["Vertical Position", "How close to the top of the screen you want the HUD to be, relative to the default position in the bottom right corner.\n"],
    ["KtweaK - Client", "Health HUD"],
    [0, 60.5, 0, 2], // data for this setting: [min, max, default, number of shown trailing decimals]
    0,
    { call KTWK_fnc_HUD_health_moveDialog; }
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorHealthy", 
    "COLOR",
    ["Healthy color", "Color for healthy body parts.\n"],
    ["KtweaK - Client", "Health HUD"],
    [0.5,0.5,0.5],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorLightWound", 
    "COLOR",
    ["Light Wound color", "Color for lightly wounded body parts.\n"],
    ["KtweaK - Client", "Health HUD"],
    [1,1,0],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorModerateWound", 
    "COLOR",
    ["Moderate Wound color", "Color for moderately wounded body parts.\n"],
    ["KtweaK - Client", "Health HUD"],
    [1,0.5,0],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HUD_health_opt_ColorSevereWound", 
    "COLOR",
    ["Severe Wound color", "Color for severely wounded body parts.\n"],
    ["KtweaK - Client", "Health HUD"],
    [0.6,0,0],
    0,
    {} 
] call CBA_fnc_addSetting;

// HUMIDITY EFFECTS
[
    "KTWK_HFX_opt_enabled", 
    "CHECKBOX",
    ["Enable", "If enabled, blurry visuals and muffled sounds will be applied depending on the current fog settings and the location of the player respective to the fog.\nThe effect is increased the deeper the player is into the fog and is lowered when inside a covered vehicle or building.\n"],
    ["KtweaK - Client", "Humidity Effects"],
    [true],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HFX_opt_intensity", 
    "LIST",
    ["Effect Intensity", "Strength of the blur effect and the dampening of sounds.\n"],
    ["KtweaK - Client", "Humidity Effects"],
    [[3, 2, 1], ["Low", "Moderate", "Strong"], 1],
    0,
    {} 
] call CBA_fnc_addSetting;

[
    "KTWK_HFX_opt_activeEffects", 
    "LIST",
    ["Active Effects", "Choose which effects should be applied.\n"],
    ["KtweaK - Client", "Humidity Effects"],
    [[0, 1, 2], ["All", "Only visual", "Only auditive"], 1],
    0,
    {} 
] call CBA_fnc_addSetting;
