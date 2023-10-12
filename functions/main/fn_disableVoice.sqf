
params ["_unit"];
if (_unit in agents) then {_unit = agent _unit};

// SSD Death Screams
_unit setVariable ["SSD_disabledSounds", true, true];

// Unit Voice-overs
_unit setVariable ["UVO_voice", nil, true];
_unit setVariable ["UVO_speaking", nil, true];
_unit setVariable ["UVO_suppressBuffer", nil, true];
_unit setVariable ["UVO_allowDeathShouts", false, true];

// Project SFX
_unit setVariable ["disableUnitSFX", true, true];

// General
[_unit, "NoVoice"] remoteExecCall ["setSpeaker", 0, _unit];
