// KTWK_NVG_fnc_disableSystem
// Disables NVG effects and cleans up resources
//
// Parameters:
//   None
// Returns:
//   Nothing

if (!isNil "KTWK_NVG_filmGrainHandle") then { 
    ppEffectDestroy KTWK_NVG_filmGrainHandle; 
    KTWK_NVG_filmGrainHandle = nil; 
};
if (!isNil "KTWK_NVG_blurHandle") then { 
    ppEffectDestroy KTWK_NVG_blurHandle; 
    KTWK_NVG_blurHandle = nil; 
};
if (!isNil "KTWK_NVG_colorHandle") then { 
    ppEffectDestroy KTWK_NVG_colorHandle; 
    KTWK_NVG_colorHandle = nil; 
};
if (!isNil "KTWK_NVG_pfh") then { 
    [KTWK_NVG_pfh] call CBA_fnc_removePerFrameHandler; 
    KTWK_NVG_pfh = nil; 
};
if (!isNil "KTWK_NVG_lightingProbe") then { 
    camDestroy KTWK_NVG_lightingProbe; 
    KTWK_NVG_lightingProbe = nil; 
}; 
if (!isNil "KTWK_NVG_EH_weapon") then { 
    ["weapon", KTWK_NVG_EH_weapon] call CBA_fnc_removePlayerEventHandler; 
    KTWK_NVG_EH_weapon = nil; 
};
if (!isNil "KTWK_NVG_EH_vehicle") then { 
    ["vehicle", KTWK_NVG_EH_vehicle] call CBA_fnc_removePlayerEventHandler; 
    KTWK_NVG_EH_vehicle = nil; 
};
if (!isNil "KTWK_NVG_EH_loadout") then { 
    ["loadout", KTWK_NVG_EH_loadout] call CBA_fnc_removePlayerEventHandler; 
    KTWK_NVG_EH_loadout = nil; 
};
if (!isNil "KTWK_NVG_EH_killed") then { 
    ["killed", KTWK_NVG_EH_killed] call CBA_fnc_removePlayerEventHandler; 
    KTWK_NVG_EH_killed = nil; 
};
if (!isNil "KTWK_NVG_EH_aceVisionMode") then {
    ["visionMode", KTWK_NVG_EH_aceVisionMode] call CBA_fnc_removePlayerEventHandler;
    KTWK_NVG_EH_aceVisionMode = nil;
};
if (!isNil "KTWK_NVG_EH_aceCameraView") then {
    ["cameraView", KTWK_NVG_EH_aceCameraView] call CBA_fnc_removePlayerEventHandler;
    KTWK_NVG_EH_aceCameraView = nil;
};
if (!isNil "KTWK_NVG_EH_turret") then {
    ["turret", KTWK_NVG_EH_turret] call CBA_fnc_removePlayerEventHandler;
    KTWK_NVG_EH_turret = nil;
};
if (!isNil "KTWK_NVG_EH_turretOpticsMode") then {
    ["turretOpticsMode", KTWK_NVG_EH_turretOpticsMode] call CBA_fnc_removePlayerEventHandler;
    KTWK_NVG_EH_turretOpticsMode = nil;
};
if (!isNil "KTWK_NVG_EH_playerViewChanged") then {
    removeMissionEventHandler ["PlayerViewChanged", KTWK_NVG_EH_playerViewChanged];
    KTWK_NVG_EH_playerViewChanged = nil;
};

[false, false] call KTWK_NVG_fnc_toggleIRLight;

KTWK_NVG_mode = "disabled";

call KTWK_NVG_fnc_resetCache;

KTWK_NVG_isActive = false;
