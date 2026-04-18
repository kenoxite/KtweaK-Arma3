// KTWK_NVG_fnc_createIRLight
// Creates an IR light attached to player's head with parameters based on NVG generation
//
// Parameters:
//   _gen - NVG generation (1-4, default: 3)
// Returns:
//   Nothing

params [["_gen", 3], ["_uid", getPlayerUID player]];

private _conePars = call {
    if (_gen == 2) exitWith { [50, 12, 3.5] };
    if (_gen >= 3) exitWith { [45, 10, 3.5] };
    // Gen 1
    [60, 15, 3.5]
};

private _intensity = call {
    if (_gen == 2) exitWith { 275 };
    if (_gen >= 3) exitWith { 400 };
    // Gen 1
    150
};

private _ambient = call {
    if (_gen == 2) exitWith { [0.18,0.09,0.38] };
    if (_gen >= 3) exitWith { [0.2,0.1,0.4] };
    // Gen 1
    [0.15,0.08,0.35]
};

private _color = call {
    if (_gen == 2) exitWith { [0.28,0.18,0.58] };
    if (_gen >= 3) exitWith { [0.3,0.2,0.6] };
    // Gen 1
    [0.25,0.15,0.55]
};

private _attenuation = call {
    if (_gen == 2) exitWith { [0.8, 1.5, 3, 0.4] };
    if (_gen >= 3) exitWith { [0.5, 1, 2, 0.5] };
    // Gen 1
    [1, 2, 4, 0.3]
};

private _pos = call {
    if (_gen == 2) exitWith { [0, -0.01, 0.14] };
    if (_gen >= 3) exitWith { [0.07, -0.035, 0.14] };
    // Gen 1
    [0, -0.01, 0.14]
};

// Create the IR light
private _light = "#lightreflector" createVehicleLocal [0,0,0];  
// _light setLightVolumeShape ["a3\data_f\VolumeLightFlashlight.p3d", [1, 1, 1]];
_light setLightConePars _conePars;
_light setLightIntensity _intensity;
_light setLightAmbient _ambient;
_light setLightColor _color;
_light setLightAttenuation _attenuation;
_light setLightDayLight true;  
_light setLightUseFlare true;  
_light setLightIR true;

private _unit = _uid call BIS_fnc_getUnitByUID;
_light attachTo [_unit, _pos, "head", true];

KTWK_NVG_irLightManager pushBack [getPlayerUID _unit, _light];
