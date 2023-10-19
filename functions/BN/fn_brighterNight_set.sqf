// Brighter nights - Set
// by kenoxite

if (!isServer) exitwith {false};
params [["_targets", []], ["_noWait", false]];

private _terrain = toLowerAnsi worldName;
if (_terrain in KTWK_BN_excluded) exitwith {
    KTWK_BN_set = true;
    ["KTWK_BN_set", true, true] remoteExec ["setVariable", _targets];
    false
};

// Skip if in Livonia while having Contact DLC enabled
if (_terrain == "enoch" && {isClass (configFile >> "cfgVehicles" >> "B_A_AlienDrone_01_F")}) exitwith {
    KTWK_BN_set = true;
    ["KTWK_BN_set", true, true] remoteExec ["setVariable", _targets];
    false
};

private _altEffect = _terrain in KTWK_BN_altPpEffect_darker;
private _effect = call {
    if (KTWK_BN_opt_enabled == 1) exitWith {
        if (_altEffect) exitWith {
            [1.03,0.97,0,[0.5,0.5,1,0.01],[1,1,1,1],[-1,0.8,0.8,0]];
        };
        [1.03,0.97,0,[0.5,0.5,1,0.03],[1,1,1,1],[-1,0.8,0.8,0]];
    };
    if (KTWK_BN_opt_enabled == 2) exitWith {
        if (_altEffect) exitWith {
            [1.03,0.97,0,[0.5,0.5,1,0.03],[1,1,1,1],[-1,0.8,0.8,0]];
        };
        [1.03,0.97,0.03,[0.5,0.5,1,0.03],[1,1,1,1],[-1,0.8,0.8,0]];
    };
    [1.03,0.97,0,[0.5,0.5,1,0.03],[1,1,1,1],[-1,0.8,0.8,0]];
};

// Aperture
private _aperture = call {
    if !(_terrain in KTWK_BN_noAperture) exitWith {
        if (_terrain in KTWK_BN_altAperture_narrow) exitWith {
            [4.5, 4.6, 4.7, 0.9]
        };
        if (_terrain in KTWK_BN_altAperture_mid) exitWith {
            [3.5, 3.6, 3.7, 0.9]
        };
        if (_terrain in KTWK_BN_altAperture_wide) exitWith {
            [2.7, 2.8, 2.9, 0.9]
        };
        if (_terrain in KTWK_BN_altAperture_ultraWide) exitWith {
            [2.3, 2.4, 2.5, 0.9]
        };
        [4, 4.1, 4.2, 0.9]
    };
    [];
};

private _debugStr = format ["[KtweaK] %1 Night applied", ["", "Bright", "Brighter"] select KTWK_BN_opt_enabled];
call {
    if (count _targets == 0) exitwith {
        KTWK_BN_set = true;
        [_effect, _aperture, _noWait] call KTWK_fnc_brighterNight_set_client;
        if (KTWK_opt_debug) then { systemChat _debugStr };
    };
    [_effect, _aperture, _noWait] remoteExec ["KTWK_fnc_brighterNight_set_client", _targets];
    if (KTWK_opt_debug) then { _debugStr remoteExec ["systemChat", _targets]};
};
