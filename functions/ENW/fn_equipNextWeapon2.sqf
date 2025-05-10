// Changes the currently equipped primary/secondary/handgun weapon to other similar weapons in the player's inventory. Default keys are Ctrl+1, Ctrl+2 and Ctrl+3
// by kenoxite

if (!KTWK_ENW_opt_enabled) exitwith {[]};
    
params ["_unit", "_slot", "_equippedWeapon", "_equippedWeaponClass", "_nextWeapon", "_nextWeaponClass", "_weaponContainer", "_inUniform", "_inVest", "_inBackpack"];

_unit setVariable ["KTWK_swappingWeapon", true, true];

if (canSuspend) then {
    // Wait for the previous animation to end
    sleep call {
        if (_slot == 1) exitWith {0.75};
        if (_slot == 2) exitWith {0.5};
        if (_slot == 3) exitWith {1.5};
    };
};

private _primWep = primaryWeapon _unit;
private _hgWep = handgunWeapon _unit;
private _secWep = secondaryWeapon _unit;

// Remove current weapon
if (count _equippedWeapon > 0) then {
    _unit removeWeaponGlobal call {
        if (_slot == 1) exitWith { _primWep };
        if (_slot == 2) exitWith { _hgWep };
        if (_slot == 3) exitWith { _secWep };
    };
};

private _nextWeaponMag1 = _nextWeapon #4;
private _nextWeaponMag2 = _nextWeapon #5;
if (count _nextWeaponMag1 > 0) then { _unit addMagazineGlobal (_nextWeaponMag1#0) };
if (count _nextWeaponMag2 > 0) then { _unit addMagazineGlobal (_nextWeaponMag2#0) };

// Add new weapon
_unit addWeapon _nextWeaponClass;

_primWep = primaryWeapon _unit;
_hgWep = handgunWeapon _unit;
_secWep = secondaryWeapon _unit;

// Add primary magazine to new weapon
if (count _nextWeaponMag1 > 0) then {
    call {
         if (_slot == 1) exitWith { _unit setAmmo [_primWep, (_nextWeaponMag1#1)] };
         if (_slot == 2) exitWith { _unit setAmmo [_hgWep, (_nextWeaponMag1#1)] };
         if (_slot == 3) exitWith { _unit setAmmo [_secWep, (_nextWeaponMag1#1)] };
    };
};
// Add secondary magazine to new weapon
if (count _nextWeaponMag2 > 0) then {
    private _muzzle = (getArray (configFile >> "cfgWeapons" >> _nextWeaponClass >> "muzzles"))#1;
    _unit setAmmo [_muzzle, (_nextWeaponMag2#1)];
};

// Remove any default weapon items
call {
    if (_slot == 1) exitWith { removeAllPrimaryWeaponItems _unit; };
    if (_slot == 2) exitWith { removeAllHandgunItems _unit; };
    if (_slot == 3) exitWith { removeAllSecondaryWeaponItems _unit; };
};

// Add weapon items to new weapon
call {
    if (_slot == 1) exitWith { {_unit addPrimaryWeaponItem (_nextWeapon#_x)} forEach [1,2,3,6]; };
    if (_slot == 2) exitWith { {_unit addHandgunItem (_nextWeapon#_x)} forEach [1,2,3,6]; };
    if (_slot == 3) exitWith { {_unit addSecondaryWeaponItem (_nextWeapon#_x)} forEach [1,2,3,6]; };
};

// Unholster new weapon
if (canSuspend) then {
    // Can't apply speed up to the following anims, so don't bother
    call {
        if (_slot == 1) exitWith { _unit selectWeapon _primWep; };
        // if (_slot == 2) exitWith { _unit selectWeapon _hgWep; };
        if (_slot == 2 && {stance _unit != "CROUCH"}) exitWith { _unit selectWeapon _hgWep; };
        if (_slot == 2 && {stance _unit == "CROUCH"}) exitWith { _unit selectWeapon _hgWep; [_unit, "AinvPknlMstpSnonWnonDnon_AmovPknlMstpSrasWpstDnon"] remoteExec ["playMoveNow", 0, _unit]; };
        if (_slot == 3) exitWith { _unit selectWeapon _secWep; };
    };
};

// Check for overflow
private _overflow = call {
    if (count _equippedWeapon > 0 && {_inUniform && !(_unit canAddItemToUniform _equippedWeaponClass)}) exitWith {true};
    if (count _equippedWeapon > 0 && {_inVest && !(_unit canAddItemToVest _equippedWeaponClass)}) exitWith {true};
    if (count _equippedWeapon > 0 && {_inBackpack && !(_unit canAddItemToBackpack _equippedWeaponClass)}) exitWith {true};
    false
};

// Place old weapon in the unit inventory or drop it to the ground or the vehicle cargo if overflowing. 
if (!_overflow) then {
    if (count _equippedWeapon > 0) then { _weaponContainer addWeaponWithAttachmentsCargoGlobal [_equippedWeapon, 1] };

    // Display next weapon
    if ((KTWK_ENW_opt_displayRifle && {_slot == 1}) || (KTWK_ENW_opt_displayLauncher && {_slot == 3})) then {
        private _wpns = [_unit, _slot, false] call KTWK_fnc_equipNextWeapon;
        if (count _wpns > 0) then {
            [_unit, _slot, 0, [KTWK_ENW_opt_riflePos, -1, KTWK_ENW_opt_launcherPos] select (_slot-1), (_wpns#1)] call KTWK_fnc_displayHolster;
        };
    };
} else {
    private _wpnName = getText (configFile >> "cfgWeapons" >> _equippedWeaponClass >> "displayName");
    private _slotName = call {
        if (_inUniform) exitWith {"uniform"};
        if (_inVest) exitWith {"vest"};
        if (_inBackpack) exitWith {"backpack"};
    };
    systemChat format ["'%1' can't fit in the %2. %3", _wpnName, _slotName, if (vehicle _unit == _unit) then {"Dropping it to the ground."} else {"Moving it to the vehicle's cargo."}];
    private _wh = if (vehicle _unit == _unit) then {
                    createVehicle ["GroundWeaponHolder", _unit getRelPos [0.2, getDir _unit], [], 0, "CAN_COLLIDE"];
                } else {
                    vehicle _unit;
                };
    _wh addWeaponWithAttachmentsCargoGlobal [_equippedWeapon, 1];
};

_unit setVariable ["KTWK_swappingWeapon", false, true];

// Restore animation speed
[_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0];
    // - Add unit back to SOG AI fast movers array
    if (!isNil {jboy_FastMovers} && {_inSOGarray}) then {
        jboy_FastMovers pushBack _unit;
    };
