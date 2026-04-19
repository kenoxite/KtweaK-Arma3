// KTWK_NVG_fnc_createPfh
// Creates the per-frame handler for NVG effects
//
// Parameters:
//   None
// Returns:
//   Nothing

KTWK_NVG_pfh = [{
    params ["_args", "_handle"];

    if (!KTWK_NVG_opt_enabled) exitWith {
        call KTWK_NVG_fnc_disableSystem;
    };

    private _unit = KTWK_player;
    private _cache = KTWK_NVG_cache;
    
    _cache params ["_active", "_modeCached", "_lightCached", "_zoomCached", "_lastSample", "_lastUpdate", "_handlesCreated", "_filmCached", "_blurCached", "_outOfRangeCached", "_testPosCached", "_itemClassCached", "_genIndexCached", "_colorPresetCached"];
    
    // Exit if paused, in splendid camera or NVG not active
    if (!isNull (findDisplay 49) || {!isNil "BIS_fnc_camera_cam"} || {currentVisionMode _unit != 1}) exitWith {   
        if (_active) then {
            if (!isNil "BIS_fnc_camera_cam") then {
                call KTWK_NVG_fnc_disableEffects;
            };
            KTWK_NVG_filmGrainHandle ppEffectEnable false;
            KTWK_NVG_cache set [0, false];
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
    private _outOfRange = _outOfRangeCached; 
    
    // Sample lighting at interval
    if (_time - _lastSample > KTWK_NVG_posInterval) then {   
        private _result = [_mode] call KTWK_NVG_fnc_sampleLighting; 
        _light = _result # 0; 
        _outOfRange = _result # 1; 
        KTWK_NVG_cache set [4, _time];
    };
    
    private _changed = !_active ||   
        _modeCached != _mode ||   
        abs (_lightCached - _light) > KTWK_NVG_lightThreshold ||   
        abs (_zoomCached - _zoom) > 0.5 || 
        _outOfRangeCached != _outOfRange; 
    
    if (!_changed) exitWith {};
    
    if (!_handlesCreated) then { call KTWK_NVG_fnc_createHandles };
    
    [_mode, _light, _zoom, _outOfRange] call KTWK_NVG_fnc_applyEffects;
    
}, KTWK_NVG_opt_pfhInterval, []] call CBA_fnc_addPerFrameHandler;
