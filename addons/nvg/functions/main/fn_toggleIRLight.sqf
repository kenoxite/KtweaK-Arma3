// KTWK_NVG_fnc_toggleIRLight
// Toggles an IR light attached to player's head based on current NVG generation
//
// Parameters:
//   _activate - True to create light, false to delete (default: true)
// Returns:
//   Nothing

params [["_activate", true], ["_updateUnitVar", true]];

private _unit = KTWK_player;

// Delete the IR light
if (!_activate || (KTWK_aceNightvision && {!KTWK_NVG_opt_aceOverride})) exitWith {
    [getPlayerUID player] remoteExec ["KTWK_NVG_fnc_deleteIRLight", 0, true];
    KTWK_NVG_irLightToggle = false;
    if (_updateUnitVar) then { _unit setVariable ["KTWK_NVG_irLightActive", false] };
};

if !(_unit isKindOf "CAManBase") exitWith {};
private _mode = [_unit] call KTWK_NVG_fnc_mode;
private _deviceGenData = [_mode, _unit] call KTWK_NVG_fnc_getDeviceGen;
_deviceGenData params ["_gen"];
if (_gen == 0 && {(hmd _unit) != ""}) then { _gen = 3 };

KTWK_NVG_irLightToggle = true;
_unit setVariable ["KTWK_NVG_irLightActive", true];

[_gen, getPlayerUID player] remoteExec ["KTWK_NVG_fnc_createIRLight", 0, true];
