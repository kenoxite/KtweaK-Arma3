// KTWK_DFB_fnc_toggleSystem
// Toggles the Bodypart HUD system on or off
//
// Parameters:
//   None (toggles based on current state)
// Returns:
//   Nothing

private _activate = !KTWK_DFB_isActive;

if (_activate) then {
    call KTWK_DFB_fnc_initSystem;
} else {
    call KTWK_DFB_fnc_disableSystem;
};

KTWK_DFB_isActive = _activate;
