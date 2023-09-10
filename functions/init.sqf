// -----------------------------------------------
// kTWEAKS - Init
// by kenoxite
// -----------------------------------------------

// KTWK_debug = if (is3DENPreview) then { true } else { false };
waitUntil {!isNil "KTWK_opt_debug"};
KTWK_debug = KTWK_opt_debug;

// Init - Humidity Effects
[] execVM "kTweaks\scripts\humidityFX.sqf";

// Init - Fatal Wounds
KTWK_FW_EH_update = [{ if (KTWK_FW_opt_enabled && time > 10) then { [] call KTWK_fnc_FW_checkUnits }; }, 5, []] call CBA_fnc_addPerFrameHandler;
