// KTWK_DFB_fnc_reset
// Resets the display of the HUD to default state
//
// Parameters:
//   None
// Returns:
//   Nothing

KTWK_DFB_invOpened = false;
KTWK_DFB_desiredAlpha = KTWK_DFB_opt_alpha;
KTWK_DFB_currentAlpha = 0;

call KTWK_DFB_fnc_resetDmgTracker;
call KTWK_DFB_fnc_update;
