// Adds weapon lights or headlamps to units without NVGs, weapon lights or headlamps
// by kenoxite

if (!canSuspend) exitwith {_this spawn KTWK_fnc_addLightToAI};
sleep 3;
params ["_unit"];
if (!alive _unit) exitWith {false};
if (isPlayer _unit) exitWith {false};

private _fnc_checkFl = {
    params ["_unit", "_currentWpn"];
    private _flashlight = call {
        if (_currentWpn == 0) exitWith {(primaryWeaponItems _unit)#1};
        if (_currentWpn == 2) exitWith {(handgunItems _unit)#1};
        ""
    };
    !isNil "_flashlight" && {_flashlight != ""}
};

private _hasNVG = [_unit] call KTWK_fnc_NVGcheck;

private _currentWpn = call {
    if (currentWeapon _unit == primaryWeapon _unit) exitwith {0};
    if (currentWeapon _unit == handgunWeapon _unit) exitwith {2};
    0
};
private _hasWepLights = [_unit, _currentWpn] call _fnc_checkFl;

private _hasHeadlamp = KTWK_WBKHeadlamps && {"WBK_HeadLampItem" in (items _unit)};
if (_hasNVG || (_hasWepLights && !KTWK_WBKHeadlamps) || _hasHeadlamp) exitWith {
    if (_hasWepLights) exitWith {
        // Force activation
        _unit spawn {
            sleep 5;
            [_this, "ForceOn"] remoteExec ["enableGunLights", _this];
        };
    };
    false
};

// Assign headlamp or weapon light
call {
    if (KTWK_WBKHeadlamps) exitWith {_unit addItem "WBK_HeadLampItem"};
    if (_currentWpn == 0) exitWith {_unit addPrimaryWeaponItem "acc_flashlight"};
    if (_currentWpn == 2) exitWith {_unit addHandgunItem "acc_flashlight_pistol"};
};

// Force activation
if (!KTWK_WBKHeadlamps) then {
    _unit spawn {
        sleep 5;
        [_this, "ForceOn"] remoteExec ["enableGunLights", _this];
    };
};
