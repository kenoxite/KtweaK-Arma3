// fn_init.sqf
// Bodypart HUD - Initialization and mod detection

if (!hasInterface) exitWith {};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";

KTWK_BPH_ktweak = isClass (_cfgPatches >> "ktweak");

if (isNil "KTWK_aceMedical") then {
    KTWK_aceMedical = isClass (_cfgPatches >> "ace_medical_engine");
};

_cfgPatches = nil;

// Global vars
if (!KTWK_BPH_ktweak) then {
    KTWK_player = call CBA_fnc_currentUnit;
};

// EH - Game loaded from save
addMissionEventHandler ["Loaded", {
    params ["_saveType"];
    
    _this spawn {
        waitUntil {!isNull player};
        sleep 1;
        
        // Remove existing PFH if running
        if (!isNil "KTWK_BPH_pfh") then {
            [KTWK_BPH_pfh] call CBA_fnc_removePerFrameHandler;
            KTWK_BPH_pfh = nil;
        };
        
        // Restart HUD
        [] call KTWK_BPH_fnc_initHUD;
    };
}];

// Initial HUD start
[] call KTWK_BPH_fnc_initHUD;

// Let Ktweak deal with the recurring checks if present
if (KTWK_BPH_ktweak) exitWith {};

// Keep player reference updated
[{
    if (!isNull (findDisplay 49)) exitWith {};
    KTWK_player = call CBA_fnc_currentUnit;
}, 1] call CBA_fnc_addPerFrameHandler;
