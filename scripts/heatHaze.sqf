/*
    Heat Haze
    by kenoxite
*/

if (!hasInterface) exitWith {};

// Global variables
KTWK_HZ_debug = 0; // 0: Disabled, 1: Debug messages, 2: Debug messages + visible particles
KTWK_HZ_distance = 25;
KTWK_HZ_maxHeight = 10;
KTWK_HZ_forceMaxIntensity = false;
KTWK_HZ_minFPS = 20;
KTWK_HZ_tempThreshold = 25; // Temperature threshold in Celsius for method 0
KTWK_HZ_method = 1; // 0: Original method, 1: New method based on black surface temperature

KTWK_fnc_HZ_createHeatHaze = {
    params ["_position", "_size"];
    private _source = "#particlesource" createVehicleLocal _position;
    private _particleShape = ["\A3\data_f\ParticleEffects\Universal\Refract.p3d", "\A3\data_f\ParticleEffects\Universal\Smoke.p3d"] select (KTWK_HZ_debug == 2);
    _source setParticleParams [
        [_particleShape, 1, 0, 1],
        "", "Billboard", 1, 3, [0, 0, 0], [0, 0, 0.5], 1, 10, 7.9, 0.01,
        _size, [[1, 1, 1, 0.1], [1, 1, 1, 0.2], [1, 1, 1, 0.1]], [0.08, 0.1, 0.12], 0.1, 0.05, "", "", "", 0, false, 0
    ];
    _source setParticleRandom [0.5, [10, 10, 5], [0.2, 0.2, 0.5], 1, 0.1, [0, 0, 0, 0.1], 0, 0];
    _source setDropInterval 0.01;
    _source
};

KTWK_fnc_HZ_calculateIntensity = {
    private _tempData = ambientTemperature;
    private _airTemp = _tempData select 0;
    private _surfaceTemp = _tempData select 1;

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

KTWK_fnc_HZ_updateHeatHaze = {
    params ["_source", "_player"];
    
    private _vehicle = vehicle _player;
    private _intensity = call KTWK_fnc_HZ_calculateIntensity;
    private _verticalSize = [20, 30, 20];
    
    private _eyePos = eyePos _vehicle;
    private _eyeDir = getCameraViewDirection _vehicle;
    private _hazePosition = _eyePos vectorAdd (_eyeDir vectorMultiply KTWK_HZ_distance);
    _hazePosition set [2, getTerrainHeightASL _hazePosition];
    _source setPosATL [_hazePosition select 0, _hazePosition select 1, 0];
    
    private _particleShape = ["\A3\data_f\ParticleEffects\Universal\Refract.p3d", "\A3\data_f\ParticleEffects\Universal\Smoke.p3d"] select (KTWK_HZ_debug == 2);
    
    private _color = [[1, 1, 1, 0.1 * _intensity], [1, 1, 1, 0.2 * _intensity], [1, 1, 1, 0.1 * _intensity]];
    if (KTWK_HZ_debug == 2) then {
        _color = _color apply {[1, 0, 0, _x select 3]};
    };
    
    _source setParticleParams [
        [_particleShape, 1, 0, 1],
        "", "Billboard", 1, 3, [0, 0, 0], [0, 0, 0.5], 1, 10, 7.9, 0.01,
        _verticalSize, _color, [0.08, 0.1, 0.12], 0.1, 0.05, "", "", "", 0, false, 0
    ];
    _source setParticleRandom [0.5, [10, 10, 5], [0.2, 0.2, 0.5], 1, 0.1, [0, 0, 0, 0.1], 0, 0];
    _source setDropInterval 0.01;
};

KTWK_fnc_HZ_debugMessage = {
    params ["_intensity", "_isActive", "_reason"];
    private _tempData = ambientTemperature;
    private _airTemp = _tempData select 0;
    private _surfaceTemp = _tempData select 1;
    private _fps = diag_fps;
    
    systemChat format ["Heat Haze: Method: %1, FPS: %2, Air Temp: %3°C, Surface Temp: %4°C, Intensity: %5, Active: %6, Reason: %7", 
        KTWK_HZ_method, _fps toFixed 1, _airTemp toFixed 1, _surfaceTemp toFixed 1, _intensity toFixed 2, _isActive, _reason];
};

KTWK_fnc_HZ_shouldBeActive = {
    params ["_player"];
    private _vehicle = vehicle _player;
    private _fps = diag_fps;
    private _isUnderwater = underwater _vehicle || {(getPosASL _vehicle) select 2 < 0};
    private _isTooHigh = (getPosATL _vehicle) select 2 > KTWK_HZ_maxHeight;
    private _surfaceTemp = (ambientTemperature select 1);
    
    if (!KTWK_HZ_opt_enabled) exitWith {["Option Disabled", false]};
    if (_fps < KTWK_HZ_minFPS) exitWith {["Low FPS", false]};
    if (_isUnderwater) exitWith {["Underwater", false]};
    if (_isTooHigh) exitWith {["Too High", false]};
    if (_surfaceTemp < KTWK_HZ_tempThreshold) exitWith {["Temperature Too Low", false]};
    
    ["Active", true]
};

KTWK_fnc_HZ_mainLoop = {
    if (!hasInterface) exitWith {};
    
    KTWK_HZ_source = objNull;
    private _updateInterval = 0.1;
    private _debugInterval = 1;
    private _lastDebugTime = 0;
    
    while {true} do {
        private _shouldBeActiveResult = [KTWK_player] call KTWK_fnc_HZ_shouldBeActive;
        private _reason = _shouldBeActiveResult select 0;
        private _isActive = _shouldBeActiveResult select 1;
        
        if (_isActive) then {
            if (isNull KTWK_HZ_source) then {
                private _eyePos = eyePos KTWK_player;
                private _eyeDir = getCameraViewDirection KTWK_player;
                private _hazePosition = _eyePos vectorAdd (_eyeDir vectorMultiply KTWK_HZ_distance);
                private _hazePositionATL = [_hazePosition select 0, _hazePosition select 1, 0];
                KTWK_HZ_source = [_hazePositionATL, [20, 30, 20]] call KTWK_fnc_HZ_createHeatHaze;
            };
            
            [KTWK_HZ_source, KTWK_player] call KTWK_fnc_HZ_updateHeatHaze;
            
            if (KTWK_HZ_debug > 0 && time - _lastDebugTime >= _debugInterval) then {
                private _intensity = call KTWK_fnc_HZ_calculateIntensity;
                [_intensity, _isActive, _reason] call KTWK_fnc_HZ_debugMessage;
                _lastDebugTime = time;
            };
            
            sleep _updateInterval;
        } else {
            if (!isNull KTWK_HZ_source) then {
                deleteVehicle KTWK_HZ_source;
                KTWK_HZ_source = objNull;
            };
            
            if (KTWK_HZ_debug > 0) then {
                private _intensity = call KTWK_fnc_HZ_calculateIntensity;
                [_intensity, _isActive, _reason] call KTWK_fnc_HZ_debugMessage;
            };
            
            sleep 5;
        };
    };
};

[] spawn KTWK_fnc_HZ_mainLoop;
