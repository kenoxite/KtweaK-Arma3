// HUD health
scriptName "Health HUD";

#include "..\control_defines.inc";

disableSerialization; 
// "KTWK_GUI_HUD_bodyHealth" cutRsc ["KTWK_GUI_Display_HUD_bodyHealth", "PLAIN"];
("KTWK_GUI_HUD_bodyHealth" call BIS_fnc_rscLayer) cutRsc ["KTWK_GUI_Dialog_HUD_bodyHealth","PLAIN", 0, false]; 

private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth"; 

_ctrl = (_display displayCtrl IDC_GRP_HUD_BODYHEALTH);
_ctrl ctrlShow true;
_ctrlx = SafeZoneX + (SafeZoneW - (4 * pixelGridNoUIScale * pixelW));
_ctrly = SafeZoneY + (SafeZoneH - (9 * pixelGridNoUIScale * pixelH));
_ctrlWidth = 4 * pixelGridNoUIScale * pixelW;
_ctrlHeight = 8 * pixelGridNoUIScale * pixelH;
_ctrl ctrlSetPosition [ _ctrlx, _ctrly, _ctrlWidth, _ctrlHeight];
_ctrl ctrlCommit 0;

// Background and foreground
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_BG1);
// _img = "kTweaks\img\bodyparts\bodyicon_parts_base.paa";
_img = "";
_ctrl ctrlSetText _img;

_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_FG1);
_img = "kTweaks\img\bodyparts\bodyicon_outline.paa";
_ctrl ctrlSetText _img;

// Head
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_HEAD);
_img = "kTweaks\img\bodyparts\bodyicon_parts_head.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_FACE);
_img = "kTweaks\img\bodyparts\bodyicon_parts_face.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_NECK);
_img = "kTweaks\img\bodyparts\bodyicon_parts_neck.paa";
_ctrl ctrlSetText _img;

// Torso
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_CHEST);
_img = "kTweaks\img\bodyparts\bodyicon_parts_chest.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_DIAPHRAGM);
_img = "kTweaks\img\bodyparts\bodyicon_parts_diaphragm.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_ABDOMEN);
_img = "kTweaks\img\bodyparts\bodyicon_parts_abdomen.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_PELVIS);
_img = "kTweaks\img\bodyparts\bodyicon_parts_pelvis.paa";
_ctrl ctrlSetText _img;

// Arms
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_ARMS);
_img = "kTweaks\img\bodyparts\bodyicon_parts_arms.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_HANDS);
_img = "kTweaks\img\bodyparts\bodyicon_parts_hands.paa";
_ctrl ctrlSetText _img;

// Legs
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_LEGS);
_img = "kTweaks\img\bodyparts\bodyicon_parts_legs.paa";
_ctrl ctrlSetText _img;

// Body
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_BODY);
_img = "kTweaks\img\bodyparts\bodyicon_parts_body.paa";
_ctrl ctrlSetText _img;

KTWK_HUD_health_alpha = 0;
KTWK_HUD_health_alphaTemp = KTWK_HUD_health_alpha;
// KTWK_HUD_health_opt_ColorHealthy = [0.5,0.5,0.5];  // Healthy
// KTWK_HUD_health_opt_ColorLightWound = [1,1,0];  // Lightly damaged
// KTWK_HUD_health_opt_ColorModerateWound = [1,0.5,0];  // Moderately damaged
// KTWK_HUD_health_opt_ColorSevereWound = [0.6,0,0];  // Severely damaged

KTWK_player = player;
KTWK_HUD_inventoryOpened = false;

KTWK_HUD_health_dmgTracker = [];
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
// Fill the array with default values
{KTWK_HUD_health_dmgTracker pushback [0, KTWK_HUD_health_alpha]} forEach _bodyParts;

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

// Display full HUD while in inventory
KTWK_fnc_InventoryEH = {
    params [["_player", call KTWK_fnc_playerUnit]];
    KTWK_HUD_health_EH_InventoryOpened = _player addEventHandler ["InventoryOpened", {
        if (!KTWK_HUD_health_opt_enabled || !KTWK_HUD_health_opt_showInv) exitwith {false};
        params ["_unit", "_container"];
        [] spawn {
            waitUntil {!isNull (findDisplay 602)}; // Wait until the right dialog is really open
            // Display health HUD
            KTWK_HUD_health_alpha = 0.6;
            KTWK_HUD_inventoryOpened = true;
            (_this#0) addEventHandler ["InventoryClosed", {
                KTWK_HUD_health_alpha = 0;
                KTWK_HUD_health_alphaTemp = 0;
                KTWK_HUD_inventoryOpened = false;
                {if ((_x #0) == 0) then {_x set [1, 0]} else {_x set [1, (_x #0) max 0.6]}} forEach KTWK_HUD_health_dmgTracker;
                (_this#0) removeEventHandler ["InventoryClosed", _thisEventHandler];
            }];
        };
    }];
};

KTWK_fnc_resetHUD = {
    KTWK_HUD_inventoryOpened = false;
    KTWK_HUD_health_alpha = 0;
    KTWK_HUD_health_alphaTemp = 0;
};

[KTWK_player] call KTWK_fnc_InventoryEH;

while {true} do {
    private _ctrl = (_display displayCtrl IDC_GRP_HUD_BODYHEALTH);
    private _playerUnit = call KTWK_fnc_playerUnit;
    if (KTWK_player != call KTWK_fnc_playerUnit) then {
        KTWK_player = _playerUnit;
        call KTWK_fnc_resetHUD;
        [KTWK_player] call KTWK_fnc_InventoryEH;
    };
    if (!KTWK_HUD_health_opt_enabled || !alive KTWK_player || !(KTWK_player isKindOf "CAManBase") || (!KTWK_HUD_health_opt_showInjured && !KTWK_HUD_inventoryOpened)) then {
        _ctrl ctrlShow false;
        sleep 1;
        continue
    };

    _ctrl ctrlShow true;
    for "_i" from 0 to (count _bodyParts - 1) do {
        private _part = _bodyParts select _i;
        private _dmg = _playerUnit getHitPointDamage format ["Hit%1", _part];

        private _ctrl = _display displayCtrl (_ctrlIDCs #_i);
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
        if ([_playerUnit] call KTWK_fnc_inMelee) then {
            KTWK_HUD_health_alphaTemp = KTWK_HUD_health_alphaTemp max 0.5;
        };

        _color pushBack KTWK_HUD_health_alphaTemp;
        _ctrl ctrlSetTextColor _color;

        KTWK_HUD_health_dmgTracker set [_i, [_dmg, KTWK_HUD_health_alphaTemp]];

        // Outline
        private _outlineAlpha = 0;
        { if ((_x #1) > _outlineAlpha) then {_outlineAlpha = (_x #1)}} forEach KTWK_HUD_health_dmgTracker;
        _ctrl = _display displayCtrl IDC_IMG_HUD_HEALTH_FG1;
        _ctrl ctrlSetTextColor [0, 0, 0 , _outlineAlpha];

    };

    sleep 0.05;
};

