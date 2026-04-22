// KTWK_BPH_fnc_initGlobals
// Initializes all global variables for the Bodypart HUD subsystem
//
// Parameters:
//   None
// Returns:
//   Nothing

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_BPH_ktweak = isClass (_cfgPatches >> "ktweak");

if (isNil "KTWK_aceMedical") then {
    KTWK_aceMedical = isClass (_cfgPatches >> "ace_medical_engine");
};

_cfgPatches = nil;

// Player reference
if (!KTWK_BPH_ktweak) then {
    KTWK_player = call CBA_fnc_currentUnit;
};

// System active state
KTWK_BPH_isActive = KTWK_BPH_opt_enabled;

// HUD state
KTWK_BPH_targetAlpha = KTWK_BPH_opt_alpha;
KTWK_BPH_displayAlpha = 0;
KTWK_BPH_invOpened = false;
KTWK_BPH_EH_invOpened = -1;
KTWK_BPH_pfh = nil;

// Damage tracking
KTWK_BPH_dmgTracker = [];
KTWK_BPH_bodyParts = [];
KTWK_BPH_idcs = [];
