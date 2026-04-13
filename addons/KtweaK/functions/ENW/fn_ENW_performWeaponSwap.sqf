// KTWK_fnc_ENW_performWeaponSwap
// Performs the actual weapon swap operation after animation completes
//
// Parameters:
//   _unit               - Unit performing the swap
//   _slot               - Weapon slot: 1 = primary, 2 = handgun, 3 = launcher
//   _equippedWeapon     - Currently equipped weapon items array
//   _equippedWeaponClass - Currently equipped weapon class name
//   _nextWeapon         - Next weapon items array to equip
//   _nextWeaponClass    - Next weapon class name to equip
//   _weaponContainer    - Container where old weapon will be placed
//   _inUniform          - Boolean: next weapon was in uniform
//   _inVest             - Boolean: next weapon was in vest
//   _inBackpack         - Boolean: next weapon was in backpack
// Returns:
//   Nothing

if (!KTWK_ENW_opt_enabled) exitWith {[]};

params [
    "_unit",
    "_slot",
    "_equippedWeapon",
    "_equippedWeaponClass",
    "_nextWeapon",
    "_nextWeaponClass",
    "_weaponContainer",
    "_inUniform",
    "_inVest",
    "_inBackpack"
];

_unit setVariable ["KTWK_swappingWeapon", true, true];

// Wait for previous animation to end (if scheduled)
if (canSuspend) then {
    private _delay = call {
        if (_slot == 1) exitWith {0.75};
        if (_slot == 2) exitWith {0.5};
        if (_slot == 3) exitWith {1.5};
        0.5
    };
    sleep _delay;
};

// Cache current weapons
private _primWep = primaryWeapon _unit;
private _hgWep = handgunWeapon _unit;
private _secWep = secondaryWeapon _unit;

// Remove current weapon
if (_equippedWeapon isNotEqualTo []) then {
    private _wepToRemove = call {
        if (_slot == 1) exitWith {_primWep};
        if (_slot == 2) exitWith {_hgWep};
        if (_slot == 3) exitWith {_secWep};
        ""
    };
    if (_wepToRemove != "") then {
        _unit removeWeaponGlobal _wepToRemove;
    };
};

// Add magazines for new weapon
private _nextWeaponMag1 = _nextWeapon param [4, []];
private _nextWeaponMag2 = _nextWeapon param [5, []];

if (_nextWeaponMag1 isNotEqualTo []) then {
    _unit addMagazineGlobal (_nextWeaponMag1 select 0);
};
if (_nextWeaponMag2 isNotEqualTo []) then {
    _unit addMagazineGlobal (_nextWeaponMag2 select 0);
};

// Add new weapon
_unit addWeapon _nextWeaponClass;

// Refresh weapon references
_primWep = primaryWeapon _unit;
_hgWep = handgunWeapon _unit;
_secWep = secondaryWeapon _unit;

// Set primary magazine ammo count
if (_nextWeaponMag1 isNotEqualTo []) then {
    private _wepToAmmo = call {
        if (_slot == 1) exitWith {_primWep};
        if (_slot == 2) exitWith {_hgWep};
        if (_slot == 3) exitWith {_secWep};
        ""
    };
    if (_wepToAmmo != "") then {
        _unit setAmmo [_wepToAmmo, _nextWeaponMag1 select 1];
    };
};

// Set secondary magazine ammo count (if applicable)
if (_nextWeaponMag2 isNotEqualTo []) then {
    private _muzzles = getArray (configFile >> "CfgWeapons" >> _nextWeaponClass >> "muzzles");
    private _muzzle = _muzzles param [1, ""];
    if (_muzzle != "") then {
        _unit setAmmo [_muzzle, _nextWeaponMag2 select 1];
    };
};

// Remove default weapon items
call {
    if (_slot == 1) exitWith {removeAllPrimaryWeaponItems _unit};
    if (_slot == 2) exitWith {removeAllHandgunItems _unit};
    if (_slot == 3) exitWith {removeAllSecondaryWeaponItems _unit};
};

// Add weapon attachments
{
    private _item = _nextWeapon param [_x, ""];
    if (_item != "") then {
        call {
            if (_slot == 1) exitWith {_unit addPrimaryWeaponItem _item};
            if (_slot == 2) exitWith {_unit addHandgunItem _item};
            if (_slot == 3) exitWith {_unit addSecondaryWeaponItem _item};
        };
    };
} forEach [1, 2, 3, 6];

// Select and unholster new weapon
if (canSuspend) then {
    call {
        if (_slot == 1) exitWith {_unit selectWeapon _primWep};
        if (_slot == 2 && {stance _unit != "CROUCH"}) exitWith {_unit selectWeapon _hgWep};
        if (_slot == 2 && {stance _unit == "CROUCH"}) exitWith {
            _unit selectWeapon _hgWep;
            [_unit, "AinvPknlMstpSnonWnonDnon_AmovPknlMstpSrasWpstDnon"] remoteExec ["playMoveNow", 0, _unit];
        };
        if (_slot == 3) exitWith {_unit selectWeapon _secWep};
    };
};

// Check for inventory overflow
private _overflow = call {
    if (_equippedWeapon isNotEqualTo [] && {_inUniform && {!(_unit canAddItemToUniform _equippedWeaponClass)}}) exitWith {true};
    if (_equippedWeapon isNotEqualTo [] && {_inVest && {!(_unit canAddItemToVest _equippedWeaponClass)}}) exitWith {true};
    if (_equippedWeapon isNotEqualTo [] && {_inBackpack && {!(_unit canAddItemToBackpack _equippedWeaponClass)}}) exitWith {true};
    false
};

// Place old weapon in inventory or drop if overflowing
if (!_overflow) then {
    if (_equippedWeapon isNotEqualTo []) then {
        _weaponContainer addWeaponWithAttachmentsCargoGlobal [_equippedWeapon, 1];
    };
    
    // Update holster display
    private _shouldUpdateHolster = (_slot == 1 && {KTWK_ENW_opt_displayRifle}) || {_slot == 3 && {KTWK_ENW_opt_displayLauncher}};
    
    if (_shouldUpdateHolster) then {
        private _wpns = [_unit, _slot, false] call KTWK_fnc_ENW_equipNextWeapon;
        if (_wpns isNotEqualTo []) then {
            private _displayPos = [KTWK_ENW_opt_launcherPos, KTWK_ENW_opt_riflePos] select (_slot == 1);
            [_unit, _slot, 0, _displayPos, _wpns select 1] call KTWK_fnc_ENW_displayHolster;
        };
    };
} else {
    // Overflow handling
    private _wpnName = getText (configFile >> "CfgWeapons" >> _equippedWeaponClass >> "displayName");
    private _slotName = call {
        if (_inUniform) exitWith {"uniform"};
        if (_inVest) exitWith {"vest"};
        if (_inBackpack) exitWith {"backpack"};
        "inventory"
    };
    
    private _inVehicle = !isNull objectParent _unit;
    systemChat format [
        "'%1' can't fit in the %2. %3",
        _wpnName,
        _slotName,
        ["Moving it to the vehicle's cargo.", "Dropping it to the ground."] select _inVehicle
    ];
    
    private _wh = if (_inVehicle) then {
        vehicle _unit;
    } else {
        createVehicle ["GroundWeaponHolder", _unit getRelPos [0.2, getDir _unit], [], 0, "CAN_COLLIDE"];
    };
    
    _wh addWeaponWithAttachmentsCargoGlobal [_equippedWeapon, 1];
};

_unit setVariable ["KTWK_swappingWeapon", false, true];

// Restore animation speed
[_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0];

// Add unit back to SOG AI fast movers array
if (!isNil "jboy_FastMovers") then {
    jboy_FastMovers pushBackUnique _unit;
};
