// KTWK_NVG_fnc_calcEffects
// Calculates effect parameters based on current state
//
// Parameters:
//   _mode       - Current NVG mode
//   _light      - Ambient light value
//   _zoom       - Current zoom level
//   _rangeFactor - Float (0-1): how far beyond effective range (0 = in range, 1 = fully out)
// Returns:
//   Array - [_film, _blur, _color]

params ["_mode", "_light", "_zoom", "_rangeFactor"];

#include "\z\ktweak\addons\nvg\cacheIndices.hpp"

private _unit = KTWK_player;
private _nvMode = KTWK_NVG_opt_nvMode;

// Global exclusion check
if (_mode != "disabled" && {[_mode, _unit] call KTWK_NVG_fnc_isExcluded}) exitWith {
    [[0, 0, 0, 0, 0, 0], [0], [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0], [-1, -1, 0, 0, 0, 0, 0]]]
};

// Determine generation index and color preset
private _deviceGenData = [_mode, _unit] call KTWK_NVG_fnc_getDeviceGen;
_deviceGenData params ["_genIndex", "_colorPreset"];

// Get parameters based on generation or manual mode
private _int = if (_genIndex > 0) then { KTWK_NVG_genIntensity # _genIndex } else { KTWK_NVG_opt_intensity };
private _baseNoise = if (_genIndex > 0) then { KTWK_NVG_genNoise # _genIndex } else { KTWK_NVG_opt_noise };
private _maxBright = if (_genIndex > 0) then { KTWK_NVG_genBrightness # _genIndex } else { KTWK_NVG_opt_brightness };

// Override with manual settings if in manual mode
if (_nvMode == 2) then {
    _int = KTWK_NVG_opt_intensity;
    _baseNoise = KTWK_NVG_opt_noise;
    _maxBright = KTWK_NVG_opt_brightness;
    _colorPreset = KTWK_NVG_opt_color;
};

private _isHmd = KTWK_NVG_isHmd;
private _isHmdADSNoScope = KTWK_NVG_isHmdADSNoScope;
private _isHmdADS = KTWK_NVG_isHmdADS;
private _outOfRangeBlur = KTWK_NVG_opt_outOfRangeBlur;
private _opt_baseBlur = KTWK_NVG_opt_baseBlur;
private _baseBlur = call {
    if (KTWK_NVG_opt_blurADS && (_isHmdADS || {_isHmdADSNoScope})) exitWith { ([_opt_baseBlur, 0] select _isHmdADSNoScope) + _outOfRangeBlur };
    _opt_baseBlur
};
private _minBlur = if (_genIndex > 0) then {
    ((_baseBlur / 2) max 0.01) * (5 - _genIndex)
} else {
    _baseBlur
};

// Blur calculation
private _blur = call {
    private _blurMod = [1, _zoom] select (_isHmd || _isHmdADSNoScope);
    
    private _zMod = switch _mode do {   
        case "disabled": {1};
        case "rangefinder": {(KTWK_NVG_opticZoomMax / 10) max 9};
        case "vehicle": {(KTWK_NVG_vehicleOpticZoomMax / 10) max 9};
        case "scoped": {(KTWK_NVG_opticZoomMax / 10) max 9};
        default {9};
    };
    
    private _effectiveZoom = _zoom;
    if (_mode == "scoped" || _mode == "rangefinder") then {
        _effectiveZoom = _zoom / KTWK_NVG_opticZoomMin;
    };
    if (_mode == "vehicle" && {KTWK_NVG_vehicleOpticHasNV}) then {
        _effectiveZoom = _zoom / KTWK_NVG_vehicleOpticZoomMin;
    };
    
    private _zBlur = (_effectiveZoom / _zMod) * (_int * 2);
    private _zoomBlur = [_baseBlur + _zBlur, 0.1] select (_zBlur == 1);
    
    private _oorBlur = _opt_baseBlur * _outOfRangeBlur * _rangeFactor * _blurMod;
    
    private _totalBlur = (_zoomBlur + _oorBlur) max _minBlur;
    [_totalBlur min 5]
};

// Film grain and lighting effects (only for Full mode)
private _film = [0,0,0,0,0,0];
private _bright = 1;
private _noise = 0;

if (_nvMode == 0) then {
    _noise = linearConversion [35, 150, _light, _baseNoise, 0, true];
    _bright = linearConversion [35, 150, _light, _maxBright, 1, true];
    
    private _gInt = linearConversion [0, 1, _noise * _zoom * _int, 1 * _int, 1.5 * _int, true];
    private _gSharp = linearConversion [0, 1, _noise, 2, 0.7, true];
    private _gSize = linearConversion [0, 1, _baseNoise * ([_zoom, 1] select !_isHmd), 0.1, 4, true];
    private _gOpac = linearConversion [0, 1, _bright * _noise * _int, 0.5 * _int, 0.7 * _int, true];
    _film = [_gInt, _gSharp, _gSize, _gOpac * 0.75, _gOpac, 0];
};

// Get color array from preset setting
private _colorArray = [1, 1, 1, 1];

if (_nvMode == 2) then {
    private _manualColor = KTWK_NVG_opt_color;
    if (_manualColor > 0) then {
        _colorArray = call compile format ["KTWK_NVG_opt_color_%1", _manualColor];
        _colorArray set [3, 0];
    };
} else {
    private _colorPresetType = typeName _colorPreset;
    if (_colorPresetType == "SCALAR") then {
        if (_colorPreset > 0) then {
            _colorArray = call compile format ["KTWK_NVG_opt_color_%1", _colorPreset];
            _colorArray set [3, 0];
        };
    };
    if (_colorPresetType == "ARRAY") then {
        _colorArray = _colorPreset;
        _colorArray set [3, 0];
    };
};

// Color calculation
private _color = call {
    if (_nvMode == 1) exitWith {
        // Basic: tint only, neutral brightness/contrast
        [1, 1.1, 0.05, [0, 0, 0, 0], _colorArray, [0.299, 0.587, 0.114, 0], [-1, -1, 0, 0, 0, 0, 0]]
    };
    [(1 * _bright) min 1.5, (0.5 * _maxBright) min 1, 0.05, [1,1,1,0], _colorArray, [0.45,0.45,0.45,0], [-1, -1, 0, 0, 0, 0, 0]]
};

diag_log format ["color: %1", _color];

// Update cache
KTWK_NVG_cache set [IDX_GENINDEXCACHED, _genIndex];
KTWK_NVG_cache set [IDX_COLORPRESETCACHED, _colorPreset];

[_film, _blur, _color]
