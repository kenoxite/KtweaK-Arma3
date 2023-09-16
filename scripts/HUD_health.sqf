// HUD health - Init
scriptName "Health HUD";
#include "..\control_defines.inc";

// ----------------------------
// FUNCTIONS

// Display full HUD while in inventory
KTWK_fnc_HUD_health_InvEH = {
    params [["_player", call KTWK_fnc_playerUnit]];
    KTWK_HUD_health_EH_InvOpened = _player addEventHandler ["InventoryOpened", {
        if (!KTWK_HUD_health_opt_enabled || !KTWK_HUD_health_opt_showInv) exitwith {false};
        params ["_unit", "_container"];
        KTWK_HUD_health_invOpened = true;
        _this spawn {
            waitUntil {!isNull (findDisplay 602)}; // Wait until the inventory is opened
            // Display health HUD
            KTWK_HUD_health_alpha = 0.6;
            (_this#0) addEventHandler ["InventoryClosed", {
                KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
                KTWK_HUD_health_alphaTemp = 0;
                KTWK_HUD_health_invOpened = false;
                {if ((_x #0) == 0) then {_x set [1, 0]} else {_x set [1, (_x #0) max 0.6]}} forEach KTWK_HUD_health_dmgTracker;
                (_this#0) removeEventHandler ["InventoryClosed", _thisEventHandler];
            }];
        };
    }];
};

KTWK_fnc_HUD_health_resetDmgTracker = {
    KTWK_HUD_health_dmgTracker = [];
    {KTWK_HUD_health_dmgTracker pushback [0, KTWK_HUD_health_opt_alpha]} forEach KTWK_HUD_health_bodyParts; 
};

KTWK_fnc_HUD_health_reset = {
    params ["_display"];
    KTWK_HUD_health_invOpened = false;
    KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
    KTWK_HUD_health_alphaTemp = 0;
    call KTWK_fnc_HUD_health_resetDmgTracker;
    call KTWK_fnc_HUD_health_update;
};

KTWK_fnc_HUD_health_update = {
    #include "..\control_defines.inc";
    disableSerialization;
    private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth";
    for "_i" from 0 to (count KTWK_HUD_health_bodyParts - 1) do {
        private _part = KTWK_HUD_health_bodyParts select _i;
        private _dmg = KTWK_HUD_health_player getHitPointDamage format ["Hit%1", _part];

        private _ctrl = _display displayCtrl (KTWK_HUD_health_ctrlIDCs #_i);
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

        // Outline
        private _outlineAlpha = 0;
        { if ((_x #1) > _outlineAlpha) then {_outlineAlpha = (_x #1)}} forEach KTWK_HUD_health_dmgTracker;
        _ctrl = _display displayCtrl IDC_IMG_HUD_HEALTH_FG1;
        _ctrl ctrlSetTextColor [0, 0, 0 , _outlineAlpha];
    };
};
/*
Common IDDs:

    46: Mission display
    312: Zeus display
    49: Pause menu
    602: Inventory
    24: Chat box
    300: Weapon state
    12: Map
    160: UAV Terminal
*/

KTWK_fnc_HUD_health_moveDialog = {
    // Make HUD visible while moving
    KTWK_HUD_health_alpha = 1;
    disableSerialization;
    private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth";
    private _ctrl = _display displayCtrl 30000;
    _ctrl ctrlSetPosition[
        SafeZoneX + (SafeZoneW - ((3.5 + KTWK_HUD_health_opt_xPos) * pixelGridNoUIScale * pixelW)),
        SafeZoneY + (SafeZoneH - ((7.4 + KTWK_HUD_health_opt_yPos) * pixelGridNoUIScale * pixelH)),
        4 * pixelGridNoUIScale * pixelW,
        8 * pixelGridNoUIScale * pixelH 
    ]; 
    _ctrl ctrlCommit 0;
    // Reset HUD to default alpha
    call KTWK_fnc_HUD_health_update;
    0 spawn {
        waituntil {IsNull (findDisplay 49)};
        KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
        call KTWK_fnc_HUD_health_update;
    };
};

KTWK_fnc_HUD_health_resetDialogPos = {
    KTWK_HUD_health_opt_xPos = 0;
    KTWK_HUD_health_opt_yPos = 0;
    disableSerialization;
    private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth";
    private _ctrl = _display displayCtrl 30000;
    _ctrl ctrlSetPosition[
        SafeZoneX + (SafeZoneW - ((4 + KTWK_HUD_health_opt_xPos) * pixelGridNoUIScale * pixelW)),
        SafeZoneY + (SafeZoneH - ((9 + KTWK_HUD_health_opt_yPos) * pixelGridNoUIScale * pixelH)),
        4 * pixelGridNoUIScale * pixelW,
        8 * pixelGridNoUIScale * pixelH 
    ]; 
    _ctrl ctrlCommit 0;
};


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
KTWK_HUD_health_ctrlIDCs = [
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
            while {!alive player} do {
                sleep 0.5;
            };
        };
        // Just restart the damn thing to avoid all the headaches I'm having when switching units
        KTWK_scr_HUD_health = [] execVM "kTweaks\scripts\HUD_health.sqf";
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
