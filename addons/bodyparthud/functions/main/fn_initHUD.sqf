// KTWK_BPH_fnc_initHUD
// Bodypart HUD - Initialization and main loop
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\bodyparthud\idc.hpp"
#include "\z\ktweak\addons\bodyparthud\ace.hpp"

// Only run on clients with interface
if (!hasInterface) exitWith {};

disableSerialization;

// Create HUD display
("BPH_Layer" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
("BPH_Layer" call BIS_fnc_rscLayer) cutRsc ["BPH_Dialog", "PLAIN", 0, false];

private _display = uiNamespace getVariable ["BPH_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "Bodypart HUD: Failed to create display!";
};

private _ctrl = _display displayCtrl IDC_BPH_GROUP;
_ctrl ctrlShow true;

private _ctrlX = safeZoneX + (safeZoneW - (4 * pixelGridNoUIScale * pixelW));
private _ctrlY = safeZoneY + (safeZoneH - (9 * pixelGridNoUIScale * pixelH));
private _ctrlWidth = 4 * pixelGridNoUIScale * pixelW;
private _ctrlHeight = 8 * pixelGridNoUIScale * pixelH;

_ctrl ctrlSetPosition [_ctrlX, _ctrlY, _ctrlWidth, _ctrlHeight];
_ctrl ctrlCommit 0;

// Initialize globals
KTWK_BPH_alpha = KTWK_BPH_opt_alpha;
KTWK_BPH_currentAlpha = 0;
KTWK_player = call CBA_fnc_currentUnit;
KTWK_BPH_invOpened = false;

// Define body parts based on medical system
KTWK_BPH_bodyParts = call {
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

KTWK_BPH_dmgTracker = [];
KTWK_BPH_EH_invOpened = -1;

// Define IDC mappings
KTWK_BPH_idcs = call {
    if (KTWK_aceMedical) exitWith {
        [
            [IDC_BPH_GLOBAL, "health"],
            [IDC_BPH_OUTLINE, "outline"],
            [IDC_BPH_HEAD, "parts_grp_head"],
            [IDC_BPH_TORSO, "parts_grp_torso"],
            [IDC_BPH_LEFTARM, "parts_armleft"],
            [IDC_BPH_RIGHTARM, "parts_armright"],
            [IDC_BPH_LEFTLEG, "parts_legleft"],
            [IDC_BPH_RIGHTLEG, "parts_legright"]
        ]
    };
    [
        [IDC_BPH_GLOBAL, "health"],
        [IDC_BPH_OUTLINE, "outline"],
        [IDC_BPH_BODY, "parts_body"],
        [IDC_BPH_HEAD, "parts_head"],
        [IDC_BPH_FACE, "parts_face"],
        [IDC_BPH_NECK, "parts_neck"],
        [IDC_BPH_CHEST, "parts_chest"],
        [IDC_BPH_DIAPHRAGM, "parts_diaphragm"],
        [IDC_BPH_ABDOMEN, "parts_abdomen"],
        [IDC_BPH_PELVIS, "parts_pelvis"],
        [IDC_BPH_ARMS, "parts_arms"],
        [IDC_BPH_HANDS, "parts_hands"],
        [IDC_BPH_LEGS, "parts_legs"]
    ]
};

// Internal function to draw HUD elements
KTWK_BPH_fnc_drawHUD = {
    params ["_display", ["_idcArr", []], ["_on", true]];
    
    if (_idcArr isEqualTo []) exitWith {false};
    
    {
        _x params ["_idc", "_img"];
        private _ctrl = _display displayCtrl _idc;
        private _path = if (_on) then {
            format ["\z\ktweak\addons\bodyparthud\img\bodyparts\bodyicon_%1.paa", _img]
        } else {
            ""
        };
        _ctrl ctrlSetText _path;
    } forEach _idcArr;
    
    true
};

// Wait for main display
waitUntil {sleep 1; !isNull findDisplay 46};

// Initial setup
[_display, KTWK_BPH_idcs, true] call KTWK_BPH_fnc_drawHUD;
call KTWK_BPH_fnc_resetDmgTracker;
[KTWK_player] call KTWK_BPH_fnc_invEH;
call KTWK_BPH_fnc_moveDialog;

// Main PFH loop
KTWK_BPH_pfh = [{
    params ["_args", "_handle"];
    _args params ["_display", "_groupIdc"];
    
    if (isNull findDisplay 46) exitWith {};
    
    private _ctrl = _display displayCtrl _groupIdc;
    if (isNull _ctrl) then {
        diag_log "Bodypart HUD: Control not found. Shutting down.";
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    
    private _currentUnit = call CBA_fnc_currentUnit;
    private _isAlive = alive KTWK_player;
    
    if (KTWK_player isNotEqualTo _currentUnit || {!_isAlive}) then {
        [_display, KTWK_BPH_idcs, false] call KTWK_BPH_fnc_drawHUD;
        KTWK_player removeEventHandler ["InventoryOpened", KTWK_BPH_EH_invOpened];
        
        if (!_isAlive) then {
            KTWK_BPH_alpha = 0.6;
            [_handle] call CBA_fnc_removePerFrameHandler;
            [{
                alive player
            }, {
                [] call KTWK_BPH_fnc_initHUD;
            }] call CBA_fnc_waitUntilAndExecute;
        } else {
            [_handle] call CBA_fnc_removePerFrameHandler;
            [] call KTWK_BPH_fnc_initHUD;
        };
    } else {
        private _showHUD = KTWK_BPH_opt_enabled &&
            {[KTWK_player] call ([KTWK_fnc_isHuman, KTWK_BPH_fnc_isHuman] select (! KTWK_BPH_ktweak))} &&
            {(positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) <= 5} &&
            {(KTWK_BPH_opt_showInjured || {KTWK_BPH_invOpened})} &&
            {!(dialog && {!KTWK_BPH_invOpened})};
        
        _ctrl ctrlShow _showHUD;
        
        if (_showHUD) then {
            call KTWK_BPH_fnc_update;
        };
    };
}, 0.05, [_display, IDC_BPH_GROUP]] call CBA_fnc_addPerFrameHandler;
