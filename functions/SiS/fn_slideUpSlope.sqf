// Plays the slidindg upslope action
// by kenoxite
params [["_unit", objNull]];
if (isNull _unit) exitwith {false};
if (!local _unit) exitwith {false};
if (!canSuspend) exitWith {_this spawn KTWK_fnc_slideUpSlope};
// private _prevAnim = animationState _unit;
private _lowered = weaponLowered _unit;
private _stance = stance _unit;
_unit setVariable ["KTWK_isSlopeSliding", true, true];
_unit setVelocityModelSpace [0, -5, 0];
// _unit setAnimSpeedCoef 3;
[_unit, 3] remoteExecCall ["setAnimSpeedCoef", 0, _unit];

private _wep = currentWeapon _unit;
private _anim = call {
    if (primaryWeapon _unit != "" && {_wep == primaryWeapon _unit}) exitWith {"amovpercmstpsraswrfldnon_amovppnemstpsraswrfldnon"};
    if (secondaryWeapon _unit != "" && {_wep == secondaryWeapon _unit}) exitWith {"amovpercmstpsraswlnrdnon_amovppnemstpsnonwnondnon"};
    if (handgunWeapon _unit != "" && {_wep == handgunWeapon _unit}) exitWith {"amovpercmstpsraswpstdnon_amovppnemstpsraswpstdnon"};
    "amovpercmstpsnonwnondnon_amovppnemstpsnonwnondnon"
};
// _unit playMoveNow _anim;
[_unit, _anim] remoteExec ["playMoveNow", 0, _unit];
playSound3D ["KtweaK\sounds\slidingUpSlope.wss", _unit];
sleep 1;
// _unit setAnimSpeedCoef 1;
[_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0, _unit];
// _unit playMoveNow _prevAnim;
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
    // if (_anim != "") then { _unit playMoveNow _anim };
    if (_anim != "") then { [_unit, _anim] remoteExec ["playMoveNow", 0, _unit]; };
};
_unit setVariable ["KTWK_isSlopeSliding", false, true];
