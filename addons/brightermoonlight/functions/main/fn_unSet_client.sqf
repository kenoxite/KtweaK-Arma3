// KTWK_BM_fnc_unSet_client
// Removes brighter moonlight effect from a client
//
// Parameters:
//   _noWait - Boolean: skip progressive transition (default: false)
// Returns:
//   Boolean - false if effect doesn't exist, true otherwise

params [["_noWait", false]];

player setVariable ["KTWK_BM_set", false, true];
setApertureNew [-1];

if (isNil "KTWK_BM_colorC") exitWith {false};

KTWK_BM_colorC ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.5, 0.25, 0.25, 0]];
KTWK_BM_colorC ppEffectCommit ([60, 0] select _noWait);

true
