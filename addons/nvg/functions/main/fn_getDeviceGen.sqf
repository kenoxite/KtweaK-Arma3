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

// Manual mode overrides everything - return immediately
if (KTWK_NVG_opt_nvMode == 2) exitWith { 
    [_genIndex, _colorPreset] 
};

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

// Custom gear color overrides EVERYTHING
private _customColor = [_itemClassLower] call KTWK_NVG_fnc_getColor;
if (_customColor > 0) then { 
    _colorPreset = _customColor; 
};

// Check autoGen exclusion
if (_itemClassLower in KTWK_NVG_excludeAutoGen) exitWith {
    [0, _colorPreset]
};

// Check Generation
if (KTWK_NVG_opt_nvMode < 2) then {
    _genIndex = call {
        if (_itemClassLower in KTWK_NVG_gen1) exitWith { 1 };
        if (_itemClassLower in KTWK_NVG_gen2) exitWith { 2 };
        if (_itemClassLower in KTWK_NVG_gen3) exitWith { 3 };
        if (_itemClassLower in KTWK_NVG_gen4) exitWith { 4 };
        0
    };
};

// If we have a custom color, use it regardless of generation source
if (_genIndex > 0 && _colorPreset > 0) exitWith { [_genIndex, _colorPreset] };

// Check ACE config if no generation or custom gear color found
private _cfgWeapons = configFile >> "CfgWeapons";
private _aceGen = getNumber (configFile >> "CfgWeapons" >> _itemClass >> "ace_nightvision_generation");
if (_aceGen == 0) then { _aceGen = _genIndex };
private _aceColor = _colorPreset;
private _isWP = getNumber (_cfgWeapons >> _itemClass >> "ace_nightvision_whitePhosphor") == 1;
if (_isWP) then {
    _aceColor = 2
} else {
    private _isCustom = getArray (_cfgWeapons >> _itemClass >> "ace_nightvision_colorPreset");
    if (_isCustom isNotEqualTo []) then {
        private _aceColorArray = _isCustom # 2;
        call {
            // ACE
            if (_aceColorArray isEqualTo [1.3, 1.2, 0.0, 0.9]) exitWith {
                _aceColor = 1
            };
            if (_aceColorArray isEqualTo [1.1, 0.8, 1.9, 0.9]) exitWith {
                _aceColor = 2
            };
            // USP
            if (_aceColorArray isEqualTo [0.75, 0.4, 1.7, 0.9]) exitWith {
                _aceColor = 2
            };
        };
    };
};
if (_aceGen isNotEqualTo _genIndex || _aceColor isNotEqualTo _colorPreset) exitWith {
    [_aceGen, _aceColor]
};

// String pattern fallback for color
if (_colorPreset == KTWK_NVG_opt_color) then {
    if ("_wp" in _itemClassLower) then { _colorPreset = 2 };
};

// String pattern fallback for generation
if (_genIndex == 0) then {
    if ("pvs14" in _itemClassLower || "pvs31" in _itemClassLower || "pvs15" in _itemClassLower || "gpnvg" in _itemClassLower || "1pn138" in _itemClassLower || "psq42" in _itemClassLower || "ivas" in _itemClassLower) then { _genIndex = 4 };
    if ("pvs7" in _itemClassLower) then { _genIndex = 3 };
    if ("pvs5" in _itemClassLower) then { _genIndex = 2 };
};

[_genIndex, _colorPreset]
