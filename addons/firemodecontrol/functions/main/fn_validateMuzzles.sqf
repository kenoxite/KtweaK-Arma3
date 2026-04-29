// KTWK_FMC_fnc_validateMuzzles
// Validates and returns valid firemodes for unit's current weapon, filtering out AI optics and auxiliary modes.
//
// Parameters:
//   _unit - Unit to validate muzzles for (default: KTWK_player)
//
// Returns:
//   Array - [[_muzzle, [_firemodes]], ...] or []

params [["_unit", KTWK_player]];

private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {[]};

private _weaponsInfo = _unit weaponsInfo [_weapon, false];
private _weaponsInfoClean = [];

private _excludePatterns = ["optic", "medium", "far", "close", "short"];

private _lastMuzzle = "";
private _muzzleIdx = -1;

{
    private _muzzleName = _x#3;
    private _firemode = toLower (_x#4);
    
    if (_muzzleName != _lastMuzzle) then {
        _weaponsInfoClean pushBack [_muzzleName, []];
        _muzzleIdx = _muzzleIdx + 1;
        _lastMuzzle = _muzzleName;
    };
    
    private _exclude = false;
    {
        if (_firemode find _x != -1) exitWith { _exclude = true; };
    } forEach _excludePatterns;
    
    if (!_exclude) then {
        ((_weaponsInfoClean#_muzzleIdx)#1) pushBack _firemode;
    };
} forEach _weaponsInfo;

_weaponsInfoClean
