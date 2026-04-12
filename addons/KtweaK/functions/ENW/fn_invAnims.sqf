// KTWK_fnc_invAnims
// Forces the unit to play an inventory animation based on its current weapon and stance

params [["_unit", player]];

private _current = currentWeapon _unit;
private _primary = primaryWeapon _unit;
private _secondary = secondaryWeapon _unit;
private _handgun = handgunWeapon _unit;
private _stance = stance _unit;
private _standing = _stance == "STAND";
private _crouching = _stance == "CROUCH";
private _prone = _stance == "PRONE";

private _anim = call {
    if (_current == "") exitWith {
        call {
            if (_standing) exitWith { "AinvPercMstpSnonWnonDnon" };
            if (_crouching) exitWith { "AinvPknlMstpSnonWnonDnon" };
            if (_prone) exitWith { "AinvPpneMstpSnonWnonDnon" };
            ""
        };
    };
    if (_current == _primary) exitWith {
        call {
            if (_standing) exitWith { "AinvPercMstpSrasWrflDnon" };
            if (_crouching) exitWith { "AinvPknlMstpSrasWrflDnon" };
            if (_prone) exitWith { "AinvPpneMstpSrasWrflDnon" };
            ""
        };
    };
    if (_current == _secondary) exitWith {
        call {
            if (_standing) exitWith { "AinvPercMstpSrasWlnrDnon" };
            if (_crouching) exitWith { "AinvPknlMstpSrasWlnrDnon" };
            if (_prone) exitWith { "AinvPpneMstpSrasWrflDnon" };
        };
    };
    if (_current == _handgun) exitWith {
        call {
            if (_standing) exitWith { "AinvPercMstpSrasWpstDnon" };
            if (_crouching) exitWith { "AinvPknlMstpSrasWpstDnon" };
            if (_prone) exitWith { "AinvPpneMstpSrasWpstDnon" };
            ""
        };
    };
    ""
};

if (_anim == "") exitWith {};
_unit playMoveNow _anim;
