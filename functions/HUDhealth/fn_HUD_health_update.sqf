// Update the HUD health display

// Skip if mission isn't ready yet
if (isNull findDisplay 46) exitWith {false};

// ACE Medical
#define ALL_BODY_PARTS ["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"]
#define ALL_SELECTIONS ["head", "body", "hand_l", "hand_r", "leg_l", "leg_r"]
#define ALL_HITPOINTS ["HitHead", "HitChest", "HitLeftArm", "HitRightArm", "HitLeftLeg", "HitRightLeg"]

#define HITPOINT_INDEX_HEAD 0
#define HITPOINT_INDEX_BODY 1
#define HITPOINT_INDEX_LARM 2
#define HITPOINT_INDEX_RARM 3
#define HITPOINT_INDEX_LLEG 4
#define HITPOINT_INDEX_RLEG 5

#define LIMPING_DAMAGE_THRESHOLD ace_medical_const_limpingDamageThreshold
#define FRACTURE_DAMAGE_THRESHOLD ace_medical_const_fractureDamageThreshold

#define VAR_OPEN_WOUNDS       "ace_medical_openWounds"

#define GET_OPEN_WOUNDS(unit)       (unit getVariable [VAR_OPEN_WOUNDS, createHashMap])
#define GET_DAMAGE_THRESHOLD(unit)  (unit getVariable ["ace_medical_damageThreshold", [ace_medical_AIDamageThreshold,ace_medical_playerDamageThreshold] select (isPlayer unit)])

disableSerialization;
private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth";
if (isNil {_display}) exitwith {diag_log "KtweaK: HUD health display not defined!"};
if (isNull _display) exitwith {diag_log "KtweaK: HUD health display not found!"};

if (isNil {KTWK_HUD_health_alpha}) then { KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha; };
if (isNil {KTWK_HUD_health_currentAlpha}) then { KTWK_HUD_health_currentAlpha = 0; };
if (isNil {KTWK_player}) then { KTWK_player = call KTWK_fnc_playerUnit; };
if (isNil {KTWK_HUD_health_dmgTracker}) then { KTWK_HUD_health_dmgTracker = []; };

private ["_bodyPartDamage", "_damageThreshold", "_bodyPartBloodLoss"];
if (KTWK_aceMedical) then {
    _bodyPartDamage = KTWK_player getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]];
    _damageThreshold = GET_DAMAGE_THRESHOLD(KTWK_player);
    _bodyPartBloodLoss = [0, 0, 0, 0, 0, 0];
    {
        private _partIndex = ALL_BODY_PARTS find _x;
        {
            _x params ["", "_amountOf", "_bleeding"];
            _bodyPartBloodLoss set [_partIndex, (_bodyPartBloodLoss select _partIndex) + (_bleeding * _amountOf)];
        } forEach _y;
    } forEach GET_OPEN_WOUNDS(KTWK_player);
};

private _fnc_dmgColor = {
    params ["_dmg", "_healthColors"];
    private _healthStatus = call {
        if (_dmg <= 0.2) exitWith { 0 };
        if (_dmg > 0.2 && _dmg <= 0.5) exitWith { 1 };
        if (_dmg > 0.5 && _dmg <= 0.7) exitWith { 2 };
        if (_dmg > 0.7) exitWith { 3 };
    };
   _healthColors #_healthStatus
};


private _ctrlIDCs = + KTWK_HUD_health_idcs;
_ctrlIDCs deleteRange [0, 2];

private _healthColors = [
    KTWK_HUD_health_opt_ColorHealthy,
    KTWK_HUD_health_opt_ColorLightWound,
    KTWK_HUD_health_opt_ColorModerateWound,
    KTWK_HUD_health_opt_ColorSevereWound
];
private ["_currentDamageArr", "_ctrl", "_bloodLoss", "_damage", "_bodyPartColor", "_color"];

{
    _x params ["_idc", "_part"];
    _ctrl = _display displayCtrl _idc;
    if (isNil {_ctrl}) exitwith {diag_log "KtweaK: HUD health dialog control not found!"};
    _currentDamageArr = (KTWK_HUD_health_dmgTracker #_forEachIndex) params ["_currentDamage", "_damageAlpha"];

    if (KTWK_aceMedical) then {
        // ACE
        // Update body part color based on blood loss and damage
        _bloodLoss = _bodyPartBloodLoss select _forEachIndex;
        _damage = _bodyPartDamage select _forEachIndex;
        _bodyPartColor = if (_bloodLoss > 0) then {
            [_bloodLoss] call ace_medical_gui_fnc_bloodLossToRGBA;
        } else {
            switch (true) do { // torso damage threshold doesn't need scaling
                case (_forEachIndex > 3): { // legs: index 4 & 5
                    _damageThreshold = LIMPING_DAMAGE_THRESHOLD * 4;
                };
                case (_forEachIndex > 1): { // arms: index 2 & 3
                    _damageThreshold = FRACTURE_DAMAGE_THRESHOLD * 4;
                };
                case (_forEachIndex == 0): { // head: index 0
                    _damageThreshold = _damageThreshold * 1.25;
                };
                default { // torso: index 1
                    _damageThreshold = _damageThreshold * 1.5
                };
            };
            _damage = (_damage / _damageThreshold) min 1;
            [_damage] call ace_medical_gui_fnc_damageToRGBA;
        };
    } else {
        // Vanilla
        _damage = KTWK_player getHitPointDamage format ["Hit%1", KTWK_HUD_health_bodyParts #_forEachIndex];        
        _color = + ([_damage, _healthColors] call _fnc_dmgColor);
    };

    // Flash when damaged or healed
    if (_damage isEqualTo _currentDamage) then {
        // Fade out back to normal alpha
        KTWK_HUD_health_currentAlpha = (_damageAlpha - 0.005) max KTWK_HUD_health_alpha;
    } else {
        KTWK_HUD_health_currentAlpha = 1;
    };

    // Make it visible while in IMS melee mode
    if ([KTWK_player] call KTWK_fnc_inMelee) then {
        KTWK_HUD_health_currentAlpha = KTWK_HUD_health_currentAlpha max 0.5;
    };

    if (KTWK_aceMedical) then {
        _color = +_bodyPartColor;
        _color set [3, KTWK_HUD_health_currentAlpha]
    } else {
        _color pushBack KTWK_HUD_health_currentAlpha;
    };
    _ctrl ctrlSetTextColor _color;
    KTWK_HUD_health_dmgTracker set [_forEachIndex, [_damage, KTWK_HUD_health_currentAlpha]];
} forEach _ctrlIDCs;

// Global health
(KTWK_HUD_health_idcs #0) params ["_idc"];
_damage = damage KTWK_player;
_ctrl = _display displayCtrl _idc;
if (isNil {_ctrl}) exitwith {diag_log "KtweaK: HUD health dialog control not found!"};

_color = + ([_damage, _healthColors] call _fnc_dmgColor);
// Flash when damaged or healed
private _index = (count KTWK_HUD_health_dmgTracker) - 1;
_currentDamageArr = (KTWK_HUD_health_dmgTracker #_index) params ["_currentDamage", "_damageAlpha"];
if (_damage isEqualTo _currentDamage) then {
    // Fade out back to normal alpha
    KTWK_HUD_health_currentAlpha = (_damageAlpha - 0.005) max KTWK_HUD_health_alpha;
} else {
    KTWK_HUD_health_currentAlpha = 1;
};

// Make it visible while in IMS melee mode
if ([KTWK_player] call KTWK_fnc_inMelee) then {
    KTWK_HUD_health_currentAlpha = KTWK_HUD_health_currentAlpha max 0.5;
};

_color pushBack KTWK_HUD_health_currentAlpha;
_ctrl ctrlSetTextColor _color;

KTWK_HUD_health_dmgTracker set [_index, [_damage, KTWK_HUD_health_currentAlpha]];

// Outline
private _outlineAlpha = 0;
{ if ((_x #1) > _outlineAlpha) then {_outlineAlpha = (_x #1)}} forEach KTWK_HUD_health_dmgTracker;
(KTWK_HUD_health_idcs #1) params ["_idc"];
(_display displayCtrl _idc) ctrlSetTextColor [0, 0, 0 , _outlineAlpha];
