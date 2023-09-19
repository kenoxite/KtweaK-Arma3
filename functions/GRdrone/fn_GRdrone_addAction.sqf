// Adds action menu entry to specified unit to be able to launch the drone
params ["_unit"];
_id = _unit addAction 
    [ 
        "<img image='\a3\ui_f\data\igui\cfg\actions\getinpilot_ca.paa' /> <t color='#00FF00'>Launch Recon Drone</t>",    // title 
        { 
            params ["_target", "_caller", "_actionId", "_arguments"]; // script
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
                                    if (_recharged > 50) then {"FFFF00"} else {"FF0000"}
                                    ];
                        };
                    } else {
                        hintSilent parseText "<t color='#FF0000'>Recon Drone not in inventory</t>";
                    };
                } else {
                    hintSilent parseText "<t color='#FF0000'>Recon Drone not available inside vehicles</t>";
                };
            } else {
                hintSilent parseText "<t color='#FF0000'>Recon Drone not available</t>";
            };
        }, 
        nil,        // arguments 
        1.5,        // priority 
        false,       // showWindow 
        false,       // hideOnUse 
        "",         // shortcut 
        str (!call KTWK_fnc_GRdrone_playerInUAV),     // condition 
        -1,         // radius 
        false,      // unconscious 
        "",         // selection 
        ""          // memoryPoint 
    ];
_unit setVariable ["KTWK_GRdrone_actionId", _id];
