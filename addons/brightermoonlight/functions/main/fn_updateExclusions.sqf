// KTWK_BML_fnc_updateExclusions
// Parses exclusion settings and resolves magic words to terrain names
//
// Parameters:
//   None
// Returns:
//   Nothing

private _settingScope = ["client", "server"] select (isServer);

private _excluded = [
    "sefrouramal",
    "dingor",
    "optre_eridanussecundus",
    "optre_phobos",
    "chernarus_winter",
    "swu_public_salman_map",
    "uzbin"
] apply {toLowerANSI _x};

if ("juju_" in worldName) then {_excluded pushBack toLowerANSI worldName};

KTWK_BML_excluded = +_excluded;

private _result = [KTWK_BML_opt_excludeTerrains] call KTWK_BML_fnc_resolveMagicWords;

if (_result isNotEqualTo []) then {
    private _newExcluded = (_result # 0) apply { toLowerANSI _x };
    KTWK_BML_excluded append _newExcluded;
    if ((_result # 1) != "") then {
        ["KTWK_BML_opt_excludeTerrains", _result # 1, 0, _settingScope, true] call CBA_settings_fnc_set;
    };
};
