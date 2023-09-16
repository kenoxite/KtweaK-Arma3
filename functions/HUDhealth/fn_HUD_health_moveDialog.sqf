// Moves the HUD to the position stated in the settings

KTWK_HUD_health_alpha = 1;
disableSerialization;
private _display = uiNamespace getVariable "KTWK_GUI_Display_HUD_bodyHealth";
private _ctrl = _display displayCtrl 30000;
_ctrl ctrlSetPosition[
    SafeZoneX + (SafeZoneW - ((3.5 + KTWK_HUD_health_opt_xPos) * pixelGridNoUIScale * pixelW)),
    SafeZoneY + (SafeZoneH - ((7.4 + KTWK_HUD_health_opt_yPos) * pixelGridNoUIScale * pixelH)),
    4 * pixelGridNoUIScale * pixelW,
    8 * pixelGridNoUIScale * pixelH 
]; 
_ctrl ctrlCommit 0;
// Reset HUD to default alpha
call KTWK_fnc_HUD_health_update;
0 spawn {
    waituntil {IsNull (findDisplay 49)};
    KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
    call KTWK_fnc_HUD_health_update;
};
