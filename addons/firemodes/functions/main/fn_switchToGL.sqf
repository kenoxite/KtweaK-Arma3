// KTWK_CFM_fnc_switchToGL
// Switches to underbarrel grenade launcher on current weapon if available, preserving firemode state for return switching
//
// Parameters:
//   _unit - Unit to switch GL on (default: KTWK_player)
// Returns:
//   Boolean - False if operation fails (switching weapon, no weapon, no GL, or already on GL), otherwise switches and returns nil

params [["_unit", KTWK_player], ["_cycle", false]];
if (isSwitchingWeapon _unit) exitWith {false};

missionNamespace setVariable ["KTWK_CFM_selectingGL", true];
private _weapon = currentWeapon _unit;
if (_weapon == "") exitWith {false};

private _glMuzzle = _unit weaponsInfo [_weapon, false] select { (_x#3) != _weapon };
if (_glMuzzle isNotEqualTo []) exitWith { 
    private _muzzle = (_glMuzzle#0) # 4;
    (_glMuzzle#0) params ["","", "_weapon", "_muzzle", "_firemode"];
    if (_muzzle == missionNamespace getVariable ["KTWK_CFM_lastMuzzle", ""]) exitWith {
        // Change back to normal mode
        if (_cycle) exitWith {
            [_unit, 0] call KTWK_CFM_fnc_cycleFiremode;
        };
    };

    _unit selectWeapon [_weapon, _muzzle, _firemode];
    missionNamespace setVariable ["KTWK_CFM_lastFiremode", _firemode];
    missionNamespace setVariable ["KTWK_CFM_lastMuzzle", _muzzle];
    missionNamespace setVariable ["KTWK_CFM_selectingGL", false];
};
