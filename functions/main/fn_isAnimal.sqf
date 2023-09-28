
params ["_unit"];
if (_unit in agents) then {_unit = agent _unit};
private _type = typeOf _unit;
private _animals = [
    // DBO Horse
    "dbo_horse_Base_F",

    // Libertad animals
    "Edaly_Horse_Base",
    "Edaly_Boar_Base",
    "Edaly_Cattle_Base",
    "Edaly_Crab_Base",
    "Edaly_Crocodile_Base",
    "Edaly_Tiger_Base",
    "MFR_Dog_Base"
];
private _isAnimal = {if (_type isKindOf _x) exitWith {true}; false} forEach _animals;
(_type isKindOf "CAManBase" && {_isAnimal})
