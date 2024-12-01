/*
    Heat Haze
    by kenoxite
*/

if (!hasInterface) exitWith {};

// Initialize ACE variables if not present
if (!KTWK_aceWeather) then {
    ace_weather_enabled = false;
    ace_weather_currentTemperature = 0;
};

// Global variables
KTWK_HZ_debug = 0; // 0: Disabled, 1: Debug messages, 2: Debug messages + visible particles
KTWK_HZ_distance = 5;
KTWK_HZ_maxHeight = 10;
KTWK_HZ_forceMaxIntensity = false;
KTWK_HZ_tempThreshold = 25; // Temperature threshold in Celsius for method 0
KTWK_HZ_method = 1; // 0: Original method, 1: New method based on black surface temperature
KTWK_aceSurfaceTemp = 0;

KTWK_fnc_HZ_createHeatHaze = {
    params ["_position", "_size"];
    private _source = createVehicleLocal ["#particlesource", _position, [], 0, "can_collide"];
    _source setVehiclePosition [[_position#0,_position#1], [], 0 , "can_collide"];
    private _particleShape = ["\A3\data_f\ParticleEffects\Universal\Refract.p3d", "\A3\data_f\ParticleEffects\Universal\Smoke.p3d"] select (KTWK_HZ_debug == 2);
    _source setParticleParams [
        [_particleShape, 1, 0, 1],
        "", "Billboard", 1, 0.5, [0, 0, 0], [0, 0, 0], 0, 0.8, 1, 0,
        [(_size select 0), 0.5, (_size select 2)], [[1, 1, 1, 0.06], [1, 1, 1, 0.12], [1, 1, 1, 0.06]], [0.08, 0.1, 0.12], 0.1, 0.05, "", "", "", 0, false, 0
    ];
    _source setParticleRandom [0, [0, 0, 0], [0, 0, 0], 0, 0.1, [0, 0, 0, 0.06], 0, 0];
    _source setDropInterval 0.1;
    _source
};

KTWK_fnc_HZ_calculateIntensity = {
    [KTWK_aceWeather && {ace_weather_enabled} && {KTWK_HZ_opt_aceTemp}, KTWK_HZ_opt_useHighest] call KTWK_fnc_getTemp params ["_airTemp", "_surfaceTemp"];

    if (KTWK_HZ_forceMaxIntensity) exitWith { KTWK_HZ_opt_maxIntensity };

    switch (KTWK_HZ_method) do {
        case 0: {
            private _tempDiff = _surfaceTemp - _airTemp;
            if (_surfaceTemp < KTWK_HZ_tempThreshold) exitWith { 0 };
            ((_tempDiff max 0) min 15) / 15 * KTWK_HZ_opt_maxIntensity
        };
        case 1: {
            if (_surfaceTemp < KTWK_HZ_tempThreshold) exitWith { 0 };
            private _intensityFactor = (_surfaceTemp - KTWK_HZ_tempThreshold) / (40 - KTWK_HZ_tempThreshold);
            (_intensityFactor min 1) * KTWK_HZ_opt_maxIntensity
        };
        default { 0 };
    };
};

KTWK_fnc_HZ_isHotSurface = {
    params ["_pos"]; // AGL

    private _heatAccSurf = [
        "asph",
        "concr",
        "beach",
        "desert",
        "sand",
        "tarmac",
        "dead",

        "hiekka",
        "airfield",

        "poust",
        "beton",
        "asf",
        "sil",

        "dune"
    ];
    private _isHot = false;

    if (isOnRoad _pos) then {
        private _roadType = toLowerAnsi (getRoadInfo (roadAt _pos)#3);
        // if (_roadType != "" && !("dirt" in _roadType)) exitWith {true};
        for "_i" from 0 to (count _heatAccSurf)-1 do {
            if (_isHot) then {break};
            _isHot = (_heatAccSurf #_i) in _roadType;
        };
        if (_isHot) exitWith {true};
    };
    _pos set [2, true];
    private _surface = toLowerAnsi (surfaceType _pos);
    for "_i" from 0 to (count _heatAccSurf)-1 do {
        if (_isHot) then {break};
        _isHot = (_heatAccSurf #_i) in _surface;
    };

    _isHot
};

KTWK_fnc_HZ_updateHeatHaze = { 
    params ["_source", "_player"]; 
     
    private _vehicle = vehicle _player; 
    private _intensity = call KTWK_fnc_HZ_calculateIntensity; 
    private _size = [2, 3, 2.5]; // Wide, very flat size 
     
    private _eyePosATL = ASLToATL (eyePos _vehicle); 
    private _eyeDir = getCameraViewDirection _vehicle; 
    private _hazePosition = _eyePosATL vectorAdd (_eyeDir vectorMultiply KTWK_HZ_distance); 
    _hazePosition set [2, (getPosATL _vehicle)#2]; // Set to ground level 
    _source setPosATL _hazePosition; 
     
    private _particleShape = ["\A3\data_f\ParticleEffects\Universal\Refract.p3d", "\A3\data_f\ParticleEffects\Universal\Smoke.p3d"] select (KTWK_HZ_debug == 2); 
     
    private _color = [[1, 1, 1, 0.06 * _intensity], [1, 1, 1, 0.12 * _intensity], [1, 1, 1, 0.06 * _intensity]]; 
    if (KTWK_HZ_debug == 2) then { 
        _color = _color apply {[1, 0, 0, _x select 3]}; 
    }; 
     
    _source setParticleParams [ 
        [_particleShape, 1, 0, 1], 
        "", "Billboard", 1, 0.5, [0, 0, 0], [0, 0, 0], 0, 10, 7.9, 0.01, 
        _size, _color, [0.08, 0.1, 0.12], 0.1, 0.05, "", "", "", 0, false, 0 
    ]; 
    _source setParticleRandom [0, [0, 0.25, 0], [0, 0, 0], 0, 0.1, [0, 0, 0, 0.06], 0, 0]; 
    _source setDropInterval 0.1; 
};

KTWK_fnc_HZ_debugMessage = {
    params ["_intensity", "_isActive", "_reason"];
    [KTWK_aceWeather && {ace_weather_enabled} && {KTWK_HZ_opt_aceTemp}, KTWK_HZ_opt_useHighest] call KTWK_fnc_getTemp params ["_airTemp", "_surfaceTemp"];
    private _fps = diag_fps;
    
    systemChat format ["Heat Haze: Method: %1, FPS: %2, Air Temp: %3°C, Surface Temp: %4°C, Intensity: %5, Active: %6, Reason: %7", 
        KTWK_HZ_method, _fps toFixed 1, _airTemp toFixed 1, _surfaceTemp toFixed 1, _intensity toFixed 2, _isActive, _reason];
};

KTWK_fnc_HZ_shouldBeActive = {
    params ["_player"];
    if (!KTWK_HZ_opt_enabled) exitWith {["Option Disabled", false]};
    if (rain > 0) exitWith {["Raining", false]};

    if (KTWK_HZ_opt_minFPS > 0 && {diag_fps < KTWK_HZ_opt_minFPS}) exitWith {["Low FPS", false]};
    private _vehicle = vehicle _player;
    private _vehiclePos = getPosASL _vehicle;
    private _isUnderwater = underwater _vehicle || {_vehiclePos select 2 < 0};
    if (_isUnderwater) exitWith {["Underwater", false]};
    private _isTooHigh = (ASLToATL _vehiclePos) select 2 > KTWK_HZ_maxHeight;
    if (_isTooHigh) exitWith {["Too High", false]};

    [KTWK_aceWeather && {ace_weather_enabled} && {KTWK_HZ_opt_aceTemp}, KTWK_HZ_opt_useHighest] call KTWK_fnc_getTemp params ["_airTemp", "_surfaceTemp"];
    if (_surfaceTemp < KTWK_HZ_tempThreshold) exitWith {["Temperature Too Low", false]};
    private _isHotSurface = [ASLToAGL _vehiclePos] call KTWK_fnc_HZ_isHotSurface;
    if (!_isHotSurface) exitWith {["Not on hot surface", false]};
    
    ["Active", true]
};

KTWK_HZ_source = objNull;
KTWK_HZ_lastHotSurfaceCheckTime = 0;
KTWK_HZ_lastDebugTime = 0;

[{
    params ["_args", "_pfhId"];
    _args params ["_hotSurfaceCheckInterval", "_debugInterval"];
    
    private _currentTime = time;
    
    // Check for activation conditions, including hot surface, every _hotSurfaceCheckInterval seconds
    if (_currentTime - KTWK_HZ_lastHotSurfaceCheckTime >= _hotSurfaceCheckInterval) then {
        private _shouldBeActiveResult = [KTWK_player] call KTWK_fnc_HZ_shouldBeActive;
        (_shouldBeActiveResult) params ["_reason", "_isActive"];
        KTWK_HZ_lastHotSurfaceCheckTime = _currentTime;
        
        if (_isActive) then {
            if (isNull KTWK_HZ_source) then {
                private _eyePos = eyePos KTWK_player;
                private _eyeDir = getCameraViewDirection KTWK_player;
                private _hazePosition = _eyePos vectorAdd (_eyeDir vectorMultiply KTWK_HZ_distance);
                private _hazePositionATL = _hazePosition vectorMultiply [1,1,0];
                KTWK_HZ_source = [_hazePositionATL, [20, 30, 20]] call KTWK_fnc_HZ_createHeatHaze;
            };
            
            [KTWK_HZ_source, KTWK_player] call KTWK_fnc_HZ_updateHeatHaze;
            
            if (KTWK_HZ_debug > 0 && _currentTime - KTWK_HZ_lastDebugTime >= _debugInterval) then {
                private _intensity = call KTWK_fnc_HZ_calculateIntensity;
                [_intensity, _isActive, _reason] call KTWK_fnc_HZ_debugMessage;
                KTWK_HZ_lastDebugTime = _currentTime;
            };
        } else {
            if (!isNull KTWK_HZ_source) then {
                deleteVehicle KTWK_HZ_source;
                KTWK_HZ_source = objNull;
            };
            
            if (KTWK_HZ_debug > 0) then {
                private _intensity = call KTWK_fnc_HZ_calculateIntensity;
                [_intensity, _isActive, _reason] call KTWK_fnc_HZ_debugMessage;
            };
        };
    } else {
        // Update haze position if active
        if (!isNull KTWK_HZ_source) then {
            [KTWK_HZ_source, KTWK_player] call KTWK_fnc_HZ_updateHeatHaze;
        };
    };
}, 0.1, [1, 1]] call CBA_fnc_addPerFrameHandler;
