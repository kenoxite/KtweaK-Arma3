// Check if unit is in a unit's FOV
//
// Params:
// - _observed: unit to be checked to be in FOV
// - _observer: unit the FOV of which is checked


params ["_observed", "_observer"];

private _unitPos = getPosWorld (vehicle _observed);
private _vehObserver = vehicle _observer;
private _observerPos = getPosWorld _vehObserver;
private _allTurrets = allTurrets [_vehObserver, false];
private _camDir = -1;
if (count _allTurrets == 0 || {_vehObserver turretUnit [0] != _observer}) then {
    _camDir = [0,0,0] getdir getCameraViewDirection _vehObserver;
} else {
    private _weaponDir = _vehObserver weaponDirection (currentWeapon _vehObserver);
    private _turretDir = (_weaponDir select 0) atan2 (_weaponDir select 1);
    _camDir = [
                    _turretDir,
                    360 + _turretDir
                ] select (_turretDir < 0);
};

[_observerPos, _camDir, ceil((call CBA_fnc_getFov select 0)*100), _unitPos] call BIS_fnc_inAngleSector
