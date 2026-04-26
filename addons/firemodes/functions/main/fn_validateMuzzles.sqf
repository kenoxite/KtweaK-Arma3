// KTWK_CFM_fnc_validateMuzzles
// Filters weaponsInfo array to return only valid player-usable firemodes for current weapon, excluding AI optics modes and GL muzzles
//
// Parameters:
//   _unit - Unit to validate muzzles for (default: KTWK_player)
// Returns:
//   Array - Filtered array of valid firemode entries in weaponsInfo format, or empty array if no weapon or no valid modes

params [["_unit", KTWK_player]];

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {[]};

private _weaponsInfo = _unit weaponsInfo [_weapon, false];
private _weaponsInfoCleaned = [];

// Patterns to exclude
private _excludePatterns = ["optics", "_medium", "_far", "_close"];
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
            _weaponsInfoCleaned pushBack _x;
        };
    };
} forEach _weaponsInfo;

_weaponsInfoCleaned
