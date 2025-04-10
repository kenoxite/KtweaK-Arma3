/*
    Cold Breath
    by kenoxite
*/

// Initialize ACE variables if not present
if (!KTWK_aceWeather) then {
    ace_weather_enabled = false;
    ace_weather_currentTemperature = 0;
};
if (!KTWK_aceFatigue) then {
    ace_advanced_fatigue_enabled = false;
    ace_advanced_fatigue_anReserve = 100;
};

// State variables
KTWK_CB_lastNearUnitsCheck = 0;
KTWK_CB_previousNearUnits = [];

// Check if gear covers mouth
KTWK_fnc_CB_gearCoversMouth = {
    params ["_unit"];
    private _headgear = headgear _unit;
    private _facewear = goggles _unit;
    private _lastCheckedGear = _unit getVariable ["KTWK_lastCheckedGear", ["", ""]];
    
    if (_headgear isEqualTo (_lastCheckedGear#0) && _facewear isEqualTo (_lastCheckedGear#1)) exitWith {
        _unit getVariable ["KTWK_gearCoversMouth", false]
    };
    
    _unit setVariable ["KTWK_lastCheckedGear", [_headgear, _facewear], false];
    private _headgearCovers = ["pilot", "crew", "shemag"];
    private _facewearCovers = [
        "balaclava",
        "mask",
        "respirator",
        // "shemag",
        "bandana",
        "facewrap"
        ];
    
    private _keywordCheck = {
        params ["_item", "_cfgRoot", "_coveringItems"];
        if (_item isEqualTo "") exitWith {false};
        private _itemName = toLower (getText (configFile >> _cfgRoot >> _item >> "displayName"));
        (_coveringItems findIf {_itemName find _x != -1}) != -1
    };
    
    private _result = ([_headgear, "CfgWeapons", _headgearCovers] call _keywordCheck) || 
                      ([_facewear, "CfgGlasses", _facewearCovers] call _keywordCheck);
    _unit setVariable ["KTWK_gearCoversMouth", _result, false];
    _result
};

// Update nearby units
KTWK_fnc_CB_nearUnits = {
    params ["_detectionDistance"];
    private _refPos = positionCameraToWorld [0,0,0];
    private _firstPerson = (positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) < 2;
    KTWK_allInfantry select {
        (_x == KTWK_player ||
        {_x distance _refPos <= _detectionDistance && {!_firstPerson || (_firstPerson && {[_x, KTWK_player] call KTWK_fnc_inFOV})}}) &&
        {alive _x} && 
        {!(underwater _x)} && 
        {!([_x] call KTWK_fnc_inBuilding)} && 
        {!([_x] call KTWK_fnc_CB_gearCoversMouth)}
    };
};

// Get global temperature
KTWK_fnc_CB_getTemp = {
    params [["_useAce", false]];
    
    // Check if KTWK_CB_customTemp is defined
    if (!isNil "KTWK_CB_customTemp") exitWith {
        KTWK_CB_customTemp
    };
    [ambientTemperature#0, ace_weather_currentTemperature] select _useAce
};

// Get temperature for a unit
KTWK_fnc_CB_getTempUnit = {
    params ["_unit", "_baseTemp"];

    private _pos = getPosASL _unit;
    private _alt = _pos#2;
    private _altitudeAdjustment = (_alt / 1000) * -6.5;
    private _adjustedTemp = _baseTemp + _altitudeAdjustment;
    round(_adjustedTemp * 10) / 10
};

// Create cold breath effect
KTWK_fnc_CB_createColdBreathEffect = {
    params ["_unit", "_adjustedBreathInt", "_adjustedBreathIntensity", "_adjustedBreathSize", "_scaleFactor", "_isDistant", "_distanceToCamera", "_effectIntensity"];

    private _particlePos = [_unit, _distanceToCamera] call KTWK_fnc_CB_calculateParticlePosition;
    private _breath = createVehicleLocal ["#particlesource", _particlePos, [], 0, "can_collide"];

    private _randomizedSize = [_adjustedBreathSize, _scaleFactor, _isDistant] call KTWK_fnc_CB_calculateParticleSize;
    private _opacity = [_unit, _isDistant, _effectIntensity] call KTWK_fnc_CB_calculateOpacity;
    private _particleLifeTime = [_isDistant, _effectIntensity] call KTWK_fnc_CB_calculateParticleLifetime;

    private _pfhHandle = [_unit, _breath, _randomizedSize, _opacity, _scaleFactor, _particleLifeTime] call KTWK_fnc_CB_setupPerFrameHandler;

    [_breath] call KTWK_fnc_CB_setParticleRandomParams;

    private _dropInterval = [_unit, _adjustedBreathInt, _adjustedBreathIntensity, _scaleFactor, _isDistant] call KTWK_fnc_CB_calculateDropInterval;
    _breath setDropInterval _dropInterval;

    [_pfhHandle, _breath]
};

// Position calculation function
KTWK_fnc_CB_calculateParticlePosition = {
    params ["_unit", "_distanceToCamera"];

    private _headPos = _unit modelToWorld (_unit selectionPosition "head");
    private _eyeDir = eyeDirection _unit;
    private _fp = _unit == KTWK_player && {(positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) < 2};
    private _mouthOffsetAdjust = [0.03, 0.08] select _fp;
    private _mouthOffset = _eyeDir vectorMultiply _mouthOffsetAdjust;
    private _particlePos = _headPos vectorAdd _mouthOffset;

    call {
        if (_fp) exitWith {
            private _stance = stance KTWK_player;
            if (_stance == "PRONE") exitWith { _particlePos = _particlePos vectorAdd [0, 0.1, -0.1]; };
            if (_stance == "CROUCH") exitWith { _particlePos = _particlePos vectorAdd [0, 0.1, -0.05]; };
            _particlePos = _particlePos vectorAdd [0, 0.2, 0];
        };
        _particlePos = _particlePos vectorAdd [0, 0, 0.03];
    };

    if (_distanceToCamera > 100) then {
        _particlePos = _particlePos vectorAdd [0, 0, -0.08];
    };

    _particlePos
};

// Particle size calculation function
KTWK_fnc_CB_calculateParticleSize = {
    params ["_adjustedBreathSize", "_scaleFactor", "_isDistant"];

    private _baseParticleSize = [
        [0.05 * _adjustedBreathSize * _scaleFactor, 0.12 * _adjustedBreathSize * _scaleFactor],
        [0.08, 0.16]
    ] select _isDistant;
    
    private _sizeVariation = 0.3;
    private _minSize = _baseParticleSize#0 * (1 - _sizeVariation);
    private _maxSize = _baseParticleSize#1 * (1 + _sizeVariation);
    [_minSize + random(_maxSize - _minSize), _maxSize]
};

// Opacity calculation function
KTWK_fnc_CB_calculateOpacity = {
    params ["_unit", "_isDistant", "_effectIntensity"];

    private _opacity = if (_unit == KTWK_player && {(positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) < 2}) then {
        0.008
    } else {
        if (_isDistant) then { 0.01 } else { 0.008 }
    };
    _opacity * _effectIntensity
};

// Particle lifetime calculation function
KTWK_fnc_CB_calculateParticleLifetime = {
    params ["_isDistant", "_effectIntensity"];
    ([2, 3] select _isDistant) * _effectIntensity
};

// Per-frame update function
KTWK_fnc_CB_setupPerFrameHandler = {
    params ["_unit", "_breath", "_randomizedSize", "_opacity", "_scaleFactor", "_particleLifeTime"];

    [
        {
            params ["_args", "_pfhHandle"];
            _args params ["_unit", "_breath", "_randomizedSize", "_opacity", "_scaleFactor", "_particleLifeTime"];

            if (!alive _unit || isNull _breath) exitWith {
                [_pfhHandle] call CBA_fnc_removePerFrameHandler;
                if (!isNull _breath) then { deleteVehicle _breath; };
            };

            private _particlePos = [_unit, KTWK_player distance _unit] call KTWK_fnc_CB_calculateParticlePosition;
            _breath setPosATL _particlePos;

            private _eyeDir = eyeDirection _unit;
            _breath setParticleParams [
                ["\A3\data_f\cl_basic", 1, 0, 1],
                "",
                "Billboard",
                1,
                _particleLifeTime,
                [0, 0, 0],
                (_eyeDir vectorMultiply 0.12) vectorAdd [0,0,-0.005],
                0.7,
                0.25,
                0.2,
                0.05,
                _randomizedSize,
                [[1, 1, 1, 0],
                 [1, 1, 1, _opacity * _scaleFactor * 0.5],
                 [1, 1, 1, _opacity * _scaleFactor],
                 [1, 1, 1, _opacity * _scaleFactor * 0.5],
                 [1, 1, 1, 0]],
                [0, 0.2, 0.4, 0.6, 1],
                0.1,
                0.05,
                "",
                "",
                _breath
            ];
        },
        0.1,
        [_unit, _breath, _randomizedSize, _opacity, _scaleFactor, _particleLifeTime]
    ] call CBA_fnc_addPerFrameHandler
};

// Particle random parameters function
KTWK_fnc_CB_setParticleRandomParams = {
    params ["_breath"];

    _breath setParticleRandom [
        0.01,
        [0.005, 0.005, 0.005],
        [0.01, 0.01, 0.01],
        0,
        0.005,
        [0, 0, 0, 0.005],
        0,
        0
    ];
};

// Drop interval calculation function
KTWK_fnc_CB_calculateDropInterval = {
    params ["_unit", "_adjustedBreathInt", "_adjustedBreathIntensity", "_scaleFactor", "_isDistant"];

    if (_unit == KTWK_player && cameraView == "INTERNAL") then {
        0.006 / (_adjustedBreathInt * _adjustedBreathIntensity * _scaleFactor)
    } else {
        if (_isDistant) then {
            0.012 / _adjustedBreathInt
        } else {
            0.008 / (_adjustedBreathInt * _adjustedBreathIntensity * _scaleFactor)
        }
    }
};

// Adjust breath parameters for incapacitated units
KTWK_fnc_CB_adjustBreathForIncapacitated = {
    params ["_unit", "_breathInt", "_breathIntensity", "_breathSize"];
    if (lifeState _unit != "HEALTHY" || {_unit getVariable ["ACE_isUnconscious", false]}) then {
        _breathInt = 2 + (random 3);
        _breathIntensity = 0.1 + (random 0.2);
        _breathSize = 0.4 + (random 0.5);
    };
    
    [_breathInt, _breathIntensity, _breathSize]
};

// Function to calculate breath parameters
KTWK_fnc_CB_calculateBreathParams = {
    params ["_unit", "_group", "_isExerted", "_inCombat"];
    private _timeSinceExertion = time - (_unit getVariable ["KTWK_lastExertionTime", 0]);
    private _recoveryTime = 120;
    private _normalBreathRate = 3;

    private _breathInt = 0;
    private _breathIntensity = 0;
    private _breathSize = 0;

    switch true do {
        case _inCombat: {
            _breathInt = 0.5 + (random 0.5);
            _breathIntensity = 0.8 + (random 0.2);
            _breathSize = 0.5 + (random 0.3);
        };
        case _isExerted: {
            _breathInt = 0.7 + (random 0.6);
            _breathIntensity = 0.6 + (random 0.2);
            _breathSize = 0.7 + (random 0.3);
        };
        default {
            private _recoveryFactor = (_timeSinceExertion min _recoveryTime) / _recoveryTime;
            _breathInt = _normalBreathRate - ((_normalBreathRate - 0.7) * (1 - _recoveryFactor));
            _breathIntensity = 0.3 + (random 0.2);
            _breathSize = 1 + (random 0.5);
        };
    };

    [_breathInt, _breathIntensity, _breathSize]
};

// Calculate effect intensity based on atmospheric factors
KTWK_fnc_CB_effectIntensity = {
    params ["_temp"];
    
    private _humidityFactor = linearConversion [0.7, 0.9, humidity, 0, 1, true];
    private _effectIntensity = call {
        if (_temp < 0) exitWith {linearConversion [0, -10, _temp, 0.7, 1, true]};
        if (_temp > 10) exitWith {_humidityFactor * 0.3};
        private _tempFactor = linearConversion [10, 0, _temp, 0, 1, true];
        _tempFactor + (_humidityFactor * (1 - _tempFactor))
    };
    
    (_effectIntensity * (1 - (rain * ([0, 0.2] select (!(rainParams params ["_snow"])))))) max 0 min 1
};

// Function to process a single unit
KTWK_fnc_CB_processUnit = {
    params ["_unit", "_detectionDistance", "_baseTemp"];
    private _group = group _unit;

    private _inCombat = [_unit, _group] call KTWK_fnc_inCombat;

    private _temp = [_unit, _baseTemp] call KTWK_fnc_CB_getTempUnit;
    private _effectIntensity = [_temp] call KTWK_fnc_CB_effectIntensity;
    if (_effectIntensity > 0.1 && {_unit getVariable ["KTWK_lastBreathTime", -1] < time}) then {
        private _isExerted = if (KTWK_aceFatigue && {ace_advanced_fatigue_enabled}) then {
            ace_advanced_fatigue_anReserve < 80
        } else {
            (getFatigue _unit > 0.6) || (speed _unit > 12)
        };
        if (_isExerted) then {
            _unit setVariable ["KTWK_lastExertionTime", time, false];
        };

        [_unit, _group, _isExerted, _inCombat] call KTWK_fnc_CB_calculateBreathParams params ["_breathInt", "_breathIntensity", "_breathSize"];

        [_unit, _breathInt, _breathIntensity, _breathSize] call KTWK_fnc_CB_adjustBreathForIncapacitated params ["_adjustedBreathInt", "_adjustedBreathIntensity", "_adjustedBreathSize"];

        private _persistentOffset = _unit getVariable ["KTWK_breathOffset", random _adjustedBreathInt];
        _unit setVariable ["KTWK_breathOffset", _persistentOffset];

        private _nextBreathTime = time + _adjustedBreathInt + _persistentOffset;
        _unit setVariable ["KTWK_lastBreathTime", _nextBreathTime, false];

        private _distanceToCamera = ((positionCameraToWorld [0,0,0]) distance _unit) max 50;
        private _scaleFactor = linearConversion [50, _detectionDistance, _distanceToCamera, 1, 0.3, true];
        private _isDistant = _scaleFactor < 0.3;

        // Create and manage breath effect
        private _breathEffect = [_unit, _adjustedBreathInt, _adjustedBreathIntensity, _adjustedBreathSize, _scaleFactor, _isDistant, _distanceToCamera, _effectIntensity] call KTWK_fnc_CB_createColdBreathEffect;
        _breathEffect params ["_pfhHandle", "_breath"];

        [{
            params ["_pfhHandle", "_breath"];
            [_pfhHandle] call CBA_fnc_removePerFrameHandler;
            if (!isNull _breath) then { deleteVehicle _breath; };
        }, [_pfhHandle, _breath], 0.25 + random 0.15] call CBA_fnc_waitAndExecute;
    };
};

// Initial near units check
KTWK_CB_nearUnits = [50] call KTWK_fnc_CB_nearUnits;

// Main loop for cold breath effect
[{
    params ["_args", "_pfhId"];

    if (KTWK_CB_opt_enabled) then {
        private _baseTemp = ([KTWK_CB_opt_aceTemp && {KTWK_aceWeather && ace_weather_enabled}] call KTWK_fnc_getTemp) #0;
        if (_baseTemp <= 20) then {
            private _vehPlayer = vehicle KTWK_player;
            private _inCamera = (positionCameraToWorld [0,0,0] distance _vehPlayer) > 2;
            private _detectionDistance = call {
                if (_inCamera) exitWith { 100 };
                if (cameraView isEqualTo "GUNNER") exitWith { 600 };
                100
            };

            // Update nearby units periodically
            if (time - KTWK_CB_lastNearUnitsCheck > 10) then {
                KTWK_CB_nearUnits = [_detectionDistance] call KTWK_fnc_CB_nearUnits;
                KTWK_CB_lastNearUnitsCheck = time;
                
                {
                    private _unit = _x;
                    if !(_unit in KTWK_CB_nearUnits) then {
                        {
                            _unit setVariable [_x, nil];
                        } forEach ["KTWK_breathOffset", "KTWK_lastBreathTime", "KTWK_lastExertionTime"];
                    };
                } forEach KTWK_CB_previousNearUnits;

                KTWK_CB_previousNearUnits = +KTWK_CB_nearUnits;
            };

            // Process cold breath effect if player speed is below threshold
            if (_inCamera || {(speed _vehPlayer) < 50}) then {
                {
                    [_x, _detectionDistance, _baseTemp] call KTWK_fnc_CB_processUnit;
                } forEach KTWK_CB_nearUnits;
            };
        };
    };
}, 0.1, []] call CBA_fnc_addPerFrameHandler;
