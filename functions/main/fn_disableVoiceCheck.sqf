// Disable voice mods for non humans

if (!isServer) exitwith {false};

private _isUnitDisabled = false;

// Stalker voices variables
private _stalkerArray = missionNamespace getVariable "FGSVunits";
private _stalkerInstalled = !isNil {_stalkerArray};

// Creatures check
{
    [_x] call KTWK_fnc_disableVoice;
    _isUnitDisabled = true;
    // Disable Stalker Voices
    if (_stalkerInstalled) then {
        _isUnitDisabled = false;
        private _idx = _stalkerArray find _x;
        if (_idx >= 0) then {
            _stalkerArray deleteAt _idx;
            // _stalkerArray set [_idx, objNull];
            missionNamespace setVariable ["FGSVunits",_stalkerArray, true];
            _isUnitDisabled = true;
        };
        // _stalkerArray = missionNamespace getVariable ["EHsound",[]];
        // _idx = _stalkerArray find _x;
        // if (_idx >= 0) then {
        //     _stalkerArray set [_idx, objNull];
        //     missionNamespace setVariable ["EHsound",_stalkerArray, true];
        //     // _isUnitDisabled = true;
        // };
    };
    if (_isUnitDisabled) then {
        _x setVariable ["KTWK_disabledVoice", true, true];
    };
} forEach (KTWK_allCreatures select {!(_x getVariable ["KTWK_disabledVoice", false])});


// Incapacitated infantry check
{
    private _isUnconscious = (incapacitatedState _x) != "" || {_x getVariable ["ACE_isUnconscious", false]};
    private _isCurrentlyDisabled = _x getVariable ["KTWK_disabledVoice", false];
    if (_isUnconscious && !_isCurrentlyDisabled) then {
        [_x, true] call KTWK_fnc_disableVoice;
        _isUnitDisabled = true;
        if (_stalkerInstalled) then {
            _isUnitDisabled = false;
            private _idx = _stalkerArray find _x;
            if (_idx >= 0) then {
                _x setVariable ["KTWK_stalkerVoice", true, true];
                _stalkerArray deleteAt _idx;
                missionNamespace setVariable ["FGSVunits",_stalkerArray, true];
                _isUnitDisabled = true;
            };
        };
        if (_isUnitDisabled) then {
            _x setVariable ["KTWK_disabledVoice", true, true];
        };
    };

    if (!_isUnconscious && _isCurrentlyDisabled) then {
        [_x] call KTWK_fnc_enableVoice;
        _x setVariable ["KTWK_disabledVoice", nil, true];
        
        // Stalker voices
        if (_stalkerInstalled && {_x getVariable ["KTWK_stalkerVoice", false]}) then {
            _stalkerArray pushBackUnique _x;
            missionNamespace setVariable ["FGSVunits",_stalkerArray, true];
        };
    };
} forEach KTWK_allInfantry;
