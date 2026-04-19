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

private _maxRange = 200;
private _knownIndex = KTWK_NVG_knownOptics findIf {_x == _optic};

if (_knownIndex != -1) then {
    _maxRange = KTWK_NVG_knownOpticZooms # _knownIndex;
} else {
    _maxRange = call {
        if (_isOptic) exitWith {
            getNumber (configFile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes" >> (_unit getOpticsMode 0) >> "distanceZoomMax");
        };
        getNumber (configFile >> "CfgWeapons" >> _optic >> "distanceZoomMax");
    };
    if (_maxRange > 0) then {
        KTWK_NVG_knownOptics pushBack _optic;
        KTWK_NVG_knownOpticZooms pushBack _maxRange;
    };
};

KTWK_NVG_opticZoom = _maxRange;
