// Add Inventory EventHandler
// by kenoxite

// For the next weapon display to work we have to override the opening of the inventory
// Reasons being:
//  - The container holding the displayed weapon is non interactable
//  - But, even then, it will be displayed in the player's inventory when crouching or lying down
//  - That means that in those cases, any droped object will be dropped inside the container of the displayed weapon
//  - But, as the container of the displayed weapon can't be interacted with, the player is unable to drop anything in this case, as the container appears just as Ground
// The solution so far is:
//  - Delete the displayed weapon containers whenever the player opens the inventory, and display them again once its closed
//  - The problem is: this can only be done via InventoryOpened EH but, once you get there, and if you don't ovreride its behavior, it's already too late. It has already built its own array of nearby containers so, if you move or delte any close container now, the inventory screen will be closed, as the closest container is now not present (same issue as trying to open a backpack of a unit that is moving away; it auto-closes)
//  - So, the main Open Inventory action is now overriden, disabling the default behavior. It now first deletes the display containers and THEN (after 0.01, to wait for the deleteVehicle commands to take effect) it opens the inventory via Action ["Gear"]

params [["_unit", player]];
_unit addEventHandler ["InventoryOpened", { 
    params ["_unit", "_container", "_container2"]; 
    if (!isNull (_unit getVariable ["KTWK_rifleHolster", objNull]) || !isNull (_unit getVariable ["KTWK_launcherHolster", objNull])) then {
        // Hide holsters
        [_unit, 1, 2] call KTWK_fnc_displayHolster; 
        [_unit, 3, 2] call KTWK_fnc_displayHolster;

        _unit removeEventHandler [_thisEvent, _thisEventHandler];
        _this spawn KTWK_fnc_openInv;
        if (vehicle _unit == _unit) exitWith {
            _unit setVariable ["KTWK_swappingWeapon", true]; 
            true
        };
    };
}];
