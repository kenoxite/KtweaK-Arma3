// KTWK_NVG_fnc_applyEffects
// Applies effect arrays if changed
//
// Parameters:
//   _state - State array from getState
// Returns:
//   Nothing

params ["_state"];

private _enabled = _state # 0;

private _ppBlur = KTWK_NVG_ppBlur;
private _ppColor = KTWK_NVG_ppColor;
private _ppFilm = KTWK_NVG_ppFilm;
private _ppChrom = KTWK_NVG_ppChrom;

if (!_enabled) exitWith {
    { _x ppEffectEnable false } forEach [_ppBlur, _ppColor, _ppFilm, _ppChrom];
};

// Round numeric values to 2 decimal places for cache stability
private _blurArray = (_state # 1) apply { _x - (_x mod 0.01) };
private _colorArray = _state # 2;
private _filmArray = (_state # 3) apply { _x - (_x mod 0.01) };
private _chromValue = (_state # 4) - ((_state # 4) mod 0.001);

private _lastBlurArray = KTWK_NVG_lastBlurArray;
private _lastColorArray = KTWK_NVG_lastColorArray;
private _lastFilmArray = KTWK_NVG_lastFilmArray;
private _lastChromArray = KTWK_NVG_lastChromArray;

if (KTWK_NVG_debug_disableCache) then {
    { _x ppEffectEnable true } forEach [_ppBlur, _ppColor];
    
    _ppBlur ppEffectAdjust _blurArray;
    _ppBlur ppEffectCommit 0;
    
    _ppColor ppEffectAdjust _colorArray;
    _ppColor ppEffectCommit 0;
    
    if (_filmArray isEqualTo []) then {
        _ppFilm ppEffectEnable false;
    } else {
        _ppFilm ppEffectEnable true;
        _ppFilm ppEffectAdjust _filmArray;
        _ppFilm ppEffectCommit 0;
    };
    
    if (_chromValue > 0) then {
        _ppChrom ppEffectEnable true;
        _ppChrom ppEffectAdjust [_chromValue, _chromValue, true];
        _ppChrom ppEffectCommit 0;
    } else {
        _ppChrom ppEffectEnable false;
    };
} else {
    { _x ppEffectEnable true } forEach [_ppBlur, _ppColor];
    
    if (_blurArray isNotEqualTo _lastBlurArray) then {
        _ppBlur ppEffectAdjust _blurArray;
        _ppBlur ppEffectCommit 0;
        KTWK_NVG_lastBlurArray = _blurArray;
    };
    
    if (_colorArray isNotEqualTo _lastColorArray) then {
        _ppColor ppEffectAdjust _colorArray;
        _ppColor ppEffectCommit 0;
        KTWK_NVG_lastColorArray = _colorArray;
    };
    
    if (_filmArray isEqualTo []) then {
        _ppFilm ppEffectEnable false;
        KTWK_NVG_lastFilmArray = [];
    } else {
        _ppFilm ppEffectEnable true;
        if (_filmArray isNotEqualTo _lastFilmArray) then {
            _ppFilm ppEffectAdjust _filmArray;
            _ppFilm ppEffectCommit 0;
            KTWK_NVG_lastFilmArray = _filmArray;
        };
    };
    
    if (_chromValue > 0) then {
        _ppChrom ppEffectEnable true;
        private _chromArray = [_chromValue, _chromValue, true];
        if (_chromArray isNotEqualTo _lastChromArray) then {
            _ppChrom ppEffectAdjust _chromArray;
            _ppChrom ppEffectCommit 0;
            KTWK_NVG_lastChromArray = _chromArray;
        };
    } else {
        _ppChrom ppEffectEnable false;
    };
};
