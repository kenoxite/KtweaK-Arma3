// KTWK_BPH_fnc_update
// Updates the HUD health display with current damage values
//
// Parameters:
//   None
// Returns:
//   Boolean - false if display not ready, true otherwise

// Skip if mission isn't ready yet
if (isNull findDisplay 46) exitWith { false };

#include "\z\ktweak\addons\bodyparthud\ace.hpp"

disableSerialization;

private _display = uiNamespace getVariable ["BPH_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "Bodypart HUD: Display not found!";
    false
};

// Initialize globals if needed
if (isNil "KTWK_BPH_targetAlpha") then {
    KTWK_BPH_targetAlpha = KTWK_BPH_opt_alpha;
};
if (isNil "KTWK_BPH_displayAlpha") then {
    KTWK_BPH_displayAlpha = 0;
};
if (isNil "KTWK_player") then {
    KTWK_player = call CBA_fnc_currentUnit;
};
if (isNil "KTWK_BPH_dmgTracker") then {
    KTWK_BPH_dmgTracker = [];
};

// ACE Medical data collection
private _bodyPartDamage = [];
private _damageThreshold = 1;
private _bodyPartBloodLoss = [];

if (KTWK_aceMedical) then {
    _bodyPartDamage = KTWK_player getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]];
    _damageThreshold = KTWK_player getVariable [
        "ace_medical_damageThreshold",
        [ace_medical_AIDamageThreshold, ace_medical_playerDamageThreshold] select (isPlayer KTWK_player)
    ];
    
    _bodyPartBloodLoss = [0, 0, 0, 0, 0, 0];
    private _openWounds = KTWK_player getVariable ["ace_medical_openWounds", createHashMap];
    
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
    KTWK_BPH_opt_ColorHealthy,
    KTWK_BPH_opt_ColorScuffed,
    KTWK_BPH_opt_ColorLightWound,
    KTWK_BPH_opt_ColorModerateWound,
    KTWK_BPH_opt_ColorSevereWound
];

// Process each body part
private _ctrlIDCs = KTWK_BPH_idcs select [2, count KTWK_BPH_idcs - 2];
private _inMelee = if (!KTWK_BPH_ktweak) then {
    [KTWK_player] call KTWK_BPH_fnc_inMelee
} else {
    [KTWK_player] call KTWK_fnc_inMelee
};

{
    _x params ["_idc", "_part"];
    
    private _ctrl = _display displayCtrl _idc;
    if (isNull _ctrl) then {
        diag_log "Bodypart HUD: Dialog control not found!";
        continue;
    };
    
    private _currentDamageArr = KTWK_BPH_dmgTracker # _forEachIndex;
    _currentDamageArr params ["_currentDamage", "_damageAlpha"];
    
    private _damage = 0;
    private _color = [];
    
    if (KTWK_aceMedical) then {
        // ACE Medical color calculation
        private _bloodLoss = _bodyPartBloodLoss # _forEachIndex;
        _damage = _bodyPartDamage # _forEachIndex;
        
        if (_bloodLoss > 0) then {
            _color = [_bloodLoss] call ace_medical_gui_fnc_bloodLossToRGBA;
        } else {
            private _threshold = switch (true) do {
                case (_forEachIndex > 3): { ace_medical_const_limpingDamageThreshold * 4 };
                case (_forEachIndex > 1): { ace_medical_const_fractureDamageThreshold * 4 };
                case (_forEachIndex isEqualTo 0): { _damageThreshold * 1.25 };
                default { _damageThreshold * 1.5 };
            };
            _damage = (_damage / _threshold) min 1;
            _color = [_damage] call ace_medical_gui_fnc_damageToRGBA;
        };
    } else {
        // Vanilla damage
        _damage = KTWK_player getHitPointDamage format ["Hit%1", KTWK_BPH_bodyParts # _forEachIndex];
        _color = +([_damage, _healthColors] call _fnc_dmgColor);
    };
    
    // Flash effect - compare against stored damage to detect changes
    if (_damage isEqualTo _currentDamage) then {
        KTWK_BPH_displayAlpha = (_damageAlpha - 0.005) max KTWK_BPH_targetAlpha;
    } else {
        KTWK_BPH_displayAlpha = 1;
    };
    
    // Apply color with alpha
    if (KTWK_aceMedical) then {
        _color set [3, KTWK_BPH_displayAlpha];
    } else {
        _color pushBack KTWK_BPH_displayAlpha;
    };
    
    _ctrl ctrlSetTextColor _color;
    KTWK_BPH_dmgTracker set [_forEachIndex, [_damage, KTWK_BPH_displayAlpha]];
    
} forEach _ctrlIDCs;

// Global health indicator
private _globalIdc = (KTWK_BPH_idcs # 0) # 0;
private _globalCtrl = _display displayCtrl _globalIdc;

if (!isNull _globalCtrl) then {
    if (!KTWK_aceMedical) then {
        private _damage = damage KTWK_player;
        private _color = +([_damage, _healthColors] call _fnc_dmgColor);
        
        private _lastIndex = (count KTWK_BPH_dmgTracker) - 1;
        private _lastArr = KTWK_BPH_dmgTracker # _lastIndex;
        _lastArr params ["_currentDamage", "_damageAlpha"];
        
        if (_damage isEqualTo _currentDamage) then {
            KTWK_BPH_displayAlpha = (_damageAlpha - 0.005) max KTWK_BPH_targetAlpha;
        } else {
            KTWK_BPH_displayAlpha = 1;
        };
        
        if (_inMelee) then {
            KTWK_BPH_displayAlpha = KTWK_BPH_displayAlpha max 0.5;
        };
        
        _color pushBack KTWK_BPH_displayAlpha;
        _globalCtrl ctrlSetTextColor _color;
        
        KTWK_BPH_dmgTracker set [_lastIndex, [_damage, KTWK_BPH_displayAlpha]];
    } else {
        // Hide with ACE Medical
        _globalCtrl ctrlSetTextColor [0, 0, 0, 0];
    };
};

// Update outline alpha and call showHUD for final display
private _outlineAlpha = 0;
{
    private _alpha = _x # 1;
    if (_alpha > _outlineAlpha) then {
        _outlineAlpha = _alpha;
    };
} forEach KTWK_BPH_dmgTracker;

private _outlineIdc = (KTWK_BPH_idcs # 1) # 0;
private _outlineCtrl = _display displayCtrl _outlineIdc;
_outlineCtrl ctrlSetTextColor [0, 0, 0, _outlineAlpha];

// Call showHUD to apply proper transparency and handle ACE/Vanilla differences
[_display, KTWK_BPH_idcs, KTWK_BPH_dmgTracker, _inMelee, KTWK_aceMedical, _healthColors] call KTWK_BPH_fnc_showHUD;

true
