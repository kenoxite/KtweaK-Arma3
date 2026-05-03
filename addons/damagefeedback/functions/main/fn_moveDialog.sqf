// KTWK_DFB_fnc_moveDialog
// Moves the HUD to the position stated in the settings and resets alpha
//
// Parameters:
//   None
// Returns:
//   Boolean - false if display doesn't exist, true otherwise

#include "\z\ktweak\addons\damagefeedback\idc.hpp"

disableSerialization;

private _display = uiNamespace getVariable ["BPH_Display", displayNull];
if (isNull _display) exitWith {false};

private _ctrl = _display displayCtrl IDC_BPH_GROUP;
if (isNull _ctrl) exitWith {false};

// Calculate position based on settings
private _xPos = safeZoneX + (safeZoneW - ((3.5 + KTWK_DFB_opt_xPos) * pixelGridNoUIScale * pixelW));
private _yPos = safeZoneY + (safeZoneH - ((7.4 + KTWK_DFB_opt_yPos) * pixelGridNoUIScale * pixelH));
private _width = 4 * pixelGridNoUIScale * pixelW;
private _height = 8 * pixelGridNoUIScale * pixelH;

_ctrl ctrlSetPosition [_xPos, _yPos, _width, _height];
_ctrl ctrlCommit 0;

// Reset HUD to default alpha
if (isNull player || {time < 3}) exitWith {false};

KTWK_DFB_targetAlpha = 0.6;
call KTWK_DFB_fnc_update;

// Reset alpha after pause menu closes
if (canSuspend) then {
    [] spawn {
        waitUntil {isNull (findDisplay 49) || {!alive player}};
        KTWK_DFB_targetAlpha = KTWK_DFB_opt_alpha;
        call KTWK_DFB_fnc_update;
    };
};

true
