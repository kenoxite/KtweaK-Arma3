params [["_parent", objNull], ["_stance", ""]];

if (isNull _parent) exitwith {objNull};
    
// systemchat format ["stance: %1", _stance];
// Hide unit
// private _clone = createAgent [typeOf _parent, getPos _parent, [], 0, "CAN_COLLIDE"];
private _clone = createAgent [typeOf _parent, _parent modelToWorld (_parent selectionPosition "spine3"), [], 0, "CAN_COLLIDE"];
_clone setVariable ["BIS_enableRandomization", false, true];
_clone hideObjectGlobal true;
_clone setVariable ["KTWK_FW_exclude", true, true];
_clone setDir (getDir _parent);

// Start cloning
[_clone, name _parent] remoteExecCall ["setName", 0, _clone];
[_clone, face _parent] remoteExecCall ["setFace", 0, _clone];
[_clone, speaker _parent] remoteExecCall ["setSpeaker", 0, _clone];
[_clone, pitch _parent] remoteExecCall ["setPitch", 0, _clone];
[_clone, rank _parent] remoteExecCall ["setUnitRank", 0, _clone];

_clone setUnitLoadout [getUnitLoadout _parent, false];
if (KTWK_FW_opt_mode == "keep") then {
    _clone removeWeapon (currentWeapon _clone);
    _clone removeWeapon (secondaryWeapon _clone);
};

// Set textures
private _textures = getObjectTextures _parent; 
{ _clone setObjectTextureGlobal [_forEachIndex, _x]; } forEach _textures;

// Damage unit
_clone setHit ["body", (_parent getHit "body") min 0.7];
_clone setHit ["head", (_parent getHit "head") min 0.7];
_clone setHit ["neck", (_parent getHit "neck") min 0.7];
_clone setHit ["face_hub", (_parent getHit "face_hub") min 0.7];
_clone setHit ["spine1", (_parent getHit "spine1") min 0.7];
_clone setHit ["spine2", (_parent getHit "spine2") min 0.7];
_clone setHit ["spine3", (_parent getHit "spine3") min 0.7];
_clone setHit ["pelvis", (_parent getHit "pelvis") min 0.7];
_clone setHit ["legs", (_parent getHit "legs") min 0.7];
_clone setHit ["hands", (_parent getHit "hands") min 0.7];

[_clone, ["body", (_parent getHit "body") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["head", (_parent getHit "head") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["neck", (_parent getHit "neck") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["face_hub", (_parent getHit "face_hub") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["spine1", (_parent getHit "spine1") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["spine2", (_parent getHit "spine2") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["spine3", (_parent getHit "spine3") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["pelvis", (_parent getHit "pelvis") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["legs", (_parent getHit "legs") min 0.7]] remoteExecCall ["setHit", 0, _clone];
[_clone, ["hands", (_parent getHit "hands") min 0.7]] remoteExecCall ["setHit", 0, _clone];

// _clone setDamage 0.9;

_clone setCaptive true;
_clone allowDamage false;
[_clone, "all"] remoteExecCall ["disableAI", 0, _clone];

// switch (_stance) do {
//     case "STAND":
//         { [_clone, "AmovPercMstpSnonWnonDnon"] remoteExec ["switchMove", 0, _clone]; };
//     case "PRONE":
//         { [_clone, "AmovPpneMstpSnonWnonDnon"] remoteExec ["switchMove", 0, _clone]; };
//     case "CROUCH":
//         { [_clone, "AmovPknlMstpSnonWnonDnon"] remoteExec ["switchMove", 0, _clone]; };
// };

// Healing will be ineffective for this unit
[_clone, ["HandleHeal", {
    _this spawn {
        params ["_injured", "_healer"];
        private _startHealingTime = time;
        private _healerFAKs = count ((items _healer) select {_x == "FirstAidKit"});
        private _damage = damage _injured;
        waitUntil {damage _injured != _damage || isNull _injured || isNull _healer};
        if (isNull _injured || isNull _healer) exitwith {true};
        if (damage _injured < _damage) then {
            _injured setDamage _damage;
        };
        // waitUntil {(time - _startHealingTime) > 5};
        waitUntil {!alive _healer || isNull _injured || isNull _healer || {(animationState _healer) != "ainvpknlmstpslaywrfldnon_medicother" || (animationState _healer) != "ainvppnemstpslaywrfldnon_medicother"}};
        if (isNull _injured || isNull _healer) exitwith {true};
        // Give FAK back if used
        private _healerFAKsNow = count ((items _healer) select {_x == "FirstAidKit"});
        if (alive _healer && {_healerFAKsNow < _healerFAKs}) then { _healer addItem "FirstAidKit" };
    };
}]] remoteExec ["addEventHandler", 0, true];


_clone setVariable ["KTWK_FW_animDone", false, true];
[_clone, ["AnimDone", {
    params ["_unit", "_anim"];
    _unit setVariable ["KTWK_FW_animDone", true, true];
}]] remoteExec ["addEventHandler", 0 , true];

[_clone, ["AnimChanged", {
    params ["_unit", "_anim"];
    _unit setVariable ["KTWK_FW_animDone", false, true];
}]] remoteExec ["addEventHandler", 0 , true];

// _clone switchMove "AmovPpneMstpSnonWnonDnon_healed";
// _clone switchMove "AinjPpneMstpSnonWnonDnon_rolltoback";
[_clone, "AinjPpneMstpSnonWnonDnon_rolltoback"] remoteExec ["switchMove", 0, _clone];

_clone
