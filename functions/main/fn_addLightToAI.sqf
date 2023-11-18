// Adds weapon lights or headlamps to units without NVGs, weapon lights or headlamps
// by kenoxite

if (!canSuspend) exitwith {_this spawn KTWK_fnc_addLightToAI};
sleep 3;
params ["_unit"];
if (!alive _unit) exitWith {false};
if (isPlayer _unit && !KTWK_AIlights_opt_players) exitWith {false};

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

if (!_hasNVG && {KTWK_AIlights_opt_NVGinv}) then {
    _hasNVG = [_unit] call KTWK_fnc_NVGcheckInv;
};

private _currentWpn = call {
    if (currentWeapon _unit == primaryWeapon _unit) exitwith {0};
    if (currentWeapon _unit == handgunWeapon _unit) exitwith {2};
    0
};
private _hasWepLights = [_unit, _currentWpn] call _fnc_checkFl;

private _hasHeadlamp = KTWK_WBKHeadlamps && {"WBK_HeadLampItem" in (items _unit)};
if (_hasNVG || (_hasWepLights && !KTWK_WBKHeadlamps) || _hasHeadlamp) exitWith {
    if (_hasWepLights) then {
        // Force activation
        if (KTWK_AIlights_opt_force) then {
            _unit spawn {
                sleep 5;
                [_this, "ForceOn"] remoteExec ["enableGunLights", _this];
            };
        };
    };
    false
};

// Assign headlamp or weapon light
private _knownFlashlights = [
    "acc_flashlight_smg_01",
    "acc_flashlight",

    // CUP
    "CUP_acc_flashlight",

    // RHS
    "rhs_acc_2dpZenit",
    "rhs_acc_2dpZenit_ris",
    "rhsusf_acc_M952V",
    "rhs_acc_perst3_2dp_light_h",
    "rhsusf_acc_wmx",
    "rhsusf_acc_wmx_bk",

    // GM
    "gm_flashlightp2_wht_ak74handguard_blu",
    "gm_flashlightp2_brk_ak74handguard_dino",
    "gm_flashlightp2_wht_akhandguard_blu",
    "gm_flashlightp2_wht_akhandguard_dino",
    "gm_surefire_l60_wht_bayonetg11_blk",
    "gm_surefire_l60_red_bayonetg11_blk",
    "gm_maglite_2d_hkslim_blk",
    "gm_flashlightp2_wht_akkhandguard_blu",
    "gm_flashlightp2_brk_akkhandguard_dino",
    "gm_surefire_l60_wht_surefire_blk",
    "gm_surefire_l60_red_surefire_blk",
    "gm_surefire_l60_wht_hoseclamp_blk",
    "gm_surefire_l60_red_hoseclamp_blk"
    ];
private _knownFlashlights_pistol = [
    "acc_flashlight_pistol",
    "acc_flashlight",
    "acc_esd_01_flashlight",

    // RHS
    "rhs_acc_2dpZenit_ris",
    "rhsusf_acc_M952V",
    "rhs_acc_perst1ik_ris",
    "rhsusf_acc_wmx",
    "rhsusf_acc_wmx_bk"
    ];
call {
    if (KTWK_WBKHeadlamps) exitWith {_unit addItem "WBK_HeadLampItem"};
    if (_currentWpn == 0) exitWith {
        {
            private _flashlight = (primaryWeaponItems _unit)#1;
            if (!isNil "_flashlight") then {
                if (_flashlight == "") then {
                    _unit addPrimaryWeaponItem _x;
                };
            };
        } forEach _knownFlashlights;
    };
    if (_currentWpn == 2) exitWith {
        {
            private _flashlight = (handgunItems _unit)#1;
            if (!isNil "_flashlight") then {
                if (_flashlight == "") then {
                    _unit addHandgunItem _x;
                };
            };
        } forEach _knownFlashlights_pistol;
    };
};

// Force activation
if (!KTWK_WBKHeadlamps && KTWK_AIlights_opt_force) then {
    _unit spawn {
        sleep 5;
        [_this, "ForceOn"] remoteExec ["enableGunLights", _this];
    };
};
