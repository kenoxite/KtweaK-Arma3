// Water Puddles
// by kenoxite

#define DRYRATE 10

KTWK_puddles = [];
KTWK_wasRaining = false;
KTWK_dryRate = DRYRATE;

KTWK_fnc_spawnPuddles = {
    params ["_centerUnit", "_increment", "_maxRange", "_amount"];
    private _puddles = [];
    private _currentMinRange = _increment;

    for "_i" from 0 to _amount do {
        private _attempts = 0;
        private _validPosition = false;
        private _randomPos = [];

        while {!_validPosition && _attempts < 10} do {
            private _randomDistance = _currentMinRange + random (_maxRange - _currentMinRange);
            _randomPos = _centerUnit getPos [_randomDistance, random 360];
            
            // Check if position is not under roof, not too steep, and not underwater
            if (!([AGLToASL _randomPos] call KTWK_fnc_underRoof) &&
                ([_randomPos] call KTWK_fnc_checkSlope < 15) &&
                (getTerrainHeightASL _randomPos > 0)) then {
                _validPosition = true;
            };
            _attempts = _attempts + 1;
        };

        if (_validPosition) then {
            _randomPos set [2, getTerrainHeightASL _randomPos];
            private _posATL = ASLtoATL _randomPos;
            
            _puddle = createSimpleObject ["Land_Puddle_01_F", _posATL, true];
            _puddle setPosATL _posATL;
            _puddle setDir (random 360);
            _puddles pushBack _puddle;
        };

        _currentMinRange = (_currentMinRange + _increment) min _maxRange;
    };
    _puddles
};

KTWK_fnc_checkSlope = {
    params ["_pos", ["_checkRadius", 5]];
    
    private _pos1 = getTerrainHeightASL _pos;
    private _pos2 = getTerrainHeightASL (_pos vectorAdd [_checkRadius,0,0]);
    private _pos3 = getTerrainHeightASL (_pos vectorAdd [0,_checkRadius,0]);
    
    private _slope1 = abs(_pos1 - _pos2) / _checkRadius;
    private _slope2 = abs(_pos1 - _pos3) / _checkRadius;
    
    private _maxSlope = _slope1 max _slope2;
    private _slopeInDegrees = atan _maxSlope;
    
    _slopeInDegrees
};

KTWK_fnc_managePuddles = {
    params ["_centerUnit", "_range", "_maxPuddles"];
    private _sortedPuddles = KTWK_puddles apply {[_x distance2D _centerUnit, _x]};
    _sortedPuddles sort false;
    private ["_puddle"];
    { _puddle = _x #1; if ((_puddle distance2D _centerUnit) > _range) then {KTWK_puddles deleteAt (KTWK_puddles find _puddle); deleteVehicle _puddle;}} forEach _sortedPuddles;
    private _amount = _maxPuddles - (count KTWK_puddles);
    systemChat format ["amount: %1", _amount];
    if (_amount > 0) then {
        private _increment = round (_range / _amount) max 1;
        private _puddles = [_centerUnit, _increment, _range, _amount] call KTWK_fnc_spawnPuddles;
        KTWK_puddles append _puddles;
    };
};

[] spawn {
    private ["_lastPos", "_firstCheck"];
    _firstCheck = true;
    while {true} do {
        if (KTWK_WP_opt_enabled) then {
            call {
                if (rain > 0 && {!(rainParams params ["_snow"])}) exitWith {
                    _lastPos = KTWK_player getVariable ["KTWK_lastPos", getpos vehicle KTWK_player];
                    // [vehicle KTWK_player, 10, 5] call KTWK_fnc_spawnPuddles;
                    if (_firstCheck || {_lastPos distance2D (getpos vehicle KTWK_player) > (KTWK_WP_opt_maxRange / 2)}) then {
                        [vehicle KTWK_player, KTWK_WP_opt_maxRange, KTWK_WP_opt_maxPuddles] call KTWK_fnc_managePuddles;
                        KTWK_player setVariable ["KTWK_lastPos", getpos vehicle KTWK_player];
                        _firstCheck = false;
                    };
                    KTWK_wasRaining = true;
                    KTWK_dryRate = DRYRATE;
                };
                if (KTWK_wasRaining && {KTWK_dryRate > 0}) exitWith {
                    KTWK_dryRate = KTWK_dryRate - 1;
                };
                KTWK_dryRate = DRYRATE;
                KTWK_wasRaining = false;
                if (count KTWK_puddles > 0) then {
                    {deleteVehicle _X} forEach KTWK_puddles;
                    KTWK_puddles = [];
                    _firstCheck = true;
                };
            };
        } else {
            if (count KTWK_puddles > 0) then {
                {deleteVehicle _X} forEach KTWK_puddles;
                KTWK_puddles = [];
                _firstCheck = true;
            };
        };
        sleep 3;
    };
};
