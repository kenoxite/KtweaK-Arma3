// Display full HUD while in inventory
params [["_player", call KTWK_fnc_playerUnit]];
KTWK_HUD_health_EH_InvOpened = _player addEventHandler ["InventoryOpened", {
    if (!KTWK_HUD_health_opt_enabled || !KTWK_HUD_health_opt_showInv) exitwith {false};
    params ["_unit", "_container"];
    KTWK_HUD_health_invOpened = true;
    _this spawn {
        waitUntil {!isNull (findDisplay 602)}; // Wait until the inventory is opened
        // Display health HUD
        KTWK_HUD_health_alpha = 0.6;
        (_this#0) addEventHandler ["InventoryClosed", {
            KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
            KTWK_HUD_health_alphaTemp = 0;
            KTWK_HUD_health_invOpened = false;
            {if ((_x #0) == 0) then {_x set [1, 0]} else {_x set [1, (_x #0) max 0.6]}} forEach KTWK_HUD_health_dmgTracker;
            (_this#0) removeEventHandler ["InventoryClosed", _thisEventHandler];
        }];
    };
}];
