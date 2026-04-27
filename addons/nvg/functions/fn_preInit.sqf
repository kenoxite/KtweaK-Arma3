// KTWK_NVG preInit
// NVG Effects - Server initialization

if (!isServer || !hasInterface) exitWith {};

KTWK_player = [] call KTWK_NVG_fnc_getPlayer;
KTWK_lastPlayer = KTWK_player;
