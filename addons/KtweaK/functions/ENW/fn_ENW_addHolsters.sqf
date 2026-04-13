// KTWK_fnc_addHolsters
// Creates needed holsters to display the extra weapons on the unit

params [["_unit", player]];
// - Add rifle holster to player unit
if (KTWK_ENW_opt_displayRifle) then {
    private _wpns = [_unit, 1, false] call KTWK_fnc_ENW_equipNextWeapon;
    if (count _wpns > 1) then {
        [_unit, 1, 0, KTWK_ENW_opt_riflePos, (_wpns#1)] call KTWK_fnc_ENW_displayHolster;
    };
};
// - Add launcher holster to player unit
if (KTWK_ENW_opt_displayLauncher) then {
    private _wpns = [_unit, 3, false] call KTWK_fnc_ENW_equipNextWeapon;
    if (count _wpns > 1) then {
        [_unit, 3, 0, KTWK_ENW_opt_launcherPos, (_wpns#1)] call KTWK_fnc_ENW_displayHolster;
    };
};
