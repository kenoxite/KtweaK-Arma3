// Spawn the drone

if (isNil {KTWK_player}) then { KTWK_player = [] call KTWK_fnc_getPlayer; };
    
private _unit = KTWK_player;
private _playerPos = getPos vehicle _unit;
private _UAV = createVehicle ["B_UAV_01_F", vehicle _unit getRelPos [2, 0], [], 0, "NONE"];
_UAV setObjectTextureGlobal [0, "z\ktweak\addons\main\drones\air\uav_01\data\uav_01_black_co.paa"];
createVehicleCrew _UAV;
private _grp = createGroup playerSide;
{[_x] joinSilent _grp} count crew _UAV;

// Init drone stuff
if (!KTWK_GRdrone_opt_enableLaser) then { _UAV removeWeapon "Laserdesignator_mounted" };
if (!KTWK_GRdrone_opt_enableRadar) then { {_UAV enableInfoPanelComponent [_x,"SensorsDisplayComponent",false]} forEach ["left","right"]; };
if (!KTWK_GRdrone_opt_enableNV) then { _UAV disableNVGEquipment true };
if (!KTWK_GRdrone_opt_enableTI) then { _UAV disableTIEquipment true };

// Position drone
_UAV setDir (getDir vehicle _unit);
private _pos = getPos _UAV;
private _posASL = AGLToASL _pos;
_UAV allowDamage false;
KTWK_playerAllowDamage = isDamageAllowed _unit;
_unit allowDamage false;
driver _UAV action ["engineOn", _UAV];
_UAV action ["autoHover", _UAV];
// Start on the ground if inside a building and flying otherwise
if ([_unit, 10] call KTWK_fnc_underRoof) then {
    _UAV setPosATL [_pos#0, _pos#1, getPosATL vehicle _unit #2 + 1];
    _UAV setVelocity [0, 0, 1];
} else {
    _UAV setPosATL [_pos#0, _pos#1, getPosATL vehicle _unit #2 + 2];
    _UAV setVelocity [0, 0, 15];
};
// Give control to the player
_unit remoteControl driver _UAV;
_UAV switchCamera "internal";
// Check for manual disconnects and automatic ones caused by the drone being too far away or time running out
[_UAV, _playerPos] spawn {
    params ["_UAV", "_playerPos"];
    private _fnc_UAVdisconnect = {
        // Check if drone should be deleted due to distance or time
        params ["_time", "_unit", "_UAV", "_UAVpos", "_playerPos"];
        private _disconnect = false;
        // Check for time
        if (_time >= KTWK_GRdrone_opt_maxTime) then {
            _disconnect = true;
            hintSilent parseText "<t color='#FF0000'>Battery drained</t>";
        };
        // Check for distance
        if(_UAVpos distance2D _playerPos > KTWK_GRdrone_opt_maxDist) then {
            _disconnect = true;
            hintSilent parseText "<t color='#FF0000'>Signal lost</t>";
        };
        if (!alive _UAV) then {
            _disconnect = true;
            hintSilent parseText "<t color='#FF0000'>Drone destroyed</t>";
        };
        // Return control to the player unit proper if there's an automatic disconnect
        if (_disconnect) then {
            objNull remoteControl driver _UAV;
            _unit switchCamera "internal";
        };
    };
    // Keep an eye on the current drone status
    private _timer = 0;
    private _batteryLeft = 100;
    while {alive _UAV && alive player && KTWK_player ==_UAV && KTWK_GRdrone_opt_enabled} do
    {
        private _unit = KTWK_player;
        // AI won't attack if drone is at this altitude
        if (KTWK_GRdrone_opt_invisibleHeight >= 0) then {
            private _pos = getPosATL _UAV;
            private _h = _pos#2;
            if (_h >= KTWK_GRdrone_opt_invisibleHeight) then {
                _UAV setCaptive true;
            } else {
                _UAV setCaptive false;
            };
        };
        // Display current drone status
        private _dist = round ((getPos _UAV) distance2D _playerPos);
        private _timeLeft = (KTWK_GRdrone_opt_maxTime - _timer) max 0;
        _batteryLeft = 100 - round((round (KTWK_GRdrone_opt_maxTime - _timeLeft)/KTWK_GRdrone_opt_maxTime)*100);
        hintSilent parseText format [
                "<t align='left'>Battery: <t color='#%3'>%1%5</t>
                <br/>Signal: <t color='#%4'>%2</t>
                </t>",
                _batteryLeft,
                if (_dist < KTWK_GRdrone_opt_maxDist*0.25) then {"Strong"} else {if (_dist < KTWK_GRdrone_opt_maxDist*0.5) then {"Normal"} else {["Very Weak", "Weak"] select (_dist < (KTWK_GRdrone_opt_maxDist * 0.75))}},
                if (_batteryLeft > 50) then {"00FF00"} else {["FF0000", "FFFF00"] select (_batteryLeft > 25)},
                if (_dist < KTWK_GRdrone_opt_maxDist*0.25) then {"00FF00"} else {if (_dist < KTWK_GRdrone_opt_maxDist*0.5) then {"FFFF00"} else {["FF0000", "f78205"] select (_dist < (KTWK_GRdrone_opt_maxDist * 0.75))}},
                "%"
            ];
        // Check for automatic disconnect
        [_timer, _unit, _UAV, getPos _UAV, _playerPos] call _fnc_UAVdisconnect;
        // Disable invincibility after 3 s
        if (_timer >= 3) then {
            _UAV allowDamage true;
            _unit allowDamage KTWK_playerAllowDamage;
        };
        if (!KTWK_GRdrone_opt_enableRadar) then {
            {_UAV enableInfoPanelComponent [_x,"SensorsDisplayComponent",false]} forEach ["left","right"];
            {[_UAV, [0]] enableInfoPanelComponent [_x,"SensorsDisplayComponent",false]} forEach ["left","right"];
        };
        // Project SFX
        _unit setVariable ["disableUnitSFX", true, true];
        // Update timer and wait
        _timer = _timer + 1;
        sleep 1;
    };
    // Delete drone if disconnected
    hintSilent "";
    // Set battery left to 0 if the drone was destroyed
    if (!alive _UAV) then { _batteryLeft = 0 };
    _unit = KTWK_player;
    // Return control to player
    objNull remoteControl driver _UAV;
    _unit switchCamera "internal";
    // Project SFX
    _unit setVariable ["disableUnitSFX", false, true];
    // Delete the drone
    deleteVehicleCrew _UAV;
    deleteVehicle _UAV;
    // Keep track of the remaining battery since last use, so recharge will start at the current battery level
    KTWK_GRdrone_lastUse = time - (KTWK_GRdrone_opt_reuseTime*(_batteryLeft/100));
};
