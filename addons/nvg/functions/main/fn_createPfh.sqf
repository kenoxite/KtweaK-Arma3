// KTWK_NVG_fnc_createPfh
// Creates the per-frame handler for NVG effects
//
// Parameters:
//   None
// Returns:
//   Nothing

if (!isNil "KTWK_NVG_pfh") exitWith {};

#include "\z\ktweak\addons\nvg\cacheIndices.hpp"

KTWK_NVG_pfh = [{
    params ["_args", "_handle"];

    if (!KTWK_NVG_opt_enabled || (KTWK_aceNightvision && {!KTWK_NVG_opt_aceOverride})) exitWith {
        call KTWK_NVG_fnc_disableSystem;
    };

    private _unit = KTWK_player;
    private _cache = KTWK_NVG_cache;
    
    _cache params ["_active", "_modeCached", "_lightCached", "_zoomCached", "_lastSample", "_handlesCreated", "_rangeFactorCached"];
    
    // Exit if paused, in splendid camera or NVG not active
    if (!isNull (findDisplay 49) || {!isNil "BIS_fnc_camera_cam"} || {currentVisionMode _unit != 1}) exitWith {   
        if (_active) then {
            if (!isNil "BIS_fnc_camera_cam") then {
                call KTWK_NVG_fnc_disableEffects;
            };
            KTWK_NVG_filmGrainHandle ppEffectEnable false;
            KTWK_NVG_cache set [IDX_ACTIVE, false];
        };
    };
    
    private _mode = [_unit] call KTWK_NVG_fnc_mode;

    // Skip if current device is excluded
    if ([_mode, _unit] call KTWK_NVG_fnc_isExcluded) exitWith {
        call KTWK_NVG_fnc_disableEffects;
    };
    
    // Update globals
    KTWK_NVG_isHmd = _mode in ["standard","helmet"];
    KTWK_NVG_isHmdADS = _mode in ["ADS"];
    
    private _zoom = call KTWK_NVG_fnc_getZoom;
    KTWK_NVG_zoom = _zoom;
    KTWK_NVG_isHmdADSNoScope = KTWK_NVG_isHmdADS && _zoom < 3;
    
    private _time = diag_tickTime;
    private _light = _lightCached;
    private _rangeFactor = _rangeFactorCached; 
    
    // Sample lighting at interval
    if (_time - _lastSample > KTWK_NVG_posInterval) then {   
        private _result = [_mode] call KTWK_NVG_fnc_sampleLighting; 
        _light = _result # 0; 
        _rangeFactor = _result # 1; 
        KTWK_NVG_cache set [IDX_LIGHTCACHED, _light];
        KTWK_NVG_cache set [IDX_LASTSAMPLE, _time];
        KTWK_NVG_cache set [IDX_RANGEFACTORCACHED, _rangeFactor];
    };
    
    private _changed = !_active ||   
        _modeCached != _mode ||   
        abs (_lightCached - _light) > KTWK_NVG_lightThreshold ||   
        abs (_zoomCached - _zoom) > 0.5 || 
        _rangeFactorCached != _rangeFactor; 
    
    if (!_changed) exitWith {};
    
    if (!_handlesCreated) then { call KTWK_NVG_fnc_createHandles };
    
    [_mode, _light, _zoom, _rangeFactor] call KTWK_NVG_fnc_applyEffects;
    
    KTWK_NVG_cache set [IDX_MODECACHED, _mode];
    KTWK_NVG_cache set [IDX_ZOOMCACHED, _zoom];

    // ACE Nightvision overrides
    if (KTWK_aceNightvision && {KTWK_NVG_opt_aceOverride}) then {
            missionNamespace setVariable ["ace_nightvision_nvgColorize", [1,1,1,1]];
            missionNamespace setVariable ["ace_nightvision_effectScaling", 0.1];
            missionNamespace setVariable ["ace_nightvision_noiseScaling", 0];
            missionNamespace setVariable ["ace_nightvision_nvgOffset", 0]; 
            missionNamespace setVariable ["ace_nightvision_nvgWeight", [0.45,0.45,0.45,0]];
            missionNamespace setVariable ["ace_nightvision_nvgBlend", [1,1,1,0]];
    };

}, KTWK_NVG_opt_pfhInterval, []] call CBA_fnc_addPerFrameHandler;
