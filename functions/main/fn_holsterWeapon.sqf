// 

params ["_unit"];

// Check if the unit is valid and local
if (isNull _unit || {!local _unit}) exitWith {false};

// Get the current weapon and muzzle
private _currentWeapon = currentWeapon _unit;
private _currentMuzzle = currentMuzzle _unit;

// Toggle holster state
if (_currentWeapon == "") then {
    // Trying to unholster
    private _lastWeapon = _unit getVariable ["KTWK_lastWeapon", ""];
    private _lastMuzzle = _unit getVariable ["KTWK_lastMuzzle", ""];
    
    if (_lastWeapon != "") then {
        if (_lastWeapon == primaryWeapon _unit) then {
            _unit selectWeapon _lastWeapon;
        } else {
            if (_lastWeapon == handgunWeapon _unit) then {
                _unit selectWeapon _lastWeapon;
            } else {
                // Last weapon was primary or handgun but is no longer available
                if (primaryWeapon _unit != "") then {
                    _unit selectWeapon (primaryWeapon _unit);
                } else {
                    if (handgunWeapon _unit != "") then {
                        _unit selectWeapon (handgunWeapon _unit);
                    };
                    // If no primary or handgun available, do nothing
                };
            };
        };
        
        // Restore last muzzle if applicable
        if (currentWeapon _unit == _lastWeapon && {_lastMuzzle in getArray (configFile >> "CfgWeapons" >> _lastWeapon >> "muzzles")}) then {
            _unit selectWeapon _lastMuzzle;
        };
    };
} else {
    // Holster current weapon (any type)
    _unit setVariable ["KTWK_lastWeapon", _currentWeapon];
    _unit setVariable ["KTWK_lastMuzzle", _currentMuzzle];
    _unit action ["SwitchWeapon", _unit, _unit, 299];
};

true
