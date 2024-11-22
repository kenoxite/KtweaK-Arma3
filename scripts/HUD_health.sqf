// HUD health - Init
scriptName "Health HUD";
#include "..\control_defines.inc";

// ACE Medical
#define ALL_BODY_PARTS ["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"]

// ----------------------------
// INIT HUD DISPLAY
disableSerialization; 
("KTWK_GUI_HUD_bodyHealth" call BIS_fnc_rscLayer) cutText ["", "PLAIN"]; // Remove HUD
("KTWK_GUI_HUD_bodyHealth" call BIS_fnc_rscLayer) cutRsc ["KTWK_GUI_Dialog_HUD_bodyHealth","PLAIN", 0, false]; // Add HUD
_display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth"; 

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
// _img = "KtweaK\img\bodyparts\bodyicon_parts_base.paa";
// _img = "";
_img = "KtweaK\img\bodyparts\bodyicon_health.paa";
_ctrl ctrlSetText _img;

_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_FG1);
_img = "KtweaK\img\bodyparts\bodyicon_outline.paa";
_ctrl ctrlSetText _img;

// Head
call {
    if (KTWK_aceMedical) exitWith {
        _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_GRP_HEAD);
        _img = "KtweaK\img\bodyparts\bodyicon_parts_grp_head.paa";
        _ctrl ctrlSetText _img;
    };
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_HEAD);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_head.paa";
    _ctrl ctrlSetText _img;
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_FACE);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_face.paa";
    _ctrl ctrlSetText _img;
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_NECK);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_neck.paa";
    _ctrl ctrlSetText _img;
};

// Torso
call {
    if (KTWK_aceMedical) exitWith {
        _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_GRP_TORSO);
        _img = "KtweaK\img\bodyparts\bodyicon_parts_grp_torso.paa";
        _ctrl ctrlSetText _img;
    };
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_CHEST);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_chest.paa";
    _ctrl ctrlSetText _img;
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_DIAPHRAGM);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_diaphragm.paa";
    _ctrl ctrlSetText _img;
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_ABDOMEN);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_abdomen.paa";
    _ctrl ctrlSetText _img;
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_PELVIS);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_pelvis.paa";
    _ctrl ctrlSetText _img;
};

// Arms
call {
    if (KTWK_aceMedical) exitWith {
        _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_LEFTARM);
        _img = "KtweaK\img\bodyparts\bodyicon_parts_armleft.paa";
        _ctrl ctrlSetText _img;
        _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_RIGHTARM);
        _img = "KtweaK\img\bodyparts\bodyicon_parts_armright.paa";
        _ctrl ctrlSetText _img;
    };
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_ARMS);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_arms.paa";
    _ctrl ctrlSetText _img;
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_HANDS);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_hands.paa";
    _ctrl ctrlSetText _img;
};

// Legs
call {
    if (KTWK_aceMedical) exitWith {
        _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_LEFTLEG);
        _img = "KtweaK\img\bodyparts\bodyicon_parts_legleft.paa";
        _ctrl ctrlSetText _img;
        _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_RIGHTLEG);
        _img = "KtweaK\img\bodyparts\bodyicon_parts_legright.paa";
        _ctrl ctrlSetText _img;
    };
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_LEGS);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_legs.paa";
    _ctrl ctrlSetText _img;
};

// Body
if (!KTWK_aceMedical) then {
    _ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_BODY);
    _img = "KtweaK\img\bodyparts\bodyicon_parts_body.paa";
    _ctrl ctrlSetText _img;
};

// ----------------------------
// GLOBAL VARS
KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
KTWK_HUD_health_currentAlpha = 0;
KTWK_player = call KTWK_fnc_playerUnit;
KTWK_HUD_health_invOpened = false;
KTWK_HUD_health_bodyParts = call {
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
KTWK_HUD_health_dmgTracker = [];
KTWK_HUD_health_EH_InvOpened = -1;


// ----------------------------
// INIT
call KTWK_fnc_HUD_health_resetDmgTracker;
[KTWK_player] call KTWK_fnc_HUD_health_InvEH;
call KTWK_fnc_HUD_health_moveDialog;

// ----------------------------
// MAIN LOOP
KTWK_HUD_health_PFH = [{
    params ["_args", "_handle"];
    _args params ["_display", "_idcGrpHudBodyHealth"];

    private _ctrl = (_display displayCtrl _idcGrpHudBodyHealth);
    if (isNil {_ctrl}) then {
        diag_log "KtweaK: Unable to find health HUD. Shutting down script.";
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    private _isAlive = alive KTWK_player;
    if (KTWK_player != call KTWK_fnc_playerUnit || !_isAlive) then {
        KTWK_player removeEventHandler ["InventoryOpened", KTWK_HUD_health_EH_InvOpened];
        if (!_isAlive) then {
            KTWK_HUD_health_alpha = 0.6;
            [_handle] call CBA_fnc_removePerFrameHandler;
            [{alive player}, {
                KTWK_scr_HUD_health = [] execVM "KtweaK\scripts\HUD_health.sqf";
            }] call CBA_fnc_waitUntilAndExecute;
        } else {
            [_handle] call CBA_fnc_removePerFrameHandler;
            KTWK_scr_HUD_health = [] execVM "KtweaK\scripts\HUD_health.sqf";
        };
    } else {
        if (!KTWK_HUD_health_opt_enabled || 
            !([KTWK_player] call KTWK_fnc_isHuman) || 
            ((positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) > 5) || // this should fix the problem of ui being showm in intros and scripted camera scenes
            (!KTWK_HUD_health_opt_showInjured && !KTWK_HUD_health_invOpened) || 
            (dialog && !KTWK_HUD_health_invOpened)) then {
            _ctrl ctrlShow false;
        } else {
            _ctrl ctrlShow true;
            call KTWK_fnc_HUD_health_update;
        };
    };
}, 0.05, [_display, IDC_GRP_HUD_BODYHEALTH]] call CBA_fnc_addPerFrameHandler;

