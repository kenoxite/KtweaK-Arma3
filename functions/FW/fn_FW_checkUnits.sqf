//

if (!isServer) exitwith {false};
    
// EH
{
    if (alive _x && {!(_x getVariable ["KTWK_FW_ready", false]) && {!(_x getVariable ["KTWK_FW_exclude", false])}}) then {
        _x setVariable ["KTWK_FW_ready", true, true];
        [_x, ["HandleDamage",{
        params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
            if !(_unit getVariable ["KTWK_FW_fatallyWounded", false]) then {
                if (!alive _unit) then {
                    [_unit, stance _unit, _selection, _damage, _instigator, group _unit] call KTWK_fnc_fatalWoundPrep;
                    _unit removeEventHandler [_thisEvent, _thisEventHandler];
                    _unit setVariable ["KTWK_FW_fatallyWounded", true, true];  
                    _unit setVariable ["KTWK_FW_Killed", false, true]; 
                }; 
            };
            _damage
        }]] remoteExec ["addEventHandler", 0, true];
        
        [_x, ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
                if !(_unit getVariable ["KTWK_FW_fatallyWounded", false]) then {
                        private _selection = "";
                        if ((_unit getHit "head") >= 1 || (_unit getHit "neck") >= 1 || (_unit getHit "face_hub") >= 1) then { _selection = "head" };
                        if ((_unit getHit "spine3") >= 1) then { _selection = "spine3" };
                        _unit setVariable ["KTWK_FW_fatallyWounded", true, true];  
                        _unit setVariable ["KTWK_FW_Killed", false, true]; 
                        [_unit, stance _unit, _selection, -1, _instigator, group _unit] call KTWK_fnc_fatalWoundPrep;
                };
        }]] remoteExec ["addEventHandler", 0, true]; 
    };

} forEach KTWK_allInfantry;


// Delete corpses
if (KTWK_FW_opt_mode != "delete" || KTWK_FW_opt_deleteTimer == 0) exitWith {false};
{
    private _timeDead = _x getVariable ["KTWK_FW_timeDead", -1];
    if (_timeDead >= 0) then {
        if ((time - _timeDead) > KTWK_FW_opt_deleteTimer) then { _x remoteExecCall ["hideBody", 0, owner _x] };
    };
} forEach allDeadMen;
