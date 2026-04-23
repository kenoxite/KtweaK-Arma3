// KTWK_BPH_fnc_createPfh
// Creates the per-frame handler for Bodypart HUD updates
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\bodyparthud\idc.hpp"

private _display = uiNamespace getVariable ["BPH_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "Bodypart HUD: Cannot create PFH - display not found";
};

// Main PFH loop
KTWK_BPH_pfh = [{
    params ["_args", "_handle"];
    _args params ["_display", "_groupIdc"];
    
    if (isNull findDisplay 46) exitWith {};
    
    private _ctrl = _display displayCtrl _groupIdc;
    if (isNull _ctrl) then {
        diag_log "Bodypart HUD: Control not found. Shutting down.";
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    
    private _currentUnit = call CBA_fnc_currentUnit;
    private _isAlive = alive KTWK_player;
    
    if (KTWK_player isNotEqualTo _currentUnit || {!_isAlive}) then {
        if (!_isAlive) then {
            // Death: keep HUD visible to show fatal damage
            KTWK_BPH_targetAlpha = 0.6;
            [_handle] call CBA_fnc_removePerFrameHandler;
            [{
                alive player
            }, {
                [] call KTWK_BPH_fnc_initSystem;
            }] call CBA_fnc_waitUntilAndExecute;
        } else {
            // Unit switch - update player reference and reset
            KTWK_player = _currentUnit;
            KTWK_BPH_targetAlpha = 0;
            KTWK_BPH_displayAlpha = 0;
            KTWK_BPH_invOpened = false;
            call KTWK_BPH_fnc_resetDmgTracker;
            // Force hide then show to refresh display
            [_display, KTWK_BPH_idcs] call KTWK_BPH_fnc_hideHUD;
            [_display, KTWK_BPH_idcs, true] call KTWK_BPH_fnc_drawHUD;
        };
    } else {
        private _isHuman = [KTWK_player] call ([KTWK_fnc_isHuman, KTWK_BPH_fnc_isHuman] select (!KTWK_BPH_ktweak));
        private _showHUD = KTWK_BPH_opt_enabled &&
            {_isHuman} &&
            {(positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) <= 5} &&
            {(KTWK_BPH_opt_showInjured || {KTWK_BPH_invOpened})} &&
            {!(dialog && {!KTWK_BPH_invOpened})};
        
        _ctrl ctrlShow _showHUD;
        
        // Handle inventory state
        private _inventoryOpen = !isNull findDisplay 602;
        
        if (_inventoryOpen) then {
            if (!KTWK_BPH_invOpened) then {
                KTWK_BPH_invOpened = true;
                KTWK_BPH_targetAlpha = 0.6;
            };
        } else {
            if (KTWK_BPH_invOpened) then {
                KTWK_BPH_invOpened = false;
                KTWK_BPH_targetAlpha = KTWK_BPH_opt_alpha;
                KTWK_BPH_displayAlpha = 0;
                
                // Reset damage tracker values to base levels
                {
                    private _baseValue = _x # 0;
                    private _newValue = if (_baseValue isEqualTo 0) then {0} else {_baseValue max 0.6};
                    _x set [1, _newValue];
                } forEach KTWK_BPH_dmgTracker;
            };
        };
        
        if (_showHUD) then {
            call KTWK_BPH_fnc_update;
        };
    };
}, 0.05, [_display, IDC_BPH_GROUP]] call CBA_fnc_addPerFrameHandler;
