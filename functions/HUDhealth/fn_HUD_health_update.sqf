// Update the HUD health display

#include "..\..\control_defines.inc";

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

private _bodyParts = call {
    if (KTWK_aceMedical) exitWith {
        ALL_BODY_PARTS
    };
    [
        "Body",
        "Head",
        "Face",
        "Neck",
        "Chest",
        "Diaphragm",
        "Abdomen",
        "Pelvis",
        "Arms",
        "Hands",
        "Legs"
    ];
};

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

private _ctrlIDCs = call {
    if (KTWK_aceMedical) exitWith {
        [
            IDC_IMG_HUD_HEALTH_GRP_HEAD,
            IDC_IMG_HUD_HEALTH_GRP_TORSO,
            IDC_IMG_HUD_HEALTH_LEFTARM,
            IDC_IMG_HUD_HEALTH_RIGHTARM,
            IDC_IMG_HUD_HEALTH_LEFTLEG,
            IDC_IMG_HUD_HEALTH_RIGHTLEG
        ];
    };
    [
        IDC_IMG_HUD_HEALTH_BODY,
        IDC_IMG_HUD_HEALTH_HEAD,
        IDC_IMG_HUD_HEALTH_FACE,
        IDC_IMG_HUD_HEALTH_NECK,

        IDC_IMG_HUD_HEALTH_CHEST,
        IDC_IMG_HUD_HEALTH_DIAPHRAGM,
        IDC_IMG_HUD_HEALTH_ABDOMEN,
        IDC_IMG_HUD_HEALTH_PELVIS,

        IDC_IMG_HUD_HEALTH_ARMS,
        IDC_IMG_HUD_HEALTH_HANDS,

        IDC_IMG_HUD_HEALTH_LEGS
    ];
};

private _fnc_dmgColor = {
    params ["_dmg"];
    private _healthStatus = call {
        if (_dmg <= 0.1) exitWith { 0 };
        if (_dmg > 0.1 && _dmg <= 0.3) exitWith { 1 };
        if (_dmg > 0.3 && _dmg <= 0.7) exitWith { 2 };
        if (_dmg > 0.7) exitWith { 3 };
    };
    private _healthColors = [
        KTWK_HUD_health_opt_ColorHealthy,
        KTWK_HUD_health_opt_ColorLightWound,
        KTWK_HUD_health_opt_ColorModerateWound,
        KTWK_HUD_health_opt_ColorSevereWound
    ];
   _healthColors #_healthStatus
};

call {
    // ACE
    if (KTWK_aceMedical) exitWith {
        {
            _x params ["_bodyPartIDC"];
            private _ctrl = _display displayCtrl (_ctrlIDCs #_forEachIndex);
            if (isNil {_ctrl}) exitwith {diag_log "KtweaK: HUD health dialog control not found!"};

            // Update body part color based on blood loss and damage
            private _bloodLoss = _bodyPartBloodLoss select _forEachIndex;
            private _damage = _bodyPartDamage select _forEachIndex;
            private _bodyPartColor = if (_bloodLoss > 0) then {
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

            // Flash when damaged or healed
            if (_damage isEqualTo ((KTWK_HUD_health_dmgTracker #_forEachIndex) #0)) then {
                // Fade out back to normal alpha
                KTWK_HUD_health_currentAlpha = (((KTWK_HUD_health_dmgTracker #_forEachIndex) #1) - 0.005) max KTWK_HUD_health_alpha;
            } else {
                KTWK_HUD_health_currentAlpha = 1;
            };

            // Make it visible while in IMS melee mode
            if ([KTWK_player] call KTWK_fnc_inMelee) then {
                KTWK_HUD_health_currentAlpha = KTWK_HUD_health_currentAlpha max 0.5;
            };

            private _color = +_bodyPartColor;   // Ok ace... whatevs
            _color set [3, KTWK_HUD_health_currentAlpha];
            _ctrl ctrlSetTextColor _color;

            KTWK_HUD_health_dmgTracker set [_forEachIndex, [_damage, KTWK_HUD_health_currentAlpha]];
        } forEach _ctrlIDCs;
    };

    // Vanilla
    for "_i" from 0 to (count _bodyParts - 1) do {
        private _part = _bodyParts select _i;
        private _dmg = KTWK_player getHitPointDamage format ["Hit%1", _part];

        private _ctrl = _display displayCtrl (_ctrlIDCs #_i);
        if (isNil {_ctrl}) exitwith {diag_log "KtweaK: HUD health dialog control not found!"};
        
        private _color = + ([_dmg] call _fnc_dmgColor);

        // Flash when damaged or healed
        if (_dmg isEqualTo ((KTWK_HUD_health_dmgTracker #_i) #0)) then {
            // Fade out back to normal alpha
            KTWK_HUD_health_currentAlpha = (((KTWK_HUD_health_dmgTracker #_i) #1) - 0.005) max KTWK_HUD_health_alpha;
        } else {
            KTWK_HUD_health_currentAlpha = 1;
        };

        // Make it visible while in IMS melee mode
        if ([KTWK_player] call KTWK_fnc_inMelee) then {
            KTWK_HUD_health_currentAlpha = KTWK_HUD_health_currentAlpha max 0.5;
        };

        _color pushBack KTWK_HUD_health_currentAlpha;
        _ctrl ctrlSetTextColor _color;

        KTWK_HUD_health_dmgTracker set [_i, [_dmg, KTWK_HUD_health_currentAlpha]];
    };
};

// Global health
private _dmg = damage KTWK_player;
private _ctrl = _display displayCtrl IDC_IMG_HUD_HEALTH_BG1;
if (isNil {_ctrl}) exitwith {diag_log "KtweaK: HUD health dialog control not found!"};

private _color = + ([_dmg] call _fnc_dmgColor);
// Flash when damaged or healed
private _index = (count KTWK_HUD_health_dmgTracker) - 1;
if (_dmg isEqualTo ((KTWK_HUD_health_dmgTracker #_index) #0)) then {
    // Fade out back to normal alpha
    KTWK_HUD_health_currentAlpha = (((KTWK_HUD_health_dmgTracker #_index) #1) - 0.005) max KTWK_HUD_health_alpha;
} else {
    KTWK_HUD_health_currentAlpha = 1;
};

// Make it visible while in IMS melee mode
if ([KTWK_player] call KTWK_fnc_inMelee) then {
    KTWK_HUD_health_currentAlpha = KTWK_HUD_health_currentAlpha max 0.5;
};

_color pushBack KTWK_HUD_health_currentAlpha;
_ctrl ctrlSetTextColor _color;

KTWK_HUD_health_dmgTracker set [_index, [_dmg, KTWK_HUD_health_currentAlpha]];

// Outline
private _outlineAlpha = 0;
{ if ((_x #1) > _outlineAlpha) then {_outlineAlpha = (_x #1)}} forEach KTWK_HUD_health_dmgTracker;
private _ctrl = _display displayCtrl IDC_IMG_HUD_HEALTH_FG1;
_ctrl ctrlSetTextColor [0, 0, 0 , _outlineAlpha];
