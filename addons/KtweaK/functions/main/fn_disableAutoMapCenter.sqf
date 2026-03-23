// Disable map autocenter and restore map position and zoom next time map is opened
// by kenoxite

private _mrk_mapCenter = createMarkerLocal ["KTWK_GPSHI_mapCenter",[worldSize / 2, worldsize / 2, 0]];
_mrk_mapCenter setMarkerShapeLocal "ICON";
_mrk_mapCenter setMarkerTypeLocal "Empty";

KTWK_GPSHI_lastMapCenter = [worldSize / 2, worldsize / 2, 0];
KTWK_GPSHI_lastMapZoom = 0.05;
KTWK_GPSHI_centerPlayerBtnColor = [];
KTWK_GPSHI_centerPlayerBtnTooltip = "x";

KTWK_opt_GPSHideIcons_autoCenter_last = KTWK_opt_GPSHideIcons_autoCenter;

addMissionEventHandler ["Map", {
    params ["_mapIsOpened", "_mapIsForced"];

    private _mapCtrl = findDisplay 12 displayCtrl 51;    
    if (_mapIsOpened) then {
        if (KTWK_opt_GPSHideIcons_enable && !(call KTWK_fnc_checkForGPS) && !KTWK_opt_GPSHideIcons_autoCenter) then {
            // Move map to last map position
            _mapCtrl ctrlMapAnimAdd [0, KTWK_GPSHI_lastMapZoom, KTWK_GPSHI_lastMapCenter];
            ctrlMapAnimCommit _mapCtrl;
        
            // Disable center on map button
            // by Larrow
            private _display = uiNamespace getVariable "RSCDiary";
            private _ctrl = _display displayCtrl 1202;
            if (count KTWK_GPSHI_centerPlayerBtnColor == 0) then {
                KTWK_GPSHI_centerPlayerBtnColor =  ctrlTextColor _ctrl;
                KTWK_GPSHI_centerPlayerBtnTooltip =  ctrlTooltip _ctrl;
            };
            _ctrl ctrlEnable false;
            _ctrl ctrlSetTextColor [0,0,0,0];
            _ctrl ctrlSetTooltip "";
            _ctrl ctrlCommit 0;
        } else {
            if (!KTWK_opt_GPSHideIcons_autoCenter_last && KTWK_opt_GPSHideIcons_autoCenter) then {
                // Enable center on map button
                private _display = uiNamespace getVariable "RSCDiary";
                private _ctrl = _display displayCtrl 1202;
                _ctrl ctrlEnable true;
                _ctrl ctrlSetTextColor KTWK_GPSHI_centerPlayerBtnColor;
                _ctrl ctrlSetTooltip KTWK_GPSHI_centerPlayerBtnTooltip;
                _ctrl ctrlCommit 0; 
            };           
        };
    } else {
        // Save last map position
        private _ctrlPos = ctrlPosition _mapCtrl;
        private _ctrlX =  (_ctrlPos #0);
        private _ctrlY =  (_ctrlPos #1);
        private _ctrlW =  ((_ctrlPos #2) / 2);
        private _ctrlH =  ((_ctrlPos #3) / 2);

        KTWK_GPSHI_lastMapCenter = _mapCtrl ctrlMapScreenToWorld [(_ctrlW + _ctrlX), (_ctrlH + _ctrlY)];
        "KTWK_GPSHI_mapCenter" setMarkerPosLocal KTWK_GPSHI_lastMapCenter;
        KTWK_GPSHI_lastMapZoom = ctrlMapScale _mapCtrl;
    };

    KTWK_opt_GPSHideIcons_autoCenter_last = KTWK_opt_GPSHideIcons_autoCenter;
}];
