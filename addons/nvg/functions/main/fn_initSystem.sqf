// KTWK_NVG_fnc_initSystem
// Initializes NVG effects and state tracking
//
// Parameters:
//   None
// Returns:
//   Nothing

private _unit = KTWK_player;
KTWK_NVG_lastWeapon = currentWeapon _unit;
KTWK_NVG_lastWeaponZoom = getNumber (configFile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");

private _veh = vehicle _unit;
private _inVehicle = _veh != _unit;
KTWK_lastVehicle = _veh;
KTWK_lastVehicleMFD = (count ([configOf _veh >> "MFD", 0] call BIS_fnc_returnChildren)) > 0;

// Initialize effects
KTWK_NVG_ppChrom = ppEffectCreate ["ChromAberration", 217];
KTWK_NVG_ppBlur = ppEffectCreate ["dynamicBlur", 773];  // IMPORTANT: range 400-999 - going over 999 will cause darkening when zooming bug
KTWK_NVG_ppColor = ppEffectCreate ["ColorCorrections", 1974];
KTWK_NVG_ppFilm = ppEffectCreate ["FilmGrain", 2174];

// Error check
if (KTWK_NVG_ppBlur < 0 || {KTWK_NVG_ppColor < 0} || {KTWK_NVG_ppFilm < 0} || {KTWK_NVG_ppChrom < 0}) exitWith {
    diag_log "KTWK NVG Effects: PPEffects Error: Failed to create effects";
};

// Configure effects
KTWK_NVG_ppColor ppEffectAdjust [0.6, 1.4, -0.02, [1, 1, 1, 0], [1, 1, 1, 1], [0, 0, 0, 0]];
{ _x ppEffectForceInNVG true; _x ppEffectEnable false } forEach [KTWK_NVG_ppBlur, KTWK_NVG_ppColor, KTWK_NVG_ppFilm, KTWK_NVG_ppChrom];
