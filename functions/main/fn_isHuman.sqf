
params ["_unit"];
if (_unit in agents) then {_unit = agent _unit};
private _type = typeOf _unit;
(_type isKindOf "CAManBase" && !(_type isKindOf "dbo_horse_Base_F") && !(_type isKindOf "Edaly_Horse_Base") && !([_unit] call KTWK_fnc_isZombie))
