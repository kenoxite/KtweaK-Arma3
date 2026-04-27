// KTWK_BPH_fnc_initClient
// Bodypart HUD - Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

call KTWK_BPH_fnc_initGlobals;
call KTWK_BPH_fnc_disableSystem;
call KTWK_BPH_fnc_initSystem;
