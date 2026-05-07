// KTWK_DFB_fnc_disableSystem
// Completely shuts down the Damage Feedback system and cleans up all resources
// Can be called at any time regardless of system state
// Preserves detection globals and player reference for reactivation
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\damagefeedback\idc.hpp"

// Remove per-frame handler if it exists
if (!isNil "KTWK_DFB_pfh") then {
    [KTWK_DFB_pfh] call CBA_fnc_removePerFrameHandler;
    KTWK_DFB_pfh = nil;
};

if (!isNil "KTWK_DFB_EH_playerViewChanged") then {
    removeMissionEventHandler ["PlayerViewChanged", KTWK_DFB_EH_playerViewChanged];
    KTWK_DFB_EH_playerViewChanged = nil;
};

// Reset runtime state variables
KTWK_DFB_desiredAlpha = KTWK_DFB_opt_alpha;
KTWK_DFB_currentAlpha = 0;
KTWK_DFB_invOpened = false;
KTWK_DFB_dmgTracker = [];

KTWK_DFB_isActive = false;

diag_log "[DFB] System disabled";
