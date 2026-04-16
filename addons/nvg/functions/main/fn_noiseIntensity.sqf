// KTWK_NVG_fnc_noiseIntensity
// Returns noise value based on settings and ambient lighting
//
// Parameters:
//   _brightness - Current ambient brightness value
//   _mode - Current NVG mode
// Returns:
//   Number - Noise value

params ["_brightness", "_mode"];

private _autoGenTypes = ["standard"];

private _baseNoise = if (KTWK_NVG_opt_autoGen && {_mode in _autoGenTypes}) then {
    KTWK_NVG_cachedDetection # 3
} else {
    KTWK_NVG_opt_noise
};

if (_baseNoise == 0) exitWith { 0 };

linearConversion [35, 150, _brightness, _baseNoise, 0, true];
