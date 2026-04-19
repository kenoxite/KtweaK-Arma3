// KTWK_NVG_fnc_updateOpticZoom
// Updates cached optic max range for current weapon/optic
//
// Parameters:
//   _unit - Player unit
//   _weapon - Weapon class to check (default: currentWeapon _unit)
// Returns:
//   Nothing

params ["_unit", ["_weapon", currentWeapon KTWK_player]];

if (_weapon == "") exitWith {};

private _isOptic = true;
private _weaponItems = (weaponsItems _unit) select {(_x # 0) == _weapon};
private _optic = if (_weaponItems isNotEqualTo []) then {(_weaponItems # 0) # 3} else {""};

if (_optic == "") then { _optic = _weapon; _isOptic = false; };

private _minRange = 200;
private _maxRange = 200;
private _knownIndex = KTWK_NVG_knownOptics findIf {_x == _optic};

if (_knownIndex != -1) then {
    private _rangeData = KTWK_NVG_knownOpticZooms # _knownIndex;
    _minRange = _rangeData # 0;
    _maxRange = _rangeData # 1;
} else {
    private _config = call {
        if (_isOptic) exitWith {
            configFile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes" >> (_unit getOpticsMode 0);
        };
        configFile >> "CfgWeapons" >> _optic
    };
    _minRange = getNumber (_config >> "distanceZoomMin");
    _maxRange = getNumber (_config >> "distanceZoomMax");
    if (_maxRange > 0) then {
        KTWK_NVG_knownOptics pushBack _optic;
        KTWK_NVG_knownOpticZooms pushBack [_minRange, _maxRange];
    };
};

KTWK_NVG_opticZoomMin = _minRange;
KTWK_NVG_opticZoomMax = _maxRange;
