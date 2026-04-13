// KTWK_fnc_ENW_equipNextWeapon
// Changes the currently equipped weapon to other similar weapons in the player's inventory

// Default keys: Ctrl+1 (primary), Ctrl+2 (handgun), Ctrl+3 (launcher)
//
// Parameters:
//   _unit  - Unit to swap weapon for (default: player)
//   _slot  - Weapon slot: 1 = primary, 2 = handgun, 3 = launcher (default: 2)
//   _apply - Actually perform the swap (default: true)
// Returns:
//   Array - [_equippedWeapon, _nextWeapon]

params [["_unit", player], ["_slot", 2], ["_apply", true]];

if (!KTWK_ENW_opt_enabled) exitWith {[]};

// Cache config path (Wiki: "Config path delimiter" - cache for performance)
private _cfgWeapons = configFile >> "CfgWeapons";

// Only swap if player is actually playing
// Disable when inventory, pause menu, or other dialogs are open
if (_apply && {
    !isNull (findDisplay 602) ||
    {!isNull (findDisplay 49)} ||
    {!isNull (findDisplay 312)} ||
    {!isNull (findDisplay 300)}
}) exitWith {[]};

// Disable in arsenal
if (_apply && {!isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull])}) exitWith {[]};

// Disable for non-humans
if !([_unit] call KTWK_fnc_isHuman) exitWith {[]};

// Disallow inside vehicles
if (_apply && {!isNull objectParent _unit}) exitWith {[]};

// Disallow when swimming, falling, etc
if (_apply && {stance _unit == "UNDEFINED" && {!([_unit] call KTWK_fnc_inMelee)}}) exitWith {[]};

// Determine base weapon class by slot
private _baseClass = call {
    if (_slot == 1) exitWith {"Rifle_Base_F"};
    if (_slot == 2) exitWith {"Pistol_Base_F"};
    if (_slot == 3) exitWith {"Launcher_Base_F"};
    ""
};
if (_baseClass == "") exitWith {[]};

// Get all weapons of this type in inventory
private _weapons = (weaponsItems _unit) select {
    (_x select 0) isKindOf [_baseClass, _cfgWeapons]
};

// Don't swap if player only has one or no weapon of this type
if (_apply && {count _weapons < 2}) exitWith {[]};

if (_apply) then {
    _unit setVariable ["KTWK_swappingWeapon", true, true];
};

// Get currently equipped weapon class
private _equippedWeaponClass = call {
    if (_slot == 1) exitWith {primaryWeapon _unit};
    if (_slot == 2) exitWith {handgunWeapon _unit};
    if (_slot == 3) exitWith {secondaryWeapon _unit};
};

// Build rotation array excluding current weapon
private _rotation = [];
private _currentExcluded = false;
{
    if (!_currentExcluded && {(_x select 0) == _equippedWeaponClass}) then {
        _currentExcluded = true;
    } else {
        _rotation pushBack _x;
    };
} forEach _weapons;

// Get next weapon (first in rotation)
private _nextWeapon = if (_rotation isNotEqualTo []) then {_rotation select 0} else {[]};
private _nextWeaponClass = if (_rotation isNotEqualTo []) then {_nextWeapon select 0} else {""};

// Find equipped weapon array
private _equippedWeapon = (_weapons select {
    (_x select 0) == _equippedWeaponClass || {(_x select 0) == format ["%1_loaded", _equippedWeaponClass]}
}) param [0, []];
if (_equippedWeapon isEqualTo []) then {_equippedWeapon = []};

// Find where the next weapon is located
private _inUniform = _nextWeaponClass in uniformItems _unit;
private _inVest = _nextWeaponClass in vestItems _unit;
private _inBackpack = _nextWeaponClass in backpackItems _unit;

private _weaponContainer = "";
call {
    if (_inUniform) exitWith {
        if (_apply) then {_unit removeItemFromUniform _nextWeaponClass};
        _weaponContainer = uniformContainer _unit;
    };
    if (_inVest) exitWith {
        if (_apply) then {_unit removeItemFromVest _nextWeaponClass};
        _weaponContainer = vestContainer _unit;
    };
    if (_inBackpack) exitWith {
        if (_apply) then {_unit removeItemFromBackpack _nextWeaponClass};
        _weaponContainer = backpackContainer _unit;
    };
};

// Get stance abbreviation for animation
private _stanceAnim = call {
    if (stance _unit == "STAND") exitWith {"erc"};
    if (stance _unit == "CROUCH") exitWith {"knl"};
    if (stance _unit == "PRONE") exitWith {"pne"};
    "erc"
};

// Play holstering animation and proceed to swap
private _isSlotWeapon = (currentWeapon _unit) isKindOf [_baseClass, _cfgWeapons];

if (_apply) then {
    private _isMeleeEquipped = [_equippedWeaponClass] call KTWK_fnc_isMeleeWeapon;
    private _isMeleeNext = [_nextWeaponClass] call KTWK_fnc_isMeleeWeapon;
    private _isNotMeleeSwap = _slot != 2 || {!_isMeleeEquipped && {!_isMeleeNext}};
    
    if (_isNotMeleeSwap && {count _equippedWeapon > 0} && {_isSlotWeapon}) then {
        // Speed up animation
        // Remove unit from SOG AI fast movers array
        if (!isNil "jboy_FastMovers") then {
            jboy_FastMovers = jboy_FastMovers - [_unit];
        };
        
        [_unit, 3] remoteExecCall ["setAnimSpeedCoef", 0];
        
        call {
            if (_slot == 1) exitWith {
                [_unit, format ["AmovP%1MstpSrasWrflDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]] remoteExec ["playMoveNow", 0, _unit];
            };
            if (_slot == 2 && {stance _unit != "CROUCH"}) exitWith {
                [_unit, format ["AmovP%1MstpSrasWpstDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]] remoteExec ["playMoveNow", 0, _unit];
            };
            if (_slot == 2 && {stance _unit == "CROUCH"}) exitWith {
                [_unit, "AmovPknlMstpSrasWpstDnon_AinvPknlMstpSnonWnonDnon"] remoteExec ["playMoveNow", 0, _unit];
            };
            if (_slot == 3) exitWith {
                [_unit, format ["AmovP%1MstpSrasWlnrDnon_AmovP%1MstpSnonWnonDnon", _stanceAnim]] remoteExec ["playMoveNow", 0, _unit];
            };
        };
        
        [_unit, _slot, _equippedWeapon, _equippedWeaponClass, _nextWeapon, _nextWeaponClass, _weaponContainer, _inUniform, _inVest, _inBackpack] spawn KTWK_fnc_ENW_performWeaponSwap;
    } else {
        [_unit, _slot, _equippedWeapon, _equippedWeaponClass, _nextWeapon, _nextWeaponClass, _weaponContainer, _inUniform, _inVest, _inBackpack] call KTWK_fnc_ENW_performWeaponSwap;
    };
};

[_equippedWeapon, _nextWeapon]
