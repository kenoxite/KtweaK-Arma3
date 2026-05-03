// KTWK_DFB_fnc_disableSystem
// Completely shuts down the Bodypart HUD system and cleans up all resources
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

// Remove inventory event handler if it exists
if (!isNil "KTWK_DFB_EH_invOpened" && {KTWK_DFB_EH_invOpened != -1}) then {
    if (!isNil "KTWK_player" && {!isNull KTWK_player}) then {
        KTWK_player removeEventHandler ["InventoryOpened", KTWK_DFB_EH_invOpened];
    };
    KTWK_DFB_EH_invOpened = -1;
};
if (!isNil "KTWK_DFB_EH_playerViewChanged") then {
    removeMissionEventHandler ["PlayerViewChanged", KTWK_DFB_EH_playerViewChanged];
    KTWK_DFB_EH_playerViewChanged = nil;
};

// Hide and destroy the HUD display
private _display = uiNamespace getVariable ["BPH_Display", displayNull];
if (!isNull _display) then {
    // Hide all HUD elements first
    if (!isNil "KTWK_DFB_idcs") then {
        [_display, KTWK_DFB_idcs, false] call KTWK_DFB_fnc_drawHUD;
    };
    // Remove the display
    _display closeDisplay 2;
};

// Cut the RSC layer to ensure complete removal
("BPH_Layer" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];

// Reset runtime state variables
KTWK_DFB_targetAlpha = KTWK_DFB_opt_alpha;
KTWK_DFB_displayAlpha = 0;
KTWK_DFB_invOpened = false;
KTWK_DFB_dmgTracker = [];

KTWK_DFB_isActive = false;
