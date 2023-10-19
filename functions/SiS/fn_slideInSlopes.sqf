// Controls the chance and starts the action of sliding in a slope
// by kenoxite

params [["_unit", objNull]];
if (isNull _unit) exitwith {false};
if (!local _unit) exitwith {false};
if !([_unit] call KTWK_fnc_isHuman) exitWith {false};
if ((count (KTWK_SiS_excluded select { _unit isKindOf _x}) > 0)) exitWith {false};
if (!alive _unit) exitwith {false};
if (vehicle _unit != _unit) exitWith {false};
private _falling = _unit getVariable ["KTWK_isSlopeSliding", false];
if (_falling) exitWith {false};
if ((getPosATl _unit)#2 >= 1) exitwith {false};
private _s = speed _unit;
if (abs _s < 3) exitWith {false};

private _g = [getPos _unit, getDir _unit] call BIS_fnc_terrainGradAngle;
private _sureFall = ((abs _g) > 30 && _s > 4) || ((abs _g) > 20 && _s > 12) || (abs _g) > 45;
private _balance = call {
                            if (isStaminaEnabled _unit) exitWith {
                                (((1 - (getFatigue _unit)) - load _unit) max 0) + (skill _unit / 2);
                            };
                            (load _unit) + (skill _unit / 3);
                        };
if (_sureFall && {random 1 > _balance}) then {
    _s = "camera" camCreate (getPos _unit);
    _s spawn {
        waitUntil {!isNull _this};
        // _this say (format ["KTWK_gruntMan%1", (round (random 3)) + 1]);
        [_this, format ["KTWK_gruntMan%1", (round (random 3)) + 1]] remoteExecCall ["say"];

        sleep 2;
        camdestroy _this;
    };
    call {
        // Up slope
        if (_g > 0) exitWith {
            [_unit] spawn KTWK_fnc_slideUpSlope;
        };
        // Down slope
        [_unit] spawn KTWK_fnc_slideDownSlope;
    };
};
