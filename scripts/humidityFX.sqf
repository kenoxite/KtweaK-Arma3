// Humidity FX by kenoxite
scriptName "Humidity Effects";

params [["_fog", []]];

if (count _fog > 0) then {
    0 setFog _fog;
};

waituntil { !isNull player };

private _player = call KTWK_fnc_playerUnit;
KTWK_HFX_inFog = false;
KTWK_HFX_wasUnderwater = false;
KTWK_HFX_wasInBuilding = false;
KTWK_HFX_wasInsideVehicle = false;
KTWK_HFX_lastAltitude = (getPosASL (vehicle _player)) #2;
KTWK_HFX_lastFogParams = fogParams;
KTWK_HFX_soundVolume = soundVolume;
KTWK_HFX_environmentVolume = environmentVolume;
KTWK_HFX_speechVolume = speechVolume;
KTWK_HFX_radioVolume = radioVolume;
KTWK_HFX_initialSoundVolume = 1;
KTWK_HFX_initialEnvironmentVolume = 1;
KTWK_HFX_initialSpeechVolume = 1;
KTWK_HFX_initialRadioVolume = 1;
KTWK_HFX_fogFXactive = false;
KTWK_HFX_audioFXmod = 4;

private _audioEffectWasOn = KTWK_HFX_opt_activeEffects != 1;
private _scriptTimer = 0;
private _sleepTime = 0.5;
while {KTWK_HFX_opt_enabled} do {
    _scriptTimer = _scriptTimer + _sleepTime;
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
    private _maxEffect = [0.6, 0.4, 0.2] select KTWK_HFX_opt_intensity - 1;
    KTWK_HFX_effect = linearConversion [0, _altitude, (_fogBase - _altitude) * _fogValue * _fogDecay * 10, 0, _maxEffect, true];
    if (_insideVehicle || _inBuilding) then { KTWK_HFX_effect = KTWK_HFX_effect min 0.2 };

    private _wasInFog = KTWK_HFX_inFog;
    private _isUnderwater = eyePos _player #2 < 0 && (cameraView == "INTERNAL" || cameraView == "GUNNER");
    KTWK_HFX_inFog = _fogSet && {_altitude < _fogBase && !_isUnderwater};

    // Apply humidiy effects
    if (KTWK_HFX_inFog && !_wasInFog) then {
        private _delay = [3, 0] select ((!_isUnderwater && KTWK_HFX_wasUnderwater) || (KTWK_HFX_wasInBuilding && !_inBuilding));
        // Visual
        KTWK_HFX_fog_handle = ppEffectCreate ["DynamicBlur", 401];
        KTWK_HFX_fogFXactive = true;
        if (KTWK_HFX_opt_activeEffects < 2) then {
            KTWK_HFX_fog_handle ppEffectEnable true;
            KTWK_HFX_fog_handle ppEffectAdjust [KTWK_HFX_effect max 0];
            KTWK_HFX_fog_handle ppEffectCommit _delay;
        } else {
            KTWK_HFX_fog_handle ppEffectEnable false;
        };
        // Sound
        if (KTWK_HFX_opt_activeEffects == 0 || KTWK_HFX_opt_activeEffects == 2) then {
            KTWK_HFX_soundVolume = soundVolume;
            KTWK_HFX_environmentVolume = environmentVolume;
            KTWK_HFX_speechVolume = speechVolume;
            KTWK_HFX_radioVolume = radioVolume;
            _delay fadeSound ((KTWK_HFX_soundVolume - (KTWK_HFX_effect * KTWK_HFX_audioFXmod))) max 0.05;
            _delay fadeEnvironment ((KTWK_HFX_environmentVolume - (KTWK_HFX_effect * KTWK_HFX_audioFXmod))) max 0;
            _delay fadeSpeech ((KTWK_HFX_speechVolume - (KTWK_HFX_effect * KTWK_HFX_audioFXmod))) max 0.05;
            _delay fadeRadio KTWK_HFX_radioVolume;
        };
        waitUntil {ppEffectCommitted KTWK_HFX_fog_handle};
        if (KTWK_debug) then { systemchat "Humidity FX enabled" };
    };

    // Update effects based on current altitude, inside a vehicle or building
    if (_fogSet && KTWK_HFX_fogFXactive && KTWK_HFX_inFog && _wasInFog && (abs(_altitude - KTWK_HFX_lastAltitude) > 1 || !(KTWK_HFX_lastFogParams isEqualTo _fogParams)) || (KTWK_HFX_wasInsideVehicle != _insideVehicle) || (KTWK_HFX_wasInBuilding != _inBuilding)) then {
        private _delay = 1;
        // Visual
        if (KTWK_HFX_opt_activeEffects < 2) then {
            KTWK_HFX_fog_handle ppEffectEnable true;
            KTWK_HFX_fog_handle ppEffectAdjust [KTWK_HFX_effect max 0];
            KTWK_HFX_fog_handle ppEffectCommit _delay;
        } else {
            KTWK_HFX_fog_handle ppEffectEnable false;
        };
        // Sound
        if (KTWK_HFX_opt_activeEffects == 0 || KTWK_HFX_opt_activeEffects == 2) then {
            _delay fadeSound (KTWK_HFX_soundVolume - (KTWK_HFX_effect * KTWK_HFX_audioFXmod)) max 0.05;
            _delay fadeEnvironment (KTWK_HFX_environmentVolume - (KTWK_HFX_effect * KTWK_HFX_audioFXmod)) max 0;
            _delay fadeSpeech (KTWK_HFX_speechVolume - (KTWK_HFX_effect * KTWK_HFX_audioFXmod)) max 0.05;
            _delay fadeRadio KTWK_HFX_radioVolume;
        } else {
            if (_audioEffectWasOn) then {
                _delay fadeSound KTWK_HFX_initialSoundVolume;
                _delay fadeEnvironment KTWK_HFX_initialEnvironmentVolume;
                _delay fadeSpeech KTWK_HFX_initialSpeechVolume;
                _delay fadeRadio KTWK_HFX_initialRadioVolume;
            };
        };
        KTWK_HFX_lastAltitude = _altitude;
        // waitUntil {ppEffectCommitted KTWK_HFX_fog_handle};
        if (KTWK_debug && (_scriptTimer mod 5) == 0) then { diag_log format ["Humidity FX tweaked - altitude: %1, limit altitude: %2, effect: %3, invehicle: %4", _altitude, _fogBase, KTWK_HFX_effect max 0, _insideVehicle] };
    };

    // Remove effects if player exits foggy area
    if (!_fogSet || {KTWK_HFX_fogFXactive && !KTWK_HFX_inFog && _wasInFog}) then {
        private _delay = [3, 0] select _isUnderwater;
        // Restore sound levels
        _delay fadeSound KTWK_HFX_soundVolume;
        _delay fadeEnvironment KTWK_HFX_environmentVolume;
        _delay fadeSpeech KTWK_HFX_speechVolume;
        _delay fadeRadio KTWK_HFX_radioVolume;
        sleep _delay;
        // Destroy blur effect
        if (!isNil {KTWK_HFX_fog_handle}) then {
            KTWK_HFX_fog_handle ppEffectEnable false;
            ppEffectDestroy KTWK_HFX_fog_handle;
            KTWK_HFX_fogFXactive = false;
            if (KTWK_debug) then { systemchat "Humidity FX disabled" };
        };
    };

    KTWK_HFX_wasUnderwater = _isUnderwater;
    KTWK_HFX_wasInBuilding = _inBuilding;
    KTWK_HFX_wasInsideVehicle = _insideVehicle;
    KTWK_HFX_lastFogParams = _fogParams;

    _audioEffectWasOn = KTWK_HFX_opt_activeEffects != 1;

    sleep _sleepTime;
};

// Deactivate humidity effects
if (!isNil "KTWK_HFX_fog_handle") then {
    private _delay = 0;
    _delay fadeSound KTWK_HFX_initialSoundVolume;
    _delay fadeEnvironment KTWK_HFX_initialEnvironmentVolume;
    _delay fadeSpeech KTWK_HFX_initialSpeechVolume;
    _delay fadeRadio KTWK_HFX_initialRadioVolume;
    sleep _delay;
    KTWK_HFX_fog_handle ppEffectEnable false;
    ppEffectDestroy KTWK_HFX_fog_handle;
    KTWK_HFX_fogFXactive = false;   
};
if (KTWK_debug) then { systemchat "Humidity FX terminated" };

waitUntil {sleep 1; KTWK_HFX_opt_enabled};

[] execVM "KtweaK\scripts\humidityFX.sqf";
