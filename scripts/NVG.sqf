/*
    NVG Effect
    by kenoxite

    Based on a script by Tripod27
*/

if (isDedicated || !hasInterface || KTWK_aceNightvision) exitWith {};

KK_fnc_getZoom = {
    (
        [0.5,0.5] 
        distance 
        worldToScreen 
        positionCameraToWorld 
        [0,1.05,1]
    ) * (
        getResolution 
        select 
        5
    )
};

waitUntil {!isNull player};

KTWK_NVG_lastWeapon = currentWeapon KTWK_player;
KTWK_NVG_lastWeaponZoom = getnumber (configfile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");

private _veh = vehicle KTWK_player;
private _inVehicle = _veh != KTWK_player;
KTWK_lastVehicle = _veh;
KTWK_lastVehicleType = call {if (_inVehicle) exitWith {(_veh call BIS_fnc_objectType)#1}; ""};
KTWK_lastVehicleMFD = (count ([configFile >> "CfgVehicles" >> typeOf _veh >> "MFD", 0] call BIS_fnc_returnChildren)) > 0;

// Initialize effects
KWTK_NVG_ppBlur = ppEffectCreate ["dynamicBlur", 500];
KWTK_NVG_ppColor = ppEffectCreate ["ColorCorrections", 1500];
KWTK_NVG_ppFilm = ppEffectCreate ["FilmGrain", 2501];

// Error check
if (KWTK_NVG_ppBlur < 0 || {KWTK_NVG_ppColor < 0} || {KWTK_NVG_ppFilm < 0}) exitWith {
    systemChat "KTWK NVG Effects: PPEffects Error: Failed to create effects";
};

// Configure effects
KWTK_NVG_ppColor ppEffectAdjust [0.6, 1.4, -0.02, [1, 1, 1, 0], [1, 1, 1, 1], [0, 0, 0, 0]];
{ _x ppEffectForceInNVG true } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppColor, KWTK_NVG_ppFilm];
{ _x ppEffectEnable false } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppColor, KWTK_NVG_ppFilm];

// Change effect intensity based on zoom, type of NVG, etc
KTWK_NVG_PFH = [{
    params ["_args", "_pfhId"];
    
    if (!KTWK_NVG_opt_enabled || {currentVisionMode KTWK_player != 1}) exitWith {
        { _x ppEffectEnable false } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppColor, KWTK_NVG_ppFilm];
    };

    private _veh = vehicle KTWK_player;
    { _x ppEffectEnable (currentVisionMode KTWK_player == 1 && isNull curatorCamera && (positionCameraToWorld [0,0,0] distance _veh) < 5) } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppColor, KWTK_NVG_ppFilm];

    if (KTWK_NVG_lastWeapon != currentWeapon KTWK_player) then {
        KTWK_NVG_lastWeapon = currentWeapon KTWK_player;
        KTWK_NVG_lastWeaponZoom = getnumber (configfile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");
    };

    private _inVehicle = _veh != KTWK_player;
    if (KTWK_lastVehicle != _veh) then {
        KTWK_lastVehicle = _veh;
        KTWK_lastVehicleType = call {if (_inVehicle) exitWith {(_veh call BIS_fnc_objectType)#1};""};
        KTWK_lastVehicleMFD = (count ([configFile >> "CfgVehicles" >> typeOf _veh >> "MFD", 0] call BIS_fnc_returnChildren)) > 0;
    };
    private _isAiming = cameraView == "GUNNER";
    private _disable = _inVehicle && {KTWK_lastVehicleType == "Helicopter" || KTWK_lastVehicleType == "Plane"} && {KTWK_lastVehicleMFD} && {(driver _veh == KTWK_player || gunner _veh == KTWK_player)} && {!_isAiming};
    private _zoom = [call KK_fnc_getZoom, 1] select _disable;
    private _zoomIntensityMod = call {
        if (_disable) exitWith {1}; // Disable effect for pilots to not mess with the vehicles HUD
        if (!_inVehicle && {KTWK_NVG_lastWeaponZoom < 0.1} && {_isAiming}) exitWith {28}; // Using rangefinder or similar
        if (_inVehicle && {((_veh currentvisionmode (_veh unitTurret KTWK_player))#0) == 1} && {_isAiming}) exitWith {56}; // Using the vehicle's NVG
        if (!_inVehicle && {_zoom > 10} && {_isAiming}) exitWith {16}; // Using scope with NVG on
        9
    };
    private _zoomIntensity = KTWK_NVG_opt_intensity * (_zoom / _zoomIntensityMod);
    KWTK_NVG_ppBlur ppEffectAdjust [[0.25 + (_zoomIntensity * 0.35), 0.1] select _disable];
    KWTK_NVG_ppFilm ppEffectAdjust [0.22, 1, _zoomIntensity, 0.4, 0.2, false];
    
    { _x ppEffectCommit 0 } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppFilm];
}, 0.05, []] call CBA_fnc_addPerFrameHandler;
