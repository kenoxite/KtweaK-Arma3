// fn_initClient.sqf
// NVG Effects - Client initialization and main loop

if (!hasInterface) exitWith {};

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";

KTWK_NVG_ktweak = isClass (_cfgPatches >> "ktweak");

if (isNil "KTWK_aceNightvision") then {
    KTWK_aceNightvision = isClass (_cfgPatches >> "ace_nightvision");
};

_cfgPatches = nil;

// Global vars
if (!KTWK_NVG_ktweak) then {
    KTWK_player = call CBA_fnc_currentUnit;
};

waitUntil {!isNull player};

// Init NVG subsystem
call KTWK_NVG_fnc_initSystem;

// Change effect intensity based on zoom, type of NVG, etc
KTWK_NVG_pfh = [{
    if (!isNull (findDisplay 49)) exitWith {};    // Don't check while paused
    params ["_args", "_pfhId"];
    
    if (!KTWK_NVG_opt_enabled || {currentVisionMode KTWK_player != 1}) exitWith {
        { _x ppEffectEnable false } forEach [KTWK_NVG_ppBlur, KTWK_NVG_ppColor, KTWK_NVG_ppFilm];
    };

    private _veh = vehicle KTWK_player;
    { _x ppEffectEnable (currentVisionMode KTWK_player == 1 && {isNull curatorCamera} && {(positionCameraToWorld [0,0,0] distance _veh) < 30}) } forEach [KTWK_NVG_ppBlur, KTWK_NVG_ppColor, KTWK_NVG_ppFilm];

    if (KTWK_NVG_lastWeapon != currentWeapon KTWK_player) then {
        KTWK_NVG_lastWeapon = currentWeapon KTWK_player;
        KTWK_NVG_lastWeaponZoom = getNumber (configFile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");
    };

    private _inVehicle = _veh != KTWK_player;
    if (KTWK_lastVehicle != _veh) then {
        KTWK_lastVehicle = _veh;
        KTWK_lastVehicleMFD = (count ([configOf _veh >> "MFD", 0] call BIS_fnc_returnChildren)) > 0;
    };

    private _zoomIntensity = [KTWK_player, _veh, _inVehicle, KTWK_lastVehicleMFD, KTWK_NVG_lastWeaponZoom, KTWK_NVG_opt_intensity] call KTWK_NVG_fnc_zoomIntensity;

    KTWK_NVG_ppBlur ppEffectAdjust [[0.25 + (_zoomIntensity * 0.35), 0.1] select (_zoomIntensity == 1)];
    KTWK_NVG_ppFilm ppEffectAdjust [0.22, 1, (_zoomIntensity * 3) min 8, 0.4, 0.2, 0];
    
    { _x ppEffectCommit 0 } forEach [KTWK_NVG_ppBlur, KTWK_NVG_ppFilm];
}, 0.05, []] call CBA_fnc_addPerFrameHandler;

// Let Ktweak deal with the recurring checks if present
if (KTWK_NVG_ktweak) exitWith {};

// Keep player reference updated
[{
    if (!isNull (findDisplay 49)) exitWith {};
    KTWK_player = call CBA_fnc_currentUnit;
}, 1] call CBA_fnc_addPerFrameHandler;
