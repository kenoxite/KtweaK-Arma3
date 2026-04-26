#include "\z\ktweak\addons\firemodes\version.hpp"

#define OVERRIDES "Default keybind overrides - Unbind first!"
#define OVERRIDE_WARNING "\nUnbind the vanilla keybind for this action for this to work properly!"
#define GL "Grenade Launcher keybinds"

[
    "ktweak_firemodes",
    VERSION_STR,
    { /* mismatch handler */ }
] call CBA_fnc_registerVersion;

// -----------------------------------------------------------------------------------------------
// * CBA *
// -----------------------------------------------------------------------------------------------
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

#include "\a3\ui_f\hpp\definedikcodes.inc"

// Switch to Primary Weapon
[
    ["KtweaK - Clean Firemodes", OVERRIDES],
    "KTWK_key_switchToPrimary",
    ["Switch to Primary Weapon [Override]", format ["Switches to primary weapon or cycles forward through firemodes if already holding it.\n%1", OVERRIDE_WARNING]],
    {},
    { 
        [KTWK_player, 1] call KTWK_CFM_fnc_nextWeapon; 
    },
    [ -1, [false, false, false] ], // [DIK, [shift, ctrl, alt]
    false
] call CBA_fnc_addKeybind;

// Cycle firemode (forward)
[
    ["KtweaK - Clean Firemodes", OVERRIDES],
    "KTWK_key_cycleFiremode",
    ["Cycle Firemode [Next Weapon override]", format ["Cycles through valid firemodes (Single, FullAuto, Burst) without switching weapons or GL.\n%1", OVERRIDE_WARNING]],
    {},
    { 
        [KTWK_player, 1] call KTWK_CFM_fnc_cycleFiremode; 
    },
    [ -1, [false, false, false] ], // [DIK, [shift, ctrl, alt]
    false
] call CBA_fnc_addKeybind;

// Cycle firemode (backward) - optional
[
    ["KtweaK - Clean Firemodes", OVERRIDES],
    "KTWK_key_cycleFiremodeBack",
    ["Cycle Firemode (Backward) [Previous Weapon override]", format ["Cycles backward through valid firemodes.\n%1", OVERRIDE_WARNING]],
    {},
    { 
        [KTWK_player, -1] call KTWK_CFM_fnc_cycleFiremode; 
    },
    [ -1, [true, false, false] ], // [DIK, [shift, ctrl, alt]
    false
] call CBA_fnc_addKeybind;

// --------------------------
// Switch to Grenade Launcher
[
    ["KtweaK - Clean Firemodes", GL],
    "KTWK_key_switchToGL",
    ["Switch to Grenade Launcher", "Switches to the underbarrel grenade launcher if available.\nInstant switch version. Better use a separate key from the other ones.\nCycles to next normal firemode if already in GL mode.\n"],
    {},
    { 
        [KTWK_player, true] call KTWK_CFM_fnc_switchToGL; 
    },
    [ -1, [false, false, false] ], // [DIK, [shift, ctrl, alt]
    false
] call CBA_fnc_addKeybind;

[
    ["KtweaK - Clean Firemodes", GL],
    "KTWK_key_switchToGLHold",
    ["Switch to Grenade Launcher [Hold Key]", "Switches to the underbarrel grenade launcher if available.\nHold the key for this version of the keybind.\nUseful if you want to use the same keybind as Cycle Firemode and Switch to Primary.\n"],
    { 
        [KTWK_player] call KTWK_CFM_fnc_switchToGL; 
    },
    {
        0 spawn {
            sleep 0.1;
            missionNamespace setVariable ["KTWK_CFM_selectingGL", false];
            [KTWK_player, 0] call KTWK_CFM_fnc_cycleFiremode; 
        };
    },
    [ -1, [false, false, false] ], // [DIK, [shift, ctrl, alt]
    true,
    0.05
] call CBA_fnc_addKeybind;
