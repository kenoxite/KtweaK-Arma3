// KTWK_DFB_fnc_isZombie
// Returns true if unit is a zombie or mutant type
//
// Parameters:
//   _unit - Unit to check
// Returns:
//   Boolean - true if zombie/mutant, false otherwise

params ["_unit"];

if (isNull _unit) exitWith {false};
if (_unit in agents) then {_unit = agent _unit};
if (typeName _unit != "OBJECT") exitWith {false};

(
    (["zombie", "dev_mutant_base", "DSA_SpookBase", "DSA_SpookBase2"] findIf {_unit isKindOf _x} != -1) ||
    {!isNil {_unit getVariable "WBK_AI_ISZombie"}} ||
    {!isNil {_unit getVariable "isMutant"}}
)
