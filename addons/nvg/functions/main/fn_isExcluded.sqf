// KTWK_NVG_fnc_isExcluded
// Checks if current NVG item is globally excluded
//
// Parameters:
//   _mode - Current NVG mode
//   _unit - Unit to check (player)
// Returns:
//   Boolean - True if item is globally excluded

params ["_mode", "_unit"];

private _inVeh = !isNull objectParent _unit;
if (_inVeh) exitWith { false };

private _itemClass = call {
    if (_mode == "helmet") exitWith { headgear _unit };
    if (_mode == "rangefinder") exitWith { currentWeapon _unit };
    if (_mode == "scoped") exitWith { (_unit weaponAccessories currentWeapon _unit) # 2 };
    if (_mode in ["standard","ADS"]) exitWith { hmd _unit };
    ""
};

_itemClass != "" && {toLowerANSI _itemClass in KTWK_NVG_excludeGlobal}
