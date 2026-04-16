// KTWK_NVG_fnc_detectGeneration
// Returns intensity multiplier and color preset based on NVG class
//
// Parameters:
//   _nvgClass - NVG class name to check (default: "")
// Returns:
//   Array - [_intensity, _colorIndex, _brightness, _noise, _chromAberration]

params [["_nvgClass", ""]];

if (_nvgClass == "") exitWith { [1.0, 0, 1.0, 0.5, 0.003] };

private _intensity = [
    1.0,  // No gen
    1.8,  // Gen 1
    1.4,  // Gen 2
    1.2,  // Gen 3
    0.7   // Gen 4
];

private _brightness = [
    1.0,  // No gen
    0.7,  // Gen 1
    0.8,  // Gen 2
    1.0,  // Gen 3
    1.0   // Gen 4
];

private _noise = [
    0.5,  // No gen
    0.9,  // Gen 1
    0.6,  // Gen 2
    0.3,  // Gen 3
    0.1   // Gen 4
];

private _chromAberration = [
    0.003,  // No gen
    0.015,  // Gen 1
    0.008,  // Gen 2
    0.003,  // Gen 3
    0.001    // Gen 4
];

private _nvgClassLower = toLowerANSI _nvgClass;

// Determine color from arrays
private _color = 1;  // Default Green
if (_nvgClassLower in KTWK_NVG_wp) then { _color = 2 };
if (_nvgClassLower in KTWK_NVG_amber) then { _color = 3 };
if (_nvgClassLower in KTWK_NVG_bw) then { _color = 4 };
if (_nvgClassLower in KTWK_NVG_crimson) then { _color = 5 };

// Check global generation arrays
if (_nvgClassLower in KTWK_NVG_gen1) exitWith { [_intensity # 1, _color, _brightness # 1, _noise # 1, _chromAberration # 1] };
if (_nvgClassLower in KTWK_NVG_gen2) exitWith { [_intensity # 2, _color, _brightness # 2, _noise # 2, _chromAberration # 2] };
if (_nvgClassLower in KTWK_NVG_gen3) exitWith { [_intensity # 3, _color, _brightness # 3, _noise # 3, _chromAberration # 3] };
if (_nvgClassLower in KTWK_NVG_gen4) exitWith { [_intensity # 4, _color, _brightness # 4, _noise # 4, _chromAberration # 4] };

// Check for ace_nightvision_generation config value
private _cfgWeapons = configFile >> "CfgWeapons";
private _aceGenConfig = getNumber (_cfgWeapons >> _nvgClass >> "ace_nightvision_generation");
if (_aceGenConfig > 0) then {
    private _gen = _aceGenConfig;
    private _isWP = if (_nvgClassLower find "_wp" != -1) then {
        2
    } else {
        private _wpConfig = getNumber (_cfgWeapons >> _nvgClass >> "ace_nightvision_whitePhosphor");
        [1, 2] select (_wpConfig == 1)
    };
    [_intensity # _gen, _isWP, _brightness # _gen, _noise # _gen, _chromAberration # _gen]
} else {
    [1.0, 0, 1.0, 0.5, 0.003]
};
