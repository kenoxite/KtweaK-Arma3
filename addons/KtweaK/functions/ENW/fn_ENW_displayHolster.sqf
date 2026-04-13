// KTWK_fnc_ENW_displayHolster
// Manages holster container creation, positioning, and display state

// Parameters:
//   _unit        - Unit to attach holster to (default: KTWK_player)
//   _type        - Holster type: 1 = rifle, 3 = launcher (default: 1)
//   _mode        - Operation: 0 = add/update, 1 = empty, 2 = remove, 3 = hide (default: 0)
//   _style       - Position style (rifle: 0-4, launcher: 0-2) (default: 0)
//   _displayItem - Weapon items array to display in holster (default: [])
// Returns:
//   Array - The displayItem passed in

params [["_unit", KTWK_player], ["_type", 1], ["_mode", 0], ["_style", 0], ["_displayItem", []]];

private _unitVar = call {
    if (_type == 1) exitWith {"KTWK_ENW_rifleHolster"};
    if (_type == 3) exitWith {"KTWK_ENW_launcherHolster"};
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
            // Rifle positioning
            if (_type == 1) exitWith {
                private _weaponClass = _displayItem param [0, ""];
                private _isLong = [_weaponClass] call KTWK_fnc_ENW_isWeaponLong;
                private _isShort = [_weaponClass] call KTWK_fnc_ENW_isWeaponShort;
                
                call {
                    // Back right (default)
                    if (_style == 0) exitWith {
                        if (_isLong) exitWith {
                            _holster attachTo [_unit, [0.1,-0.2,-0.2], "spine3", true];
                            [_holster, [70,0,-90]] call BIS_fnc_setObjectRotation;
                        };
                        _holster attachTo [_unit, [0.15,-0.2,0.05], "spine3", true];
                        [_holster, [70,0,-90]] call BIS_fnc_setObjectRotation;
                    };
                    
                    // Back left
                    if (_style == 1) exitWith {
                        if (backpack _unit == "") exitWith {
                            if (_isLong) exitWith {
                                _holster attachTo [_unit, [-0.05,-0.2,-0.2], "spine3", true];
                                [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                            };
                            _holster attachTo [_unit, [-0.05,-0.2,0.05], "spine3", true];
                            [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                        };
                        
                        if (secondaryWeapon _unit == "") exitWith {
                            if (_isLong) exitWith {
                                _holster attachTo [_unit, [-0.15,-0.17,-0.2], "spine3", true];
                                [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                            };
                            _holster attachTo [_unit, [-0.15,-0.17,0.05], "spine3", true];
                            [_holster, [270,0,-90]] call BIS_fnc_setObjectRotation;
                        };
                        
                        if (_isLong) exitWith {
                            _holster attachTo [_unit, [-0.25,-0.25,-0.2], "spine3", true];
                            [_holster, [0,0,-90]] call BIS_fnc_setObjectRotation;
                        };
                        _holster attachTo [_unit, [-0.24,-0.25,0.05], "spine3", true];
                        [_holster, [0,0,-90]] call BIS_fnc_setObjectRotation;
                    };
                    
                    // Front downwards
                    if (_style == 2) exitWith {
                        _holster attachTo [_unit, [0.05,0.35,-0.35], "spine3", true];
                        [_holster, [270,0,70]] call BIS_fnc_setObjectRotation;
                    };
                    
                    // Front horizontal
                    if (_style == 3) exitWith {
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
                    
                    // Front upwards
                    if (_style == 4) exitWith {
                        _holster attachTo [_unit, [-0.05,0.2,0], "spine3", true];
                        [_holster, [100,30,290]] call BIS_fnc_setObjectRotation;
                    };
                    
                    // Default fallback - Back right
                    _holster attachTo [_unit, [0.15,-0.15,0.05], "spine3", true];
                    [_holster, [70,0,-90]] call BIS_fnc_setObjectRotation;
                };
            };
            
            // Launcher positioning
            if (_type == 3) exitWith {
                call {
                    // Pelvis back (default)
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
                    
                    // Default fallback - Pelvis back
                    _holster attachTo [_unit, [0.1,-0.25,0.03], "pelvis", true];
                    [_holster, [-20,0,20]] call BIS_fnc_setObjectRotation;
                };
            };
        };

        // Update displayed item
        if (_displayItem isNotEqualTo []) then {
            _holster setDamage 0;
            clearWeaponCargoGlobal _holster;
            _holster addWeaponWithAttachmentsCargoGlobal [_displayItem, 1];
            _holster setDamage 1;
        };
    };
    
    // Empty holster contents
    if (_mode == 1) exitWith {
        if (!isNull _holster) then {
            _holster setDamage 0;
            clearWeaponCargoGlobal _holster;
            _holster setDamage 1;
        };
    };
    
    // Remove holster
    if (_mode == 2) exitWith {
        deleteVehicle _holster;
        _unit setVariable [_unitVar, nil, true];
        _unit setVariable ["KTWK_swappingWeapon", false];
    };
    
    // Hide holster (move away)
    if (_mode == 3) exitWith {
        detach _holster;
        _holster setPos [0,0,-1000];
    };
};

_displayItem
