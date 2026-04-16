// KTWK_NVG_fnc_colorFromCustom
// Returns color preset if item is in custom color arrays
//
// Parameters:
//   _itemClass - Item class name to check
// Returns:
//   Number - Color preset (0 if not found)

params ["_itemClass"];

private _itemLower = toLowerANSI _itemClass;

if (_itemLower in KTWK_NVG_wp) exitWith { 2 };
if (_itemLower in KTWK_NVG_amber) exitWith { 3 };
if (_itemLower in KTWK_NVG_bw) exitWith { 4 };
if (_itemLower in KTWK_NVG_crimson) exitWith { 5 };

0
