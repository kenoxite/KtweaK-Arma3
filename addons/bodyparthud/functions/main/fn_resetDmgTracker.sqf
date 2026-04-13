// KTWK_BPH_fnc_resetDmgTracker
// Resets the damage tracker array to default values
//
// Parameters:
//   None
// Returns:
//   Nothing

KTWK_BPH_dmgTracker = [];

{
    KTWK_BPH_dmgTracker pushBack [0, KTWK_BPH_opt_alpha];
} forEach KTWK_BPH_bodyParts;

// Global health
KTWK_BPH_dmgTracker pushBack [0, KTWK_BPH_opt_alpha];
