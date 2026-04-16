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
private _mode = [_unit, _veh, _inVehicle, KTWK_lastVehicleMFD, KTWK_NVG_lastWeaponZoom] call KTWK_NVG_fnc_nvgMode;

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

// Get lighting factors
private _noise = [KTWK_NVG_ambientBrightness, _mode] call KTWK_NVG_fnc_noiseIntensity;
private _brightnessFactor = [KTWK_NVG_ambientBrightness, _mode] call KTWK_NVG_fnc_lightIntensity;

// Calculate zoom intensity fresh every frame (no caching - it changes constantly)
private _zoomIntensity = ([_mode] call KTWK_NVG_fnc_zoomIntensity) * _intensity;

// Build effect arrays
private _grainIntensity = _noise * _zoomIntensity;
private _grainSize = ((_zoomIntensity * 5) * _noise) min 8;
private _blurIntensity = 0.25 + (_zoomIntensity * 0.35);

_chromAberration = _chromAberration * _zoomIntensity;

private _blurArray = [[_blurIntensity, 0.1] select (_zoomIntensity == 1)];
private _colorArray = [
    0.8 * _brightnessFactor,
    0.5,
    0.05,
    [1, 1, 1, 0],
    _colorizeArray,
    [0.45, 0.45, 0.45, 0]
];
private _filmArray = if (_noise == 0) then { [] } else { [_grainIntensity, 1, _grainSize, 0.4, 0.2, 0] };

[true, _blurArray, _colorArray, _filmArray, _chromAberration]
