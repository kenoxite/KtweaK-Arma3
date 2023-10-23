// Disable voice mods for non humans

if (!isServer) exitwith {false};

private _isUnitDisabled = false;

// Stalker voices
private _stalkerArray = missionNamespace getVariable ["FGSVunits",[]];
private _stalkerInstalled = !isNil {_stalkerArray};
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
