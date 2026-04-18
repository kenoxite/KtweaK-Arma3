if (!KTWK_NVG_opt_enabled) exitWith {
    if (!isNil "KTWK_NVG_pfh" || {!isNil "KTWK_NVG_lightingProbe"}) then {
        call KTWK_NVG_fnc_disableSystem;
    };
};

// Event handlers
if (isNil "KTWK_NVG_EH_weapon") then {
    KTWK_NVG_EH_weapon = ["weapon", { 
        KTWK_NVG_weaponZoom = getNumber (configFile >> "CfgWeapons" >> currentWeapon KTWK_player >> "opticsZoomInit"); 
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_vehicle") then {
    KTWK_NVG_EH_vehicle = ["vehicle", { 
        KTWK_NVG_vehicleMFD = (count ([configOf (vehicle KTWK_player) >> "MFD", 0] call BIS_fnc_returnChildren)) > 0; 
    }] call CBA_fnc_addPlayerEventHandler;
};

// System reactivation EHs - won't be removed
if (isNil "KTWK_NVG_EH_visibleMap") then {
    KTWK_NVG_EH_visibleMap = ["visibleMap", {
        params ["_unit", "_isMapShown"];
        if (_isMapShown) exitWith {
            call KTWK_NVG_fnc_disableSystem;
        };
        if (isNil "KTWK_NVG_pfh") exitWith {
            call KTWK_NVG_fnc_initSystem;
        };
    }] call CBA_fnc_addPlayerEventHandler;
};

if (isNil "KTWK_NVG_EH_visionMode") then {
    KTWK_NVG_EH_visionMode = ["visionMode", {
        params ["_unit", "_mode", "_number"];
        if (_mode != 1) exitWith {
            call KTWK_NVG_fnc_disableSystem;
        };
        if (isNil "KTWK_NVG_pfh") exitWith {
            call KTWK_NVG_fnc_initSystem;
        };
    }] call CBA_fnc_addPlayerEventHandler;
};

KTWK_NVG_lightingProbe = "camera" camCreate [0,0,0];

private _irLightActive = KTWK_player getVariable ["KTWK_NVG_irLightActive", false];
[_irLightActive] call KTWK_NVG_fnc_toggleIRLight;

call KTWK_NVG_fnc_createHandles;
call KTWK_NVG_fnc_createPfh;
