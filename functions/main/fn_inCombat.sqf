// Function to check and update combat status of a group

params ["_unit", "_group", ["_checkTimer", 60], ["_outOfCombatTime", 30]];

if !(_unit isEqualTo (leader _group)) exitWith {false};
private _return = _group getVariable ["KTWK_inCombat", false];
if (diag_tickTime - (_group getVariable ["KTWK_lastCombatCheck", 90]) > _checkTimer) then {
    private _nearEnemy = _unit findNearestEnemy _unit;
    if (!isNull _nearEnemy && {_unit distance _nearEnemy < 100}) then {
        _group setVariable ["KTWK_lastCombatTime", diag_tickTime, false];
        _return = true;
    } else {
        if (diag_tickTime - (_group getVariable ["KTWK_lastCombatTime", 0]) > _outOfCombatTime) then {
            _return = false;
        };
    };
    _group setVariable ["KTWK_inCombat", _return, false];
    _group setVariable ["KTWK_lastCombatCheck", diag_tickTime, false];
};

_return
