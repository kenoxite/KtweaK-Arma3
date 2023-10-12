// Changes the currently equipped primary/secondary/handgun weapon to other similar weapons in the player's inventory. Default keys are Ctrl+1, Ctrl+2 and Ctrl+3
// by kenoxite

if (!KTWK_equipNextWpn_opt_enabled) exitwith {[]};

params [["_unit", player], ["_slot", 2], ["_apply", true]];

// Only swap if player is actually playing
if (_apply && {!(isNull (findDisplay 602)) || {!(isNull (findDisplay 49)) || !(isNull (findDisplay 312)) || !(isNull (findDisplay 300))}}) exitWith {[]};
// Disable in arsenal
if (_apply && {!isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull])}) exitwith {[]};
// Disable for non humans
if !([_unit] call KTWK_fnc_isHuman) exitWith {[]};
// Disallow inside vehicles
if (_apply && {vehicle _unit != _unit}) exitWith {[]};
// Disallow when swimming, falling, etc
if (_apply && {stance _unit == "UNDEFINED" && !([_unit] call KTWK_fnc_inMelee)}) exitWith {[]};

private _baseClass = call {
    if (_slot == 1) exitWith {"Rifle_Base_F"};
    if (_slot == 2) exitWith {"Pistol_Base_F"};
    if (_slot == 3) exitWith {"Launcher_Base_F"};
    ""
};
if (_baseClass == "") exitWith {[]};
private _weapons = (weaponsItems _unit) select {
    (_x#0) isKindOf [_baseClass, configFile >> "CfgWeapons"]
};
// Don't swap if player only has one or no weapon
if (_apply && {count _weapons < 2}) exitWith {[]};

if (_apply) then { _unit setVariable ["KTWK_swappingWeapon", true, true] };

// Choose the weapon it will be swapped to
private _equippedWeaponClass = call {
    if (_slot == 1) exitWith { primaryWeapon _unit };
    if (_slot == 2) exitWith { handgunWeapon _unit };
    if (_slot == 3) exitWith { secondaryWeapon _unit };
};

private _rotation = [];
private _currentExcluded = false;
{
    if (!_currentExcluded && (_x#0) == _equippedWeaponClass) then {
        _currentExcluded = true;
    } else {
        _rotation pushBack _x     
    };
} forEach _weapons;

private _nextWeapon = [[],_rotation#0] select (count _rotation > 0);
private _nextWeaponClass = ["", (_rotation#0)#0] select (count _rotation > 0);

private _equippedWeapon = (_weapons select {(_x#0) == _equippedWeaponClass || (_x#0) == format ["%1_loaded",_equippedWeaponClass]})#0;
if (isNil {_equippedWeapon}) then {_equippedWeapon = []};

// Find where the next weapon is in the player's inventory and remove it (it will be equipped later). The old weapon will be placed in the same inventory slot
private _inUniform = _nextWeaponClass in uniformItems _unit;
private _inVest = _nextWeaponClass in vestItems _unit;
private _inBackpack = _nextWeaponClass in backpackItems _unit;
private _weaponContainer = "";
call {
    if (_inUniform) exitWith {
        if (_apply) then { _unit removeItemFromUniform _nextWeaponClass };
        _weaponContainer = uniformContainer _unit;
    };  
    if (_inVest) exitWith {
        if (_apply) then { _unit removeItemFromVest _nextWeaponClass };
        _weaponContainer = vestContainer _unit;
    };
    if (_inBackpack) exitWith {
        if (_apply) then { _unit removeItemFromBackpack _nextWeaponClass };
        _weaponContainer = backpackContainer _unit;
    };
};

private _stanceAnim = call {
    if (stance _unit == "STAND") exitWith {"erc"};  
    if (stance _unit == "CROUCH") exitWith {"knl"};  
    if (stance _unit == "PRONE") exitWith {"pne"};
    "erc" 
};

// Play holstering animation and proceed to swapping
private _isSlotWeapon = (currentWeapon _unit) isKindOf [_baseClass, configFile >> "CfgWeapons"];
if (_apply) then {
    private _isNotMeleeSwap = _slot != 2 || {!([_equippedWeaponClass] call ktwk_fnc_isMeleeWeapon) && !([_nextWeaponClass] call ktwk_fnc_isMeleeWeapon)};
    if (_isNotMeleeSwap && count _equippedWeapon > 0 && _isSlotWeapon) then {
        call {
            // if (_slot == 1) exitWith { _unit playMoveNow format ["AmovP%1MstpSrasWrflDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]; };
            // // if (_slot == 2) exitWith { _unit playMoveNow format ["AmovP%1MstpSrasWpstDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]; };
            // if (_slot == 2 && {stance _unit != "CROUCH"}) exitWith { _unit playMoveNow format ["AmovP%1MstpSrasWpstDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]; };
            // if (_slot == 2 && {stance _unit == "CROUCH"}) exitWith { _unit playMoveNow "AmovPknlMstpSrasWpstDnon_AinvPknlMstpSnonWnonDnon"; };
            // if (_slot == 3) exitWith { _unit playMoveNow format ["AmovP%1MstpSrasWlnrDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]; };

            if (_slot == 1) exitWith { [_unit, format ["AmovP%1MstpSrasWrflDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]] remoteExec ["playMoveNow", 0, _unit]; };
            if (_slot == 2 && {stance _unit != "CROUCH"}) exitWith { [_unit, format ["AmovP%1MstpSrasWpstDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]] remoteExec ["playMoveNow", 0, _unit]; };
            if (_slot == 2 && {stance _unit == "CROUCH"}) exitWith { [_unit, "AmovPknlMstpSrasWpstDnon_AinvPknlMstpSnonWnonDnon"] remoteExec ["playMoveNow", 0, _unit]; };
            if (_slot == 3) exitWith { [_unit, format ["AmovP%1MstpSrasWlnrDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]] remoteExec ["playMoveNow", 0, _unit]; };
        };
        [_unit, _slot, _equippedWeapon, _equippedWeaponClass, _nextWeapon, _nextWeaponClass, _weaponContainer, _inUniform, _inVest, _inBackpack] spawn KTWK_fnc_equipNextWeapon2;
    } else {
        [_unit, _slot, _equippedWeapon, _equippedWeaponClass, _nextWeapon, _nextWeaponClass, _weaponContainer, _inUniform, _inVest, _inBackpack] call KTWK_fnc_equipNextWeapon2;
    };
};

[_equippedWeapon, _nextWeapon]
