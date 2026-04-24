// KTWK_NVG_fnc_toggleSystem
// Toggles the NVG system on or off
//
// Parameters:
//   None
// Returns:
//   Nothing

private _activate = !KTWK_NVG_isActive;

if (_activate) then {
    if (!KTWK_aceNightvision || (KTWK_aceNightvision && {KTWK_NVG_opt_aceOverride})) then {
        call KTWK_NVG_fnc_initSystem;
    };
} else {
    call KTWK_NVG_fnc_disableSystem;
};
