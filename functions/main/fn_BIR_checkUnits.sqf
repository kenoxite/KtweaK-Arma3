//

if (!isServer) exitwith {false};
    
private _allInfantry = KTWK_allInfantry select {!isPlayer _x};
private _stealth = KTWK_BIR_stealth_opt_enabled;
private _nvg = KTWK_BIR_NVG_illum_opt_enabled;
private _wpn = KTWK_BIR_wpn_illum_opt_enabled;

private _fnc_inRange = {
    params ["_unit", "_dist"]; 
    private _inRange = false;
    {if (_unit distance _x <= _dist) exitWith { _inRange = true}} forEach allPlayers;
    _inRange
};

private _playerGroups = [];
{_playerGroups pushBackUnique (group _x)} forEach allPlayers;

// Check all infantry units
{
    // Reset illuminators status
    [_x] call BettIR_fnc_nvgIlluminatorOff;
    [_x] call BettIR_fnc_weaponIlluminatorOff;
    // Skip if nightvision isn't active
    if (currentVisionMode _x != 1) then {continue};
    // Skip if in vehicle
    if (vehicle _x != _x) then {continue};
    // Skip if too far away from players
    if (!(group _x in _playerGroups) && {!([_x, KTWK_BIR_opt_dist] call _fnc_inRange)}) then {continue};
    private _behaviour = behaviour _x;
    private _inStealth = _behaviour == "STEALTH";
    if (_stealth == 0 && _inStealth) then {continue};   // Disable if in stealth mode
    // Darkness check for moonlight, overcast and wether the unit is inside a building or not
    private _posASL = getPosASL _x;
    private _tooDark = overcast > 0.6 || moonIntensity < 0.1 || insideBuilding _x > 0.9;
    // Enable NVG Illuminator
    if (_nvg > 0
        && (
            _stealth == 0 && !_inStealth
            || _stealth == 1   // Enable always regardless of stealth mode
            || (_stealth == 2 && !_inStealth)   // Enable if not in stealth mode
            || _stealth == 3    // Enable if only weapon illuminators are disabled
            )
        ) then {
        if (_nvg == 1
            || (_nvg > 1 && _tooDark)
            ) then {
            if (alive _x) then {[_x] call BettIR_fnc_nvgIlluminatorOn};
        };   
    };
    // Enable weapon Illuminator
    if (_wpn > 0
        && (
            _stealth == 0 && !_inStealth
            || _stealth == 1    // Enable always regardless of stealth mode
            || _stealth == 2   // Enable if only NVGs illuminators are disabled
            || (_stealth == 3 && !_inStealth)  // Enable if not in stealth mode 
            )
        ) then {
        if (_wpn == 1
            || (
                _wpn == 2 && _tooDark
                || (_wpn == 3 && _tooDark && _behaviour == "COMBAT")
                )
            ) then {
            if (alive _x) then {[_x] call BettIR_fnc_weaponIlluminatorOn};
        };
    };
} forEach _allInfantry;


// Disable illuminators from dead infantry
{
    [_x] call BettIR_fnc_nvgIlluminatorOff;
    [_x] call BettIR_fnc_weaponIlluminatorOff;
} forEach allDeadMen;
