params [["_unit", objNull]];
if (isNull _unit) exitwith {true};
private _selectionPos = _unit selectionPosition ["head", "HitPoints"];
((_unit modelToWorldVisual _selectionPos) select 2) < 0.2
