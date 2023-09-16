// Resets the display of the HUD

params ["_display"];
KTWK_HUD_health_invOpened = false;
KTWK_HUD_health_alpha = KTWK_HUD_health_opt_alpha;
KTWK_HUD_health_alphaTemp = 0;
call KTWK_fnc_HUD_health_resetDmgTracker;
call KTWK_fnc_HUD_health_update;
