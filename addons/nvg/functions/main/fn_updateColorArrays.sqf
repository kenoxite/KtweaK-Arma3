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
    "Laserdesignator_03",
    // Vehicles
    "B_UAV_01_F",
    "O_UAV_01_F",
    "I_UAV_01_F",
    // CUP
    "cup_nvg_gpnvg_black",
    "CUP_NVG_GPNVG_Hide",
    "cup_nvg_gpnvg_tan",
    "cup_nvg_gpnvg_green",
    "cup_nvg_gpnvg_winter",
    // EUDF
    "I_EUDF35_UAV_01_F",
    "I_EUDF35_A_UAV_01_F",
    "I_EUDF35_D_UAV_01_F",
    "B_EUDF35_UAV_01_F",
    "B_EUDF35_A_UAV_01_F",
    "B_EUDF35_D_UAV_01_F",
    "O_EUDF35_UAV_01_F",
    "O_EUDF35_A_UAV_01_F",
    "O_EUDF35_D_UAV_01_F",
    "O_EUDF35_D_UAV_01_F"
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

private _knownGreen = [] apply {toLowerANSI _x};

// Parse user settings
private _wpResult = [KTWK_NVG_opt_color_wp] call KTWK_NVG_fnc_resolveMagicWords;
private _userWP = if (_wpResult isNotEqualTo []) then {
    _wpResult # 0
} else { [] };
if (_wpResult isNotEqualTo [] && {(_wpResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_wp", _wpResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _amberResult = [KTWK_NVG_opt_color_amber] call KTWK_NVG_fnc_resolveMagicWords;
private _userAmber = if (_amberResult isNotEqualTo []) then {
    _amberResult # 0
} else { [] };
if (_amberResult isNotEqualTo [] && {(_amberResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_amber", _amberResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _bwResult = [KTWK_NVG_opt_color_bw] call KTWK_NVG_fnc_resolveMagicWords;
private _userBW = if (_bwResult isNotEqualTo []) then {
    _bwResult # 0
} else { [] };
if (_bwResult isNotEqualTo [] && {(_bwResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_bw", _bwResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _crimsonResult = [KTWK_NVG_opt_color_crimson] call KTWK_NVG_fnc_resolveMagicWords;
private _userCrimson = if (_crimsonResult isNotEqualTo []) then {
    _crimsonResult # 0
} else { [] };
if (_crimsonResult isNotEqualTo [] && {(_crimsonResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_crimson", _crimsonResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _greenResult = [KTWK_NVG_opt_color_green] call KTWK_NVG_fnc_resolveMagicWords;
private _userGreen = if (_greenResult isNotEqualTo []) then {
    _greenResult # 0
} else { [] };
if (_greenResult isNotEqualTo [] && {(_greenResult # 1) != ""}) then {
    ["KTWK_NVG_opt_color_green", _greenResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

// Merge
KTWK_NVG_wp = _knownWP + _userWP;
KTWK_NVG_amber = _knownAmber + _userAmber;
KTWK_NVG_bw = _knownBW + _userBW;
KTWK_NVG_crimson = _knownCrimson + _userCrimson;
KTWK_NVG_green = _knownGreen + _userGreen;

KTWK_NVG_wp_custom = _userWP;
KTWK_NVG_amber_custom = _userAmber;
KTWK_NVG_bw_custom = _userBW;
KTWK_NVG_crimson_custom = _userCrimson;
KTWK_NVG_green_custom = _userGreen;

// Clear cache
call KTWK_NVG_fnc_resetCache;
