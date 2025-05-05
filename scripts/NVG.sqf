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

KTWK_fnc_NVG_zoomIntensity = {
    params ["_unit", "_veh", "_inVehicle", "_MFD", "_weaponZoom", "_intensity"];
    private _isAiming = cameraView == "GUNNER";
    private _disable = _MFD && {(driver _veh == _unit || gunner _veh == _unit)} && {!_isAiming};
    private _zoom = [call KK_fnc_getZoom, 1] select _disable;
    private _zoomIntensityMod = call {
        if (_disable) exitWith {1}; // Disable effect if MFD active
        if (!_inVehicle && {_weaponZoom < 0.1} && {_isAiming}) exitWith {28}; // Using rangefinder or similar
        if (_inVehicle && {((_veh currentvisionmode (_veh unitTurret _unit))#0) == 1} && {_isAiming}) exitWith {56}; // Using the vehicle's NV
        if (!_inVehicle && {_zoom > 10} && {_isAiming}) exitWith {16}; // Using scope with NV on
        9
    };
    _intensity * (_zoom / _zoomIntensityMod);
};

waitUntil {!isNull player};

KTWK_NVG_lastWeapon = currentWeapon KTWK_player;
KTWK_NVG_lastWeaponZoom = getnumber (configfile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");

private _veh = vehicle KTWK_player;
private _inVehicle = _veh != KTWK_player;
KTWK_lastVehicle = _veh;
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
{ _x ppEffectForceInNVG true; _x ppEffectEnable false } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppColor, KWTK_NVG_ppFilm];

// Change effect intensity based on zoom, type of NVG, etc
KTWK_NVG_PFH = [{
    params ["_args", "_pfhId"];
    
    if (!KTWK_NVG_opt_enabled || {currentVisionMode KTWK_player != 1}) exitWith {
        { _x ppEffectEnable false } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppColor, KWTK_NVG_ppFilm];
    };

    private _veh = vehicle KTWK_player;
    { _x ppEffectEnable (currentVisionMode KTWK_player == 1 && isNull curatorCamera && (positionCameraToWorld [0,0,0] distance _veh) < 30) } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppColor, KWTK_NVG_ppFilm];

    if (KTWK_NVG_lastWeapon != currentWeapon KTWK_player) then {
        KTWK_NVG_lastWeapon = currentWeapon KTWK_player;
        KTWK_NVG_lastWeaponZoom = getnumber (configfile >> "CfgWeapons" >> KTWK_NVG_lastWeapon >> "opticsZoomInit");
    };

    private _inVehicle = _veh != KTWK_player;
    if (KTWK_lastVehicle != _veh) then {
        KTWK_lastVehicle = _veh;
        KTWK_lastVehicleMFD = (count ([configFile >> "CfgVehicles" >> typeOf _veh >> "MFD", 0] call BIS_fnc_returnChildren)) > 0;
    };

    private _zoomIntensity = [KTWK_player, _veh, _inVehicle, KTWK_lastVehicleMFD, KTWK_NVG_lastWeaponZoom, KTWK_NVG_opt_intensity] call KTWK_fnc_NVG_zoomIntensity;

    KWTK_NVG_ppBlur ppEffectAdjust [[0.25 + (_zoomIntensity * 0.35), 0.1] select (_zoomIntensity == 1)];
    KWTK_NVG_ppFilm ppEffectAdjust [0.22, 1, (_zoomIntensity * 3) min 8, 0.4, 0.2, 0];
    
    { _x ppEffectCommit 0 } forEach [KWTK_NVG_ppBlur, KWTK_NVG_ppFilm];
}, 0.05, []] call CBA_fnc_addPerFrameHandler;
