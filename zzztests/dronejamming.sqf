// Drone jamming
// - SP & MP
// - Supports multiple players jamming the same drone
// - Players controlling jammed drones will be booted from control
// - Server authoritative
// by kenoxite

#define FOCUS_ANGLE 30  // Angle at which the jammer must be pointing at in order to jam
#define TOLERANCE 0.06  // Frequency tolerance when checking for matching frequencies
#define MIN_STRENGTH -60    // Signal strength required to jam a drone

// Only set if mission hasn't set it already
if (isNil {missionNamespace getVariable "#EM_FMin"}) then { missionNamespace setVariable ["#EM_FMin", 140]; };
if (isNil {missionNamespace getVariable "#EM_FMax"}) then { missionNamespace setVariable ["#EM_FMax", 143]; };
if (isNil {missionNamespace getVariable "#EM_SMin"}) then { missionNamespace setVariable ["#EM_SMin", -100]; };
if (isNil {missionNamespace getVariable "#EM_SMax"}) then { missionNamespace setVariable ["#EM_SMax", -10]; };
if (isNil {missionNamespace getVariable "#EM_SelMin"}) then { missionNamespace setVariable ["#EM_SelMin", 141.6]; };
if (isNil {missionNamespace getVariable "#EM_SelMax"}) then { missionNamespace setVariable ["#EM_SelMax", 141.9]; };
if (isNil {missionNamespace getVariable "#EM_Values"}) then { missionNamespace setVariable ["#EM_Values", []]; };

if (isServer) then {
    missionNamespace setVariable ["KTWK_EW_activeJammers", createHashMap, true];
    missionNamespace setVariable ["KTWK_EW_usedFrequencies", []];
};

// Assign unique and random frequency to a drone
KTWK_fnc_EW_assignUniqueFrequency = {
    params ["_drone"];
    private _freq = _drone getVariable ["KTWK_EW_droneFrequency", 0];
    if (_freq == 0) then {
        private _usedPairs = (missionNamespace getVariable ["KTWK_EW_usedFrequencies", []]) select {
            !isNull (_x#0) && {alive (_x#0)}
        };
        private _usedFreqs = _usedPairs apply {_x#1};
        private _fMin = missionNamespace getVariable ["#EM_FMin", 140];
        private _fMax = missionNamespace getVariable ["#EM_FMax", 143];
        private _minSpacing = TOLERANCE*2;
        private _edgeMin = _fMin + _minSpacing;
        private _edgeMax = _fMax - _minSpacing;
        private _attempts = 0;
        private _success = false;

        while {!_success && _attempts < 100} do {
            // Generate a candidate frequency within safe bounds, 1 decimal place
            private _candidate = _edgeMin + (random (_edgeMax - _edgeMin));
            _candidate = parseNumber (_candidate toFixed 1);

            // Check minimum spacing from all used frequencies
            private _tooClose = false;
            {
                if (abs (_candidate - _x) < _minSpacing) exitWith { _tooClose = true; };
            } forEach _usedFreqs;

            if (!_tooClose) then {
                _freq = _candidate;
                _success = true;
            };
            _attempts = _attempts + 1;
        };

        if (!_success) exitWith { diag_log "KTWK: Failed to assign frequency"; };

        _drone setVariable ["KTWK_EW_droneFrequency", _freq, true];
        _usedPairs pushBack [_drone, _freq];
        missionNamespace setVariable ["KTWK_EW_usedFrequencies", _usedPairs];
    };
};


// Signal calculation
KTWK_fnc_EW_calcSignal = {
    params ["_player", "_drone", "_selMin", "_selMax", "_tolerance"];
    private _sMin = missionNamespace getVariable ["#EM_SMin", -100];
    private _sMax = missionNamespace getVariable ["#EM_SMax", -10];

    private _muzzlePos = _player modelToWorldWorld (_player selectionPosition "proxy:\a3\characters_f\proxies\pistol.001");
    private _muzzleDir = _player weaponDirection currentWeapon _player;
    private _dronePos = getPosASL _drone;
    private _dirToDrone = vectorNormalized (_dronePos vectorDiff _muzzlePos);
    private _dot = _dirToDrone vectorDotProduct _muzzleDir;
    private _focusAngle = FOCUS_ANGLE;
    private _focusMult = linearConversion [cos _focusAngle, 1, _dot, 0, 1, true];
    _focusMult = _focusMult ^ 2;

    private _obstructed = lineIntersects [
        _muzzlePos, _dronePos, _player, _drone
    ];

    private _distance = (_player distance _drone) max 1;
    private _rawStrength = _sMax - 20 * log (_distance / 10);
    _rawStrength = _rawStrength max _sMin;

    private _strength = if (!_obstructed) then {
        _rawStrength * _focusMult + _sMin * (1 - _focusMult)
    } else {
        private _attenuated = (_rawStrength - 50) max (_sMin + 5);
        _attenuated * _focusMult + _sMin * (1 - _focusMult)
    };

    private _freq = _drone getVariable ["KTWK_EW_droneFrequency", 0];
    private _freqCenter = (_selMin + _selMax) / 2;
    private _freqDiff = abs(_freq - _freqCenter);
    private _sigma = _tolerance max 0.001;
    private _freqEffect = exp(-(_freqDiff^2) / (2 * _sigma^2));
    private _isFrequencyMatch = (_freqEffect > 0.1);
    private _isFocused = (_focusMult > 0.5);
    private _canJam = (_strength > MIN_STRENGTH) && _isFrequencyMatch;

    [_freq, _distance, !_obstructed, _strength, _isFocused, _isFrequencyMatch, _canJam]
};

// Drone jamming
KTWK_fnc_EW_jamDrone = {
    params ["_drone", ["_duration", 5]];
    if (isNull _drone) exitWith {};
    // Boot players from drone control
    {
        [_x, objNull] remoteExec ["connectTerminalToUAV", _x];
        [_x, objNull] remoteExec ["remoteControl", _x];
    } forEach ((UAVControl _drone) select {typeName _x == "OBJECT" && {!isNull _x}});
    // Disallow all players from connecting to the drone while jammed
    {
        _x disableUAVConnectability [_drone, true];
    } forEach allPlayers;
    [_drone, false] remoteExec ["engineOn", _drone];
    if (_drone isKindOf "Air") then {
        if (_drone isKindOf "Helicopter") then {
            [_drone, 1] remoteExec ["flyInHeight", _drone];
        } else {
            [_drone, "LAND"] remoteExec ["land", _drone];
        };
    };
    [_drone, false] remoteExec ["setAutonomous", _drone];
    {[_drone, _x] remoteExec ["forgetTarget", _drone]} forEach (_drone targets [true]);
    _drone setVariable ["KTWK_EW_isJammed", true, true];
    _drone setVariable ["KTWK_EW_jamEndTime", CBA_missionTime + _duration, true];
};

// Reset jammed drone when jam expires
KTWK_fnc_EW_unjamDrone = {
    params ["_drone"];
    [_drone, true] remoteExec ["engineOn", _drone];
    if (_drone isKindOf "Air") then {
        if (_drone isKindOf "Helicopter") then {
            [_drone, 100] remoteExec ["flyInHeight", _drone];
        } else {
            [_drone, "NONE"] remoteExec ["land", _drone];
        };
    };
    [_drone, true] remoteExec ["setAutonomous", _drone];

    // Allow all players to connect to the drone
    {
        _x enableUAVConnectability [_drone, true];
    } forEach allPlayers;

    _drone setVariable ["KTWK_EW_isJammed", false, true];
    _drone setVariable ["KTWK_EW_jamEndTime", 0, true];
};

// Debug hint
KTWK_fnc_EW_debug = {
    params ["_drone", "_freq", "_distance", "_obstructed", "_strength", "_isFocused", "_isFrequencyMatch", "_canJam", "_progress", "_isTransmitting", "_isJamming"];
    private _text = if (isNull _drone) then {
        "<t color='#FFA500' size='1.2'>Drone Signal Debug</t><br/>" +
        "<t color='#00FF00'>Drone:</t> <t color='#FFFFFF'>--</t><br/>" +
        "<t color='#00FF00'>Freq:</t> <t color='#FFFFFF'>-- MHz</t><br/>" +
        "<t color='#00FF00'>Dist:</t> <t color='#FFFFFF'>-- m</t><br/>" +
        "<t color='#00FF00'>LoS:</t> <t color='#FFFFFF'>--</t><br/>" +
        "<t color='#00FF00'>Strength:</t> <t color='#FFFFFF'>-- dBm</t><br/>" +
        "<t color='#00FF00'>Focused:</t> <t color='#FFFFFF'>--</t><br/>" +
        "<t color='#00FF00'>FreqMatch:</t> <t color='#FFFFFF'>--</t><br/>" +
        "<t color='#00FF00'>CanJam:</t> <t color='#FFFFFF'>--</t><br/>" +
        "<t color='#00FF00'>Progress:</t> <t color='#FFFFFF'>%1</t><br/>" +
        "<t color='#00FF00'>Transmitting:</t> <t color='#FFFFFF'>%2</t><br/>" +
        "<t color='#00FF00'>Jamming:</t> <t color='#FFFFFF'>%3</t><br/>"
    } else {
        "<t color='#FFA500' size='1.2'>Drone Signal Debug</t><br/>" +
        "<t color='#00FF00'>Drone:</t> <t color='#FFFFFF'>%1</t><br/>" +
        "<t color='#00FF00'>Freq:</t> <t color='#FFFFFF'>%2 MHz</t><br/>" +
        "<t color='#00FF00'>Dist:</t> <t color='#FFFFFF'>%3 m</t><br/>" +
        "<t color='#00FF00'>LoS:</t> <t color='#%4'>%5</t><br/>" +
        "<t color='#00FF00'>Strength:</t> <t color='#FFFFFF'>%6 dBm</t><br/>" +
        "<t color='#00FF00'>Focused:</t> <t color='#%7'>%8</t><br/>" +
        "<t color='#00FF00'>FreqMatch:</t> <t color='#%9'>%10</t><br/>" +
        "<t color='#00FF00'>CanJam:</t> <t color='#%11'>%12</t><br/>" +
        "<t color='#00FF00'>Progress:</t> <t color='#FFFFFF'>%13</t><br/>" +
        "<t color='#00FF00'>Transmitting:</t> <t color='#%14'>%15</t><br/>" +
        "<t color='#00FF00'>Jamming:</t> <t color='#%16'>%17</t><br/>"
    };

    if (isNull _drone) then {
        _text = format [_text, _progress, if (_isTransmitting) then {"Yes"} else {"No"}, if (_isJamming) then {"Yes"} else {"No"}];
    } else {
        _text = format [
            _text,
            getText (configFile >> "cfgVehicles" >> typeOf _drone >> "displayName"),
            _freq,
            _distance,
            if (_obstructed) then {"00FF00"} else {"FF0000"}, if (_obstructed) then {"Yes"} else {"No"},
            _strength,
            if (_isFocused) then {"00FF00"} else {"FF0000"}, if (_isFocused) then {"Yes"} else {"No"},
            if (_isFrequencyMatch) then {"00FF00"} else {"FF0000"}, if (_isFrequencyMatch) then {"Yes"} else {"No"},
            if (_canJam) then {"00FF00"} else {"FF0000"}, if (_canJam) then {"Yes"} else {"No"},
            _progress,
            if (_isTransmitting) then {"00FF00"} else {"FF0000"}, if (_isTransmitting) then {"Yes"} else {"No"},
            if (_isJamming) then {"00FF00"} else {"FF0000"}, if (_isJamming) then {"Yes"} else {"No"}
        ];
    };
    hintSilent parseText _text;
};

// Returns all UAVs with valid assigned frequencies
KTWK_fnc_EW_getActiveDrones = {
    allUnitsUAV select {
        alive _x && { (_x getVariable ["KTWK_EW_droneFrequency", 0]) > 0 }
    }
};

// Assign frequencies to UAVs with none
KTWK_fnc_EW_assignFrequenciesToNewDrones = {
    {
        [_x] call KTWK_fnc_EW_assignUniqueFrequency;
    } forEach (allUnitsUAV select {isNil {_x getVariable "KTWK_EW_droneFrequency"}});
};

// EW Server Initialization
KTWK_fnc_EW_serverInit = {
    if (!isServer) exitWith {};

    // Assign frequencies to new drones every 5 seconds
    [{
        call KTWK_fnc_EW_assignFrequenciesToNewDrones;
    }, 5] call CBA_fnc_addPerFrameHandler;

    // Manage drone jamming every second
    [{
        private _activeJammers = missionNamespace getVariable "KTWK_EW_activeJammers";
        private _drones = allUnitsUAV select {
            alive _x && { (_x getVariable ["KTWK_EW_droneFrequency", 0]) > 0 }
        };
        {
            private _drone = _x;
            private _netId = netId _drone;
            private _jammerList = _activeJammers getOrDefault [_netId, []];

            // Remove disconnected/stale clients (no update in last 0.5s)
            _jammerList = _jammerList select {
                private _clientObj = objectFromNetId (_x#0);
                private _lastUpdate = if (count _x > 4) then {_x#4} else {0};
                !isNull _clientObj && alive _clientObj && (diag_tickTime - _lastUpdate) < 0.5
            };

            // Only keep valid jammers (progress > 0.99, strength > MIN_STRENGTH, etc.)
            _jammerList = _jammerList select {
                private _strength = _x#1;
                private _progress = _x#3;
                (_progress >= 0.99) && (_strength > MIN_STRENGTH)
            };

            private _isJammed = _drone getVariable ["KTWK_EW_isJammed", false];
            private _jamEndTime = _drone getVariable ["KTWK_EW_jamEndTime", 0];

            if (_isJammed) then {
                // If jammed, check if jam duration is over and noone is jamming
                if (CBA_missionTime > _jamEndTime && count _jammerList == 0) then {
                    [_drone] call KTWK_fnc_EW_unjamDrone;
                };
            } else {
                // Not jammed: can only jam if there's at least one valid jammer
                if (count _jammerList > 0) then {
                    [_drone, 3 + random 2] call KTWK_fnc_EW_jamDrone;
                };
            };

            // Update the list in the hashmap
            _activeJammers set [_netId, _jammerList];
        } forEach _drones;


    }, 1] call CBA_fnc_addPerFrameHandler;
};

// EW Client Initialization
KTWK_fnc_EW_clientInit = {
    if (!hasInterface || isNull player || !local player) exitWith {};
    KWTK_EW_lastJammedDroneNetId = "";
    KWTK_EW_wasJamming = false;

    [{
        private _isAlive = alive player;
        private _isConscious = lifeState KTWK_player != "INCAPACITATED" || {!isNil {KTWK_player getVariable "ACE_isUnconscious" && {!(KTWK_player getVariable "ACE_isUnconscious")}}};
        if !(_isAlive && _isConscious) exitWith {
            ["disable"] call KTWK_fnc_EW_infobox;
        };
        if (!isNull (findDisplay 49)) exitwith {};    // Don't check while paused

        // Scanner and player checks
        private _hasScanner = ("muzzle_antenna_03_f" in (handgunItems KTWK_player));
        private _usingScanner = (currentWeapon KTWK_player == "hgun_esd_01_F");
        if !(_hasScanner && _usingScanner) exitWith {
            ["disable"] call KTWK_fnc_EW_infobox;
        };

        // Selected frequency and tolerance values
        private _selMin = missionNamespace getVariable ["#EM_SelMin", 141.6];
        private _selMax = missionNamespace getVariable ["#EM_SelMax", 141.9];
        private _tolerance = TOLERANCE;

        // Gather all active drones with assigned frequency
        private _drones = allUnitsUAV select {
            alive _x && { (_x getVariable ["KTWK_EW_droneFrequency", 0]) > 0 }
        };

        // Calculate spectrum values for display
        private _emValues = [];
        // Find focused drone and calculate its signal
        private _focusedDrone = objNull;
        private _canJam = false;
        private _signalVals = [0,0,false,-100,false,false,false];
        {
            private _signal = [KTWK_player, _x, _selMin, _selMax, _tolerance] call KTWK_fnc_EW_calcSignal;
            _emValues append [_signal#0, _signal#3]; // [frequency, strength]
            // Frequency match
            if (_signal#5) then {
                _focusedDrone = _x;
                _canJam = _signal#6;
                _signalVals = +_signal;
            };
        } forEach _drones;
        missionNamespace setVariable ["#EM_Values", _emValues];

        // Progress bar logic
        private _isTransmitting = (inputAction "defaultAction" > 0) && _hasScanner;
        private _progress = missionNamespace getVariable ["#EM_Progress", 0];
        _progress = if (_isTransmitting && _canJam) then { (_progress + 0.05) min 1 } else { 0 };
        missionNamespace setVariable ["#EM_Progress", _progress];

        private _displayName = call {
            if (!visibleMap) exitWith {
                if (!isNull _focusedDrone && _signalVals#3 > -100) exitWith {
                    if (_signalVals#3 > MIN_STRENGTH || !isNil {_focusedDrone getVariable "KTWK_EW_displayName"}) exitWith {
                        if (isNil {_focusedDrone getVariable "KTWK_EW_displayName"}) then {
                            playSoundUI ["\A3\Sounds_F\sfx\beep_target.wss", 0.5, 0.1, true, 0];
                            _focusedDrone setVariable ["KTWK_EW_displayName", getText (configFile >> "cfgVehicles" >> typeOf _focusedDrone >> "displayName")];
                        };
                        if (_progress > 0) then {
                            if (_progress >= 0.99) then {
                                playSoundUI ["\A3\Sounds_F\weapons\Rockets\locked_3.wss", 0.05, 0.8, true, 0];
                            } else {
                                playSoundUI ["\A3\Sounds_F\weapons\Rockets\locked_1.wss", 0.3, 1.5, true, 0];
                            };
                        } else {
                            playSoundUI ["\A3\Sounds_F\weapons\Rockets\locked_1.wss", 0.3, 1.8, true, 0];
                        };
                        _focusedDrone getVariable "KTWK_EW_displayName";
                    };
                    playSoundUI ["\A3\Sounds_F\weapons\Rockets\locked_1.wss", 0.3, 0.8, true, 0];
                    "Unkown signal";
                };
                "No signal";
            };
            "disable";
        };
        [_displayName] call KTWK_fnc_EW_infobox;

        // Jamming intent messaging
        private _focusedDroneNetId = if (!isNull _focusedDrone) then { netId _focusedDrone } else { "" };
        private _isJammingNow = (_progress >= 0.99) && (!isNull _focusedDrone) && _canJam;

        // Only send if controlled unit is alive, not in vehicle, and not null
        if (_isJammingNow && alive KTWK_player && vehicle KTWK_player == KTWK_player && !isNull KTWK_player) then {
            ["KTWK_EW_jammingState", [
                netId KTWK_player,
                _focusedDroneNetId,
                _signalVals#3, // strength
                _signalVals#0, // frequency
                _progress,
                diag_tickTime // timestamp for server-side staleness check
            ]] call CBA_fnc_serverEvent;
        };

        // If stopped jamming, inform server (only send once per stop)
        if (!_isJammingNow && KWTK_EW_wasJamming && {KWTK_EW_lastJammedDroneNetId != ""}) then {
            ["KTWK_EW_stopJamming", [netId player, KWTK_EW_lastJammedDroneNetId]] call CBA_fnc_serverEvent;
            missionNamespace setVariable ["#EM_Progress", 0];
        };

        // Update state trackers
        KWTK_EW_wasJamming = _isJammingNow;
        KWTK_EW_lastJammedDroneNetId = _focusedDroneNetId;

        // Debug
        // ([_focusedDrone] + _signalVals + [_progress, _isTransmitting, _isJammingNow]) call KTWK_fnc_EW_debug;

    }, 0.1] call CBA_fnc_addPerFrameHandler;
};

// Client sends jamming state (intent)
["KTWK_EW_jammingState", {
    if (!isServer) exitWith {};

    params ["_clientId", "_droneNetId", "_strength", "_frequency", "_progress", "_timestamp"];
    private _drone = objectFromNetId _droneNetId;
    private _client = objectFromNetId _clientId;

    // Validate drone and client
    if (isNull _drone || isNull _client || !alive _client) exitWith {};
    if (!isPlayer _client) exitWith {};
    if (!alive _drone || (_drone getVariable ["KTWK_EW_droneFrequency", 0]) == 0) exitWith {};

    private _activeJammers = missionNamespace getVariable "KTWK_EW_activeJammers";
    private _jammerList = _activeJammers getOrDefault [_droneNetId, []];

    private _found = false;
    {
        if (_x#0 == _clientId) exitWith {
            _x set [1, _strength];
            _x set [2, _frequency];
            _x set [3, _progress];
            _x set [4, _timestamp];
            _found = true;
        };
    } forEach _jammerList;

    if (!_found) then {
        _jammerList pushBack [_clientId, _strength, _frequency, _progress, _timestamp];
    };

    _activeJammers set [_droneNetId, _jammerList];
}] call CBA_fnc_addEventHandler;

// Client stops jamming
["KTWK_EW_stopJamming", {
    if (!isServer) exitWith {};

    params ["_clientId", "_droneNetId"];
    private _drone = objectFromNetId _droneNetId;
    private _client = objectFromNetId _clientId;

    if (isNull _drone || isNull _client || !alive _client) exitWith {};

    private _activeJammers = missionNamespace getVariable "KTWK_EW_activeJammers";
    private _jammerList = _activeJammers getOrDefault [_droneNetId, []];

    _jammerList = _jammerList select { _x#0 != _clientId };
    _activeJammers set [_droneNetId, _jammerList];
}] call CBA_fnc_addEventHandler;


if (isServer) then { call KTWK_fnc_EW_serverInit };
if (hasInterface) then { waitUntil {!isNil {KTWK_player}}; call KTWK_fnc_EW_clientInit };

// Drone information display
KTWK_fnc_EW_infobox = {
    /*
        Usage:
          ["bottom", "Text", [R,G,B,A], "#RRGGBB"] call KTWK_fnc_EW_infobox;
          ["Text"] call KTWK_fnc_EW_infobox; // uses default position (bottom), default colors
          ["disable"] call KTWK_fnc_EW_infobox; // disables/hides the infobox
    */

    // Unique IDC values for our controls
    private _bgIDC = 42000;
    private _txtIDC = 42001;

    // Remove infobox if disabling
    if (count _this == 1 && { toLower (_this select 0) isEqualTo "disable" }) exitWith {
        private _display = uiNamespace getVariable ["KTWK_EW_infobox_display", displayNull];
        if (!isNull _display) then {
            {
                private _ctrl = _display displayCtrl _x;
                if (!isNull _ctrl) then { ctrlDelete _ctrl; };
            } forEach [_bgIDC, _txtIDC];
        };
        uiNamespace setVariable ["KTWK_EW_infobox_display", displayNull];
        uiNamespace setVariable ["KTWK_EW_infobox_active", false];
    };

    // Parameters
    private _posKeyword = "bottom";
    private _text = "No signal";
    private _bgColor = [0,0,0,0.7];
    private _fontColor = "#ffffff";

    if (count _this == 1) then {
        _text = _this select 0;
    } else {
        if (count _this > 1) then {
            _posKeyword = _this select 0;
            _text = _this select 1;
            if (count _this > 2) then {
                _bgColor = _this select 2;
            };
            if (count _this > 3) then {
                _fontColor = _this select 3;
            };
        };
    };

    // Size
    private _w = 0.075 * safeZoneW;
    private _h = 0.015 * safeZoneH;

    // Position Calculation
    private _positions = [
        "topLeft",     [safeZoneX, safeZoneY],
        "topRight",    [safeZoneX + safeZoneW - _w, safeZoneY],
        "bottomLeft",  [safeZoneX, safeZoneY + safeZoneH - _h],
        "bottomRight", [safeZoneX + safeZoneW - _w, safeZoneY + safeZoneH - _h],
        "top",         [safeZoneX + 0.5 * safeZoneW - 0.5 * _w, safeZoneY],
        "bottom",      [safeZoneX + 0.5 * safeZoneW - 0.5 * _w, safeZoneY + safeZoneH - _h],
        "center",      [safeZoneX + 0.5 * safeZoneW - 0.5 * _w, safeZoneY + 0.5 * safeZoneH - 0.5 * _h]
    ];

    // Default to bottom (centered)
    private _xy = [safeZoneX + 0.5 * safeZoneW - 0.5 * _w, safeZoneY + safeZoneH - _h];
    if (_positions find _posKeyword > -1) then {
        _xy = _positions select ((_positions find _posKeyword) + 1);
    };

    // Create Infobox
    private _display = findDisplay 46; // Main display (46)
    if (isNull _display) exitWith {};

    // Remove existing controls if present
    {
        private _ctrl = _display displayCtrl _x;
        if (!isNull _ctrl) then { ctrlDelete _ctrl; };
    } forEach [_bgIDC, _txtIDC];

    // Create background
    private _bg = _display ctrlCreate ["RscText", _bgIDC];
    _bg ctrlSetPosition [_xy select 0, _xy select 1, _w, _h];
    _bg ctrlSetBackgroundColor _bgColor;
    _bg ctrlCommit 0;

    // Create text
    private _txt = _display ctrlCreate ["RscStructuredText", _txtIDC];
    _txt ctrlSetPosition [_xy select 0, _xy select 1, _w, _h];
    _txt ctrlSetStructuredText parseText format[
        "<t align='center' size='0.7' color='%2'>%1</t>",
        _text,
        _fontColor
    ];
    _txt ctrlCommit 0;

    uiNamespace setVariable ["KTWK_EW_infobox_display", _display];
};
