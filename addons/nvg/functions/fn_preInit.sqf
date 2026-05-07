// KTWK_NVG preInit
// NVG Effects - Server initialization

if (!isServer || !hasInterface) exitWith {};

KTWK_player = [] call KTWK_NVG_fnc_getPlayer;
KTWK_lastPlayer = KTWK_player;

// Set POLPOX's Star Sphere default visibility to user settings
PLP_SSP_brightness = KTWK_NVG_opt_starSphere;
