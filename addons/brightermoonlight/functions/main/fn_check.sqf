// KTWK_BML_fnc_check
// Checks conditions and applies brighter moonlight effect to players
//
// Parameters:
//   None
// Returns:
//   Boolean - false if not server or setting undefined, true otherwise

if (!isServer) exitWith {false};
if (isNil "KTWK_BML_opt_enabled") exitWith {false};

if (isNil "KTWK_BML_lastOption") then {
    KTWK_BML_lastOption = KTWK_BML_opt_enabled;
};
if (isNil "KTWK_BML_lastExcluded") then {
    KTWK_BML_lastExcluded = KTWK_BML_opt_excludeTerrains;
};

// Force exlusion array update if in editor
private _excludedChanged = KTWK_BML_lastExcluded isNotEqualTo KTWK_BML_opt_excludeTerrains;
if (
    is3DEN
    && (_excludedChanged || {isNil "KTWK_BML_editorExclusionChecked"})
    ) then {
    if (isNil "KTWK_BML_editorExclusionChecked") then {
        KTWK_BML_editorExclusionChecked = true;
    };
    call KTWK_BML_fnc_updateExclusions;
};

// Check exclusion first
if (
    (toLowerANSI worldName) in KTWK_BML_excluded
    || (_excludedChanged && !KTWK_BML_wasExcluded)
    ) exitWith {
    private _targets = call {
        if (is3DEN) exitWith { [] };
        allPlayers select {_x getVariable ["KTWK_BML_set", false]};
    };
    [_targets, true] call KTWK_BML_fnc_unSet;
    KTWK_BML_wasExcluded = true;
    KTWK_BML_lastExcluded = KTWK_BML_opt_excludeTerrains;
    false
};

if (KTWK_BML_opt_enabled > 0 && {call KTWK_BML_fnc_isNight}) then {
    call {
        if (
            is3DEN
            && {
                (!isNil "KTWK_BML_set" && {!KTWK_BML_set})
                || (KTWK_BML_lastOption != 0
                && {KTWK_BML_lastOption != KTWK_BML_opt_enabled})
                || KTWK_BML_wasExcluded
            }
        ) exitWith {
            KTWK_BML_wasExcluded = false;
            [[], true] call KTWK_BML_fnc_set;
        };
        
        private _targets = call {
            // Update lighting if selected lighting has changed
            if (
                KTWK_BML_lastOption != 0
                && {KTWK_BML_lastOption != KTWK_BML_opt_enabled}
            ) exitWith {
                allPlayers select {_x getVariable ["KTWK_BML_set", false]}
            };
            // Or set normally
            allPlayers select {!(_x getVariable ["KTWK_BML_set", false])}
        };
        
        if (_targets isNotEqualTo []) then {
            if (KTWK_BML_lastOption == KTWK_BML_opt_enabled && !KTWK_BML_wasExcluded) then {
                [_targets, false] call KTWK_BML_fnc_set;
            } else {
                [_targets, true] call KTWK_BML_fnc_set;
            };
        };
    };
} else {
    call {
        if (
            is3DEN
            && {!isNil "KTWK_BML_set"
            && {KTWK_BML_set}}
        ) exitWith {
            [[], true] call KTWK_BML_fnc_unSet;
        };
        
        private _targets = allPlayers select {_x getVariable ["KTWK_BML_set", false]};
        
        if (_targets isNotEqualTo []) then {
            if (KTWK_BML_opt_enabled > 0) then {
                [_targets, false] call KTWK_BML_fnc_unSet;
            } else {
                [_targets, true] call KTWK_BML_fnc_unSet;
            };
        };
    };
};

KTWK_BML_lastOption = KTWK_BML_opt_enabled;
KTWK_BML_lastExcluded = KTWK_BML_opt_excludeTerrains;

true
