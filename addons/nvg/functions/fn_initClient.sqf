// KTWK_NVG_fnc_initClient
// NVG Effects - Client initialization and event handlers

if (!hasInterface) exitWith {};

#include "\z\ktweak\addons\nvg\cacheIndices.hpp"

waitUntil {!isNull player};

// Init NVG subsystem
call KTWK_NVG_fnc_initGlobals;
call KTWK_NVG_fnc_updateGenArrays;
call KTWK_NVG_fnc_updateColorArrays;
call KTWK_NVG_fnc_disableSystem;
call KTWK_NVG_fnc_initSystem;
