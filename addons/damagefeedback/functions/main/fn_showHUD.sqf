// KTWK_DFB_fnc_showHUD
// Shows the HUD with proper transparency for all body parts
// Handles both ACE Medical and Vanilla color/transparency systems
//
// Parameters:
//   _display - The HUD display
//   _idcs - Array of IDC mappings [[_idc, "_img"], ...]
//   _damageTracker - Current damage tracking array (for alpha values)
//   _inMelee - Whether player is in melee mode (forces minimum alpha 0.5)
//   _isACE - Whether ACE Medical is active
//   _colors - Array of color settings for Vanilla mode [healthy, scuffed, light, moderate, severe]
// Returns:
//   Boolean - false if display or controls invalid, true otherwise

params ["_display", "_idcs", "_damageTracker", "_inMelee", "_isACE", ["_colors", []]];

if (isNull _display) exitWith { false };

// Process only body part controls (skip global and outline which are indices 0 and 1)
private _bodyPartIdcs = _idcs select [2, count _idcs - 2];
private _outlineAlpha = 0;

{
    _x params ["_idc", "_part"];
    
    private _ctrl = _display displayCtrl _idc;
    if (isNull _ctrl) then {
        diag_log format ["[DFB] Control %1 not found in showHUD", _idc];
        continue;
    };
    
    // Get current alpha from damage tracker
    private _currentAlpha = (_damageTracker # _forEachIndex) # 1;
    
    // Apply melee visibility boost
    if (_inMelee) then {
        _currentAlpha = _currentAlpha max 0.5;
    };
    
    // Track highest alpha for outline
    if (_currentAlpha > _outlineAlpha) then {
        _outlineAlpha = _currentAlpha;
    };
    
    // Set color based on medical system
    if (_isACE) then {
        // ACE Medical: color already set by update function before calling showHUD
        // Just ensure alpha is applied
        private _currentColor = ctrlTextColor _ctrl;
        _currentColor set [3, _currentAlpha];
        _ctrl ctrlSetTextColor _currentColor;
    } else {
        // Vanilla: need to recalculate color from damage
        private _damage = (_damageTracker # _forEachIndex) # 0;
        private _healthStatus = call {
            if (_damage isEqualTo 0) exitWith { 0 };
            if (_damage <= 0.25) exitWith { 1 };
            if (_damage <= 0.5) exitWith { 2 };
            if (_damage <= 0.7) exitWith { 3 };
            4
        };
        
        private _color = +(_colors # _healthStatus);
        _color pushBack _currentAlpha;
        _ctrl ctrlSetTextColor _color;
    };
    
} forEach _bodyPartIdcs;

// Update outline alpha (index 1 in idcs)
private _outlineIdc = (_idcs # 1) # 0;
private _outlineCtrl = _display displayCtrl _outlineIdc;
if (!isNull _outlineCtrl) then {
    _outlineCtrl ctrlSetTextColor [0, 0, 0, _outlineAlpha];
};

// Handle global health indicator (index 0 in idcs)
private _globalIdc = (_idcs # 0) # 0;
private _globalCtrl = _display displayCtrl _globalIdc;
if (!isNull _globalCtrl) then {
    if (!_isACE) then {
        // Vanilla: global health uses last entry in damage tracker
        private _lastIndex = (count _damageTracker) - 1;
        private _globalDamage = (_damageTracker # _lastIndex) # 0;
        private _globalAlpha = (_damageTracker # _lastIndex) # 1;
        
        if (_inMelee) then {
            _globalAlpha = _globalAlpha max 0.5;
        };
        
        private _healthStatus = call {
            if (_globalDamage isEqualTo 0) exitWith { 0 };
            if (_globalDamage <= 0.25) exitWith { 1 };
            if (_globalDamage <= 0.5) exitWith { 2 };
            if (_globalDamage <= 0.7) exitWith { 3 };
            4
        };
        
        private _color = +(_colors # _healthStatus);
        _color pushBack _globalAlpha;
        _globalCtrl ctrlSetTextColor _color;
    } else {
        // ACE Medical: hide global indicator
        _globalCtrl ctrlSetTextColor [0, 0, 0, 0];
    };
};

true
