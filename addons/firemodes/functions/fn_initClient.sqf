// KTWK_CFM_fnc_initClient
// Client initialization and event handlers

if (!hasInterface) exitWith {};

waitUntil {!isNull player};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_CFM_ktweak = isClass (_cfgPatches >> "ktweak");
_cfgPatches = nil;

// Player reference
if (!KTWK_CFM_ktweak) then {
    KTWK_player = [] call KTWK_CFM_fnc_getPlayer;
    KTWK_lastPlayer = KTWK_player;
};

if (isNil "KTWK_CFM_EH_playerViewChanged") then {
    KTWK_CFM_EH_playerViewChanged = addMissionEventHandler ["PlayerViewChanged", {
        params ["_previousUnit", "_newUnit", "_vehicleIn","_oldCameraOn", "_newCameraOn", "_uav"];
        if (!KTWK_CFM_ktweak) then {
            KTWK_player = [_newUnit] call KTWK_CFM_fnc_getPlayer;
            KTWK_lastPlayer = KTWK_player;
        };
    }];
};

// KTWK_CFM_fnc_keyDownHandler = {
//     params ["_display", "_dik", "_shift", "_ctrl", "_alt"];
    
//     private _unit = KTWK_player;
//     private _veh = vehicle _unit;
//     private _canFirePrimary = (
//         isNull objectParent _unit
//         || (!isNull objectParent _unit && {driver _veh != _unit}  && {commander _veh != _unit} && {gunner _veh != _unit});
//     private _handled = false;
    
//     // Get vanilla nextWeapon key
//     private _nextWeaponKeys = actionKeys "nextWeapon";
//     if (_dik in _nextWeaponKeys) then {
//         if (_canFirePrimary) then {
//             [_unit, 1] call KTWK_CFM_fnc_cycleFiremode;
//             _handled = true;
//         };
//     };
    
//     // Get vanilla Switch to Primary Weapon key
//     private _primaryKeys = actionKeys "SwitchPrimary";
//     if (_dik in _primaryKeys) then {
//         if (_canFirePrimary) then {
//             [_unit, 1] call KTWK_CFM_fnc_nextWeapon;
//             _handled = true;
//         };
//     };
    
//     _handled;
// };

// // Add handler
// waitUntil {sleep 0.1; !isNull (findDisplay 46)};
// KTWK_CFM_EH_keyDownHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {_this call KTWK_CFM_fnc_keyDownHandler}];

// // Cleanup on mission end
// addMissionEventHandler ["Ended", {
//     if (!isNil "KTWK_CFM_EH_keyDownHandler") then {
//         (findDisplay 46) displayRemoveEventHandler ["KeyDown", KTWK_CFM_EH_keyDownHandler];
//     };
// }];
