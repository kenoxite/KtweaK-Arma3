
params ["_unit", ["_unconscious", false]];
if (_unit in agents) then {_unit = agent _unit};

call {
    if (_unconscious) exitWith {
        _unit setVariable ["KTWK_voice", speaker _unit, true];
        _unit setVariable ["KTWK_UVO_voice", _unit getVariable ["UVO_voice", "GUER"], true];
        _unit setVariable ["KTWK_UVO_speaking", _unit getVariable ["UVO_speaking", false], true];
        _unit setVariable ["KTWK_UVO_suppressBuffer", _unit getVariable ["UVO_suppressBuffer", 0], true];

        // Unit Voice-overs
        _unit setVariable ["UVO_voice", nil, true];
        _unit setVariable ["UVO_speaking", nil, true];
        _unit setVariable ["UVO_suppressBuffer", nil, true];

        // Project SFX
        _unit setVariable ["disableUnitSFX", true, true];
    };

    // SSD Death Screams
    _unit setVariable ["SSD_disabledSounds", true, true];

    // Unit Voice-overs
    _unit setVariable ["UVO_voice", nil, true];
    _unit setVariable ["UVO_speaking", nil, true];
    _unit setVariable ["UVO_suppressBuffer", nil, true];
    _unit setVariable ["UVO_allowDeathShouts", false, true];

    // Project SFX
    _unit setVariable ["disableUnitSFX", true, true];
};

// General
[_unit, "NoVoice"] remoteExecCall ["setSpeaker", 0, _unit];
