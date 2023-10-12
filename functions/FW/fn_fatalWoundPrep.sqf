// Fatal Wounds - Preparation by kenoxite

params [["_unit", objNull], ["_stance", ""], ["_selection", ""], ["_damage", -1], ["_instigator", objNull], ["_grp", grpNull]];

if (isNull _unit) exitwith {false};

[_unit] call KTWK_fnc_disableVoice;

private _instantDeath = (
                (_selection == "head" || _selection == "neck" || _selection == "face_hub") && random 1 <= (KTWK_FW_opt_instantDeath_head/100)) // Chance of instant death when head is damaged
                || (_selection == "spine3" && random 1 <= (KTWK_FW_opt_instantDeath_chest/100)); // Chance of instant death when chest is damaged

private _closePlayers = [];
{if (_unit distance _x <= KTWK_FW_opt_maxRange) then { _closePlayers pushBack _x}} forEach allPlayers;

if(!KTWK_FW_opt_enabled || vehicle _unit != _unit || count _closePlayers == 0 || isPlayer _unit || _instantDeath) exitWith {
    _unit setVariable ["KTWK_FW_Killed", true, true];
    if (KTWK_opt_debug) then { systemchat "Instant death" };
};

private _clone = [_unit, _stance] call KTWK_fnc_cloneDead;

if (isNull _clone) exitwith {false};
// Unit Voice-Overs mod compatibility
_clone setVariable ["UVO_voice", nil, true];
_clone setVariable ["UVO_speaking", nil, true];
_clone setVariable ["UVO_suppressBuffer", nil, true];
_clone setVariable ["UVO_allowDeathShouts", false, true];

(_this + [_clone]) spawn KTWK_fnc_fatalWound;
