// KTWK_fnc_isHuman
// Returns true if unit is a human character

params ["_unit"];

if (_unit in agents) then {_unit = agent _unit};
if (typeName _unit != "OBJECT") exitWith {false};
if (isNull _unit) exitWith {false};

private _type = typeOf _unit;

(
    _type isKindOf "CAManBase"
    && {!(_type isKindOf "VirtualCurator_F")}
    && {!(_unit isKindOf "HeadlessClient_F")}
    && {!(unitIsUAV _unit)}
    && {!([_unit] call KEF_fnc_isAnimal)}
    && {!([_unit] call KEF_fnc_isZombie)}
)
