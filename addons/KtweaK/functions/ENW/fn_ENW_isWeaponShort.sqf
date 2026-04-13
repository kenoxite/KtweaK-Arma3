// KTWK_fnc_ENW_isWeaponShort
// Returns whether the weapon is considered to be physically short or not
//
// Parameters:
//   _wep - Weapon class name to check (default: "")
// Returns:
//   Boolean - true if weapon is considered short, false otherwise

params [["_wep", ""]];

if (_wep == "") exitWith {false};

private _primWep = toLowerANSI _wep;
private _primWepType = (_primWep call BIS_fnc_itemType) param [1, ""];
private _primWepDes = toLowerANSI (getText (configFile >> "CfgWeapons" >> _primWep >> "descriptionShort"));

call {
    if (_primWepType == "SubmachineGun") exitWith {true};
    if ("submachine" in _primWepDes) exitWith {true};
    if ("smg" in _primWepDes) exitWith {true};
    if ("smg" in _primWep) exitWith {true};
    false
};
