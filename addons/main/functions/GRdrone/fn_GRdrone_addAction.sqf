// Adds action menu entry to specified unit to be able to launch the drone
params ["_unit"];
_id = _unit addAction 
    [ 
        "<img image='\a3\ui_f\data\igui\cfg\actions\getinpilot_ca.paa' /> <t color='#00FF00'>Deploy Recon Drone</t>",    // title 
        { 

            _this call KTWK_fnc_GRdrone_action;
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
_unit setVariable ["KTWK_GRdrone_actionId", _id, true];
