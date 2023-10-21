// Returns whether the weapon is considered to be physically short or not
// by kenoxite

params [["_wep", ""]];
if (_wep == "") exitWith {false};
private _primWep = toLowerAnsi _wep;
private _primWepType = (_primWep call BIS_fnc_itemType) select 1;
private _primWepDes = toLowerAnsi (getText (configFile >> "CfgWeapons" >> _primWep >> "descriptionShort"));

call {
    if (_primWepType == "SubmachineGun") exitWith {true};
    if ("submachine" in _primWepDes) exitWith {true};
    if ("smg" in _primWepDes) exitWith {true};
    if ("smg" in _primWep) exitWith {true};
    false;
};
