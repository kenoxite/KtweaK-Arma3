// KTWK_FMC_fnc_switchToAltMuzzle
// Switches to alternate muzzle, if available.
//
// Parameters:
//   _unit  - Unit to switch alternate muzzle on (default: KTWK_player)

params [["_unit", KTWK_player]];
if (isSwitchingWeapon _unit) exitWith {false};

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {false};

private _weaponData = [_unit] call KTWK_FMC_fnc_getWeaponData;
if (_weaponData isEqualTo []) exitWith {false};

// Find alternate muzzle
private _altMuzzle = (_weaponData select { (_x#0) != _weapon })#0;
if (isNil "_altMuzzle") exitWith {false};

_altMuzzle params ["_muzzle", "_firemodes"];
if (_firemodes isEqualTo []) exitWith {false};

private _targetFiremode = _firemodes#0;

// Switch directly
_unit selectWeapon [_weapon, _muzzle, _targetFiremode];

missionNamespace setVariable ["KTWK_FMC_lastMuzzle", _muzzle];
missionNamespace setVariable ["KTWK_FMC_lastAltFiremode", _targetFiremode];
