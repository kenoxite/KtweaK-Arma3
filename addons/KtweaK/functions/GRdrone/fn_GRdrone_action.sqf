// Recon drone - Action
// by kenoxite

params ["_target", "_caller", "_actionId", "_arguments"];
if (KTWK_GRdrone_opt_enabled) then {
    if (vehicle _target == _target) then {
        private _droneInInv = "KTWK_GRdrone" in (itemsWithMagazines _target);
        private _dronePrereqsMet = !KTWK_GRdrone_opt_itemRequired || {KTWK_GRdrone_opt_itemRequired && _droneInInv};
        if (_dronePrereqsMet) then {
            if ((time-KTWK_GRdrone_lastUse)>KTWK_GRdrone_opt_reuseTime) then {
                call KTWK_fnc_GRdrone_spawnDrone;
            } else {
                    private _recharged = 100 - round((round (KTWK_GRdrone_opt_reuseTime - (time-KTWK_GRdrone_lastUse))/KTWK_GRdrone_opt_reuseTime)*100);
                    hintSilent parseText format [
                        "Recharging drone: <t color='#%3'>%1%2</t>",
                        _recharged,
                        "%",
                        ["FF0000", "FFFF00"] select {_recharged > 50}
                        ];
            };
        } else {
            hintSilent parseText "<t color='#FF0000'>Recon Drone Dispenser not in inventory</t>";
        };
    } else {
        hintSilent parseText "<t color='#FF0000'>Recon Drone not available inside vehicles</t>";
    };
} else {
    hintSilent parseText "<t color='#FF0000'>Recon Drone not available</t>";
};
