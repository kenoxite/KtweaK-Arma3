// Toggle holster display
// by kenoxite

params [["_unit", player]];

if (_unit getVariable ["KTWK_swappingWeapon", false]) exitWith {false};

private ["_wpns"];
if (KTWK_equipNextWpn_opt_displayRifle) then {
    call {
        if (vehicle _unit == _unit) exitWith {
            // - Update rifle holster
            _wpns = [_unit, 1, false] call KTWK_fnc_equipNextWeapon;
            if (count _wpns > 0) then {
                [_unit, 1, 0, KTWK_equipNextWpn_opt_riflePos, (_wpns#1)] call KTWK_fnc_displayHolster;
            } else {
                [_unit, 1, 2] call KTWK_fnc_displayHolster;
            };
        };
        //  - Remove rifle holster
        [_unit, 1, 2] call KTWK_fnc_displayHolster;
    };
} else {
    //  - Remove rifle holster
    [_unit, 1, 2] call KTWK_fnc_displayHolster;
};
if (KTWK_equipNextWpn_opt_displayLauncher) then {
    call {
        if (vehicle _unit == _unit) exitWith {
            // - Update launcher holster
            _wpns = [_unit, 3, false] call KTWK_fnc_equipNextWeapon;
            if (count _wpns > 0) then {
                [_unit, 3, 0, KTWK_equipNextWpn_opt_launcherPos, (_wpns#1)] call KTWK_fnc_displayHolster;
            } else {
                [_unit, 3, 2] call KTWK_fnc_displayHolster;
            };
        };
        //  - Remove launcher holster
        [_unit, 3, 2] call KTWK_fnc_displayHolster;
    };
} else {
    //  - Remove launcher holster
    [_unit, 3, 2] call KTWK_fnc_displayHolster;
};
