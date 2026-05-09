// KTWK_fnc_ENW_toggleHolsterDisplay
// Toggle holster display

// Parameters:
//   _unit - Unit to toggle holster display for (default: KTWK_player)
// Returns:
//   Boolean - false if display was skipped, true otherwise

params [["_unit", KTWK_player]];

if (_unit getVariable ["KTWK_swappingWeapon", false]) exitWith {false};

// Disable in pause menu
if (!isNull (findDisplay 49)) exitWith {false};

// Disable in Splendid Camera
if (!isNil "BIS_fnc_camera_cam") exitWith {false};

private _inVehicle = !isNull objectParent _unit;

// Toggle rifle holster
if (KTWK_ENW_opt_displayRifle) then {
    // Disable while in a vehicle to not disrupt AI driving/flying
    if (_inVehicle) exitWith {
        [_unit, 1, 2] call KTWK_fnc_ENW_displayHolster;
    };
    
    // Update rifle holster
    private _wpns = ([_unit, 1, false] call KTWK_fnc_ENW_equipNextWeapon) select {count _x > 0};
    
    if (count _wpns > 1 || {count _wpns == 1 && {primaryWeapon _unit == ""}}) then {
        [_unit, 1, 0, KTWK_ENW_opt_riflePos, _wpns select -1] call KTWK_fnc_ENW_displayHolster;
    } else {
        [_unit, 1, 2] call KTWK_fnc_ENW_displayHolster;
    };
} else {
    [_unit, 1, 2] call KTWK_fnc_ENW_displayHolster;
};

// Toggle launcher holster
if (KTWK_ENW_opt_displayLauncher) then {
    // Disable while in a vehicle to not disrupt AI driving/flying
    if (_inVehicle) exitWith {
        [_unit, 3, 2] call KTWK_fnc_ENW_displayHolster;
    };
    
    // Update launcher holster
    private _wpns = ([_unit, 3, false] call KTWK_fnc_ENW_equipNextWeapon) select {count _x > 0};
    
    if (count _wpns > 1 || {count _wpns == 1 && {secondaryWeapon _unit == ""}}) then {
        [_unit, 3, 0, KTWK_ENW_opt_launcherPos, _wpns select -1] call KTWK_fnc_ENW_displayHolster;
    } else {
        [_unit, 3, 2] call KTWK_fnc_ENW_displayHolster;
    };
} else {
    [_unit, 3, 2] call KTWK_fnc_ENW_displayHolster;
};

true
