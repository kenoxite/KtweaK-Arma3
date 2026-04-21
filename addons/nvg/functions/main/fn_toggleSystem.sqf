// KTWK_NVG_fnc_toggleSystem
// Toggles the NVG system on or off
//
// Parameters:
//   None
// Returns:
//   Nothing

private _activate = !KTWK_NVG_isActive;

if (_activate) then {
    if (!KTWK_aceNightvision) then {
        call KTWK_NVG_fnc_initSystem;
    };
} else {
    call KTWK_NVG_fnc_disableSystem;
};

KTWK_NVG_isActive = _activate;
