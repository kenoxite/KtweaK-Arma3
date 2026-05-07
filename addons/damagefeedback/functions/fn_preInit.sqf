// KTWK_DFB preInit
// Damage Feedback - Server initialization

if (!isServer) exitWith {};

// EH - Game loaded from save
if (isNil "KTWK_DFB_EH_loaded") then {
    KTWK_DFB_EH_loaded = addMissionEventHandler ["Loaded", {
        params ["_saveType"];
        if (KTWK_DFB_opt_enabled) then {
            diag_log "[DFB] Loading from save. Restarting system...";
            [{
                !isNull player
                && !isNull findDisplay 46
            }, {
                execVM "z\ktweak\addons\damagefeedback\functions\fn_initClient.sqf";
            }] call CBA_fnc_waitUntilAndExecute;
        };
    }];
};
