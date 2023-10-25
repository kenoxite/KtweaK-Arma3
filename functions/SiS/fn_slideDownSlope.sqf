// Plays the slidindg downslope action
// by kenoxite
params [["_unit", objNull]];
if (isNull _unit) exitwith {false};
if (!local _unit) exitwith {false};
if (!alive _unit) exitwith {false};
if (!canSuspend) exitWith {_this spawn KTWK_fnc_slideDownSlope};
private _noWpnInHand = "snonwnon" in (animationState _unit);
private _lowered = weaponLowered _unit && !_noWpnInHand;
private _stance = stance _unit;
private _animSpeed = 3;
_unit setVariable ["KTWK_isSlopeSliding", true, true];
[_unit, "Acts_In_Sinkhole"] remoteExec ["switchMove", 0, _unit];
[_unit, "Acts_In_Sinkhole"] remoteExec ["playMoveNow", 0, _unit];
_unit setVelocityModelSpace [0, 7, 0];
playSound3D ["KtweaK\sounds\slidingDownSlope.wss", _unit];

waitUntil {speed _unit <= 0};
[_unit, _animSpeed] remoteExecCall ["setAnimSpeedCoef", 0, _unit];
[_unit, "Acts_Getting_Up_Player"] remoteExec ["switchMove", 0, _unit];

private _recoveryTime = 2.5;
private _i = 0;
while {_i < _recoveryTime} do {
    _unit setAnimSpeedCoef _animSpeed;
    _i = _i + 0.1;
    sleep 0.1; 
};

if (!alive _unit) exitwith {_unit setVariable ["KTWK_isSlopeSliding", false, true]; false};

if (_lowered && !KTWK_aceMovement) then {
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
    if (_anim != "") then {
        [_unit, _anim] remoteExec ["switchMove", 0, _unit];
        [_unit, _anim] remoteExec ["playMoveNow", 0, _unit];
    };
};

if (_noWpnInHand) then {
    [_unit, "amovpercmstpsnonwnondnon"] remoteExec ["switchMove", 0, _unit];
    [_unit, "amovpercmstpsnonwnondnon"] remoteExec ["playMoveNow", 0, _unit];
};

[_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0, _unit];
_unit setVariable ["KTWK_isSlopeSliding", false, true];
