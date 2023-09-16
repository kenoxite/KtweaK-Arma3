// Update the HUD health display

#include "..\..\control_defines.inc";

// Skip if mission isn't ready yet
if (isNull findDisplay 46) exitWith {};

disableSerialization;
private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth";
if (isNil {_display}) exitwith {diag_log "KtweaK: HUD health display not defined!"};
if (isNull _display) exitwith {diag_log "KtweaK: HUD health display not found!"};

if (isNil {KTWK_HUD_health_alpha}) then { KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha; };
if (isNil {KTWK_HUD_health_alphaTemp}) then { KTWK_HUD_health_alphaTemp = KTWK_HUD_health_alpha; };
if (isNil {KTWK_HUD_health_player}) then { KTWK_HUD_health_player = call KTWK_fnc_playerUnit; };
if (isNil {KTWK_HUD_health_dmgTracker}) then { KTWK_HUD_health_dmgTracker = []; };

private _bodyParts = [
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
private _ctrlIDCs = [
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
for "_i" from 0 to (count _bodyParts - 1) do {
    private _part = _bodyParts select _i;
    private _dmg = KTWK_HUD_health_player getHitPointDamage format ["Hit%1", _part];

    private _ctrl = _display displayCtrl (_ctrlIDCs #_i);
    if (isNil {_ctrl}) exitwith {diag_log "KtweaK: HUD health dialog control not found!"};
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
    private _color = +_healthColors #_healthStatus;

    // Flash when damaged or healed
    if (_dmg isEqualTo ((KTWK_HUD_health_dmgTracker #_i) #0)) then {
        // Fade out back to normal alpha
        KTWK_HUD_health_alphaTemp = (((KTWK_HUD_health_dmgTracker #_i) #1) - 0.005) max KTWK_HUD_health_alpha;
    } else {
        KTWK_HUD_health_alphaTemp = 1;
    };

    // Make it visible while in IMS melee mode
    if ([KTWK_HUD_health_player] call KTWK_fnc_inMelee) then {
        KTWK_HUD_health_alphaTemp = KTWK_HUD_health_alphaTemp max 0.5;
    };

    _color pushBack KTWK_HUD_health_alphaTemp;
    _ctrl ctrlSetTextColor _color;

    KTWK_HUD_health_dmgTracker set [_i, [_dmg, KTWK_HUD_health_alphaTemp]];
};

// Outline
private _outlineAlpha = 0;
{ if ((_x #1) > _outlineAlpha) then {_outlineAlpha = (_x #1)}} forEach KTWK_HUD_health_dmgTracker;
private _ctrl = _display displayCtrl IDC_IMG_HUD_HEALTH_FG1;
_ctrl ctrlSetTextColor [0, 0, 0 , _outlineAlpha];
