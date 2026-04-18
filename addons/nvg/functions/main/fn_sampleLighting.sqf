// KTWK_NVG_fnc_sampleLighting
// Samples ambient lighting at player's look direction
//
// Parameters:
//   _mode - Current NVG mode
// Returns:
//   Array - [_light, _outOfRange]

params ["_mode"];

private _player = KTWK_player;
private _probe = KTWK_NVG_lightingProbe;
private _isHmd = KTWK_NVG_isHmd;
private _isHmdADS = KTWK_NVG_isHmdADS;
private _isHmdADSNoScope = KTWK_NVG_isHmdADSNoScope;

// Get current generation for max range
private _genIndex = 0;
if (KTWK_NVG_opt_autoGen) then {
    _genIndex = ([_mode, _player] call KTWK_NVG_fnc_getDeviceGen) # 0;
};
private _maxRange = [-1, KTWK_NVG_genMaxRange # _genIndex] select (_isHmd || _isHmdADSNoScope);

private _eye = eyePos _player; 
private _dir = screenToWorldDirection [0.5,0.5]; 
private _scaledDir = _dir vectorMultiply 1000;
private _end = _eye vectorAdd _scaledDir; 
private _hits = lineIntersectsSurfaces [_eye, _end, _player, objNull, true, 1, "GEOM", "FIRE"]; 
private _lookingAtSky = _hits isEqualTo [] && (_isHmd || _isHmdADSNoScope || _isHmdADS);
private _idealPos = if (_lookingAtSky) then {getPosASL _player} else {(_hits # 0) # 0}; 
    
private _maxRangeSqr = [-1, _maxRange * _maxRange] select (_maxRange > 0);
private _outOfRange = false; 
private _testPos = _idealPos; 
    
if (_lookingAtSky || {_maxRange > 0 && {_eye vectorDistanceSqr _idealPos > _maxRangeSqr}}) then { 
    _outOfRange = true; 
    _testPos = _eye vectorAdd (_dir vectorMultiply _maxRange); 
}; 
    
_probe setPosASL _testPos; 
private _look = getLightingAt _probe; 
private _ply = getLightingAt _player; 
private _light = ((_look # 1) + (_ply # 1) + (_look # 3) + (_ply # 3)) / 2; 
    
KTWK_NVG_outOfRange = _outOfRange; 
[_light, _outOfRange]
