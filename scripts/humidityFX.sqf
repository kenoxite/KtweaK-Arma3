// Humidity FX by kenoxite
scriptName "Humidity Effects";

params [["_fog", []]];

if (count _fog > 0) then {
    0 setFog _fog;
};

waituntil { !isNull player };

private _player = call KTWK_fnc_playerUnit;
_player setVariable ["KTWK_altitude", (getPosASL (vehicle _player)) #2];
_player setVariable ["KTWK_isUnderwater", false];
_player setVariable ["KTWK_inBuilding", false];
_player setVariable ["KTWK_inVehicle", false];
_player setVariable ["KTWK_maxEffect", 0];

KTWK_HFX_lastFogParams = fogParams;
KTWK_HFX_inFog = false;
KTWK_HFX_fogFXactive = false;

private _audioEffectWasOn = KTWK_HFX_opt_activeEffects != 1;

private _scriptTimer = 0;
private _sleepTime = 0.5;
while {KTWK_HFX_opt_enabled} do {
    _scriptTimer = _scriptTimer + _sleepTime;
    private _audioEffectMod = [1, 0.75, 0.5] select KTWK_HFX_opt_intensity - 1;
    private _maxEffect = [0.5, 0.3, 0.15] select KTWK_HFX_opt_intensity - 1;
    private _player = call KTWK_fnc_playerUnit;
    private _altitude = (getPosASL (vehicle _player)) #2;
    // private _inBuilding = [_player] call KTWK_fnc_inBuilding;
    private _inBuilding = insideBuilding _player > 0.9;
    private _isOnFoot = isNull objectParent _player;
    private _insideVehicle = !_isOnFoot && !isTurnedOut _player && cameraView != "EXTERNAL" && cameraView != "GROUP" && cameraView != "GUNNER" && count (lineIntersectsWith [ (getPosASL _player) vectorAdd [0, 0, -0.07], (getPosASL _player) vectorAdd [0, 0, 3], _player]) > 0;
    private _fogParams = fogParams;
    private _fogValue = _fogParams #0;
    private _fogDecay = _fogParams #1;
    private _fogBase = _fogParams #2;
    private _fogSet = (_fogValue > 0 && _fogDecay > 0) && isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull]);
    private _altitudeMod = linearConversion [0, _fogBase + (_fogBase *_fogDecay), _altitude, 1, 0, true];
    private _altitudeDiff = (_fogBase - _altitude) max 0;
    private _effect = _fogValue * _altitudeMod;
    KTWK_HFX_effect = (_effect *_altitudeMod) min (_maxEffect min _fogValue);
    // if (_altitudeDiff > (_fogBase * 0.3)) then {KTWK_HFX_effect = _maxEffect};
    if ((_altitude + (eyePos _player select 2)) <= _fogBase) then {KTWK_HFX_effect = (_maxEffect min _fogValue)};
    if (_insideVehicle || _inBuilding) then { KTWK_HFX_effect = KTWK_HFX_effect min 0.2 };

    private _wasInFog = KTWK_HFX_inFog;
    private _isUnderwater = (eyePos _player) #2 < 0 && (cameraView == "INTERNAL" || cameraView == "GUNNER");
    KTWK_HFX_inFog = _fogSet && {_altitudeMod > 0 && !_isUnderwater};

    private _applyVisuals = KTWK_HFX_opt_activeEffects < 2;
    private _applyAudio = KTWK_HFX_opt_activeEffects == 0 || KTWK_HFX_opt_activeEffects == 2;

    // Apply humidity effects
    if (KTWK_HFX_inFog && !_wasInFog) then {
        private _delay = [_sleepTime, 0] select ((!_isUnderwater && (_player getVariable ["KTWK_isUnderwater", false])) || ((_player getVariable ["KTWK_inBuilding", false]) && !_inBuilding));
        // Visual
        KTWK_HFX_fog_handle = ppEffectCreate ["DynamicBlur", 401];
        KTWK_HFX_fogFXactive = true;
        if (_applyVisuals) then {
            KTWK_HFX_fog_handle ppEffectEnable true;
            KTWK_HFX_fog_handle ppEffectAdjust [KTWK_HFX_effect max 0];
            KTWK_HFX_fog_handle ppEffectCommit _delay;
        } else {
            KTWK_HFX_fog_handle ppEffectEnable false;
        };
        // Sound
        if (_applyAudio) then {
            _delay fadeSound (1 - (_altitudeMod * _audioEffectMod)) max 0.05;
            _delay fadeEnvironment (1 - (_altitudeMod * _audioEffectMod)) max 0;
            _delay fadeSpeech (1 - (_altitudeMod * _audioEffectMod)) max 0.05;
        };
        waitUntil {ppEffectCommitted KTWK_HFX_fog_handle};
        if (KTWK_debug) then { systemchat "Humidity FX enabled" };
    };

    // Update effects based on current altitude, inside a vehicle or building
    if (
        _fogSet
        && KTWK_HFX_fogFXactive
        && KTWK_HFX_inFog
        && _wasInFog
        && (
            abs(_altitude - (_player getVariable ["KTWK_altitude", 0])) > 1
            || !(KTWK_HFX_lastFogParams isEqualTo _fogParams)
            || ((_player getVariable ["KTWK_inVehicle", false]) != _insideVehicle)
            || ((_player getVariable ["KTWK_inBuilding", false]) != _inBuilding)
            || (_player getVariable ["KTWK_maxEffect", _maxEffect]) != _maxEffect
            )
        ) then {
        private _delay = _sleepTime;
        // Visual
        if (_applyVisuals) then {
            if (!isNil {KTWK_HFX_fog_handle}) then {
                KTWK_HFX_fog_handle ppEffectEnable true;
                KTWK_HFX_fog_handle ppEffectAdjust [KTWK_HFX_effect max 0];
                KTWK_HFX_fog_handle ppEffectCommit _delay;
            };
        } else {
            KTWK_HFX_fog_handle ppEffectEnable false;
        };
        // Sound
        if (_applyAudio) then {
            _delay fadeSound (1 - (_altitudeMod * _audioEffectMod)) max 0.05;
            _delay fadeEnvironment (1 - (_altitudeMod * _audioEffectMod)) max 0;
            _delay fadeSpeech (1 - (_altitudeMod * _audioEffectMod)) max 0.05;
        } else {
            if (_audioEffectWasOn) then {
                _delay fadeSound 1;
                _delay fadeEnvironment 1;
                _delay fadeSpeech 1;
            };
        };
        _player setVariable ["KTWK_altitude", _altitude];
        // waitUntil {ppEffectCommitted KTWK_HFX_fog_handle};
        if (KTWK_debug && (_scriptTimer mod 5) == 0) then { diag_log format ["Humidity FX tweaked - altitude: %1, limit altitude: %2, effect: %3, invehicle: %4", _altitude, _fogBase, KTWK_HFX_effect max 0, _insideVehicle] };
    };

    // Remove effects if player exits foggy area
    if (!_fogSet || {KTWK_HFX_fogFXactive && !KTWK_HFX_inFog && _wasInFog}) then {
        private _delay = [_sleepTime, 0] select _isUnderwater;
        // Restore sound levels
        if (_applyAudio) then {
            _delay fadeSound 1;
            _delay fadeEnvironment 1;
            _delay fadeSpeech 1;
            sleep _delay;
        };
        // Destroy blur effect
        if (!isNil {KTWK_HFX_fog_handle}) then {
            KTWK_HFX_fog_handle ppEffectEnable false;
            ppEffectDestroy KTWK_HFX_fog_handle;
            KTWK_HFX_fogFXactive = false;
            if (KTWK_debug) then { systemchat "Humidity FX disabled" };
        };
    };

    _player setVariable ["KTWK_isUnderwater", _isUnderwater];
    _player setVariable ["KTWK_inBuilding", _inBuilding];
    _player setVariable ["KTWK_inVehicle", _insideVehicle];
    _player setVariable ["KTWK_maxEffect", _maxEffect];
    KTWK_HFX_lastFogParams = _fogParams;

    _audioEffectWasOn = KTWK_HFX_opt_activeEffects != 1;

    sleep _sleepTime;
};

// Deactivate humidity effects
if (!isNil "KTWK_HFX_fog_handle") then {
    private _delay = 0;
    if (_audioEffectWasOn) then {
        _delay fadeSound 1;
        _delay fadeEnvironment 1;
        _delay fadeSpeech 1;
        sleep _delay;
    };
    KTWK_HFX_fog_handle ppEffectEnable false;
    ppEffectDestroy KTWK_HFX_fog_handle;
    KTWK_HFX_fogFXactive = false; 
};
if (KTWK_debug) then { systemchat "Humidity FX terminated" };

waitUntil {sleep 1; KTWK_HFX_opt_enabled};

[] execVM "KtweaK\scripts\humidityFX.sqf";
