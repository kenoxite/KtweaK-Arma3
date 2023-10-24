// RECON DRONE
// by kenoxite
// 
// Drone can be launched anytime as long as the player isn't in a vehicle and the drone is fully recharged, without the need to have equipped an UAV terminal.
// The drone will be deleted after manual disconnect, whenever the time runs out (battery) or if the drone is too far away (signal).
// It has unlimited uses but can be disabled any time with a global variable.
// All this can be copy/pasted in the console, in the init.sqf (if SP) or initplayerlocal.sqf (if MP)
scriptName "Recon Drone";

KTWK_GRdrone_player = call KTWK_fnc_playerUnit;
KTWK_GRdrone_lastUse = time-KTWK_GRdrone_opt_reuseTime; // Time since last used

// Add player action to the menu
waitUntil {!isNull player && time > 1};

private _ace = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");

while {true} do {
    private _isAlive = alive KTWK_GRdrone_player;    // Check if the previously stored player unit is alive
    // Wait until respawn or team switch if dead
    if (!_isAlive) then {
        while {!alive player} do {
            sleep 0.5;
        };
    };
    // Check if player switched units
    private _playerUnit = KTWK_GRdrone_player;
    KTWK_GRdrone_player = [call KTWK_fnc_playerUnit, player] select (call KTWK_fnc_GRdrone_playerInUAV);
    if (KTWK_GRdrone_player != _playerUnit) then {
        // Player switched units, exit loop
        break;
    };
    // Manage adding and removing of drone action
    private _actionId = KTWK_GRdrone_player getVariable ["KTWK_GRdrone_actionId", -1];
    private _droneInInv = "KTWK_GRdrone" in (itemsWithMagazines _playerUnit);
    private _dronePrereqsMet = !KTWK_GRdrone_opt_itemRequired || {KTWK_GRdrone_opt_itemRequired && _droneInInv};
    if (KTWK_GRdrone_opt_enabled && _dronePrereqsMet) then {
        call {
            if (_ace && isNil {KTWK_GRdrone_aceAdded}) exitWith {
                private _condition = {
                    !(call KTWK_fnc_GRdrone_playerInUAV)
                };
                private _statement = {
                    [KTWK_GRdrone_player] call KTWK_fnc_GRdrone_action;
                    [KTWK_GRdrone_player, 1, ["ACE_SelfActions", "KTWK_GRdrone"]] call ace_interact_menu_fnc_removeActionFromObject;
                    KTWK_GRdrone_aceAdded = nil;
                };
                private _action = ["KTWK_GRdrone","Deploy Recon Drone","\a3\ui_f\data\igui\cfg\actions\getinpilot_ca.paa",_statement,_condition] call ace_interact_menu_fnc_createAction;
                [KTWK_GRdrone_player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;
                KTWK_GRdrone_aceAdded = true;
            };
            if (_actionId < 0) exitWith {
                [KTWK_GRdrone_player] call KTWK_fnc_GRdrone_addAction;
            };
        };
    } else {
        call {
            if (_ace && !isNil {KTWK_GRdrone_aceAdded}) exitWith {
                [KTWK_GRdrone_player, 1, ["ACE_SelfActions", "KTWK_GRdrone"]] call ace_interact_menu_fnc_removeActionFromObject;
                KTWK_GRdrone_aceAdded = nil;
            };
            if (_actionId >= 0) exitWith {
                KTWK_GRdrone_player removeAction _actionId;
                KTWK_GRdrone_player setVariable ["KTWK_GRdrone_actionId", nil, true];
            };
        };
    };
    sleep 1;
};
