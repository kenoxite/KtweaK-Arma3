// crouchMoveStamina.sqf
// Adds extra fatigue drain while moving in a crouched stance.

// Factor to control the intensity of the effect. Higher = more stamina drain
CROUCH_FATIGUE_FACTOR = 0.00007;

[{
    params ["_args", "_handle"];
    private _unit = KTWK_player;

    // Check if the player is alive, local, and on foot
    if (
        KTWK_opt_crouchMoveIsTiring
        && {alive _unit}
        && {[_unit] call KTWK_fnc_isHuman}
        && {isNull objectParent _unit}
        ) then {

        // Check if player is crouched AND moving (speed > 0)
        if ((stance _unit == "CROUCH") && ((speed _unit) > 0.3)) then {

            // Get current fatigue
            private _currentFatigue = getFatigue _unit;

            // Add a small amount of fatigue based on the factor
            private _newFatigue = _currentFatigue + (CROUCH_FATIGUE_FACTOR * (abs (speed _unit)));

            // Apply the new fatigue, capped at 1 (max)
            _unit setFatigue (_newFatigue min 1);
        };
    };
}, 0, []] call CBA_fnc_addPerFrameHandler;
