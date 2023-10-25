// Plays the slidindg upslope action
// by kenoxite
params [["_unit", objNull]];
if (isNull _unit) exitwith {false};
if (!local _unit) exitwith {false};
if (!alive _unit) exitwith {false};
if (!canSuspend) exitWith {_this spawn KTWK_fnc_slideUpSlope};
private _noWpnInHand = "snonwnon" in (animationState _unit);
private _lowered = weaponLowered _unit && !_noWpnInHand;
private _stance = stance _unit;
_unit setVariable ["KTWK_isSlopeSliding", true, true];
_unit setVelocityModelSpace [0, -5, 0];
private _animSpeed = 3;
[_unit, _animSpeed] remoteExecCall ["setAnimSpeedCoef", 0, _unit];

private _wep = currentWeapon _unit;
private _anim = call {
    if (primaryWeapon _unit != "" && {_wep == primaryWeapon _unit}) exitWith {"amovpercmstpsraswrfldnon_amovppnemstpsraswrfldnon"};
    if (secondaryWeapon _unit != "" && {_wep == secondaryWeapon _unit}) exitWith {"amovpercmstpsraswlnrdnon_amovppnemstpsnonwnondnon"};
    if (handgunWeapon _unit != "" && {_wep == handgunWeapon _unit}) exitWith {"amovpercmstpsraswpstdnon_amovppnemstpsraswpstdnon"};
    "amovpercmstpsnonwnondnon_amovppnemstpsnonwnondnon"
};
[_unit, _anim] remoteExec ["playMoveNow", 0, _unit];
playSound3D ["KtweaK\sounds\slidingUpSlope.wss", _unit];

sleep 1;

if (!alive _unit) exitwith {_unit setVariable ["KTWK_isSlopeSliding", false, true]; false};
// _unit setAnimSpeedCoef 1;
[_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0, _unit];
private _wpn =  currentWeapon _unit;
private _anim = call {
    if (_stance == "STAND") exitWith {
        if (_noWpnInHand) exitWith {"amovpercmstpsnonwnondnon"};
        if (_wpn == primaryWeapon _unit) exitWith {
            if (_lowered) exitWith {"AmovPercMstpSlowWrflDnon"};
            "AmovPercMstpsrasWrflDnon"
        };
        if (_wpn == handgunWeapon _unit) exitWith {
            if (_lowered) exitWith {"AmovPercMstpSlowWpstDnon"};
            "AmovPercMstpsrasWpstDnon"
        };
        ""
    };  
    if (_stance == "CROUCH") exitWith {
        if (_noWpnInHand) exitWith {"amovpknlmstpsnonwnondnon"};
        if (_wpn == primaryWeapon _unit) exitWith {
            if (_lowered) exitWith {"AmovPknlMstpSlowWrflDnon"};
            "AmovPknlMstpsrasWrflDnon"
        };
        if (_wpn == handgunWeapon _unit) exitWith {
            if (_lowered) exitWith {"AmovPknlMstpSlowWpstDnon"};
            "AmovPknlMstpsrasWpstDnon"
        };
        ""
    };
    ""
};
sleep 0.2;
if (_anim != "") then {
    [_unit, _anim] remoteExec ["playMoveNow", 0, _unit];
};

_unit setVariable ["KTWK_isSlopeSliding", false, true];
