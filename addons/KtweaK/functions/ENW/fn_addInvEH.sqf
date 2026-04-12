// KTWK_fnc_addInvEH

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

if (!isNil "KTWK_EH_invOpened_ENW") then {
    _unit removeEventHandler ["InventoryOpened", KTWK_EH_invOpened_ENW];
};

KTWK_EH_invOpened_ENW = _unit addEventHandler ["InventoryOpened", { 
    params ["_unit", "_container", "_container2"];
    
    if (!isNull (_unit getVariable ["KTWK_rifleHolster", objNull]) || !isNull (_unit getVariable ["KTWK_launcherHolster", objNull])) then {
        
        _unit removeEventHandler [_thisEvent, _thisEventHandler];
    
        // Hide holsters
        [_unit, 1, 3] call KTWK_fnc_displayHolster; 
        [_unit, 3, 3] call KTWK_fnc_displayHolster;

        if (isNull objectParent _unit) exitWith {
            _unit setVariable ["KTWK_swappingWeapon", true];

            if (_container == (_unit getVariable ["KTWK_rifleHolster", objNull]) || _container == (_unit getVariable ["KTWK_launcherHolster", objNull])) then {
                _container = objNull;
            };
            [_unit, _container] spawn {
                params ["_unit", "_container"];
                _unit action ["Gear", _container];
                // Display holsters 
                waitUntil {!isNull (findDisplay 602)};
                _unit call KTWK_fnc_addInvEH;
                sleep 0.5;
                _unit setVariable ["KTWK_swappingWeapon", false];
                [_unit] call KTWK_fnc_toggleHolsterDisplay;
                [_unit] call KTWK_fnc_invAnims;
            };
            true; // inventory override
        };
    };
    false
}];
