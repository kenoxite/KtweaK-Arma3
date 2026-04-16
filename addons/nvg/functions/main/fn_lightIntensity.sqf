// KTWK_NVG_fnc_lightIntensity
// Calculates brightness factor based on ambient lighting
//
// Parameters:
//   _brightness - Current ambient brightness value
// Returns:
//   Number - Brightness factor

params ["_brightness", "_mode"];

private _autoGenTypes = ["standard"];

private _intensity = if (KTWK_NVG_opt_autoGen && {_mode in _autoGenTypes}) then {
    KTWK_NVG_cachedDetection # 2
} else {
    KTWK_NVG_opt_brightness
};

if (_intensity == 0) exitWith { 1 };

linearConversion [35, 150, _brightness, _intensity, 0.8, true];
