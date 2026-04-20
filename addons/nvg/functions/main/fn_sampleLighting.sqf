// KTWK_NVG_fnc_sampleLighting
// Samples ambient lighting at player's look direction
//
// Parameters:
//   _mode - Current NVG mode
// Returns:
//   Array - [_light, _rangeFactor]

#include "\z\ktweak\addons\nvg\cacheIndices.hpp"

params ["_mode"];

private _unit = KTWK_player;
private _probe = KTWK_NVG_lightingProbe;
private _inVeh = !isNull objectParent _unit;
private _veh = vehicle _unit;

// Get current generation for max range
private _genIndex = 0;
if (KTWK_NVG_opt_nvMode < 2) then {
    _genIndex = ([_mode, _unit] call KTWK_NVG_fnc_getDeviceGen) # 0;
};
private _genMaxRange = KTWK_NVG_genMaxRange # _genIndex;
private _cache = KTWK_NVG_cache;
private _maxRange = _cache # IDX_MAXRANGECACHED;    // cached max range for current mode
private _minZoomOffset = _cache # IDX_MINZOOMOFFSETCACHED;  // cached optic minimum zoom for scoped/rangefinder

// Calculate and cache range values if not already cached
if (_maxRange <= 0) then {
    _maxRange = _genMaxRange;
    if (_mode == "MFD" || _mode == "vehicle") then { 
        _maxRange = _maxRange * 2;  // vehicles have extended range
    };
    if (_mode == "rangefinder" || {_mode == "scoped"}) then { 
        _minZoomOffset = KTWK_NVG_opticZoomMin;
        _maxRange = (_minZoomOffset + _genMaxRange) min KTWK_NVG_opticZoomMax;  // optic min zoom adds to effective range
    };
    KTWK_NVG_cache set [IDX_MAXRANGECACHED, _maxRange];
    KTWK_NVG_cache set [IDX_MINZOOMOFFSETCACHED, _minZoomOffset];
};
private _eye = eyePos _unit; 

// Get look direction based on player state (vehicle turret or normal)
private _dir = if (_inVeh && {count (allTurrets [_veh, false]) > 0 && {_veh turretUnit [0] == _unit}}) then {
    private _weaponDir = _veh weaponDirection (currentWeapon _veh);
    private _turretDir = (_weaponDir select 0) atan2 (_weaponDir select 1);
    private _camDir = [_turretDir, 360 + _turretDir] select (_turretDir < 0);
    [sin _camDir, cos _camDir, 0]
} else {
    screenToWorldDirection [0.5,0.5]
};

// Raycast to find what player is looking at
private _scaledDir = _dir vectorMultiply 1000;
private _end = _eye vectorAdd _scaledDir; 
private _hits = lineIntersectsSurfaces [_eye, _end, _unit, objNull, true, 1]; 
private _lookingAtSky = _hits isEqualTo [];

// Early exit for sky - no distance calculation needed
if (_lookingAtSky) exitWith {
    _probe setPosASL (getPosASL _unit);
    private _look = getLightingAt _probe;
    private _ply = getLightingAt _unit;
    private _light = ((_look # 1) + (_ply # 1) + (_look # 3) + (_ply # 3)) / 2;
    KTWK_NVG_outOfRange = true;
    [_light, 1]
};

private _idealPos = (_hits # 0) # 0;
private _distance = _eye vectorDistance _idealPos;
private _effectiveDistance = _distance - _minZoomOffset;    // subtract optic min zoom for scoped modes
private _rangeFactor = 0;

// Quadratic progressive falloff: 0 at max range, 1 at 2x max range
if (_maxRange > 0 && {_effectiveDistance > _genMaxRange}) then {
    private _excess = (_effectiveDistance - _genMaxRange) / _genMaxRange;
    _rangeFactor = (_excess min 1.0) ^ 2;
};

// For OOR, sample lighting at max range distance instead of actual target position
private _testPos = if (_rangeFactor > 0) then {
    _eye vectorAdd (_dir vectorMultiply _maxRange)
} else {
    _idealPos
};

_probe setPosASL _testPos;
private _look = getLightingAt _probe;
private _ply = getLightingAt _unit;
private _light = ((_look # 1) + (_ply # 1) + (_look # 3) + (_ply # 3)) / 2;

KTWK_NVG_outOfRange = _rangeFactor > 0;
[_light, _rangeFactor]
