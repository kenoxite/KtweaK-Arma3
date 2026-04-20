// KTWK_NVG_fnc_resolveMagicWords
// Resolves magic words in a comma-separated string to class names
//
// Parameters:
//   _input - Comma-separated string of items
// Returns:
//   Array - [_resolvedArray, _updatedString] or [] if input empty

params ["_input"];

if (_input == "") exitWith { [] };

private _fnc_resolveWord = {
    params ["_word", "_unit"];
    call {
        if (_word == "nvg") exitWith { hmd _unit };
        if (_word == "helmet") exitWith { headgear _unit };
        if (_word == "binoc") exitWith { currentWeapon _unit };
        if (_word == "scope") exitWith { (_unit weaponAccessories currentWeapon _unit) # 2 };
        if (_word == "vehicle") exitWith { if (!isNull objectParent _unit) then { typeOf vehicle _unit } else {""} };
        _word
    };
};

private _items = _input splitString ",";
private _resolved = [];
private _changed = false;

{
    private _item = toLowerANSI (_x trim [" ", 0]);
    private _resolvedItem = [_item, KTWK_player] call _fnc_resolveWord;
    if (_resolvedItem == "") then { continue };
    _resolved pushBack toLowerANSI _resolvedItem;
    if (_resolvedItem != _item) then { _changed = true };
} forEach _items;

if (_changed) then {
    _input = _resolved joinString ", ";
    [_resolved, _input]
} else {
    [_resolved, ""]
};
