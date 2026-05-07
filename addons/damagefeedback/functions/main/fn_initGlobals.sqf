// KTWK_DFB_fnc_initGlobals
// Initializes all global variables for the Damage Feedback subsystem
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\damagefeedback\idc.hpp"
#include "\z\ktweak\addons\damagefeedback\ace.hpp"

// diag_log "[DFB] Init globals";

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_DFB_ktweak = isClass (_cfgPatches >> "ktweak");

if (isNil "KTWK_aceMedical") then {
    KTWK_aceMedical = isClass (_cfgPatches >> "ace_medical_engine");
};

_cfgPatches = nil;

// System active state
KTWK_DFB_isActive = KTWK_DFB_opt_enabled;

// HUD state
KTWK_DFB_desiredAlpha = KTWK_DFB_opt_alpha;
KTWK_DFB_currentAlpha = 0;
KTWK_DFB_invOpened = false;

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

call KTWK_DFB_fnc_resetDmgTracker;

// Define IDC mappings
KTWK_DFB_idcs = call {
    if (KTWK_aceMedical) exitWith {
        [
            [IDC_DFB_GLOBAL, "health"],
            [IDC_DFB_OUTLINE, "outline"],
            [IDC_DFB_HEAD, "parts_grp_head"],
            [IDC_DFB_TORSO, "parts_grp_torso"],
            [IDC_DFB_LEFTARM, "parts_armleft"],
            [IDC_DFB_RIGHTARM, "parts_armright"],
            [IDC_DFB_LEFTLEG, "parts_legleft"],
            [IDC_DFB_RIGHTLEG, "parts_legright"]
        ]
    };
    [
        [IDC_DFB_GLOBAL, "health"],
        [IDC_DFB_OUTLINE, "outline"],
        [IDC_DFB_BODY, "parts_body"],
        [IDC_DFB_HEAD, "parts_head"],
        [IDC_DFB_FACE, "parts_face"],
        [IDC_DFB_NECK, "parts_neck"],
        [IDC_DFB_CHEST, "parts_chest"],
        [IDC_DFB_DIAPHRAGM, "parts_diaphragm"],
        [IDC_DFB_ABDOMEN, "parts_abdomen"],
        [IDC_DFB_PELVIS, "parts_pelvis"],
        [IDC_DFB_ARMS, "parts_arms"],
        [IDC_DFB_HANDS, "parts_hands"],
        [IDC_DFB_LEGS, "parts_legs"]
    ]
};
