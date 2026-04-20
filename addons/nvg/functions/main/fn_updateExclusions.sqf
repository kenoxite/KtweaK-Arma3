// KTWK_NVG_fnc_updateExclusions
// Parses exclusion settings and resolves magic words to class names
//
// Parameters:
//   None
// Returns:
//   Nothing

private _settingScope = ["client", "server"] select (isServer);

private _globalResult = [KTWK_NVG_opt_excludeGlobal] call KTWK_NVG_fnc_resolveMagicWords;
if (_globalResult isNotEqualTo []) then {
    KTWK_NVG_excludeGlobal = _globalResult # 0;
    if ((_globalResult # 1) != "") then {
        ["KTWK_NVG_opt_excludeGlobal", _globalResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
    };
} else {
    KTWK_NVG_excludeGlobal = [];
};

private _autoGenResult = [KTWK_NVG_opt_excludeAutoGen] call KTWK_NVG_fnc_resolveMagicWords;
if (_autoGenResult isNotEqualTo []) then {
    KTWK_NVG_excludeAutoGen = _autoGenResult # 0;
    if ((_autoGenResult # 1) != "") then {
        ["KTWK_NVG_opt_excludeAutoGen", _autoGenResult # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
    };
} else {
    KTWK_NVG_excludeAutoGen = [];
};
