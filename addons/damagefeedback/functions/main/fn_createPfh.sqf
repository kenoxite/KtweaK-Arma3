// KTWK_DFB_fnc_createPfh
// Creates the per-frame handler for Bodypart HUD updates
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\damagefeedback\idc.hpp"

private _display = uiNamespace getVariable ["BPH_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "Bodypart HUD: Cannot create PFH - display not found";
};

// Main PFH loop
KTWK_DFB_pfh = [{
    params ["_args", "_handle"];
    _args params ["_display", "_groupIdc"];
    
    if (isNull findDisplay 46) exitWith {};
    
    private _ctrl = _display displayCtrl _groupIdc;
    if (isNull _ctrl) then {
        diag_log "Bodypart HUD: Control not found. Shutting down.";
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    
    private _player = KTWK_player;
    private _isAlive = alive _player;
    
    if (!_isAlive) then {
        // Death: keep HUD visible to show fatal damage
        KTWK_DFB_targetAlpha = 0.6;
        [_handle] call CBA_fnc_removePerFrameHandler;
        [{
            alive player
        }, {
            [] call KTWK_DFB_fnc_initSystem;
        }] call CBA_fnc_waitUntilAndExecute;
    } else {
        private _isHuman = [_player] call ([KTWK_fnc_isHuman, KTWK_DFB_fnc_isHuman] select (!KTWK_DFB_ktweak));
        private _showHUD = KTWK_DFB_opt_enabled &&
            {_isHuman} &&
            {(positionCameraToWorld [0,0,0] distance (vehicle _player)) <= 5} &&
            {(KTWK_DFB_opt_showInjured || {KTWK_DFB_invOpened})} &&
            {!(dialog && {!KTWK_DFB_invOpened})};
        
        _ctrl ctrlShow _showHUD;
        
        // Handle inventory state
        private _inventoryUIShown = !isNull findDisplay 602;
        private _invOpened = KTWK_DFB_invOpened;
        if (_inventoryUIShown) then {
            if (!_invOpened) then {
                KTWK_DFB_invOpened = true;
                KTWK_DFB_targetAlpha = 0.6;
            };
        } else {
            if (_invOpened) then {
                KTWK_DFB_invOpened = false;
                KTWK_DFB_targetAlpha = KTWK_DFB_opt_alpha;
                KTWK_DFB_displayAlpha = 0;
                
                // Reset damage tracker values to base levels
                {
                    private _baseValue = _x # 0;
                    private _newValue = if (_baseValue isEqualTo 0) then {0} else {_baseValue max 0.6};
                    _x set [1, _newValue];
                } forEach KTWK_DFB_dmgTracker;
            };
        };
        
        if (_showHUD) then {
            call KTWK_DFB_fnc_update;
        };
    };
}, 0.05, [_display, IDC_BPH_GROUP]] call CBA_fnc_addPerFrameHandler;
