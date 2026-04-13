//
if (isNil {IMS_Melee_Weapons}) exitWith {false};

params [["_unit", objNull]];
if (isNull _unit) exitWith {false};

(currentWeapon _unit in IMS_Melee_Weapons) || !(isNil {_unit getVariable "IMS_InFistsMode"})
