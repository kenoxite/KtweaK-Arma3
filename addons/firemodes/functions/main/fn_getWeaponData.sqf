// KTWK_CFM_fnc_getWeaponData
// Retrieves valid firemode data for a unit's current weapon, from cache if available or by calling validateMuzzles.
//
// Parameters:
//   _unit - Unit to get weapon data for (default: KTWK_player)
//
// Returns:
//   Array - Firemode entries in format [[_muzzle, _firemode], ...], or empty array if no weapon or no valid modes

params [["_unit", KTWK_player]];

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {[]};

// Check the cached known weapons first
// Cache format: [[_weapon, [[_muzzle, _firemode], ...]], ...]
private _weaponData = [];
private _cachedWeaponsData = missionNamespace getVariable ["KTWK_CFM_cachedWeaponsData", []];
private _cachedIndex = _cachedWeaponsData findIf {_x#0 == _weapon};

if (_cachedIndex != -1) then {
    _weaponData = (_cachedWeaponsData#_cachedIndex)#1;
} else {
    _weaponData = [_unit] call KTWK_CFM_fnc_validateMuzzles;

    if (_weaponData isNotEqualTo []) then {
        _cachedWeaponsData pushBack [_weapon, _weaponData];
        missionNamespace setVariable ["KTWK_CFM_cachedWeaponsData", _cachedWeaponsData];
    };
};

_weaponData
