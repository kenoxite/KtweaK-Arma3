/*
    Cold Breath
    by kenoxite & Perplexity AI (https://www.perplexity.ai)
*/

// Check for ACE modules
private _hasACEWeather = isClass (configFile >> "CfgPatches" >> "ace_weather");
private _hasACEFatigue = isClass (configFile >> "CfgPatches" >> "ace_advanced_fatigue");

// Initialize ACE variables if not present
if (!_hasACEWeather) then {
    ace_weather_enabled = false;
    ace_weather_currentTemperature = 0;
};
if (!_hasACEFatigue) then {
    ace_advanced_fatigue_enabled = false;
    ace_advanced_fatigue_anReserve = 100;
};

// State variables
private _lastCombatCheck = 0;
private _lastNearUnitsCheck = 0;
private _lastVehicleUnderwaterCheck = 0;
private _nearUnits = [];
private _inVehicle = false;
private _isUnderwater = false;

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
        "bandana"
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

// Check if unit is in player's FOV
KTWK_fnc_isInFOV = {
    params ["_unit"];
    private _unitPos = getPosWorld (vehicle _unit);
    private _vehPlayer = vehicle KTWK_player;
    private _playerPos = getPosWorld _vehPlayer;
    private _allTurrets = allTurrets [_vehPlayer, false];
    private _camDir = -1;
    if (count _allTurrets == 0 || {_vehPlayer turretUnit [0] != KTWK_player}) then {
        _camDir = [0,0,0] getdir getCameraViewDirection _vehPlayer;
    } else {
        private _weaponDir = _vehPlayer weaponDirection (currentWeapon _vehPlayer);
        private _turretDir = (_weaponDir select 0) atan2 (_weaponDir select 1);
        _camDir = [
                        _turretDir,
                        360 + _turretDir
                    ] select (_turretDir < 0);
    };

    [_playerPos, _camDir, ceil((call CBA_fnc_getFov select 0)*100), _unitPos] call BIS_fnc_inAngleSector
};

// Update nearby units
KTWK_fnc_CB_nearUnits = {
    params ["_detectionDistance"];
    private _refPos = positionCameraToWorld [0,0,0];
    private _firstPerson = (positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) < 2;
    KTWK_allInfantry select {
        (_x == KTWK_player ||
        {_x distance _refPos <= _detectionDistance && {!_firstPerson || (_firstPerson && {[_x] call KTWK_fnc_isInFOV})}}) &&
        {alive _x} && 
        {!(underwater _x)} && 
        {!([_x] call KTWK_fnc_inBuilding)} && 
        {!([_x] call KTWK_fnc_CB_gearCoversMouth)}
    };
};

// Get global temperature
KTWK_fnc_CB_getTemp = {
    params [["_useAce", false]];
    
    // Check if KTWK_customTemp is defined
    if (!isNil "KTWK_customTemp") exitWith {
        KTWK_customTemp
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
    params ["_unit", "_adjustedBreathInt", "_adjustedBreathIntensity", "_adjustedBreathSize", "_scaleFactor", "_isDistant", "_distanceToCamera", "_tempMod"];

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

    private _breath = "#particlesource" createVehicleLocal _particlePos;

    private _particleLifeTime = [2, 3.0] select _isDistant;
    _particleLifeTime = _particleLifeTime * _tempMod;
    private _baseParticleSize = [
        [0.05 * _adjustedBreathSize * _scaleFactor, 0.12 * _adjustedBreathSize * _scaleFactor],
        [0.08, 0.16]
    ] select _isDistant;
    
    // Introduce randomness to particle size
    private _sizeVariation = 0.3; // 30% variation
    private _minSize = _baseParticleSize#0 * (1 - _sizeVariation);
    private _maxSize = _baseParticleSize#1 * (1 + _sizeVariation);
    private _randomizedSize = [_minSize + random(_maxSize - _minSize), _maxSize];

    private _opacity = if (_fp) then {
        0.02
    } else {
        if (_isDistant) then {
            0.04
        } else {
            0.015
        }
    };
    _opacity = _opacity * _tempMod;

    private _pfhHandle = [
        {
            params ["_args", "_pfhHandle"];
            _args params ["_unit", "_breath", "_fp", "_isDistant", "_particleLifeTime", "_randomizedSize", "_opacity", "_scaleFactor", "_eyeDir"];

            if (!alive _unit || isNull _breath) exitWith {
                [_pfhHandle] call CBA_fnc_removePerFrameHandler;
                if (!isNull _breath) then { deleteVehicle _breath; };
            };

            private _headPos = _unit modelToWorld (_unit selectionPosition "head");
            private _mouthOffsetAdjust = [0.03, 0.08] select _fp;
            private _mouthOffset = _eyeDir vectorMultiply _mouthOffsetAdjust;
            private _particlePos = _headPos vectorAdd _mouthOffset;

            if (_fp) then {
                private _stance = stance KTWK_player;
                call {
                    if (_fp) exitWith {
                        private _stance = stance KTWK_player;
                        if (_stance == "PRONE") exitWith { _particlePos = _particlePos vectorAdd [0, 0.1, -0.1]; };
                        if (_stance == "CROUCH") exitWith { _particlePos = _particlePos vectorAdd [0, 0.1, -0.05]; };
                        _particlePos = _particlePos vectorAdd [0, 0.1, 0];
                    };
                    _particlePos = _particlePos vectorAdd [0, 0, 0.03];
                };
            } else {
                _particlePos = _particlePos vectorAdd [0, 0, 0.03];
            };

            if (KTWK_player distance _unit > 100) then {
                _particlePos = _particlePos vectorAdd [0, 0, -0.08];
            };

            _breath setPosATL _particlePos;
            _breath setParticleParams [
                ["\A3\data_f\cl_basic", 1, 0, 1],  // Shape: Particle texture, type, animation speed, scale
                "",                                // Animation name (empty string for no animation)
                "Billboard",                       // Type of particle (Billboard, SpaceObject, etc.)
                1,                                 // Timer period (in seconds)
                _particleLifeTime,                 // Lifetime of particle (in seconds)
                [0, 0, 0],                         // Position offset from particle source
                (_eyeDir vectorMultiply 0.12) vectorAdd [0,0,-0.005],  // Movement vector
                0.7,                               // Rotation velocity
                0.25,                            // Weight (affects how particle falls)
                0.2,                              // Volume (affects air resistance)
                0.05,                            // Rubbing (affects how particle slows down)
                _randomizedSize,                   // Size of particle [min, max]
                [[1, 1, 1, 0],                     // Color of particle over time (RGBA)
                 [1, 1, 1, _opacity * _scaleFactor * 0.5],
                 [1, 1, 1, _opacity * _scaleFactor],
                 [1, 1, 1, _opacity * _scaleFactor * 0.5],
                 [1, 1, 1, 0]],
                [0, 0.2, 0.4, 0.6, 1],             // Time points for color changes
                0.1,                               // Randomness of particle direction
                0.05,                              // Random rotation of particle
                "",                                // On-timer function (empty string for none)
                "",                                // Before-destroy function (empty string for none)
                _breath                            // Object the particle is created relative to
            ];

        },
        0.1, // Run every 0.1 seconds
        [_unit, _breath, _fp, _isDistant, _particleLifeTime, _randomizedSize, _opacity, _scaleFactor, _eyeDir]
    ] call CBA_fnc_addPerFrameHandler;

    _breath setParticleRandom [
        0.01,           // Lifetime
        [0.005, 0.005, 0.005], // Position
        [0.01, 0.01, 0.01],    // Velocity
        0,              // Rotation velocity
        0.005,          // Size
        [0, 0, 0, 0.005], // Color
        0,              // Random direction period
        0               // Random direction intensity
    ];

    private _dropInterval = if (_unit == KTWK_player && cameraView == "INTERNAL") then {
        0.006 / (_adjustedBreathInt * _adjustedBreathIntensity * _scaleFactor)
    } else {
        if (_isDistant) then {
            0.012 / _adjustedBreathInt
        } else {
            0.008 / (_adjustedBreathInt * _adjustedBreathIntensity * _scaleFactor)
        }
    };
    _breath setDropInterval _dropInterval;

    [_pfhHandle, _breath]
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

// Function to check and update combat status
KTWK_fnc_inCombat = {
    params ["_unit", "_group", ["_outOfCombatTime", 30]];
    if (diag_tickTime - _lastCombatCheck > 60 && {_unit isEqualTo (leader _group)}) then {
        private _nearEnemy = _unit findNearestEnemy _unit;
        if (!isNull _nearEnemy && {_unit distance _nearEnemy < 100}) then {
            _group setVariable ["KTWK_inCombat", true, false];
            _group setVariable ["KTWK_lastCombatTime", diag_tickTime, false];
        } else {
            if (diag_tickTime - (_group getVariable ["KTWK_lastCombatTime", 0]) > _outOfCombatTime) then {
                _group setVariable ["KTWK_inCombat", false, false];
            };
        };
        _lastCombatCheck = diag_tickTime;
    };
};

// Function to calculate breath parameters
KTWK_fnc_CB_calculateBreathParams = {
    params ["_unit", "_group", "_isExerted"];
    private _timeSinceExertion = diag_tickTime - (_unit getVariable ["KTWK_lastExertionTime", 0]);
    private _recoveryTime = 120;
    private _normalBreathRate = 3;
    private _inCombat = _group getVariable ["KTWK_inCombat", false];

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

// Function to process a single unit
KTWK_fnc_CB_processUnit = {
    params ["_unit", "_detectionDistance", "_baseTemp"];
    private _group = group _unit;

    [_unit, _group] call KTWK_fnc_inCombat;

    private _temp = [_unit, _baseTemp] call KTWK_fnc_CB_getTempUnit;
    if (_temp < 5 && {_unit getVariable ["KTWK_lastBreathTime", -1] < diag_tickTime}) then {
        private _isExerted = if (_hasACEFatigue && {ace_advanced_fatigue_enabled}) then {
            ace_advanced_fatigue_anReserve < 80
        } else {
            (getFatigue _unit > 0.6) || (speed _unit > 12)
        };
        if (_isExerted) then {
            _unit setVariable ["KTWK_lastExertionTime", diag_tickTime, false];
        };

        [_unit, _group, _isExerted] call KTWK_fnc_CB_calculateBreathParams params ["_breathInt", "_breathIntensity", "_breathSize"];

        [_unit, _breathInt, _breathIntensity, _breathSize] call KTWK_fnc_CB_adjustBreathForIncapacitated params ["_adjustedBreathInt", "_adjustedBreathIntensity", "_adjustedBreathSize"];

        private _persistentOffset = _unit getVariable ["KTWK_breathOffset", random _adjustedBreathInt];
        _unit setVariable ["KTWK_breathOffset", _persistentOffset];

        private _nextBreathTime = diag_tickTime + _adjustedBreathInt + _persistentOffset;
        _unit setVariable ["KTWK_lastBreathTime", _nextBreathTime, false];

        private _distanceToCamera = ((positionCameraToWorld [0,0,0]) distance _unit) max 50;
        private _scaleFactor = linearConversion [50, _detectionDistance, _distanceToCamera, 1, 0.3, true];
        private _isDistant = _scaleFactor < 0.3;

        private _tempMod = linearConversion [5, -10, _temp, 0.1, 1, true];

        // Create and manage breath effect
        private _breathEffect = [_unit, _adjustedBreathInt, _adjustedBreathIntensity, _adjustedBreathSize, _scaleFactor, _isDistant, _distanceToCamera, _tempMod] call KTWK_fnc_CB_createColdBreathEffect;
        _breathEffect params ["_pfhHandle", "_breath"];

        [{
            params ["_pfhHandle", "_breath"];
            [_pfhHandle] call CBA_fnc_removePerFrameHandler;
            if (!isNull _breath) then { deleteVehicle _breath; };
        }, [_pfhHandle, _breath], 0.25 + random 0.15] call CBA_fnc_waitAndExecute;
    };
};
// Initial near units check
private _initialDetectionDistance = 50;
KTWK_nearUnits = [_initialDetectionDistance] call KTWK_fnc_CB_nearUnits;

KTWK_previousNearUnits = [];
KTWK_lastNearUnitsCheck = diag_tickTime;

// Main loop for cold breath effect
[{
    params ["_args", "_pfhId"];
    _args params ["_hasACEWeather"];

    if (KTWK_CB_opt_enabled) then {
        private _playerVeh = vehicle KTWK_player;
        private _playerSpeed = speed _playerVeh;
        private _detectionDistance = call {
            if ((positionCameraToWorld [0,0,0] distance (vehicle KTWK_player)) > 2) exitWith { 100 };
            if (cameraView isEqualTo "GUNNER") exitWith { 600 };
            100
        };
        private _baseTemp = [_hasACEWeather && {ace_weather_enabled} && {KTWK_CB_opt_aceTemp}] call KTWK_fnc_CB_getTemp;

        // Update nearby units periodically
        if (diag_tickTime - KTWK_lastNearUnitsCheck > 10) then {
            KTWK_nearUnits = [_detectionDistance] call KTWK_fnc_CB_nearUnits;
            KTWK_lastNearUnitsCheck = diag_tickTime;
            
            {
                private _unit = _x;
                if !(_unit in KTWK_nearUnits) then {
                    {
                        _unit setVariable [_x, nil];
                    } forEach ["KTWK_breathOffset", "KTWK_lastBreathTime", "KTWK_lastExertionTime"];
                };
            } forEach KTWK_previousNearUnits;

            KTWK_previousNearUnits = +KTWK_nearUnits;
        };

        // Process cold breath effect if player speed is below threshold
        if (_playerSpeed < 50) then {
            {
                [_x, _detectionDistance, _baseTemp] call KTWK_fnc_CB_processUnit;
            } forEach KTWK_nearUnits;
        };
    };
}, 0.1, [_hasACEWeather]] call CBA_fnc_addPerFrameHandler;
