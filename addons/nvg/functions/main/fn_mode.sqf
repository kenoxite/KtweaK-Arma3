// KTWK_NVG_fnc_mode
// Returns current NVG usage mode
//
// Parameters:
//   _unit        - Unit to check
// Returns:
//   String - NVG mode: "standard", "scoped", "rangefinder", "vehicle", "helmet", "ADS", "MFD", "disabled"

params [["_unit", KTWK_player]];

private _isNVG = currentVisionMode _unit == 1;
private _isUAV = unitIsUAV _unit;
private _veh = vehicle _unit;
private _inVeh = _isUAV || {!isNull objectParent _unit};
private _vehicleMFD = KTWK_NVG_vehicleMFD;
private _wpnZoom = KTWK_NVG_weaponZoom;
private _aiming = cameraView == "GUNNER";
private _mfd = _vehicleMFD && {driver _veh == _unit || gunner _veh == _unit} && {!_aiming};

// MFD active
if (_mfd) exitWith {
    if (!_isNVG) exitWith {"disabled"};
    "MFD"
};

// Vehicle turret with NV active
if (_inVeh && {_aiming}) exitWith {
    private _turretPath = _veh unitTurret _unit;
    private _isRealTurret = count _turretPath > 0 && {_turretPath # 0 >= 0};
    private _isNVActive = ((_veh currentVisionMode _turretPath) # 0) == 1;
    // Vehicle turret - NV on
    if (_isRealTurret && {_isNVActive}) exitWith {"vehicle"};
    // Vehicle turret - NV off
    if (_isRealTurret && {_isUAV} && {!_isNVActive}) exitWith {"disabled"};
    // UAV pilot - NV on
    private _isUAVNVActive = ((_veh currentVisionMode [-1]) # 0) == 1;
    if (_isUAV && _isUAVNVActive) exitWith {"vehicle"};
    // UAV pilot - NV off
    if (_isUAV) exitWith {"disabled"};
    // Infantry turret - NV off
    if (!_isNVG) exitWith {"disabled"};
    // Infantry turret - NV on
    "ADS"
};

private _isScopeNVActive = ((_unit currentVisionMode (currentWeapon _unit)) # 0) == 1;
// Rangefinder/designator
if (_wpnZoom > 0 && _wpnZoom < 0.3 && {_isScopeNVActive} && {_aiming}) exitWith {"rangefinder"};

// NV scope
if (call KTWK_NVG_fnc_getZoom > 10 && {_isScopeNVActive} && {_aiming}) exitWith {"scoped"};

// Disabled
if (!_isNVG) exitWith {"disabled"};

// NVG - Aiming Down Sights
if (_aiming) exitWith {"ADS"};

// Built-in helmet NV
private _helm = headgear _unit;
if (_helm != "" && {toLowerANSI _helm in KTWK_NVG_allItems}) exitWith {"helmet"};

// NVG
"standard"
