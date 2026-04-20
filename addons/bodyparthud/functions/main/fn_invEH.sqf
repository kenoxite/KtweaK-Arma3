// KTWK_BPH_fnc_invEH
// Adds inventory opened event handler to display full HUD while inventory is open
//
// Parameters:
//   _unit - Unit to add the event handler to (default: current unit)
// Returns:
//   Number - Event handler ID

params [["_unit", objNull]];

if (isNull _unit) then {
    _unit = call CBA_fnc_currentUnit;
};

KTWK_BPH_EH_invOpened = _unit addEventHandler ["InventoryOpened", {

    if (!KTWK_BPH_opt_enabled || {!KTWK_BPH_opt_showInv}) exitWith {false};

    KTWK_BPH_invOpened = true;

    _this spawn {
        params ["_unit", "_container"];
        
        // Display health HUD
        if (isNull objectParent _unit) then {
            sleep 1;
        };
        
        KTWK_BPH_alpha = 0.6;

        _unit addEventHandler ["InventoryClosed", {
            [_this#0, _thisEvent, _thisEventHandler] spawn {

                params ["_unit", "_event", "_handler"];

                // Give time for double opening from ENW
                sleep 1;
                if (!isNull (findDisplay 602)) exitWith {};
                
                KTWK_BPH_alpha = KTWK_BPH_opt_alpha;
                KTWK_BPH_currentAlpha = 0;
                KTWK_BPH_invOpened = false;
                
                // Reset damage tracker values to their base levels
                {
                    private _baseValue = _x # 0;
                    private _newValue = if (_baseValue isEqualTo 0) then {0} else {_baseValue max 0.6};
                    _x set [1, _newValue];
                } forEach KTWK_BPH_dmgTracker;
                
                _unit removeEventHandler [_event, _handler];
            };
        }];
    };
}];

KTWK_BPH_EH_invOpened
