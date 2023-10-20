// Brighter nights - Set Client
// by kenoxite

params ["_effect", "_aperture", "_noWait"];

if (isNil {KTWK_BN_colorC}) then {
    KTWK_BN_colorC = ppEffectCreate ["ColorCorrections",2000]; 
    KTWK_BN_colorC ppEffectAdjust [1,1,0,[0,0,0,0],[1,1,1,1],[0.5,0.25,0.25,0]];
    KTWK_BN_colorC ppEffectCommit 0;
    KTWK_BN_colorC ppEffectEnable true;
};

// Apply immediately if it's mission start
if (time < 5) then {_noWait = true};    

KTWK_BN_colorC ppEffectAdjust _effect;
KTWK_BN_colorC ppEffectCommit ([60, 0] select _noWait);

// default: [30,55,70,200];
if (count _aperture > 0) then {
    call {
        // Don't wait if forced or at dawn
        if (_noWait || (date#3) < 12) exitWith { setApertureNew _aperture };
        // Progressive aperture at dusk/night
        [_aperture] spawn {
            params ["_aperture"];
            private ["_ap", "_ap0", "_ap1", "_ap2", "_ap3", "_step"];
            _ap = apertureParams;
            _ap0 = (_ap#0);
            _ap1 = (_ap#0)+0.1;
            _ap2 = (_ap#0)+0.2;
            _ap3 = _aperture#3;
            _step = 0.1;
            setApertureNew [_ap0, _ap1, _ap2, _ap3];
            while {(apertureParams#8) && !([_ap0, _ap1, _ap2] isEqualTo [_aperture#0,_aperture#1,_aperture#2])} do {
                _ap0 = _ap0 - _step;
                _ap1 = _ap1 - _step;
                _ap2 = _ap2 - _step;
                setApertureNew [_ap0, _ap1, _ap2, _ap3];
                // Exit if aperture was reset while transitioning or if any parameter is below desired threshold
                if (!(apertureParams#8) || {_ap0 < (_aperture#0) || _ap1 < (_aperture#1) || _ap2 < (_aperture#2)}) exitWith {
                    if (apertureParams#8) exitWith {setApertureNew _aperture};
                };
                sleep 1;
            };
            if (KTWK_opt_debug) then {systemChat "[KtweaK] Aperture set!"};
        };
    };
} else {
    setApertureNew [-1];
};

player setVariable ["KTWK_BN_set", true, true];
