// Disable voice mods for non humans
private _isUnitDisabled = false;
private _isDisabledStalker = false;
private _nonHumans = allUnits select { !(_x in KTWK_allInfantry) };
(agents select { !([_x] call KTWK_fnc_isHuman) }) apply { _nonHumans pushBack (agent _x); };
KTWK_allCreatures = +_nonHumans;

// Stalker voices
private _stalkerArray = missionNamespace getVariable ["FGSVunits",[]];
private _stalkerInstalled = !isNil {_unitsArray};
{
    [_x] call KTWK_fnc_disableVoice;
    _isUnitDisabled = true;
    // Disable Stalker Voices
    if (_stalkerInstalled) then {
        _isUnitDisabled = false;
        private _idx = _stalkerArray find _x;
        if (_idx >= 0) then {
            _stalkerArray deleteAt _idx;
            missionNamespace setVariable ["FGSVunits",_stalkerArray];
            _isUnitDisabled = true;
        };
    };
    if (_isUnitDisabled) then {
         _x setVariable ["KTWK_disabledVoice", true];
    };
} forEach (KTWK_allCreatures select {!(_x getVariable ["KTWK_disabledVoice", false])});
