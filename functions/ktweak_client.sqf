// -----------------------------------------------
// KtweaK - Client
// by kenoxite
// -----------------------------------------------

if (!hasInterface) exitwith {false};

// --------------------------------
// Disable bright night effects
// - SP
addMissionEventHandler ["Ended", {
    params ["_endType"];
    true call KTWK_fnc_brighterNight_unSet_client;
}];
// - MP
0 spawn
{
    waitUntil { !isNull findDisplay 46 };
    findDisplay 46 displayAddEventHandler ["Unload",
    {
        true call KTWK_fnc_brighterNight_unSet_client;
    }];
};

// --------------------------------
// Safechecks for JiP
KTWK_allInfantry = [];
private _cftPatches = configFile >> "CfgPatches";

if (isNil "KTWK_aceCommon") then
{
    KTWK_aceCommon = isClass(_cftPatches >> "ace_common");
};
if (isNil "KTWK_aceMedical") then
{
    KTWK_aceMedical = isClass(_cftPatches >> "ace_medical_engine");
};
if (isNil "KTWK_aceMovement") then
{
    KTWK_aceMovement = isClass(_cftPatches >> "ace_movement");
};
if (isNil "KTWK_aceFlashlights") then
{
    KTWK_aceFlashlights = isClass(_cftPatches >> "ace_flashlights");
};
if (isNil "KTWK_aceInteractMenu") then
{
    KTWK_aceInteractMenu = isClass(_cftPatches >> "ace_interact_menu");
};
if (isNil "KTWK_aceWeather") then
{
    KTWK_aceWeather = isClass(_cftPatches >> "ace_weather");
};
if (isNil "KTWK_aceFatigue") then
{
    KTWK_aceFatigue = isClass(_cftPatches >> "ace_advanced_fatigue");
};
if (isNil "KTWK_aceInteraction") then
{
    KTWK_aceInteraction = isClass(_cftPatches >> "ace_interaction");
};
if (isNil "KTWK_aceNightvision") then
{
    KTWK_aceNightvision = isClass(_cftPatches >> "ace_nightvision");
};

if (isNil "KTWK_WBKDeath") then
{
    KTWK_WBKDeath = isClass(_cftPatches >> "WBK_DyingAnimationsMod");
};
if (isNil "KTWK_WBKHeadlamps") then
{
    KTWK_WBKHeadlamps = isClass(_cftPatches >> "WBK_Headlamps");
};

if (isNil "KTWK_mgsr_poncho") then
{
    KTWK_mgsr_poncho = isClass(_cftPatches >> "mgsr_poncho");
};

if (isNil "KTWK_pir") then
{
    KTWK_pir = isClass(_cftPatches >> "PiR");
};

if (isNil "KTWK_ravage") then
{
    KTWK_ravage = isClass(_cftPatches >> "ravage");
};

if (isNil "KTWK_lambsDanger") then
{
    KTWK_lambsDanger = isClass(_cftPatches >> "lambs_danger");
};

_cftPatches = nil;

// --------------------------------
// Wait for player init
waitUntil {!isNull player && time > 1};

KTWK_player = player;

// --------------------------------
// Disable auto map center
call KTWK_fnc_disableAutoMapCenter;

// --------------------------------
// Equip Next Weapon
private ["_wpns"];
// - Add rifle holster to player unit
if (KTWK_ENW_opt_displayRifle) then {
    _wpns = [KTWK_player, 1, false] call KTWK_fnc_equipNextWeapon;
    if (count _wpns > 0) then {
        [KTWK_player, 1, 0, KTWK_ENW_opt_riflePos, (_wpns#1)] call KTWK_fnc_displayHolster;
    };
};
// - Add launcher holster to player unit
if (KTWK_ENW_opt_displayLauncher) then {
    _wpns = [KTWK_player, 3, false] call KTWK_fnc_equipNextWeapon;
    if (count _wpns > 0) then {
        [KTWK_player, 3, 0, KTWK_ENW_opt_launcherPos, (_wpns#1)] call KTWK_fnc_displayHolster;
    };
};
// Add inventory EH
KTWK_EH_invOpened_ENW = KTWK_player call KTWK_fnc_addInvEH;
KTWK_player setVariable ["KTWK_invOpened", false, true];

// Arsenal EH
[missionNamespace, "arsenalPreOpen", {
    params ["_missionDisplay", "_center"];
    // Check for all weapons stored in inventory and save it's attachments to reapply them later
    KTWK_player setVariable ["KTWK_uniformWeapons", ([KTWK_player, "uniform"] call KTWK_fnc_unitContainerItems)#1];
    KTWK_player setVariable ["KTWK_vestWeapons", ([KTWK_player, "vest"] call KTWK_fnc_unitContainerItems)#1];
    KTWK_player setVariable ["KTWK_backpackWeapons", ([KTWK_player, "backpack"] call KTWK_fnc_unitContainerItems)#1];
}] call BIS_fnc_addScriptedEventHandler;

KTWK_fnc_restoreStoredWeapon =
{
    // Reapply attachments by deleting the base weapons and adding a version with all the attachments
    {
        [uniformContainer KTWK_player, (_x#0)] call CBA_fnc_removeWeaponCargo;
        (uniformContainer KTWK_player) addWeaponWithAttachmentsCargo [_x, 1];
    } forEach (KTWK_player getVariable "KTWK_uniformWeapons");

    {
        [vestContainer KTWK_player, (_x#0)] call CBA_fnc_removeWeaponCargo;
        (vestContainer KTWK_player) addWeaponWithAttachmentsCargo [_x, 1];
    } forEach (KTWK_player getVariable "KTWK_vestWeapons");

    {
        [backpackContainer KTWK_player, (_x#0)] call CBA_fnc_removeWeaponCargo;
        (backpackContainer KTWK_player) addWeaponWithAttachmentsCargo [_x, 1];
    } forEach (KTWK_player getVariable "KTWK_backpackWeapons");
};

[missionNamespace, "arsenalOpened", {
    params ["_displayNull", "_toggleSpace"];
    KTWK_player setVariable ["KTWK_arsenalOpened", true, true];
    call KTWK_fnc_restoreStoredWeapon;
}] call BIS_fnc_addScriptedEventHandler;

[missionNamespace, "arsenalClosed", {
    KTWK_player setVariable ["KTWK_arsenalOpened", false, true];
    call KTWK_fnc_restoreStoredWeapon;
    KTWK_player setVariable ["KTWK_uniformWeapons", nil];
    KTWK_player setVariable ["KTWK_vestWeapons", nil];
    KTWK_player setVariable ["KTWK_backpackWeapons", nil];
}] call BIS_fnc_addScriptedEventHandler;

// --------------------------------
// Save inventory opened status so it can be retrieved remotely
KTWK_EH_invOpened = KTWK_player addEventHandler ["InventoryOpened", {(_this#0) setVariable ["KTWK_invOpened", true, true]}];
KTWK_EH_invClosed = KTWK_player addEventHandler ["InventoryClosed", {(_this#0) setVariable ["KTWK_invOpened", false, true]}];

// --------------------------------
// - ACE arsenal
[missionNamespace, "ace_arsenal_displayOpened", {
    KTWK_player setVariable ["KTWK_arsenalOpened", true, true];
}] call BIS_fnc_addScriptedEventHandler;
[missionNamespace, "ace_arsenal_displayClosed", {
    KTWK_player setVariable ["KTWK_arsenalOpened", false, true];
}] call BIS_fnc_addScriptedEventHandler;

// --------------------------------
// AI stop when opening backpack
KTWK_fnc_SFB_addInvEH = {
    params [["_unit", player]];
    _unit addEventHandler ["InventoryOpened", {
        if (!KTWK_SFB_opt_enabled) exitWith { false };
        params ["_unit", "_container", "_container2"];
        if (isNull _container2) exitWith {false};
        private _near = (_unit nearEntities ["Man", 5]) select {!isPlayer _x && (backpack _x) != ""};
        if (count _near == 0) exitWith { false };
        // Sort by distance
        _near apply { [_x distance _unit, _x] };
        _near sort true;
        [_unit, _near#0] spawn {           
            params ["_player", "_carrier"];
            sleep 0.1;// Wait for other EH to update the invopened unitvar state
            private _startTime = time;
            [_carrier, "MOVE"] remoteExecCall ["disableAI", _carrier, true];
            waitUntil {sleep 1; !alive _carrier || !alive _player || (time - _startTime) > 30 || !(_player getVariable ["KTWK_invOpened", false])};
            [_carrier, "MOVE"] remoteExecCall ["enableAI", _carrier, true];
        }; 
    }];
};
KTWK_EH_invOpened_SFB = [KTWK_player] call KTWK_fnc_SFB_addInvEH;

// --------------------------------
// EH - Game loaded from save
addMissionEventHandler ["Loaded", {
    params ["_saveType"];
    diag_log format[ "KtweaK: Mission loaded from %1", _saveType ];

    // HUD Health
    _this spawn {
        waitUntil {!isNull player};
        sleep 1;
        if (!isNil {KTWK_scr_HUD_health}) then {
            terminate KTWK_scr_HUD_health;
            waitUntil {scriptDone KTWK_scr_HUD_health};
            KTWK_scr_HUD_health = [] execVM "KtweaK\scripts\HUD_health.sqf";
        };
    };
}];

// --------------------------------
// EH - PlayerViewChanged
addMissionEventHandler ["PlayerViewChanged", {
    params [
        "_previousUnit", "_newUnit", "_vehicleIn",
        "_oldCameraOn", "_newCameraOn", "_uav"
    ];
    if (_previousUnit isEqualTo _newUnit) exitWith {false};
    // --------------------------------
    // Recon Drone
    private _actionId = _previousUnit getVariable ["KTWK_GRdrone_actionId", -1];
    if (_actionId >= 0) then {
        // _previousUnit removeAction _actionId;
        [_previousUnit, _actionId] remoteExecCall ["removeAction", 0 , _previousUnit];
        _previousUnit setVariable ["KTWK_GRdrone_actionId", nil, true];
    };
    if (isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) then {
        [_previousUnit, 1, ["ACE_SelfActions", "KTWK_GRdrone"]] call ace_interact_menu_fnc_removeActionFromObject;
    };
    terminate KTWK_scr_GRdrone;
    _this spawn {
        waitUntil {scriptDone KTWK_scr_GRdrone};
        KTWK_scr_GRdrone = [] execVM "KtweaK\scripts\reconDrone.sqf";
        player remoteControl (_this#1); // Make double sure control is restored to the player
    };

    // --------------------------------
    // Equip Next Weapon
    private ["_wpns"];
    if (KTWK_ENW_opt_displayRifle) then {
        // - Add rifle holster to _newUnit
        _wpns = [_newUnit, 1, false] call KTWK_fnc_equipNextWeapon;
        if (count _wpns > 0) then {
            [_newUnit, 1, 0, KTWK_ENW_opt_riflePos, (_wpns#1)] call KTWK_fnc_displayHolster;
        };
    };
    if (KTWK_ENW_opt_displayLauncher) then {
        // - Add launcher holster to _newUnit
        _wpns = [_newUnit, 3, false] call KTWK_fnc_equipNextWeapon;
        if (count _wpns > 0) then {
            [_newUnit, 3, 0, KTWK_ENW_opt_launcherPos, (_wpns#1)] call KTWK_fnc_displayHolster;
        };
    };
    // Add and remove inventory EH
    _previousUnit removeEventHandler ["InventoryOpened", KTWK_EH_invOpened_ENW];
    // _previousUnit removeEventHandler ["InventoryClosed", KTWK_EH_invClosed_ENW];
    KTWK_EH_invOpened_ENW = _newUnit call KTWK_fnc_addInvEH;

    // --------------------------------
    // Save inventory opened status so it can be retrieved remotely
    _previousUnit removeEventHandler ["InventoryOpened", KTWK_EH_invOpened];
    _previousUnit removeEventHandler ["InventoryClosed", KTWK_EH_invClosed];
    KTWK_EH_invOpened = _newUnit addEventHandler ["InventoryOpened", {(_this#0) setVariable ["KTWK_invOpened", true, true]}];
    KTWK_EH_invClosed = _newUnit addEventHandler ["InventoryClosed", {(_this#0) setVariable ["KTWK_invOpened", false, true]}];
    _previousUnit setVariable ["KTWK_invOpened", false, true];
    _newUnit setVariable ["KTWK_invOpened", false, true];
    
    _previousUnit setVariable ["KTWK_arsenalOpened", false, true];
    _newUnit setVariable ["KTWK_arsenalOpened", false, true];

    // --------------------------------
    // Disable ADS if unconscious
    if (lifeState _newUnit == "INCAPACITATED" || {_newUnit getVariable ["AIS_unconscious", false]}) then {
        KWTK_wasUnconscious = true;
    };

    // --------------------------------
    // AI stop when opening backpack
    _previousUnit removeEventHandler ["InventoryOpened", KTWK_EH_invOpened_SFB];
    KTWK_EH_invOpened_SFB = [_newUnit] call KTWK_fnc_SFB_addInvEH;
}];

// --------------------------------
// EH - Respawn
player addEventHandler ["Respawn", {
    params ["_unit", "_corpse"];

    // --------------------------------
    // Readd recon drone action
    private _actionId = _unit getVariable ["KTWK_GRdrone_actionId", -1];
    if (_actionId >= 0) then {
        _unit removeAction _actionId;
        [_corpse, _actionId] remoteExecCall ["removeAction", 0 , _corpse];
        _unit setVariable ["KTWK_GRdrone_actionId", nil, true];
    };
    if (isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) then {
        [_unit, 1, ["ACE_SelfActions", "KTWK_GRdrone"]] call ace_interact_menu_fnc_removeActionFromObject;
    };
    terminate KTWK_scr_GRdrone;
    [] spawn {
        waitUntil {scriptDone KTWK_scr_GRdrone};
        KTWK_scr_GRdrone = [] execVM "KtweaK\scripts\reconDrone.sqf";
    };

    // --------------------------------
    // Disable ADS if unconscious
    KWTK_wasUnconscious = false;
}];

// --------------------------------
// Init - SOG ambient voices
if (!isNil {vn_sam_masteraudioarray}) then {
    call KTWK_fnc_toggleSOGvoices;
};

// --------------------------------
// Init - Humidity Effects
KTWK_scr_HFX = [] execVM "KtweaK\scripts\humidityFX.sqf";

// --------------------------------
// Init - Health HUD
KTWK_scr_HUD_health = [] execVM "KtweaK\scripts\HUD_health.sqf";

// Init - Ghost Recon Drone
KTWK_scr_GRdrone = [] execVM "KtweaK\scripts\reconDrone.sqf";

// Init - Cold Breath
KTWK_scr_coldBreath = [] execVM "KtweaK\scripts\coldBreath.sqf";

// Init - Heat Haze
KTWK_scr_heatHaze = [] execVM "KtweaK\scripts\heatHaze.sqf";

// Init - NVG Effects
KTWK_scr_NVG = [] execVM "KtweaK\scripts\NVG.sqf";

// Init - Restrict Stance
KTWK_scr_restrictStance = [] execVM "KtweaK\scripts\restrictStance.sqf";

// --------------------------------
KTWK_SiS_excluded = [
    // TIOW
    "TIOWSpaceMarine_Base",
    "TIOW_NecronLord_Sautekh",
    "TIOW_NecronWarrior_Sautekh",

    // OPTRE
    "OPTRE_Spartan2_Soldier_Base",
    "OPTRE_Spartan3_Soldier_Base"
];

KWTK_wasUnconscious = false;

// --------------------------------
// Loop
[{
    if (!isNull (findDisplay 49)) exitwith {};    // Don't check while paused
    KTWK_player = call CBA_fnc_currentUnit;

    // AI stop when healed
    if (!isServer) then {
        {
            if !(_x getVariable ["KTWK_handleHeal_added", false]) then {
                _x addEventHandler ["handleHeal", {
                    if (!KTWK_SFH_opt_enabled) exitWith {};
                    _this remoteExec ["KTWK_fnc_AIstopForHealing", _this#0, true];
                }];
                _x setVariable ["KTWK_handleHeal_added", true, true];
            };
        } forEach KTWK_allInfantry;
    };

    // Hide Icons without GPS
    call KTWK_fnc_GPSHideIcons;

    // Slide in slopes
    if (KTWK_slideInSlopes_opt_enabled) then {
        [KTWK_player] call KTWK_fnc_slideInSlopes;
    };

    // Display holsters
    if !(KTWK_player getVariable ["KTWK_swappingWeapon", false]) then {
        [KTWK_player] call KTWK_fnc_toggleHolsterDisplay;
    };

    // Disable ADS if unconscious
    if (lifeState KTWK_player == "INCAPACITATED" || {KTWK_player getVariable ["AIS_unconscious", false]}) then {
        KWTK_wasUnconscious = true;
    } else {
        if (KWTK_wasUnconscious) then {
            KWTK_wasUnconscious = false;
            if (KTWK_opt_noUnconADS) then {
                KTWK_player switchCamera "internal";
            };
        };
    };
}, 1] call CBA_fnc_addPerFrameHandler;

// Fix for holsters blocking Ravage loot
if (KTWK_ravage) then {
    KTWK_phe_ENWRavageFix = [{
        if (!isNil {rvg_lootTarget}) then {
            // Hide holsters
            [_unit, 1, 2] call KTWK_fnc_displayHolster; 
            [_unit, 3, 2] call KTWK_fnc_displayHolster;
        };
    }, 0, []] call CBA_fnc_addPerFrameHandler;
};
