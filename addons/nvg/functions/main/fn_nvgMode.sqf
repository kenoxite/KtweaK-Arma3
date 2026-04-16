// KTWK_NVG_fnc_nvgMode
// Returns current NVG usage mode
//
// Parameters:
//   _unit        - Unit to check
//   _veh         - Vehicle unit is in
//   _inVehicle   - Boolean: unit is in vehicle
//   _MFD         - Boolean: vehicle has MFD
//   _weaponZoom  - Current weapon's optics zoom value
// Returns:
//   String - NVG mode: "disabled", "standard", "scoped", "rangefinder", "vehicle", "helmet"

params ["_unit", "_veh", "_inVehicle", "_MFD", "_weaponZoom"];

private _isAiming = cameraView == "GUNNER";
private _disable = _MFD && {(driver _veh == _unit || gunner _veh == _unit)} && {!_isAiming};
private _zoom = [call KTWK_NVG_fnc_getZoom, 1] select _disable;

call {
    // MFD active
    if (_disable) exitWith { "disabled" };
    // Rangefinder/designator
    if (!_inVehicle && {_weaponZoom < 0.1} && {_isAiming}) exitWith { "rangefinder" };
    // Vehicle NVG
    if (_inVehicle && {((_veh currentVisionMode (_veh unitTurret _unit)) # 0) == 1} && {_isAiming}) exitWith { "vehicle" };
    // NVG scope
    if (!_inVehicle && {_zoom > 10} && {_isAiming}) exitWith { "scoped" };
    // Built-in helmet NVG
    private _headgear = headgear _unit;
    if (_headgear != "" && {toLowerANSI _headgear in KTWK_NVG_allItems}) exitWith { "helmet" };
    // Portable NVG
    "standard"
};
