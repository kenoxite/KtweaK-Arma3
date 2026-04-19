// KTWK_NVG_fnc_sampleLighting
// Samples ambient lighting at player's look direction
//
// Parameters:
//   _mode - Current NVG mode
// Returns:
//   Array - [_light, _outOfRange]

params ["_mode"];

private _unit = KTWK_player;
private _probe = KTWK_NVG_lightingProbe;
private _isHmd = KTWK_NVG_isHmd;
private _isHmdADS = KTWK_NVG_isHmdADS;
private _isHmdADSNoScope = KTWK_NVG_isHmdADSNoScope;
private _inVeh = !isNull objectParent _unit;
private _veh = vehicle _unit;

// Get current generation for max range
private _genIndex = 0;
if (KTWK_NVG_opt_autoGen) then {
    _genIndex = ([_mode, _unit] call KTWK_NVG_fnc_getDeviceGen) # 0;
};
private _maxRange = KTWK_NVG_genMaxRange # _genIndex;
if (_mode == "MFD" || _mode == "vehicle") then { _maxRange = _maxRange * 2};
if (_mode == "rangefinder" || {_mode == "scoped"}) then { _maxRange = KTWK_NVG_opticZoom };

private _eye = eyePos _unit; 

// Get look direction based on player state
private _dir = if (_inVeh && {count (allTurrets [_veh, false]) > 0 && {_veh turretUnit [0] == _unit}}) then {
    private _weaponDir = _veh weaponDirection (currentWeapon _veh);
    private _turretDir = (_weaponDir select 0) atan2 (_weaponDir select 1);
    private _camDir = [_turretDir, 360 + _turretDir] select (_turretDir < 0);
    [sin _camDir, cos _camDir, 0]
} else {
    screenToWorldDirection [0.5,0.5]
};

private _scaledDir = _dir vectorMultiply 1000;
private _end = _eye vectorAdd _scaledDir; 
private _hits = lineIntersectsSurfaces [_eye, _end, _unit, objNull, true, 1]; 
private _lookingAtSky = _hits isEqualTo [];
private _idealPos = if (_lookingAtSky) then {getPosASL _unit} else {(_hits # 0) # 0}; 
    
private _maxRangeSqr = [-1, _maxRange * _maxRange] select (_maxRange > 0);
private _outOfRange = false; 
private _testPos = _idealPos; 
    
if (_lookingAtSky || {_maxRange > 0 && {_eye vectorDistanceSqr _idealPos > _maxRangeSqr}}) then { 
    _outOfRange = true; 
    _testPos = _eye vectorAdd (_dir vectorMultiply _maxRange); 
}; 
    
_probe setPosASL _testPos; 
private _look = getLightingAt _probe; 
private _ply = getLightingAt _unit; 
private _light = ((_look # 1) + (_ply # 1) + (_look # 3) + (_ply # 3)) / 2; 
    
KTWK_NVG_outOfRange = _outOfRange; 
[_light, _outOfRange]
