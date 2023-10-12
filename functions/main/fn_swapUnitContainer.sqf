// Swap uniform, vest or backpack for another, transferring the old items to the new container
// by kenoxite

params [["_unit", objNull], "_containerType", ["_newContainer", ""], ["_allowOverflow", false], ["_deleteOverflow", false]];

if (isNull _unit) exitWith {false};
if (!local _unit) exitWith {false};

if (_newContainer == "") exitWith {false};

private _isUniform = toLowerAnsi _containerType == "uniform";
private _isVest = toLowerAnsi _containerType == "vest";
private _isBackpack = toLowerAnsi _containerType == "backpack";

// Exit if unit doesn't have the container needed to be swapped
if (_isUniform && {uniform _unit == ""}) exitWith {false};
if (_isVest && {vest _unit == ""}) exitWith {false};
if (_isBackpack && {backpack _unit == ""}) exitWith {false};

// Check for space of new container and warn and/or exit if is smaller than the old one
private _unitContainerOld = call {
        if (_isUniform) exitWith { uniform _unit };
        if (_isVest) exitWith { vest _unit };
        if (_isBackpack) exitWith { backpack _unit };
    };
private _oldContainerMaxLoad = call {
    if (_isBackpack) exitWith {
        getNumber (configFile >> "cfgVehicles" >> _unitContainerOld >> "maximumLoad");
    };
    parseNumber (((toLowerANSI (getText (configFile >> "CfgWeapons" >> _unitContainerOld >> "ItemInfo" >> "containerClass"))) splitString "supply")#0);
};
private _newContainerMaxLoad = call {
    if (_isBackpack) exitWith {
        getNumber (configFile >> "cfgVehicles" >> _newContainer >> "maximumLoad");
    };
    parseNumber (((toLowerANSI (getText (configFile >> "CfgWeapons" >> _newContainer >> "ItemInfo" >> "containerClass"))) splitString "supply")#0);
};
private _overflowing = _newContainerMaxLoad < _oldContainerMaxLoad;
if (_overflowing && {!_allowOverflow}) exitWith { diag_log format ["ERROR: New container '%1' has less capacity than '%2' and overflow isn't allowed. Cancelling swapping.", _newContainer, _unitContainerOld]; false };

// Wait until inventory screen is closed if unit is player
// if (isPlayer _unit && {!(isNull (findDisplay 602))}) exitWith {
if (isPlayer _unit && {_unit getVariable ["KTWK_invOpened", false]}) exitWith {
    _this spawn {
        // waitUntil {isNull (findDisplay 602)};
        waitUntil {!(_unit getVariable ["KTWK_invOpened", false])};
        _this call KTWK_fnc_swapUnitContainer;
    };
};

// _unit setVariable ["BIS_enableRandomization",false, true];

// Retrieve detailed info about the items, weapons and mags stored in the container
private _containerItems = ([_unit, _containerType] call KTWK_fnc_unitContainerItems) params ["_items", "_weapons", "_mags", "_grenades"];
// private _containerItems = ([_unit, _containerType] remoteExecCall ["KTWK_fnc_unitContainerItems", _unit]) params ["_items", "_weapons", "_mags", "_grenades"];

// Swap the old container with the new one
call {
    if (_isUniform) exitWith { removeUniform _unit; _unit forceAddUniform _newContainer; };
    if (_isVest) exitWith { removeVest _unit; _unit addVest _newContainer; };
    if (_isBackpack) exitWith { removeBackpack _unit; _unit addBackpack _newContainer; };
};

private _overflowItems = [];
private _overflowWeapons = [];
private _overflowMags = [];
private _overflowGrenades = [];
// Add move all the stored stuff from the old one to the new one
// - Add items
{
    call {
        if (_isUniform) exitWith {
            if (_unit canAddItemToUniform _x) then {
                _unit addItemToUniform _x;
            } else {
                _overflowItems pushBack _x;
            };
        };
        if (_isVest) exitWith {
            if (_unit canAddItemToVest _x) then {
                _unit addItemToVest _x;
            } else {
                _overflowItems pushBack _x;
            };
        };
        if (_isBackpack) exitWith {
            if (_unit canAddItemToBackpack _x) then {
                _unit addItemToBackpack _x;
            } else {
                _overflowItems pushBack _x;
            };
        };
    };
} forEach _items;

private _unitContainer = call {
        if (_isUniform) exitWith { uniformContainer _unit };
        if (_isVest) exitWith { vestContainer _unit };
        if (_isBackpack) exitWith { backpackContainer _unit };
    };

// - Add weapons
private _canAdd = true;
{
    call {
        if (_isUniform) exitWith {
            if !(_unit canAddItemToUniform (_x#0)) then {
                _canAdd = false;
                _overflowWeapons pushBack _x;
            };
        };
        if (_isVest) exitWith {
            if !(_unit canAddItemToVest (_x#0)) then {
                _canAdd = false;
                _overflowWeapons pushBack _x;
            };
        };
        if (_isBackpack) exitWith {
            if !(_unit canAddItemToBackpack (_x#0)) then {
                _canAdd = false;
                _overflowWeapons pushBack _x;
            };
        };
    };
    if (_canAdd) then { _unitContainer addWeaponWithAttachmentsCargoGlobal [_x, 1] };
} forEach _weapons;

// - Add magazines
_canAdd = true;
{
    call {
        if (_isUniform) exitWith {
            if !(_unit canAddItemToUniform (_x#0)) then {
                _canAdd = false;
                _overflowMags pushBack _x;
            };
        };
        if (_isVest) exitWith {
            if !(_unit canAddItemToVest (_x#0)) then {
                _canAdd = false;
                _overflowMags pushBack _x;
            };
        };
        if (_isBackpack) exitWith {
            if !(_unit canAddItemToBackpack (_x#0)) then {
                _canAdd = false;
                _overflowMags pushBack _x;
            };
        };
    };
    if (_canAdd) then { _unitContainer addMagazineAmmoCargo [_x#0, 1, _x#1]; };
} forEach _mags;

// - Add grenades
{
    call {
        if (_isUniform) exitWith {
            if (_unit canAddItemToUniform _x) then {
                _unit addItemToUniform _x;
            } else {
                _overflowGrenades pushBack _x;
            };
        };
        if (_isVest) exitWith {
            if (_unit canAddItemToVest _x) then {
                _unit addItemToVest _x;
            } else {
                _overflowGrenades pushBack _x;
            };
        };
        if (_isBackpack) exitWith {
            if (_unit canAddItemToBackpack _x) then {
                _unit addItemToBackpack _x;
            } else {
                _overflowGrenades pushBack _x;
            };
        };
    };
} forEach _grenades;

// Move overflow items to the ground
if (!_deleteOverflow && {(count _overflowItems > 0 || count _overflowWeapons > 0 || count _overflowMags > 0)}) then {
    // If unit is in vehicle, move the items to the vehicle cargo instead
    private _wh = if (vehicle _unit == _unit) then {
                    createVehicle ["Weapon_Empty", _unit getRelPos [0.2, getDir _unit], [], 0, "CAN_COLLIDE"];
                } else {
                    vehicle _unit;
                };
    {_wh addItemCargoGlobal [_x, 1]} forEach _overflowItems;
    {_wh addWeaponWithAttachmentsCargoGlobal [_x, 1]} forEach _overflowWeapons;
    {_wh addMagazineAmmoCargo [_x#0, 1, _x#1]} forEach _overflowMags;
    {_wh addMagazineCargoGlobal [_x, 1]} forEach _overflowGrenades;
};
