// Returns true if player is controlling the drone

params ["_unit", "_uav"];

private _remoteControlled = [] call KTWK_fnc_getPlayer;
_remoteControlled == _uav
