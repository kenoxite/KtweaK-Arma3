// KTWK_NVG_fnc_getState
// Returns current NVG effect state for PFH to apply
//
// Parameters:
//   None
// Returns:
//   Array - [_enabled, _blurArray, _colorArray, _filmArray, _chromValue]

// Check if effects should be enabled
private _unit = KTWK_player;
private _veh = vehicle _unit;
private _enabled = currentVisionMode _unit == 1 && {isNull curatorCamera} && {(positionCameraToWorld [0,0,0] distance _veh) < 30};

if (!_enabled) exitWith { [false, [], [], [], 0] };

// Get current mode
private _inVehicle = _veh != _unit;
private _mode = [_unit, _veh, _inVehicle, KTWK_lastVehicleMFD, KTWK_NVG_weaponZoom] call KTWK_NVG_fnc_nvgMode;

// Check global exclusion first
private _itemClass = call {
    if (_mode == "helmet") exitWith { headgear _unit };
    if (_mode in ["rangefinder", "laserdesignator"]) exitWith { currentWeapon _unit };
    if (_mode == "scoped") exitWith { (_unit weaponAccessories currentWeapon _unit) # 2 };
    if (_mode == "standard") exitWith { hmd _unit };
    ""
};

if (_itemClass != "" && {toLowerANSI _itemClass in KTWK_NVG_excludeGlobal}) exitWith {
    [false, [], [], [], 0]
};

// Determine intensity and color
private _intensity = KTWK_NVG_opt_intensity;
private _customColor = [_itemClass] call KTWK_NVG_fnc_colorFromCustom;
private _colorPreset = [KTWK_NVG_opt_color, _customColor] select (_customColor > 0);
private _chromAberration = 0.003;
private _autoGenTypes = ["standard", "helmet", "rangefinder", "laserdesignator", "scoped"];
private _itemClassLower = toLowerANSI _itemClass;

if (KTWK_NVG_opt_autoGen && {_mode in _autoGenTypes} && {!(_itemClassLower in KTWK_NVG_excludeAutoGen)}) then {
    // Bypass cache if debug mode or item changed
    private _cachedItemClass = [KTWK_NVG_cachedItemClass, ""] select (KTWK_NVG_debug_disableCache);
    
    if (_itemClass != _cachedItemClass) then {
        private _detection = [_itemClass] call KTWK_NVG_fnc_detectGeneration;
        if (!KTWK_NVG_debug_disableCache) then {
            KTWK_NVG_cachedItemClass = _itemClass;
            KTWK_NVG_cachedDetection = _detection;
        };
        _intensity = _detection # 0;
        _chromAberration = _detection # 4;
    } else {
        _intensity = KTWK_NVG_cachedDetection # 0;
        _chromAberration = KTWK_NVG_cachedDetection # 4;
    };
};

// Get color array
private _colorizeArray = if (!KTWK_NVG_opt_autoGen || {!(_mode in _autoGenTypes)}) then {
    private _cachedColorPreset = if (KTWK_NVG_debug_disableCache) then { -2 } else { KTWK_NVG_cachedColorPreset };
    private _cachedColor = if (KTWK_NVG_debug_disableCache) then { [] } else { KTWK_NVG_cachedColor };
    
    if (_colorPreset == _cachedColorPreset && {_cachedColor isNotEqualTo []}) then {
        _cachedColor
    } else {
        private _color = [_colorPreset] call KTWK_NVG_fnc_color;
        if (!KTWK_NVG_debug_disableCache) then {
            KTWK_NVG_cachedColorPreset = _colorPreset;
            KTWK_NVG_cachedColor = _color;
        };
        _color
    }
} else {
    [_colorPreset] call KTWK_NVG_fnc_color
};

private _zoom = call KTWK_NVG_fnc_getZoom;

private _lighting = getLightingAt KTWK_player; 
_lighting params ["", "_ambientBrightness", "", "_dynamicBrightness"];
private _ambientLighting = _ambientBrightness + _dynamicBrightness;

_baseNoise = KTWK_NVG_opt_brightness;
_noise = linearConversion [35, 150, _ambientLighting, _baseNoise, 0, true];
 
private _brightnessFactor = linearConversion [35, 150, _ambientLighting, 1, 0.1, true];

// Film grain
private _grainIntensity = linearConversion [0, 1, _noise * _zoom * _intensity, 0.3, 0.5, true];
private _grainSharpness = linearConversion [0, 1, _noise, 2, 0.7, true];
private _grainSize = linearConversion [0, 1, _baseNoise * _zoom, 0.1, 4, true];
private _grainOpacity = linearConversion [0, 1, _brightnessFactor * _noise * _intensity, 0.4, 1.5, true];

// Calculate zoom intensity for blur effect
private _zoomIntensityMod = call {
    if (_mode == "disabled") exitWith { 1 };
    if (_mode == "rangefinder") exitWith { 28 };
    if (_mode == "vehicle") exitWith { 56 };
    if (_mode == "scoped") exitWith { 16 };
    9  // standard
};
private _zoomBlur = (_zoom / _zoomIntensityMod) * _intensity * 0.35;

// Chrome aberration
_chromAberration = _chromAberration * _zoomBlur;

// Blur
// Scale blur with zoom if using portable NVG
private _blurMod = [0, _zoomBlur] select (_mode in ["standard", "helmet"]);
private _blurIntensity = 0.25 + _blurMod;
private _blurArray = [[_blurIntensity, 0.1] select (_zoomBlur == 1)];

// Color
private _colorArray = [
    0.8 * _brightnessFactor,
    0.5,
    0.05,
    [1, 1, 1, 0],
    _colorizeArray,
    [0.45, 0.45, 0.45, 0],
    [1, 1, 1, 1]
];
private _filmArray = if (_noise == 0) then { [] } else { [_grainIntensity, _grainSharpness, _grainSize, _grainOpacity * 0.75, _grainOpacity, 0] };

[true, _blurArray, _colorArray, _filmArray, _chromAberration]
