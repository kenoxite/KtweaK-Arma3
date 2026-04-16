// KTWK_BML preInit
// Brighter Moonlight - Server initialization

if (!isServer) exitWith {};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_BML_ktweak = isClass (_cfgPatches >> "ktweak");
_cfgPatches = nil;

// Global variables
if (isNil "KTWK_opt_debug") then {
    KTWK_opt_debug = false;
};
KTWK_BML_wasExcluded = false;

// Build exclusion list
if (isNil "KTWK_BML_excluded") then {
    KTWK_BML_excluded = [];
};
call KTWK_BML_fnc_updateExclusions;

addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

    if (KTWK_BML_opt_enabled > 0 && {call KTWK_BML_fnc_isNight}) then {
        [[_id], true] call KTWK_BML_fnc_set;
    };
}];

// Initial check
call KTWK_BML_fnc_check;

// Let Ktweak deal with the recurring checks if present
if (KTWK_BML_ktweak) exitWith {};

// Recurring check
[{
    if (!isNull (findDisplay 49)) exitWith {};    // Don't check while paused

    call KTWK_BML_fnc_check;
}, 3] call CBA_fnc_addPerFrameHandler;
