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
KTWK_HUD_health_idcs = call {
    if (KTWK_aceMedical) exitWith {
        [
            [IDC_IMG_HUD_HEALTH_BG1, "health"],
            [IDC_IMG_HUD_HEALTH_FG1, "outline"],
            [IDC_IMG_HUD_HEALTH_GRP_HEAD, "parts_grp_head"],
            [IDC_IMG_HUD_HEALTH_GRP_TORSO, "parts_grp_torso"],
            [IDC_IMG_HUD_HEALTH_LEFTARM, "parts_armleft"],
            [IDC_IMG_HUD_HEALTH_RIGHTARM, "parts_armright"],
            [IDC_IMG_HUD_HEALTH_LEFTLEG, "parts_legleft"],
            [IDC_IMG_HUD_HEALTH_RIGHTLEG, "parts_legright"]
        ]
    };
    [
        [IDC_IMG_HUD_HEALTH_BG1, "health"],
        [IDC_IMG_HUD_HEALTH_FG1, "outline"],
        [IDC_IMG_HUD_HEALTH_BODY, "parts_body"],
        [IDC_IMG_HUD_HEALTH_HEAD, "parts_head"],
        [IDC_IMG_HUD_HEALTH_FACE, "parts_face"],
        [IDC_IMG_HUD_HEALTH_NECK, "parts_neck"],
        [IDC_IMG_HUD_HEALTH_CHEST, "parts_chest"],
        [IDC_IMG_HUD_HEALTH_DIAPHRAGM, "parts_diaphragm"],
        [IDC_IMG_HUD_HEALTH_ABDOMEN, "parts_abdomen"],
        [IDC_IMG_HUD_HEALTH_PELVIS, "parts_pelvis"],
        [IDC_IMG_HUD_HEALTH_ARMS, "parts_arms"],
        [IDC_IMG_HUD_HEALTH_HANDS, "parts_hands"],
        [IDC_IMG_HUD_HEALTH_LEGS, "parts_legs"]
    ]
};

KTWK_fnc_HUD_health_drawHUD = {
    params ["_display", ["_idcArr", []], ["_on", true]];
    if (_idcArr isEqualTo []) exitWith {false};
    private ["_ctrl"];
    {
        _x params ["_idc", "_img"];
        _ctrl = _display displayCtrl _idc;
        _ctrl ctrlSetText (["", format ["KtweaK\img\bodyparts\bodyicon_%1.paa", _img]] select _on);
    } forEach _idcArr;
};

// ----------------------------
// INIT
waitUntil {sleep 1; !isNull findDisplay 46 };
[_display, KTWK_HUD_health_idcs, true] call KTWK_fnc_HUD_health_drawHUD;
call KTWK_fnc_HUD_health_resetDmgTracker;
[KTWK_player] call KTWK_fnc_HUD_health_InvEH;
call KTWK_fnc_HUD_health_moveDialog;

// ----------------------------
// MAIN LOOP
KTWK_HUD_health_PFH = [{
    if !(isNull findDisplay 46) then { // Skip if in intro, outro, etc
        params ["_args", "_handle"];
        _args params ["_display", "_idcGrpHudBodyHealth"];

        private _ctrl = (_display displayCtrl _idcGrpHudBodyHealth);
        if (isNil {_ctrl}) then {
            diag_log "KtweaK: Unable to find health HUD. Shutting down script.";
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        private _isAlive = alive KTWK_player;
        if (KTWK_player != call KTWK_fnc_playerUnit || !_isAlive) then {
            [_display, _idcs, false] call KTWK_fnc_HUD_health_drawHUD;
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
                ((positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) > 5) || // this should fix the problem of ui being showm in scripted camera scenes
                (!KTWK_HUD_health_opt_showInjured && !KTWK_HUD_health_invOpened) || 
                (dialog && !KTWK_HUD_health_invOpened)) then {
                _ctrl ctrlShow false;
            } else {
                _ctrl ctrlShow true;
                call KTWK_fnc_HUD_health_update;
            };
        };
    };
}, 0.05, [_display, IDC_GRP_HUD_BODYHEALTH]] call CBA_fnc_addPerFrameHandler;
