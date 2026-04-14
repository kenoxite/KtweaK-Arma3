// KTWK_BM_fnc_set
// Applies brighter moonlight effect to specified targets
//
// Parameters:
//   _targets - Array of players to apply effect to (default: [])
//   _noWait  - Boolean: skip progressive transition (default: false)
// Returns:
//   Boolean - false if terrain excluded, true otherwise

if (!isServer) exitWith {false};

params [["_targets", []], ["_noWait", false]];

private _terrain = toLowerANSI worldName;
if (_terrain in KTWK_BM_excluded) exitWith {
    KTWK_BM_set = true;
    ["KTWK_BM_set", true, true] remoteExec ["setVariable", _targets];
    false
};

// Skip if in Livonia while having Contact DLC enabled
if (_terrain == "enoch" && {isClass (configFile >> "cfgVehicles" >> "B_A_AlienDrone_01_F")}) exitWith {
    KTWK_BM_set = true;
    ["KTWK_BM_set", true, true] remoteExec ["setVariable", _targets];
    false
};

private _altEffect = _terrain in KTWK_BM_altPpEffect_darker;
private _effect = call {
    if (KTWK_BM_opt_enabled == 1) exitWith {
        if (_altEffect) exitWith {
            [1.03, 0.97, 0, [0.5, 0.5, 1, 0.01], [1, 1, 1, 1], [-1, 0.8, 0.8, 0]];
        };
        [1.03, 0.97, 0, [0.5, 0.5, 1, 0.03], [1, 1, 1, 1], [-1, 0.8, 0.8, 0]];
    };
    if (KTWK_BM_opt_enabled == 2) exitWith {
        if (_altEffect) exitWith {
            [1.03, 0.97, 0, [0.5, 0.5, 1, 0.03], [1, 1, 1, 1], [-1, 0.8, 0.8, 0]];
        };
        [1.03, 0.97, 0.03, [0.5, 0.5, 1, 0.03], [1, 1, 1, 1], [-1, 0.8, 0.8, 0]];
    };
    [1.03, 0.97, 0, [0.5, 0.5, 1, 0.03], [1, 1, 1, 1], [-1, 0.8, 0.8, 0]];
};

// Aperture
private _aperture = call {
    if !(_terrain in KTWK_BM_noAperture) exitWith {
        if (_terrain in KTWK_BM_altAperture_narrow) exitWith {
            [4.5, 4.6, 4.7, 0.9]
        };
        if (_terrain in KTWK_BM_altAperture_mid) exitWith {
            [3.5, 3.6, 3.7, 0.9]
        };
        if (_terrain in KTWK_BM_altAperture_wide) exitWith {
            [2.7, 2.8, 2.9, 0.9]
        };
        if (_terrain in KTWK_BM_altAperture_ultraWide) exitWith {
            [2.3, 2.4, 2.5, 0.9]
        };
        [4, 4.1, 4.2, 0.9]
    };
    [];
};

private _debugStr = format ["[Brighter Moonlight] %1 night applied", ["", "Bright", "Brighter"] select KTWK_BM_opt_enabled];

call {
    if (_targets isEqualTo []) exitWith {
        KTWK_BM_set = true;
        [_effect, _aperture, _noWait] spawn KTWK_BM_fnc_set_client;
        if (!isNil "KTWK_opt_debug" && {KTWK_opt_debug}) then {
            systemChat _debugStr;
        };
    };
    [_effect, _aperture, _noWait] remoteExec ["KTWK_BM_fnc_set_client", _targets];
    if (!isNil "KTWK_opt_debug" && {KTWK_opt_debug}) then {
        _debugStr remoteExec ["systemChat", _targets];
    };
};

true
