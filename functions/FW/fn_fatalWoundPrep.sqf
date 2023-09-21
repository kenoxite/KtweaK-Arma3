// Fatal Wounds - Preparation by kenoxite

params [["_unit", objNull], ["_stance", ""], ["_selection", ""], ["_damage", -1], ["_instigator", objNull], ["_EHindex", -1], ["_grp", grpNull]];

if (isNull _unit) exitwith {true};
// if !(_unit isKindOf "CAManBase") exitwith {true};
// if (_unit isKindOf "zombie") exitwith {true};

if (_EHindex >= 0) then { _unit removeEventHandler ["HandleDamage", _EHindex] };

private _instantDeath = (
                (_selection == "head" || _selection == "neck" || _selection == "face_hub") && random 1 <= (KTWK_FW_opt_instantDeath_head/100)) // High chance of instant death when head is damaged
                || (_selection == "spine3" && random 1 <= (KTWK_FW_opt_instantDeath_chest/100)); // Medium chance of instant death when chest is damaged

private _player = call KTWK_fnc_playerUnit;
if(!KTWK_FW_opt_enabled || vehicle _unit != _unit || _unit distance _player > KTWK_FW_opt_maxRange || isPlayer _unit || _instantDeath) exitWith {
    _unit setVariable ["KTWK_FW_Killed",true]; 
    if (KTWK_opt_debug) then { systemchat "Instant death" };
};


_unit setVariable ["SSD_disabledSounds", true];

// Unit Voice-Overs mod compatibility
_unit setVariable ["UVO_voice", nil, true];
_unit setVariable ["UVO_speaking",nil,true];
_unit setVariable ["UVO_suppressBuffer",nil,true];
_unit setVariable ["UVO_allowDeathShouts",false,true];

private _clone = [_unit, _stance] call KTWK_fnc_cloneDead;
if (isNull _clone) exitwith {true};
// Unit Voice-Overs mod compatibility
_clone setVariable ["UVO_voice", nil, true];
_clone setVariable ["UVO_speaking",nil,true];
_clone setVariable ["UVO_suppressBuffer",nil,true];
_clone setVariable ["UVO_allowDeathShouts",false,true];

private _params = _this + [_clone];

_params execVM "KtweaK\scripts\fatalWound.sqf";
