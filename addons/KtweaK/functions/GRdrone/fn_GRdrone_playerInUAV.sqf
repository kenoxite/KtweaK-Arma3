// Returns true if player is controlling the drone
private _player = player;
{
    private _UAVrole = (UAVControl _x) select 1;
    if ((player in UAVControl _x) && (_UAVrole != "")) then {
        _player = [_x, gunner _x] select (_UAVrole == "GUNNER")
    }
} foreach allUnitsUAV;
player != _player
