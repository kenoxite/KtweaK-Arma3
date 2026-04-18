// KTWK_NVG_fnc_detectGeneration
// Detects NVG generation from item class
//
// Parameters:
//   _nvgClass - NVG class name to check (default: "")
// Returns:
//   Number - _genIndex 0-4 (0 = unknown)

params [["_nvgClass", ""]];

if (_nvgClass == "") exitWith { 0 };

private _nvgClassLower = toLowerANSI _nvgClass;

// Check custom generation arrays
if (_nvgClassLower in KTWK_NVG_gen1) exitWith { 1 };
if (_nvgClassLower in KTWK_NVG_gen2) exitWith { 2 };
if (_nvgClassLower in KTWK_NVG_gen3) exitWith { 3 };
if (_nvgClassLower in KTWK_NVG_gen4) exitWith { 4 };

0  // Unknown generation
