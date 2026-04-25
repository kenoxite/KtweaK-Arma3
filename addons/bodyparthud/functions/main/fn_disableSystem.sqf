// KTWK_BPH_fnc_disableSystem
// Completely shuts down the Bodypart HUD system and cleans up all resources
// Can be called at any time regardless of system state
// Preserves detection globals and player reference for reactivation
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\bodyparthud\idc.hpp"

// Remove per-frame handler if it exists
if (!isNil "KTWK_BPH_pfh") then {
    [KTWK_BPH_pfh] call CBA_fnc_removePerFrameHandler;
    KTWK_BPH_pfh = nil;
};

// Remove inventory event handler if it exists
if (!isNil "KTWK_BPH_EH_invOpened" && {KTWK_BPH_EH_invOpened != -1}) then {
    if (!isNil "KTWK_player" && {!isNull KTWK_player}) then {
        KTWK_player removeEventHandler ["InventoryOpened", KTWK_BPH_EH_invOpened];
    };
    KTWK_BPH_EH_invOpened = -1;
};
if (!isNil "KTWK_BPH_EH_playerViewChanged") then {
    removeMissionEventHandler ["PlayerViewChanged", KTWK_BPH_EH_playerViewChanged];
    KTWK_BPH_EH_playerViewChanged = nil;
};

// Hide and destroy the HUD display
private _display = uiNamespace getVariable ["BPH_Display", displayNull];
if (!isNull _display) then {
    // Hide all HUD elements first
    if (!isNil "KTWK_BPH_idcs") then {
        [_display, KTWK_BPH_idcs, false] call KTWK_BPH_fnc_drawHUD;
    };
    // Remove the display
    _display closeDisplay 2;
};

// Cut the RSC layer to ensure complete removal
("BPH_Layer" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];

// Reset runtime state variables
KTWK_BPH_targetAlpha = KTWK_BPH_opt_alpha;
KTWK_BPH_displayAlpha = 0;
KTWK_BPH_invOpened = false;
KTWK_BPH_dmgTracker = [];

KTWK_BPH_isActive = false;
