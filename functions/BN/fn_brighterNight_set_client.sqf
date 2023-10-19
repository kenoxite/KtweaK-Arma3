// Brighter nights - Set Client
// by kenoxite

params ["_effect", "_aperture", "_noWait"];

if (isNil {KTWK_BN_colorC}) then {
    KTWK_BN_colorC = ppEffectCreate ["ColorCorrections",2000]; 
    KTWK_BN_colorC ppEffectAdjust [1,1,0,[0,0,0,0],[1,1,1,1],[0.5,0.25,0.25,0]];
    KTWK_BN_colorC ppEffectCommit 0;
    KTWK_BN_colorC ppEffectEnable true;
};

// Apply immediately if it's mission start
if (time < 5) then {_noWait = true};    

KTWK_BN_colorC ppEffectAdjust _effect;
KTWK_BN_colorC ppEffectCommit ([60, 0] select _noWait);

if (count _aperture > 0) then {
    setApertureNew _aperture;
} else {
    setApertureNew [-1];
};

player setVariable ["KTWK_BN_set", true, true];
