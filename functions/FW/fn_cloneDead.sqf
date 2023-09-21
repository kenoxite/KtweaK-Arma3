params [["_parent", objNull], ["_stance", ""]];

if (isNull _parent) exitwith {objNull};
    
// systemchat format ["stance: %1", _stance];
// Hide unit
// private _clone = createAgent [typeOf _parent, getPos _parent, [], 0, "CAN_COLLIDE"];
private _clone = createAgent [typeOf _parent, _parent modelToWorld (_parent selectionPosition "spine3"), [], 0, "CAN_COLLIDE"];
_clone setVariable ["BIS_enableRandomization", false];
_clone hideObject true;
_clone setVariable ["KTWK_FW_exclude", true];
_clone setDir (getDir _parent);

// Start cloning
_clone setName (name _parent);
_clone setFace (face _parent);
_clone setSpeaker (speaker _parent);
_clone setPitch (pitch _parent);
_clone setUnitRank (rank _parent); 

_clone setUnitLoadout [getUnitLoadout _parent, false];
if (KTWK_FW_opt_mode == "keep") then {
    _clone removeWeapon (currentWeapon _clone);
    _clone removeWeapon (secondaryWeapon _clone);
};

// Set textures
private _textures = getObjectTextures _parent;
{ _clone setObjectTexture [_forEachIndex, _x]; } forEach _textures;

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

// _clone setDamage 0.9;

_clone setCaptive true;
_clone allowDamage false;
_clone disableAI "all";

// switch (_stance) do {
//     case "STAND":
//         { _clone switchMove "AmovPercMstpSnonWnonDnon" };
//     case "PRONE":
//         { _clone switchMove "AmovPpneMstpSnonWnonDnon" };
//     case "CROUCH":
//         { _clone switchMove "AmovPknlMstpSnonWnonDnon" };
// };

// Healing will be ineffective for this unit
_clone addEventHandler ["HandleHeal", {
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
}];


_clone setVariable ["KTWK_FW_animDone", false];
_clone addEventHandler ["AnimDone", {
    params ["_unit", "_anim"];
    _unit setVariable ["KTWK_FW_animDone", true];
}];

_clone addEventHandler ["AnimChanged", {
    params ["_unit", "_anim"];
    _unit setVariable ["KTWK_FW_animDone", false];
}];

// _clone switchMove "AmovPpneMstpSnonWnonDnon_healed";
_clone switchMove "AinjPpneMstpSnonWnonDnon_rolltoback";

_clone
