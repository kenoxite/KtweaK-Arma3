// KTWK_BML_fnc_set_client
// Applies brighter moonlight effect to a client
//
// Parameters:
//   _effect   - Color correction effect array
//   _aperture - Aperture settings array
//   _noWait   - Boolean: skip progressive transition
// Returns:
//   Nothing

params ["_effect", "_aperture", "_noWait"];

if (!canSuspend) exitWith {
    _this spawn KTWK_BML_fnc_set_client;
};

if (isNil "KTWK_BML_colorC") then {
    KTWK_BML_colorC = ppEffectCreate ["ColorCorrections", 2000];
    waitUntil {!isNil "KTWK_BML_colorC"};
    KTWK_BML_colorC ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.5, 0.25, 0.25, 0]];
    KTWK_BML_colorC ppEffectCommit 0;
    KTWK_BML_colorC ppEffectEnable true;
};

// Apply immediately if it's mission start
if (time < 5) then {
    _noWait = true;
};

KTWK_BML_colorC ppEffectAdjust _effect;
KTWK_BML_colorC ppEffectCommit ([60, 0] select _noWait);

if (_aperture isNotEqualTo []) then {
    call {
        // Don't wait if forced or at dawn
        if (_noWait || {date # 3 < 12}) exitWith {
            setApertureNew _aperture;
        };
        
        // Progressive aperture at dusk/night
        [_aperture] spawn {
            params ["_aperture"];
            
            private _ap = apertureParams;
            private _ap0 = _ap # 0;
            private _ap1 = _ap0 + 0.1;
            private _ap2 = _ap0 + 0.2;
            private _ap3 = _aperture # 3;
            private _step = 0.1;
            
            setApertureNew [_ap0, _ap1, _ap2, _ap3];
            
            while {(apertureParams # 8) && {[_ap0, _ap1, _ap2] isNotEqualTo [_aperture # 0, _aperture # 1, _aperture # 2]}} do {
                _ap0 = _ap0 - _step;
                _ap1 = _ap1 - _step;
                _ap2 = _ap2 - _step;
                setApertureNew [_ap0, _ap1, _ap2, _ap3];
                
                // Exit if aperture was reset while transitioning or below threshold
                if (!(apertureParams # 8) || {_ap0 < (_aperture # 0) || {_ap1 < (_aperture # 1)} || {_ap2 < (_aperture # 2)}}) exitWith {
                    if (apertureParams # 8) exitWith {
                        setApertureNew _aperture;
                    };
                };
                sleep 1;
            };
            
            if (!isNil "KTWK_opt_debug" && {KTWK_opt_debug}) then {
                systemChat "[Brighter Moonlight] Aperture set!";
            };
        };
    };
} else {
    setApertureNew [-1];
};

player setVariable ["KTWK_BML_set", true, true];
