// KTWK_NVG_fnc_color
// Returns colorize array based on selected phosphor preset
//
// Parameters:
//   _preset - Optional preset override (0 = None, 1 = Green, 2 = White Phosphor, 3 = Amber, 4 = White, 5 = Crimson)
// Returns:
//   Array - Colorize array for ppEffectAdjust

params [["_preset", KTWK_NVG_opt_color]];

call {
    if (_preset == 1) exitWith { [0.263,0.58,0.075, 0] };  // Green
    if (_preset == 2) exitWith { [0.7, 0.92, 0.95, 0] };  // White Phosphor
    if (_preset == 3) exitWith { [0.96, 0.98, 0.45, 0] };  // Amber
    if (_preset == 4) exitWith { [1, 1, 1, 0] };              // White
    if (_preset == 5) exitWith { [1.0, 0.75, 0.75, 0] };  // Crimson
    [1, 1, 1, 1]  // Vanilla
};
