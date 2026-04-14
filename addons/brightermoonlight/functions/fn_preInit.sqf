// KTWK_BM preInit
// Brighter Moonlight - Server initialization

if (!isServer) exitWith {};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_BM_ktweak = isClass (_cfgPatches >> "ktweak_main");
_cfgPatches = nil;

// Debug fallback
if (isNil "KTWK_opt_debug") then {
    KTWK_opt_debug = false;
};

addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

    if (KTWK_BM_opt_enabled > 0 && {call KTWK_BM_fnc_isNight}) then {
        [[_id], true] call KTWK_BM_fnc_set;
    };
}];

// Initial check
call KTWK_BM_fnc_check;

// Let Ktweak deal with the recurring checks if present
if (KTWK_BM_ktweak) exitWith {};

// Recurring check
[{
    if (!isNull (findDisplay 49)) exitWith {};    // Don't check while paused

    call KTWK_BM_fnc_check;
}, 3] call CBA_fnc_addPerFrameHandler;
