// KTWK_CFM_fnc_initClient
// Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_CFM_ktweak = isClass (_cfgPatches >> "ktweak");
_cfgPatches = nil;

// Player reference
if (!KTWK_CFM_ktweak) then {
    KTWK_player = [] call KTWK_CFM_fnc_getPlayer;
    KTWK_lastPlayer = KTWK_player;
};

if (isNil "KTWK_CFM_EH_playerViewChanged") then {
    KTWK_CFM_EH_playerViewChanged = addMissionEventHandler ["PlayerViewChanged", {
        params ["_previousUnit", "_newUnit", "_vehicleIn","_oldCameraOn", "_newCameraOn", "_uav"];
        if (!KTWK_CFM_ktweak) then {
            KTWK_player = [_newUnit] call KTWK_CFM_fnc_getPlayer;
            KTWK_lastPlayer = KTWK_player;
        };
        if (_newUnit != _previousUnit) then {
            missionNamespace setVariable ["KTWK_CFM_lastMainFiremode", ""];
            missionNamespace setVariable ["KTWK_CFM_lastMainMuzzle", ""];
            missionNamespace setVariable ["KTWK_CFM_lastFiremode", ""];
            missionNamespace setVariable ["KTWK_CFM_lastMuzzle", ""];
            // Reset firemode to prevent starting with an AI-only one
            [_newUnit, 1, 0] call KTWK_CFM_fnc_cycleFiremode;
        };
    }];
};

// Reset vars on death
if (isNil "KTWK_CFM_EH_killed") then {
    KTWK_CFM_EH_killed = ["Killed", { 
        missionNamespace setVariable ["KTWK_CFM_lastMainFiremode", ""];
        missionNamespace setVariable ["KTWK_CFM_lastMainMuzzle", ""];
        missionNamespace setVariable ["KTWK_CFM_lastFiremode", ""];
        missionNamespace setVariable ["KTWK_CFM_lastMuzzle", ""];
    }] call CBA_fnc_addPlayerEventHandler;
};
