
params ["_unit"];
if (_unit in agents) then {_unit = agent _unit};

// SSD Death Screams
_unit setVariable ["SSD_disabledSounds", true];

// Unit Voice-overs
_unit setVariable ["UVO_voice", nil];
_unit setVariable ["UVO_speaking", nil];
_unit setVariable ["UVO_suppressBuffer", nil];
_unit setVariable ["UVO_allowDeathShouts", false];

// Project SFX
_unit setVariable ["disableUnitSFX", true];

// General
_unit setSpeaker "NoVoice";
