// KTWK_BPH_fnc_reset
// Resets the display of the HUD to default state
//
// Parameters:
//   None
// Returns:
//   Nothing

KTWK_BPH_invOpened = false;
KTWK_BPH_alpha = KTWK_BPH_opt_alpha;
KTWK_BPH_currentAlpha = 0;

call KTWK_BPH_fnc_resetDmgTracker;
call KTWK_BPH_fnc_update;
