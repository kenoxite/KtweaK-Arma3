// KTWK_DFB_fnc_initClient
// Bodypart HUD - Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

call KTWK_DFB_fnc_initGlobals;
call KTWK_DFB_fnc_disableSystem;
call KTWK_DFB_fnc_initSystem;
