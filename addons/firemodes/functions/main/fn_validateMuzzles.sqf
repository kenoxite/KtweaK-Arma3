// KTWK_CFM_fnc_validateMuzzles
// Returns main weapon firemodes (no AI optics). Caches GL muzzles to global array.
//
// Parameters:
//   _unit - Unit to validate muzzles for (default: KTWK_player)
//
// Returns:
//   Array - [[_muzzle, _firemode], ...] or []

params [["_unit", KTWK_player]];

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {[]};

private _weaponsInfo = _unit weaponsInfo [_weapon, false];
private _weaponsInfoMain = [];
private _weaponsInfoAlt = [];

// Patterns to exclude
private _excludePatterns = ["optic", "medium", "far", "close", "short"];
{
    private _muzzleName = _x#3;
    private _firemode = toLower (_x#4);
    
    // Valid: base weapon muzzle AND no exclude patterns found
    if (_muzzleName == _weapon) then {
        private _exclude = false;
        {
            if (_firemode find _x != -1) then {
                _exclude = true;
            };
        } forEach _excludePatterns;
        
        if (!_exclude) then {
            _weaponsInfoMain pushBack [_muzzleName, _firemode];
        };
    } else {
        _weaponsInfoAlt pushBack [_muzzleName, _firemode];
    };
} forEach _weaponsInfo;

// Cache alternative muzzles
if (_weaponsInfoAlt isNotEqualTo []) then {
    private _cachedAlt = missionNamespace getVariable ["KTWK_CFM_cachedWeaponsDataAlt", []];
    private _entry = [_weapon];
    _entry append _weaponsInfoAlt;
    _cachedAlt pushBack _entry;
    missionNamespace setVariable ["KTWK_CFM_cachedWeaponsDataAlt", _cachedAlt];
};

_weaponsInfoMain
