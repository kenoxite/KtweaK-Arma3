// Display full HUD while in inventory
params [["_unit", objNull]];
if (isNull _unit) then { _unit = call CBA_fnc_currentUnit };
KTWK_HUD_health_EH_InvOpened = _unit addEventHandler ["InventoryOpened", {
    if (!KTWK_HUD_health_opt_enabled || !KTWK_HUD_health_opt_showInv) exitwith {false};
    KTWK_HUD_health_invOpened = true;
    _this spawn {
        params ["_unit", "_container"];
        // Display health HUD
        if (vehicle _unit == _unit) then {
            sleep 1;
        };
        KTWK_HUD_health_alpha = 0.6;
        _unit addEventHandler ["InventoryClosed", {
            params ["_unit", "_container"];
            KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
            KTWK_HUD_health_currentAlpha = 0;
            KTWK_HUD_health_invOpened = false;
            {if ((_x #0) == 0) then {_x set [1, 0]} else {_x set [1, (_x #0) max 0.6]}} forEach KTWK_HUD_health_dmgTracker;
            _unit removeEventHandler [_thisEvent, _thisEventHandler];
        }];
    };
}];
