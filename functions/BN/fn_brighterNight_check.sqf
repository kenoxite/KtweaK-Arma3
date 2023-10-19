// Brighter nights - Check
// by kenoxite

if (!isServer) exitwith {false};
if (isNil {KTWK_BN_opt_enabled}) exitwith {false};

if (KTWK_BN_opt_enabled > 0 && {sunOrMoon < 1}) then {
    call {
        if (is3DEN && {(!isNil {KTWK_BN_set} && {!KTWK_BN_set}) || {(KTWK_BN_lastOption != 0 && {KTWK_BN_lastOption != KTWK_BN_opt_enabled})}}) exitWith {
            [[], true] call KTWK_fnc_brighterNight_set;
        };
        private _targets = call {
            // Update lighting if selected lighting has changed
            if (KTWK_BN_lastOption != 0 && {KTWK_BN_lastOption != KTWK_BN_opt_enabled}) exitwith { allPlayers select {_x getVariable ["KTWK_BN_set", false]} };
            // Or set normally
            allPlayers select {!(_x getVariable ["KTWK_BN_set", false])}
        };
        if (count _targets > 0) then {
            if (KTWK_BN_lastOption == KTWK_BN_opt_enabled) then {
                [_targets, false] call KTWK_fnc_brighterNight_set;
            } else {
                [_targets, true] call KTWK_fnc_brighterNight_set;
            };
        };
    };
} else {
    call {
        if (is3DEN && {!isNil {KTWK_BN_set} && {KTWK_BN_set}}) exitWith {
            [[], true] call KTWK_fnc_brighterNight_unSet;
        };
        private _targets = allPlayers select {_x getVariable ["KTWK_BN_set", false]};
        if (count _targets > 0) then {
            if (KTWK_BN_opt_enabled > 0) then {
                [_targets, false] call KTWK_fnc_brighterNight_unSet;
            } else {
                [_targets, true] call KTWK_fnc_brighterNight_unSet;
            };
        };
    };
};
KTWK_BN_lastOption = KTWK_BN_opt_enabled;
