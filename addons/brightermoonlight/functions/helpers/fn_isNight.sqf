// KTWK_BM_fnc_isNight
// Returns true during night based on aperture value
//
// Parameters:
//   None
// Returns:
//   Boolean - true if aperture <= 5.5, false otherwise

(apertureParams select 3) <= 5.5
