// Returns true if unit is under any kind of roof
// by kenoxite
params [["_unit", objNull], ["_height", 20]];
if (_unit in agents) then {_unit = agent _unit};
private _pos = getpos _unit;
count (lineIntersectsObjs [_pos, [_pos#0, _pos#1, (_pos#2) + _height + 1]]) > 0
