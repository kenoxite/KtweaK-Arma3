//
private _allInfantry = allUnits select {_x isKindOf "CAManBase"};

// Exclude zombies, animals, etc
_allInfantry = _allInfantry select {
        if (_x isKindOf "zombie"
            || _x isKindOf "dbo_horse_Base_F"
            || !(isNil {_x getVariable "WBK_AI_ISZombie"})
            || faction _x == "dev_mutants") then {
            false //Remove element from array
        } else {
            true //Keep element in array
        };
    };


// EH
{
    private _ready = _x getVariable "KTWK_FW_ready";
    if (alive _x && {isNil "_ready" && {!(_x getVariable ["KTWK_FW_exclude", false])}}) then {
        _x setVariable ["KTWK_FW_ready", true];
        _KTWK_FW_HandleDamage = _x addEventHandler ["HandleDamage",{
        params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
            if!(_unit getVariable ["KTWK_FW_fatallyWounded",false])then{
                if (!alive _unit) then {
                    [_unit, stance _unit, _selection, _damage, _instigator, _thisEventHandler, group _unit] call KTWK_fnc_fatalWoundPrep;
                    _unit setVariable ["KTWK_FW_fatallyWounded",true];  
                    _unit setVariable ["KTWK_FW_Killed",false]; 
                }; 
            };
            _damage
        }]; 
        _x setVariable ["KTWK_FW_HandleDamage", _KTWK_FW_HandleDamage];
        
        _KTWK_FW_Killed = _x addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
                // systemchat format ["_killer : %1", _killer ];
                if!(_unit getVariable ["KTWK_FW_fatallyWounded",false])then{
                        private _selection = "";
                        if ((_unit getHit "head") >= 1 || (_unit getHit "neck") >= 1 || (_unit getHit "face_hub") >= 1) then { _selection = "head" };
                        if ((_unit getHit "spine3") >= 1) then { _selection = "spine3" };
                        [_unit, stance _unit, _selection, -1, _instigator, -1, group _unit] call KTWK_fnc_fatalWound;
                        _unit setVariable ["KTWK_FW_fatallyWounded",true];  
                        _unit setVariable ["KTWK_FW_Killed",false]; 
                } else {
                    // _unit setVariable ["KTWK_FW_fatallyWounded",nil];   
                    // _unit setVariable ["KTWK_FW_Killed",nil]; 
                };
        }];
        _x setVariable ["KTWK_FW_Killed", _KTWK_FW_Killed];

    };

} forEach _allInfantry;


// Delete corpses
if (KTWK_FW_opt_mode != "delete") exitWith {true};
{
    private _timeDead = _x getVariable "KTWK_FW_timeDead";
    if (!isNil "_timeDead" && {KTWK_FW_opt_deleteTimer > 0}) then {
        if ((time - _timeDead) > KTWK_FW_opt_deleteTimer) then { hideBody _x };
    };
} forEach allDeadMen;
