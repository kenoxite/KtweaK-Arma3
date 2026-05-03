// KTWK_DFB_fnc_initSystem
// Bodypart HUD - Initialization and main loop
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\damagefeedback\idc.hpp"
#include "\z\ktweak\addons\damagefeedback\ace.hpp"

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Check if system is enabled by setting
if (!KTWK_DFB_opt_enabled) exitWith {
    if (!isNil "KTWK_DFB_pfh") then {
        call KTWK_DFB_fnc_disableSystem;
    };
};

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

if (isNil "KTWK_DFB_EH_playerViewChanged") then {
    KTWK_DFB_EH_playerViewChanged = addMissionEventHandler ["PlayerViewChanged", {
        params ["_previousUnit", "_newUnit", "_vehicleIn","_oldCameraOn", "_newCameraOn", "_uav"];
        if (!KTWK_DFB_ktweak) then {
            KTWK_player = [] call KTWK_DFB_fnc_getPlayer;
            KTWK_lastPlayer = KTWK_player;
        };
        missionNamespace setVariable ["KTWK_DFB_invOpened", false];
        call KTWK_DFB_fnc_resetDmgTracker;
    }];
};

// Define body parts based on medical system
KTWK_DFB_bodyParts = call {
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

KTWK_DFB_dmgTracker = [];
KTWK_DFB_EH_invOpened = -1;

// Define IDC mappings
KTWK_DFB_idcs = call {
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

// Wait for main display
[{
    !isNull findDisplay 46
}, {
    // Display is ready, continue initialization
    private _display = uiNamespace getVariable ["BPH_Display", displayNull];
    if (isNull _display) exitWith { diag_log "Bodypart HUD: Display disappeared before init"; };

    [_display, KTWK_DFB_idcs, true] call KTWK_DFB_fnc_drawHUD;
    call KTWK_DFB_fnc_resetDmgTracker;
    call KTWK_DFB_fnc_moveDialog;
    call KTWK_DFB_fnc_createPfh;
    
    KTWK_DFB_isActive = true;
}] call CBA_fnc_waitUntilAndExecute;
