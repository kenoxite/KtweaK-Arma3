// KTWK_NVG_fnc_resolveMagicWords
// Resolves magic words in a comma-separated string to class names and sanitizes the input
//
// Parameters:
//   _input - Comma-separated string of items
// Returns:
//   Array - [_resolvedArray, _sanitizedString] or [] if input empty

params ["_input"];

_input = trim _input;
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
    private _item = trim _x;
    if (_item == "") then { continue };
    private _itemLower = toLowerANSI _item;
    private _resolvedItem = [_itemLower, KTWK_player] call _fnc_resolveWord;
    if (_resolvedItem == "") then { continue };
    _resolved pushBack toLowerANSI _resolvedItem;
    if (_resolvedItem != _itemLower) then { _changed = true };
} forEach _items;

// Always return sanitized string without lone commas or extra spaces
private _sanitizedInput = _resolved joinString ",";
[_resolved, _sanitizedInput]
