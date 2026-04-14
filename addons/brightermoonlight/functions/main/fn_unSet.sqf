// KTWK_BM_fnc_unSet
// Removes brighter moonlight effect from specified targets
//
// Parameters:
//   _targets - Array of players to remove effect from (default: [])
//   _noWait  - Boolean: skip progressive transition (default: false)
// Returns:
//   Boolean - true

if (!isServer) exitWith {false};

params [["_targets", []], ["_noWait", false]];

private _debugStr = "[Brighter Moonlight] Disabled";

call {
    if (_targets isEqualTo []) exitWith {
        KTWK_BM_set = false;
        [_noWait] call KTWK_BM_fnc_unSet_client;
        if (!isNil "KTWK_opt_debug" && {KTWK_opt_debug}) then {
            systemChat _debugStr;
        };
    };
    [_noWait] remoteExec ["KTWK_BM_fnc_unSet_client", _targets];
    if (!isNil "KTWK_opt_debug" && {KTWK_opt_debug}) then {
        _debugStr remoteExec ["systemChat", _targets];
    };
};

true
