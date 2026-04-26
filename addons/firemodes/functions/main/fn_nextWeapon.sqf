// KTWK_CFM_fnc_nextWeapon
// Handles weapon slot switching (primary, handgun, launcher) with firemode persistence
//
// Parameters:
//   _unit           - Unit to switch weapon on (default: KTWK_player)
//   _switchToWeapon - Weapon slot to switch to: 0 = cycle firemode, 1 = primary, 2 = handgun, 3 = launcher (default: 0)
// Returns:
//   Boolean - False if operation fails, otherwise switches weapon/firemode and returns nil

params [["_unit", KTWK_player], ["_switchToWeapon", 0]];

private _weapon = currentWeapon _unit;

// Check if asked to change weapons and desired weapon is already selected
private _sameWeapon = call {
    if (_switchToWeapon > 0) exitWith {
        if (_weapon == "") exitWith {false};
        if (_switchToWeapon == 1 && {_weapon == primaryWeapon _unit}) exitWith {true};
        if (_switchToWeapon == 2 && {_weapon == handgunWeapon _unit}) exitWith {true};
        if (_switchToWeapon == 3 && {_weapon == secondaryWeapon _unit}) exitWith {true};
        false
    };
    true
};

// Switch weapons and exit if not holding requested weapon
if (_switchToWeapon > 0 && {!_sameWeapon}) exitWith {
    private _lastMuzzle = missionNamespace getVariable ["KTWK_CFM_lastMuzzle", ""];
    private _lastFiremode = missionNamespace getVariable ["KTWK_CFM_lastFiremode", ""];
    private _nextWeapon = call {
            if (_switchToWeapon == 1) exitWith {primaryWeapon _unit};
            if (_switchToWeapon == 2) exitWith {handgunWeapon _unit};
            if (_switchToWeapon == 3) exitWith {secondaryWeapon _unit};
            primaryWeapon _unit;
    };
    
    if (_lastMuzzle == "" || _lastFiremode == "") exitWith {
        _unit selectWeapon _nextWeapon;
    };
    _unit selectWeapon [_nextWeapon, _lastMuzzle, _lastFiremode];
};

// Change firemode otherwise
[_unit, 1] call KTWK_CFM_fnc_cycleFiremode;
