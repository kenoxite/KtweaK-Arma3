// Brighter nights - unSet Client
// by kenoxite


params [["_noWait", false]];

player setVariable ["KTWK_BN_set", false, true];
setApertureNew [-1];

if (isNil {KTWK_BN_colorC}) exitwith {false};
KTWK_BN_colorC ppEffectAdjust [1,1,0,[0,0,0,0],[1,1,1,1],[0.5,0.25,0.25,0]];
KTWK_BN_colorC ppEffectCommit ([60, 0] select _noWait);
