// KTWK_NVG_fnc_updateGenArrays
// Rebuilds global generation arrays from settings and known NVGs
//
// Parameters:
//   None
// Returns:
//   Nothing

private _settingScope = ["client", "server"] select (isServer);

// Base known NVGs
private _knownGen1 = [
    // CSLA
    "CSLA_nokto",
    // Global Mobilization
    "gm_ferod51_oli",
    "gm_nsg66_oli",
    "gm_feroz51_ris_oli",
    "gm_fero51_oli",
    // Prairie Fire
    "vn_o_1pn138",
    "vn_nvg_01",
    "vn_nvg_02"
] apply {toLowerANSI _x};

private _knownGen2 = [
    // CSLA
    "US85_ANPVS5_Goggles",
    // Reaction Forces
    "TiGoggles_RF",
    "TiGoggles_grn_RF",
    "TiGoggles_tan_RF",
    // Prairie Fire
    "vn_nvg_03"
] apply {toLowerANSI _x};

private _knownGen3 = [
    // Vanilla
    "nvgoggles",
    "nvgoggles_opfor",
    "nvgoggles_indep",
    "NVGoggles_tna_F",
    // CUP
    "cup_nvg_pvs7",
    "cup_nvg_hmnvs",
    "cup_nvg_pvs14",
    "cup_nvg_pvs15_black",
    "cup_nvg_pvs15_tan",
    "cup_nvg_pvs15_green",
    "cup_nvg_pvs15_winter",
    // RHS
    "rhsusf_anpvs_14",
    "rhsusf_anpvs_15",
    // Rangefinder
    "Rangefinder",
    // Optics
    "optic_NVS"
] apply {toLowerANSI _x};

private _knownGen4 = [
    "o_nvgoggles_hex_f",
    "o_nvgoggles_urb_f",
    "o_nvgoggles_ghex_f",
    "O_NVGoggles_grn_F",
    "nvgogglesb_grn_f",
    "nvgogglesb_blk_f",
    "nvgogglesb_gry_f",
    // CUP
    "cup_nvg_gpnvg_black",
    "cup_nvg_gpnvg_tan",
    "cup_nvg_gpnvg_green",
    "cup_nvg_gpnvg_winter",
    "cup_nvg_1pn138",
    // RHS
    "rhs_1pn138",
    // Reaction Forces
    "EF_LPNVG",
    "EF_LPNVG_T",
    "EF_LPNVG_T_Tan",
    "EF_LPNVG_Tan",
    // Headgear
    "H_HelmetO_ViperSP_hex_F",
    "H_HelmetO_ViperSP_ghex_F",
    // Laser designators
    "Laserdesignator",
    "Laserdesignator_01_khk_F",
    "Laserdesignator_02",
    "Laserdesignator_02_ghex_F",
    "Laserdesignator_03",
    // Optics
    "optic_Nightstalker"
] apply {toLowerANSI _x};

// Parse user settings
private _gen1Result = [KTWK_NVG_opt_gen1] call KTWK_NVG_fnc_resolveMagicWords;
private _userGen1 = if (_gen1Result isNotEqualTo []) then {
    (_gen1Result # 0) apply { toLowerANSI _x }
} else { [] };
if (_gen1Result isNotEqualTo [] && {(_gen1Result # 1) != ""}) then {
    ["KTWK_NVG_opt_gen1", _gen1Result # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _gen2Result = [KTWK_NVG_opt_gen2] call KTWK_NVG_fnc_resolveMagicWords;
private _userGen2 = if (_gen2Result isNotEqualTo []) then {
    (_gen2Result # 0) apply { toLowerANSI _x }
} else { [] };
if (_gen2Result isNotEqualTo [] && {(_gen2Result # 1) != ""}) then {
    ["KTWK_NVG_opt_gen2", _gen2Result # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _gen3Result = [KTWK_NVG_opt_gen3] call KTWK_NVG_fnc_resolveMagicWords;
private _userGen3 = if (_gen3Result isNotEqualTo []) then {
    (_gen3Result # 0) apply { toLowerANSI _x }
} else { [] };
if (_gen3Result isNotEqualTo [] && {(_gen3Result # 1) != ""}) then {
    ["KTWK_NVG_opt_gen3", _gen3Result # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

private _gen4Result = [KTWK_NVG_opt_gen4] call KTWK_NVG_fnc_resolveMagicWords;
private _userGen4 = if (_gen4Result isNotEqualTo []) then {
    (_gen4Result # 0) apply { toLowerANSI _x }
} else { [] };
if (_gen4Result isNotEqualTo [] && {(_gen4Result # 1) != ""}) then {
    ["KTWK_NVG_opt_gen4", _gen4Result # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
};

// Merge
KTWK_NVG_gen1 = _knownGen1 + _userGen1;
KTWK_NVG_gen2 = _knownGen2 + _userGen2;
KTWK_NVG_gen3 = _knownGen3 + _userGen3;
KTWK_NVG_gen4 = _knownGen4 + _userGen4;

KTWK_NVG_allItems = [];
KTWK_NVG_allItems append KTWK_NVG_gen1;
KTWK_NVG_allItems append KTWK_NVG_gen2;
KTWK_NVG_allItems append KTWK_NVG_gen3;
KTWK_NVG_allItems append KTWK_NVG_gen4;

// Clear cache
KTWK_NVG_cachedDetection = [1.0, 0, 1.0, 0.5, 0.003];
KTWK_NVG_cachedItemClass = "";
