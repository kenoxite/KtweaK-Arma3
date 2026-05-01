// KTWK_FMC_fnc_cycleFiremode
// Pre-positions firemode so Arma's native cycle lands on valid main firemode.
//
// Parameters:
//   _unit          - Unit (default: KTWK_player)
//   _direction     - 1 = forward, -1 = backward (default: 1)
//   _forcedFiremode - Force specific firemode index (default: -1)

params [["_unit", KTWK_player], ["_direction", 1], ["_forcedFiremode", -1]];

if (!KTWK_FMC_opt_restrictFiremodes) exitWith {false};
if (isSwitchingWeapon _unit) exitWith {false};

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {false};

private _weaponData = [_unit, _weapon] call KTWK_FMC_fnc_getWeaponData;
if (_weaponData isEqualTo []) exitWith {false};

// Build full firemode sequence including all muzzles
private _fullSequence = [];
{
    private _muzzle = _x#0;
    private _firemodes = _x#1;
    { _fullSequence pushBack [_muzzle, _x] } forEach _firemodes;
} forEach _weaponData;

// Handle forced firemode (direct call, no vanilla cycling happening)
if (_forcedFiremode >= 0) exitWith {
    private _cleanForcedFiremode = _forcedFiremode min ((count _fullSequence) - 1);
    private _muzzleData = _fullSequence#_cleanForcedFiremode;
    _muzzleData params ["_muzzle", "_firemode"];
    _unit selectWeapon [_weapon, _muzzle, _firemode];
    missionNamespace setVariable ["KTWK_FMC_lastMuzzle", _muzzle];
    missionNamespace setVariable ["KTWK_FMC_lastFiremode", _firemode];
};

private _currentMuzzle = currentMuzzle _unit;
private _currentFiremode = toLower currentWeaponMode _unit;
private _currentIndex = _fullSequence findIf { (_x#0 == _currentMuzzle) && {_x#1 == _currentFiremode} };

if (_currentIndex == -1) exitWith {false};

private _mainFiremodes = [];
private _mainMuzzle = (_weaponData select { (_x#0) == _weapon })#0;
if (isNil "_mainMuzzle") exitWith {false};

_mainMuzzle params ["_muzzle", "_firemodes"];
_mainFiremodes = _firemodes;

private _switchedToAlt = missionNamespace getVariable ["KTWK_FMC_switchedToAlt", false];
if (_switchedToAlt) exitWith {
    missionNamespace setVariable ["KTWK_FMC_switchedToAlt", false];
};

// Calculate where Arma will land after native cycle
private _landingIndex = (_currentIndex + _direction) % count _fullSequence;
if (_landingIndex < 0) then { _landingIndex = _landingIndex + count _fullSequence };
private _landingEntry = _fullSequence#_landingIndex;
_landingEntry params ["_landingMuzzle", "_landingFiremode"];

// If landing on main muzzle, do nothing
if (_landingMuzzle == _weapon) exitWith {
    missionNamespace setVariable ["KTWK_FMC_lastMuzzle", _landingMuzzle];
    missionNamespace setVariable ["KTWK_FMC_lastFiremode", _landingFiremode];
};

// Landing on alt muzzle (GL) - need to pre-position
// Find what main firemode we want to end up with
// For forward: we want the main firemode that comes AFTER the alt muzzle
// For backward: we want the main firemode that comes BEFORE the alt muzzle
private _desiredIndex = (_landingIndex + _direction) % count _fullSequence;
if (_desiredIndex < 0) then { _desiredIndex = _desiredIndex + count _fullSequence };
private _desiredEntry = _fullSequence#_desiredIndex;
_desiredEntry params ["_desiredMuzzle", "_desiredFiremode"];

// Pre-position to the alt muzzle firemode
_unit selectWeapon [_weapon, _landingMuzzle, _landingFiremode];

missionNamespace setVariable ["KTWK_FMC_lastMuzzle", _desiredMuzzle];
missionNamespace setVariable ["KTWK_FMC_lastFiremode", _desiredFiremode];
