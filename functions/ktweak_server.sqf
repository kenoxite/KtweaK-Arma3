// -----------------------------------------------
// KtweaK - Server
// by kenoxite
// -----------------------------------------------

if (!isServer) exitWith {false};

KTWK_allInfantry = [];
publicVariable "KTWK_allInfantry";
KTWK_allInfPlayers = [];
KTWK_allCreatures = [];
KTWK_allAnimals = [];
KTWK_allPredators = [];

KTWK_BIR_opt_enabled_last = KTWK_BIR_opt_enabled;

// ---------------------------------------
// Mods check
private _cftPatches = configFile >> "CfgPatches";

KTWK_aceCommon = isClass(_cftPatches >> "ace_common");
publicVariable "KTWK_aceCommon";
KTWK_aceMedical = isClass(_cftPatches >> "ace_medical_engine");
publicVariable "KTWK_aceMedical";
KTWK_aceMovement = isClass(_cftPatches >> "ace_movement");
publicVariable "KTWK_aceMovement";
KTWK_aceFlashlights = isClass(_cftPatches >> "ace_flashlights");
publicVariable "KTWK_aceFlashlights";
KTWK_aceInteractMenu = isClass(_cftPatches >> "ace_interact_menu");
publicVariable "KTWK_aceInteractMenu";
KTWK_aceWeather = isClass(_cftPatches >> "ace_weather");
publicVariable "KTWK_aceWeather";
KTWK_aceFatigue = isClass(_cftPatches >> "ace_advanced_fatigue");
publicVariable "KTWK_aceFatigue";
KTWK_aceInteraction = isClass(_cftPatches >> "ace_interaction");
publicVariable "KTWK_aceInteraction";
KTWK_aceNightvision = isClass(_cftPatches >> "ace_nightvision");
publicVariable "KTWK_aceNightvision";

KTWK_WBKDeath = isClass(_cftPatches >> "WBK_DyingAnimationsMod");
publicVariable "KTWK_WBKDeath";
KTWK_WBKHeadlamps = isClass(_cftPatches >> "WBK_Headlamps");
publicVariable "KTWK_WBKHeadlamps";

KTWK_mgsr_poncho = isClass(_cftPatches >> "mgsr_poncho");
publicVariable "KTWK_mgsr_poncho";

KTWK_pir = isClass(_cftPatches >> "PiR");
publicVariable "KTWK_pir";

KTWK_ravage = isClass(_cftPatches >> "ravage");
publicVariable "KTWK_ravage";

_cftPatches = nil;

// -----------------------------------------------
// AI auto enable IR laser
["CAManBase", "fired", {
    params ["_unit"];
    if (!KTWK_laser_opt_enabled || {currentVisionMode _unit != 1}) exitWith {};
    if !([_unit] call KTWK_fnc_isHuman) exitWith {};
    // Enable IR laser
    _unit enableIRLasers true;
    _unit spawn {
        sleep 2;
        // Disable IR laser
        _this enableIRLasers false;
    };
}, true, [], true] call CBA_fnc_addClassEventHandler;

["CAManBase", "killed", {
    params ["_unit"];
    if !([_unit] call KTWK_fnc_isHuman) exitWith {};
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
    if (!KTWK_SFH_opt_enabled) exitWith {};
    _this remoteExec ["KTWK_fnc_AIstopForHealing", _this#0, true];
}, true, [], true] call CBA_fnc_addClassEventHandler;

// ACE Map Flashlights
if (KTWK_aceFlashlights) then {
    ["CAManBase", "init", {
        if (!KTWK_ACEfl_opt_enabled) exitWith {false};
        params ["_unit"];
        if (!alive _unit) exitWith {false};
        if !([_unit] call KTWK_fnc_isHuman) exitWith {false};
        private _fl = [
            "ACE_Flashlight_MX991",
            "ACE_Flashlight_XL50",
            "ACE_Flashlight_KSF1"
            ];
        // Exit if unit already has one
        private _hasFl = false;
        private _unitItems = itemsWithMagazines _unit;
        {if (_x in _unitItems) then { _hasFl = true }} forEach _fl;
        if (_hasFl) exitWith {false};
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
};

// Add Lights to AI
["CAManBase", "init", {
    if (!KTWK_AIlights_opt_enabled) exitWith {};
    if (KTWK_AIlights_opt_onlyDark && (!(call KTWK_fnc_isNight) || (call KTWK_fnc_isNight && call KTWK_fnc_beforeDawn))) exitWith {};
    params ["_unit"];
    if !([_unit] call KTWK_fnc_isHuman) exitWith {};
    if (!alive _unit) exitWith {};
    [_unit] spawn KTWK_fnc_addLightToAI;
}, true, [], true] call CBA_fnc_addClassEventHandler;

// ACE Firing Devices and Defusal Kits
if (KTWK_aceInteraction) then {
    ["CAManBase", "init", {
        if (!KTWK_ACEexpl_opt_enabled) exitWith {false};
        params ["_unit"];
        if (!alive _unit) exitWith {false};
        if !([_unit] call KTWK_fnc_isHuman) exitWith {false};
        private _unitItems = itemsWithMagazines _unit;
        // Check for firing devices
        private _fd = [
            "ACE_Clacker",
            "ACE_M26_Clacker",
            "ACE_Cellphone"
            ];
        private _hasFd = false;
        {if (_x in _unitItems) then { _hasFd = true }} forEach _fd;
        if (_hasFd) exitWith {false};
        // Check if unit has vanilla explosives that can use remote trigger
        private _expl = [
            "ClaymoreDirectionalMine_Remote_Mag",
            "DemoCharge_Remote_Mag",
            "SatchelCharge_Remote_Mag",
            "SLAMDirectionalMine_Wire_Mag",
            "IEDLandBig_Remote_Mag",
            "IEDUrbanBig_Remote_Mag",
            "IEDLandSmall_Remote_Mag",
            "IEDUrbanSmall_Remote_Mag"
        ];
        private _hasExpl = false;
        {if (_x in _unitItems) then { _hasExpl = true }} forEach _expl;
        if (_hasExpl) then {
            _unit addItem "ACE_Clacker";
        };
        // Check if unit can defuse and doesn't have defusal kit
        if !(_unit getUnitTrait "explosiveSpecialist") exitwith {false};
        if ("ACE_DefusalKit" in _unitItems) exitwith {false};
        _unit addItem "ACE_DefusalKit";
    }, true, [], true] call CBA_fnc_addClassEventHandler;
};

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
[{
    if (!isNull (findDisplay 49)) exitwith {};    // Don't check while paused

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
    if (!KTWK_WBKDeath && !KTWK_pir && {KTWK_FW_opt_enabled && time > 10}) then { call KTWK_fnc_FW_checkUnits };

    // BettIR - auto enable NVG illuminator for all units
    if (!isNil "BettIR_fnc_nvgIlluminatorOn") then {
        if (KTWK_BIR_opt_enabled && call KTWK_fnc_isDuskorDawn) then { call KTWK_fnc_BIR_checkUnits };
        // Disable illuminators if option is disabled now but was enabled before
        if (!KTWK_BIR_opt_enabled && {KTWK_BIR_opt_enabled_last}) then {
            {
                [_x] call BettIR_fnc_nvgIlluminatorOff;
                [_x] call BettIR_fnc_weaponIlluminatorOff;
            } forEach (KTWK_allInfantry select {!isPlayer _x && !isNull _x});
        };
        KTWK_BIR_opt_enabled_last = KTWK_BIR_opt_enabled;
    };

    // AI will defend from predators
    if (KTWK_opt_AIPredDefense_enable) then {
        call KTWK_fnc_AIPredatorDefense;
    };

    // Poncho swap
    if (KTWK_mgsr_poncho && {KTWK_ponchoSwap_opt_enabled}) then {
        {
            if (!isNull _x) then { 
                [_x] remoteExecCall ["KTWK_fnc_ponchoSwap", _x];
            }
        } forEach (KTWK_allInfantry + allDeadMen);
    };

    // Brighter full moon nights
    call KTWK_fnc_brighterNight_check;

    // WBK Headlamps loop alternative
    if (!WBK_IsAIEnableHeadlamps) then {
        private _dark = call KTWK_fnc_isDuskOrDawn;
        private _dayTime = !call KTWK_fnc_isNight;
        private _AIlights_opt_force = KTWK_AIlights_opt_force;
        {
            private _unit = _x;
            if (isNil {_unit getVariable "KTWK_WBKFlOn"}) then { _unit setVariable ["KTWK_WBKFlOn", false, true]; };
            private _flOn = _unit getVariable ["KTWK_WBKFlOn", false];
            private _hasNVG = [_unit] call KTWK_fnc_NVGcheck;
            private _hasFl = (WBK_HeadlampsAndFlashlights findIf {_x in items _unit} != -1);
            private _beh = behaviour _unit;
            if (!_flOn 
                && _dark 
                && _hasFl
                && !_hasNVG 
                && (_beh == "COMBAT" || _AIlights_opt_force)
            ) then {
                _unit spawn WBK_CustomFlashlight;
                _unit setVariable ["KTWK_WBKFlOn", true, true];
            };
            if (_flOn 
                && ( 
                    (_dayTime && !_dark && _hasFl && !_hasNVG)
                    || 
                    (_beh != "COMBAT" && !_AIlights_opt_force)
                )
            ) then {
                _unit spawn WBK_CustomFlashlight;
                _unit setVariable ["KTWK_WBKFlOn", false, true];
            };
        } forEach (KTWK_allInfantry select {!(isPlayer _x)});
    };
}, 3] call CBA_fnc_addPerFrameHandler;
