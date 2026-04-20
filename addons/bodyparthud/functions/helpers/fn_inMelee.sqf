// KTWK_BPH_fnc_inMelee
// Returns true if unit is in melee mode (IMS compatibility)
//
// Parameters:
//   _unit - Unit to check
// Returns:
//   Boolean - true if in melee mode, false otherwise

params [["_unit", objNull]];

if (isNull _unit) exitWith {false};
if (isNil "IMS_Melee_Weapons") exitWith {false};

(currentWeapon _unit in IMS_Melee_Weapons) || {!isNil {_unit getVariable "IMS_InFistsMode"}}
