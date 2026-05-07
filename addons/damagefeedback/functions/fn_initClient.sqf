// KTWK_DFB_fnc_initClient
// Damage Feedback - Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

// diag_log "[DFB] Init client";

call KTWK_DFB_fnc_initGlobals;
call KTWK_DFB_fnc_initSystem;
