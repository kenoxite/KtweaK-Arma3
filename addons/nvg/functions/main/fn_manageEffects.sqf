// KTWK_NVG_fnc_manageEffects
// Creates or destroys effects based on active state
//
// Parameters:
//   _shouldBeActive - Boolean: effects should be active
// Returns:
//   Nothing

params ["_shouldBeActive"];

if (!_shouldBeActive) then {
    if (KTWK_NVG_effectsActive) then {
        { ppEffectDestroy _x } forEach [KTWK_NVG_ppBlur, KTWK_NVG_ppColor, KTWK_NVG_ppFilm, KTWK_NVG_ppChrom];
        KTWK_NVG_effectsActive = false;
        KTWK_NVG_lastBlurArray = [];
        KTWK_NVG_lastColorArray = [];
        KTWK_NVG_lastFilmArray = [];
        KTWK_NVG_lastChromArray = [];
    };
} else {
    if (!KTWK_NVG_effectsActive) then {
        call KTWK_NVG_fnc_initSystem;
        KTWK_NVG_effectsActive = true;
        KTWK_NVG_lastBlurArray = [];
        KTWK_NVG_lastColorArray = [];
        KTWK_NVG_lastFilmArray = [];
        KTWK_NVG_lastChromArray = [];
    };
};
