// Adds weapon lights or headlamps to units without NVGs, weapon lights or headlamps
// by kenoxite

if (!canSuspend) exitwith {_this spawn KTWK_fnc_addLightToAI};
sleep 3;
params ["_unit"];
if (!alive _unit) exitWith {false};
if (isPlayer _unit && !KTWK_AIlights_opt_players) exitWith {false};

private _fnc_checkFl = {
    params ["_unit", "_currentWpnType"];
    private _flashlight = call {
        if (_currentWpnType == 0) exitWith {(primaryWeaponItems _unit)#1};
        if (_currentWpnType == 2) exitWith {(handgunItems _unit)#1};
        ""
    };
    !isNil "_flashlight" && {_flashlight != ""}
};

private _hasNVG = [_unit] call KTWK_fnc_NVGcheck;

if (!_hasNVG && {KTWK_AIlights_opt_NVGinv}) then {
    _hasNVG = [_unit] call KTWK_fnc_NVGcheckInv;
};

private _currentWpn = currentWeapon _unit;
private _currentWpnType = call {
    if (_currentWpn == primaryWeapon _unit) exitwith {0};
    if (_currentWpn == handgunWeapon _unit) exitwith {2};
    0
};
private _hasWepLights = [_unit, _currentWpnType] call _fnc_checkFl;

private _opt_headlampType = KTWK_AIlights_opt_headlampType;
private _opt_allowHandFL = KTWK_AIlights_opt_allowHandFL;
private _unitItems = items _unit;
private _hasHeadlamp = false;
private [
    "_WBKheadlamps",
    "_WBKshoulderFl",
    "_WBKlanterns",
    "_WBKhandfl",
    "_allWBKFlashlights"
];
if (_opt_headlampType > 0) then {
    _WBKheadlamps = [
        "WBK_HeadLampItem",
        "WBK_HeadLampItem_Long",
        "WBK_HeadLampItem_Narrow",
        "WBK_HeadLampItem_Double"
    ];
    _WBKshoulderFl = [
        "WBK_ShoulderLampItem_Regular",
        "WBK_ShoulderLampItem_Strong",
        "WBK_ShoulderLampItem_Weak"
    ];
    _WBKlanterns = [
        "WBK_LampItem_Black",
        "WBK_LampItem_Blue",
        "WBK_LampItem_Green",
        "WBK_LampItem_Red"
    ];
    _WBKhandfl = [
        "WBK_HandFlashlight",
        "WBK_HandFlashlight_Strong",
        "WBK_HandFlashlight_Weak"
    ];
    _allWBKFlashlights = _WBKheadlamps + _WBKshoulderFl + _WBKlanterns + _WBKhandfl;
    _hasHeadlamp = KTWK_WBKHeadlamps && {count (_unitItems arrayIntersect _allWBKFlashlights) > 0};
};

if (_hasNVG || (_hasWepLights && !KTWK_WBKHeadlamps) || _hasHeadlamp) exitWith {
    if (_hasWepLights && !_hasNVG && !_hasHeadlamp) then {
        // Force activation
        if (KTWK_AIlights_opt_force) then {
            _unit spawn {
                sleep 5;
                if (!isNull _this) then {
                    [_this, "ForceOn"] remoteExec ["enableGunLights", _this];
                };
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
    "gm_surefire_l60_red_hoseclamp_blk",

    // WS
    "saber_light_lxWS",
    "saber_light_arid_lxWS",
    "saber_light_khaki_lxWS",
    "saber_light_lush_lxWS",
    "saber_light_sand_lxWS",
    "saber_light_snake_lxWS",

    // JCA
    "JCA_acc_flashlight_khaki_F",
    "JCA_acc_flashlight_sand_F",
    "JCA_acc_flashlight_tactical_black",
    "JCA_acc_flashlight_tactical_olive",
    "JCA_acc_flashlight_tactical_sand"
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
    // Add WBK lights
    if (KTWK_WBKHeadlamps && _opt_headlampType > 0) exitWith {
        // Add hand held fl
        if (_opt_allowHandFL > 0 && {_currentWpn == "" || _currentWpn == handgunWeapon _unit}) exitwith {
            if (_opt_allowHandFL < 4) exitwith {
                _unit addItem (_WBKhandfl select (_opt_allowHandFL - 1));
            };
            _unit addItem (selectRandom _WBKhandfl);
        };
        // Add other types based on preference
        if (_opt_headlampType < 12) exitwith {
           _unit addItem (_allWBKFlashlights select (_opt_headlampType - 1));
        };
        if (_opt_headlampType == 12) exitwith {
           _unit addItem (selectRandom _WBKheadlamps);
        };
        if (_opt_headlampType == 13) exitwith {
           _unit addItem (selectRandom _WBKshoulderFl);
        };
        if (_opt_headlampType == 14) exitwith {
           _unit addItem (selectRandom _WBKlanterns);
        };
        if (_opt_headlampType == 15) exitwith {
           _unit addItem (selectRandom (_WBKheadlamps + _WBKshoulderFl + _WBKlanterns));
        };
    };

    // Add primary wpn light
    if (_currentWpnType == 0) exitWith {
        {
            private _flashlight = (primaryWeaponItems _unit)#1;
            if (!isNil "_flashlight") then {
                if (_flashlight == "") then {
                    _unit addPrimaryWeaponItem _x;
                };
            };
        } forEach _knownFlashlights;
    };
    // Add handgun light
    if (_currentWpnType == 2) exitWith {
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
