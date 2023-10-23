// Plays the slidindg downslope action
// by kenoxite
params [["_unit", objNull]];
if (isNull _unit) exitwith {false};
if (!local _unit) exitwith {false};
if (!alive _unit) exitwith {false};
if (!canSuspend) exitWith {_this spawn KTWK_fnc_slideDownSlope};
private _lowered = weaponLowered _unit;
private _stance = stance _unit;
_unit setVariable ["KTWK_isSlopeSliding", true, true];
// _unit switchMove "Acts_In_Sinkhole";
[_unit, "Acts_In_Sinkhole"] remoteExec ["switchMove", 0, _unit];
// _unit playMoveNow "Acts_In_Sinkhole";
[_unit, "Acts_In_Sinkhole"] remoteExec ["playMoveNow", 0, _unit];
_unit setVelocityModelSpace [0, 7, 0];
playSound3D ["KtweaK\sounds\slidingDownSlope.wss", _unit];

waitUntil {speed _unit <= 0};
// _unit switchMove "Acts_Getting_Up_Player";
[_unit, "Acts_Getting_Up_Player"] remoteExec ["switchMove", 0, _unit];
// _unit setAnimSpeedCoef 3;
[_unit, 3] remoteExecCall ["setAnimSpeedCoef", 0, _unit];

sleep 2.5;
[_unit, 3] remoteExecCall ["setAnimSpeedCoef", 0, _unit];

if (!alive _unit) exitwith {_unit setVariable ["KTWK_isSlopeSliding", false, true]; false};
// _unit switchMove "";
[_unit, ""] remoteExec ["switchMove", 0, _unit];

if (_lowered) then {
    private _wpn =  currentWeapon _unit;
    private _anim = call {
        if (_stance == "STAND") exitWith {
            if (_wpn == primaryWeapon _unit) exitWith {"AmovPercMstpSlowWrflDnon"};
            if (_wpn == handgunWeapon _unit) exitWith {"AmovPercMstpSlowWpstDnon"};
            ""
        };  
        if (_stance == "CROUCH") exitWith {
            if (_wpn == primaryWeapon _unit) exitWith {"AmovPknlMstpSlowWrflDnon"};
            if (_wpn == handgunWeapon _unit) exitWith {"AmovPknlMstpSlowWpstDnon"};
            ""
        };
        ""
    };
    sleep 0.2;
    if (_anim != "") then { [_unit, _anim] remoteExec ["playMoveNow", 0, _unit]; };
};
// _unit setAnimSpeedCoef 1;
[_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0, _unit];
_unit setVariable ["KTWK_isSlopeSliding", false, true];
