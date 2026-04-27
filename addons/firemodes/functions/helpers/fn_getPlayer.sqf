// KTWK_CFM_fnc_getPlayer
// Returns the actual unit controlled by the player, accounting for drones and Zeus remote control
//
// Parameters:
//   _unit - Object (optional) - Unit to check. Default: player
// Returns:
//   Object - The actual controlled unit

params [["_unit", player]];

[_unit, remoteControlled player] select (!isNull remoteControlled player)
