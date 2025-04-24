// RECON DRONE
// by kenoxite
// 
// Drone can be launched anytime as long as the player isn't in a vehicle and the drone is fully recharged, without the need to have equipped an UAV terminal.
// The drone will be deleted after manual disconnect, whenever the time runs out (battery) or if the drone is too far away (signal).
// It has unlimited uses but can be disabled any time with a global variable.
// All this can be copy/pasted in the console, in the init.sqf (if SP) or initplayerlocal.sqf (if MP)
scriptName "Recon Drone";

KTWK_player = call CBA_fnc_currentUnit;
KTWK_GRdrone_lastUse = time-KTWK_GRdrone_opt_reuseTime; // Time since last used

// Add player action to the menu
waitUntil {!isNull player && time > 1};

KTWK_GRdrone_PFH = [{
    params ["_args", "_handle"];

    private _isAlive = alive KTWK_player;
    if (!_isAlive) then {
        [_handle] call CBA_fnc_removePerFrameHandler;
        [{alive player}, {
            KTWK_GRdrone_PFH = _this call CBA_fnc_addPerFrameHandler;
        }, _this] call CBA_fnc_waitUntilAndExecute;
    } else {
        private _playerUnit = KTWK_player;
        KTWK_player = [call CBA_fnc_currentUnit, player] select (call KTWK_fnc_GRdrone_playerInUAV);
        if (KTWK_player != _playerUnit) then {
            [_handle] call CBA_fnc_removePerFrameHandler;
        } else {
            private _actionId = KTWK_player getVariable ["KTWK_GRdrone_actionId", -1];
            private _droneInInv = "KTWK_GRdrone" in (itemsWithMagazines _playerUnit);
            private _dronePrereqsMet = !KTWK_GRdrone_opt_itemRequired || {KTWK_GRdrone_opt_itemRequired && _droneInInv};
            if (KTWK_GRdrone_opt_enabled && _dronePrereqsMet) then {
                if (KTWK_aceInteractMenu && isNil {KTWK_GRdrone_aceAdded}) then {
                    private _condition = {
                        !(call KTWK_fnc_GRdrone_playerInUAV) && 
                        !(visibleMap)
                    };
                    private _statement = {
                        [KTWK_player] call KTWK_fnc_GRdrone_action;
                        [KTWK_player, 1, ["ACE_SelfActions", "KTWK_GRdrone"]] call ace_interact_menu_fnc_removeActionFromObject;
                        KTWK_GRdrone_aceAdded = nil;
                    };
                    private _action = ["KTWK_GRdrone","Deploy Recon Drone","\a3\ui_f\data\igui\cfg\actions\getinpilot_ca.paa",_statement,_condition] call ace_interact_menu_fnc_createAction;
                    [KTWK_player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;
                    KTWK_GRdrone_aceAdded = true;
                } else {
                    if (_actionId < 0) then {
                        [KTWK_player] call KTWK_fnc_GRdrone_addAction;
                    };
                };
            } else {
                if (KTWK_aceInteractMenu && !isNil {KTWK_GRdrone_aceAdded}) then {
                    [KTWK_player, 1, ["ACE_SelfActions", "KTWK_GRdrone"]] call ace_interact_menu_fnc_removeActionFromObject;
                    KTWK_GRdrone_aceAdded = nil;
                } else {
                    if (_actionId >= 0) then {
                        KTWK_player removeAction _actionId;
                        KTWK_player setVariable ["KTWK_GRdrone_actionId", nil, true];
                    };
                };
            };
        };
    };
}, 1, []] call CBA_fnc_addPerFrameHandler;
