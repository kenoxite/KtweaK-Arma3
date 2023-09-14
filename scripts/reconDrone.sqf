// GHOST RECON DRONE
// by kenoxite
// 
// Drone can be launched anytime as long as the player isn't in a vehicle and the drone is fully recharged, without the need to have equipped an UAV terminal.
// The drone will be deleted after manual disconnect, whenever the time runs out (battery) or if the drone is too far away (signal).
// It has unlimited uses but can be disabled any time with a global variable.
// All this can be copy/pasted in the console, in the init.sqf (if SP) or initplayerlocal.sqf (if MP)

// - Options
KTWK_GRdrone_allow = true; // Allow the use of the drone. Set to false anytime to disallow
KTWK_GRdrone_maxTime = 120;  // Maximum allowed time to fly the drone, in seconds
KTWK_GRdrone_maxDist = 200; // Maximum allowed horizontal distance from the player to the drone, in meters
KTWK_GRdrone_reuseTime = 60; // Seconds to wait until the drone can be reused, in seconds
// - 
KTWK_GRdrone_lastUse = time-KTWK_GRdrone_reuseTime; // Time since last used
KTWK_fnc_playerInUAV = {
    // Returns true if player is controlling the drone
    private _player = player;
    {
        private _UAVrole = (UAVControl _x) select 1;
        if ((player in UAVControl _x) && (_UAVrole != "")) then {
            _player = [_x, gunner _x] select (_UAVrole == "GUNNER")
        }
    } foreach allUnitsUAV;
    player != _player
};

KTWK_fnc_spawnGRdrone = {
    // Spawn the drone
    private _playerPos = getPos vehicle player;
    private _UAV = createVehicle ["B_UAV_01_F", vehicle player getRelPos [2, 0], [], 0, "NONE"];
    createVehicleCrew _UAV;
    private _grp = createGroup playerSide;
    {[_x] joinSilent _grp} count crew _UAV;
    // Disable misc stuff for the drone
    _UAV spawn {
        // Stalker Voices
        private _unitsArray = missionNamespace getVariable ["FGSVunits",[]];
        // Disable voices
        {
            _x setSpeaker "NoVoice";
            // Project SFX
            _x setVariable ["disableUnitSFX", true];
            // Disable Stalker Voices
            if !(isNil {_unitsArray}) then {
                waitUntil {sleep 1; _x in _unitsArray || !alive _x || isNull _x};
                if (alive _x) then {
                    private _idx = _unitsArray find _x;
                    _unitsArray deleteAt _idx;
                    missionNamespace setVariable ["FGSVunits",_unitsArray];
                };
            };
        } forEach crew _this;
    };
    // Position drone
    _UAV setDir getDir vehicle player;
    private _pos = getPos _UAV;
    private _posASL = AGLtoASL _pos;
    _UAV allowDamage false;
    KTWK_playerAllowDamage = isDamageAllowed player;
    player allowDamage false;
    driver _UAV action ["engineOn", _UAV];
    _UAV action ["autoHover", _UAV];
    // Start on the ground if inside a building and flying otherwise
    if (lineIntersects [_posASL, _posASL vectorAdd [0,0,10]]) then {
        _UAV setPosATL [_pos#0, _pos#1, getPosATL vehicle player #2 + 1];
        _UAV setVelocity [0, 0, 1];
    } else {
        _UAV setPosATL [_pos#0, _pos#1, getPosATL vehicle player #2 + 2];
        _UAV setVelocity [0, 0, 15];
    };
    // Give control to the player
    player remoteControl driver _UAV;
    _UAV switchCamera "internal";
    // Check for manual disconnects and automatic ones caused by the drone being too far away or time running out
    [_UAV, _playerPos] spawn {
        params ["_UAV", "_playerPos"];
        private _fnc_UAVdisconnect = {
            // Check if drone should be deleted due to distance or time
            params ["_time", "_UAV", "_UAVpos", "_playerPos"];
            private _disconnect = false;
            // Check for time
            if (_time >= KTWK_GRdrone_maxTime) then {
                _disconnect = true;
                hintSilent parseText "<t color='#FF0000'>Battery drained</t>";
            };
            // Check for distance
            if(_UAVpos distance2D _playerPos > KTWK_GRdrone_maxDist) then {
                _disconnect = true;
                hintSilent parseText "<t color='#FF0000'>Signal lost</t>";
            };
            // Return control to the player unit proper if there's an automatic disconnect
            if (_disconnect) then {
                objNull remoteControl driver _UAV;
                player switchCamera "internal";
            };
        };
        // Keep an eye on the current drone status
        private _timer = 0;
        private _batteryLeft = 100;
        while {alive _UAV && alive player && call KTWK_fnc_playerInUAV && KTWK_GRdrone_allow} do
        {
            // AI won't attack if altitude is over 25m
            // private _pos = getPosATL _UAV;
            // private _h = _pos#2;
            // if (_h > 25) then {
            //     _UAV setCaptive true;
            // } else {
            //     _UAV setCaptive false;
            // };
            // Display current drone status
            private _dist = round ((getPos _UAV) distance2D _playerPos);
            private _timeLeft = (KTWK_GRdrone_maxTime - _timer) max 0;
            _batteryLeft = 100 - round((round (KTWK_GRdrone_maxTime - _timeLeft)/KTWK_GRdrone_maxTime)*100);
            hintSilent parseText format [
                    "<t align='left'>Battery: <t color='#%3'>%1%5</t>
                    <br/>Signal: <t color='#%4'>%2</t>
                    </t>",
                    _batteryLeft,
                    if (_dist < KTWK_GRdrone_maxDist*0.25) then {"Strong"} else {if (_dist < KTWK_GRdrone_maxDist*0.5) then {"Normal"} else {if (_dist < KTWK_GRdrone_maxDist*0.75) then {"Weak"} else {"Very Weak"}}},
                    if (_batteryLeft > 50) then {"00FF00"} else {if (_batteryLeft > 25) then {"FFFF00"} else {"FF0000"}},
                    if (_dist < KTWK_GRdrone_maxDist*0.25) then {"00FF00"} else {if (_dist < KTWK_GRdrone_maxDist*0.5) then {"FFFF00"} else {if (_dist < KTWK_GRdrone_maxDist*0.75) then {"f78205"} else {"FF0000"}}},
                    "%"
                ];
            // Check for automatic disconnect
            [_timer, _UAV, getPos _UAV, _playerPos] call _fnc_UAVdisconnect;
            // Disable invincibility after 3 s
            if (_timer >= 3) then {
                _UAV allowDamage true;
                player allowDamage KTWK_playerAllowDamage;
            };
            // Project SFX
            player setVariable ["disableUnitSFX", true];
            // Update timer and wait
            _timer = _timer + 1;
            sleep 1;
        };
        // Delete drone if disconnected
        hintSilent "";
        // Set battery left to 0 if the drone was destroyed
        if (!alive _UAV) then { _batteryLeft = 0 };
        // Return control to player
        objNull remoteControl driver _UAV;
        player switchCamera "internal";
        // Project SFX
        player setVariable ["disableUnitSFX", false];
        // Delete the drone
        deleteVehicleCrew _UAV;
        deleteVehicle _UAV;
        // Keep track of the remaining battery since last use, so recharge will start at the current battery level
        KTWK_GRdrone_lastUse = time - (KTWK_GRdrone_reuseTime*(_batteryLeft/100));
    };
};

// Add player action to the menu
waitUntil {!isNull player && time > 1};
KTWK_GRdrone_Action = player addAction 
    [ 
        "<img image='\a3\ui_f\data\igui\cfg\actions\getinpilot_ca.paa' /> <t color='#00FF00'>Launch Recon Drone</t>",    // title 
        { 
            params ["_target", "_caller", "_actionId", "_arguments"]; // script
            if (KTWK_GRdrone_allow) then {
                if (vehicle player == player) then {
                    if ((time-KTWK_GRdrone_lastUse)>KTWK_GRdrone_reuseTime) then {
                        call KTWK_fnc_spawnGRdrone;
                    } else {
                            private _recharged = 100 - round((round (KTWK_GRdrone_reuseTime - (time-KTWK_GRdrone_lastUse))/KTWK_GRdrone_reuseTime)*100);
                            hintSilent parseText format [
                                "Recharging drone: <t color='#%3'>%1%2</t>",
                                _recharged,
                                "%",
                                if (_recharged > 50) then {"FFFF00"} else {"FF0000"}
                                ];
                    };
                } else {
                    hintSilent parseText "<t color='#FF0000'>Recon Drone not available inside vehicles</t>";
                };
            } else {
                hintSilent parseText "<t color='#FF0000'>Recon Drone not available</t>";
            };
        }, 
        nil,        // arguments 
        1.5,        // priority 
        false,       // showWindow 
        false,       // hideOnUse 
        "",         // shortcut 
        str (!call KTWK_fnc_playerInUAV),     // condition 
        -1,         // radius 
        false,      // unconscious 
        "",         // selection 
        ""          // memoryPoint 
    ];
