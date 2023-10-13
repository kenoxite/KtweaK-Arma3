// Get all items, weapons (with attachments, mags, etc) and mags (with ammo count) from the unit's uniform, vest or backpack
// Returns an array in format:
// [<items>,<weapons>,<mags>,<grenades>]
// by kenoxite

params ["_unit", ["_containerType", "uniform"]];

private _isUniform = toLowerAnsi _containerType == "uniform";
private _isVest = toLowerAnsi _containerType == "vest";
private _isBackpack = toLowerAnsi _containerType == "backpack";

// Get magazines names and its current ammo from the container
private _containerMagDet = call {
    if (_isUniform) exitWith { magazinesDetailUniform [_unit, true, false] };
    if (_isVest) exitWith { magazinesDetailVest [_unit, true, false] };
    if (_isBackpack) exitWith { magazinesDetailBackpack [_unit, true, false] };
};
private ["_rev","_i1","_i2","_i3"]; 
_containerMagDet = _containerMagDet apply { 
    _rev = reverse _x; 
    _i1 = (_rev find "[)") + 1; 
    _i2 = (_rev find ["/", _i1]) + 1; 
    _i3 = (_rev find ["(", _i2]); 
    [ 
    reverse (_rev select [_i3+1]), 
    parseNumber reverse (_rev select [_i2,(_i3-_i2)])
    ]  
};

// Get all the items in the container
private _containerItemsRaw = call {
    if (_isUniform) exitWith { uniformItems _unit };
    if (_isVest) exitWith { vestItems _unit };
    if (_isBackpack) exitWith { backpackItems _unit };
};

// Store detailed info about items, weapons and magazines in the returned array
private _cfgMags = configFile >> "cfgMagazines";
private _cfgWeps = configFile >> "cfgWeapons";
private _containerItems = [];
private _containerWeapons = [];
private _containerMags = [];
private _containerGrenades = [];
private _i = 0;
private ["_wep","_wItems"];
_containerItemsRaw apply {
    call {
        if (isClass(_cfgMags >> _x)) exitWith {
            if (_x isKindOf ["HandGrenade", _cfgMags]) then {
                _containerGrenades pushBack _x;
                _i = _i + 1;
            } else {
                _containerMags pushBack [_x, (_containerMagDet#_i)#1];
                _i = _i + 1;
            };
        };
        if (isClass(_cfgWeps >> _x)) exitWith {
            _wep = _x;
            _wItems = (weaponsItems _unit select {toLower (_x #0) == _wep}) #0;
            if (isNil {_wItems}) then {
                _containerItems pushBack _x;
            } else {
                _containerWeapons pushBack _wItems;
            };
        };
        _containerItems pushBack _x;
    };
};

[_containerItems, _containerWeapons, _containerMags, _containerGrenades]
