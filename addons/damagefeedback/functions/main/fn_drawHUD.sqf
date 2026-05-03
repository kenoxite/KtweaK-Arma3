// KTWK_DFB_fnc_drawHUD
// Draws or hides HUD elements by setting their texture paths
//
// Parameters:
//   _display - The HUD display
//   _idcArr  - Array of IDC and image name pairs [[_idc, _img], ...]
//   _on      - True to show elements, false to hide (default: true)
// Returns:
//   Boolean - False if _idcArr is empty, true otherwise

params ["_display", ["_idcArr", []], ["_on", true]];

if (_idcArr isEqualTo []) exitWith {false};

{
    _x params ["_idc", "_img"];
    private _ctrl = _display displayCtrl _idc;
    private _path = if (_on) then {
        format ["\z\ktweak\addons\damagefeedback\img\bodyparts\bodyicon_%1.paa", _img]
    } else {
        ""
    };
    _ctrl ctrlSetText _path;
    
    // Set alpha based on current display alpha
    if (_on) then {
        _ctrl ctrlSetTextColor [1, 1, 1, KTWK_DFB_displayAlpha];
    };
} forEach _idcArr;

true
