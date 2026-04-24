if (!KTWK_NVG_opt_enabled) exitWith {
    if (!isNil "KTWK_NVG_pfh" || {!isNil "KTWK_NVG_lightingProbe"}) then {
        call KTWK_NVG_fnc_disableSystem;
    };
};

#include "\z\ktweak\addons\nvg\cacheIndices.hpp"

// Event handlers
if (isNil "KTWK_NVG_EH_weapon") then {
    KTWK_NVG_EH_weapon = ["weapon", { 
        params ["_unit", "_newWeapon", "_oldWeapon"];
        KTWK_NVG_weaponZoom = getNumber (configFile >> "CfgWeapons" >> _newWeapon >> "opticsZoomInit");
        [_unit, _newWeapon] call KTWK_NVG_fnc_updateOpticZoom;
        KTWK_NVG_cache set [IDX_MAXRANGECACHED, 0];
        KTWK_NVG_cache set [IDX_MINZOOMOFFSETCACHED, 0];
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_loadout") then {
    KTWK_NVG_EH_loadout = ["loadout", {
        params ["_unit", "_newLoadout", "_oldLoadout"];
        [_unit] call KTWK_NVG_fnc_updateOpticZoom;
        KTWK_NVG_cache set [IDX_MAXRANGECACHED, 0];
        KTWK_NVG_cache set [IDX_MINZOOMOFFSETCACHED, 0];
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_vehicle") then {
    KTWK_NVG_EH_vehicle = ["vehicle", { 
        params ["_unit", "_newVehicle", "_oldVehicle"];
        KTWK_NVG_vehicleMFD = (count ([configOf _newVehicle >> "MFD", 0] call BIS_fnc_returnChildren)) > 0; 
        KTWK_NVG_cache set [IDX_MAXRANGECACHED, 0];
        KTWK_NVG_cache set [IDX_MINZOOMOFFSETCACHED, 0];
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_killed") then {
    KTWK_NVG_EH_killed = player addEventHandler ["Killed", {
        params ["_unit", "_killer"];
        [_unit] call KTWK_NVG_fnc_deleteIRLight;
        KTWK_NVG_irLightToggle = false;
    }];
};

if (isNil "KTWK_NVG_EH_turret") then {
    KTWK_NVG_EH_turret = ["turret", {
        params ["_unit", "_turretPath", "_oldTurretPath"];
        call KTWK_NVG_fnc_updateVehicleOptic;
        private _mode = KTWK_NVG_mode;
        private _nvOn = (((vehicle _unit) currentVisionMode _turretPath) # 0) == 1;
        if (_mode == "disabled" && _nvOn && {KTWK_NVG_opt_enabled} && {isNil "KTWK_NVG_pfh"}) exitWith {
            call KTWK_NVG_fnc_initSystem;
        };
        if (_mode != "disabled" && !_nvOn && {!isNil "KTWK_NVG_pfh"}) exitWith {
            call KTWK_NVG_fnc_disableSystem;
        };
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_playerViewChanged") then {
    KTWK_NVG_EH_playerViewChanged = addMissionEventHandler ["PlayerViewChanged", {
        params ["_previousUnit", "_newUnit", "_vehicleIn","_oldCameraOn", "_newCameraOn", "_uav"];
        // Force update
        KTWK_NVG_cache set [IDX_ACTIVE, false];
        if (!isNull _uav) exitWith {
            call KTWK_NVG_fnc_updateVehicleOptic;
        };
        if (currentVisionMode _newUnit != 1 && {!isNil "KTWK_NVG_pfh"}) exitWith {
            call KTWK_NVG_fnc_disableSystem;
        };
    }];
};


// System reactivation EHs - won't be removed
if (isNil "KTWK_NVG_EH_visibleMap") then {
    KTWK_NVG_EH_visibleMap = ["visibleMap", {
        params ["_unit", "_isMapShown"];
        if (_isMapShown) exitWith {
            [!_isMapShown] call KTWK_NVG_fnc_toggleEffects;
        };
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_visionMode") then {
    KTWK_NVG_EH_visionMode = ["visionMode", {
        params ["_unit", "_mode", "_number"];
        call KTWK_NVG_fnc_resetCache;
        if (_mode != 1 && {!isNil "KTWK_NVG_pfh"}) exitWith {
            call KTWK_NVG_fnc_disableSystem;
        };
        if (_mode == 1 && {KTWK_NVG_opt_enabled} && {isNil "KTWK_NVG_pfh"}) exitWith {
            call KTWK_NVG_fnc_initSystem;
        };
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_featureCamera") then {
    KTWK_NVG_EH_featureCamera = ["featureCamera", {
        params ["_unit", "_cameraMode"];
        // cameramode: "", "splendid", "arsenal", "nexus" (spectator)
        // Disable effects when in any special camera
        if (_cameraMode != "" && {!isNil "KTWK_NVG_pfh"}) exitWith {
            call KTWK_NVG_fnc_disableSystem;
        };
        if (_cameraMode == "" && {KTWK_NVG_opt_enabled} && {isNil "KTWK_NVG_pfh"}) exitWith {
            call KTWK_NVG_fnc_initSystem;
        };
    }] call CBA_fnc_addPlayerEventHandler;
};

// ACE Nightvision EH overrides
if (KTWK_aceNightvision && {KTWK_NVG_opt_aceOverride}) then {
    KTWK_NVG_EH_aceVisionMode = ["visionMode", {
        params ["_unit", "_mode", "_number"];
        missionNamespace setVariable ["ace_nightvision_nvgColorize", [1,1,1,1]];
        missionNamespace setVariable ["ace_nightvision_effectScaling", 0.1];
        missionNamespace setVariable ["ace_nightvision_noiseScaling", 0];
        missionNamespace setVariable ["ace_nightvision_nvgOffset", 0.05]; 
        missionNamespace setVariable ["ace_nightvision_nvgWeight", [0.45,0.45,0.45,0]];
        missionNamespace setVariable ["ace_nightvision_nvgBlend", [1,1,1,0]];
    }] call CBA_fnc_addPlayerEventHandler;
    
    KTWK_NVG_EH_aceCameraView = ["cameraView", {
        missionNamespace setVariable ["ace_nightvision_nvgColorize", [1,1,1,1]];
        missionNamespace setVariable ["ace_nightvision_effectScaling", 0.1];
        missionNamespace setVariable ["ace_nightvision_noiseScaling", 0];
        missionNamespace setVariable ["ace_nightvision_nvgOffset", 0.05]; 
        missionNamespace setVariable ["ace_nightvision_nvgWeight", [0.45,0.45,0.45,0]];
        missionNamespace setVariable ["ace_nightvision_nvgBlend", [1,1,1,0]];
    }] call CBA_fnc_addPlayerEventHandler;
};

KTWK_NVG_lightingProbe = "camera" camCreate [0,0,0];

private _irLightActive = KTWK_player getVariable ["KTWK_NVG_irLightActive", false];
[_irLightActive] call KTWK_NVG_fnc_toggleIRLight;

call KTWK_NVG_fnc_createHandles;
call KTWK_NVG_fnc_createPfh;

KTWK_NVG_isActive = true;
