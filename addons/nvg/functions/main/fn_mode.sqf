// KTWK_NVG_fnc_mode
// Returns current NVG usage mode
//
// Parameters:
//   _unit        - Unit to check
// Returns:
//   String - NVG mode: "standard", "scoped", "rangefinder", "vehicle", "helmet", "ADS", "MFD"

params [["_unit", KTWK_player]];

private _veh = vehicle _unit;
private _inVeh = !isNull objectParent _unit;
private _vehicleMFD = KTWK_NVG_vehicleMFD;
private _wpnZoom = KTWK_NVG_weaponZoom;
private _aiming = cameraView == "GUNNER";
private _mfd = _vehicleMFD && {driver _veh == _unit || gunner _veh == _unit} && {!_aiming};
// MFD active
if (_inVeh || _mfd) exitWith {
    if (((_veh currentVisionMode (_veh unitTurret _unit)) # 0) == 1 && {_aiming}) exitWith {"vehicle"};
    if (_mfd) exitWith {"MFD"};
    "standard"
};
// Rangefinder/designator
if (_wpnZoom > 0 && _wpnZoom < 0.1 && {_aiming}) exitWith {"rangefinder"};
// NV scope
if (call KTWK_NVG_fnc_getZoom > 10 && {_aiming}) exitWith {"scoped"};
// NVG - Aiming Down Sights
if (_aiming) exitWith {"ADS"};
// Built-in helmet NV
private _helm = headgear _unit;
if (_helm != "" && {toLowerANSI _helm in KTWK_NVG_allItems}) exitWith {"helmet"};
// NVG
"standard"
