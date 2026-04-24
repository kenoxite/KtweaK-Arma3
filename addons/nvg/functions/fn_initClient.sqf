// KTWK_NVG_fnc_initClient
// NVG Effects - Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

// Init NVG subsystem
call KTWK_NVG_fnc_initGlobals;
call KTWK_NVG_fnc_updateGenArrays;
call KTWK_NVG_fnc_updateColorArrays;
call KTWK_NVG_fnc_disableSystem;
call KTWK_NVG_fnc_initSystem;

// Let Ktweak deal with the recurring checks if present
if (KTWK_NVG_ktweak) exitWith {};

// Keep player reference updated
[{
    if (!isNull (findDisplay 49)) exitWith {};
    KTWK_player = call KTWK_NVG_fnc_getPlayer;
}, 1] call CBA_fnc_addPerFrameHandler;
