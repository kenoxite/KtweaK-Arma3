// KTWK_NVG_fnc_getPlayer
// Returns the actual unit controlled by the player, accounting for drones and Zeus remote control
//
// Parameters:
//   None
// Returns:
//   Object - The actual controlled unit

private _unit = player;

// Check for controlled drones
{
    private _UAVControl = UAVControl _x;
    private _UAVrole = _UAVControl # 1;
    if ((_unit in _UAVControl) && (_UAVrole != "")) then {
        _unit = [_x, gunner _x] select (_UAVrole == "GUNNER");
    };
} forEach allUnitsUAV;

// Check for Zeus controlled units
private _curatorModule = allCurators select 0;
if (isNil "_curatorModule") exitWith { _unit };

private _curatorUnit = getAssignedCuratorUnit _curatorModule;
private _curatorObjects = curatorEditableObjects _curatorModule select { typeOf _x isKindOf "CAManBase" };
private _curatorControlledUnit = [];
if (side _unit == sideLogic) then {
    if (cameraOn != _unit) then { _curatorControlledUnit = [cameraOn] };
} else {
    _curatorControlledUnit = _curatorObjects select { _x getVariable "bis_fnc_moduleremotecontrol_owner" isEqualTo _curatorUnit };
};

[
    [_unit, _curatorControlledUnit # 0] select (_curatorControlledUnit isNotEqualTo []),
    _unit
] select (isNil "_curatorControlledUnit");
