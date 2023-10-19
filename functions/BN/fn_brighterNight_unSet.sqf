// Brighter nights - unSet
// by kenoxite

if (!isServer) exitwith {false};

params [["_targets", []], ["_noWait", false]];

private _debugStr = "[KtweaK] Bright Night disabled";
call {
    if (count _targets == 0) exitwith {
        KTWK_BN_set = false;
        [_noWait] call KTWK_fnc_brighterNight_unSet_client;
        if (KTWK_opt_debug) then { systemChat _debugStr };
    };
    [_noWait] remoteExec ["KTWK_fnc_brighterNight_unSet_client", _targets];
    if (KTWK_opt_debug) then { _debugStr remoteExec ["systemChat", _targets]};
};
