// Controls the chance and starts the action of sliding in a slope
// by kenoxite

params [["_unit", objNull]];

// Check for conditions that would prevent falling
if (
    isNull _unit || 
    {!local _unit} || 
    {!([_unit] call KTWK_fnc_isHuman)} || 
    {(count (KTWK_SiS_excluded select { _unit isKindOf _x}) > 0)} || 
    {!alive _unit} || 
    {vehicle _unit != _unit} ||
    {_unit getVariable ["KTWK_isSlopeSliding", false]} ||
    {(getPosATL _unit)#2 >= 1} ||
    {abs speed _unit < 3}
) exitWith {false};

// Calculate terrain gradient and unit speed
private _terrainGrad = [getPos _unit, getDir _unit] call BIS_fnc_terrainGradAngle;
private _speed = speed _unit;
private _absGrad = abs _terrainGrad;

// Determine if conditions guarantee a fall
private _isSureFall = (_absGrad > 30 && _speed > 4) || (_absGrad > 20 && _speed > 12) || _absGrad > 45;

if (!_isSureFall) exitWith {false};

// Calculate the unit's balance, factoring in rain
private _rainEffect = [0, rain * 0.5] select (rain > 0 && !(rainParams params ["_snow"]));
private _balance = if (isStaminaEnabled _unit) then {
    (((1 - (getFatigue _unit)) - load _unit) max 0) + (skill _unit / 2) - _rainEffect
} else {
    (load _unit) + (skill _unit / 3) - _rainEffect
};

// Check if the unit falls and handle the fall
if (random 1 > _balance) then {
    // Create a sound emitter and play a grunt sound
    private _soundEmitter = "Land_HelipadEmpty_F" createVehicleLocal (getPos _unit);
    [_soundEmitter, format ["KTWK_gruntMan%1", (floor (random 4)) + 1]] remoteExecCall ["say3D"];
    
    // Clean up the sound emitter after 2 seconds
    [_soundEmitter] spawn {
        params ["_emitter"];
        sleep 2;
        deleteVehicle _emitter;
    };

    // Initiate the appropriate sliding behavior based on slope direction
    [_unit] spawn (if (_terrainGrad > 0) then {KTWK_fnc_slideUpSlope} else {KTWK_fnc_slideDownSlope});
};

true
