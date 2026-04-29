// -----------------------------------------------
// KtweaK - Client
// by kenoxite
// -----------------------------------------------

if (!hasInterface) exitWith {false};

// --------------------------------
// Safechecks for JiP
KTWK_allInfantry = [];
private _cfgPatches = configFile >> "CfgPatches";

if (isNil "KTWK_aceCommon") then
{
    KTWK_aceCommon = isClass(_cfgPatches >> "ace_common");
};
if (isNil "KTWK_aceMedical") then
{
    KTWK_aceMedical = isClass(_cfgPatches >> "ace_medical_engine");
};
if (isNil "KTWK_aceMovement") then
{
    KTWK_aceMovement = isClass(_cfgPatches >> "ace_movement");
};
if (isNil "KTWK_aceFlashlights") then
{
    KTWK_aceFlashlights = isClass(_cfgPatches >> "ace_flashlights");
};
if (isNil "KTWK_aceInteractMenu") then
{
    KTWK_aceInteractMenu = isClass(_cfgPatches >> "ace_interact_menu");
};
if (isNil "KTWK_aceWeather") then
{
    KTWK_aceWeather = isClass(_cfgPatches >> "ace_weather");
};
if (isNil "KTWK_aceFatigue") then
{
    KTWK_aceFatigue = isClass(_cfgPatches >> "ace_advanced_fatigue");
};
if (isNil "KTWK_aceInteraction") then
{
    KTWK_aceInteraction = isClass(_cfgPatches >> "ace_interaction");
};
if (isNil "KTWK_aceNightvision") then
{
    KTWK_aceNightvision = isClass(_cfgPatches >> "ace_nightvision");
};

if (isNil "KTWK_WBKDeath") then
{
    KTWK_WBKDeath = isClass(_cfgPatches >> "WBK_DyingAnimationsMod");
};
if (isNil "KTWK_WBKHeadlamps") then
{
    KTWK_WBKHeadlamps = isClass(_cfgPatches >> "WBK_Headlamps");
};

if (isNil "KTWK_mgsr_poncho") then
{
    KTWK_mgsr_poncho = isClass(_cfgPatches >> "mgsr_poncho");
};

if (isNil "KTWK_pir") then
{
    KTWK_pir = isClass(_cfgPatches >> "PiR");
};

if (isNil "KTWK_ravage") then
{
    KTWK_ravage = isClass(_cfgPatches >> "ravage");
};

if (isNil "KTWK_lambsDanger") then
{
    KTWK_lambsDanger = isClass(_cfgPatches >> "lambs_danger");
};

_cfgPatches = nil;

// --------------------------------
// Wait for player init
waitUntil {!isNull player && time > 1};

KTWK_player = player;

// --------------------------------
// Disable auto map center
call KTWK_fnc_disableAutoMapCenter;

// --------------------------------
// Equip Next Weapon

// Add Put EH
KTWK_ENW_EH_put = KTWK_player addEventHandler ["Put", {
	params ["_unit", "_container", "_item"];
    [_unit] call KTWK_fnc_ENW_addHolsters;
}];

// Add Take EH
KTWK_ENW_EH_take = KTWK_player addEventHandler ["Take", {
	params ["_unit", "_container", "_item"];
    [_unit] call KTWK_fnc_ENW_addHolsters;
}];
// Add inventory EH
KTWK_player call KTWK_fnc_ENW_addInvEH;

[KTWK_player] call KTWK_fnc_ENW_addHolsters;
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
        if (_near isEqualTo []) exitWith { false };
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
}];

// --------------------------------
// EH - PlayerViewChanged
addMissionEventHandler ["PlayerViewChanged", {
    params ["_previousUnit", "_newUnit", "_vehicleIn", "_oldCameraOn", "_newCameraOn", "_uav"];
    KTWK_player = [_newUnit] call KTWK_fnc_getPlayer;
    KTWK_lastPlayer = KTWK_player;
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
        KTWK_scr_GRdrone = [] execVM "z\ktweak\addons\main\scripts\reconDrone.sqf";
        player remoteControl (_this#1); // Make double sure control is restored to the player
    };

    // --------------------------------
    // Equip Next Weapon
    [_newUnit] call KTWK_fnc_ENW_addHolsters;
    // Add and remove inventory EH
    _previousUnit removeEventHandler ["InventoryOpened", KTWK_ENW_EH_invOpened];
    // _previousUnit removeEventHandler ["InventoryClosed", KTWK_EH_invClosed_ENW];
    _newUnit call KTWK_fnc_ENW_addInvEH;

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
KTWK_EH_respawn = player addEventHandler ["Respawn", {
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
        KTWK_scr_GRdrone = [] execVM "z\ktweak\addons\main\scripts\reconDrone.sqf";
    };

    // --------------------------------
    // Disable ADS if unconscious
    KWTK_wasUnconscious = false;
}];

// EH - Killed
KTWK_EH_killed = player addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects", "_shot", "_real"];
    // Remove death blur
    if (KTWK_opt_removeDeathBlur) then {
        0 spawn {
            private _maxTime = time + 10;
            private _timer = time;
            waitUntil {sleep 1; _timer = _timer + 1; _timer >= _maxTime || !isNil {BIS_DeathBlur}};
            BIS_DeathBlur ppEffectAdjust [0];
            BIS_DeathBlur ppEffectCommit 0;
        };
    };
}];

// --------------------------------
// Init - SOG ambient voices
if (!isNil {vn_sam_masteraudioarray}) then {
    call KTWK_fnc_toggleSOGvoices;
};

// --------------------------------
// Init - Humidity Effects
KTWK_scr_HFX = [] execVM "z\ktweak\addons\main\scripts\humidityFX.sqf";

// Init - Ghost Recon Drone
KTWK_scr_GRdrone = [] execVM "z\ktweak\addons\main\scripts\reconDrone.sqf";

// Init - Cold Breath
KTWK_scr_coldBreath = [] execVM "z\ktweak\addons\main\scripts\coldBreath.sqf";

// Init - Heat Haze
KTWK_scr_heatHaze = [] execVM "z\ktweak\addons\main\scripts\heatHaze.sqf";

// Init - Restrict Stance
KTWK_scr_restrictStance = [] execVM "z\ktweak\addons\main\scripts\restrictStance.sqf";

// Init - Crouch Walking Is Tiring
KTWK_scr_crouchMoveStamina = [] execVM "z\ktweak\addons\main\scripts\crouchMoveStamina.sqf";

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
    if (!isNull (findDisplay 49)) exitWith {};    // Don't check while paused

    // AI stop when healed
    if (!isServer) then {
        {
            if !(_x getVariable ["KTWK_handleHeal_added", false]) then {
                _x addEventHandler ["HandleHeal", {
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
            [KTWK_player, 1, 2] call KTWK_fnc_ENW_displayHolster; 
            [KTWK_player, 3, 2] call KTWK_fnc_ENW_displayHolster;
        };
    }, 0, []] call CBA_fnc_addPerFrameHandler;
};
