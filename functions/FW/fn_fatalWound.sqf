// Fatal Wounds by kenoxite

params [["_unit", objNull], ["_stance", ""], ["_selection", ""], ["_damage", -1], ["_instigator", objNull], ["_grp", grpNull], ["_clone", objNull]];

if (isNull _unit || isNull _clone) exitwith {true};

if (!canSuspend) exitwith {_this spawn KTWK_fnc_fatalWound};

// Wait for the ragdolling to stop
waitUntil {[_unit] call KTWK_fnc_checkBodySlam};
// waitUntil {alive _unit != isAwake _unit};
if (isNull _unit) exitwith {true};
// private _parentPos = ASLToAGL(aimPos _unit);
// _parentPos set [2, 0];
private _parentPos = getPosWorld _unit;
private _parentHeadPos = _unit modelToWorld (_unit selectionPosition "head");
private _parentHeadDir = _unit getRelDir _parentHeadPos;
private _parentDir = ((getDir _unit) + _parentHeadDir) mod 360;

private _keepCorpse = call {
    if (KTWK_FW_opt_mode == "keep") exitwith {true};
    false
};

if (_keepCorpse) then {
    // _unit hideObjectGlobal true;
    // _unit spawn {
    //     sleep 0.1;
    //     _this setPosWorld [0,0,0];
    // };
    _unit setPosWorld [0,0,0];
    sleep 0.01;
    _unit setPosWorld [0,0,0];
    // waitUntil {{_unit setPosWorld [0,0,0]; true}; getPosWorld _unit isEqualTo [0,0,0]};
} else {
    deleteVehicle _unit;
};
_clone setPosWorld _parentPos;
_clone setDir _parentDir;
_clone hideObjectGlobal false;

// systemchat format ["_selection: %1", _selection];

private _pos = getPosWorld _clone;
private _dir = getDir _clone;

// if (KTWK_FW_opt_enabled && ((getPosATL _clone) select 2) < 3 && _instigator != _unit) then {
// Ragdoll
// systemchat "Ragdoll";
// sleep 0.001;
// _clone setUnconscious true;
// waitUntil {[_clone] call KTWK_fnc_checkBodySlam};
// _clone setUnconscious false;
// sleep 0.001;
// _clone setPos _pos;
// _clone setDir _dir;

private _currentSide = "back";
private _anim = "";
private _scream_SSD = !isNil "SSD_fnc_playSound";
private _scream_ProjectHuman = !isNil "L_fnc_DeathScream";
private _scream = _scream_SSD || _scream_ProjectHuman;
private _maxAnimTime = 10;

// if (_scream_ProjectHuman) then { [_clone] spawn L_fnc_DeathScream };

call {
    // Head
    if (_selection == "head" || _selection == "neck" || _selection == "face_hub") exitwith {
        private _animData = (selectRandom [
                                    ["Acts_CivilInjuredHead_1", 25, 0, "back"]
                                    ]) params ["_anim", "_animTime", "_animDir", "_animSide"];
        if (KTWK_opt_debug) then { systemchat format ["Head injury anim: %1", _anim] };
        // if (_currentSide == "front" && _animSide == "back") then {
        //     _clone setUnconscious true;
        //     sleep 0.001;
        //     _clone setUnconscious false;
        //     _clone playMoveNow "AinjPpneMstpSnonWnonDnon_rolltoback";
        //     sleep 0.001;
        //     waitUntil {_clone getVariable "KTWK_FW_animDone"};
        // };
        if (_scream_SSD) then { [selectRandom SSD_RattleHead, _clone, 0, 2] call SSD_fnc_playSound };
        _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
        // _clone playMoveNow _anim;
        // sleep 0.001;
        // waitUntil {_clone getVariable "KTWK_FW_animDone"};
        // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
        // waitUntil {(animationState _clone) == _anim};
        // _clone switchMove _anim;
        [_clone, _anim] remoteExec ["switchMove", 0, _clone];
        sleep (2 + random 5);
        // _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
    };

    // Chest
    if (_selection == "spine3") exitwith {
        private _animData = (selectRandom [
                                                // ["Acts_InjuredLyingRifle01", 10, -30, "back"],
                                                // ["Acts_InjuredLyingRifle02", 10, -30, "back"],
                                                // ["Acts_InjuredLookingRifle01", 10, -30, "back"],
                                                // ["Acts_InjuredLookingRifle02", 10, -30, "back"],
                                                // ["Acts_InjuredLookingRifle03", 10, -30, "back"],
                                                // ["Acts_InjuredLookingRifle04", 10, -30, "back"],
                                                // ["Acts_InjuredLookingRifle05", 10, -30, "back"],
                                                // ["Acts_InjuredAngryRifle01", 10, -30, "back"],
                                                // ["Acts_InjuredSpeakingRifle01", 10, -30, "back"],
                                                // ["Acts_InjuredCoughRifle02", 10, -30, "back"],
                                                ["Acts_CivilInjuredChest_1", 16, 0, "back"]
                                                ]) params ["_anim", "_animTime", "_animDir", "_animSide"];
        if (KTWK_opt_debug) then { systemchat format ["Chest injury anim: %1", _anim] };
        if (_currentSide == "front" && _animSide == "back") then {
            _clone setUnconscious true;
            sleep 0.001;
            _clone setUnconscious false;
            // _clone playMoveNow "AinjPpneMstpSnonWnonDnon_rolltoback";
            [_clone, "AinjPpneMstpSnonWnonDnon_rolltoback"] remoteExec ["playMoveNow", 0, _clone];
            // _clone setDir ((getDir _clone) + 180) mod 360;
            // sleep 0.001;
            // waitUntil {_clone getVariable "KTWK_FW_animDone"};
            sleep 0.8;
        };
        if (_scream_SSD) then { [selectRandom SSD_RattleHeart, _clone, 1, 2] call SSD_fnc_playSound };
        _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
        // _clone playMoveNow _anim;
        [_clone, _anim] remoteExec ["switchMove", 0, _clone];
        waitUntil {_clone getVariable "KTWK_FW_animDone"};
        // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
        // waitUntil {(animationState _clone) == _anim};
        // _clone switchMove _anim;
        [_clone, _anim] remoteExec ["switchMove", 0, _clone];
        // sleep (3 + random 5);
        sleep (_animTime min _maxAnimTime);
    };

    // Stomach
    if (_selection == "spine1" || _selection == "spine2" || _selection == "pelvis") exitwith {
        private _animData = (selectRandom [
                                                ["Acts_InjuredLyingRifle01", 10, -30, "back"],
                                                ["Acts_InjuredLyingRifle02", 10, -30, "back"],
                                                ["Acts_InjuredLookingRifle01", 10, -30, "back"],
                                                ["Acts_InjuredLookingRifle02", 10, -30, "back"],
                                                ["Acts_InjuredLookingRifle03", 10, -30, "back"],
                                                ["Acts_InjuredLookingRifle04", 10, -30, "back"],
                                                ["Acts_InjuredLookingRifle05", 10, -30, "back"],
                                                ["Acts_InjuredAngryRifle01", 10, -30, "back"],
                                                ["Acts_InjuredSpeakingRifle01", 10, -30, "back"],
                                                ["Acts_InjuredCoughRifle02", 10, -30, "back"]
                                                // "passenger_flatground_leanleft"
                                                ]) params ["_anim", "_animTime", "_animDir", "_animSide"];
        if (KTWK_opt_debug) then { systemchat format ["Stomach injury anim: %1", _anim] };
        if (_currentSide == "front" && _animSide == "back") then {
            _clone setUnconscious true;
            sleep 0.001;
            _clone setUnconscious false;
            // _clone playMoveNow "AinjPpneMstpSnonWnonDnon_rolltoback";
            [_clone, "AinjPpneMstpSnonWnonDnon_rolltoback"] remoteExec ["playMoveNow", 0, _clone];
            _clone setDir ((getDir _clone) + 180) mod 360;
            // sleep 0.001;
            // waitUntil {_clone getVariable "KTWK_FW_animDone"};
            sleep 0.8;
        };
        sleep 0.001;
        if (_scream_SSD) then { [selectRandom SSD_RattleStomach, _clone, 2, 2] call SSD_fnc_playSound };
        _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
        // _clone playMoveNow _anim;
        [_clone, _anim] remoteExec ["playMoveNow", 0, _clone];
        waitUntil {_clone getVariable "KTWK_FW_animDone"};
        // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
        // waitUntil {(animationState _clone) == _anim};
        // _clone switchMove _anim;
        [_clone, _anim] remoteExec ["switchMove", 0, _clone];
        // sleep (10 + random 10);
        sleep (_animTime min _maxAnimTime);
    };

    // Legs
    if (_selection == "legs") exitwith {
        private _animData = (selectRandom [
                                                ["Acts_CivilInjuredLegs_1", 16.5, -20, "back"]
                                                ]) params ["_anim", "_animTime", "_animDir", "_animSide"];
        if (KTWK_opt_debug) then { systemchat format ["Leg injury anim: %1", _anim] };
        // if (_currentSide == "front" && _animSide == "back") then {
        //     _clone setUnconscious true;
        //     sleep 0.001;
        //     _clone setUnconscious false;
        //     _clone playMoveNow "AinjPpneMstpSnonWnonDnon_rolltoback";
        //     // sleep 0.001;
        //     // waitUntil {_clone getVariable "KTWK_FW_animDone"};
        //     sleep 0.8;
        // };
        if (_scream_SSD) then { [selectRandom SSD_RattleOther, _clone, 3, 2] call SSD_fnc_playSound };
        _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
        // _clone playMoveNow _anim;
        // sleep 0.001;
        // waitUntil {_clone getVariable "KTWK_FW_animDone"};
        // // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
        // // waitUntil {(animationState _clone) == _anim};
        // _clone switchMove _anim;
        [_clone, _anim] remoteExec ["switchMove", 0, _clone];
        // sleep (5 + random 10);
        sleep (_animTime min _maxAnimTime);
        // _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
    };

    // Arms
    if (_selection == "hands") exitwith {
        private _animData = (selectRandom [
                                                ["Acts_CivilInjuredArms_1", 20, -20, "back"]
                                                ]) params ["_anim", "_animTime", "_animDir", "_animSide"];
        if (KTWK_opt_debug) then { systemchat format ["Arm injury anim: %1", _anim] };
        // if (_currentSide == "front" && _animSide == "back") then {
        //     _clone setUnconscious true;
        //     sleep 0.001;
        //     _clone setUnconscious false;
        //     _clone playMoveNow "AinjPpneMstpSnonWnonDnon_rolltoback";
        //     // sleep 0.001;
        //     // waitUntil {_clone getVariable "KTWK_FW_animDone"};
        //     sleep 0.8;
        // };
        if (_scream_SSD) then { [selectRandom SSD_RattleOther, _clone, 3, 2] call SSD_fnc_playSound };
        _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
        // _clone playMoveNow _anim;
        // sleep 0.001;
        // waitUntil {_clone getVariable "KTWK_FW_animDone"};
        // // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
        // // waitUntil {(animationState _clone) == _anim};
        // _clone switchMove _anim;
        [_clone, _anim] remoteExec ["switchMove", 0, _clone];
        // sleep (5 + random 10);
        sleep (_animTime min _maxAnimTime);
        // _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
    };

    // Body
    if (_selection == "" || _selection == "body") exitwith {
        // private _inBuilding = [_clone] call KTWK_fnc_inBuilding;
        private _inBuilding = insideBuilding _clone > 0.9;
        private _type = [ selectRandom ["still", "move"], "still"] select _inBuilding;
        _type = "still"; // Disable moving animations (slowly crawling away)
        call {
            if (_type == "still") exitwith {
                private _animData = (selectRandom [
                                                            ["Acts_InjuredLyingRifle01", 10, -30, "back"],
                                                            ["Acts_InjuredLyingRifle02", 10, -30, "back"],
                                                            ["Acts_InjuredLookingRifle01", 10, -30, "back"],
                                                            ["Acts_InjuredLookingRifle02", 10, -30, "back"],
                                                            ["Acts_InjuredLookingRifle03", 10, -30, "back"],
                                                            ["Acts_InjuredLookingRifle04", 10, -30, "back"],
                                                            ["Acts_InjuredLookingRifle05", 10, -30, "back"],
                                                            ["Acts_InjuredAngryRifle01", 10, -30, "back"],
                                                            ["Acts_InjuredSpeakingRifle01", 10, -30, "back"],
                                                            ["Acts_InjuredCoughRifle02", 10, -30, "back"],
                                                            ["Acts_CivilInjuredGeneral_1", 21, 0, "back"],
                                                            ["Acts_CivilInjuredChest_1", 16, 0, "back"]
                                                            // "passenger_flatground_leanleft"
                                                            ]) params ["_anim", "_animTime", "_animDir", "_animSide"];
                if (KTWK_opt_debug) then { systemchat format ["Generic still anim: %1", _anim] };
                if (_currentSide == "front" && _animSide == "back") then {
                    _clone setUnconscious true;
                    sleep 0.001;
                    _clone setUnconscious false;
                    // _clone playMoveNow "AinjPpneMstpSnonWnonDnon_rolltoback";
                    [_clone, "AinjPpneMstpSnonWnonDnon_rolltoback"] remoteExec ["playMoveNow", 0, _clone];
                    // _clone setDir ((getDir _clone) + 180) mod 360;
                    // sleep 0.001;
                    // waitUntil {_clone getVariable "KTWK_FW_animDone"};
                    sleep 0.8;
                };
                if (_anim == "sit") then {
                    // _clone playAction "SitDown";
                    _clone playAction "passenger_flatground_leanleft";
                    // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
                    // waitUntil {(animationState _clone) == _anim};
                } else {
                    sleep 0.001;
                    _clone setDir ((getDir _clone) + _animDir + 180) mod 360;
                    // _clone playMoveNow _anim;
                    // sleep 0.001;
                    // waitUntil {_clone getVariable "KTWK_FW_animDone"};
                    // sleep 0.8;
                    // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
                    // waitUntil {(animationState _clone) == _anim};
                    // _clone switchMove _anim;
                    [_clone, _anim] remoteExec ["switchMove", 0, _clone];
                };
                if (_scream_SSD) then { [selectRandom SSD_RattleOther, _clone, 3, 2] call SSD_fnc_playSound };
                // sleep (10 + random 10);
                sleep (_animTime min _maxAnimTime);
            };

            if (_type == "move") exitwith {
                private _animData = selectRandom [
                                                ["AmovPpneMsprSnonWnonDf_injured", 12, 0, "front"] // slowly crawling - clips
                                                // ["ApanPercMsprSnonWnonDf", 1],    // running scared - looks silly
                                                // ["ApanPknlMsprSnonWnonDf", 1],    // running scared - looks silly
                                                // ["AmovPercMstpSnonWnonDnon_Scared", 2],
                                                // ["AmovPercMstpSnonWnonDnon_Scared2", 2]
                                                ];
                _anim = _animData select 0;
                private _animTime = _animData select 1;
                private _animDir = _animData select 2;
                private _animSide = _animData select 3;
                if (KTWK_opt_debug) then { systemchat format ["Generic moving anim: %1", _anim] };
                if (_currentSide == "front" && _animSide == "back") then {
                    _clone setUnconscious true;
                    sleep 0.001;
                    _clone setUnconscious false;
                    // _clone playMoveNow "AinjPpneMstpSnonWnonDnon_rolltoback";
                    [_clone, "AinjPpneMstpSnonWnonDnon_rolltoback"] remoteExec ["playMoveNow", 0, _clone];
                    // sleep 0.001;
                    // waitUntil {_clone getVariable "KTWK_FW_animDone"};
                    sleep 0.8;
                };
                if (_scream_SSD) then { [selectRandom SSD_RattleOther, _clone, 3, 2] call SSD_fnc_playSound };
                _clone setDir ((getDir _clone) + _animDir) mod 360;
                // _clone playMoveNow _anim;
                [_clone, _anim] remoteExec ["switchMove", 0, _clone];
                sleep 0.001;
                waitUntil {_clone getVariable "KTWK_FW_animDone"};
                // _clone switchMove _anim;
                [_clone, _anim] remoteExec ["switchMove", 0, _clone];
                // waitUntil {(animationState _clone) == "unconsciousfacedown" || (animationState _clone) == "unconsciousfaceup"};
                // waitUntil {(animationState _clone) == _anim select 0};
                sleep ((_animTime - 0.1) min _maxAnimTime);
            };
        };
    }; 

};

// Kill unit
if (KTWK_opt_debug) then { systemchat "Death" };
_clone setUnconscious true;
sleep 0.01;
_unit setVariable ["KTWK_FW_Killed", true, true];

if (_keepCorpse) then {
    private ["_clonePos","_cloneDir"];
    _clonePos = _parentPos;
    _clonePos set [2, (_clonePos#2)+0.1]; 
    _cloneDir = _parentDir;
    if (!isNil {_clone} && {!isNull _clone}) then {
        _clonePos = getPosWorld _clone;
        _clonePos set [2, (_clonePos#2)+0.1]; 
        _cloneDir = getDir _clone;
    };
    deleteVehicle _clone;
    sleep 0.01;
    _unit setVariable ["SSD_disabledSounds", true, true];
    _unit setPosWorld _clonePos;
    _unit setDir _cloneDir;
    _unit setVectorUp (surfaceNormal position _unit);
    _unit setVelocity [0,0,0];
    // _unit hideObjectGlobal false;

    [_unit, true] remoteExecCall ["awake"];
    [_unit, false] remoteExecCall ["awake"];
} else {
    [_clone, true] remoteExecCall ["allowDamage", 0, true];
    _clone setVariable ["SSD_disabledSounds", true, true];
    [_clone, [_selection, 1, true, _instigator]] remoteExecCall ["setHit", 0, _clone];
    [_clone, ["body", 1, true, _instigator]] remoteExecCall ["setHit", 0, _clone];
    _clone setVectorUp (surfaceNormal position _clone);
    _clone setVelocity [0,0,0];
    _clone setVariable ["KTWK_FW_timeDead", time, true];
    
    addToRemainsCollector [_clone];

    // Squad Feedback compatibility
    if (!isNil {SQFB_player}) then {
        if (_grp == group SQFB_player) then { SQFB_units append [_clone] };
    };
};
