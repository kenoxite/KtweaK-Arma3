// KTWK_BPH_fnc_toggleSystem
// Toggles the Bodypart HUD system on or off
//
// Parameters:
//   None (toggles based on current state)
// Returns:
//   Nothing

private _activate = !KTWK_BPH_isActive;

if (_activate) then {
    call KTWK_BPH_fnc_initSystem;
} else {
    call KTWK_BPH_fnc_disableSystem;
};

KTWK_BPH_isActive = _activate;
