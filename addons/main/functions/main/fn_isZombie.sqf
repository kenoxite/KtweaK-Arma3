// KTWK_fnc_isZombie
// Returns true if unit is a zombie or mutant type

params ["_unit"];
if (_unit in agents) then {_unit = agent _unit};
if (typeName _unit != "OBJECT") exitWith {false};
if (isNull _unit) exitWith {false};

(
    (["zombie", "dev_mutant_base", "DSA_SpookBase", "DSA_SpookBase2"] findIf { _unit isKindOf _x } != -1)
    || !isNil {_unit getVariable "WBK_AI_ISZombie"}
    || !isNil {_unit getVariable "isMutant"}
)
