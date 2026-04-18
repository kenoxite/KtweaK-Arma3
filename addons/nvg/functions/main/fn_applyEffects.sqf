// KTWK_NVG_fnc_applyEffects
// Applies NVG effects to ppEffect handlers
//
// Parameters:
//   _mode       - Current NVG mode
//   _light      - Ambient light value
//   _zoom       - Current zoom level
//   _outOfRange - Boolean: looking beyond effective range
// Returns:
//   Nothing

params ["_mode", "_light", "_zoom", "_outOfRange"];

private _params = [_mode, _light, _zoom, _outOfRange] call KTWK_NVG_fnc_calcEffects;
_params params ["_film", "_blur", "_color"];

// Apply film grain if enabled
if (KTWK_NVG_opt_filmGrainEnabled) then {
    KTWK_NVG_filmGrainHandle ppEffectAdjust _film;
    KTWK_NVG_filmGrainHandle ppEffectCommit 0;
    KTWK_NVG_filmGrainHandle ppEffectEnable true;
} else {
    KTWK_NVG_filmGrainHandle ppEffectEnable false;
};

// Apply blur
KTWK_NVG_blurHandle ppEffectAdjust _blur;
KTWK_NVG_blurHandle ppEffectCommit 0;
KTWK_NVG_blurHandle ppEffectEnable true;

// Apply color
KTWK_NVG_colorHandle ppEffectAdjust _color;
KTWK_NVG_colorHandle ppEffectForceInNVG true; 
KTWK_NVG_colorHandle ppEffectCommit 0;
KTWK_NVG_colorHandle ppEffectEnable true;

// Update cache
KTWK_NVG_cache set [0, true];
KTWK_NVG_cache set [1, _mode];
KTWK_NVG_cache set [2, _light];
KTWK_NVG_cache set [3, _zoom];
KTWK_NVG_cache set [9, _outOfRange];
