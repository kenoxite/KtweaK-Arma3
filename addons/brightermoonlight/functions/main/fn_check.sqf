// KTWK_BM_fnc_check
// Checks conditions and applies brighter moonlight effect to players
//
// Parameters:
//   None
// Returns:
//   Boolean - false if not server or setting undefined, true otherwise

if (!isServer) exitWith {false};
if (isNil "KTWK_BM_opt_enabled") exitWith {false};

if (KTWK_BM_opt_enabled > 0 && {call KTWK_BM_fnc_isNight}) then {
    call {
        if (is3DEN && {(!isNil "KTWK_BM_set" && {!KTWK_BM_set}) || {KTWK_BM_lastOption != 0 && {KTWK_BM_lastOption != KTWK_BM_opt_enabled}}}) exitWith {
            [[], true] call KTWK_BM_fnc_set;
        };
        
        private _targets = call {
            // Update lighting if selected lighting has changed
            if (KTWK_BM_lastOption != 0 && {KTWK_BM_lastOption != KTWK_BM_opt_enabled}) exitWith {
                allPlayers select {_x getVariable ["KTWK_BM_set", false]}
            };
            // Or set normally
            allPlayers select {!(_x getVariable ["KTWK_BM_set", false])}
        };
        
        if (_targets isNotEqualTo []) then {
            if (KTWK_BM_lastOption == KTWK_BM_opt_enabled) then {
                [_targets, false] call KTWK_BM_fnc_set;
            } else {
                [_targets, true] call KTWK_BM_fnc_set;
            };
        };
    };
} else {
    call {
        if (is3DEN && {!isNil "KTWK_BM_set" && {KTWK_BM_set}}) exitWith {
            [[], true] call KTWK_BM_fnc_unSet;
        };
        
        private _targets = allPlayers select {_x getVariable ["KTWK_BM_set", false]};
        
        if (_targets isNotEqualTo []) then {
            if (KTWK_BM_opt_enabled > 0) then {
                [_targets, false] call KTWK_BM_fnc_unSet;
            } else {
                [_targets, true] call KTWK_BM_fnc_unSet;
            };
        };
    };
};

KTWK_BM_lastOption = KTWK_BM_opt_enabled;

true
