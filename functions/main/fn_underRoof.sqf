// Returns true if unit or ASL position is under any kind of roof
// by kenoxite
params [["_unit", objNull], ["_height", 20]];
private ["_pos"];
if (typeName _unit == "OBJECT") then {
    if (isNull _unit) exitwith {false};
    if (_unit in agents) then {_unit = agent _unit};
    _pos = getposASL _unit;
} else {
    _pos = _unit;
};
count (lineIntersectsObjs [_pos, [_pos#0, _pos#1, (_pos#2) + _height + 1]]) > 0