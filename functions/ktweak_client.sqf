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
KTWK_player call KTWK_fnc_addInvEH;

// Arsenal EH
[missionNamespace, "arsenalPreOpen", {
    params ["_missionDisplay", "_center"];
    // Check for all weapons stored in inventory and save it's attachments to reapply them later
    KTWK_player setVariable ["KTWK_uniformWeapons", ([KTWK_player, "uniform"] call KTWK_fnc_unitContainerItems)#1];
    KTWK_player setVariable ["KTWK_vestWeapons", ([KTWK_player, "vest"] call KTWK_fnc_unitContainerItems)#1];
    KTWK_player setVariable ["KTWK_backpackWeapons", ([KTWK_player, "backpack"] call KTWK_fnc_unitContainerItems)#1];
}] call BIS_fnc_addScriptedEventHandler;

[missionNamespace, "arsenalOpened", {
    params ["_displayNull", "_toggleSpace"];
    KTWK_player setVariable ["KTWK_arsenalOpened", true, true];
    // Reapply attachments by deleting the base weapons and adding a version with all the attachments
    {
        [uniformContainer KTWK_player, (_x#0)] call CBA_fnc_removeWeaponCargo;
        (uniformContainer KTWK_player) addWeaponWithAttachmentsCargo [_x, 1];
    } forEach (KTWK_player getVariable "KTWK_uniformWeapons");
    KTWK_player setVariable ["KTWK_uniformWeapons", nil];

    {
        [vestContainer KTWK_player, (_x#0)] call CBA_fnc_removeWeaponCargo;
        (vestContainer KTWK_player) addWeaponWithAttachmentsCargo [_x, 1];
    } forEach (KTWK_player getVariable "KTWK_vestWeapons");
    KTWK_player setVariable ["KTWK_vestWeapons", nil];

    {
        [backpackContainer KTWK_player, (_x#0)] call CBA_fnc_removeWeaponCargo;
        (backpackContainer KTWK_player) addWeaponWithAttachmentsCargo [_x, 1];
    } forEach (KTWK_player getVariable "KTWK_backpackWeapons");
    KTWK_player setVariable ["KTWK_backpackWeapons", nil];
}] call BIS_fnc_addScriptedEventHandler;

[missionNamespace, "arsenalClosed", {
    KTWK_player setVariable ["KTWK_arsenalOpened", false, true];
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
// EH - Team Switch
addMissionEventHandler ["TeamSwitch", {
    params ["_previousUnit", "_newUnit"];

    // Recon Drone
    private _actionId = _previousUnit getVariable ["KTWK_GRdrone_actionId", -1];
    if (_actionId >= 0) then {
        // _previousUnit removeAction _actionId;
        [_previousUnit, _actionId] remoteExecCall ["removeAction", 0 , _previousUnit];
        _previousUnit setVariable ["KTWK_GRdrone_actionId", nil, true];
    };
    terminate KTWK_scr_GRdrone;
    _this spawn {
        waitUntil {scriptDone KTWK_scr_GRdrone};
        KTWK_scr_GRdrone = [] execVM "KtweaK\scripts\reconDrone.sqf";
        player remoteControl (_this#1); // Make double sure control is restored to the player
    };

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
    _newUnit call KTWK_fnc_addInvEH;
    _previousUnit removeEventHandler ["InventoryOpened", KTWK_EH_invOpened_ENW];
    _previousUnit removeEventHandler ["InventoryClosed", KTWK_EH_invClosed_ENW];

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

// --------------------------------
// Loop
KTWK_scr_updateClient = [{
    KTWK_player = call KTWK_fnc_playerUnit;

    // AI stop when healed
    // - Thanks, pierremgi!
    if (!isServer) then {
        {
            _x addEventHandler ["handleHeal", {
                if (!KTWK_SFH_opt_enabled) exitwith {};
                _this remoteExec ["KTWK_fnc_AIstopForHealing", _this#0, true];
            }];
            _x setVariable ["KTWK_handleHeal_added", true, true];
        } forEach (KTWK_allInfantry select {!(_x getVariable ["KTWK_handleHeal_added",false])});
    };

    // No map icons if no GPS
    call KTWK_fnc_GPSHideIcons;

    // Slide in slopes
    if (KTWK_slideInSlopes_opt_enabled) then {
        [KTWK_player] call KTWK_fnc_slideInSlopes;
    };

    // Equip Next Weapon
    if !(KTWK_player getVariable ["KTWK_swappingWeapon", false]) then {
        [KTWK_player] call KTWK_fnc_toggleHolsterDisplay;
    };

}, 1, []] call CBA_fnc_addPerFrameHandler;

// Fix for holsters blocking Ravage loot
if (isClass (configFile >> "CfgPatches" >> "ravage")) then {
    KTWK_scr_ENWRavageFix = [{
        if (!isNil {rvg_lootTarget}) then {
            // Hide holsters
            [_unit, 1, 2] call KTWK_fnc_displayHolster; 
            [_unit, 3, 2] call KTWK_fnc_displayHolster;
        };
    }, 0, []] call CBA_fnc_addPerFrameHandler;
};
