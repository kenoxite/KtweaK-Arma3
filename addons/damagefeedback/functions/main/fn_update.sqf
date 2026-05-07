// KTWK_DFB_fnc_update
// Updates the HUD health display with current damage values
//
// Parameters:
//   None
// Returns:
//   Boolean - false if display not ready, true otherwise

// Skip if mission isn't ready yet
if (isNull findDisplay 46) exitWith { false };

if (!KTWK_DFB_opt_enabled) exitWith {false};

#include "\z\ktweak\addons\damagefeedback\ace.hpp"

disableSerialization;

private _display = uiNamespace getVariable ["DFB_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "[DFB] Display not found!";
    false
};

private _player = [] call KTWK_DFB_fnc_getPlayer;
private _desiredAlpha = missionNamespace getVariable ["KTWK_DFB_desiredAlpha", KTWK_DFB_opt_alpha];
private _currentAlpha = missionNamespace getVariable ["KTWK_DFB_currentAlpha", 0];
private _dmgTracker = missionNamespace getVariable ["KTWK_DFB_dmgTracker", []];
if (_dmgTracker isEqualTo []) exitWith {false};
private _aceMedical = missionNamespace getVariable ["KTWK_aceMedical", false];
private _idcs = missionNamespace getVariable ["KTWK_DFB_idcs", []];

// ACE Medical data collection
private _bodyPartDamage = [];
private _damageThreshold = 1;
private _bodyPartBloodLoss = [];

if (_aceMedical) then {
    _bodyPartDamage = _player getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]];
    _damageThreshold = _player getVariable [
        "ace_medical_damageThreshold",
        [ace_medical_AIDamageThreshold, ace_medical_playerDamageThreshold] select (isPlayer _player)
    ];
    
    _bodyPartBloodLoss = [0, 0, 0, 0, 0, 0];
    private _openWounds = _player getVariable ["ace_medical_openWounds", createHashMap];
    
    {
        private _partIndex = ["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"] find _x;
        {
            _x params ["", "_amountOf", "_bleeding"];
            _bodyPartBloodLoss set [_partIndex, (_bodyPartBloodLoss # _partIndex) + (_bleeding * _amountOf)];
        } forEach _y;
    } forEach _openWounds;
};

// Damage to color function
private _fnc_dmgColor = {
    params ["_dmg", "_healthColors"];
    
    private _healthStatus = call {
        if (_dmg isEqualTo 0) exitWith {0};
        if (_dmg <= 0.25) exitWith {1};
        if (_dmg <= 0.5) exitWith {2};
        if (_dmg <= 0.7) exitWith {3};
        4
    };
    
    _healthColors # _healthStatus
};

// Color definitions
private _healthColors = [
    KTWK_DFB_opt_ColorHealthy,
    KTWK_DFB_opt_ColorScuffed,
    KTWK_DFB_opt_ColorLightWound,
    KTWK_DFB_opt_ColorModerateWound,
    KTWK_DFB_opt_ColorSevereWound
];

// Process each body part
private _ctrlIDCs = _idcs select [2, count _idcs - 2];
private _inMelee = if (!KTWK_DFB_ktweak) then {
    [_player] call KTWK_DFB_fnc_inMelee
} else {
    [_player] call KTWK_fnc_inMelee
};

private _needsShowHud = false;

{
    _x params ["_idc", "_part"];
    
    private _ctrl = _display displayCtrl _idc;
    if (isNull _ctrl) then {
        diag_log "[DFB] Dialog control not found!";
        continue;
    };
    
    private _currentDamageArr = _dmgTracker # _forEachIndex;
    _currentDamageArr params ["_currentDamage", "_damageAlpha"];
    
    private _damage = 0;
    private _color = [];
    
    if (_aceMedical) then {
        // ACE Medical color calculation
        private _bloodLoss = _bodyPartBloodLoss # _forEachIndex;
        _damage = _bodyPartDamage # _forEachIndex;
        
        if (_bloodLoss > 0) then {
            _color = +([_bloodLoss] call ace_medical_gui_fnc_bloodLossToRGBA);
        } else {
            private _threshold = switch (true) do {
                case (_forEachIndex > 3): { ace_medical_const_limpingDamageThreshold * 4 };
                case (_forEachIndex > 1): { ace_medical_const_fractureDamageThreshold * 4 };
                case (_forEachIndex isEqualTo 0): { _damageThreshold * 1.25 };
                default { _damageThreshold * 1.5 };
            };
            _damage = (_damage / (0.01 max _threshold)) min 1;
            _color = +([_damage] call ace_medical_gui_fnc_damageToRGBA);
        };
    } else {
        // Vanilla damage
        _damage = _player getHitPointDamage format ["Hit%1", KTWK_DFB_bodyParts # _forEachIndex];
        _color = +([_damage, _healthColors] call _fnc_dmgColor);
    };
    
    // Flash effect - compare against stored damage to detect changes
    if (_damage isEqualTo _currentDamage) then {
        private _newAlpha = (_damageAlpha - 0.005) max _desiredAlpha;
        if (_newAlpha isNotEqualTo _damageAlpha) then {
            _needsShowHud = true;
        };
        KTWK_DFB_currentAlpha = _newAlpha;
    } else {
        _needsShowHud = true;
        KTWK_DFB_currentAlpha = 1;
    };

    _currentAlpha = KTWK_DFB_currentAlpha;
    
    // Apply color with alpha
    if (_aceMedical) then {
        _color set [3, _currentAlpha];
    } else {
        _color pushBack _currentAlpha;
    };
    
    _ctrl ctrlSetTextColor _color;
    KTWK_DFB_dmgTracker set [_forEachIndex, [_damage, KTWK_DFB_currentAlpha]];
    
} forEach _ctrlIDCs;

_dmgTracker = KTWK_DFB_dmgTracker;

// Global health indicator
private _globalIdc = (_idcs # 0) # 0;
private _globalCtrl = _display displayCtrl _globalIdc;

if (!isNull _globalCtrl) then {
    if (!_aceMedical) then {
        private _damage = damage _player;
        private _color = +([_damage, _healthColors] call _fnc_dmgColor);
        
        private _lastIndex = (count _dmgTracker) - 1;
        private _lastArr = _dmgTracker # _lastIndex;
        _lastArr params ["_currentDamage", "_damageAlpha"];
        
        if (_damage isEqualTo _currentDamage) then {
            private _newAlpha = (_damageAlpha - 0.005) max KTWK_DFB_desiredAlpha;
            if (_newAlpha isNotEqualTo _damageAlpha) then {
                _needsShowHud = true;
            };
            KTWK_DFB_currentAlpha = _newAlpha;
        } else {
            _needsShowHud = true;
            KTWK_DFB_currentAlpha = 1;
        };
        
        if (_inMelee) then {
            KTWK_DFB_currentAlpha = KTWK_DFB_currentAlpha max 0.5;
        };

        _currentAlpha = KTWK_DFB_currentAlpha;
        
        _color pushBack _currentAlpha;
        _globalCtrl ctrlSetTextColor _color;
        
        KTWK_DFB_dmgTracker set [_lastIndex, [_damage, _currentAlpha]];
    } else {
        // Hide with ACE Medical
        _globalCtrl ctrlSetTextColor [0, 0, 0, 0];
    };
};

_dmgTracker = KTWK_DFB_dmgTracker;

// Update outline alpha and call showHUD for final display
private _outlineAlpha = 0;
{
    private _alpha = _x # 1;
    if (_alpha > _outlineAlpha) then {
        _outlineAlpha = _alpha;
    };
} forEach _dmgTracker;

private _outlineIdc = (_idcs # 1) # 0;
private _outlineCtrl = _display displayCtrl _outlineIdc;
_outlineCtrl ctrlSetTextColor [0, 0, 0, _outlineAlpha];

// Only call showHUD if something actually changed
if (_needsShowHud) then {
    [_display, _idcs, _dmgTracker, _inMelee, _aceMedical, _healthColors] call KTWK_DFB_fnc_showHUD;
};

true
