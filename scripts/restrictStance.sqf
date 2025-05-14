// Restrict group units stance when moving in stealth or combat mode

if (!hasInterface) exitWith {false};

#define FAST_SPEED 1.3
#define MOVEMENT_THRESHOLD 1

KTWK_RS_opt_wasEnabled = KTWK_RS_opt_enabled;
KTWK_RS_restricted = [];
private _unit = objNull;
KTWK_RS_noLambs = !KTWK_lambsDanger || {(KTWK_lambsDanger && lambs_danger_disableAIPlayerGroup)}; // Disable if LAMBS Danger is active and player squad is already managed by it
KTWK_phe_restrictStance = [{
    // Clean array of deleted units
    KTWK_RS_restricted = KTWK_RS_restricted - [objNull];

    if (!KTWK_RS_opt_enabled) exitWith {
        if (KTWK_RS_opt_wasEnabled) then {
            {
                _unit = _x;
                if (_SOGAIactive) then {
                    jboy_FastMovers pushBackUnique _unit;
                };
                [_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0];
                [_unit, "AUTO"] remoteExecCall ["setUnitPos", _unit];
                _unit setVariable ["KTWK_RS_wasStealth", nil, false];
                _unit setVariable ["KTWK_RS_wasCombat", nil, false];
                _unit setVariable ["KTWK_RS_wasMoving", nil, false];
                KTWK_RS_restricted = KTWK_RS_restricted - [_unit];
            } forEach (KTWK_allInfantry select {_x in KTWK_RS_restricted});
        };
        KTWK_RS_opt_wasEnabled = KTWK_RS_opt_enabled;
    };
    KTWK_RS_opt_wasEnabled = KTWK_RS_opt_enabled;
    private _SOGAIactive = !isNil {jboy_FastMovers};

    // Check for AI units in player group
    private _units = (units group KTWK_player) select {!isPlayer _x && alive _x && !isNull _x && {((local _x && KTWK_RS_opt_onlyIfLeader) || !KTWK_RS_opt_onlyIfLeader)}};
    {
        _unit = _x;
        KTWK_RS_restricted pushBackUnique _unit;
        // Retrieve status vars from last iteration
        private _wasStealth = _unit getVariable ["KTWK_RS_wasStealth", false];
        private _wasCombat = _unit getVariable ["KTWK_RS_wasCombat", false];
        private _wasMoving = _unit getVariable ["KTWK_RS_wasMoving", false];
        // Check for current status
        private _behaviour = behaviour _unit;
        private _isStealth = KTWK_RS_opt_stealth && {_behaviour == "STEALTH" && KTWK_RS_noLambs};
        private _isCombat = KTWK_RS_opt_combat && {_behaviour == "COMBAT" && KTWK_RS_noLambs};
        private _isMoving = (abs speed _unit > MOVEMENT_THRESHOLD) || {!unitReady _unit};

        // Detect entering or exiting stealth or combat
        if (_isStealth != _wasStealth || _isCombat != _wasCombat) then {
            if (_isStealth || _isCombat) then {
                if (_isMoving) then {
                    [_unit, "MIDDLE"] remoteExecCall ["setUnitPos", _unit];
                    // - Remove unit from SOG AI fast movers array
                    if (_SOGAIactive) then {
                        jboy_FastMovers = jboy_FastMovers - [_unit];
                    };
                    [_unit, FAST_SPEED] remoteExecCall ["setAnimSpeedCoef", 0];
                } else {
                    if (_isStealth) then {
                        [_unit, "DOWN"] remoteExecCall ["setUnitPos", _unit];
                    };
                    if (_isCombat) then {
                        [_unit, "AUTO"] remoteExecCall ["setUnitPos", _unit];
                    };
                };
            } else {
                // Just exited stealth, allow all stances
                if ((unitPos _unit) != "AUTO") then {
                    [_unit, "AUTO"] remoteExecCall ["setUnitPos", _unit];
                    // - Add unit back to SOG AI fast movers array
                    if (_SOGAIactive) then {
                        jboy_FastMovers pushBackUnique _unit;
                    };
                    [_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0];
                };
            };
            _unit setVariable ["KTWK_RS_wasStealth", _isStealth, false];
            _unit setVariable ["KTWK_RS_wasCombat", _isCombat, false];
            _unit setVariable ["KTWK_RS_wasMoving", _isMoving, false];
        };

        // If in stealth or combat, detect movement state change (start/stop moving)
        if ((_isStealth || _isCombat) && (_isMoving != _wasMoving)) then {
            if (_isMoving) then {
                [_unit, "MIDDLE"] remoteExecCall ["setUnitPos", _unit];
                // - Remove unit from SOG AI fast movers array
                if (_SOGAIactive) then {
                    jboy_FastMovers = jboy_FastMovers - [_unit];
                };
                [_unit, FAST_SPEED] remoteExecCall ["setAnimSpeedCoef", 0];
            } else {
                if (_isStealth) then {
                    [_unit, "DOWN"] remoteExecCall ["setUnitPos", _unit];
                };
                if (_isCombat) then {
                    [_unit, "AUTO"] remoteExecCall ["setUnitPos", _unit];
                };
                // - Add unit back to SOG AI fast movers array
                if (_SOGAIactive) then {
                    jboy_FastMovers pushBackUnique _unit;
                };
                [_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0];
            };
            _unit setVariable ["KTWK_RS_wasMoving", _isMoving, false];
        };
    } forEach _units;

    // Disable for those units no longer in the player's group
    {
        _unit = _x;
        if (_SOGAIactive) then {
            jboy_FastMovers pushBackUnique _unit;
        };
        [_unit, 1] remoteExecCall ["setAnimSpeedCoef", 0];
        [_unit, "AUTO"] remoteExecCall ["setUnitPos", _unit];
        _unit setVariable ["KTWK_RS_wasStealth", nil, false];
        _unit setVariable ["KTWK_RS_wasCombat", nil, false];
        _unit setVariable ["KTWK_RS_wasMoving", nil, false];
        KTWK_RS_restricted = KTWK_RS_restricted - [_unit];
    } forEach (KTWK_allInfantry select {(_x in KTWK_RS_restricted) && !(_x in _units)});

}, 2] call CBA_fnc_addPerFrameHandler;
