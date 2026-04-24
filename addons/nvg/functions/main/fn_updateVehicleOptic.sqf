// KTWK_NVG_fnc_updateVehicleOptic
// Updates cached vehicle optic max range for current turret optics mode
//
// Parameters:
//   None
// Returns:
//   Array - [_minRange, _maxRange, _hasNV] or [-1, -1, false] if not in vehicle turret or no NV

private _unit = call KTWK_NVG_fnc_getPlayer;
private _isUAV = unitIsUAV _unit;

private _veh = vehicle _unit;
if (!_isUAV && {_veh == _unit}) exitWith { [-1, -1, false] };

private _turretPath = _veh unitTurret _unit;

private _vehClass = typeOf _veh;
private _knownIndex = -1;
if (_turretPath isNotEqualTo []) then {
    _knownIndex = KTWK_NVG_knownVehicleOptics findIf {_x # 0 == _vehClass && {_x # 1 isEqualTo _turretPath}};
} else {
    if (_isUAV) then {
        _knownIndex = KTWK_NVG_knownVehicleOptics findIf {_x # 0 == _vehClass && {_x # 1 isEqualTo []}};
    };
};

private _minRange = 200;
private _maxRange = 200;
private _hasNV = false;

if (_knownIndex != -1) then {
    private _cachedModes = KTWK_NVG_knownVehicleOpticRanges # _knownIndex;
    private _modeIndex = if (_turretPath isNotEqualTo []) then { getTurretOpticsMode _unit } else { 0 };
    if (_modeIndex >= 0 && {_modeIndex < count _cachedModes}) then {
        _minRange = _cachedModes # _modeIndex # 0;
        _maxRange = _cachedModes # _modeIndex # 1;
        _hasNV = _cachedModes # _modeIndex # 2;
    };
} else {
    private _turretCfg = if (_turretPath isNotEqualTo []) then {
        private _cfg = configFile >> "CfgVehicles" >> _vehClass >> "Turrets";
        if (count _turretPath > 0) then {
            _cfg = _cfg select (_turretPath # 0);
            if (count _turretPath > 1) then {
                _cfg = _cfg >> "Turrets" select (_turretPath # 1);
            };
        };
        _cfg
    } else {
        configFile >> "CfgVehicles" >> _vehClass
    };

    private _opticModes = [];
    private _opticsInCfg = _turretCfg >> "OpticsIn";

    if (isClass _opticsInCfg) then {
        for "_i" from 0 to (count _opticsInCfg - 1) do {
            private _mode = _opticsInCfg select _i;
            if (isClass _mode) then {
                private _visionMode = getArray (_mode >> "visionMode");
                private _modeHasNV = "NVG" in _visionMode || "nvg" in _visionMode;
                if (_modeHasNV) then {
                    _hasNV = true;
                    private _fov = getNumber (_mode >> "maxFov");
                    if (_fov > 0) then {
                        private _range = round (0.75 / _fov * 50);
                        _opticModes pushBack [_range, _range, true];
                    };
                } else {
                    _opticModes pushBack [-1, -1, false];
                };
            };
        };
    } else {
        private _viewOpticsCfg = _turretCfg >> "ViewOptics";
        if (isClass _viewOpticsCfg) then {
            private _visionMode = getArray (_viewOpticsCfg >> "visionMode");
            if ("NVG" in _visionMode || "nvg" in _visionMode) then {
                _hasNV = true;
                private _minFov = getNumber (_viewOpticsCfg >> "minFov");
                private _maxFov = getNumber (_viewOpticsCfg >> "maxFov");
                if (_minFov > 0 && {_maxFov > 0}) then {
                    _minRange = round (0.75 / _maxFov * 50);
                    _maxRange = round (0.75 / _minFov * 50);
                    _opticModes pushBack [_minRange, _maxRange, true];
                };
            };
        };
    };

    if (_opticModes isNotEqualTo []) then {
        private _cachePath = if (_turretPath isNotEqualTo []) then { _turretPath } else { [] };
        KTWK_NVG_knownVehicleOptics pushBack [_vehClass, _cachePath];
        KTWK_NVG_knownVehicleOpticRanges pushBack _opticModes;
        private _modeIndex = if (_turretPath isNotEqualTo []) then { getTurretOpticsMode _unit } else { 0 };
        if (_modeIndex >= 0 && {_modeIndex < count _opticModes}) then {
            _minRange = _opticModes # _modeIndex # 0;
            _maxRange = _opticModes # _modeIndex # 1;
            _hasNV = _opticModes # _modeIndex # 2;
        };
    };
};

KTWK_NVG_vehicleOpticZoomMin = _minRange;
KTWK_NVG_vehicleOpticZoomMax = _maxRange;
KTWK_NVG_vehicleOpticHasNV = _hasNV;

[_minRange, _maxRange, _hasNV]
