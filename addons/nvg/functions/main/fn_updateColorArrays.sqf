// KTWK_NVG_fnc_updateColorArrays
// Rebuilds global color arrays from settings and known NVGs
//
// Parameters:
//   None
// Returns:
//   Nothing

private _settingScope = ["client", "server"] select (isServer);

// Base known NVGs by color
private _knownWP = [
    "nvgogglesb_grn_f",
    "nvgogglesb_blk_f",
    "nvgogglesb_gry_f",
    // Laser designators
    "Laserdesignator",
    "Laserdesignator_01_khk_F",
    "Laserdesignator_02",
    "Laserdesignator_02_ghex_F",
    "Laserdesignator_03"
] apply {toLowerANSI _x};

private _knownAmber = [
    // Reaction Forces
    "EF_LPNVG",
    "EF_LPNVG_T",
    "EF_LPNVG_T_Tan",
    "EF_LPNVG_Tan"
] apply {toLowerANSI _x};

private _knownBW = [] apply {toLowerANSI _x};

private _knownCrimson = [
    "H_HelmetO_ViperSP_hex_F",
    "H_HelmetO_ViperSP_ghex_F",
    // Optics
    "optic_Nightstalker"
] apply {toLowerANSI _x};

// Parse user settings
private _wpResult = [KTWK_NVG_opt_color_wp] call KTWK_NVG_fnc_resolveMagicWords;
private _userWP = if (_wpResult isNotEqualTo []) then {
    (_wpResult # 0) apply { toLowerANSI _x }
} else { [] };
if (_wpResult isNotEqualTo [] && {(_wpResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_wp", _wpResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _amberResult = [KTWK_NVG_opt_color_amber] call KTWK_NVG_fnc_resolveMagicWords;
private _userAmber = if (_amberResult isNotEqualTo []) then {
    (_amberResult # 0) apply { toLowerANSI _x }
} else { [] };
if (_amberResult isNotEqualTo [] && {(_amberResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_amber", _amberResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _bwResult = [KTWK_NVG_opt_color_bw] call KTWK_NVG_fnc_resolveMagicWords;
private _userBW = if (_bwResult isNotEqualTo []) then {
    (_bwResult # 0) apply { toLowerANSI _x }
} else { [] };
if (_bwResult isNotEqualTo [] && {(_bwResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_bw", _bwResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _crimsonResult = [KTWK_NVG_opt_color_crimson] call KTWK_NVG_fnc_resolveMagicWords;
private _userCrimson = if (_crimsonResult isNotEqualTo []) then {
    (_crimsonResult # 0) apply { toLowerANSI _x }
} else { [] };
if (_crimsonResult isNotEqualTo [] && {(_crimsonResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_crimson", _crimsonResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

// Merge
KTWK_NVG_wp = _knownWP + _userWP;
KTWK_NVG_amber = _knownAmber + _userAmber;
KTWK_NVG_bw = _knownBW + _userBW;
KTWK_NVG_crimson = _knownCrimson + _userCrimson;

KTWK_NVG_allColors = [];
KTWK_NVG_allColors append KTWK_NVG_wp;
KTWK_NVG_allColors append KTWK_NVG_amber;
KTWK_NVG_allColors append KTWK_NVG_bw;
KTWK_NVG_allColors append KTWK_NVG_crimson;

// Clear cache
KTWK_NVG_cachedDetection = [1.0, 0, 1.0, 0.5, 0.003];
KTWK_NVG_cachedItemClass = "";
