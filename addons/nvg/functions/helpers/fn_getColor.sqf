// KTWK_NVG_fnc_getColor
// Returns color preset if item is in color arrays
//
// Parameters:
//   _itemClass - Item class name to check
// Returns:
//   Number - Color preset (0 if not found)

params ["_itemClass"];

// Check custom gear color first
if (_itemClass in KTWK_NVG_green_custom) exitWith { 1 };
if (_itemClass in KTWK_NVG_wp_custom) exitWith { 2 };
if (_itemClass in KTWK_NVG_amber_custom) exitWith { 3 };
if (_itemClass in KTWK_NVG_bw_custom) exitWith { 4 };
if (_itemClass in KTWK_NVG_crimson_custom) exitWith { 5 };

// Then generation color arrays
if (KTWK_NVG_opt_autoGen) exitWith {
    if (_itemClass in KTWK_NVG_green) exitWith { 1 };
    if (_itemClass in KTWK_NVG_wp) exitWith { 2 };
    if (_itemClass in KTWK_NVG_amber) exitWith { 3 };
    if (_itemClass in KTWK_NVG_bw) exitWith { 4 };
    if (_itemClass in KTWK_NVG_crimson) exitWith { 5 };
    1
};

0
