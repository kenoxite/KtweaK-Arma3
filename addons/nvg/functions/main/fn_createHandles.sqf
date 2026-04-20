// KTWK_NVG_fnc_createHandles
// Creates ppEffect handlers for NVG effects
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\nvg\cacheIndices.hpp"

KTWK_NVG_filmGrainHandle = ppEffectCreate ["filmGrain", 2001];
KTWK_NVG_blurHandle = ppEffectCreate ["dynamicBlur", 775];
KTWK_NVG_colorHandle = ppEffectCreate ["ColorCorrections", 1505];
KTWK_NVG_colorHandle ppEffectForceInNVG true; 

KTWK_NVG_filmGrainHandle ppEffectEnable KTWK_NVG_opt_filmGrainEnabled;
KTWK_NVG_blurHandle ppEffectEnable true;
KTWK_NVG_colorHandle ppEffectEnable true;

KTWK_NVG_cache set [IDX_HANDLESCREATED, true];
