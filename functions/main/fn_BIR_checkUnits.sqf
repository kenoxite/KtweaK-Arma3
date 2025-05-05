// BettIR

if (!isServer) exitwith {false};
    
private _allInfantry = KTWK_allInfantry select {!isPlayer _x};
private _stealthOpt = KTWK_BIR_stealth_opt_enabled;
private _nvgOpt = KTWK_BIR_NVG_illum_opt_enabled;
private _wpnOpt = KTWK_BIR_wpn_illum_opt_enabled;

private _fnc_inRange = {
    params ["_unit", "_dist"]; 
    private _inRange = false;
    {if (_unit distance _x <= _dist) exitWith { _inRange = true}} forEach allPlayers;
    _inRange
};

private _fnc_deactivateAll = {
    params ["_unit"];
    [_unit] call BettIR_fnc_nvgIlluminatorOff;
    [_unit] call BettIR_fnc_weaponIlluminatorOff;
    _unit setVariable ["KTWK_BIR_nvg", false];
    _unit setVariable ["KTWK_BIR_wpn", false];
};

private _playerGroups = [];
{_playerGroups pushBackUnique (group _x)} forEach allPlayers;
private _darkOutside = overcast > 0.6 || moonIntensity < 0.1;

// Check all infantry units
{
    // Skip if dead
    if !(alive _x) then {
        [_x] call _fnc_deactivateAll;
        continue;
    };
    // Skip if nightvision isn't active
    if (currentVisionMode _x != 1) then {
        [_x] call _fnc_deactivateAll;
        continue;
    };
    // Skip if in vehicle
    if (vehicle _x != _x) then {
        [_x] call _fnc_deactivateAll;
        continue;
    };
    // Skip if too far away from players
    if (!(group _x in _playerGroups) && {!([_x, KTWK_BIR_opt_dist] call _fnc_inRange)}) then {
        [_x] call _fnc_deactivateAll;
        continue;
    };
    private _behaviour = behaviour _x;
    private _inStealth = _behaviour == "STEALTH";
    // Disable if in stealth mode
    if (_stealthOpt == 0 && _inStealth) then {
        [_x] call _fnc_deactivateAll;
        continue;
    };
    // Darkness check for moonlight, overcast and wether the unit is inside a building or not
    private _tooDark = _darkOutside || insideBuilding _x > 0.9;
    private _nvgOn = _x getVariable ["KTWK_BIR_nvg", false];
    private _wpnOn = _x getVariable ["KTWK_BIR_wpn", false];
    // Enable NVG Illuminator
    private _nvgToggle = call {
        if (_nvgOpt == 0) exitwith {false}; // Never enable
        if (_nvgOpt == 1) exitwith {true};  // Always enable
        if (_nvgOpt == 2 && _tooDark) exitwith {true};    // Enable if dark enough
        false
    };
    // Enable weapon Illuminator
    private _wpnToggle = call {
        if (_wpnOpt == 0) exitwith {false}; // Never enable
        if (_wpnOpt == 1) exitwith {true};  // Always enable
        if (_wpnOpt == 2 && _tooDark) exitwith {true};    // Enable if dark enough
        if (_wpnOpt == 3 && _tooDark && _behaviour == "COMBAT") exitwith {true};    // Enable if in combat
        false
    };
    // Stealth options check
    private _stealthToggle = _stealthOpt == 1 || !_inStealth;
    // Toggle activation of NVG illum
    if (_nvgToggle && (_stealthToggle || (_inStealth && _stealthOpt == 3))) then {
        if (!_nvgOn) then {
            [_x] call BettIR_fnc_nvgIlluminatorOn;
            _x setVariable ["KTWK_BIR_nvg", true];
        };
    } else {
        if (_nvgOn) then {
            [_x] call BettIR_fnc_nvgIlluminatorOff;
            _x setVariable ["KTWK_BIR_nvg", false];
        };
    };
    // Toggle activation of weapon illum
    if (_wpnToggle && (_stealthToggle || (_inStealth && _stealthOpt == 2))) then {
        if (!_wpnOn) then {
            [_x] call BettIR_fnc_weaponIlluminatorOn;
            _x setVariable ["KTWK_BIR_wpn", true];
        };
    } else {
        if (_wpnOn) then {
            [_x] call BettIR_fnc_weaponIlluminatorOff;
            _x setVariable ["KTWK_BIR_wpn", false];
        };
    };
} forEach _allInfantry;


// Disable illuminators from dead infantry
{
    [_x] call _fnc_deactivateAll;
} forEach allDeadMen;
