// KTWK_DFB_fnc_hideHUD
// Quickly hides all body part HUD elements
// Clears textures and resets alpha values to 0
//
// Parameters:
//   _display - The HUD display
//   _idcs - Array of IDC mappings [[_idc, "_img"], ...]
// Returns:
//   Boolean - false if display or controls invalid, true otherwise

#include "\z\ktweak\addons\damagefeedback\idc.hpp"

params ["_display", "_idcs"];

if (isNull _display) exitWith { false };

// Hide all HUD elements by clearing their textures
{
    _x params ["_idc", "_img"];
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlSetText "";
        // Reset alpha to 0 for all controls
        _ctrl ctrlSetTextColor [0, 0, 0, 0];
    };
} forEach _idcs;

// Also ensure the group control is hidden
private _groupCtrl = _display displayCtrl IDC_BPH_GROUP;
if (!isNull _groupCtrl) then {
    _groupCtrl ctrlShow false;
};

true
