// by Killzone Kid

params [["_unit", objNull]];

if (isNull _unit) exitwith {false};

lineIntersectsSurfaces [
    getPosWorld _unit, 
    getPosWorld _unit vectorAdd [0, 0, 50], 
    _unit, objNull, true, 1, "GEOM", "NONE"
] select 0 params ["","","","_house"];
if (!isNil "_house" && {_house isKindOf "House"}) exitWith { true };
false
