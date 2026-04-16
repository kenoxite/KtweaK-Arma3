// KTWK_NVG_fnc_updateWeapon
// Updates cached weapon state when weapon changes
//
// Parameters:
//   None
// Returns:
//   Nothing

KTWK_NVG_lastWeapon = currentWeapon KTWK_player;
KTWK_NVG_lastWeaponZoom = getNumber (configFile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");
KTWK_NVG_cachedMode = "";  // Invalidate mode cache
