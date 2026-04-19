// KTWK_NVG_fnc_getDeviceGen
// Determines current generation index and color preset based on active NVG item
//
// Parameters:
//   _mode - Current NVG mode
//   _unit - Unit to check (player)
// Returns:
//   Array - [_genIndex, _colorPreset]

params ["_mode", "_unit"];

private _genIndex = 0;
private _colorPreset = KTWK_NVG_opt_color;

private _itemClass = call {
    if (_mode == "helmet") exitWith { headgear _unit };
    if (_mode == "rangefinder") exitWith { currentWeapon _unit };
    if (_mode == "scoped") exitWith { (_unit weaponAccessories currentWeapon _unit) # 2 };
    if (_mode in ["standard","ADS"]) exitWith { hmd _unit };
    if (_mode in ["MFD","vehicle"]) exitWith { typeOf vehicle _unit };
    ""
};

if (_itemClass == "") exitWith { [_genIndex, _colorPreset] };
private _itemClassLower = toLowerANSI _itemClass;

// Check autoGen exclusion
if (_itemClassLower in KTWK_NVG_excludeAutoGen) exitWith {
    [0, _colorPreset]
};

// Check Generation
if (KTWK_NVG_opt_autoGen) then {
    _genIndex = call {
        if (_itemClassLower in KTWK_NVG_gen1) exitWith { 1 };
        if (_itemClassLower in KTWK_NVG_gen2) exitWith { 2 };
        if (_itemClassLower in KTWK_NVG_gen3) exitWith { 3 };
        if (_itemClassLower in KTWK_NVG_gen4) exitWith { 4 };
        0
    };
};

// Gemeration or custom color
private _customColor = [_itemClassLower] call KTWK_NVG_fnc_getColor;
if (_customColor > 0) then { _colorPreset = _customColor; };
if (_genIndex > 0 && _colorPreset > 0) exitWith { [_genIndex, _colorPreset] };

// Check ACE config if no generation or custom gear color found
private _cfgWeapons = configFile >> "CfgWeapons";
private _aceGen = getNumber (_cfgWeapons >> _itemClass >> "ace_nightvision_generation");
if (_aceGen > 0) exitWith {
    private _isWP = getNumber (_cfgWeapons >> _itemClass >> "ace_nightvision_whitePhosphor") == 1;
    private _aceColor = [_colorPreset, 2] select _isWP;
    [_aceGen, _aceColor]
};

[_genIndex, _colorPreset]
