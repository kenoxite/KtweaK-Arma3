// Moves the HUD to the position stated in the settings


disableSerialization;
private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth";
private _ctrl = _display displayCtrl 30000;
_ctrl ctrlSetPosition[
    safeZoneX + (safeZoneW - ((3.5 + KTWK_HUD_health_opt_xPos) * pixelGridNoUIScale * pixelW)),
    safeZoneY + (safeZoneH - ((7.4 + KTWK_HUD_health_opt_yPos) * pixelGridNoUIScale * pixelH)),
    4 * pixelGridNoUIScale * pixelW,
    8 * pixelGridNoUIScale * pixelH 
]; 
_ctrl ctrlCommit 0;

// Reset HUD to default alpha
if (isNull player || time < 3) exitWith {false};
KTWK_HUD_health_alpha = 0.6;
call KTWK_fnc_HUD_health_update;
0 spawn {
    waitUntil {isNull (findDisplay 49) || !alive player};
    KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
    call KTWK_fnc_HUD_health_update;
};
