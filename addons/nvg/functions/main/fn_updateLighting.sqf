// KTWK_NVG_fnc_updateLighting
// Updates cached ambient lighting values
//
// Parameters:
//   None
// Returns:
//   Nothing

private _lighting = getLightingAt KTWK_player;

if (!isNil "_lighting") then {
    _lighting params ["", "_ambientBrightness", "", "_dynamicBrightness"];
    KTWK_NVG_ambientBrightness = _ambientBrightness + _dynamicBrightness;
} else {
    KTWK_NVG_ambientBrightness = 150;
};
