// KTWK_NVG_fnc_initClient
// NVG Effects - Client initialization and event handlers

if (!hasInterface) exitWith {};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";

KTWK_NVG_ktweak = isClass (_cfgPatches >> "ktweak");

if (isNil "KTWK_aceNightvision") then {
    KTWK_aceNightvision = isClass (_cfgPatches >> "ace_nightvision");
};

_cfgPatches = nil;

// Exit if ace is managing night vision
if (KTWK_aceNightvision) exitWith {};

waitUntil {!isNull player};

// Global vars
if (!KTWK_NVG_ktweak) then {
    KTWK_player = call CBA_fnc_currentUnit;
};

KTWK_NVG_debug_disableCache = false;

// Init NVG subsystem
call KTWK_NVG_fnc_updateGenArrays;
call KTWK_NVG_fnc_updateColorArrays;

// Initialize cached values
call KTWK_NVG_fnc_updateWeapon;
call KTWK_NVG_fnc_updateVehicle;
KTWK_NVG_ambientBrightness = 150;
KTWK_NVG_cachedMode = "";
KTWK_NVG_cachedItemClass = "";
KTWK_NVG_cachedDetection = [1.0, 0, 1.0, 0.5, 0.003];
KTWK_NVG_cachedColor = [];
KTWK_NVG_cachedColorPreset = -1;
KTWK_NVG_cachedZoomIntensity = 0;
KTWK_NVG_effectsActive = false;
KTWK_NVG_lastBlurArray = [];
KTWK_NVG_lastColorArray = [];
KTWK_NVG_lastFilmArray = [];
KTWK_NVG_lastChromArray = [];

// CBA setting changed handler
["settingChanged", {
    params ["_setting"];
    if (_setting in ["KTWK_NVG_opt_color", "KTWK_NVG_opt_autoGen", "KTWK_NVG_opt_intensity"]) then {
        KTWK_NVG_cachedColor = [];
        KTWK_NVG_cachedColorPreset = -1;
        KTWK_NVG_cachedDetection = [1.0, 0, 1.0, 0.5, 0.003];
        KTWK_NVG_cachedItemClass = "";
        KTWK_NVG_lastBlurArray = [];
        KTWK_NVG_lastColorArray = [];
        KTWK_NVG_lastFilmArray = [];
        KTWK_NVG_lastChromArray = [];
    };
}] call CBA_fnc_addEventHandler;

// Weapon changed event handler
KTWK_NVG_EH_weapon = ["weapon", {
    call KTWK_NVG_fnc_updateWeapon;
    KTWK_NVG_cachedItemClass = "";
    KTWK_NVG_cachedMode = "";
}] call CBA_fnc_addPlayerEventHandler;

// Vehicle changed event handler  
KTWK_NVG_EH_vehicle = ["vehicle", {
    call KTWK_NVG_fnc_updateVehicle;
}] call CBA_fnc_addPlayerEventHandler;

// Camera view changed
KTWK_NVG_EH_cameraView = ["cameraView", {
    params ["_unit"];
    if (currentVisionMode _unit != 1) exitWith {};
    private _weapon = currentWeapon _unit;
    private _weaponLower = toLowerANSI _weapon;
    if (_weaponLower in KTWK_NVG_allItems) then {
        KTWK_NVG_cachedMode = "";
        KTWK_NVG_cachedItemClass = "";
        KTWK_NVG_cachedZoomIntensity = 0;
    };
}] call CBA_fnc_addPlayerEventHandler;

// Main effect application PFH
KTWK_NVG_pfh = [{
    if (!isNull (findDisplay 49)) exitWith {};
    
    private _shouldBeActive = KTWK_NVG_opt_enabled && {currentVisionMode KTWK_player == 1};
    
    [_shouldBeActive] call KTWK_NVG_fnc_manageEffects;
    if (!_shouldBeActive) exitWith {};
    
    call KTWK_NVG_fnc_updateLighting;
    private _state = call KTWK_NVG_fnc_getState;
    [_state] call KTWK_NVG_fnc_applyEffects;
}, 0.05, []] call CBA_fnc_addPerFrameHandler;

// Let Ktweak deal with the recurring checks if present
if (KTWK_NVG_ktweak) exitWith {};

// Keep player reference updated
[{
    if (!isNull (findDisplay 49)) exitWith {};
    KTWK_player = call CBA_fnc_currentUnit;
}, 1] call CBA_fnc_addPerFrameHandler;
