// KTWK_NVG_fnc_toggleEffects
// Disables NVG effects without destroying handles
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\nvg\cacheIndices.hpp"

params [["_activate", true]];

KTWK_NVG_filmGrainHandle ppEffectEnable _activate;
KTWK_NVG_blurHandle ppEffectEnable _activate;
KTWK_NVG_colorHandle ppEffectEnable _activate;

// Force update
KTWK_NVG_cache set [IDX_ACTIVE, false];
