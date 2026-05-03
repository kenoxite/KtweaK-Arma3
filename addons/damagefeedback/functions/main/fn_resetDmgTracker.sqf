// KTWK_DFB_fnc_resetDmgTracker
// Resets the damage tracker array to default values
//
// Parameters:
//   None
// Returns:
//   Nothing

KTWK_DFB_dmgTracker = [];

{
    KTWK_DFB_dmgTracker pushBack [0, KTWK_DFB_opt_alpha];
} forEach KTWK_DFB_bodyParts;

// Global health
KTWK_DFB_dmgTracker pushBack [0, KTWK_DFB_opt_alpha];
