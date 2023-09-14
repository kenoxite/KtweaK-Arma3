// -----------------------------------------------
// kTWEAKS - Init
// by kenoxite
// -----------------------------------------------

waitUntil {!isNil "KTWK_opt_debug"};
KTWK_debug = KTWK_opt_debug;

// Wait for player init
waitUntil {!isNull player && time > 1};

// Init - Humidity Effects
KTWK_scr_HFX = [] execVM "kTweaks\scripts\humidityFX.sqf";

// Update all infantry units array
KTWK_allInfantry = [];
KTWK_FW_EH_update = [{
    private _allInfantry = allUnits select {_x isKindOf "CAManBase"};
    // Exclude zombies, animals, etc
    KTWK_allInfantry = _allInfantry select {
            if (_x isKindOf "zombie"
                || _x isKindOf "dbo_horse_Base_F"
                || !(isNil {_x getVariable "WBK_AI_ISZombie"})
                || faction _x == "dev_mutants"
                ) then {
                false //Remove element from array
            } else {
                true //Keep element in array
            };
        };
}, 3, []] call CBA_fnc_addPerFrameHandler;

// Fatal Wounds
KTWK_FW_EH_update = [{ if (KTWK_FW_opt_enabled && time > 10) then { [] call KTWK_fnc_FW_checkUnits }; }, 5, []] call CBA_fnc_addPerFrameHandler;

// BettIR - auto enable NVG illuminator for all units
if (!isNil "BettIR_fnc_nvgIlluminatorOn") then {
    KTWK_BIR_update = [{ if ((KTWK_BIR_NVG_illum_opt_enabled > 0 || KTWK_BIR_wpn_illum_opt_enabled > 0)) then { [] call KTWK_fnc_BIR_checkUnits }; }, 3, []] call CBA_fnc_addPerFrameHandler;
};

// Init - Health HUD
KTWK_scr_HUD_health = [] execVM "kTweaks\scripts\HUD_health.sqf";

// Init - Ghost Recon Drone
// KTWK_scr_GRdrone = [] execVM "kTweaks\scripts\reconDrone.sqf";
