// KTWK_NVG_fnc_zoomIntensity
// Calculates intensity modifier based on zoom level and view state
//
// Parameters:
//   _unit        - Unit to check
//   _veh         - Vehicle unit is in
//   _inVehicle   - Boolean: unit is in vehicle
//   _MFD         - Boolean: vehicle has MFD
//   _weaponZoom  - Current weapon's optics zoom value
//   _intensity   - Base intensity from settings
// Returns:
//   Number - Modified intensity value

params ["_unit", "_veh", "_inVehicle", "_MFD", "_weaponZoom", "_intensity"];

private _isAiming = cameraView == "GUNNER";
private _disable = _MFD && {(driver _veh == _unit || gunner _veh == _unit)} && {!_isAiming};
private _zoom = [call KTWK_NVG_fnc_getZoom, 1] select _disable;

private _zoomIntensityMod = call {
    if (_disable) exitWith {1}; // Disable effect if MFD active
    if (!_inVehicle && {_weaponZoom < 0.1} && {_isAiming}) exitWith {28}; // Using rangefinder or similar
    if (_inVehicle && {((_veh currentVisionMode (_veh unitTurret _unit)) # 0) == 1} && {_isAiming}) exitWith {56}; // Using the vehicle's NV
    if (!_inVehicle && {_zoom > 10} && {_isAiming}) exitWith {16}; // Using scope with NV on
    9
};

_intensity * (_zoom / _zoomIntensityMod);
