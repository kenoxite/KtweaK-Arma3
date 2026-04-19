// KTWK_BML_fnc_resolveMagicWords
// Resolves magic words in a comma-separated string to terrain names
//
// Parameters:
//   _input - Comma-separated string of items
// Returns:
//   Array - [_resolvedArray, _updatedString] or [] if input empty

params ["_input"];

if (_input == "") exitWith { [] };

private _fnc_resolveWord = {
    params ["_word"];
    call {
        if (_word == "current") exitWith { toLowerANSI worldName };
        _word
    };
};

private _items = _input splitString ",";
private _resolved = [];
private _changed = false;

{
    private _item = toLowerANSI (_x trim [" ", 0]);
    private _resolvedItem = [_item] call _fnc_resolveWord;
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
