// KTWK_NVG_fnc_calcEffects
// Calculates effect parameters based on current state
//
// Parameters:
//   _mode       - Current NVG mode
//   _light      - Ambient light value
//   _zoom       - Current zoom level
//   _outOfRange - Boolean: looking beyond effective range
// Returns:
//   Array - [_film, _blur, _color]

params ["_mode", "_light", "_zoom", "_outOfRange"];

private _player = KTWK_player;

// Global exclusion check
if (_mode != "disabled" && {[_mode, _player] call KTWK_NVG_fnc_isExcluded}) exitWith {
    [[0, 0, 0, 0, 0, 0], [0], [1, 1, 1, 1]]
};

// Determine generation index and color preset
private _deviceGenData = [_mode, _player] call KTWK_NVG_fnc_getDeviceGen;
_deviceGenData params ["_genIndex", "_colorPreset"];

// Get parameters based on generation
private _int = if (_genIndex > 0) then {
    KTWK_NVG_genIntensity # _genIndex
} else {
    KTWK_NVG_opt_intensity
};

private _baseNoise = if (_genIndex > 0) then {
    KTWK_NVG_genNoise # _genIndex
} else {
    KTWK_NVG_opt_noise
};

private _maxBright = if (_genIndex > 0) then {
    KTWK_NVG_genBrightness # _genIndex
} else {
    KTWK_NVG_opt_brightness
};

private _isHmd = KTWK_NVG_isHmd;
private _isHmdADSNoScope = KTWK_NVG_isHmdADSNoScope;
private _baseBlur = KTWK_NVG_opt_baseBlur;
private _outOfRangeBlur = KTWK_NVG_opt_outOfRangeBlur;
    
private _noise = linearConversion [35, 150, _light, _baseNoise, 0, true];
private _bright = linearConversion [35, 150, _light, _maxBright, 1, true];
    
private _gInt = linearConversion [0, 1, _noise * _zoom * _int, 1 * _int, 1.5 * _int, true];
private _gSharp = linearConversion [0, 1, _noise, 2, 0.7, true];
private _gSize = linearConversion [0, 1, _baseNoise * ([_zoom, 1] select !_isHmd), 0.1, 4, true];
private _gOpac = linearConversion [0, 1, _bright * _noise * _int, 0.5 * _int, 0.7 * _int, true];
private _film = [_gInt, _gSharp, _gSize, _gOpac * 0.75, _gOpac, 0];
    
private _blur = call { 
    if (_outOfRange) exitWith { 
        private _blurMod = [1, _zoom] select (_isHmd || _isHmdADSNoScope);
        private _calcBlur = _baseBlur * _outOfRangeBlur * _blurMod;
        [[_calcBlur max ([_baseBlur, _baseBlur + _blurMod] select (!_isHmd && !_isHmdADSNoScope))]]
    }; 
    private _zMod = switch _mode do {   
        case "disabled": {1};
        case "rangefinder": {28};
        case "vehicle": {56};
        case "scoped": {16};
        default {9};
    };
    private _zBlur = (_zoom / _zMod) * (_int * 2);
    private _blurMod = [0, _zBlur] select (_isHmd || _isHmdADSNoScope);
    [[[_baseBlur + _blurMod], [0.1]] select (_zBlur == 1)]; 
}; 
    
// Get color array from preset setting
private _colorArray = [1, 1, 1, 1];
if (_colorPreset > 0) then {
    _colorArray = call compile format ["KTWK_NVG_opt_color_%1", _colorPreset];
    _colorArray set [3, 0];
};

private _color = [   
    (1 * _bright) min 1,   
    (0.5 * _maxBright) min 1,   
    0.05,   
    [1,1,1,0],   
    _colorArray,   
    [0.45,0.45,0.45,0],   
    [1,1,1,1]   
];

[_film, _blur, _color]
