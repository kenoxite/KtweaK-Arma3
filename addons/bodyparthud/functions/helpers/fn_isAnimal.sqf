// KTWK_BPH_fnc_isAnimal
// Returns true if unit is an animal type
//
// Parameters:
//   _unit - Unit to check
// Returns:
//   Boolean - true if animal, false otherwise

params ["_unit"];

if (isNull _unit) exitWith {false};
if (_unit in agents) then {_unit = agent _unit};
if (typeName _unit != "OBJECT") exitWith {false};

private _type = typeOf _unit;
private _animals = [
    // DBO Horse
    "dbo_horse_Base_F",

    // Edaly animals
    "Edaly_Horse_Base",
    "Edaly_Boar_Base",
    "Edaly_Cattle_Base",
    "Edaly_Crab_Base",
    "Edaly_Crocodile_Base",
    "Edaly_Tiger_Base",
    "MFR_Dog_Base",

    // Dino Mod
    "max_Raptor",
    "max_Bront",
    "max_Bront_baby",
    "Max_Mega",
    "Max_Ples",
    "Max_PT",
    "max_TRex",
    "max_Tric",
    "max_tric_baby"
];

private _isAnimal = false;
{
    if (_type isKindOf _x) exitWith {_isAnimal = true};
} forEach _animals;

(_type isKindOf "CAManBase" && {_isAnimal})
