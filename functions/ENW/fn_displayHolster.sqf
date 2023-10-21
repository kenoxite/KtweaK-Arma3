//

params [["_unit", KTWK_player], ["_type", 1], ["_mode", 0], ["_style", 0], ["_displayItem", []]];

private _unitVar = call {
    if (_type == 1) exitWith {"KTWK_rifleHolster"};  
    if (_type == 3) exitWith {"KTWK_launcherHolster"};
    "" 
};

if (_unitVar == "") exitWith {false};

private _holster = _unit getVariable [_unitVar, objNull];
call {
    // Add/Update
    if (_mode == 0) exitWith {
        // Add holster
        if (isNull _holster) then {
            _holster = createVehicle ["Weapon_Empty", [0,0,0], [], 0, "CAN_COLLIDE"];
            _unit setVariable [_unitVar, _holster];
        };

        // Update holster position
        call {
            // Rifle
            if (_type == 1) exitWith {
                private _isLong = [_displayItem#0] call KTWK_fnc_isWeaponLong;
                private _isShort = [_displayItem#0] call KTWK_fnc_isWeaponShort;
                call {
                    // Back right
                    if (_style == 0) exitWith {
                        call {
                            if (_isLong) exitWith {
                                _holster attachTo [_unit, [0.1,-0.2,-0.2], "spine3", true];
                                [_holster, [70,0,-90]] call BIS_fnc_setObjectRotation;
                            };
                            _holster attachTo [_unit, [0.15,-0.2,0.05], "spine3", true];
                            [_holster, [70,0,-90]] call BIS_fnc_setObjectRotation;
                        };
                    };
                    // Back left
                    if (_style == 1) exitWith {
                        call {
                            if (backpack _unit == "") exitWith {
                                call {
                                    if (_isLong) exitWith {
                                        _holster attachTo [_unit, [-0.05,-0.2,-0.2], "spine3", true];  
                                        [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                                    };
                                    _holster attachTo [_unit, [-0.05,-0.2,0.05], "spine3", true];  
                                    [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                                };
                            };
                            if (secondaryWeapon _unit == "") exitWith {
                                call {
                                    if (_isLong) exitWith {
                                        _holster attachTo [_unit, [-0.15,-0.17,-0.2], "spine3", true];  
                                        [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                                    };
                                    _holster attachTo [_unit, [-0.15,-0.17,0.05], "spine3", true];  
                                    [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                                };
                            };
                            call {
                                if (_isLong) exitWith {
                                    _holster attachTo [_unit, [-0.25,-0.25,-0.2], "spine3", true];  
                                    [_holster, [0,0,-90]] call BIS_fnc_setObjectRotation;
                                };
                                _holster attachTo [_unit, [-0.24,-0.25,0.05], "spine3", true];  
                                [_holster, [0,0,-90]] call BIS_fnc_setObjectRotation;
                            };
                        };
                    };
                    // Front downwards
                    if (_style == 2) exitWith {
                        _holster attachTo [_unit, [0.05,0.35,-0.35], "spine3", true];  
                        [_holster, [270,0,70]] call BIS_fnc_setObjectRotation;
                    };
                    // Front horizontal
                    if (_style == 3) exitWith { 
                        call {
                            if (_isLong) exitWith {
                                _holster attachTo [_unit, [0.1,0.27,-0.2], "spine3", true]; 
                                [_holster, [180,90,0]] call BIS_fnc_setObjectRotation;
                            };
                            if (_isShort) exitWith {
                                _holster attachTo [_unit, [-0.1,0.25,-0.2], "spine3", true]; 
                                [_holster, [180,90,0]] call BIS_fnc_setObjectRotation;
                            };
                            _holster attachTo [_unit, [0,0.25,-0.2], "spine3", true]; 
                            [_holster, [180,90,0]] call BIS_fnc_setObjectRotation;
                        };
                    };
                    // Front upwards
                    if (_style == 4) exitWith {                        
                        _holster attachTo [_unit, [-0.05,0.2,0], "spine3", true];  
                        [_holster, [100,30,290]] call BIS_fnc_setObjectRotation;
                    };
                    // Default - Back right
                    _holster attachTo [_unit, [0.15,-0.15,0.05], "spine3", true];
                    [_holster, [70,0,-90]] call BIS_fnc_setObjectRotation;
                };
            };
            // Launcher
            if (_type == 3) exitWith {
                call {
                    // Pelvis back
                    if (_style == 0) exitWith {
                        _holster attachTo [_unit, [0.1,-0.25,0.03], "pelvis", true]; 
                        [_holster, [0,-80,0]] call BIS_fnc_setObjectRotation;
                    };
                    // Back left
                    if (_style == 1) exitWith {
                        _holster attachTo [_unit, [-0.22,-0.2,0.01], "spine3", true];     
                        [_holster, [270,0,-100]] call BIS_fnc_setObjectRotation;
                    };
                    // Back right
                    if (_style == 2) exitWith {
                        _holster attachTo [_unit, [0.18,-0.2,0.01], "spine3", true];   
                        [_holster, [260,5,-100]] call BIS_fnc_setObjectRotation;
                    };
                    // Default - Pelvis back
                    _holster attachTo [_unit, [0.1,-0.25,0.03], "pelvis", true]; 
                    [_holster, [-20,0,20]] call BIS_fnc_setObjectRotation;
                };
            };
        };

        // Update displayed item
        if (count _displayItem > 0) then {
            _holster setDamage 0;
            clearWeaponCargoGlobal _holster;
            _holster addWeaponWithAttachmentsCargoGlobal [_displayItem, 1];
            _holster setDamage 1;
        };
    };
    // Empty
    if (_mode == 1) exitWith {
        if (!isNull _holster) then {
            _holster setDamage 0;
            clearWeaponCargoGlobal _holster;
            _holster setDamage 1;
        };
    };
    // Remove
    if (_mode == 2) exitWith {
        deleteVehicle _holster;
        _unit setVariable [_unitVar, nil, true];
        _unit setVariable ["KTWK_swappingWeapon", false];
    };
    // Hide
    if (_mode == 3) exitWith {
        detach _holster;
        _holster setPos [0,0,-1000];
    };
};

_displayItem
