// HUD health - Init
scriptName "Health HUD";
#include "..\control_defines.inc";

// ----------------------------
// INIT HUD DISPLAY
disableSerialization; 
("KTWK_GUI_HUD_bodyHealth" call BIS_fnc_rscLayer) cutRsc ["KTWK_GUI_Dialog_HUD_bodyHealth","PLAIN", 0, false]; 
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
_img = "";
_ctrl ctrlSetText _img;

_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_FG1);
_img = "KtweaK\img\bodyparts\bodyicon_outline.paa";
_ctrl ctrlSetText _img;

// Head
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_HEAD);
_img = "KtweaK\img\bodyparts\bodyicon_parts_head.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_FACE);
_img = "KtweaK\img\bodyparts\bodyicon_parts_face.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_NECK);
_img = "KtweaK\img\bodyparts\bodyicon_parts_neck.paa";
_ctrl ctrlSetText _img;

// Torso
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

// Arms
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_ARMS);
_img = "KtweaK\img\bodyparts\bodyicon_parts_arms.paa";
_ctrl ctrlSetText _img;
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_HANDS);
_img = "KtweaK\img\bodyparts\bodyicon_parts_hands.paa";
_ctrl ctrlSetText _img;

// Legs
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_LEGS);
_img = "KtweaK\img\bodyparts\bodyicon_parts_legs.paa";
_ctrl ctrlSetText _img;

// Body
_ctrl = (_display displayCtrl IDC_IMG_HUD_HEALTH_BODY);
_img = "KtweaK\img\bodyparts\bodyicon_parts_body.paa";
_ctrl ctrlSetText _img;

// ----------------------------
// GLOBAL VARS
KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
KTWK_HUD_health_alphaTemp = KTWK_HUD_health_alpha;
KTWK_HUD_health_player = call KTWK_fnc_playerUnit;
KTWK_HUD_health_invOpened = false;
KTWK_HUD_health_bodyParts = [
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
KTWK_HUD_health_dmgTracker = [];
KTWK_HUD_health_EH_InvOpened = -1;


// ----------------------------
// INIT
call KTWK_fnc_HUD_health_resetDmgTracker;
[KTWK_HUD_health_player] call KTWK_fnc_HUD_health_InvEH;
call KTWK_fnc_HUD_health_moveDialog;

// ----------------------------
// MAIN LOOP
private _ctrl = (_display displayCtrl IDC_GRP_HUD_BODYHEALTH);
while {true} do {
    private _playerUnit = call KTWK_fnc_playerUnit; // Check for the current player unit
    private _isAlive = alive KTWK_HUD_health_player;    // Check if the previously stored player unit is alive
    if (KTWK_HUD_health_player != call KTWK_fnc_playerUnit || !_isAlive) then {
        // If stored player unit isn't the same as the current one, the player has switched unit, so let's clean up a bit
        KTWK_HUD_health_player removeEventHandler ["InventoryOpened", KTWK_HUD_health_EH_InvOpened];   // Remove EH from old unit
        // Wait until respawn or team switch if dead
        if (!_isAlive) then {
            // Display health HUD
            KTWK_HUD_health_alpha = 0.6;
            while {!alive player} do {
                sleep 0.5;
            };
        };
        // Just restart the damn thing to avoid all the headaches I'm having when switching units
        KTWK_scr_HUD_health = [] execVM "KtweaK\scripts\HUD_health.sqf";
        break;
    };
    if (!KTWK_HUD_health_opt_enabled || !(KTWK_HUD_health_player isKindOf "CAManBase") || (!KTWK_HUD_health_opt_showInjured && !KTWK_HUD_health_invOpened)) then {
        _ctrl ctrlShow false;
        sleep 1;
        continue
    };

    _ctrl ctrlShow true;
    call KTWK_fnc_HUD_health_update;

    sleep 0.05;
};
