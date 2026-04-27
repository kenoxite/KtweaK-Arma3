// KTWK_CFM_fnc_switchToGL
// Switches to GL if available. Toggles back to main weapon if _cycle is true and already on GL.
//
// Parameters:
//   _unit  - Unit to switch GL on (default: KTWK_player)
//   _cycle - If true, return to main weapon when already on GL (default: false)
//
// Returns:
//   Boolean

params [["_unit", KTWK_player], ["_cycle", false]];
if (isSwitchingWeapon _unit) exitWith {false};

missionNamespace setVariable ["KTWK_CFM_selectingGL", true];
private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {false};

private _weaponData = [_unit] call KTWK_CFM_fnc_getWeaponData;

if (_weaponData isEqualTo []) exitWith {false};

private _cachedWeaponsDataAlt = missionNamespace getVariable ["KTWK_CFM_cachedWeaponsDataAlt", []];
private _weaponDataAlt = [];

private _cachedIndex = _cachedWeaponsDataAlt findIf {_x#0 == _weapon};
if (_cachedIndex != -1) then {
    _weaponDataAlt = (_cachedWeaponsDataAlt#_cachedIndex)#1;
};

if (_weaponDataAlt isEqualTo []) exitWith {};

_weaponDataAlt params ["_muzzle", "_firemode"];
if (_muzzle == missionNamespace getVariable ["KTWK_CFM_lastMuzzle", ""]) exitWith {
    // Change back to normal mode
    if (_cycle) exitWith {
        [_unit, 0] call KTWK_CFM_fnc_cycleFiremode;
    };
};

_unit selectWeapon [_weapon, _muzzle, _firemode];
missionNamespace setVariable ["KTWK_CFM_lastFiremode", _firemode];
missionNamespace setVariable ["KTWK_CFM_lastMuzzle", _muzzle];
missionNamespace setVariable ["KTWK_CFM_selectingGL", false];
