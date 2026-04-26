// KTWK_CFM_fnc_cycleFiremode
// Cycles through valid firemodes (Single, FullAuto, Burst) on current weapon, skipping AI optics modes and GL
//
// Parameters:
//   _unit      - Unit to cycle firemode on (default: KTWK_player)
//   _direction - Direction to cycle: 1 for forward, -1 for backward (default: 1)
// Returns:
//   Boolean - False if operation fails (switching weapon, no weapon, no valid muzzles), otherwise cycles and returns nil
 
params [["_unit", KTWK_player], ["_direction", 1]];

if (missionNamespace getVariable ["KTWK_CFM_selectingGL", false] && {_direction != 0}) exitWith {false};
if (isSwitchingWeapon _unit) exitWith {false};

private _weapon = currentWeapon _unit;

// Exit if no switching was requested and no weapon is held
if (_weapon == "") exitWith {false};

private _muzzleData = [_unit] call KTWK_CFM_fnc_validateMuzzles;
if (_muzzleData isEqualTo []) exitWith {false};

// Find current firemode using the isSelected flag (index 1)
private _current = _muzzleData findIf { _x#1 };
if (_current == -1) then { _current = 0 }; // Fallback to first if none selected

// If direction is 0, return with the current main firemode
if (_direction == 0) exitWith {
    private _lastFiremode = missionNamespace getVariable ["KTWK_CFM_lastMainFiremode", ""];
    private _lastMuzzle = missionNamespace getVariable ["KTWK_CFM_lastMainMuzzle", ""];
    missionNamespace setVariable ["KTWK_CFM_lastFiremode", _lastFiremode];
    missionNamespace setVariable ["KTWK_CFM_lastMuzzle", _lastMuzzle];

    missionNamespace setVariable ["KTWK_CFM_selectingGL", false];
    if (_lastMuzzle == "" || _lastFiremode == "") exitWith {
        _unit selectWeapon _weapon;
    };
    _unit selectWeapon [_weapon, _lastMuzzle, _lastFiremode];
};

private _nextIndex = (_current + _direction) % count _muzzleData;
if (_nextIndex < 0) then { _nextIndex = _nextIndex + count _muzzleData };

private _next = _muzzleData # _nextIndex;
_next params ["","", "_weapon", "_muzzle", "_firemode"];
if (_firemode == missionNamespace getVariable ["KTWK_CFM_lastFiremode", ""]) exitWith {false};

_unit selectWeapon [_weapon, _muzzle, _firemode];

missionNamespace setVariable ["KTWK_CFM_lastMainFiremode", _firemode];
missionNamespace setVariable ["KTWK_CFM_lastMainMuzzle", _muzzle];
missionNamespace setVariable ["KTWK_CFM_lastFiremode", _firemode];
missionNamespace setVariable ["KTWK_CFM_lastMuzzle", _muzzle];
