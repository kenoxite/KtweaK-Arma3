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
    private _lower = toLowerANSI _word;
    call {
        if (_lower == "nvg") exitWith { hmd _unit };
        if (_lower == "helmet") exitWith { headgear _unit };
        if (_lower == "binoc") exitWith { currentWeapon _unit };
        if (_lower == "scope") exitWith { (_unit weaponAccessories currentWeapon _unit) # 2 };
        _word
    };
};

private _items = _input splitString ",";
private _resolved = [];
private _changed = false;

{
    private _item = _x trim [" ", 0];
    private _resolvedItem = [_item, KTWK_player] call _fnc_resolveWord;
    if (_resolvedItem == "") then { continue };
    _resolved pushBack _resolvedItem;
    if (_resolvedItem != _item) then { _changed = true };
} forEach _items;

if (_changed) then {
    _input = _resolved joinString ", ";
    [_resolved, _input]
} else {
    [_resolved, ""]
};
