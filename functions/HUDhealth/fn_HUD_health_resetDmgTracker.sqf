// Reset damage tracker
KTWK_HUD_health_dmgTracker = [];
{KTWK_HUD_health_dmgTracker pushback [0, KTWK_HUD_health_opt_alpha]} forEach KTWK_HUD_health_bodyParts;
