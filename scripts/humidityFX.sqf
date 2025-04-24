// Humidity FX by kenoxite
scriptName "Humidity Effects";

params [["_fog", []]];

if (count _fog > 0) then {
    0 setFog _fog;
};

waituntil { !isNull player };

private _player = call CBA_fnc_currentUnit;
_player setVariable ["KTWK_isUnderwater", false];
_player setVariable ["KTWK_inBuilding", false];
_player setVariable ["KTWK_inVehicle", false];
_player setVariable ["KTWK_maxEffect", 0];

KTWK_HFX_lastFogParams = fogParams;
KTWK_HFX_inFog = false;
KTWK_HFX_fogFXactive = false;

private _applyAudioFXLast = KTWK_HFX_opt_activeEffects != 1;

private _scriptTimer = 0;
private _sleepTime = 0.5;
while {KTWK_HFX_opt_enabled} do {
    _scriptTimer = _scriptTimer + _sleepTime;

    // Set intensity to low and disable audio FX if in Livonia while playing Contact campaign
    if (worldName == "Enoch" && !isNil {bin_player}) then {
        KTWK_HFX_opt_intensity = 3;
        KTWK_HFX_opt_activeEffects = 1;
    };

    private _visualFXMod = [1, 0.5, 0.25] select KTWK_HFX_opt_intensity - 1;
    private _audioFXMod = [1.5, 1, 0.75] select KTWK_HFX_opt_intensity - 1;
    private _player = call CBA_fnc_currentUnit;
    private _fogDensityLast = _player getVariable ["KTWK_fogDensity", 0];
    private _insideVehicleLast = _player getVariable ["KTWK_inVehicle", false];
    private _inBuildingLast = _player getVariable ["KTWK_inBuilding", false];
    private _underwaterLast = _player getVariable ["KTWK_isUnderwater", false];

    private _eyePos = (eyePos _player) #2;
    private _alt = (getPosASL (vehicle _player)) #2;
    private _inBuilding = insideBuilding _player > 0.9;
    private _isOnFoot = isNull objectParent _player;
    private _thirdPerson = cameraView == "EXTERNAL" || cameraView == "GROUP";
    private _insideVehicle = !_isOnFoot && !isTurnedOut _player && !_thirdPerson && cameraView != "GUNNER" && count (lineIntersectsWith [ (getPosASL _player) vectorAdd [0, 0, -0.07], (getPosASL _player) vectorAdd [0, 0, 3], _player]) > 0;
    private _altitude = [_eyePos, _alt] select _thirdPerson;
    private _fogParams = fogParams;
    private _fogValue = _fogParams #0;
    private _fogDecay = _fogParams #1;
    private _fogBase = _fogParams #2;
    private _fogSet = (_fogValue > 0 && _fogDecay > 0) && isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull]);

    private _decayMod = (1 - (_fogDecay * (_altitude - _fogBase))) min 1;
    private _fogDensity = ((_fogValue * _decayMod) min _fogValue) max 0;
    if (_fogDecay <= 0.03) then { _fogDensity = _fogDensity max (_fogValue * 0.15) };
    KTWK_HFX_effect = _fogDensity * _visualFXMod;

    if (_insideVehicle || _inBuilding) then { KTWK_HFX_effect = KTWK_HFX_effect min 0.2 };

    private _wasInFog = KTWK_HFX_inFog;
    private _isUnderwater = _eyePos < 0 && (cameraView == "INTERNAL" || cameraView == "GUNNER");
    KTWK_HFX_inFog = _fogSet && {_fogDensity > 0 && !_isUnderwater};

    private _applyVisualFX = KTWK_HFX_opt_activeEffects < 2;
    private _applyAudioFX = KTWK_HFX_opt_activeEffects == 0 || KTWK_HFX_opt_activeEffects == 2;

    // ACE compatibility
    if (!isNil {ace_hearing_enableCombatDeafness} && {ace_hearing_enableCombatDeafness}) then { _applyAudioFX = false };  // Disable audio FX if ACE Hearing is enabled
    if (!isNil {acex_volume_enabled} && {acex_volume_enabled}) then { _applyAudioFX = false };  // Disable audio FX if ACE Volume is enabled

    // Apply humidity effects
    if (KTWK_HFX_inFog && !_wasInFog) then {
        private _delay = [_sleepTime, 0] select ((!_isUnderwater && _underwaterLast) || (_inBuildingLast && !_inBuilding));
        // Visual
        KTWK_HFX_fog_handle = ppEffectCreate ["DynamicBlur", 401];
        KTWK_HFX_fogFXactive = true;
        if (_applyVisualFX) then {
            KTWK_HFX_fog_handle ppEffectEnable true;
            KTWK_HFX_fog_handle ppEffectAdjust [KTWK_HFX_effect];
            KTWK_HFX_fog_handle ppEffectCommit _delay;
        } else {
            KTWK_HFX_fog_handle ppEffectEnable false;
        };
        // Sound
        if (_applyAudioFX) then {
            _delay fadeSound (1 - (_fogDensity * _audioFXMod)) max 0.05;
            _delay fadeEnvironment (1 - (_fogDensity * _audioFXMod)) max 0;
            _delay fadeSpeech (1 - (_fogDensity * _audioFXMod)) max 0.05;
        };
        waitUntil {ppEffectCommitted KTWK_HFX_fog_handle};
        if (KTWK_opt_debug) then { systemchat "Humidity FX enabled" };
    };

    // Update effects if values of fog, fog density, inside a vehicle or building have changed
    if (
        _fogSet
        && KTWK_HFX_fogFXactive
        && KTWK_HFX_inFog
        && _wasInFog
        && (
            !(KTWK_HFX_lastFogParams isEqualTo _fogParams)
            || abs (_fogDensityLast - _fogDensity) >= 0.05
            || _insideVehicleLast != _insideVehicle
            || _inBuildingLast != _inBuilding
            )
        ) then {
        private _delay = _sleepTime;
        // Visual
        if (_applyVisualFX) then {
            if (!isNil {KTWK_HFX_fog_handle}) then {
                KTWK_HFX_fog_handle ppEffectEnable true;
                KTWK_HFX_fog_handle ppEffectAdjust [KTWK_HFX_effect];
                KTWK_HFX_fog_handle ppEffectCommit _delay;
            };
        } else {
            KTWK_HFX_fog_handle ppEffectEnable false;
        };
        // Sound
        if (_applyAudioFX) then {
            _delay fadeSound (1 - (_fogDensity * _audioFXMod)) max 0.05;
            _delay fadeEnvironment (1 - (_fogDensity * _audioFXMod)) max 0;
            _delay fadeSpeech (1 - (_fogDensity * _audioFXMod)) max 0.05;
        } else {
            if (_applyAudioFXLast) then {
                _delay fadeSound 1;
                _delay fadeEnvironment 1;
                _delay fadeSpeech 1;
            };
        };
        // waitUntil {ppEffectCommitted KTWK_HFX_fog_handle};
        if (KTWK_opt_debug && (_scriptTimer mod 5) == 0) then { diag_log format ["Humidity FX tweaked - altitude: %1, fog base: %2, fog density: %3, effect: %4, invehicle: %5", _altitude, _fogBase, _fogDensity, KTWK_HFX_effect, _insideVehicle] };
    };

    // Remove effects if player exits foggy area
    if (!_fogSet || {KTWK_HFX_fogFXactive && !KTWK_HFX_inFog && _wasInFog}) then {
        private _delay = [_sleepTime, 0] select _isUnderwater;
        // Restore sound levels
        if (_applyAudioFX) then {
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
            if (KTWK_opt_debug) then { systemchat "Humidity FX disabled" };
        };
    };

    _player setVariable ["KTWK_isUnderwater", _isUnderwater];
    _player setVariable ["KTWK_inBuilding", _inBuilding];
    _player setVariable ["KTWK_inVehicle", _insideVehicle];
    _player setVariable ["KTWK_fogDensity", _fogDensity];
    KTWK_HFX_lastFogParams = _fogParams;

    _applyAudioFXLast = _applyAudioFX;

    sleep _sleepTime;
};

// Deactivate humidity effects
if (!isNil "KTWK_HFX_fog_handle") then {
    private _delay = 0;
    if (_applyAudioFXLast) then {
        _delay fadeSound 1;
        _delay fadeEnvironment 1;
        _delay fadeSpeech 1;
        sleep _delay;
    };
    KTWK_HFX_fog_handle ppEffectEnable false;
    ppEffectDestroy KTWK_HFX_fog_handle;
    KTWK_HFX_fogFXactive = false; 
};
if (KTWK_opt_debug) then { systemchat "Humidity FX terminated" };

waitUntil {sleep 1; KTWK_HFX_opt_enabled};

[] execVM "KtweaK\scripts\humidityFX.sqf";
