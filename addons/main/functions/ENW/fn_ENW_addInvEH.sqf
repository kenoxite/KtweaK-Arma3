// KTWK_fnc_ENW_addInvEH
// Adds inventory opened event handler with holster container management

// For the next weapon display to work we have to override the opening of the inventory.
// Reasons being:
//  - The container holding the displayed weapon is non-interactable.
//  - But, even then, it will be displayed in the player's inventory when crouching or lying down.
//  - That means that in those cases, any dropped object will be dropped inside the container of the displayed weapon.
//  - But, as the container of the displayed weapon can't be interacted with, the player is unable to drop anything
//    in this case, as the container appears just as Ground.
//
// The solution so far is:
//  - Detach and move away the displayed weapon containers whenever the player opens the inventory, and re-attach them again once it's closed.
//  - The problem is: this can only be done via InventoryOpened EH but, once you get there, and if you don't override its behavior,
//    it's already too late. It has already built its own array of nearby containers so, if you move or delete any close container now,
//    the inventory screen will be closed, as the closest container is now not present (same issue as trying to open a backpack of a unit
//    that is moving away, it auto-closes).
//  - So, the main Open Inventory action is now overridden, disabling the default behavior. It now first detachs and moves away the display containers
//    and THEN it opens the inventory via Action ["Gear"].

params [["_unit", player]];

if (!isNil "KTWK_ENW_EH_invOpened") then {
    _unit removeEventHandler ["InventoryOpened", KTWK_ENW_EH_invOpened];
};

KTWK_ENW_EH_invOpened = _unit addEventHandler ["InventoryOpened", {
    params ["_unit", "_container", "_container2"];

    private _rifleHolster = _unit getVariable ["KTWK_ENW_rifleHolster", objNull];
    private _launcherHolster = _unit getVariable ["KTWK_ENW_launcherHolster", objNull];

    // Only double open if not opened by key: checking a vehicle inventory through the action menu, etc.
    if (!(_unit getVariable ["KTWK_invOpenedByKey", false]) && (!isNull _rifleHolster || {!isNull _launcherHolster})) then {

        _unit removeEventHandler [_thisEvent, _thisEventHandler];

        // Hide holsters
        [_unit, 1, 3] call KTWK_fnc_ENW_displayHolster;
        [_unit, 3, 3] call KTWK_fnc_ENW_displayHolster;

        if (isNull objectParent _unit) exitWith {
            _unit setVariable ["KTWK_swappingWeapon", true];

            if (_container isEqualTo _rifleHolster || {_container isEqualTo _launcherHolster}) then {
                _container = objNull;
            };

            [_unit, _container] spawn {
                params ["_unit", "_container"];

                _unit action ["Gear", _container];

                // Display holsters
                waitUntil {!isNull (findDisplay 602)};

                _unit call KTWK_fnc_ENW_addInvEH;

                sleep 0.5;

                _unit setVariable ["KTWK_swappingWeapon", false];

                [_unit] call KTWK_fnc_ENW_toggleHolsterDisplay;
                [_unit] call KTWK_fnc_ENW_invAnims;
            };

            true // inventory override
        };
    };

    false
}];
