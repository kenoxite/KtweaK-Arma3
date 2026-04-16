// KTWK_NVG_fnc_zoomIntensity
// Calculates intensity modifier based on zoom level and view state
//
// Parameters:
//   _mode - NVG mode string from nvgMode function
// Returns:
//   Number - Modified intensity value

params ["_mode"];

private _zoom = call KTWK_NVG_fnc_getZoom;

private _zoomIntensityMod = call {
    if (_mode == "disabled") exitWith { 1 };
    if (_mode == "rangefinder") exitWith { 28 };
    if (_mode == "vehicle") exitWith { 56 };
    if (_mode == "scoped") exitWith { 16 };
    9  // standard
};

_zoom / _zoomIntensityMod;
