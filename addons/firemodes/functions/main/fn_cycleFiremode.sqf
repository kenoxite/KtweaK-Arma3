// KTWK_CFM_fnc_cycleFiremode
// Cycles through valid firemodes (Single, FullAuto, Burst) on current weapon, skipping AI optics and GL.
// Direction: 1 = forward, -1 = backward, 0 = restore last firemode from saved variables.
//
// Parameters:
//   _unit      - Unit to cycle firemode on (default: KTWK_player)
//   _direction - Direction to cycle: 1, -1, or 0 (default: 1)
//
// Returns:
//   Boolean
 
params [["_unit", KTWK_player], ["_direction", 1], ["_forcedFiremode", -1]];

if (missionNamespace getVariable ["KTWK_CFM_selectingGL", false] && {_direction != 0}) exitWith {false};
if (isSwitchingWeapon _unit) exitWith {false};

private _weapon = currentWeapon _unit;

// Exit if no switching was requested and no weapon is held
if (_weapon == "") exitWith {false};

private _lastMainFiremode = missionNamespace getVariable ["KTWK_CFM_lastMainFiremode", ""];
private _lastMainMuzzle = missionNamespace getVariable ["KTWK_CFM_lastMainMuzzle", ""];

// If direction is 0, return with the current main firemode
if (_direction == 0) exitWith {
    missionNamespace setVariable ["KTWK_CFM_lastMuzzle", _lastMainMuzzle];
    missionNamespace setVariable ["KTWK_CFM_selectingGL", false];
    if (_lastMainMuzzle == "" || _lastMainFiremode == "") exitWith {
        _unit selectWeapon _weapon;
    };
    _unit selectWeapon [_weapon, _lastMainMuzzle, _lastMainFiremode];
};

private _weaponData = [_unit] call KTWK_CFM_fnc_getWeaponData;

if (_weaponData isEqualTo []) exitWith {false};

// Find current firemode
private _currentFiremode = _weaponData findIf { (_x#1) == _lastMainFiremode };
if (_currentFiremode == -1) then { _currentFiremode = 0 }; // Fallback to first if none selected

private _nextIndex = call {
    if (_forcedFiremode >= 0) exitWith {_forcedFiremode};
    (_currentFiremode + _direction) % count _weaponData;
};
if (_nextIndex < 0) then { _nextIndex = _nextIndex + count _weaponData };

private _selectedModeData = _weaponData # _nextIndex;
_selectedModeData params ["_muzzle", "_firemode"];
_unit selectWeapon [_weapon, _muzzle, _firemode];

missionNamespace setVariable ["KTWK_CFM_lastMainFiremode", _firemode];
missionNamespace setVariable ["KTWK_CFM_lastMainMuzzle", _muzzle];
missionNamespace setVariable ["KTWK_CFM_lastFiremode", _firemode];
missionNamespace setVariable ["KTWK_CFM_lastMuzzle", _muzzle];
