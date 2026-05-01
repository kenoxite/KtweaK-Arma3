// KTWK_FMC_fnc_initClient
// Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_FMC_ktweak = isClass (_cfgPatches >> "ktweak");
_cfgPatches = nil;

// Player reference
if (!KTWK_FMC_ktweak) then {
    KTWK_player = [] call KTWK_FMC_fnc_getPlayer;
    KTWK_lastPlayer = KTWK_player;
};

// removeUserActionEventHandler ["SwitchPrimary", "Activate", KTWK_FMC_EH_switchPrimary];
// removeUserActionEventHandler ["NextWeapon", "Activate", KTWK_FMC_EH_nextWeapon];
// removeUserActionEventHandler ["PreviousWeapon", "Activate", KTWK_FMC_EH_previousWeapon];

// Override firemode cycling to restrict to main muzzle ones
if (isNil "KTWK_FMC_EH_switchPrimary") then {
    KTWK_FMC_EH_switchPrimary = addUserActionEventHandler ["SwitchPrimary", "Activate", {
        [KTWK_player, 1] call KTWK_FMC_fnc_cycleFiremode;
    }];
};
if (isNil "KTWK_FMC_EH_nextWeapon") then {
    KTWK_FMC_EH_nextWeapon = addUserActionEventHandler ["NextWeapon", "Activate", {
        [KTWK_player, 1] call KTWK_FMC_fnc_cycleFiremode;
    }];
};
if (isNil "KTWK_FMC_EH_previousWeapon") then {
    KTWK_FMC_EH_previousWeapon = addUserActionEventHandler ["PreviousWeapon", "Activate", {
        [KTWK_player, -1] call KTWK_FMC_fnc_cycleFiremode;
    }];
};

if (isNil "KTWK_FMC_EH_playerViewChanged") then {
    KTWK_FMC_EH_playerViewChanged = addMissionEventHandler ["PlayerViewChanged", {
        params ["_previousUnit", "_newUnit", "_vehicleIn","_oldCameraOn", "_newCameraOn", "_uav"];
        if (!KTWK_FMC_ktweak) then {
            KTWK_player = [_newUnit] call KTWK_FMC_fnc_getPlayer;
            KTWK_lastPlayer = KTWK_player;
        };
        if (_newUnit != _previousUnit) then {
            missionNamespace setVariable ["KTWK_FMC_lastFiremode", ""];
            missionNamespace setVariable ["KTWK_FMC_lastMuzzle", ""];
            missionNamespace setVariable ["KTWK_FMC_lastPrimary", ""];
            missionNamespace setVariable ["KTWK_FMC_lastMainFiremodeIdx", -1];
            missionNamespace setVariable ["KTWK_FMC_switchedToAlt", false];
            // Reset firemode to prevent starting with an AI-only one
            [_newUnit, 1, 0] call KTWK_FMC_fnc_cycleFiremode;
        };
    }];
};

// Reset vars on death
if (isNil "KTWK_FMC_EH_killed") then {
    KTWK_FMC_EH_killed = player addEventHandler ["Killed", {
        missionNamespace setVariable ["KTWK_FMC_lastFiremode", ""];
        missionNamespace setVariable ["KTWK_FMC_lastMuzzle", ""];
        missionNamespace setVariable ["KTWK_FMC_lastPrimary", ""];
        missionNamespace setVariable ["KTWK_FMC_lastMainFiremodeIdx", -1];
        missionNamespace setVariable ["KTWK_FMC_switchedToAlt", false];
    }];
};

// Reset vars on weapon change
if (isNil "KTWK_FMC_EH_weapon") then {
    KTWK_FMC_EH_weapon = ["Weapon", { 
        private _lastPrimary = missionNamespace getVariable ["KTWK_FMC_lastPrimary", ""];
        private _currentPrimary = primaryWeapon KTWK_player;
        if (_currentPrimary != _lastPrimary) then {
            missionNamespace setVariable ["KTWK_FMC_lastFiremode", ""];
            missionNamespace setVariable ["KTWK_FMC_lastMuzzle", ""];
            missionNamespace setVariable ["KTWK_FMC_lastPrimary", _currentPrimary];
            missionNamespace setVariable ["KTWK_FMC_lastMainFiremodeIdx", -1];
            missionNamespace setVariable ["KTWK_FMC_switchedToAlt", false];
        };
    }] call CBA_fnc_addPlayerEventHandler;
};
