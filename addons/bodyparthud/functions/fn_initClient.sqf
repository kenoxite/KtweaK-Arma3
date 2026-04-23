// KTWK_BPH_fnc_initClient
// Bodypart HUD - Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

call KTWK_BPH_fnc_initGlobals;
call KTWK_BPH_fnc_disableSystem;
call KTWK_BPH_fnc_initSystem;

// Let Ktweak deal with the recurring checks if present
if (KTWK_BPH_ktweak) exitWith {};

// Keep player reference updated
[{
    if (!isNull (findDisplay 49)) exitWith {};
    KTWK_player = call CBA_fnc_currentUnit;
}, 1] call CBA_fnc_addPerFrameHandler;
