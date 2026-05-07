// KTWK_DFB_fnc_initSystem
// Damage Feedback - Initialization and main loop
//
// Parameters:
//   None
// Returns:
//   Nothing

#include "\z\ktweak\addons\damagefeedback\idc.hpp"

// Only run on clients with interface
if (!hasInterface) exitWith {};

// diag_log "[DFB] Initializing system...";

// Check if system is enabled by setting
if (!KTWK_DFB_opt_enabled) exitWith {
    if (!isNil "KTWK_DFB_pfh") then {
        call KTWK_DFB_fnc_disableSystem;
    };
};

disableSerialization;

// Create HUD display
("DFB_Layer" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
("DFB_Layer" call BIS_fnc_rscLayer) cutRsc ["DFB_Dialog", "PLAIN", 0, false];

private _display = uiNamespace getVariable ["DFB_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "[DFB] Failed to create display!";
};

private _ctrl = _display displayCtrl IDC_DFB_GROUP;
_ctrl ctrlShow true;

private _ctrlX = safeZoneX + (safeZoneW - (4 * pixelGridNoUIScale * pixelW));
private _ctrlY = safeZoneY + (safeZoneH - (9 * pixelGridNoUIScale * pixelH));
private _ctrlWidth = 4 * pixelGridNoUIScale * pixelW;
private _ctrlHeight = 8 * pixelGridNoUIScale * pixelH;

_ctrl ctrlSetPosition [_ctrlX, _ctrlY, _ctrlWidth, _ctrlHeight];
_ctrl ctrlCommit 0;

if (isNil "KTWK_DFB_EH_playerViewChanged") then {
    KTWK_DFB_EH_playerViewChanged = addMissionEventHandler ["PlayerViewChanged", {
        params ["_previousUnit", "_newUnit", "_vehicleIn","_oldCameraOn", "_newCameraOn", "_uav"];
        missionNamespace setVariable ["KTWK_DFB_invOpened", false];
        // call KTWK_DFB_fnc_resetDmgTracker;
    }];
};

// Wait for main display
[{
    !isNull findDisplay 46
}, {
    // Display is ready, continue initialization
    private _display = uiNamespace getVariable ["DFB_Display", displayNull];
    if (isNull _display) exitWith { diag_log "[DFB] Display disappeared before init"; };

    [_display, KTWK_DFB_idcs, true] call KTWK_DFB_fnc_drawHUD;
    call KTWK_DFB_fnc_resetDmgTracker;
    call KTWK_DFB_fnc_moveDialog;
    call KTWK_DFB_fnc_createPfh;
    KTWK_DFB_isActive = true;
    // diag_log "[DFB] System initialized";
}] call CBA_fnc_waitUntilAndExecute;
