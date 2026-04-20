// KTWK_NVG preInit
// NVG Effects - Server initialization

if (!isServer || !hasInterface) exitWith {};

KTWK_player = call CBA_fnc_currentUnit;
