// Hide icons if no GPS
// by kenoxite

if (KTWK_opt_GPSHideIcons_enable) then {
    missionNamespace setVariable ["KTWK_GPSHideIcons_enabled", true];
    if (call KTWK_fnc_checkForGPS) then {
        disableMapIndicators [false,KTWK_opt_GPSHideIcons_enemies,KTWK_opt_GPSHideIcons_mines,false];
        // Enable custom waypoint
        // onMapSingleClick {};
    } else {
        disableMapIndicators [true,true,true,false];
        // Disable custom waypoint
        if (!KTWK_opt_GPSHideIcons_customWP) then {
            onMapSingleClick {_shift};
        };
    };
} else {
    if (missionNamespace getVariable ["KTWK_GPSHideIcons_enabled", true]) then {
        missionNamespace setVariable ["KTWK_GPSHideIcons_enabled", false];
        disableMapIndicators [false,false,false,false];
        // Enable custom waypoint
        // onMapSingleClick {};
    };
};
