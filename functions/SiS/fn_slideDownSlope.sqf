params [["_unit", objNull]];

// Early exit conditions
if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {false};
if (!canSuspend) exitWith {_this spawn KTWK_fnc_slideDownSlope};

// Initialize variables
private _noWpnInHand = "snonwnon" in (animationState _unit);
private _lowered = weaponLowered _unit && !_noWpnInHand;
private _stance = stance _unit;
private _animSpeed = 3;

// Set sliding state
_unit setVariable ["KTWK_SiS_isSlopeSliding", true, true];

// Apply sliding animation
[_unit, "Acts_In_Sinkhole"] remoteExec ["switchMove", 0];
[_unit, "Acts_In_Sinkhole"] remoteExec ["playMoveNow", 0];

// Apply force
private _force = if (KTWK_aceMedical) then {6} else {7};
_unit setVelocityModelSpace [0, _force, 0];

// Play sound
playSound3D ["KtweaK\sounds\slidingDownSlope.wss", _unit];

// Wait for unit to stop
private _maxWait = serverTime + 5;
waitUntil {sleep 0.1; speed _unit <= 0 || serverTime > _maxWait};

// Recovery animation
    // - Remove player from SOG AI fast movers array
    private _inSOGarray = false;
    if (!isNil {jboy_FastMovers}) then {
        _inSOGarray = SQFB_player in jboy_FastMovers;
        jboy_FastMovers = jboy_FastMovers - [SQFB_player];
    };
[_unit, _animSpeed] remoteExecCall ["setAnimSpeedCoef", 0];
[_unit, "Acts_Getting_Up_Player"] remoteExec ["switchMove", 0];

// Recovery period
private _recoveryTime = 2.5;
for "_i" from 0 to _recoveryTime step 0.1 do {
    _unit setAnimSpeedCoef _animSpeed;
    sleep 0.1;
};

// Exit if unit died during recovery
if (!alive _unit) exitWith {
    _unit setVariable ["KTWK_SiS_isSlopeSliding", false, true];
    false
};

// Handle weapon lowered state
if (_lowered && !KTWK_aceMovement) then {
    private _wpn = currentWeapon _unit;
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
    
    if (_anim != "") then {
        sleep 0.2;
        [_unit, _anim] remoteExec ["switchMove", 0];
        [_unit, _anim] remoteExec ["playMoveNow", 0];
    };
};

// Handle no weapon in hand
if (_noWpnInHand) then {
    [_unit, "amovpercmstpsnonwnondnon"] remoteExec ["switchMove", 0];
    [_unit, "amovpercmstpsnonwnondnon"] remoteExec ["playMoveNow", 0];
};

// Reset animation speed and sliding state
[_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0];
_unit setVariable ["KTWK_SiS_isSlopeSliding", false, true];

    // - Add player back to SOG AI fast movers array
    if (!isNil {jboy_FastMovers} && {_inSOGarray}) then {
        jboy_FastMovers pushBack SQFB_player;
    };

true
