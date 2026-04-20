// KTWK_BPH_fnc_isHuman
// Returns true if unit is a human character
//
// Parameters:
//   _unit - Unit to check
// Returns:
//   Boolean - true if human, false otherwise

params ["_unit"];

if (isNull _unit) exitWith {false};
if (_unit in agents) then {_unit = agent _unit};
if (typeName _unit != "OBJECT") exitWith {false};

private _type = typeOf _unit;

(
    _type isKindOf "CAManBase" &&
    {!(_type isKindOf "VirtualCurator_F")} &&
    {!(_unit isKindOf "HeadlessClient_F")} &&
    {!(unitIsUAV _unit)} &&
    {!([_unit] call KTWK_BPH_fnc_isAnimal)} &&
    {!([_unit] call KTWK_BPH_fnc_isZombie)}
)
