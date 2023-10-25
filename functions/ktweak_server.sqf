// -----------------------------------------------
// KtweaK - Server
// by kenoxite
// -----------------------------------------------

if (!isServer) exitwith {false};

KTWK_allInfantry = [];
publicVariable "KTWK_allInfantry";
KTWK_allInfPlayers = [];
KTWK_allCreatures = [];
KTWK_allAnimals = [];
KTWK_allPredators = [];

KTWK_BIR_opt_enabled_last = KTWK_BIR_opt_enabled;

KTWK_aceCommon = isClass(configFile >> "CfgPatches" >> "ace_common");
publicVariable "KTWK_aceCommon";
KTWK_aceMedical = isClass(configFile >> "CfgPatches" >> "ace_medical_engine");
publicVariable "KTWK_aceMedical";
KTWK_aceMovement = isClass(configFile >> "CfgPatches" >> "ace_movement");
publicVariable "KTWK_aceMovement";

// -----------------------------------------------
// AI auto enable IR laser
["CAManBase", "fired", {
    if (!KTWK_laser_opt_enabled || {currentVisionMode (_this#0) != 1}) exitwith {};
    // Enable IR laser
    (_this#0) enableIRLasers true;
    _this spawn {
        sleep 2;
        // Disable IR laser
        (_this#0) enableIRLasers false;
    };
}, true, [], true] call CBA_fnc_addClassEventHandler;

["CAManBase", "killed", {
    params ["_unit"];
    // Equip Next Weapon
    //  - Remove rifle holster
    [_unit, 1, 2] call KTWK_fnc_displayHolster;
    //  - Remove launcher holster
    [_unit, 3, 2] call KTWK_fnc_displayHolster;

    // Disable illuminators when dead
    [_unit] call BettIR_fnc_nvgIlluminatorOff;
    [_unit] call BettIR_fnc_weaponIlluminatorOff;
}, true, [], true] call CBA_fnc_addClassEventHandler;

// AI stop when healed
["CAManBase", "HandleHeal", {
    if (!KTWK_SFH_opt_enabled) exitwith {};
    _this remoteExec ["KTWK_fnc_AIstopForHealing", _this#0, true];
}, true, [], true] call CBA_fnc_addClassEventHandler;

// ACE Map Flashlights
["CAManBase", "init", {
    if (!KTWK_ACEfl_opt_enabled || !isClass (configFile >> "CfgVehicles" >> "ACE_Flashlight_KSF1Item")) exitwith {};
    params ["_unit"];
    if (!alive _unit) exitwith {};
    private _fl = [
        "ACE_Flashlight_MX991",
        "ACE_Flashlight_XL50",
        "ACE_Flashlight_KSF1"
        ];
    // Exit if unit already has one
    private _hasFl = false;
    private _unitItems = itemsWithMagazines _unit;
    {if (_x in _unitItems) then { _hasFl = true }} forEach _fl;
    if (_hasFl) exitwith {};
    // Give appropriate flashlight based on settings
    private _side = side _unit;
    private _item = "";
    call {
        if (_side == west && {KTWK_ACEfl_opt_BLUFOR > 0}) exitWith {
            if (KTWK_ACEfl_opt_BLUFOR < 4) then {
                _item = _fl#(KTWK_ACEfl_opt_BLUFOR-1);
            } else {
                _item = selectRandom _fl;
            };
        };
        if (_side == east && {KTWK_ACEfl_opt_OPFOR > 0}) exitWith {
            if (KTWK_ACEfl_opt_OPFOR < 4) then {
                _item = _fl#(KTWK_ACEfl_opt_OPFOR-1);
            } else {
                _item = selectRandom _fl;
            };
        };
        if (_side == resistance && {KTWK_ACEfl_opt_INDEP > 0}) exitWith {
            if (KTWK_ACEfl_opt_INDEP < 4) then {
                _item = _fl#(KTWK_ACEfl_opt_INDEP-1);
            } else {
                _item = selectRandom _fl;
            };
        };
        if (_side == civilian && {KTWK_ACEfl_opt_CIV > 0}) exitWith {
            if (KTWK_ACEfl_opt_CIV < 4) then {
                _item = _fl#(KTWK_ACEfl_opt_CIV-1);
            } else {
                _item = selectRandom _fl;
            };
        };
    }; 
    if (_item != "") then { _unit addItem _item };
}, true, [], true] call CBA_fnc_addClassEventHandler;

// --------------------------------
addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];

    // Brighter full moon nights
    if (KTWK_BN_opt_enabled > 0 && {call KTWK_fnc_isNight}) then {
        [[_id], true] call KTWK_fnc_brighterNight_set;
    };
}];

// --------------------------------
// Brighter full moon nights
#include "brightNights.hpp"

call KTWK_fnc_brighterNight_check;

// --------------------------------
// Global system loop
KTWK_scr_update = [{
    if (!isServer) exitwith {false};

    private _allUnits = allUnits;
    private _agents = agents;

    // Update all creatures array
    KTWK_allCreatures = _allUnits select { !([_x] call KTWK_fnc_isHuman) };
    (_agents select { alive agent _x && {!([_x] call KTWK_fnc_isHuman)}}) apply { KTWK_allCreatures pushBack (agent _x); };

    // Update all animals array
    KTWK_allAnimals = KTWK_allCreatures select {[_x] call KTWK_fnc_isAnimal};
    (_agents select { alive agent _x && {[_x] call KTWK_fnc_isAnimal}}) apply { KTWK_allAnimals pushBack (agent _x); };

    // Update all infantry units array
    KTWK_allInfantry = _allUnits select {!(_x in KTWK_allCreatures)};
    publicVariable "KTWK_allInfantry";

    // Update all infantry players array
    KTWK_allInfPlayers = KTWK_allInfantry select {isPlayer _x};

    // Disable voice mods for non humans
    if (KTWK_disableVoices_opt_creatures) then {
        call KTWK_fnc_disableVoiceCheck;
    };

    // Fatal Wounds
    if (KTWK_FW_opt_enabled && time > 10) then { call KTWK_fnc_FW_checkUnits };

    // BettIR - auto enable NVG illuminator for all units
    if (!isNil "BettIR_fnc_nvgIlluminatorOn") then {
        if (KTWK_BIR_opt_enabled) then { call KTWK_fnc_BIR_checkUnits };
        // Disable illuminators if option is disabled now but was enabled before
        if (!KTWK_BIR_opt_enabled && {KTWK_BIR_opt_enabled_last}) then {
            {
                [_x] call BettIR_fnc_nvgIlluminatorOff;
                [_x] call BettIR_fnc_weaponIlluminatorOff;
            } forEach (KTWK_allInfantry select {!isPlayer _x});
        };
        KTWK_BIR_opt_enabled_last = KTWK_BIR_opt_enabled;
    };

    // AI will defend from predators
    if (KTWK_opt_AIPredDefense_enable) then {
        call KTWK_fnc_AIPredatorDefense;
    };

    // Poncho swap
    if (KTWK_ponchoSwap_opt_enabled) then {
        {[_x] remoteExecCall ["KTWK_fnc_ponchoSwap", _x]} forEach (KTWK_allInfantry + allDeadMen);
    };

    // Brighter full moon nights
    call KTWK_fnc_brighterNight_check;

    _allUnits = nil;
    _agents = nil;
}, 3, []] call CBA_fnc_addPerFrameHandler;
