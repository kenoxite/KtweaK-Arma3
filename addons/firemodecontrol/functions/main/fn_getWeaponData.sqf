// KTWK_FMC_fnc_getWeaponData
// Retrieves weapon firemode data from cache or validateMuzzles.
//
// Parameters:
//   _unit      - Unit to get weapon data for (default: KTWK_player)
//   _newMuzzle - Current muzzle for cache validation (default: "")
//
// Returns:
//   Array - [[_muzzle, [_firemodes]], ...] for the weapon, or empty array if no weapon

params [["_unit", KTWK_player], ["_newMuzzle", ""]];

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {[]};

private _lastWeapon = missionNamespace getVariable ["KTWK_FMC_lastPrimary", ""];
private _lastMuzzle = missionNamespace getVariable ["KTWK_FMC_lastMuzzle", ""];
private _lastWeaponData = missionNamespace getVariable ["KTWK_FMC_lastWeaponData", []];

// Return stored data if weapon didn't change
if (_weapon == _lastWeapon && {_newMuzzle == _lastMuzzle} && {_lastWeaponData isNotEqualTo []}) exitWith {
    _lastWeaponData
};

// Check the cached known weapons
// Cache format: [[_weapon, [[_muzzle, [_firemodes]], ...]], ...]
private _weaponData = [];
private _cachedWeaponsData = missionNamespace getVariable ["KTWK_FMC_cachedWeaponsData", []];
private _cachedIndex = _cachedWeaponsData findIf {_x#0 == _weapon};

// Return data, cahced or extracted it if not cached
if (_cachedIndex != -1) then {
    _weaponData = (_cachedWeaponsData#_cachedIndex)#1;
} else {
    _weaponData = [_unit] call KTWK_FMC_fnc_validateMuzzles;

    if (_weaponData isNotEqualTo []) then {
        _cachedWeaponsData pushBack [_weapon, _weaponData];
        missionNamespace setVariable ["KTWK_FMC_cachedWeaponsData", _cachedWeaponsData];
    };
};

_weaponData
