// KTWK_DFB_fnc_initGlobals
// Initializes all global variables for the Bodypart HUD subsystem
//
// Parameters:
//   None
// Returns:
//   Nothing

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_DFB_ktweak = isClass (_cfgPatches >> "ktweak");

if (isNil "KTWK_aceMedical") then {
    KTWK_aceMedical = isClass (_cfgPatches >> "ace_medical_engine");
};

_cfgPatches = nil;

// Player reference
if (!KTWK_DFB_ktweak) then {
    KTWK_player = [] call KTWK_DFB_fnc_getPlayer;
    KTWK_lastPlayer = KTWK_player;
};

// System active state
KTWK_DFB_isActive = KTWK_DFB_opt_enabled;

// HUD state
KTWK_DFB_targetAlpha = KTWK_DFB_opt_alpha;
KTWK_DFB_displayAlpha = 0;
KTWK_DFB_invOpened = false;
KTWK_DFB_EH_invOpened = -1;
KTWK_DFB_pfh = nil;

// Damage tracking
KTWK_DFB_dmgTracker = [];
KTWK_DFB_bodyParts = [];
KTWK_DFB_idcs = [];
