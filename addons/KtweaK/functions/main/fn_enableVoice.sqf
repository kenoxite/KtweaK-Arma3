
params ["_unit"];
if (_unit in agents) then {_unit = agent _unit};

// SSD Death Screams
_unit setVariable ["SSD_disabledSounds", false, true];

// Unit Voice-overs
_unit setVariable ["UVO_voice", _unit getVariable ["KTWK_UVO_voice", "GUER"], true];
_unit setVariable ["UVO_speaking", _unit getVariable ["KTWK_UVO_speaking", false], true];
_unit setVariable ["UVO_suppressBuffer", _unit getVariable ["KTWK_UVO_suppressBuffer", 0], true];
_unit setVariable ["UVO_allowDeathShouts", true, true];

// Project SFX
_unit setVariable ["disableUnitSFX", false, true];

// General
[_unit, _unit getVariable "KTWK_voice"] remoteExecCall ["setSpeaker", 0, _unit];
