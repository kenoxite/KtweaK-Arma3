// by Killzone Kid

params [["_unit", objNull]];

if (isNull _unit) exitwith {false};

lineIntersectsSurfaces [
    getPosWorld _unit, 
    getPosWorld _unit vectorAdd [0, 0, 50], 
    _unit, objNull, true, 1, "GEOM", "NONE"
] select 0 params ["","","","_house"];
if (!isNil "_house" && {_house isKindOf "Building"}) exitWith { true };
false


/*

// File Name: InBuilding.sqf
// -------------------------------------------------------------------------------------------
// Version: 0.1 BETA
// Date: 07/01/2013
// Function: Returns if a unit is in a builing
// Author: Mad_Cheese, edited by kenoxite
// -------------------------------------------------------------------------------------------

params [["_unit", objNull]];

if (isNull _unit) exitwith {false};

private _pos = getposASL _unit;
private _eyepos = eyepos _unit; 
private _return = false;
private _Array = [];
private _roof= [_eyepos select 0,_eyepos select 1, (_eyepos select 2) + 25];
private _WallFront = [(_eyepos select 0) + (((25)*sin(getdir _unit))), (_eyepos select 1) + ((25)*cos(getdir _unit)),(_eyepos select 2)];
private _WallBack = [(_eyepos select 0) + (((-25)*sin(getdir _unit))), (_eyepos select 1) + ((-25)*cos(getdir _unit)),(_eyepos select 2)];
private _WallRight = [(_eyepos select 0) + (((25)*sin(getdir _unit + 90))), (_eyepos select 1) + ((0)*cos(getdir _unit)),(_eyepos select 2)];
private _WallLeft = [(_eyepos select 0) + (((-25)*sin(getdir _unit + 90))), (_eyepos select 1) + ((0)*cos(getdir _unit)),(_eyepos select 2)];

private _roofcheck = (lineIntersectsWith [_eyepos,_roof,_unit,_unit,true]);
if (count _roofcheck == 0) exitwith {
    //hintsilent "no roof";
    _return
};
private _wallcheckFront = (lineIntersectsWith [_eyepos,_WallFront,_unit,_unit,true]);
private _wallcheckBack = (lineIntersectsWith [_eyepos,_WallBack,_unit,_unit,true]);
private _wallcheckRight = (lineIntersectsWith [_eyepos,_WallRight,_unit,_unit,true]);
private _wallcheckLeft = (lineIntersectsWith [_eyepos,_WallLeft,_unit,_unit,true]);


if ((_roofcheck select 0) iskindof "building") then {
    {
        if ((_x select 0) iskindof "building") then {
            _Array = _Array + [_x select 0];
        };
    } foreach [_wallcheckFront,_wallcheckBack,_wallcheckRight,_wallcheckLeft];

    if ({_x == (_roofcheck select 0)} count _Array >= 2) then {
        _return = true;     
    } else {
        _return = false;        
    };
};

// if (_return) then {hintsilent "in building"} else {hintsilent "not in building"};
_return*/