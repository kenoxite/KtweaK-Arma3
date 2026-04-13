// Returns an array with [airTemp, surfaceTemp] from vanilla or ace

params [["_useAce", false], ["_useHighest", false]];

// Check if KTWK_customTemp is defined
if (!isNil "KTWK_customTemp") exitWith {
    [KTWK_customTemp, KTWK_customTemp + (random [3,4,5])]
};

private _vanillaTemp = ambientTemperature;
call {
    if (_useAce) exitWith {
        if (_useHighest && {(_vanillaTemp #0) > ace_weather_currentTemperature}) exitWith { _vanillaTemp };
        [ace_weather_currentTemperature, [KTWK_aceSurfaceTemp, ace_weather_currentTemperature + (random [3,4,5])] select (isNil {KTWK_aceSurfaceTemp})];
    };
    _vanillaTemp
};
