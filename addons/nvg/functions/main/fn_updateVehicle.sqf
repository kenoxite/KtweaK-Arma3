// KTWK_NVG_fnc_updateVehicle
// Updates cached vehicle state when vehicle changes
//
// Parameters:
//   None
// Returns:
//   Nothing

private _veh = vehicle KTWK_player;
KTWK_lastVehicle = _veh;
KTWK_lastVehicleMFD = (count ([configOf _veh >> "MFD", 0] call BIS_fnc_returnChildren)) > 0;
KTWK_NVG_cachedMode = "";  // Invalidate mode cache
