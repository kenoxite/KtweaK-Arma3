// KTWK_NVG_fnc_initSystem
// Initializes NVG effects and state tracking
//
// Parameters:
//   None
// Returns:
//   Nothing

KTWK_NVG_lastWeapon = currentWeapon KTWK_player;
KTWK_NVG_lastWeaponZoom = getNumber (configFile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");

private _veh = vehicle KTWK_player;
private _inVehicle = _veh != KTWK_player;
KTWK_lastVehicle = _veh;
KTWK_lastVehicleMFD = (count ([configOf _veh >> "MFD", 0] call BIS_fnc_returnChildren)) > 0;

// Initialize effects
KTWK_NVG_ppBlur = ppEffectCreate ["dynamicBlur", 500];
KTWK_NVG_ppColor = ppEffectCreate ["ColorCorrections", 1500];
KTWK_NVG_ppFilm = ppEffectCreate ["FilmGrain", 2501];

// Error check
if (KTWK_NVG_ppBlur < 0 || {KTWK_NVG_ppColor < 0} || {KTWK_NVG_ppFilm < 0}) exitWith {
    systemChat "KTWK NVG Effects: PPEffects Error: Failed to create effects";
};

// Configure effects
KTWK_NVG_ppColor ppEffectAdjust [0.6, 1.4, -0.02, [1, 1, 1, 0], [1, 1, 1, 1], [0, 0, 0, 0]];
{ _x ppEffectForceInNVG true; _x ppEffectEnable false } forEach [KTWK_NVG_ppBlur, KTWK_NVG_ppColor, KTWK_NVG_ppFilm];
