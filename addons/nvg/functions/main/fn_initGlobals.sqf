// KTWK_NVG_fnc_initGlobals
// Initializes all global variables for the NVG subsystem
//
// Parameters:
//   None
// Returns:
//   Nothing

// Mod detection
private _cfgPatches = configFile >> "CfgPatches";
KTWK_NVG_ktweak = isClass (_cfgPatches >> "ktweak");
if (isNil "KTWK_aceNightvision") then {
    KTWK_aceNightvision = isClass (_cfgPatches >> "ace_nightvision");
};
_cfgPatches = nil;

// Player reference
if (!KTWK_NVG_ktweak) then {
    KTWK_player = call CBA_fnc_currentUnit;
};

// Mode detection state
KTWK_NVG_weaponZoom = 0;
KTWK_NVG_vehicleMFD = false;
KTWK_NVG_isHmd = true;
KTWK_NVG_isHmdADS = true;
KTWK_NVG_isHmdADSNoScope = true;
KTWK_NVG_zoom = 0.93;
KTWK_NVG_outOfRange = false;

// IR Light
KTWK_NVG_irLightToggle = false;
KTWK_NVG_irLightManager = [];

// Internal constants
KTWK_NVG_lightThreshold = 3;
KTWK_NVG_posInterval = 0.35;

// Cache array: [_active, _modeCached, _lightCached, _zoomCached, _lastSample, _handlesCreated, _rangeFactorCached, _testPosCached, _itemClassCached, _genIndexCached, _colorPresetCached, _maxRangeCached, _minZoomOffsetCached]
KTWK_NVG_cache = [false, "", 0, 1, 0, false, 0, false, "", 0, 0, 0, 0];

// Generation arrays
KTWK_NVG_gen1 = [];
KTWK_NVG_gen2 = [];
KTWK_NVG_gen3 = [];
KTWK_NVG_gen4 = [];
KTWK_NVG_allItems = [];

// Generation parameters: [NoGen, Gen1, Gen2, Gen3, Gen4]
KTWK_NVG_genIntensity = [0.4, 0.8, 0.6, 0.4, 0.2];
KTWK_NVG_genNoise = [0.5, 0.7, 0.7, 0.5, 0.3];
KTWK_NVG_genBrightness = [1.0, 0.7, 0.8, 1.0, 1.0];
KTWK_NVG_genMaxRange = [200, 50, 100, 200, 300];

// Color arrays
KTWK_NVG_wp = [];
KTWK_NVG_amber = [];
KTWK_NVG_bw = [];
KTWK_NVG_crimson = [];
KTWK_NVG_green = [];

KTWK_NVG_wp_custom = [];
KTWK_NVG_amber_custom = [];
KTWK_NVG_bw_custom = [];
KTWK_NVG_crimson_custom = [];
KTWK_NVG_green_custom = [];

// Exclusion arrays
KTWK_NVG_excludeGlobal = [];
KTWK_NVG_excludeAutoGen = [];

// Optics
KTWK_NVG_opticZoomMin = 200;
KTWK_NVG_opticZoomMax = 200;
KTWK_NVG_knownOptics = [];
KTWK_NVG_knownOpticZooms = [];

